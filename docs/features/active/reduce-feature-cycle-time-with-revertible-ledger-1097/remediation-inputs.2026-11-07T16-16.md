# Remediation Inputs — Issue 1097

Timestamp: 2026-11-07T16-16
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate
Source review artifacts:
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/policy-audit.2026-11-07T16-07.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/code-review.2026-11-07T16-07.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/feature-audit.2026-11-07T16-07.md`
Head: `41caab5a18774e8097469c7842e94c9443ecd1cc`
Remediation plan target: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/remediation-plan.2026-11-07T16-16.md`

This file is written by the orchestrator, not by a review. The stage E and E2 review passed at `9676eed60`. After PR #1110 opened, `main` advanced with PR #1108 (#1106, policy-file consistency), and the PR became `CONFLICTING`, so GitHub ran no checks. The conflict is converted into a synthetic blocking finding per `Merge-Conflict Remediation` in the orchestrate skill. Merge-conflict cycles are never light.

## Findings requiring remediation

### F1 — PR #1110 conflicts with `main` after PR #1108

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The conflict is between two repository changes, and both are known and recorded; resolving it needs no owner decision, external system, or CI result.
Finding-Scope: contained

- Files with content conflicts on `git merge origin/main`:
  - `.claude/agents/csharp-typed-engineer.md`
  - `.claude/skills/csharp-qa-gate/SKILL.md`
  - `.claude/skills/invoke-csharp-engineer/SKILL.md`
  - `.codex/agents/powershell-di-unit-test-engineer.toml`
  - `.github/agents/Powershell DI Unit Test Engineer.agent.md`
  - the five bundle copies of those files under `extensions/drm-copilot/resources/`.
- Problem: PR #1108 rewrote test-framework and toolchain wording in these files (MSTest and vstest naming, Pester v6), and stage E2 of this branch restored baseline lines in the same regions. Ledger entries `0001` and `0006` cover these files, so their revert blocks and the `0006` stored patch may no longer match after the merge.
- Required change:
  1. Merge `origin/main` into the branch, keeping both changes in each conflicted region: #1108's wording and E2's restored baseline and comparison lines. Lose neither side.
  2. Keep each bundle byte-identical to its source, and run the Codex variant generator `--check`.
  3. Update every `Current` block in entries `0001` and `0006` that covers a merged file, so that each block replays to its stated prior text against the merged tree, and regenerate the `0006` stored patch over its path set so it still reverse-applies. Commit those entry edits with `reduction: 0006` in the subject, and `reduction: 0001` too if `0001` changes. Record in each entry that its text was rebased over #1108.
  4. Re-check every other entry's replay against the merged tree.
- Verification required: no conflict markers in the tree; bundles equal their sources; generator `--check` exits 0; `Test-ProcessReductionLedger` valid; every entry's blocks replay; `git apply -R --check` of the `0006` patch exits 0; one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, and one Jest coverage run, each compared with the stage E2 Phase 0 baseline; re-review.

## Constraints

- Tests run in parallel only, per `spec.md` `## Testing Rule`: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. No single-process, seeded-shuffle, reversed-order, or comparison runs.
- No baseline task, baseline evidence, or baseline comparison is reduced.
- No forced push and no history rewrite: the resolution is a merge commit.
- No Epic #1019 folder is edited.
