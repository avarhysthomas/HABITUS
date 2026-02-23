import { onRequest } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2";
import cors from "cors";
import { computeRecovery } from "./engines/recoveryEngine";
import { computeStrain, Modality } from "./engines/strainEngine";

setGlobalOptions({ maxInstances: 10 });

const corsHandler = cors({ origin: true });

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

export const strain = onRequest({ region: "us-central1" }, (req, res) => {
  corsHandler(req, res, () => {
    if (req.method !== "POST") {
      res.status(405).send("Use POST");
      return;
    }
    const body = req.body ?? {};
    const result = computeStrain({
      durationMinutes: Number(body.durationMinutes ?? 0),
      rpe: Number(body.rpe ?? 0),
      modality: (body.modality ?? "Endurance") as Modality,
      sleepHours: Number(body.sleepHours ?? 7.5),
      sleepQuality: Number(body.sleepQuality ?? 3),
      baselineSleepHours: Number(body.baselineSleepHours ?? 7.5),
    });

    res.json(result);
  });
});
