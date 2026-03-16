import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {GoalInput} from "../engines/plannerTypes";

type GoalDoc = GoalInput & {
  isActive?: boolean;
  weekStart?: string;
};

/**
 * Firestore database instance.
 * @return {Firestore} Firestore instance for database operations.
 */
function db() {
  return getFirestore();
}

/**
 * Retrieves all active goals for a user.
 * @param {string} uid Authenticated user ID.
 * @return {Promise<Array<Object>>} Active goal documents
 * including Firestore IDs.
 */
export async function getActiveGoals(
  uid: string
): Promise<Array<GoalDoc & {id: string}>> {
  const snap = await db()
    .collection("users")
    .doc(uid)
    .collection("goals")
    .where("isActive", "==", true)
    .get();

  return snap.docs.map((doc) => ({
    id: doc.id,
    ...(doc.data() as GoalDoc),
  }));
}

/**
 * Updates weekly goal progress after a session is logged.
 * @param {string} uid Authenticated user ID.
 * @param {string} activityType Frontend activity type label.
 * @param {number=} distanceKm Optional run distance in kilometres.
 * @return {Promise<void>} Resolves when all matching goal updates complete.
 */
export async function updateGoalProgressForSession(
  uid: string,
  activityType: string,
  distanceKm?: number
): Promise<void> {
  const goals = await getActiveGoals(uid);

  const updates = goals.map(async (goal) => {
    let increment = 0;

    switch (activityType) {
    case "Strength":
    case "Hyrox":
      if (goal.type === "workoutCount") increment = 1;
      break;

    case "Run":
      if (goal.type === "workoutCount") increment = 1;
      if (goal.type === "runDistance") increment = distanceKm ?? 0;
      break;

    case "Mobility":
    case "Yoga":
      if (goal.type === "mobilitySessions") increment = 1;
      break;

    default:
      break;
    }

    if (increment <= 0) return;

    await db()
      .collection("users")
      .doc(uid)
      .collection("goals")
      .doc(goal.id)
      .update({
        currentValue: FieldValue.increment(increment),
        updatedAt: FieldValue.serverTimestamp(),
      });
  });

  await Promise.all(updates);
}

/**
 * Returns the UTC date key for the current ISO week start (Monday).
 * @return {string} Week start in YYYY-MM-DD format.
 */
export function currentWeekStartUTC(): string {
  const now = new Date();
  const day = now.getUTCDay();
  const diffToMonday = day === 0 ? -6 : 1 - day;

  const monday = new Date(Date.UTC(
    now.getUTCFullYear(),
    now.getUTCMonth(),
    now.getUTCDate() + diffToMonday
  ));

  return monday.toISOString().slice(0, 10);
}

/**
 * Resets all active weekly goals for all users.
 * @return {Promise<void>} Resolves when all active goals are reset.
 */
export async function resetWeeklyGoalsForAllUsers(): Promise<void> {
  const usersSnap = await db().collection("users").get();
  const weekStart = currentWeekStartUTC();

  for (const userDoc of usersSnap.docs) {
    const goalsSnap = await userDoc.ref
      .collection("goals")
      .where("isActive", "==", true)
      .get();

    const writes = goalsSnap.docs.map((goalDoc) =>
      goalDoc.ref.update({
        currentValue: 0,
        weekStart,
        updatedAt: FieldValue.serverTimestamp(),
      })
    );

    await Promise.all(writes);
  }
}
