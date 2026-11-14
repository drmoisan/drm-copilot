# Preflight Fixes - Stage D Plan (Issue #1097)

Timestamp: 2026-11-07T09-28
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-07T00-22.md

## Fixes

1. [P2-T6] | changed-behavior test citation incomplete (validator-blind class) | The `Existing pins, unchanged` bullet now also names `parallel-gate-wording.Tests.ps1` (its `EXEC-*` rows read `.claude/agents/atomic-executor.md`, its bundle, and `.codex/agents/atomic-executor.toml`, and `PGW-SWEEP-SURFACES` reads every edited skill and agent under `.claude/skills`, `.claude/agents`, `.agents/skills`, and `.codex/agents`), `claude-architecture-doc.Tests.ps1`, and `test_push_down_issue_824_follow_ups.py`, each with its unchanged disposition. [P2-T5] already named these three for its surfaces; [P2-T6] edits further surfaces that the same tests read. No assertion, task, file set, or order changed.

## Checks Performed Without a Fix

- Validators: the installed MCP `validate_orchestration_artifacts` (plan) and the branch-current Python CLI `plan` subcommand both pass; the only findings are the two expected G4 warnings on `--cov --cov-branch` in [P0-T2] and [P3-T3].
- Guard size: all four guard copies are 696 lines and byte-identical (one hash). The R2 edit adds a cap constant and a bounded loop, and the R3 edit adds header text only; the Limits paragraph that [P1-T1] shortens is 13 lines, so the plan's bound of 699 logical lines is reachable. The 700-line advisory tier is not crossed and the 800-line limit is not approached, so no split is required.
- No-key decision: `Get-EpicMergeGateReviewShapeDecision` reads checkpoints only to add a denial under the key, so capping the reads cannot change a decision without the key.
- R3 premise: a SCRATCH probe of the unmodified guard showed a trailing line feed, a trailing semicolon, `pr (#12)`, and `pr $HOME` each unbound and denied under the key and allowed without it, and a plain merge bound to 42, which matches the twelve rows [P1-T2] adds (204 to 216).
- Absent `remediation_path`: no file under `tests`, `scripts`, `extensions/drm-copilot/src`, or `.claude/lib` carries the key, and the corpus parity suites run the full validator over the 41 committed rows, so the unchanged corpus and backcompat suites prove the absent-key case.
- Ledger: entry `0002` holds a `Current` fence for the D10 paragraph of `.claude/rules/orchestrator-state.md`, so each Phase 1 commit updates that entry, as Execution Terms state; the 40-character identifier form is accepted by `Get-ProcessReductionSummaryError`.
- Final gates: project `addopts` writes `artifacts/python/lcov.info`, Jest writes `extensions/drm-copilot/coverage/lcov.info`, and [P3-T3] sets `PYTHONPATH` and keeps both files on disk.
