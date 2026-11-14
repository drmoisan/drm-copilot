# Leak Scan (cycle 3, [P3-T3])

Timestamp: 2026-11-14T01-31
Command: sh SCRATCH/issue-1160-c3r3-leak.sh (Import-Module of the branch-current scripts/powershell/PoshQC/PoshQC.psd1, then Invoke-PoshQCLeakScan -Root at the worktree root; git diff --quiet against the remediation start ref for config/poshqc-leak-allowlist.json); sh SCRATCH/issue-1160-c3r3-leak3.sh (module-scope Get-PoshQCLeakFinding over each of the three changed test files, with a control probe)
EXIT_CODE: 0
Output Summary: `Leak scan: 772 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures.` (the scan throws on any failure, so exit 0 confirms none). Per-file findings: Cases file 0, existing commands suite 0, new Modelled suite 0; the control probe (an unrestored environment write) yields 1 finding, so the per-file check is not vacuous. `config/poshqc-leak-allowlist.json` is unchanged against the remediation start ref (git diff --quiet exit 0). The scan printed one configuration warning that the `tests/powershell` scan folder does not exist, which is unrelated to this change.

| File | Findings |
|---|---|
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1 | 0 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Modelled.Tests.ps1 | 0 |
