import {onRequest, onCall, HttpsError} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {setGlobalOptions} from "firebase-functions/v2";
import cors from "cors";
import {initializeApp} from "firebase-admin/app";
import {getAuth} from "firebase-admin/auth";
import {getFirestore, FieldValue} from "firebase-admin/firestore";

import {computeRecovery} from "./engines/recoveryEngine";
import {
  computeStrain,
  Modality,
  STRAIN_A,
} from "./engines/strainEngine";
import {computeRecommendation} from "./engines/recommendationEngine";
import {buildSmartPlan} from "./engines/smartPlanningEngine";
import {GoalInput, PlannerInput} from "./engines/plannerTypes";
import {
  getActiveGoals,
  updateGoalProgressForSession,
  reverseGoalProgressForSession,
  resetWeeklyGoalsForAllUsers,
} from "./services/goalService";
import {yesterdayKeyUTC} from "./utils/dateKey";

initializeApp();
const db = getFirestore();

setGlobalOptions({maxInstances: 10, region: "us-central1"});

const corsHandler = cors({origin: true});

// Rounding to 2 d.p. for UI.
const r2 = (n: number) => Math.round(n * 100) / 100;

/**
 * Deletes every document in a known user-owned subcollection.
 * @param {FirebaseFirestore.DocumentReference} userRef User document reference.
 * @param {string} collectionName Name of the subcollection to delete.
 * @return {Promise<number>} Number of deleted documents.
 */
async function deleteUserSubcollection(
  userRef: FirebaseFirestore.DocumentReference,
  collectionName: string
): Promise<number> {
  const snapshot = await userRef.collection(collectionName).get();

  let batch = db.batch();
  let operationCount = 0;
  let deletedCount = 0;

  for (const doc of snapshot.docs) {
    batch.delete(doc.ref);
    operationCount += 1;
    deletedCount += 1;

    if (operationCount === 400) {
      await batch.commit();
      batch = db.batch();
      operationCount = 0;
    }
  }

  if (operationCount > 0) {
    await batch.commit();
  }

  return deletedCount;
}

/**
 * Builds a default day document so the frontend always receives
 * a stable Firestore shape.
 * @param {string} dateKey Day key in YYYY-MM-DD format.
 * @return {{
 *   dateKey: string,
 *   updatedAt: FirebaseFirestore.FieldValue,
 *   inputs: {
 *     sleepHours: number,
 *     sleepQuality: number,
 *     hadRestDay: boolean
 *   },
 *   strain: {
 *     totalLAdj: number,
 *     score: number,
 *     sessionCount: number
 *   },
 *   recovery: {
 *     score: number,
 *     state: "yellow",
 *     guidance: string
 *   },
 *   recommendation: {
 *     type: string,
 *     title: string,
 *     subtitle: string
 *   }
 * }} Default day document payload.
 */
function buildDefaultDayDoc(dateKey: string) {
  return {
    dateKey,
    updatedAt: FieldValue.serverTimestamp(),
    inputs: {
      sleepHours: 0,
      sleepQuality: 3,
      hadRestDay: false,
    },
    strain: {
      totalLAdj: 0,
      score: 0,
      sessionCount: 0,
    },
    recovery: {
      score: 0,
      state: "yellow" as const,
      guidance: "Add sleep to personalise recovery.",
    },
    recommendation: {
      type: "moderate",
      title: "Awaiting inputs",
      subtitle:
        "Add sleep and recovery inputs to personalise today’s guidance.",
    },
  };
}

/**
 * Converts accumulated adjusted load into the 0-21 daily strain scale.
 * @param {number} totalLAdj Accumulated adjusted load.
 * @return {number} Compressed strain score.
 */
function compressTo21(totalLAdj: number): number {
  return 21 * (1 - Math.exp(-STRAIN_A * totalLAdj));
}

/**
 * Recomputes one day summary from remaining session documents.
 * @param {string} uid Authenticated user ID.
 * @param {string} dateKey Day key in YYYY-MM-DD format.
 * @return {Promise<void>} Resolves after the day summary is updated.
 */
async function recomputeDayStrain(uid: string, dateKey: string): Promise<void> {
  const userRef = db.collection("users").doc(uid);
  const dayRef = userRef.collection("days").doc(dateKey);
  const sessionsSnap = await userRef
    .collection("sessions")
    .where("dateKey", "==", dateKey)
    .get();

  let totalLAdj = 0;
  for (const doc of sessionsSnap.docs) {
    totalLAdj += Number(doc.get("strain.lAdj") ?? 0);
  }

  await dayRef.set(
    {
      dateKey,
      updatedAt: FieldValue.serverTimestamp(),
      strain: {
        totalLAdj: r2(totalLAdj),
        score: r2(compressTo21(totalLAdj)),
        sessionCount: sessionsSnap.size,
      },
    },
    {merge: true}
  );
}

/**
 * HTTP endpoint for quick recovery testing.
 * The app should use callable functions in normal operation.
 */
export const recovery = onRequest((req, res) => {
  corsHandler(req, res, () => {
    if (req.method !== "POST") {
      res.status(405).send("Use POST");
      return;
    }

    const {yesterdayStrain, sleepHours, hadRestDay} = req.body ?? {};

    const result = computeRecovery({
      yesterdayStrain: Number(yesterdayStrain ?? 0),
      sleepHours: Number(sleepHours ?? 0),
      hadRestDay: Boolean(hadRestDay ?? false),
    });

    res.json(result);
  });
});

/**
 * Logs a session, computes strain, stores the session,
 * and updates the daily strain summary.
 */
export const logSession = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const data = request.data ?? {};

  const activityType = String(data.activityType ?? "").trim();
  const distanceKmRaw = Number(data.distanceKm ?? 0);
  const distanceKm = Number.isFinite(distanceKmRaw) && distanceKmRaw > 0 ?
    distanceKmRaw :
    undefined;

  const dateKey = String(data.dateKey ?? "").trim();
  if (!/^\d{4}-\d{2}-\d{2}$/.test(dateKey)) {
    throw new HttpsError(
      "invalid-argument",
      "dateKey must be YYYY-MM-DD."
    );
  }

  const durationMinutes = Number(data.durationMinutes ?? 0);
  if (!Number.isFinite(durationMinutes) || durationMinutes <= 0) {
    throw new HttpsError(
      "invalid-argument",
      "durationMinutes must be > 0."
    );
  }

  const rpe = Number(data.rpe ?? 0);
  if (!Number.isFinite(rpe) || rpe < 0 || rpe > 10) {
    throw new HttpsError(
      "invalid-argument",
      "rpe must be between 0 and 10."
    );
  }

  const modalityInput = String(data.modality ?? "Endurance");
  const validModalities: Modality[] = [
    "HIIT",
    "Endurance",
    "Strength",
    "Mobility",
  ];
  if (!validModalities.includes(modalityInput as Modality)) {
    throw new HttpsError("invalid-argument", "Invalid modality.");
  }
  const modality = modalityInput as Modality;

  const sleepHours = Number(data.sleepHours ?? 7.5);
  if (!Number.isFinite(sleepHours) || sleepHours < 0 || sleepHours > 24) {
    throw new HttpsError(
      "invalid-argument",
      "sleepHours must be between 0 and 24."
    );
  }

  const sleepQuality = Number(data.sleepQuality ?? 3);
  if (!Number.isFinite(sleepQuality) || sleepQuality < 1 || sleepQuality > 5) {
    throw new HttpsError(
      "invalid-argument",
      "sleepQuality must be between 1 and 5."
    );
  }

  const baselineSleepHours = Number(data.baselineSleepHours ?? 7.5);

  const userRef = db.collection("users").doc(uid);
  const dayRef = userRef.collection("days").doc(dateKey);
  const daySnap = await dayRef.get();

  const storedInputs = daySnap.get("inputs") as Record<string, unknown> | undefined;
  const effectiveSleepHoursRaw = Number(
    storedInputs?.sleepHours ?? data.sleepHours ?? 7.5
  );
  const effectiveSleepQualityRaw = Number(
    storedInputs?.sleepQuality ?? data.sleepQuality ?? 3
  );
  const effectiveSleepHours = Number.isFinite(effectiveSleepHoursRaw) ?
    effectiveSleepHoursRaw :
    7.5;
  const effectiveSleepQuality = Number.isFinite(effectiveSleepQualityRaw) ?
    effectiveSleepQualityRaw :
    3;

  const strain = computeStrain({
    durationMinutes,
    rpe,
    modality,
    sleepHours: effectiveSleepHours,
    sleepQuality: effectiveSleepQuality,
    baselineSleepHours,
  });

  const sessionRef = userRef.collection("sessions").doc();

  const txnResult = await db.runTransaction(async (tx) => {
    const now = FieldValue.serverTimestamp();
    const freshDaySnap = await tx.get(dayRef);

    if (!freshDaySnap.exists) {
      tx.set(dayRef, buildDefaultDayDoc(dateKey), {merge: true});
    }

    const prevTotal = Number(freshDaySnap.get("strain.totalLAdj") ?? 0);
    const prevCount = Number(freshDaySnap.get("strain.sessionCount") ?? 0);

    const newTotal = prevTotal + strain.lAdj;
    const newScore = compressTo21(newTotal);

    tx.set(sessionRef, {
      createdAt: now,
      dateKey,
      durationMinutes,
      rpe,
      modality,
      activityType,
      distanceKm: distanceKm ?? 0,
      sleepHours: effectiveSleepHours,
      sleepQuality: effectiveSleepQuality,
      strain: {
        lBase: r2(strain.lBase),
        lMod: r2(strain.lMod),
        sF: r2(strain.sF),
        lAdj: r2(strain.lAdj),
        score: r2(strain.strainScore021),
      },
    });

    tx.set(
      dayRef,
      {
        dateKey,
        updatedAt: now,
        strain: {
          totalLAdj: r2(newTotal),
          score: r2(newScore),
          sessionCount: prevCount + 1,
        },
      },
      {merge: true}
    );

    return {
      sessionId: sessionRef.id,
      day: {
        dateKey,
        strain: {
          totalLAdj: r2(newTotal),
          score: r2(newScore),
          sessionCount: prevCount + 1,
        },
      },
    };
  });

  if (activityType) {
    await updateGoalProgressForSession(uid, activityType, distanceKm);
  }

  return txnResult;
});

/**
 * Saves daily sleep/rest inputs, computes recovery from yesterday’s
 * strain, and stores recovery plus recommendation on the day document.
 */
export const setDailyInputs = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const data = request.data ?? {};
  const dateKey = String(data.dateKey ?? "").trim();

  if (!/^\d{4}-\d{2}-\d{2}$/.test(dateKey)) {
    throw new HttpsError(
      "invalid-argument",
      "dateKey must be YYYY-MM-DD."
    );
  }

  const sleepHours = Number(data.sleepHours ?? 0);
  if (!Number.isFinite(sleepHours) || sleepHours < 0 || sleepHours > 24) {
    throw new HttpsError(
      "invalid-argument",
      "sleepHours must be between 0 and 24."
    );
  }

  const sleepQuality = Number(data.sleepQuality ?? 3);
  if (!Number.isFinite(sleepQuality) || sleepQuality < 1 || sleepQuality > 5) {
    throw new HttpsError(
      "invalid-argument",
      "sleepQuality must be between 1 and 5."
    );
  }

  const hadRestDay = Boolean(data.hadRestDay ?? false);

  const userRef = db.collection("users").doc(uid);
  const todayRef = userRef.collection("days").doc(dateKey);

  const yKey = yesterdayKeyUTC(dateKey);
  const ySnap = await userRef.collection("days").doc(yKey).get();
  const yesterdayStrainScore = Number(ySnap.get("strain.score") ?? 0);

  const recoveryResult = computeRecovery({
    yesterdayStrain: yesterdayStrainScore,
    sleepHours,
    hadRestDay,
  });

  const recommendation = computeRecommendation(recoveryResult.state);

  await todayRef.set(buildDefaultDayDoc(dateKey), {merge: true});

  await todayRef.set(
    {
      dateKey,
      updatedAt: FieldValue.serverTimestamp(),
      inputs: {
        sleepHours,
        sleepQuality,
        hadRestDay,
      },
      recovery: {
        score: recoveryResult.score,
        state: recoveryResult.state,
        guidance: recoveryResult.guidance,
      },
      recommendation: {
        type: recommendation.type,
        title: recommendation.title,
        subtitle: recommendation.subtitle,
      },
    },
    {merge: true}
  );

  return {dateKey, recovery: recoveryResult, recommendation};
});

/**
 * Builds a Smart Plan for the requested day using stored day inputs
 * plus the user’s active weekly goals from Firestore.
 */
export const getPlanForUser = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const data = request.data ?? {};
  const dateKey = String(data.dateKey ?? "").trim();

  if (!/^\d{4}-\d{2}-\d{2}$/.test(dateKey)) {
    throw new HttpsError(
      "invalid-argument",
      "dateKey must be YYYY-MM-DD."
    );
  }

  const userRef = db.collection("users").doc(uid);
  const dayRef = userRef.collection("days").doc(dateKey);
  const daySnap = await dayRef.get();

  if (!daySnap.exists) {
    await dayRef.set(buildDefaultDayDoc(dateKey), {merge: true});
  }

  const freshDaySnap = await dayRef.get();

  const strain = Number(freshDaySnap.get("strain.score") ?? 0);
  const recovery = Number(freshDaySnap.get("recovery.score") ?? 0);
  const recoveryState = String(
    freshDaySnap.get("recovery.state") ?? "yellow"
  ) as "red" | "yellow" | "green";
  const sleepHours = Number(freshDaySnap.get("inputs.sleepHours") ?? 0);
  const sleepQuality = Number(freshDaySnap.get("inputs.sleepQuality") ?? 3);
  const hadRestDay = Boolean(freshDaySnap.get("inputs.hadRestDay") ?? false);
  const completedSessionsToday = Number(
    freshDaySnap.get("strain.sessionCount") ?? 0
  );

  const activeGoals = await getActiveGoals(uid);

  const goals: GoalInput[] = activeGoals.map((goal) => ({
    type: goal.type as GoalInput["type"],
    targetValue: Number(goal.targetValue ?? 0),
    currentValue: Number(goal.currentValue ?? 0),
  }));

  const plannerInput: PlannerInput = {
    dateKey,
    strain,
    recovery,
    recoveryState,
    sleepHours,
    sleepQuality,
    hadRestDay,
    goals,
    completedSessionsToday,
  };

  const plan = buildSmartPlan(plannerInput);

  await dayRef.set(
    {
      updatedAt: FieldValue.serverTimestamp(),
      smartPlan: {
        summary: plan.summary,
        items: plan.items,
      },
    },
    {merge: true}
  );

  return {
    dateKey,
    smartPlan: plan,
  };
});

/**
 * Deletes the authenticated user's HABITUS data and Firebase Auth account.
 * This supports GDPR-style user control over stored wellness data.
 */
export const deleteAccountData = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const userRef = db.collection("users").doc(uid);

  const deletedCollections = await Promise.all([
    deleteUserSubcollection(userRef, "days"),
    deleteUserSubcollection(userRef, "sessions"),
    deleteUserSubcollection(userRef, "goals"),
  ]);

  await userRef.delete();
  await getAuth().deleteUser(uid);

  return {
    deletedDocuments: deletedCollections.reduce((sum, count) => sum + count, 0),
  };
});

/**
 * Deletes one logged session and recomputes the affected day summary.
 */
export const deleteSession = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const data = request.data ?? {};
  const sessionId = String(data.sessionId ?? "").trim();
  if (!sessionId) {
    throw new HttpsError("invalid-argument", "sessionId is required.");
  }

  const userRef = db.collection("users").doc(uid);
  const sessionRef = userRef.collection("sessions").doc(sessionId);
  const sessionSnap = await sessionRef.get();

  if (!sessionSnap.exists) {
    throw new HttpsError("not-found", "Session not found.");
  }

  const dateKey = String(sessionSnap.get("dateKey") ?? "");
  if (!/^\d{4}-\d{2}-\d{2}$/.test(dateKey)) {
    throw new HttpsError("failed-precondition", "Session has no valid date.");
  }

  const activityType = String(sessionSnap.get("activityType") ?? "").trim();
  const distanceKmRaw = Number(sessionSnap.get("distanceKm") ?? 0);
  const distanceKm = Number.isFinite(distanceKmRaw) && distanceKmRaw > 0 ?
    distanceKmRaw :
    undefined;

  await sessionRef.delete();
  await recomputeDayStrain(uid, dateKey);

  if (activityType) {
    await reverseGoalProgressForSession(uid, activityType, distanceKm);
  }

  return {dateKey, sessionId};
});

export const resetWeeklyGoals = onSchedule(
  {
    schedule: "0 1 * * 1",
    timeZone: "Europe/London",
    region: "us-central1",
  },
  async () => {
    await resetWeeklyGoalsForAllUsers();
  }
);
