// Wave66: search/filter, export, and deterministic offline AI insights over own records.
// No provider call is made here; fallback is always labelled aiGenerated:false.
export function filterRecords(rows, { q = "", status = "", risk = "", owner = "" } = {}) {
  const needle = String(q).trim().toLowerCase();
  return (rows || []).filter((r) => {
    const st = r.status ?? r.state ?? "";
    if (status && String(st) !== status) return false;
    if (risk && String(r.risk ?? "") !== risk) return false;
    if (owner && !String(r.owner ?? "").toLowerCase().includes(String(owner).toLowerCase())) return false;
    if (!needle) return true;
    return [r.reference, r.title, r.subject, r.owner, st, r.risk, r.feature_id, r.workflow_id]
      .map((v) => String(v ?? "").toLowerCase()).some((v) => v.includes(needle));
  });
}
export function recordColumns(rows) {
  const cols = [];
  for (const r of rows || []) for (const k of Object.keys(r)) if (!cols.includes(k)) cols.push(k);
  return cols;
}
function cell(v) { if (v === null || v === undefined) return ""; if (typeof v === "object") return JSON.stringify(v); return String(v); }
export function recordsToCSV(rows) {
  const cols = recordColumns(rows);
  const esc = (v) => /[",\n]/.test(v) ? '"' + v.replace(/"/g, '""') + '"' : v;
  return [cols.join(","), ...(rows || []).map((r) => cols.map((c) => esc(cell(r[c]))).join(","))].join("\n") + "\n";
}
export function recordsToJSON(rows) { return JSON.stringify(rows ?? [], null, 2); }
const num = (v) => { const n = Number(v); return Number.isFinite(n) ? n : 0; };
const isClosed = (r) => ["Closed", "closed", "Approved", "approved"].includes(String(r.status ?? r.state ?? ""));
export function buildInsights(rows, domainLabel = "records", labels = []) {
  const list = rows || [];
  const total = list.reduce((s, r) => s + num(r.amount), 0);
  const open = list.filter((r) => !isClosed(r));
  const openValue = open.reduce((s, r) => s + num(r.amount), 0);
  const high = list.filter((r) => ["High", "Critical"].includes(String(r.risk ?? "")));
  const now = Date.now();
  const overdue = list.filter((r) => !isClosed(r) && r.due_date && Date.parse(r.due_date) < now);
  const top = [...open].sort((a, b) => num(b.amount) - num(a.amount)).slice(0, 5);
  const names = labels.length === 3 ? labels : ["Priority queue", "Exposure summary", "Stale review"];
  const mk = (id, label, metrics, sections) => ({ id, label, aiGenerated: false, source: "deterministic-fallback", provider: "none (offline fallback)", metrics, sections });
  return [
    mk("priority-queue", names[0],
      [{ label: "Open records", value: open.length }, { label: "High/Critical risk", value: high.length }, { label: "Open value", value: openValue }],
      [{ title: "Priority queue (labelled)", detail: top.length ? top.map((r) => `${r.reference ?? r.id}: ${r.title ?? r.subject ?? "Untitled"} — ${num(r.amount)} (${r.risk ?? "risk not set"})`).join("; ") : "No open records: count is 0." },
       { title: "Empty / zero check", detail: `High/Critical count is ${high.length}; false/0 values are preserved, not hidden.` }]),
    mk("exposure-summary", names[1],
      [{ label: "Total records", value: list.length }, { label: "Total value", value: total }, { label: "Closed/approved", value: list.length - open.length }],
      [{ title: "Exposure summary (labelled)", detail: `${domainLabel}: ${list.length} record(s) totalling ${total}; open exposure ${openValue}.` },
       { title: "Empty / zero check", detail: `Closed/approved count is ${list.length - open.length} (may be 0).` }]),
    mk("stale-review", names[2],
      [{ label: "Overdue open records", value: overdue.length }, { label: "Overdue value", value: overdue.reduce((s, r) => s + num(r.amount), 0) }],
      [{ title: "Stale review (labelled)", detail: overdue.length ? overdue.slice(0, 5).map((r) => `${r.reference ?? r.id} due ${String(r.due_date).slice(0, 10)}`).join("; ") : "No overdue open records: count is 0." },
       { title: "Next step", detail: "Assign an owner and due date to overdue items; operational only, no external action taken." }]),
  ];
}
export function mountWave66(app, { pool, auth, table = "feature_records", featureColumn = "feature_id", labels = [], domainLabel = "records" }) {
  const guard = typeof auth === "function" ? auth : (_req, _res, next) => next();
  app.get("/api/export/records", guard, async (req, res) => {
    const featureId = req.query.featureId || req.query.feature_id;
    const rows = featureId
      ? (await pool.query(`SELECT * FROM ${table} WHERE ${featureColumn}=$1 ORDER BY id DESC LIMIT 1000`, [featureId])).rows
      : (await pool.query(`SELECT * FROM ${table} ORDER BY id DESC LIMIT 1000`)).rows;
    const filtered = filterRecords(rows, { q: req.query.q || "", status: req.query.status || "", risk: req.query.risk || "", owner: req.query.owner || "" });
    if (String(req.query.format || "json").toLowerCase() === "csv") {
      res.setHeader("Content-Type", "text/csv; charset=utf-8");
      res.setHeader("Content-Disposition", "attachment; filename=records-export.csv");
      return res.send(recordsToCSV(filtered));
    }
    res.setHeader("Content-Disposition", "attachment; filename=records-export.json");
    return res.json({ aiGenerated: false, count: filtered.length, items: filtered });
  });
  app.get("/api/ai/insights", guard, async (req, res) => {
    const featureId = req.query.featureId || req.query.feature_id;
    const rows = featureId
      ? (await pool.query(`SELECT * FROM ${table} WHERE ${featureColumn}=$1 ORDER BY id DESC LIMIT 1000`, [featureId])).rows
      : (await pool.query(`SELECT * FROM ${table} ORDER BY id DESC LIMIT 1000`)).rows;
    const filtered = filterRecords(rows, { q: req.query.q || "", status: req.query.status || "", risk: req.query.risk || "" });
    return res.json({ aiGenerated: false, source: "deterministic-fallback", label: "Deterministic fallback (offline) — aiGenerated: false", count: filtered.length, features: buildInsights(filtered, domainLabel, labels) });
  });
}
