# PowerShell Format — Final QA Gate (Restart 1)

- Timestamp: 2026-07-18T00-50
- Reason for restart: P4-T3's first attempt showed the two new hook files were absent from the
  `CodeCoverage.Path` allowlist in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
  (an explicit per-file allowlist, not a glob), so no numeric coverage could be reported for them.
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` was edited to add
  `.claude/hooks/enforce-discovery-artifact-gate.ps1` and
  `.claude/hooks/validate-discovery-artifact-gate.ps1` to that allowlist (matching the repo's
  established per-feature convention already present in the same file for prior issues). Per the
  mandatory toolchain-loop rule, the loop restarts from P4-T1 because a file changed.
- Command: `mcp__drm-copilot__run_poshqc_format` (workspace_root=repo root; scan_folders=[".claude/hooks/enforce-discovery-artifact-gate.ps1", ".claude/hooks/validate-discovery-artifact-gate.ps1", "tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1", "tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1", "scripts/powershell/PoshQC/settings/pester.runsettings.psd1"])
- EXIT_CODE: 0
- Output Summary: `{"ok":true,"tool":"run_poshqc_format","summary":"Ran bundled PoshQC format against the workspace with 5 selected scan folder(s)."}`. `git diff --stat` confirms the runsettings file shows only the 5 inserted lines from the manual edit (no additional formatter-driven changes); the four hook/test files were unchanged. No further restart required from this step.
