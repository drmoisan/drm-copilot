# Preflight Fixes - Stage E Plan (Issue #1097)

Timestamp: 2026-11-07T11-14
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-07T02-37.md
Branch: feature/reduce-feature-cycle-time, at the stage D merge (PR #1104) plus the amended plan
Signal: PREFLIGHT: ALL CLEAR

Single-pass preflight against the item worktree tree and the `[E]` criteria of `spec.md`. Every fix below edits task text only; no task was added, removed, or reordered, and no fix changes what an acceptance condition asserts.

## Fixes

1. [P0-T3] | literal formatting | The back-fill line now states that the identifier is the full 40-character lowercase `mergeCommit.oid` that `gh` returns, which is the form `Get-ProcessReductionSummaryError` accepts (`Merge commit: ` followed by 7 to 40 lowercase hexadecimal characters). Verified: the four-step derivation over the merged pull requests of the branch yields exactly one candidate holding the reduction commit (PR #1104), and that commit is an ancestor of `HEAD`.
2. [P2-T3] | intent clarification | Place 20 now states that the template's Phase 0 task is replaced together with its `policy review timestamp` acceptance sub-bullet. The sub-bullet carries no baseline wording, so the hold is unaffected.
3. [P3-T4] | missing test disposition | Three further suites that read `tests/fixtures/orchestrator_state_remediation_loop/` are named as unchanged: `test_orchestrator_state_light_cycle.py` `test_corpus_expects_every_invariant_8_message` (requires each message in at least one row), `orchestrator-state-remediation-accounting.test.ts`, and `OrchestratorStateRemediationAccounting.Tests.ps1` (each reads one named row). Adding two rows changes none of their results.
4. [P4-T2] | unobservable output field | The Output Summary asked for the `LINE` counters of the bundle copies from `artifacts/pester/powershell-coverage.xml`. The roots of `config/poshqc-coverage.json` exclude `extensions/`, and the existing coverage report holds no `extensions` path, so those counters do not exist. The summary now states that and cites the bundle hash checks. The acceptance condition, which names only the four production files, is unchanged.
5. ## Pre-Mortem, File size | stale count | `OrchestratorStateCheckpointValue.psm1` holds 385 logical lines, not 386, and `OrchestratorStateRemediationAccounting.psm1` holds 449, not 450 (each file ends with one line terminator).

## Verified Without Change

- Baseline hold: no task changes baseline, coverage-comparison, or `N/A - no pre-change run` text. Each held string sits in a section or file the plan does not edit (`## Coverage Evidence Contract`, the `feature-review-workflow` copies, the feature-review coverage hooks, and the policy-audit template). Places 1 to 20 remove only policy-read wording, and place 18 (`.github/prompts/review-feature.prompt.md` and its bundle) stays in place.
- Entry order: smaller plans takes `0004` and policy-read removal the next number, each in its own whole commit with its entry and `README.md` row; [P3-T2] updates `0002` and [P3-T3] and [P3-T4] update `0003` with their tokens. `ProcessReductionLedger.Index.Tests.ps1` compares row and entry counts dynamically.
- Replay sample: `ProcessReductionLedger.Replay.Tests.ps1` applies the hook blocks to the live text in memory and writes no file.
- Brief: the six copies are byte-identical today, and every target heading exists. [P1-T1], [P3-T2], and [P3-T3] each copy to all six.
- N1: `Get-RemediationLightCycleError` reads exactly the seven keys the Design lists, and the invariant 2 exemption in `Get-RemediationCycleError` reads `remediation_path`. No commit after the `0003` reduction commit touched either module, so the in-place `Current` updates and the first-parent replay are consistent. A SCRATCH probe of the Python validator returned exactly the two expected messages for the `Remediation_Path` and `Scope` key variants, and no existing test feeds a mis-cased key or pins the module's export set. The three corpus floors read 55 and the directory holds 55 rows.
- Epic #1019 plans: only `.claude/hooks/validate-planner-output.ps1` enforces the policy-read task. Removing its check only relaxes validation, so a plan that keeps the task stays valid, and [P2-T1] adds `accepts a plan that keeps the policy-read task`.
- Validator: `scripts/dev_tools/validate_orchestration_artifacts.py plan` passes with the expected G4 warning on `--cov --cov-branch`.
