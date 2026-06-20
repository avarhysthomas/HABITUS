/**
 * HABITUS Smart Planning Engine
 *
 * Generates suggested wellness sessions based on:
 * - current strain
 * - recovery score/state
 * - sleep inputs
 * - weekly goals
 *
 * The engine returns a lightweight plan used by the
 * dashboard "Smart Plan" section.
 */

import {
  GoalInput,
  PlannerInput,
  PlannerResult,
  PlanItem,
} from "./plannerTypes";

interface AthleteProfileRule {
  level: string;
  intensityCap: number;
  durationScale: number;
  summary: string;
}

const athleteProfileRules: AthleteProfileRule[] = [
  {
    level: "New to exercise",
    intensityCap: 4,
    durationScale: 0.75,
    summary: "beginner profile: shorter sessions and capped intensity",
  },
  {
    level: "Building consistency",
    intensityCap: 5,
    durationScale: 0.9,
    summary: "consistency profile: manageable sessions before intensity",
  },
  {
    level: "Regular mover",
    intensityCap: 6,
    durationScale: 1,
    summary: "regular mover profile: balanced progression",
  },
  {
    level: "Training 4+ times weekly",
    intensityCap: 8,
    durationScale: 1.08,
    summary: "frequent training profile: slightly higher capacity",
  },
  {
    level: "Performance focused",
    intensityCap: 9,
    durationScale: 1.12,
    summary: "performance profile: higher capacity when readiness allows",
  },
];

/**
 * Checks whether a given goal still has remaining progress.
 * @param {GoalInput[]} goals List of goals passed from the client.
 * @param {string} type Goal type to check.
 * @return {boolean} True if progress is still remaining.
 */
function hasRemainingGoal(
  goals: GoalInput[],
  type: GoalInput["type"]
): boolean {
  return goals.some((g) => g.type === type && g.currentValue < g.targetValue);
}

/**
 * Formats a numeric metric for concise user-facing planner rationale.
 * @param {number} value Metric value.
 * @param {number} digits Number of decimal places.
 * @return {string} Formatted metric.
 */
function formatMetric(value: number, digits = 0): string {
  return value.toFixed(digits);
}

/**
 * Finds the Office Athlete adjustment rule for a planner input.
 * @param {string | undefined} level Office Athlete level from user profile.
 * @return {AthleteProfileRule | undefined} Matching rule when available.
 */
function profileRuleForLevel(
  level: string | undefined
): AthleteProfileRule | undefined {
  return athleteProfileRules.find((rule) => rule.level === level);
}

/**
 * Rounds recommended durations to neat five-minute blocks.
 * @param {number} minutes Raw duration.
 * @return {number} Rounded duration, never below five minutes.
 */
function roundDuration(minutes: number): number {
  return Math.max(5, Math.round(minutes / 5) * 5);
}

/**
 * Applies Office Athlete level adaptation to one plan item.
 * @param {PlanItem} item Generated base plan item.
 * @param {AthleteProfileRule | undefined} profileRule Profile rule.
 * @return {PlanItem} Personalised item.
 */
function personaliseItem(
  item: PlanItem,
  profileRule: AthleteProfileRule | undefined
): PlanItem {
  if (!profileRule) return item;

  const durationMinutes = roundDuration(
    item.durationMinutes * profileRule.durationScale
  );
  const intensity = Math.min(item.intensity, profileRule.intensityCap);

  return {
    ...item,
    durationMinutes,
    intensity,
    reason: item.reason + " Adjusted for Office Athlete level: " +
      profileRule.level + ".",
  };
}

/**
 * Builds the shared explanation sentence for a generated plan.
 * @param {PlannerInput} input Planner input payload.
 * @return {string} User-facing explanation of planner context.
 */
function buildPlanSummary(input: PlannerInput): string {
  const readiness = input.recoveryState;
  const strain = formatMetric(input.strain, 1);
  const recovery = formatMetric(input.recovery);
  const profileRule = profileRuleForLevel(input.officeAthleteLevel);
  const profileText = profileRule ?
    " Personalisation uses your Office Athlete " + profileRule.summary + "." :
    "";

  if (input.strain >= 16 || input.recoveryState === "red") {
    return "Recovery focus: strain is " + strain +
      "/21 and readiness is " + readiness +
      ", so HABITUS is limiting intensity today." + profileText;
  }

  if (input.recovery >= 80 && input.strain <= 10) {
    return "Training opportunity: recovery is " + recovery +
      "/100 and strain is " + strain +
      "/21, so a higher quality session is appropriate." + profileText;
  }

  return "Consistency focus: recovery is " + recovery +
    "/100 and strain is " + strain +
    "/21, so HABITUS is prioritising achievable goal progress." +
    profileText;
}

/**
 * Creates a concise remaining-goal phrase for plan rationale.
 * @param {GoalInput[]} goals List of goals passed from the client.
 * @param {string} type Goal type to explain.
 * @return {string} Remaining-goal explanation.
 */
function remainingGoalText(
  goals: GoalInput[],
  type: GoalInput["type"]
): string {
  const goal = goals.find((g) => g.type === type);
  if (!goal) return "this supports your weekly goal";

  const remaining = Math.max(goal.targetValue - goal.currentValue, 0);
  return "you still have " + formatMetric(remaining, 1) +
    " remaining toward your weekly goal";
}

/**
 * Builds a Smart Plan for the current day.
 *
 * Uses recovery state, strain level, sleep inputs and
 * weekly goals to generate 1–3 suggested sessions.
 *
 * @param {PlannerInput} input Planner input payload.
 * @return {PlannerResult} Planner result with summary and items.
 */
export function buildSmartPlan(input: PlannerInput): PlannerResult {
  const items: PlanItem[] = [];
  const planSummary = buildPlanSummary(input);
  const profileRule = profileRuleForLevel(input.officeAthleteLevel);

  if (input.strain >= 16 || input.recoveryState === "red") {
    items.push({
      activityType: "recovery",
      title: "Recovery session",
      subtitle: "20 min low intensity movement",
      reason:
        "Strain is " + formatMetric(input.strain, 1) +
        "/21 or readiness is red, so this keeps movement gentle while " +
        "supporting recovery.",
      durationMinutes: 20,
      intensity: 2,
    });

    items.push({
      activityType: "walk",
      title: "Walk break",
      subtitle: "10–15 min light movement",
      reason:
        "A short walk maintains habit momentum without adding much " +
        "extra strain to a high-load day.",
      durationMinutes: 15,
      intensity: 2,
    });

    return {
      summary: planSummary,
      items: items.slice(0, 3).map((item) =>
        personaliseItem(item, profileRule)
      ),
    };
  }

  if (input.recovery >= 80 && input.strain <= 10) {
    if (hasRemainingGoal(input.goals, "workoutCount")) {
      items.push({
        activityType: "strength",
        title: "Training session",
        subtitle: "45 min moderate-high intensity",
        reason:
          "Recovery is " + formatMetric(input.recovery) +
          "/100, strain is " + formatMetric(input.strain, 1) +
          "/21, and " +
          remainingGoalText(input.goals, "workoutCount") + ".",
        durationMinutes: 45,
        intensity: 7,
      });
    } else if (hasRemainingGoal(input.goals, "runDistance")) {
      items.push({
        activityType: "run",
        title: "Run session",
        subtitle: "30 min steady effort",
        reason:
          "Recovery is high, strain is low, and " +
          remainingGoalText(input.goals, "runDistance") + ".",
        durationMinutes: 30,
        intensity: 6,
      });
    } else {
      items.push({
        activityType: "hyrox",
        title: "Performance session",
        subtitle: "40 min quality effort",
        reason:
          "Recovery is " + formatMetric(input.recovery) +
          "/100 and strain is " + formatMetric(input.strain, 1) +
          "/21, so HABITUS can safely suggest more intensity.",
        durationMinutes: 40,
        intensity: 7,
      });
    }
  }

  if (hasRemainingGoal(input.goals, "mobilitySessions")) {
    items.push({
      activityType: "mobility",
      title: "Mobility block",
      subtitle: "10–15 min reset",
      reason:
        "Mobility is low strain, supports recovery, and " +
        remainingGoalText(input.goals, "mobilitySessions") + ".",
      durationMinutes: 15,
      intensity: 2,
    });
  }

  if (hasRemainingGoal(input.goals, "meditationSessions")) {
    items.push({
      activityType: "meditation",
      title: "Mindset reset",
      subtitle: "10 min guided breathing or meditation",
      reason:
        "This supports recovery and consistency because " +
        remainingGoalText(input.goals, "meditationSessions") + ".",
      durationMinutes: 10,
      intensity: 1,
    });
  }

  if (items.length === 0) {
    items.push({
      activityType: "walk",
      title: "Walk break",
      subtitle: "15 min light movement",
      reason:
        "With no urgent unmet goal, a short walk gives a low-friction " +
        "wellness action matched to today's readiness.",
      durationMinutes: 15,
      intensity: 2,
    });
  }

  return {
    summary: planSummary,
    items: items.slice(0, 3).map((item) =>
      personaliseItem(item, profileRule)
    ),
  };
}
