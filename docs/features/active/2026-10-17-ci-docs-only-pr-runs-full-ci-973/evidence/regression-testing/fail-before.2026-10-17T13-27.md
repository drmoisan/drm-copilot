# Fail-Before Run: Phase 1 Regression Tests against Unchanged Production Files (Issue #973)

Timestamp: 2026-10-17T13-27
Command: sh SCRATCH/issue-973-run.sh issue-973-test.ps1 -Root <worktree> -ScanList tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1,tests/scripts/ci/CiChangeScope.Tests.ps1,tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1,tests/scripts/workflows/CiWorkflow.Tests.ps1,tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 (PowerShell 7; Invoke-PoshQCTest, one Pester process), then sh SCRATCH/issue-973-run.sh issue-973-report.ps1
EXIT_CODE: 1
ExpectedExitCode: 1

The Pester process exited with the failed count (48) because the run settings set `Run.Exit`; the gate is recorded as 1 (failure expected). Production files `scripts/ci/CiChangeScope.psm1`, `scripts/ci/Invoke-CiChangeScope.ps1`, `config/ci-docs-only-paths.json`, and `.github/workflows/ci.yml` were unchanged at the time of the run.

Counts from `artifacts/pester/pester-junit.xml` (written 2026-10-17T13-27): 178 test cases, 130 passed, 48 failed, 0 skipped; no container errors.

## Failing tests (48)

`tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1` (20):

- M1 `decides code=false DOCS_ONLY_SINCE_MERGE_BASE with the merge base in the summary when no green run exists and the base ref is main (#973)`; message: expected `code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_` followed by the merge base, but was `code=true reason=NO_FULL_GREEN_RUN` (observed reason `NO_FULL_GREEN_RUN`).
- M2 `decides NON_ALLOWLISTED_PATH on the merge-base diff when one path is outside the allowlist (#973)`
- M3 `decides NON_ALLOWLISTED_PATH on the merge-base diff for a rename into the allowlist (#973)`
- M3 `decides NON_ALLOWLISTED_PATH on the merge-base diff for a rename out of the allowlist (#973)`
- M4 `reaches DOCS_ONLY_SINCE_MERGE_BASE for a Markdown path under docs/features/archive/ with the committed allowlist (#973)`
- M4 `... under docs/features/parallel/ ...`
- M4 `... under docs/features/epics/ ...`
- M5 `decides MERGE_BASE_UNRESOLVED with base none when BASE_SHA is blank (#973)`
- M5 `... when git cat-file exits 128 (#973)`
- M5 `... when git merge-base exits 1 (#973)`
- M5 `... when git merge-base exits 128 (#973)`
- M5 `... when the merge-base output is empty (#973)`
- M5 `... when the merge-base output is not a SHA (#973)`
- M5 `... when the merge-base output holds two SHA lines (#973)`
- M6 `falls back to the merge base when the primary reason is BASE_NOT_PRESENT and the base ref is main (#973)`
- M6 `falls back to the merge base when the primary reason is BASE_NOT_ANCESTOR and the base ref is main (#973)`
- M9 `decides DIFF_FAILED when the merge-base diff exits non-zero (#973)`
- M9 `decides EMPTY_DIFF when the merge-base diff is empty (#973)`
- M10 `passes the unchanged diff flag list with the merge base and the head to git diff (#973)`
- M12 `Get-CiChangeScopeContext reads BASE_SHA and BASE_REF through the injected reader (#973)`

`tests/scripts/ci/CiChangeScope.Tests.ps1` (22):

- `CiChangeScope.psm1 defines only the ten pure functions and calls no git, gh, file, or network command (AC-17)` (renamed module-structure row)
- U1 `Test-CiMergeBaseFallbackApplicable returns <Expected> for <PrimaryReason> with base ref <BaseRef> (#973)`: all 10 data rows (CommandNotFoundException)
- U2 `ConvertFrom-CiMergeBaseOutput returns the SHA for <Case> (#973)`: all 3 data rows
- U3 `ConvertFrom-CiMergeBaseOutput returns an empty string for <Case> (#973)`: all 8 data rows

`tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1` (4):

- `configures exactly the D3 include prefixes and extensions (AC-15)`
- `lists docs/features/archive/ as an include prefix (#973)`
- `lists docs/features/parallel/ as an include prefix (#973)`
- `lists docs/features/epics/ as an include prefix (#973)`

`tests/scripts/workflows/CiWorkflow.Tests.ps1` (1):

- `reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph` (expected 7 allowed event-field lines, found 5)

`tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` (1):

- `passes BASE_SHA and BASE_REF to the scope step of the changes job (#973)`

## Passing rows checked against the plan

M7 (2 rows, `development` and `epic/x`), M8 (2 rows, `RUN_LIST_FAILED` and `JOB_LIST_FAILED`), M11 (4 rows), U4 (3 rows), U5 (2 rows), and every pre-existing row of the five suites pass.

Output Summary: 130 passed, 48 failed. The failing set is exactly M1 to M6, M9, M10, M12, the renamed module-structure row, U1 to U3, the exact-string config row, the three include-prefix rows, the CiWorkflow event-field row, and the new env-line row; M7, M8, M11, U4, U5, and all pre-existing rows pass; M1 shows the observed reason `NO_FULL_GREEN_RUN`. After the run, the `-Because` text of the CiWorkflow event-field row was updated to name issue #973; the row's assertions are unchanged.
