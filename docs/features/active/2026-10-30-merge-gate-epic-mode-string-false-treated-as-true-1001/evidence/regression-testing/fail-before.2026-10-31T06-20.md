# Fail-Before: Strict epic_mode Suites Against the Unfixed Hooks (issue #1001)

Timestamp: 2026-10-31T06-20
Command: sh SCRATCH/issue-1001-run.sh SCRATCH/issue-1001-pester.ps1 -Pattern EpicModeStrict -Tag fail-before (single-process Invoke-Pester over the three tests/scripts/claude-hooks/*.EpicModeStrict.Tests.ps1 files, JUnit written to artifacts/pester/pester-junit.xml)
EXIT_CODE: 11
ExpectedExitCode: 11

Files run (order):

1. `tests/scripts/claude-hooks/enforce-epic-merge-gate.EpicModeStrict.Tests.ps1`
2. `tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicModeStrict.Tests.ps1`
3. `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.EpicModeStrict.Tests.ps1`

Output Summary (read from artifacts/pester/pester-junit.xml): tests=31, failures=11, errors=0, skipped=0, suites=3. The exit code is the failing-row count and is not the pass/fail signal; the failing rows below are read from the JUnit file.

Failing rows (11), each the expected loose-coercion outcome:

| Suite | Row | Observed |
|---|---|---|
| merge gate | `Test-ChildCheckpointAllowsEpicMerge` returns False when epic_mode is string false | got `$true` |
| merge gate | `Test-ChildCheckpointAllowsEpicMerge` returns False when epic_mode is string true | got `$true` |
| merge gate | `Test-ChildCheckpointAllowsEpicMerge` returns False when epic_mode is integer 1 | got `$true` |
| merge gate | decision returns deny for gh pr merge 42 --merge when epic_mode is string false | got `allow` |
| merge gate | decision returns deny for gh pr merge 42 --merge when epic_mode is string true | got `allow` |
| merge gate | denies an otherwise green standalone checkpoint whose epic_mode is the string false without a live-head lookup | got `allow` (branch 1) |
| model routing | returns AUTHOR_ASSERTED_AUTOCLOSE_MISSING when epic_mode is string true | got `$null` |
| model routing | returns AUTHOR_ASSERTED_AUTOCLOSE_MISSING when epic_mode is integer 1 | got `$null` |
| base branch | returns null when epic_mode is string false | got `EPIC_BASE_BRANCH_MISMATCH` |
| base branch | returns null when epic_mode is string true | got `EPIC_BASE_BRANCH_MISMATCH` |
| base branch | returns null when epic_mode is integer 1 | got `EPIC_BASE_BRANCH_MISMATCH` |

Passing rows (20): the three probe rows; merge-gate unit rows JSON true, JSON false, JSON null, absent, integer 0; merge-gate decision row JSON true (allow); model-routing rows JSON true, JSON false, JSON null, absent, string false, integer 0; base-branch rows JSON true, JSON false, JSON null, absent, integer 0.

Result: the failing set equals the set stated in [P1-T4] exactly; no other row fails, so no suite defect was found.
