export type RecoveryState = "green" | "yellow" | "red";

export interface RecoveryInput {
  yesterdayStrain: number;
  sleepHours: number;
  hadRestDay: boolean;
}

export interface RecoveryResult {
  score: number;
  state: RecoveryState;
  guidance: string;
}

export function computeRecovery(input: RecoveryInput): RecoveryResult {
  const sleep = Math.min(Math.max(input.sleepHours, 0), 12);

  const sleepPenalty = sleep < 8 ? (8 - sleep) * 8 : 0;
  const sleepBonus = sleep > 8 ? Math.min((sleep - 8) * 2, 4) : 0;

  const strainPenalty = Math.min(Math.max(input.yesterdayStrain, 0) * 1.2, 35);

  const restBonus = input.hadRestDay ? 8 : 0;

  let score = 100 - sleepPenalty - strainPenalty + sleepBonus + restBonus;
  score = Math.max(0, Math.min(100, score));

  const state: RecoveryState =
    score >= 67 ? "green" : score >= 34 ? "yellow" : "red";

  const guidance =
    state === "green"
      ? "Good to push today. Higher intensity allowed."
      : state === "yellow"
      ? "Keep it moderate. Focus on quality work."
      : "Active recovery. Prioritise sleep and mobility.";

  return {
    score: Math.round(score),
    state,
    guidance,
  };
}
