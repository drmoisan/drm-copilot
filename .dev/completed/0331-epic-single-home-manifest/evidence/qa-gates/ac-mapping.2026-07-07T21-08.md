# Acceptance-Criteria Mapping (P6-T10) (#331)

Timestamp: 2026-07-07T21-08
AC sources (full-feature mode): spec.md and user-story.md (six canonical ACs).

## AC-1 — new_active_feature_folder(type=epic) scaffolds only epics/<slug>/{epic.md, epic-status.md}; no active/ epic folder; no initiative.md

- Tasks: P1-T1..T6 (templates: epic.md + epic-status.md created in both source
  locations; initiative.md deleted), P2-T1..T8 (TS flow/io/docs + Python
  flow/io/docs epic branches; tests).
- Evidence: qa-gates/p2-python.<ts>.md, qa-gates/p2-ts.<ts>.md.
- Tests: TS flow.test.ts "createActiveFolder epic creation (single home)",
  io.test.ts "copyTemplate epic", docs.test.ts "updateFeatureDocs epic";
  Python test_new_active_feature_folder_part2.py
  test_create_epic_folder_scaffolds_single_home, test_update_feature_docs_for_epic_type.
- Status: PASS.

## AC-2 — epic-orchestrate skill documents single-home layout, epic.md merged source, DAG keyed by issue_num, generated-only epic-status.md, optional intent block; active->completed workaround removed

- Tasks: P4-T1..T6 (SKILL.md edits + byte-identical mirror sync).
- Evidence: other/related-runtime-file-review.<ts>.md, qa-gates/parity-resource-contract.<ts>.md.
- Verification: SKILL.md names epic.md, states issue_num keying, documents the intent
  block, reinforces generated-only epic-status.md; the active->completed parenthetical
  was removed and replaced with issue_num-keyed resolvable-hint phrasing. No
  epic-plan.md reference remains in the skill or related agents.
- Status: PASS.

## AC-3 — validators resolve DAG by issue_num, accept feature_folder in active/ or completed/, validate intent only when present, remain byte-identical on legacy (regression proves it)

- Tasks: P3-T1..T14 (Python resolver + hint resolution + presence-gated intent;
  TS parity port; fixtures; regression).
- Evidence: regression-testing/py-validator-legacy.<ts>.md,
  regression-testing/py-wave-computation-legacy.<ts>.md, qa-gates/p3-python.<ts>.md,
  qa-gates/p3-ts.<ts>.md, qa-gates/parity-validator.<ts>.md.
- Verification: 23 legacy validator tests + 8 wave tests unchanged and passing
  (196 insertions / 0 deletions in the test file; epic_wave_computation.py unmodified
  per git status). New tests cover issue_num resolution, active/completed hint
  resolution, and presence-gated intent (valid/negative/absent). TS port emits
  byte-identical error strings.
- Status: PASS.

## AC-4 — new/changed logic has tests; toolchain (format -> lint -> type-check -> tests) passes in order

- Tasks: P2-T9/T10, P3-T13/T14, P6-T1..T8.
- Evidence: qa-gates/final-py-format/lint/typecheck/test.<ts>.md,
  qa-gates/final-ts-format/lint/typecheck/test.<ts>.md, qa-gates/coverage-delta.<ts>.md.
- Verification: Python black/ruff/pyright/pytest all EXIT_CODE 0 (1309 passed);
  TypeScript format/lint/typecheck/test all EXIT_CODE 0 (1568 passed). Coverage above
  gates on changed modules, no regression on changed lines.
- Status: PASS.

## AC-5 — push-down tooling updated/run so consumer repos can pick up the change

- Tasks: P5-T1..T4.
- Evidence: qa-gates/pushdown.<ts>.md, qa-gates/parity-resource-contract.<ts>.md,
  qa-gates/parity-pack-manifest.<ts>.md, qa-gates/parity-validator.<ts>.md.
- Verification: push_down_claude_customizations ran EXIT_CODE 0 (99 files created,
  epic-orchestrate skill + epic-orchestrator agent published); resource-contract and
  pack-manifest-completeness parity gates pass.
- Status: PASS.

## AC-6 — change description records the deferred per-consumer migration (incl. TaskMaster epic #260)

- Tasks: P4-T9.
- Evidence: other/migration-deferral-note.<ts>.md (captures the exact text for the
  #331 change description / PR body).
- Status: PASS (deferral text recorded; to be included verbatim in the PR body).

## Summary

All six acceptance criteria map to completed tasks and concrete evidence artifacts.
