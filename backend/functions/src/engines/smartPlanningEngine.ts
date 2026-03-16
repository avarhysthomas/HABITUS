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

  if (input.strain >= 16 || input.recoveryState === "red") {
    items.push({
      activityType: "recovery",
      title: "Recovery session",
      subtitle: "20 min low intensity movement",
      reason:
        "Your current load is high, so extra" +
        " intensity is not recommended today.",
      durationMinutes: 20,
      intensity: 2,
    });

    items.push({
      activityType: "walk",
      title: "Walk break",
      subtitle: "10–15 min light movement",
      reason:
        "A short walk maintains momentum without" +
        " adding much extra strain.",
      durationMinutes: 15,
      intensity: 2,
    });

    return {
      summary: "High strain — prioritise recovery",
      items: items.slice(0, 3),
    };
  }

  if (input.recovery >= 80 && input.strain <= 10) {
    if (hasRemainingGoal(input.goals, "workoutCount")) {
      items.push({
        activityType: "strength",
        title: "Training session",
        subtitle: "45 min moderate-high intensity",
        reason:
          "Recovery is high and strain is low, making " +
          "today a strong training opportunity.",
        durationMinutes: 45,
        intensity: 7,
      });
    } else if (hasRemainingGoal(input.goals, "runDistance")) {
      items.push({
        activityType: "run",
        title: "Run session",
        subtitle: "30 min steady effort",
        reason:
          "You have good readiness today and still have " +
          "run-distance progress to make this week.",
        durationMinutes: 30,
        intensity: 6,
      });
    } else {
      items.push({
        activityType: "hyrox",
        title: "Performance session",
        subtitle: "40 min quality effort",
        reason:
          "Your readiness is high, so HABITUS is " +
          "suggesting a more demanding session.",
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
        "This supports consistency and recovery without " +
        "requiring a full session.",
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
        "A short mindfulness block supports recovery and " +
        "habit consistency.",
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
        "Today looks better suited to a low-friction movement suggestion.",
      durationMinutes: 15,
      intensity: 2,
    });
  }

  return {
    summary: items[0]?.title ?? "Suggested plan",
    items: items.slice(0, 3),
  };
}
