export type Modality = "HIIT" | "Endurance" | "Strength" | "Mobility";

export const STRAIN_A = 0.004;

export interface StrainInput {
  durationMinutes: number; // minutes
  rpe: number; // 0..10
  modality: Modality;
  sleepHours: number; // hours
  sleepQuality: number; // 1..5
  baselineSleepHours?: number; // default 7.5
}

export interface StrainResult {
  lBase: number;
  lMod: number;
  sF: number;
  lAdj: number;
  strainScore021: number;
}

const MODALITY_MULTIPLIER: Record<Modality, number> = {
  HIIT: 1.15,
  Endurance: 1.0,
  Strength: 0.9,
  Mobility: 0.5,
};

const HB_DEFAULT = 7.5;
const K1 = 0.25;
const K2 = 0.15;
const K3 = 0.06;

const SF_MIN = 0.8;
const SF_MAX = 1.3;

/**
 * Clamps a numeric value between lower and upper bounds.
 * @param {number} x Value to clamp.
 * @param {number} lo Lower bound.
 * @param {number} hi Upper bound.
 * @return {number} Clamped value.
 */
function clamp(x: number, lo: number, hi: number): number {
  return Math.max(lo, Math.min(hi, x));
}

/**
 * Computes the dissertation strain model for a single session.
 * @param {StrainInput} input Session and sleep inputs used in the model.
 * @return {StrainResult} Intermediate load values and final strain score.
 */
export function computeStrain(input: StrainInput): StrainResult {
  const duration = Math.max(0, input.durationMinutes);
  const rpe = clamp(input.rpe, 0, 10);

  const h = Math.max(0, input.sleepHours);
  const q = clamp(input.sleepQuality, 1, 5);
  const hb = input.baselineSleepHours ?? HB_DEFAULT;

  const lBase = duration * rpe;

  const modalityMultiplier = MODALITY_MULTIPLIER[input.modality] ?? 1.0;
  const lMod = lBase * modalityMultiplier;

  const sfRaw =
    1 +
    K1 * ((hb - h) / hb) -
    K2 * ((h - hb) / hb) +
    K3 * (3 - q);

  const sF = clamp(sfRaw, SF_MIN, SF_MAX);

  const lAdj = lMod * sF;
  const strainScore021 = 21 * (1 - Math.exp(-STRAIN_A * lAdj));

  return {
    lBase,
    lMod,
    sF,
    lAdj,
    strainScore021,
  };
}
