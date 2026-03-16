/**
 * Returns the previous UTC date key in YYYY-MM-DD format.
 * @param {string} dateKey Source date key.
 * @return {string} Yesterday's date key in UTC.
 */
export function yesterdayKeyUTC(dateKey: string): string {
  const d = new Date(`${dateKey}T00:00:00.000Z`);
  d.setUTCDate(d.getUTCDate() - 1);
  return d.toISOString().slice(0, 10);
}

/**
 * Returns today's UTC date key in YYYY-MM-DD format.
 * @return {string} Today's UTC date key.
 */
export function todayKeyUTC(): string {
  return new Date().toISOString().slice(0, 10);
}
