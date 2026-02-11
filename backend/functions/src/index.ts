import { onRequest } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2";
import cors from "cors";
import { computeRecovery } from "./engines/recoveryEngine";

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
