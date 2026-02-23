export type Modality = "HIIT" | "Endurance" | "Strength" | "Mobility";

export const STRAIN_A = 0.004; // compression constant for strain score

export interface StrainInput {
  durationMinutes: number; // minutes
  rpe: number;             // 0..10
  modality: Modality;

  sleepHours: number;      // hours
  sleepQuality: number;    // 1..5

  baselineSleepHours?: number; // hb, default 7.5
}

export interface StrainResult {
  L_base: number;
  L_mod: number;
  S_f: number;
  L_adj: number;
  strainScore_0_21: number;
}

// --- constants from your document ---
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

function clamp(x: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, x));
}

/**
 * Implements dissertation strain model:
 * 1) L_base = duration × RPE
 * 2) L_mod  = L_base × M
 * 3) S_f    = clamp(0.8..1.3, 1 + k1*(hb-h)/hb - k2*(h-hb)/hb + k3*(3-q))
 * 4) L_adj  = L_mod × S_f
 * 5) Strain = 21 × (1 - e^(-a × L_adj))
 */
export function computeStrain(input: StrainInput): StrainResult {
  const duration = Math.max(0, input.durationMinutes);
  const rpe = clamp(input.rpe, 0, 10);

  const h = Math.max(0, input.sleepHours);
  const q = clamp(input.sleepQuality, 1, 5);
  const hb = input.baselineSleepHours ?? HB_DEFAULT;

  // Step 1
  const L_base = duration * rpe;

  // Step 2
  const M = MODALITY_MULTIPLIER[input.modality] ?? 1.0;
  const L_mod = L_base * M;

  // Step 3 (as written in your doc)
  // 1 + k1*(hb-h)/hb - k2*(h-hb)/hb + k3*(3-q)
  const sfRaw =
    1 +
    K1 * ((hb - h) / hb) -
    K2 * ((h - hb) / hb) +
    K3 * (3 - q);

  const S_f = clamp(sfRaw, SF_MIN, SF_MAX);

  // Step 4
  const L_adj = L_mod * S_f;

  // Step 5 (0–21 compression)
  const strainScore_0_21 = 21 * (1 - Math.exp(-STRAIN_A * L_adj));

  return {
    L_base,
    L_mod,
    S_f,
    L_adj,
    strainScore_0_21,
  };
}
