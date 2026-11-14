# Remediation Inputs (Issue #1006), re-audit at the exit of remediation cycle 1

Review-Verdict: AWAITING_CI
Remediation-Mode: proportionate

**Entry timestamp:** 2026-10-31T09-41
**Feature folder:** `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006`
**Base branch:** `main` (merge base `1898400756e909b88cde5f51a05f0b11d423d3b0`)
**Head:** `bug/parallel-scheduling-false-hard-edges-1006` @ `d7dd48791e6ad0a1127251dcf32284c1cabd51aa`
**Work mode:** `full-bug`; AC source is `spec.md` only (25 AC, all PASS)
**Blocking finding count:** 1 (awaiting_ci: 1; other classes: 0)

## Audit Artifacts

- `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/policy-audit.2026-10-31T09-41.md` (Section 8, PA-2; PA-1 closed)
- `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/code-review.2026-10-31T09-41.md` (Findings Table, one Major row)
- `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/feature-audit.2026-10-31T09-41.md` (25 PASS, 0 PARTIAL, 0 FAIL)

## Cycle 1 Outcome

- R1 (TypeScript coverage artifact, PA-1): closed. `extensions/drm-copilot/coverage/lcov.info` exists; the reviewer re-read overlay LF 444/LH 442, BRF 100/BRH 96 and demote LF 157/LH 157, BRF 27/BRH 27; repo-wide 97.05% line, 93.67% branch.
- CR Minor (duplicated union): closed. One `unionStrings` definition in the demote module, imported by the overlay module; no import cycle.
- CR Nit (`$script:OverlayDirectiveKey`): closed. Local `$overlayDirectiveKey`.

## Findings

### R2 — Python repo-wide coverage figure absent (policy-audit PA-2)

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: CI job quality-checks7 / Code Quality & Tests runs pytest --cov --cov-branch over the whole repository and the step Enforce Python coverage thresholds (--min-line 85 --min-branch 75) on the PR head; no PR exists for the branch (gh pr list returned an empty list), so that record cannot exist until the PR is opened and CI completes. Cycle 1 changed no Python file, and each changed Python module holds or raises its coverage with every added line covered.

**Observed state.** `artifacts/python/lcov.info` contains five `SF:` records (the changed modules only), produced by dotted `--cov=` targets.

**Expected state.** On the PR `CI` run for the final head SHA, the step `Enforce Python coverage thresholds` concludes `success`, and its pytest `TOTAL` line shows at least 85% line and 75% branch.

**Clearing procedure.** At the S9 CI gate, record the job id, the step conclusion, and the `TOTAL` line in `evidence/qa-gates/` (for example `py-coverage-pr-ci.<timestamp>.md`). A local full-repository `poetry run pytest --cov --cov-branch` may be recorded as supplementary evidence; it does not replace the CI record.

## Do Not Do

- Do not change production or test code to address R2; it requires no code change.
- Do not lower, reinterpret, or add exclusions to coverage thresholds.
- Do not write coverage evidence outside `evidence/qa-gates/` in this feature folder.

## Related findings that do not block the merge

- CR Minor (carried forward): `.claude/skills/parallel-plan/SKILL.md` and its bundle copy state "three token shapes" while the rule lists five. Out of scope by spec (AC-23 asserts the file is unchanged); recorded in `evidence/other/follow-ups.2026-10-31T08-43.md`.

## Orchestrator Cycle Scope

No autonomous remediation cycle is required. Proceed to PR authoring and clear R2 at the S9 CI gate.
