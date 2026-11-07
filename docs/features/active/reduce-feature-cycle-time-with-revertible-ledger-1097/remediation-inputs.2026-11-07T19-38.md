# Remediation Inputs — Issue 1097

Timestamp: 2026-11-07T19-38
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate
Source review artifacts:
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/policy-audit.2026-11-07T18-49.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/code-review.2026-11-07T18-49.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/feature-audit.2026-11-07T18-49.md`
Head: `412aad26b1fbeb0eec151ea2b391d4528c1cd599`
Remediation plan target: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/remediation-plan.2026-11-07T19-38.md`

This file is written by the orchestrator, not by a review. After stage R's remediation cycle completed, and before its re-audit, `main` advanced with PR #1112 (#1096, Pester static leak scan). A trial merge conflicts in `docs/engineering/process-reductions/0001-parallel-only-test-gates.md`. The conflict is converted into a synthetic blocking finding per `Merge-Conflict Remediation` in the orchestrate skill, so that the re-audit reviews the merged tree. Merge-conflict cycles are never light.

## Findings requiring remediation

### F1 — Stage R conflicts with `main` after PR #1112 in ledger entry `0001`

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: Both sides are repository changes with their records committed; resolving them needs no owner decision, external system, or CI result.
Finding-Scope: contained

- Files: `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` has a content conflict. PR #1112 also changed `scripts/dev-tools/DrmCopilotPromptSupport.ps1` and three `tests/scripts/dev-tools/` suites, which merged cleanly.
- Problem: PR #1112 added a second landing to entry `0001`: the #1096 paths under `## Files Changed`, a note that the stored patch does not hold them, and new `### Revert Block:` sections under `## Prior Text`. That landing happened after entries `0002` to `0006`. This branch's stage R work rewrote `0001` `## Revert Steps`, added the revert-order rule and the chain test, and edited `0001` sections. The chain test walks entries newest-first by number, but part of `0001` now landed later than higher-numbered entries.
- Required change:
  1. Merge `origin/main` into the branch, keeping both sides of `0001`: PR #1112's landing text and blocks, and this branch's revert-step wording and stage R edits. Lose neither.
  2. Run the chain check over the merged ledger. If it holds with no exception, record that. If the #1096 landing breaks newest-first order, make the order rule and the chain express revert order by landing, not only by entry number. One possible shape: an entry whose blocks landed in parts reverts each part at its own place in the order. Update the README `## Revert Order` text, the chain module, and its tests together, so that the rule a reader follows months later and the rule the test enforces are the same. No exception list and no skip.
  3. Any edit to an entry carries that entry's `reduction:` token in its commit subject.
- Verification required: no conflict markers in the merged files; `Test-ProcessReductionLedger` valid; the chain check reports `IsValid` true with 0 errors over the merged ledger; `git apply -R --check` of the `0006` patch and the git-level chain gate still exit 0; one `Invoke-PoshQCParallelTest` and one `pytest -n auto` with coverage (PR #1112 changed Python files on `main`, and the merged tree must pass), each compared with the stage R Phase 0 baseline; re-review.

## Constraints

- Tests run in parallel only, per `spec.md` `## Testing Rule`: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. No single-process, seeded-shuffle, reversed-order, or comparison runs.
- No baseline task, baseline evidence, or baseline comparison is reduced.
- No forced push and no history rewrite: the resolution is a merge commit.
- No Epic #1019 folder is edited, and `plan.2026-11-07T12-43.md` (stage G) is not edited.
