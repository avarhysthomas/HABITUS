export function todayKeyUTC(d = new Date()): string {
  return d.toISOString().slice(0, 10); // YYYY-MM-DD
}

export function yesterdayKeyUTC(dateKey: string): string {
  const d = new Date(dateKey + "T00:00:00.000Z");
  d.setUTCDate(d.getUTCDate() - 1);
  return d.toISOString().slice(0, 10);
}