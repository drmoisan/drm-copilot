# Code Review: Stage R Re-audit after the Light Cycle, Revertible Ledger Chain (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `1d1ce4c3e67056c30d381d47bf9e3a922342d9ba`
- **Base:** `main`, merge base `12825cb0018a001a058aade4f65cc022f0a9ca6e` (equal to `origin/main`); trial merge clean
- **Scope:** full branch diff, 52 files, 54 commits (one merge); the light cycle added `4ef2e1f4f` and `1d1ce4c3e`
- **Reviewer:** feature-review agent, 2026-11-07

## Executive Summary

This re-audit judges the light cycle opened by `remediation-inputs.2026-11-07T20-50.md` (F1) and re-checks the whole branch.

- **F1 is resolved as specified.**
  - The `create` branch of `Invoke-ProcessReductionPatchStep` (lines 326 to 340) reports an absent created file and a created file whose chain-state text differs from its create hunk. It then sets the path absent and records the touch, as before.
  - The comparison follows the inputs: LF normalization, a leading U+FEFF ignored on both sides, and one trailing LF removed from the chain-state text.
  - `PRC-CHAIN-CREATED-FILE-ENDS-ABSENT` no longer pins an edited created file as valid. `PRC-CHAIN-REPORTS-STALE-CREATED-FILE` covers four cases: edited, absent, unchanged without a trailing newline, and unchanged with BOM and CRLF.
- **Real-ledger probes now fail as R5 requires.** Appending a line to, deleting, or editing the first line of either `0001`-created file gives `IsValid` false with the `0001` error. For `parallel-gate-wording.Tests.ps1`, which `0006` later modifies, the check runs on the chain state after `0006` is reverted, so an edit outside `0006`'s hunks is still caught at `0001`'s turn. The unchanged ledger stays valid, and a modify-hunk control still fails.
- **One new non-blocking note (RN8).** A change limited to the end-of-file newline is not seen by the chain, while `git apply -R` of the stored patch would reject it. This is how the whole chain compares text, not a defect of this fix.
- **Toolchain.** The reviewer re-checked format and analyzer: 0 findings on the three PowerShell files. The cycle 4 parallel Pester gate reports 16049 tests, 0 failed. `ProcessReductionChain.psm1` is at 100% line coverage (238 of 238), and repo-wide PowerShell coverage is 94.16%.

No blocking finding remains.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `scripts/dev-tools/ProcessReductionChain.psm1`; `docs/engineering/process-reductions/README.md` | `Invoke-ProcessReductionPatchStep` create branch, lines 332 to 334; `Get-ProcessReductionPatchHunk` line 53; README `## Revert Order` | RN8. The chain does not detect a change limited to the end-of-file newline. Removing the final newline from either `0001`-created file gives `IsValid` true. In a scratch repository, `git apply -R --check` of a create patch exits 1 once the file loses its final newline. The parser skips every `\ No newline at end of file` marker, and modify hunks are compared as split lines, so the same holds for modify hunks. The inputs prescribed the trailing-LF removal for create hunks. | Optional: state in README `## Revert Order` that the chain compares lines and not the end-of-file newline, so a newline-only change can still make `git apply -R` refuse the patch, and the hand-applied route then applies. Comparing the marker exactly would need a design decision for every hunk kind and is not recommended in this PR. | Non-blocking. R5 concerns edits to regions of lines, and editors and formatters keep final newlines in this repository. The README sentence would keep a months-later reader from being surprised by a refused `git apply -R`. | Reviewer probes (policy audit, Executive Summary table); scratch-repository `git apply -R --check` exits 0 (unchanged), 1 (newline removed), 0 (CRLF). |
| Minor | `docs/engineering/process-reductions/README.md` | `## Revert Order`, second paragraph | RN5 (carried). The rule "a later landing may not edit a region that a higher-numbered entry records" says nothing about the landing's own update to its entry text. That update can fall inside a higher entry's hunk on the entry file, as the PR #1112 merge showed for `0006`. | Add one sentence: an entry's own record text is not a landing region, and an edit to it inside a higher entry's hunk is recorded by regenerating that hunk. | Non-blocking; the ledger is correct and the chain holds. | Prior review; `0006` patch history. |
| Minor | `docs/engineering/process-reductions/README.md` | `## Revert Order`, fourth paragraph | RN6 (carried). "A hunk that does not apply is applied by hand" reads as if `git apply -R` applied the rest. Without `--reject`, it applies nothing when any hunk fails. | State `git apply -R --reject`, or state that the check is all-or-nothing. | Non-blocking. The behavior is discoverable, but the README should state it. | `git apply` behavior; README text. |
| Nit | `docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch` | Hunk on `0001-parallel-only-test-gates.md` `## Revert Steps` | RN7 (carried). The stage R pointer to README `## Revert Order` lives only in the `0006` post-image, so reverting `0006` alone removes it from `0001` step 1. | None required. | Consistent with the README rule; the README still governs. | `0006` patch hunk. |
| Nit | `scripts/dev-tools/ProcessReductionChain.psm1` | `Get-ProcessReductionDerivedSource` | RN3 (carried). Returns the first mapping hop, not the final source. | State it in the help text, or resolve transitively. | Documentation precision. | Prior review. |
| Nit | `scripts/dev-tools/ProcessReductionChain.psm1` | Derived-path decision | RN4 (carried). Derivation is decided from live text only, so a broken mirror reports as hunk failures on copies. | None required. | Diagnostic clarity. | Prior review. |
| Nit | `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` | Header block | N3 (carried). `Last Updated` and `Version` are unchanged after the stage R edits. | Update with the next spec edit. | Record only. | `spec.md` header. |
| Nit | `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py` | Threaded reader arc | N2 (carried). A timing-dependent branch, not in this branch diff. | For the owner, as before. | Record only. | Prior review. |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies. The largest changed covered file is `scripts/dev-tools/ProcessReductionChain.psm1` at 584 logical lines; the test file is 519. `config/file-size-baseline.json` is not in the branch diff.

## Detailed Review

### The created-file check (F1 fix)

- Placement: the check runs inside the per-path group before the path is set to `$null`. Earlier steps of the chain have already reverted later entries, so it compares the created file as it stood at the entry's turn. This is the correct state to compare. The `parallel-gate-wording.Tests.ps1` probes confirm it: `0006` modifies that file, and the `0001` check still sees an edit outside `0006`'s hunks.
- Normalization: `ConvertTo-ProcessReductionChainLf` handles CRLF; `TrimStart([char]0xFEFF)` on both sides handles a BOM read by `Get-Content -Raw`; one trailing LF is removed from the chain state, matching how the hunk's `Current` lines join without a final terminator. An appended blank line is still detected, because only one LF is removed.
- Absent file: reported once at `0001`'s turn when nothing later touched the file. When a later entry modifies the file, that entry reports it first (seven errors for `parallel-gate-wording.Tests.ps1`), and the `0001` absent message follows. Both name the cause.
- Several hunks for one created path: each would be compared with the whole file and report. Git emits one hunk for a new file, as the inputs note, so no defect follows.
- Empty created file: git writes no hunk for an empty new file, so the parser produces no create item and the chain does not track the path. Neither stored patch contains such a section. This is a pre-existing parser property, recorded here for completeness and not raised as a finding.

### Tests

- The edited and absent cases assert the exact error list, so removing either error branch fails them. The BOM-with-CRLF case fails if the BOM trim or LF normalization is removed. The no-newline case fails if the comparison requires a trailing LF, for example if an LF were appended to the hunk text instead of removed from the chain state.
- `PRC-CHAIN-CREATED-FILE-ENDS-ABSENT` keeps its end-state assertions with an unedited created file and still restores the deleted file.

### Security and correctness

- No secret, no command construction, no network. The module writes nothing.

## Verification Performed

- `git -C <worktree> fetch`, merge-base check, `log` and `diff` over `2195ec4e..HEAD` and `12825cb00..HEAD`.
- In-memory chain at head; created-file probes (append, delete, first-line edit, blank line, final newline removed) on both created files; a modify-hunk control.
- Scratch-repository `git apply -R --check` of a create patch against unchanged, newline-stripped, and CRLF copies.
- `Invoke-Formatter` and `Invoke-ScriptAnalyzer` on the three changed PowerShell files: formatted, 0 findings.
- One `Invoke-PoshQCParallelTest` run at this head, to replace a coverage file written 35 seconds before the head commit: exit code 0, 16049 tests, 0 failed, figures equal to the executor's run.
- Coverage XML parsing; logical line counts; `validate_evidence_locations` exit 0; `git merge-tree` exit 0; `gh run view 42414817399` (in progress on this head).

## PR Readiness

**Ready to merge once CI is green.** No blocking finding. CI run 42414817399 on this head is read by the orchestrator at S9. RN5, RN6, and RN8 are optional README sentences.
