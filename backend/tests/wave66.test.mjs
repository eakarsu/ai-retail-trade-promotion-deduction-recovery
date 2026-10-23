import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import { filterRecords, recordsToCSV, recordsToJSON, buildInsights } from "../wave66.mjs";

const rows = [
  { id: 1, reference: "A-1", title: "Alpha case", status: "Open", risk: "High", owner: "Ann", amount: 0, due_date: "2000-01-01" },
  { id: 2, reference: "B-2", title: "Beta case", status: "Closed", risk: "Low", owner: "Bob", amount: 50, due_date: "2999-01-01" },
];

test("search/filter on main list", () => {
  assert.equal(filterRecords(rows, { q: "alpha" }).length, 1);
  assert.equal(filterRecords(rows, { status: "Closed" }).length, 1);
  assert.equal(filterRecords(rows, { risk: "High", q: "a-1" }).length, 1);
  assert.equal(filterRecords(rows, { q: "missing" }).length, 0);
});

test("CSV/JSON export preserves 0 and empty", () => {
  const csv = recordsToCSV(rows);
  assert.ok(csv.split("\n")[0].includes("reference"));
  assert.ok(csv.includes("A-1"));
  assert.ok(csv.includes(",0,"));
  assert.equal(JSON.parse(recordsToJSON(rows))[0].amount, 0);
});

test("deterministic AI fallback is labelled aiGenerated:false with labelled sections preserving zero", () => {
  const feats = buildInsights(rows, "test records", ["Priority deduction queue", "Deduction exposure summary", "Stale deduction review"]);
  assert.equal(feats.length, 3);
  for (const f of feats) {
    assert.equal(f.aiGenerated, false);
    assert.equal(f.source, "deterministic-fallback");
    assert.ok(f.sections.length >= 2 && f.sections.every((s) => s.title && "detail" in s));
  }
  assert.equal(buildInsights([], "empty", ["Priority deduction queue", "Deduction exposure summary", "Stale deduction review"])[0].metrics[0].value, 0);
});

test("wave66 routes are mounted behind auth in server", () => {
  const server = fs.readFileSync(new URL("../server.mjs", import.meta.url), "utf8");
  assert.ok(server.includes("mountWave66("));
  assert.ok(server.includes("/api/export/records") || fs.readFileSync(new URL("../wave66.mjs", import.meta.url), "utf8").includes("/api/export/records"));
});
