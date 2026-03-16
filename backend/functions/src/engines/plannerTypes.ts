export type GoalType =
  | "workoutCount"
  | "runDistance"
  | "mobilitySessions"
  | "recoverySessions"
  | "meditationSessions";

export interface GoalInput {
  type: GoalType;
  targetValue: number;
  currentValue: number;
}

export type PlanActivityType =
  | "walk"
  | "run"
  | "strength"
  | "hyrox"
  | "mobility"
  | "recovery"
  | "meditation";

export interface PlanItem {
  activityType: PlanActivityType;
  title: string;
  subtitle: string;
  reason: string;
  durationMinutes: number;
  intensity: number;
}

export interface PlannerInput {
  dateKey: string;
  strain: number; // 0-21
  recovery: number; // 0-100
  recoveryState: "red" | "yellow" | "green";
  sleepHours: number;
  sleepQuality: number; // 1-5
  hadRestDay: boolean;
  goals: GoalInput[];
  completedSessionsToday: number;
}

export interface PlannerResult {
  summary: string;
  items: PlanItem[];
}
