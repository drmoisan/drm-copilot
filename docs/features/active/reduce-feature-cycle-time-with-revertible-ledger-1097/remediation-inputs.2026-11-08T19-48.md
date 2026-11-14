# Remediation Inputs — Issue 1097

Timestamp: 2026-11-08T19-48
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate
Source review artifacts: none (orchestrator-written merge-conflict finding before the cycle 2 re-audit)
Head: `ac9053572a5f3d283e8409b15564d757b5376707`
Main: `5c81af727d0c4c85b893d6542356c47123454117`
Remediation plan target: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/remediation-plan.2026-11-08T19-48.md`

This file is written by the orchestrator, not by a review. Stage I light cycle 2 (`remediation-inputs.2026-11-08T19-22.md`, reduction commit `448d9918c` with token `reduction: 0010`) completed. Before its re-audit, `main` advanced from `72e8b299c` with PR #1142 (#1138, epic subagent nesting depth). A trial merge conflicts in three files. The conflict is converted into a synthetic blocking finding per `Merge-Conflict Remediation` in the orchestrate skill, so that the re-audit covers the merged tree. Merge-conflict cycles are never light. This is the third remediation attempt of stage I; the termination guard halts after it if the re-audit does not pass.

## Findings requiring remediation

### F1 — Stage I conflicts with `main` after PR #1142

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: Both sides are repository changes with their records committed; resolving them needs no owner decision, external system, or CI result.
Finding-Scope: contained

- Content conflicts (trial `git merge --no-commit origin/main`): `.claude/skills/epic-run/SKILL.md`, its Claude bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-run/SKILL.md`, and `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (`PINNED_FROZEN_SURFACE_HASHES`).
- Clean-merging overlap with 0010 patch paths: PR #1142 also changed `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, their Claude bundle copies, and `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, all recorded by entry `0010`. It also changed the six execution-environment brief copies, `.claude/skills/orchestrate/SKILL.md`, the parallel skills and agents, `enforce-epic-invocation-origin.ps1`, and added `epic-invocation-nesting-depth.ps1` with tests.
- Required change, following the method cycle 1 used (`remediation-plan.2026-11-08T18-06.md`, ### Design Decision):
  1. Merge `origin/main` into the branch with a merge commit (no rebase, no forced push), keeping both sides of every conflicted file. Mirrors stay byte-identical to their sources.
  2. Re-pin `PINNED_FROZEN_SURFACE_HASHES` to the digests of the merged frozen surfaces.
  3. Regenerate entry `0010` and its stored patch against the merged base, so that every pre-image blob equals `origin/main`'s blob of its path and a 0010 revert keeps #1142's text; update revert step 4's pre-0010 digests; commit with a subject carrying `reduction: 0010`. The later-landing rule is not used.
  4. Confirm #1142's nesting-depth rule and the early-start rule do not contradict each other (early-start children are ordinary orchestrator children of the epic orchestrator).
- Verification required: no conflict markers in the merged files; `Test-ProcessReductionLedger` valid; the chain reports `IsValid` true with 0 errors over all 10 entries and every `-StopBefore` sub-chain; `PRC-LEDGER-END-STATE-RECORDED` passes; `git apply -R --check` of the 0010 patch exits 0 and a scratch-index reversal equals `origin/main` on all patch paths; entries `0001` to `0009` unchanged; Codex generator `--check` exits 0; one `Invoke-PoshQCParallelTest` and one `pytest -n auto` with coverage, each compared with the stage I Phase 0 baselines (no new failure, no coverage drop on stage I's changed files; both early-start siblings stay at 100% lines); then the re-audit, which also covers cycle 2's fixes.

## Constraints

- Tests run in parallel only: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. No single-process, seeded-shuffle, reversed-order, or comparison runs.
- No baseline task, baseline evidence, or baseline comparison is reduced.
- No forced push and no history rewrite: the resolution is a merge commit.
- Avoid new Python, except where an existing validator needs a change for parity.
- No Epic #1019 folder is edited; no other item's feature folder that arrived from `main` is edited.
- Do not run an unqualified `poetry install` from the item worktree.
