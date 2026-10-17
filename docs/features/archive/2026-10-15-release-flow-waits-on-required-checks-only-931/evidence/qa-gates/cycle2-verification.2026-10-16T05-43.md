# Cycle 2 Verification and Handoff (Issue #931)

Timestamp: 2026-10-16T05-43
Command: consolidation of the cycle 2 Phase 1 and Phase 2 artifacts named below (no new command)
EXIT_CODE: 0
Output Summary: F1, F2, F3, and F4 resolved. Local scoped tests 655 -> 665, 0 failures, 0 errors. SCRIPT_PERCENT 94.93 (131/138). HELPER_PERCENT not measured locally (measured in PR CI only). COMBINED_PERCENT not computed. AC1 to AC6 remain checked. S9 instruction below replaces the counts of `ac6-pr-ci-record.2026-10-16T03-38.md` step 5.

## Findings

| Finding | Status | Tasks | Artifacts |
|---|---|---|---|
| F1 (wrapper output type declared as hashtable) | Resolved | P1-T4, P1-T10, P1-T14 | `evidence/regression-testing/cycle2-pester-junit-after.2026-10-16T05-24.md` |
| F2 (Phase A retried every non-zero gh poll) | Resolved | P1-T5, P1-T6, P1-T8, P1-T9, P1-T14 | `evidence/baseline/cycle2-gh-observation.2026-10-16T05-12.md`, `evidence/regression-testing/cycle2-pester-junit-after.2026-10-16T05-24.md` |
| F3 (main script one line under the 500-line cap) | Resolved | P1-T2, P1-T3, P1-T7, P1-T11, P1-T12, P2-T4 | `evidence/regression-testing/cycle2-structure.2026-10-16T05-22.md`, `evidence/regression-testing/cycle2-reference-search.2026-10-16T05-22.md`, `evidence/qa-gates/cycle2-local-results-final.2026-10-16T05-41.md` |
| F4 (unreachable null guard in Get-CheckSetVerdict) | Resolved | P1-T2, P1-T11, P2-T4 | `evidence/regression-testing/cycle2-structure.2026-10-16T05-22.md` |

## Baseline and final values (from `cycle2-local-results-final.2026-10-16T05-41.md`)

| Value | Baseline | Final |
|---|---|---|
| Tests (scoped, tests/scripts/dev-tools) | 655 | 665 |
| Failures / errors | 0 / 0 | 0 / 0 |
| SCRIPT_PERCENT (Invoke-FullReleaseFlow.ps1) | 95.63 (153/160, missed 7) | 94.93 (131/138, missed 7) |
| HELPER_PERCENT (Invoke-FullReleaseFlow.CheckHelpers.ps1) | n/a (file did not exist) | not measured locally |
| COMBINED_PERCENT | 95.63 | not computed |

HELPER_COVERAGE: measured in PR CI only. The local MCP runner uses the installed extension's coverage allow-list, which does not name the helper file; the direct in-repo PoshQC invocation was rejected by a PreToolUse hook (false `PR_AUTHOR_SKILL_BLOCKED`). See the approved amendment under P2-T4.

AC1 to AC6 remain checked; no criterion was added.

## S9 instruction for the new PR head

This replaces the counts in `evidence/qa-gates/ac6-pr-ci-record.2026-10-16T03-38.md` step 5. In the `poshqc-test-results` artifact of the PR CI job `poshqc / PowerShell QC` (`windows-latest`) for the new head:

1. Passed testcases with classname `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` equal 23 (19 existing plus 4 added by P1-T9).
2. Passed testcases with classname `Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1` equal 22 (22 CheckHelpers tests: 18 moved plus 4 added by P1-T8).
3. No testcase has classname `Invoke-FullReleaseFlow.CheckClassification.Tests.ps1`.
4. The per-file line percentage of `Invoke-FullReleaseFlow.ps1` is at least 94.26.
5. The `Invoke-FullReleaseFlow.CheckHelpers.ps1` class is present.
6. HELPER_COVERAGE is measured in PR CI only: at S9 the poshqc-test-results coverage report of the job poshqc / PowerShell QC must contain the Invoke-FullReleaseFlow.CheckHelpers.ps1 class with a line percentage of at least 94.26 and 0 missed lines; if the class is absent or below that floor, S9 is not green and the item returns to remediation. (Approved amendment; supersedes the 85 percent helper figure in the original P2-T9 text.)

## Unchanged earlier artifact

`git diff --name-only 7051d8a8d -- docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/evidence/qa-gates/ac6-pr-ci-record.2026-10-16T03-38.md` printed nothing (exit 0), and `git status --porcelain` lists no entry for that path (`cycle2-scope.2026-10-16T05-43.md`).
