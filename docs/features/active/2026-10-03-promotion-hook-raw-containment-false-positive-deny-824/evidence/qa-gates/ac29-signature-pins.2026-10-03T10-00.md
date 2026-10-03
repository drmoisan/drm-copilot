# P4-T7 AC-29: public signature pins

Timestamp: 2026-10-03T10-00
Command: pwsh -NoProfile -Command "& 'SCRATCH/issue824-pester.ps1' -Path @('tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1') -JUnitPath 'SCRATCH/s3-p4.junit.xml'; exit `$LASTEXITCODE"; $LASTEXITCODE; PIN-BLOCK-UNCHANGED comparison of the Context 'D12 public parser contract' block (git show 9e8fe7eb576a904ac22cab96faf8c5c12311833e vs worktree, CR removed); JUnit count of passing '*pins the *' testcases
EXIT_CODE: 0
Output Summary:
- S3 run: TOTALS passed=45 failed=0 skipped=0 notrun=0 total=45; child exit 0
- PIN-BLOCK-UNCHANGED=True
- Passing '*pins the *' testcases: 5 (the five pin tests, shifted down by the P1-T3 insertion, passed without edits)
- Top-level EXIT_CODE is the step-script process exit code (the last command is a cmdlet expression), per the STEP-SCRIPT term.
- Result: PASS
