# Remediation Inputs — Issue 1097

Timestamp: 2026-11-08T18-06
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate
Source review artifacts: none (orchestrator-written merge-conflict finding before the stage I review)
Head: `536ac1b4e0c35a7bc4424b8d85946aa3d374edf5`
Main: `a90d522c6ac239bca858d7bc800d52860e823219`
Remediation plan target: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/remediation-plan.2026-11-08T18-06.md`

This file is written by the orchestrator, not by a review. Stage I finished execution (plan `plan.2026-11-07T00-56.md`, reduction commit `5988fc822` with token `reduction: 0010`, chain-fix commit `39da5e907`). Before its review, `main` advanced from `95a16e165` with PR #1134 (#1129, epic wave computation push-down), PR #1135 (#1130, epic-child PR CI required), and PR #1137 (#1128, runbook command version check). A trial merge conflicts in seven files. The conflict is converted into a synthetic blocking finding per `Merge-Conflict Remediation` in the orchestrate skill, so that the stage I review covers the merged tree. Merge-conflict cycles are never light.

## Findings requiring remediation

### F1 — Stage I conflicts with `main` after PRs #1134, #1135, #1137

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: Both sides are repository changes with their records committed; resolving them needs no owner decision, external system, or CI result.
Finding-Scope: contained

- Content conflicts (trial `git merge --no-commit origin/main`):
  - `.claude/skills/epic-run/SKILL.md`, `.agents/skills/epic-run/SKILL.md`, and the two bundle copies (`extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-run/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-run/SKILL.md`): #1130 commit `0eae765b6` added the epic-child CI requirement text; stage I added the early-dependent-start text.
  - `.claude/agents/epic-orchestrator.md` and its bundle copy: #1129 commits `22a3f578a` and `417c4f889` granted and cited the wave CLI; stage I added its own text or tool grant.
  - `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`: both #1129/#1130 and stage I re-pinned `PINNED_FROZEN_SURFACE_HASHES` digests of the frozen epic surfaces.
- Semantic overlap to check even where the merge is clean: #1129 added `.claude/lib/epic-wave/` (wave computation, corpus parity tests such as `tests/scripts/dev_tools/test_epic_wave_corpus_parity.py`) and edited `.claude/skills/epic-orchestrate/SKILL.md` and its mirrors; #1130 changed `.claude/hooks/enforce-epic-merge-gate.ps1` and added `enforce-epic-merge-gate-child-ci.ps1` (Claude and Codex). Stage I edits the epic wave barrier (layers 1 and 2), the epic-orchestrate and epic-run skills, and adds `tests/fixtures/epic_wave_barrier/early-start-edge-cases.json`. Confirm that no #1129 corpus or parity test scans the stage I corpus or wave-barrier fixtures in a way that changes its counts or results, and that the epic merge gate and the early-start rule do not contradict each other.
- Required change:
  1. Merge `origin/main` into the branch with a merge commit (no rebase, no forced push), keeping both sides of every conflicted file: main's text and stage I's text. Lose neither. Mirrors stay byte-identical to their sources.
  2. Re-pin `PINNED_FROZEN_SURFACE_HASHES` to the digests of the merged frozen surfaces.
  3. Ledger entry `0010` (`docs/engineering/process-reductions/0010-early-dependent-starts.md`) and its stored patch `patches/0010-early-dependent-starts.patch` were generated against the pre-merge base. The 0010 reduction lands on `main` after #1129 and #1130, so its record must describe the change relative to the merged base: the stored patch must reverse cleanly (`git apply -R --check`) against the merged tree and the chain (`scripts/dev-tools/ProcessReductionChain.psm1`) must report `IsValid` true with 0 errors over all 10 entries and every `-StopBefore` sub-chain, with `PRC-LEDGER-END-STATE-RECORDED` passing. Revert steps and revert signals in 0010 must name the merged frozen digests correctly. Decide whether 0010 is regenerated against the merged base (an edit to 0010, so its commit subject carries `reduction: 0010`) or whether the existing later-landing rule applies; the README `## Revert Order` and the chain must agree with the choice. No exception list and no skip.
  4. Entries `0001` to `0009` are not edited unless the chain shows it is needed.
- Verification required: no conflict markers in the merged tree; `Test-ProcessReductionLedger` valid; the chain check reports `IsValid` true with 0 errors over the merged ledger; `git apply -R --check` of the 0010 stored patch exits 0 on the merged tree; the Codex generator `--check` exits 0; the push-down contract tests pass; one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, and one Jest coverage run in `extensions/drm-copilot/`, each compared with the stage I Phase 0 baselines (main's new tests raise the counts; the comparison is no new failure and no per-file or repo-wide coverage drop on stage I's changed files); then the stage I review.

## Constraints

- Tests run in parallel only: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. No single-process, seeded-shuffle, reversed-order, or comparison runs.
- No baseline task, baseline evidence, or baseline comparison is reduced.
- No forced push and no history rewrite: the resolution is a merge commit.
- Avoid new Python, except where an existing validator needs a change for parity.
- No Epic #1019 folder is edited; no other item's feature folder that arrived from `main` is edited.
- Do not run an unqualified `poetry install` from the item worktree.
