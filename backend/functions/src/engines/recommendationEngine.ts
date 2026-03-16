export type RecommendationType = "push" | "moderate" | "recovery";

export interface RecommendationResult {
  type: RecommendationType;
  title: string;
  subtitle: string;
}

/**
 * Returns a user-facing training recommendation based on recovery state.
 * @param {"green"|"yellow"|"red"} state Recovery traffic-light state.
 * @return {RecommendationResult} Recommendation content for the dashboard.
 */
export function computeRecommendation(
  state: "green" | "yellow" | "red"
): RecommendationResult {
  if (state === "green") {
    return {
      type: "push",
      title: "High readiness",
      subtitle: "You are well recovered and can push intensity today.",
    };
  }

  if (state === "yellow") {
    return {
      type: "moderate",
      title: "Moderate readiness",
      subtitle: "A controlled session is the best fit today.",
    };
  }

  return {
    type: "recovery",
    title: "Recovery focus",
    subtitle: "Prioritise mobility, rest, or light aerobic work.",
  };
}
