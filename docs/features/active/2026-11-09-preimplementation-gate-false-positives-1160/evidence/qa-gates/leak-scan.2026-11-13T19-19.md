# Leak Scan ([P3-T3])

Timestamp: 2026-11-13T19-06
Command: sh SCRATCH/issue-1160-leak-scan.sh (pwsh 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCLeakScan -Root <worktree>); sh SCRATCH/issue-1160-r4-leak.sh (module-scope Get-PoshQCLeakFinding over the two changed test files); git diff --stat <merge base> HEAD -- config/poshqc-leak-allowlist.json
EXIT_CODE: 0
Output Summary: `Leak scan: 759 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures.` Exit 0. Findings for `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1`: 0; for `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1`: 0. `config/poshqc-leak-allowlist.json` has no diff against the merge base or the remediation start ref (unchanged). The scan configuration warns that the folder `tests/powershell` does not exist and skips it; that folder is absent from the repository and is not part of this change.
