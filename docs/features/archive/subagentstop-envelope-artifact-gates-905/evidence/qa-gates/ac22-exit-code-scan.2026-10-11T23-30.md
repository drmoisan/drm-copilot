# AC-22 exit-code inversion scan (plan [P11-T10], RS-7, issue #905)

Timestamp: 2026-10-11T23-30
Command: Select-String -Path <the seven W-SUITES-CHANGED files> -Pattern '(LASTEXITCODE|ExitCode)\s*\|\s*Should\s+-Be\s+1\b' (and the same pattern over tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1, recorded separately), run through sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-scan.ps1
EXIT_CODE: 0
Output Summary: zero matches over the seven changed suites. The ValidatorDispatch scan has one match, line 49 `$result.ExitCode | Should -Be 1`, inside `It 'returns ExitCode 1 and the module-not-found message when the shared module is absent'`, asserting the `ExitCode` of the `Invoke-DiscoveryValidatorExe` result hashtable (RS-7), not a process exit code. [P11-T1] recorded D1, P1, P9, F1, F9, and F10 passing (`evidence/regression-testing/e3-suites-combined.2026-10-11T23-27.md`). RS-7 is recorded in `evidence/other/deviations.md`.

```text
SCAN: Select-String -Path tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1,tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1,tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1,tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1,tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1,tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1,tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 -Pattern '(LASTEXITCODE|ExitCode)\s*\|\s*Should\s+-Be\s+1\b'
MATCH-COUNT: 0
```

```text
SCAN: Select-String -Path tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 -Pattern '(LASTEXITCODE|ExitCode)\s*\|\s*Should\s+-Be\s+1\b'
MATCH: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1:49: $result.ExitCode | Should -Be 1
MATCH-COUNT: 1
```
