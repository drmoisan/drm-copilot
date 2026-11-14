# Leak Scan (cycle 4, [P3-T3])

Timestamp: 2026-11-14T03-10
Command: sh SCRATCH/issue-1160-c4-leak.sh (imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCLeakScan -Root on the worktree, exit captured without a pipe; then per-file findings through the module-scope Get-PoshQCLeakFinding for the two changed test files with a control probe; then git diff --quiet <remediation start ref> -- config/poshqc-leak-allowlist.json)
EXIT_CODE: 0
Output Summary: Invoke-PoshQCLeakScan exit 0: "Leak scan: 778 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures." (one pre-existing warning that the configured scan folder `tests/powershell` does not exist, skipped). Per-file findings: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` 0, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1` 0; control probe (an unrestored environment write) returns 1 finding, so the per-file check can report a finding. `config/poshqc-leak-allowlist.json` unchanged against the remediation start ref (diff exit 0).
