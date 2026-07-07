# Baseline — PoshQC Test + Coverage

Timestamp: 2026-07-07T12-24
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = repo root, full suite, repo pester.runsettings.psd1)
EXIT_CODE: 0

Output Summary:
- Tests: 1063 total, 0 failures, 0 errors, 9 disabled (JUnit: artifacts/pester/pester-junit.xml, time 44.045s).
- Line coverage (JaCoCo/koverage report totals): covered=1006, missed=68, total=1074 => 93.67% line.
- Instruction coverage: covered=1399, missed=112 => 92.59%.
- Branch coverage: NOT EMITTED by the repo Pester config (OutputFormat = CoverageGutters produces no BRANCH counters; 0 BRANCH entries in report).
- Coverage scope note (finding): the repo pester.runsettings.psd1 CodeCoverage.Path is an explicit allow-list of specific .claude/hooks and scripts release files. It does NOT include scripts/dev-tools/new-claude-worktree-session.ps1, so the file changed by this feature is outside the configured PowerShell coverage measurement scope. This is a pre-existing repo configuration; not modified by this plan (see final findings).
