# Global-State Pass-After over TARGET and GUARD (P2-T4, remediation cycle 1)

Timestamp: 2026-11-04T01-20
Command: pwsh -NoProfile -File SCRATCH/issue-1066-global-state.ps1 -TestFile tests/scripts/dev-tools/run-actionlint.Tests.ps1; pwsh -NoProfile -File SCRATCH/issue-1066-global-state.ps1 -TestFile tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1
EXIT_CODE: 0
Output Summary:
- Supersedes APPROVED P2-T4 and the failing result in global-state-pass-after.2026-11-04T00-58.md.
- TARGET run: EXIT_CODE 0; nested Total=35 Failed=0. Control delta (1): `LASTEXITCODE after exists=True value=0`. Target delta (1): the same entry. Difference: 0 entries.
- GUARD run: EXIT_CODE 0; nested Total=4 Failed=0. Control delta (1) and target delta (1) are the same LASTEXITCODE entry. Difference: 0 entries.
- The three entries of the cycle-entry failure (`FUNCTION added Compress-Archive`, `FUNCTION added Expand-Archive`, `FUNCTION added Import-ScriptFunction`) are gone after RD1.
- Categories compared: environment, location, aliases, functions, global variables, and `$global:LASTEXITCODE`. The LASTEXITCODE entry is set by the nested harness itself (control delta) and cancels; the DD1 LASTEXITCODE restore is proven by the RD2 testcase (P1-T4, P2-T3), not by this tool.
- Acceptance: EXIT_CODE 0 for both runs and both printed differences are empty. Met.
