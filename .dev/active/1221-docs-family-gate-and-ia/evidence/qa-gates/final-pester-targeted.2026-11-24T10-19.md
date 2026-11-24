# Final QC - Targeted Pester Union (remediation cycle 1)

Plan: remediation-plan.2026-11-24T08-32.md
Task: [P1-T7]
Timestamp: 2026-11-24T10-19
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-lib/docs tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1 tests/scripts/harness/HarnessInventory.Tests.ps1 tests/scripts/claude-hooks/docs-estate-workflow.EndToEnd.Tests.ps1 tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 (absolute launcher path in the item worktree, run through the retry wrapper SCRATCH/issue-1221-retry.sh)
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCParallelTest: workers=8; wall-clock=326.32s; exit code=0; merged JUnit and coverage written.
- Pass/fail (artifacts/pester/pester-junit.xml): 2851 tests, 2851 passed, 0 failed, 0 errors, 0 skipped, 134 test suites.
- Comparison with the baseline (evidence/remediation-baseline/pester-targeted.2026-11-24T09-15.md: 2845 tests, 0 failed): no new failing test; every baseline test case is present in this run; six cases are new (listed below).
- Line coverage (artifacts/pester/powershell-coverage.xml), baseline -> final:
  - .claude/lib/docs/DocsFamilyCheck.psm1: 100.00% (95/95) -> 100.00% (100/100); at or above 85%, no drop.
  - .claude/lib/docs/Invoke-DocsCommand.ps1: 90.91% (190/209) -> 91.08% (194/213); at or above 85%, no drop; the 19 missed lines are unchanged pre-existing lines.
  - Repo-wide figure of this targeted run: 26.07% (baseline 26.06%); not comparable with a full run, because the coverage population is the whole configured set while only the targeted union ran.
- New and changed-code coverage: every changed executable line is covered (9 of 9, 100%).
- Queue timeouts (exit 75, machine test-suite lock busy; re-run after the holder finished): 2026-11-24T10-08 (holder pid 10688), 2026-11-24T10-11 (holder pid 27304). The third attempt, started 2026-11-24T10-13, produced this result.

Owner waiver: this run is the targeted union, not the full suite, under the owner instruction dated 2026-11-23: "The full test suite for any destination repo should only be run at the beginning of the orchestration and in the qc run. everything else should be targeted tests."

## Changed-line map

| File and changed line | Hits (JaCoCo ci) | Test that executes it |
|---|---|---|
| DocsFamilyCheck.psm1 `if ($rootFile.ContainsValue($true))` | 1 | `Read-DocsFamilyEvidence root-file name case` > all four cases (true branch: the first three; false branch: `makes no root listing when both root probes are negative`) |
| DocsFamilyCheck.psm1 `$rootListing = & $ListFile ''` | 1 | `accepts the exact root names from a case-insensitive TestFile after one root listing`; `probes SECURITY.md and CODEOWNERS at the repository root only when a security entry exists` |
| DocsFamilyCheck.psm1 ordinal `HashSet[string]` construction | 1 | same as above |
| DocsFamilyCheck.psm1 `foreach ($entry in @($rootListing))` | 4 | `does not accept a wrong-case root security.md or codeowners from a case-insensitive TestFile` |
| DocsFamilyCheck.psm1 `RootFile[name]` = probe and set membership | 2 | `reports DOCS_FAMILY_ROOT_FILE_MISSING for a wrong-case root CODEOWNERS beside an exact SECURITY.md` |
| Invoke-DocsCommand.ps1 `if ([string]::IsNullOrEmpty($RelativeRoot))` in `Get-DocsContextFileList` | 1 | `lists only the top-level repository-root files for the empty relative root` (true branch); `tests existence and lists files sorted` (false branch) |
| Invoke-DocsCommand.ps1 `EnumerateFiles(... TopDirectoryOnly)` | 4 | `lists only the top-level repository-root files for the empty relative root` |
| Invoke-DocsCommand.ps1 ordinal `[Array]::Sort` | 1 | same |
| Invoke-DocsCommand.ps1 `return , $names` | 1 | same |
| tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1 empty-root `ListFile` branch (test support; outside the coverage population) | n/a | `New-DocsLedgerTestContext` > `lists only the top-level files for the empty relative root` |

New test cases in this run: `New-DocsLedgerTestContext.lists only the top-level files for the empty relative root`; the four `Read-DocsFamilyEvidence root-file name case` cases; `New-DocsCommandContext (read-only against committed files).lists only the top-level repository-root files for the empty relative root`.

Saved copies: SCRATCH/issue-1221-final-junit.xml and SCRATCH/issue-1221-final-coverage.xml.
