# AC6 PR CI Record (Issue #931)

Timestamp: 2026-10-16T03-38
Command: gh run download 38845165586 -n poshqc-test-results -D SCRATCH/931/pr-coverage (files pester-junit.xml and powershell-coverage.xml read with the Read and Grep tools)
EXIT_CODE: 0
Output Summary: PR #948 head 0c24f27a8c642c15714b4459927499757c1ee28b, CI run 38845165586, job `poshqc / PowerShell QC` concluded success. Script line coverage 153 of 160 (95.63 percent), at or above the 94.26 percent CI baseline. Full-suite Pester: 10407 tests, 0 errors, 0 failures. ChecksWait 19 of 19 passed; CheckClassification 18 of 18 passed, including `reports unknown for a blank bucket value`.

## S9 procedure result (ac-verification.2026-10-16T01-51.md steps 1 to 6, with the CheckClassification count of 18 from cycle1-verification.2026-10-16T03-08.md)

1. PR `CI` run for the head SHA: run 38845165586. Job `poshqc / PowerShell QC` (windows-latest): SUCCESS.
2. Artifact `poshqc-test-results` downloaded to `SCRATCH/931/pr-coverage`.
3. `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, class-level LINE counter in `powershell-coverage.xml`: missed 7, covered 153, valid 160, percent 95.63.
4. Comparison with the greatest `evidence/baseline/ps-coverage-main.*.md` (main, run 38730332356): baseline 115 of 122, 94.26 percent. 95.63 is at least 94.26: no regression.
5. `pester-junit.xml` root: tests=10407, errors=0, failures=0, disabled=10. Passed testcases whose classname is `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`: 19. Passed testcases whose classname is `Invoke-FullReleaseFlow.CheckClassification.Tests.ps1`: 18.
6. AC6 checked off in `issue.md` in the commit that follows this artifact.

## CI gate on all checks

`gh pr checks 948` and `gh pr view 948 --json statusCheckRollup` at head 0c24f27a8c642c15714b4459927499757c1ee28b: 18 checks, 18 SUCCESS, 0 pending, 0 failing, 0 skipped.
