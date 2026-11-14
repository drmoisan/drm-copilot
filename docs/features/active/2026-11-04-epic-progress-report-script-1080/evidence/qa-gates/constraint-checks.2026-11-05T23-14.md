# Constraint Checks (Issue #1080, P2-T10)

Timestamp: 2026-11-05T23-14
Command: sh SCRATCH/issue-1080-constraints.sh (for each token: git grep -n -F -e <token> -- tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1; then git grep -n -F Get-EpicProgressReport -- extensions/drm-copilot/resources; then git ls-files scripts/dev-tools)
EXIT_CODE: 0

## Test-file token searches (both files are tracked, so git grep reads them)

| Token | Matches |
|---|---|
| TestDrive | 0 |
| New-TemporaryFile | 0 |
| Start-Sleep | 0 |
| Get-Date | 0 |
| ::UtcNow | 0 |
| ::Now | 0 |
| Invoke-WebRequest | 0 |
| Invoke-RestMethod | 0 |

Control: `git grep -c -F -e Invoke-EpicProgressReport -- tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` reports 2 matches, so the search reaches the test files and the zero counts above are not caused by an unreadable path. Write cmdlet names are not searched here; the P1-T8 test lists them as data, and that test proves the production write confinement.

## Bundled resources (AC9)

- `git grep -n -F Get-EpicProgressReport -- extensions/drm-copilot/resources`: 0 matches. No pack manifest or bundled file names the script, so it is not in any push-down pack.
- Control: the same search over `scripts/dev-tools` matches `Get-EpicProgressReport.ps1` (4) and `Get-EpicProgressReport.Logic.ps1` (1).

## dev-tools listing (AC9)

- `git ls-files scripts/dev-tools`: 36 files, 0 `.md` files. No dev-tools documentation page exists; the script's comment-based help is the usage documentation.

## Static proof by named test (P1-T8, `Describe 'Get-EpicProgressReport.ps1 repository constraints'`)

- AC3: `It 'contains no recovered hardcoded value'`
- AC6: `It 'confines native commands to their wrappers'`
- AC8: `It 'confines file writes to Write-EpicProgressState'`
- AC9 (help): `It 'documents every parameter in comment-based help'`, `It 'carries at least one example'`

The P2-T8 and P2-T9 runs report these tests in `Get-EpicProgressReport.Tests.ps1` with failed=0.

Output Summary: 0 matches for each of the eight prohibited tokens in the two new test files (a control search returns matches); 0 matches for the script in the bundled resources (AC9); no .md file under scripts/dev-tools; the P1-T8 constraint tests are the AC3, AC6, and AC8 static proof (AC6, AC9).
