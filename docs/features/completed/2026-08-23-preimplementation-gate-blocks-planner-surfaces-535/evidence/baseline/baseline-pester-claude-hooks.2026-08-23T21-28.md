# Baseline Pester (Claude hook suite) — issue #535

Timestamp: 2026-08-23T21-28

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-23T20-24` and
`scan_folders=["tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1"]`

Coverage instrumentation is supplied by the standing `CodeCoverage.Path` allow-list in
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, which already registers
`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (line 198) and
`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (line 131). The MCP test
tool exposes no per-invocation coverage parameter.

EXIT_CODE: 0

Output Summary:

- Result: pass. `{"ok":true,"tool":"run_poshqc_test", ... "with 1 selected scan folder(s)."}`
- Test counts from `artifacts/pester/pester-junit.xml`: tests=24, failures=0, errors=0,
  disabled=0, time=1.198s.
- Baseline line coverage for `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`,
  extracted from the per-file `LINE` counter in the runner-generated CoverageGutters/JaCoCo
  artifact `artifacts/pester/powershell-coverage.xml` (not from the aggregate console
  summary): covered=76, missed=10, total=86 -> **88.37%** line coverage.
- Command (instruction) coverage for the same file, reported for information only with no
  threshold attached: covered=86, missed=15, total=101 -> 85.15%.
- The `.codex` copy shows 0 covered lines in this scoped run because the codex suite was
  not selected; it is measured separately in P0-T9.
