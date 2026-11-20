# Remediation Inputs — Issue 1097

Timestamp: 2026-11-07T06-05
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate
Source review artifacts:
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/policy-audit.2026-11-07T06-05.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/code-review.2026-11-07T06-05.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/feature-audit.2026-11-07T06-05.md`
Head reviewed: `d854f13c3da7d3d97873cb4b8adab47e3a8fa7dc` (merge base `51d3886485956df68a68a38e920c7c3687ec4462`)
Remediation plan target: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/remediation-plan.2026-11-07T06-05.md`

This file supersedes `remediation-inputs.2026-11-07T04-50.md`, because the orchestrator reads the highest timestamp. That file covered stage A at another head.

## Findings requiring remediation

### F1 — Coverage artifact and full suite absent for TypeScript

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: One local Jest run in the extension produces the artifact and the full-suite result; it needs no external party, policy decision, owner input, or CI result.

- Files: `extensions/drm-copilot/coverage/lcov.info` (generated, gitignored); new evidence under `evidence/qa-gates/`. No source change is expected.
- Problem: `extensions/drm-copilot/test/lib/validate/orchestrator-state-stage-timing.test.ts` is a changed TypeScript file, so coverage verification is mandatory for TypeScript. Neither `coverage/lcov.info` nor `extensions/drm-copilot/coverage/lcov.info` exists. The recorded gates (`stage-b-typescript-test.2026-11-07T05-48.md` and the baseline `stage-b-typescript-validator-tests.2026-11-07T05-20.md`) ran `--testPathPattern "test/lib/validate/orchestrator-state" --coverage=false`, a 24-suite subset, so the TypeScript unit-test stage of the toolchain loop has not run over the full suite. No TypeScript production file changed, so the review contract has no per-file figure to judge, but it requires the artifact and a repo-wide figure for the language.
- Required change: in `extensions/drm-copilot`, run once: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` (the `test:coverage` script; Jest runs workers in parallel). Do not add a serial or shuffled run.
- Verification required: (a) the run exits 0 with zero failures; (b) `extensions/drm-copilot/coverage/lcov.info` exists after it and is on disk when re-review starts, because the directory is gitignored and the re-review reads it there; (c) a new `evidence/qa-gates/stage-b-typescript-coverage.<timestamp>.md` records the test counts and the repo-wide line and branch percentages; (d) if the run fails, report each failing suite and whether it also fails at the merge base before changing any file; a coverage-threshold failure in a file this branch does not change is a pre-existing condition to be recorded, not fixed here.

## Non-remediation items (record only; recommended for the same cycle)

These are from `code-review.2026-11-07T06-05.md`. None blocks.

- Minor: add a skipped-entry case for a missing `started_at`, which executes the unexecuted line 81 of `StageTiming.psm1`.
- Minor: add cases for a missing `stage` or `attempt` property and for a stage with only open entries (lines 163, 169, 175, 327).
- Minor: state in the skill that `issue-num` is a JSON string, or accept an integer; a JSON number skips the whole file.
- Minor: split the one-line stage-timing paragraph in the orchestrate skill copies when next edited.
- Three Nit items need no action unless the same lines are touched.

If the Minor test additions are made, one `Invoke-PoshQCParallelTest` run follows, after format and lint.

## Constraints

- Tests run in parallel only, per `spec.md` `## Testing Rule`: one Jest coverage run for F1, and one `Invoke-PoshQCParallelTest` run only if a PowerShell file changes.
- No acceptance-criterion text or checkbox changes. The six `[A]` and two `[B]` items stay checked.
- No ledger entry is owed: this cycle reduces nothing.
- PowerShell new-code line coverage stays at or above 85%, and `StageTiming.psm1` stays below 700 lines (434 now).
- No Epic #1019 folder, `execution-environment`, or `atomic-plan-contract` file is edited.
