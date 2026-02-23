import { onRequest } from "firebase-functions/v2/https";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2";
import cors from "cors";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";

initializeApp();
const db = getFirestore();

import { computeRecovery } from "./engines/recoveryEngine";
import { computeStrain, Modality, STRAIN_A } from "./engines/strainEngine";
import { yesterdayKeyUTC } from "./utils/dateKey";

setGlobalOptions({ maxInstances: 10, region: "us-central1" });

const corsHandler = cors({ origin: true });

//Roundind to d.p. for UI
const r2 = (n: number) => Math.round(n * 100) / 100;

/**
 * HTTP endpoint (useful for quick testing with curl / Postman)
 * You can keep this, but iOS “proper” flow will use callable functions.
 */
export const recovery = onRequest((req, res) => {
  corsHandler(req, res, () => {
    if (req.method !== "POST") {
      res.status(405).send("Use POST");
      return;
    }

    const { yesterdayStrain, sleepHours, hadRestDay } = req.body ?? {};

    const result = computeRecovery({
      yesterdayStrain: Number(yesterdayStrain ?? 0),
      sleepHours: Number(sleepHours ?? 0),
      hadRestDay: Boolean(hadRestDay ?? false),
    });

    res.json(result);
  });
});

/**
 * Callable (preferred for the app): log a session, compute strain, store it,
 * update day summary (totalLAdj + compressed score), return updated day.
 */
export const logSession = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");

  const data = request.data ?? {};

  const dateKey = String(data.dateKey ?? "").trim();
  if (!/^\d{4}-\d{2}-\d{2}$/.test(dateKey)) {
    throw new HttpsError("invalid-argument", "dateKey must be YYYY-MM-DD.");
  }

  const durationMinutes = Number(data.durationMinutes ?? 0);
  const rpe = Number(data.rpe ?? 0);
  const modality = String(data.modality ?? "Endurance") as Modality;

  const sleepHours = Number(data.sleepHours ?? 7.5);
  const sleepQuality = Number(data.sleepQuality ?? 3);

  const strain = computeStrain({
    durationMinutes,
    rpe,
    modality,
    sleepHours,
    sleepQuality,
    baselineSleepHours: Number(data.baselineSleepHours ?? 7.5),
  });

  const userRef = db.collection("users").doc(uid);
  const sessionRef = userRef.collection("sessions").doc();
  const dayRef = userRef.collection("days").doc(dateKey);

  const A = STRAIN_A;
  const compressTo21 = (totalLAdj: number) => 21 * (1 - Math.exp(-A * totalLAdj));

  const txnResult = await db.runTransaction(async (tx) => {
  const now = FieldValue.serverTimestamp();

  // ✅ READS FIRST
  const daySnap = await tx.get(dayRef);
  const prevTotal = Number(daySnap.get("strain.totalLAdj") ?? 0);
  const prevCount = Number(daySnap.get("strain.sessionCount") ?? 0);

  const newTotal = prevTotal + strain.L_adj;
  const newScore = Number(compressTo21(newTotal));

  // ✅ WRITES AFTER READS
  tx.set(sessionRef, {
    ts: now,
    dateKey,
    durationMinutes,
    rpe,
    modality,
    sleepHours,
    sleepQuality,
    strain: {
      L_base: strain.L_base,
      L_mod: strain.L_mod,
      S_f: strain.S_f,
      L_adj: strain.L_adj,
      score: strain.strainScore_0_21, // or strain.score if you renamed
    },
  });

  tx.set(
    dayRef,
    {
      dateKey,
      updatedAt: now,
      strain: {
        totalLAdj: newTotal,
        score: newScore,
        sessionCount: prevCount + 1,
      },
    },
    { merge: true }
  );

  return {
    sessionId: sessionRef.id,
    day: {
      dateKey,
      strain: {
        totalLAdj: Number(r2(newTotal)),
        score: Number(r2(newScore)),
        sessionCount: prevCount + 1,
      },
    },
  };
});

  return txnResult;
});

/**
 * Callable (preferred for the app): save sleep/rest inputs for a day,
 * compute recovery based on yesterday’s strain, store it on today’s day doc.
 */
export const setDailyInputs = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");

  const data = request.data ?? {};
  const dateKey = String(data.dateKey ?? "").trim();
  if (!/^\d{4}-\d{2}-\d{2}$/.test(dateKey)) {
    throw new HttpsError("invalid-argument", "dateKey must be YYYY-MM-DD.");
  }

  const sleepHours = Number(data.sleepHours ?? 0);
  const sleepQuality = Number(data.sleepQuality ?? 3);
  const hadRestDay = Boolean(data.hadRestDay ?? false);

  const userRef = db.collection("users").doc(uid);
  const todayRef = userRef.collection("days").doc(dateKey);

  const yKey = yesterdayKeyUTC(dateKey);
  const ySnap = await userRef.collection("days").doc(yKey).get();
  const yesterdayStrainScore = Number(ySnap.get("strain.score") ?? 0);

  const recovery = computeRecovery({
    yesterdayStrain: yesterdayStrainScore,
    sleepHours,
    hadRestDay,
  });

  await todayRef.set(
    {
      dateKey,
      updatedAt: FieldValue.serverTimestamp(),
      inputs: { sleepHours, sleepQuality, hadRestDay },
      recovery,
    },
    { merge: true }
  );

  return { dateKey, recovery };
});