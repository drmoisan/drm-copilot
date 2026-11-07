# Remediation Inputs — Issue 1097

Timestamp: 2026-11-07T20-50
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: light
Remediation-Mode: light
Source review artifacts:
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/policy-audit.2026-11-07T20-50.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/code-review.2026-11-07T20-50.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/feature-audit.2026-11-07T20-50.md`
Head: `2195ec4e01c54aa4fd28181f0b536de7379de4a7`
Base: `main`, merge base `12825cb0018a001a058aade4f65cc022f0a9ca6e`

This file supersedes `remediation-inputs.2026-11-07T19-38.md`. It is the re-audit of stage R (PR R) after the cycle 2 design remediation and the cycle 3 merge-conflict remediation. The path is light: one finding, opened by this review, confined to one function of `scripts/dev-tools/ProcessReductionChain.psm1` and its test file, with no spec criterion, README rule, public signature, or file inventory change. The prior cycle (19-38) was proportionate, not light. This file is the light cycle's plan, and no remediation plan target is created.

## Findings requiring remediation

### F1 — The chain does not compare a created file with its create hunk

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The correction compares chain-state text with the stored create hunk that the repository already holds; it needs no owner decision, external system, or CI result.
Finding-Scope: contained

- Files:
  - `scripts/dev-tools/ProcessReductionChain.psm1`, `Invoke-ProcessReductionPatchStep`, the `create` branch (lines 326 to 328).
  - `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1`, `PRC-CHAIN-CREATED-FILE-ENDS-ABSENT` (lines 227 to 244) and one new case.
- Problem:
  - A create hunk sets the path to `$null` without reading it. An unrecorded edit to a created file, or its absence at the entry's turn, passes the chain.
  - Reviewer probes on the real ledger: appending a line to `tests/scripts/codex-hooks/feature-review-coverage-narrowing-parity.Tests.ps1` gives `IsValid` true, and setting it to `$null` gives `IsValid` true. A control edit inside a modify hunk gives 1 error.
  - In either created-file case, `git apply -R` of the `0001` patch fails as a whole. That patch is entry `0001`'s primary record for most of its paths. PR #1113 made such an edit, and only the item's evidence-only git gate caught it.
  - AC R5 and README `## Revert Order` ("the chain test catches it on CI") state that an edit inside a recorded region fails the chain. A create hunk is a recorded region, so R5 was set back to unchecked by this review.
- Required change:
  1. In the `create` branch, before setting the path to `$null`, add the two errors below, then set the path to `$null` and record the touch as now.
     - When `$State[$path]` is `$null`: `"${Name}: ${path}: the file the entry created is absent at this step."`
     - When the chain-state text, with one trailing LF removed, differs from the hunk's `Current` lines joined by LF: `"${Name}: ${path}: the file the entry created differs from its create hunk."`
     - A leading U+FEFF on either side is ignored in the comparison, so a BOM file read by `Get-Content -Raw` matches its hunk.
     - A patch with several hunks for one created path does not occur, because git emits one hunk for a new file. If one is ever met, compare against the hunk that starts at line 1.
  2. In `PRC-CHAIN-CREATED-FILE-ENDS-ABSENT`, make the created file's live text equal its create hunk (`"created`n"`) and keep the assertions: valid, final text absent, and the deleted file restored.
  3. Add `PRC-CHAIN-REPORTS-STALE-CREATED-FILE` with three cases: an edited created file reports the "differs" message; an absent created file reports the "absent" message; and an unchanged created file with no trailing newline (`\ No newline at end of file`) reports no error.
  4. Change no README text, spec criterion, entry, or patch. The README already states the behavior this restores.
- Verification required:
  - The reviewer confirmed that both live created files equal their create hunks at the `0001` turn, so `PRC-LEDGER-CHAIN-HOLDS` and `PRC-LEDGER-SUBCHAIN-HOLDS` are expected to stay green with no ledger edit.
  - Format check and PSScriptAnalyzer with 0 findings on the two changed files.
  - One `Invoke-PoshQCParallelTest` run with 0 failures. `ProcessReductionChain.psm1` keeps 100% line coverage, the new lines included, and no coverage figure drops against the stage R Phase 0 baseline.
  - Re-review, which repeats the created-file probes and checks off R5.

## Non-blocking items carried

- RN5 (Minor): README `## Revert Order` could state that an entry's own record text is not a landing region, and that an edit to it inside a higher entry's hunk is recorded by regenerating that hunk, as the PR #1112 merge did for `0006`. Optional in this cycle; it would add the README to the light cycle's file list, which is within the branch diff.
- RN6 (Minor): the README sentence "A hunk that does not apply is applied by hand" should state that `git apply -R` is all-or-nothing without `--reject`. Optional, as RN5.
- RN7, RN3, RN4, N2, N3 (Nits): in the code review; no action required.

## Light Fix Tasks

- [ ] [P0-T1] `scripts/dev-tools/ProcessReductionChain.psm1`: F1, in the `create` branch of `Invoke-ProcessReductionPatchStep`, report an absent created file and a created file whose chain-state text differs from its create hunk, before setting the path absent.
- [ ] [P0-T2] `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1`: F1, make `PRC-CHAIN-CREATED-FILE-ENDS-ABSENT` use an unedited created file and add `PRC-CHAIN-REPORTS-STALE-CREATED-FILE` for the edited, absent, and unchanged no-trailing-newline cases; then run the gates under F1 "Verification required" and record them under `evidence/qa-gates/`.

## Constraints

- Tests run in parallel only, per `spec.md` `## Testing Rule`: one `Invoke-PoshQCParallelTest` run per gate, re-run only after a fix. No single-process, seeded-shuffle, reversed-order, or comparison runs. No Python file changes, so no pytest gate is owed by this cycle.
- No baseline task, baseline evidence, or baseline comparison is reduced.
- No forced push, no history rewrite, no tag.
- No Epic #1019 folder is edited, and `plan.2026-11-07T12-43.md` (stage G) is not edited.
