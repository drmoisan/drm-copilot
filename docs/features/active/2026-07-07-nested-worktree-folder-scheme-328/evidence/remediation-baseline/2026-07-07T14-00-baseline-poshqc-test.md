# Baseline — PowerShell Full Suite (Pester via PoshQC)

Timestamp: 2026-07-07T13-44
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = repo root; config `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`)
EXIT_CODE: 0

Output Summary:
- Tests: 1071 total, 0 failures, 0 errors, 9 disabled (skipped). Result: PASS.
- Repo-wide JaCoCo LINE coverage headline: covered=1006, missed=68, total=1074 => 93.67%.
- Other report-level counters: INSTRUCTION 92.59% (1399/1511), METHOD 90.10% (91/101), CLASS 100.00% (15/15).
- The changed production file `scripts/dev-tools/new-claude-worktree-session.ps1` is NOT present in the coverage denominator at baseline (grep of `artifacts/pester/powershell-coverage.xml` for `new-claude-worktree-session.ps1` returns no match). This confirms R1: the changed file is outside the committed `CodeCoverage.Path` and is not being measured.
- Artifacts produced: `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`.
