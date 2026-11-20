# Remediation Inputs — Issue 1097

Timestamp: 2026-11-07T18-49
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: design
Source review artifacts:
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/policy-audit.2026-11-07T18-49.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/code-review.2026-11-07T18-49.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/feature-audit.2026-11-07T18-49.md`
Head: `ce7c77f0207c8df4f9c7bc045f9a5f3c27106bfe`
Base: `main`, merge base `81b6a1be385666e5025936a85e487e43e7ac6187`
Remediation plan target: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/remediation-plan.2026-11-07T18-49.md`

This file supersedes `remediation-inputs.2026-11-07T17-13.md`. It is the first review of stage R (PR R). The path is `full` because the fix edits `docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch`, which is outside the branch diff and is neither a test nor a mirror.

## Findings requiring remediation

### F1 — Entry `0001` revert step 1 contradicts README `## Revert Order`

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The correction uses only repository records and the remedy the stage R README already states; it needs no owner decision, external system, or CI result.
Finding-Scope: contained

- Files:
  - `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` (`## Revert Steps`, step 1)
  - `docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch` (the section for `0001-parallel-only-test-gates.md`, whose added line is that step)
- Problem:
  - Step 1 reads "revert entry `0006` ... first ... Then run `git apply -R` of the patch when its check passes".
  - README `## Revert Order` requires every later entry that names any of the entry's paths to be reverted first, newest-first. It also states that an entry's `## Revert Steps` does not list the later entries that depend on it.
  - Entries `0002` to `0005` share 6, 29, 6, and 31 paths with `0001`.
  - Reverting only `0006`, then `0001`, fails 26 hunks on 15 source paths. The full newest-first chain fails none.
  - AC R1 ("no entry lists its dependants") is therefore PARTIAL and was unchecked by the review.
- Required change:
  1. Replace step 1 with text that defers to README `## Revert Order` and names no entry. For example: revert every later entry that names any path in `## Files Changed`, newest-first, as README `## Revert Order` states; then run `git apply -R` of the patch when its check passes; otherwise keep the existing fallback sentence about the `## Prior Text` blocks.
  2. In the same commit, regenerate the hunk of the `0006` stored patch that adds step 1, so that its post-image carries the new text. Leave its pre-image and every other section unchanged. Carry both `reduction: 0001` and `reduction: 0006` in the commit subject.
  3. Do not edit the `PRL-PARTIAL-REVERT-LINKED` targets: the `0001` index row, the `0001` `## Partial Revert` section, and the `0006` `## Summary` sentence naming `0001`.
- Verification required:
  - `Invoke-ProcessReductionChain` over `Read-ProcessReductionChainInput` reports `IsValid` true with 0 errors.
  - `git apply -R --check` of the `0006` patch exits 0 on the live tree.
  - The git-level chain gate of the stage R plan [P1-T10] still exits 0 for `0006` and `0001`.
  - A search of `0001` `## Revert Steps` for an entry number of a later entry returns no match.
  - One `Invoke-PoshQCParallelTest` run with 0 failures, in which `PRC-LEDGER-CHAIN-HOLDS`, `PRL-REAL-LEDGER-AGREES`, and `PRL-PARTIAL-REVERT-LINKED` pass and no coverage figure drops against the stage R Phase 0 baseline.
  - Re-review, which checks off R1.

## Non-blocking items carried

- RN1 (Minor): the README gives no route for reverting an older reduction while keeping later ones. Suggested sentence: write a new entry that restores the older entry's stored prior text over the current tree, as `0006` did for `0001`. This is an owner decision whether to require it. It may be added in this cycle, because the README is in the branch diff.
- RN2 (Minor): the created-path end-state check in `Get-ProcessReductionEndStateError` cannot fail, and line 368 is unreachable. Remove it or make it check something.
- RN3, RN4 (Nits): `Get-ProcessReductionDerivedSource` returns the first mapping hop; derivation is decided from live text only.
- N2, N3 (carried).

## Constraints

- Tests run in parallel only, per `spec.md` `## Testing Rule`: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. No single-process, seeded-shuffle, reversed-order, or comparison runs.
- No baseline task, baseline evidence, or baseline comparison is reduced.
- No forced push, no history rewrite, no tag.
- No Epic #1019 folder is edited. `plan.2026-11-07T12-43.md` (stage G) is not edited.
