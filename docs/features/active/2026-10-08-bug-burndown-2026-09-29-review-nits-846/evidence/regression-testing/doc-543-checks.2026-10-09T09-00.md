# Regression: #543 folder write scope ([P7-T21], AC-27)

Merge-base substitution: anchored commands use 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a (recorded by [P0-T4]) in place of the plan literal e7d3779b398604af919678c16c877c8539a86cc0.

Timestamp: 2026-10-09T21-40
Command: git diff --name-only 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/
EXIT_CODE: 0
Output Summary: exactly one path: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md`.

## Block 2

Command: git status --porcelain --untracked-files=all -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/
EXIT_CODE: 0
Output Summary: one line, ` M docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md`; no `??` entry.

[P7-T20] result: line 3 `Timestamp: 2026-10-02T05-14`; line 4 carries the new `Timestamp-Correction:` text; lines 32-33 unchanged (A6-SKIP).

Acceptance (AC-27): first block prints exactly the python-batch-budget evidence path; second block prints only that path with status ` M`. PASS.
