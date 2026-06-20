const test = require("node:test");
const assert = require("node:assert/strict");

const {computeStrain} = require("../lib/engines/strainEngine.js");
const {computeRecovery} = require("../lib/engines/recoveryEngine.js");
const {buildSmartPlan} = require("../lib/engines/smartPlanningEngine.js");

function round2(value) {
  return Math.round(value * 100) / 100;
}

test("computeStrain follows session-RPE, modality, sleep, and 0-21 compression", () => {
  const result = computeStrain({
    durationMinutes: 45,
    rpe: 6,
    modality: "Strength",
    sleepHours: 7.5,
    sleepQuality: 3,
  });

  assert.equal(result.lBase, 270);
  assert.equal(result.lMod, 243);
  assert.equal(result.sF, 1);
  assert.equal(result.lAdj, 243);
  assert.equal(round2(result.strainScore021), 13.06);
});

test("computeStrain clamps poor sleep adjustment inside the dissertation safety bounds", () => {
  const result = computeStrain({
    durationMinutes: 60,
    rpe: 8,
    modality: "HIIT",
    sleepHours: 0,
    sleepQuality: 1,
  });

  assert.equal(result.sF, 1.3);
  assert.equal(result.lBase, 480);
  assert.equal(result.lMod, 552);
  assert.equal(result.lAdj, 717.6);
  assert.equal(round2(result.strainScore021), 19.81);
});

test("computeRecovery returns green readiness for manageable strain and sleep", () => {
  const result = computeRecovery({
    yesterdayStrain: 10,
    sleepHours: 7,
    hadRestDay: false,
  });

  assert.deepEqual(result, {
    score: 80,
    state: "green",
    guidance: "Good to push today. Higher intensity allowed.",
  });
});

test("computeRecovery returns red readiness for low sleep and high prior strain", () => {
  const result = computeRecovery({
    yesterdayStrain: 21,
    sleepHours: 2,
    hadRestDay: false,
  });

  assert.deepEqual(result, {
    score: 27,
    state: "red",
    guidance: "Active recovery. Prioritise sleep and mobility.",
  });
});

test("buildSmartPlan prioritises recovery when strain is high", () => {
  const plan = buildSmartPlan({
    dateKey: "2026-06-14",
    strain: 17,
    recovery: 90,
    recoveryState: "green",
    sleepHours: 8,
    sleepQuality: 4,
    hadRestDay: false,
    goals: [
      {type: "workoutCount", targetValue: 4, currentValue: 1},
    ],
    completedSessionsToday: 1,
  });

  assert.match(plan.summary, /Recovery focus/);
  assert.match(plan.summary, /strain is 17\.0\/21/);
  assert.match(plan.summary, /limiting intensity/);
  assert.equal(plan.items[0].activityType, "recovery");
  assert.equal(plan.items[0].intensity, 2);
  assert.match(plan.items[0].reason, /Strain is 17\.0\/21/);
  assert.equal(plan.items[1].activityType, "walk");
});

test("buildSmartPlan uses readiness and unmet goals for training suggestions", () => {
  const plan = buildSmartPlan({
    dateKey: "2026-06-14",
    strain: 6,
    recovery: 85,
    recoveryState: "green",
    sleepHours: 8,
    sleepQuality: 4,
    hadRestDay: true,
    goals: [
      {type: "workoutCount", targetValue: 4, currentValue: 2},
      {type: "mobilitySessions", targetValue: 3, currentValue: 1},
      {type: "meditationSessions", targetValue: 3, currentValue: 1},
    ],
    completedSessionsToday: 0,
  });

  assert.match(plan.summary, /Training opportunity/);
  assert.match(plan.summary, /recovery is 85\/100/);
  assert.match(plan.summary, /strain is 6\.0\/21/);
  assert.deepEqual(
    plan.items.map((item) => item.activityType),
    ["strength", "mobility", "meditation"]
  );
  assert.ok(plan.items.every((item) => item.durationMinutes > 0));
  assert.match(plan.items[0].reason, /weekly goal/);
  assert.match(plan.items[1].reason, /Mobility is low strain/);
  assert.match(plan.items[2].reason, /recovery and consistency/);
});

test("buildSmartPlan adapts intensity for new Office Athletes", () => {
  const plan = buildSmartPlan({
    dateKey: "2026-06-14",
    strain: 6,
    recovery: 85,
    recoveryState: "green",
    sleepHours: 8,
    sleepQuality: 4,
    hadRestDay: true,
    goals: [
      {type: "workoutCount", targetValue: 4, currentValue: 2},
    ],
    completedSessionsToday: 0,
    officeAthleteLevel: "New to exercise",
  });

  assert.match(plan.summary, /Office Athlete beginner profile/);
  assert.equal(plan.items[0].activityType, "strength");
  assert.equal(plan.items[0].durationMinutes, 35);
  assert.equal(plan.items[0].intensity, 4);
  assert.match(plan.items[0].reason, /Adjusted for Office Athlete level/);
});

test("buildSmartPlan preserves capacity for performance profiles", () => {
  const plan = buildSmartPlan({
    dateKey: "2026-06-14",
    strain: 6,
    recovery: 85,
    recoveryState: "green",
    sleepHours: 8,
    sleepQuality: 4,
    hadRestDay: true,
    goals: [
      {type: "workoutCount", targetValue: 4, currentValue: 2},
    ],
    completedSessionsToday: 0,
    officeAthleteLevel: "Performance focused",
  });

  assert.match(plan.summary, /Office Athlete performance profile/);
  assert.equal(plan.items[0].activityType, "strength");
  assert.equal(plan.items[0].durationMinutes, 50);
  assert.equal(plan.items[0].intensity, 7);
  assert.match(plan.items[0].reason, /Performance focused/);
});
