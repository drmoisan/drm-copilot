# Fail-Before: RD2 LASTEXITCODE Testcase Against a Mutated TARGET (P1-T4)

Timestamp: 2026-11-04T01-19
Command: sha256sum TARGET; (delete the `$global:LASTEXITCODE` restore if/else statement from the Describe AfterEach of TARGET); pwsh -NoProfile -File SCRATCH/issue-1066-run-list.ps1 -ListFile SCRATCH/issue-1066-list-guard.txt -OutFile artifacts/pester/issue-1066/guard-alone-lec-mutation.xml -Root <worktree>; (restore TARGET from its saved copy SCRATCH/issue-1066-target-premutation.txt); sha256sum TARGET
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- TARGET SHA-256 before mutation: c73d16b203eaf275e368721be3bd89cd63881a9ad38faf26e09accccb1e07bee
- TARGET SHA-256 after restore: c73d16b203eaf275e368721be3bd89cd63881a9ad38faf26e09accccb1e07bee (equal; `git status --porcelain` lists no change to TARGET)
- Mutation: only the `if ($script:describeHadLastExitCode) { ... } else { Remove-Variable ... }` statement was deleted from the Describe AfterEach; the PATH restore stayed.
- Pester: Total=4 Passed=2 Failed=2 (JUnit RAW/guard-alone-lec-mutation.xml).
- RD2 testcase `run-actionlint.Tests.ps1 leaves global LASTEXITCODE at the value set before it runs`: failed. Message: "Expected 41, because run-actionlint.Tests.ps1 must restore global LASTEXITCODE after each test, but got 0."
- RD2 probe values: control probe 41 (the precondition assertion, which runs first, passed); target probe 0.
- The RD3 testcase also failed (pre-RD1 tree, same entries as P1-T3); the two environment testcases passed.
- Acceptance: EXIT_CODE 1; the RD2 testcase fails with target probe 0, which is not 41; hashes are equal. Met.
