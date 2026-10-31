# Remediation Inputs (Issue #1006), initial review

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

**Entry timestamp:** 2026-10-31T08-57
**Feature folder:** `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006`
**Base branch:** `main` (merge base `1898400756e909b88cde5f51a05f0b11d423d3b0`)
**Head:** `bug/parallel-scheduling-false-hard-edges-1006` @ `fc1d8618bf26e9e2ffa2e81dec5e1380ec2763f8`
**Work mode:** `full-bug`; AC source is `spec.md` only (25 AC, all PASS)
**Blocking finding count:** 2 (autonomous: 1; awaiting_ci: 1; other classes: 0)

## Audit Artifacts

- `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/policy-audit.2026-10-31T08-57.md` (Section 8, PA-1 and PA-2)
- `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/code-review.2026-10-31T08-57.md` (Findings Table, two Major rows)
- `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/feature-audit.2026-10-31T08-57.md` (25 PASS, 0 PARTIAL, 0 FAIL)

## Trigger Justification

The feature-review contract requires coverage to be verified from an artifact for every language with changed files, including a repo-wide figure. TypeScript has changed production files and no coverage artifact. The Python artifact is scoped to the five changed modules, so it gives no repo-wide figure.

## Findings

### R1 — TypeScript coverage artifact absent (policy-audit PA-1)

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The artifact can be produced locally in this worktree with the existing package script test:coverage (lcov plus text-summary reporters); CI job drm-copilot-extension-tests runs npm run test without coverage, so CI cannot supply it, and no human decision or external dependency is involved.

**Observed state.** `coverage/lcov.info` and `extensions/drm-copilot/coverage/lcov.info` do not exist. `evidence/qa-gates/ts-jest.2026-10-31T08-36.md` records a run with `--coverageReporters=text`, which overrides the configured `lcov` reporter. No repo-wide TypeScript line or branch figure is recorded.

**Expected state.** `extensions/drm-copilot/coverage/lcov.info` exists for the head commit. A new evidence file under `evidence/qa-gates/` (for example `ts-coverage.<timestamp>.md`) records `Command:`, `EXIT_CODE: 0`, the line and branch percentages for `src/lib/push-down/claude-blast-radius-overlay.ts` and `src/lib/push-down/claude-blast-radius-overlay-demote.ts` read from `lcov.info`, and the repo-wide (all files) line and branch percentages from the text-summary.

**Clearing procedure.**
1. Run `npm --prefix extensions/drm-copilot run test:coverage`.
2. Read the per-file LF/LH and BRF/BRH values for both files from `extensions/drm-copilot/coverage/lcov.info` and the totals from the text-summary.
3. Write the evidence file. If the repo-wide TypeScript figure is below 85% line or 75% branch, record the merge-base figure from the same command run on `1898400756e909b88cde5f51a05f0b11d423d3b0` to show the shortfall is pre-existing and not lowered by this branch. Then report it to the orchestrator for a decision rather than editing unrelated code.

### R2 — Python repo-wide coverage figure absent (policy-audit PA-2)

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: CI job quality-checks7 / Code Quality & Tests runs pytest --cov --cov-branch over the whole repository and the step Enforce Python coverage thresholds (--min-line 85 --min-branch 75) on the PR head; no PR exists yet, so that record cannot exist until the PR is opened and CI completes. The five changed modules each hold or raise their coverage with every added line covered, so the branch cannot lower the repo-wide figure.

**Observed state.** `artifacts/python/lcov.info` contains five `SF:` records (the changed modules only), produced by dotted `--cov=` targets.

**Expected state.** On the PR `CI` run for the final head SHA, the step `Enforce Python coverage thresholds` concludes `success`, and its pytest `TOTAL` line shows at least 85% line and 75% branch.

**Clearing procedure.** At the S9 CI gate, record the job id, the step conclusion, and the `TOTAL` line in `evidence/qa-gates/` (for example `py-coverage-pr-ci.<timestamp>.md`). A local `poetry run pytest --cov --cov-branch --cov-report=json:...` over the whole repository may be recorded as supplementary evidence. It does not replace the CI record.

## Do Not Do

- Do not change production or test code to address R1 or R2; neither requires a code change.
- Do not lower, reinterpret, or add exclusions to coverage thresholds.
- Do not write coverage evidence outside `evidence/qa-gates/` in this feature folder.

## Related findings that do not block the merge

- CR Minor: `claude-blast-radius-overlay-demote.ts` re-implements the order-preserving union instead of reusing `unionStrings`. Move the helper to a shared leaf and use it from both TS modules without creating an import cycle. This is suitable for this remediation cycle.
- CR Minor: `.claude/skills/parallel-plan/SKILL.md` and its bundle copy state "three token shapes", while the rule now lists five. Replace the count with a reference to `### Read-by-mandate classification`. The spec puts this out of scope and it is recorded in `evidence/other/follow-ups.2026-10-31T08-43.md`. Fixing it here requires a spec scope amendment, because the plan's scope check freezes the skill file.
- CR Nit: `BlastRadius.KeyPartition.Tests.ps1` assigns `$script:OverlayDirectiveKey` inside an `It` block; use a local variable.
- CR Info: the issue-promotion record under `docs/features/potential/promoted/` is in the diff. It is the standard lifecycle record and needs no action.

## Orchestrator Cycle Scope (cycle 1)

In scope for this cycle:

1. R1: produce the TypeScript coverage artifact and its evidence file as described above.
2. CR Minor (union helper): remove the duplicated order-preserving union from `claude-blast-radius-overlay-demote.ts`. The demote module must keep importing nothing from `claude-blast-radius-overlay.ts`. The permitted route is to define the single helper in `claude-blast-radius-overlay-demote.ts` (or keep it in `claude-blast-radius-overlay.ts` only if no cycle results) and import it from the other module. Do not create a new production file. Existing tests in `claude-blast-radius-overlay.test.ts`, `claude-blast-radius-overlay-parity.test.ts`, and `claude-blast-radius-overlay-demote.test.ts` must pass unchanged, and both files must keep their `coverageThreshold` entries satisfied.
3. CR Nit: in `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`, replace the `$script:OverlayDirectiveKey` assignment inside the `It` block with a local variable.
4. Re-run the toolchain for the touched languages (TypeScript format, lint, typecheck, Jest with coverage; Pester for the touched suite with analyzer) and record evidence under `evidence/qa-gates/`.

Out of scope for this cycle: R2 is `awaiting_ci` and is cleared at the S9 CI gate. The stale "three token shapes" sentence in `.claude/skills/parallel-plan/SKILL.md` stays a recorded follow-up. That file is outside this item's declared blast radius in a parallel run (the scheduler admitted sibling items against the declared radius), and AC-23 asserts it is unchanged, so editing it here would invalidate both the parallel schedule and a spec criterion.
