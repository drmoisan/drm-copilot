# R2 Fail-Before — PoshQC Module Absent from Pester Coverage Denominator

- Issue: #344
- Timestamp: 2026-07-10T20-46
- Command: `pwsh -NoLogo -NoProfile -Command "[xml]$x = Get-Content artifacts/pester/powershell-coverage.xml; $x.SelectNodes('//sourcefile') | ForEach-Object { $_.name }"` and a follow-up count query filtering names matching `PoshQC*`
- EXIT_CODE: 0

## Output Summary

The pre-remediation Pester coverage report (`artifacts/pester/powershell-coverage.xml`, LastWriteTime `2026-07-10T19:38:10.5163536-04:00`) contains 16 `sourcefile` entries. None match `PoshQC*.psm1`. `PoshQCMatches=0`.

Sourcefile names present in the coverage denominator:

```
check-powershell-test-purity.ps1
check-python-test-purity.ps1
enforce-epic-merge-gate.ps1
enforce-epic-wave-barrier.ps1
enforce-epic-worktree-removal-gate.ps1
enforce-powershell-batch-budget.ps1
enforce-pr-author-skill.epic-base-branch.ps1
enforce-pr-author-skill.ps1
enforce-python-batch-budget.ps1
persist-session-id.ps1
validate-bash.ps1
validate-orchestrator-output.ps1
Invoke-FullRelease.ps1
Invoke-MarketplacePublish.ps1
Invoke-ReleaseTagPush.ps1
Publish-DrmCopilotExtension.ps1
```

No `PoshQC.ScanConfig.psm1` (or any other `PoshQC*.psm1`) entry is present. This demonstrates the R2 fail-before state: the module is outside the coverage denominator because `PoshQC.psm1` loads sub-modules via fileless `[scriptblock]::Create((Get-Content ... -Raw))`, so Pester breakpoints never bind.
