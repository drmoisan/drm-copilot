# Baseline — Pester with coverage (repo module), issue #491

Timestamp: 2026-08-19T10-23

Command: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root (Get-Location).Path"`

This is the repo-module run, NOT `mcp__drm-copilot__run_poshqc_test`. The MCP-published PoshQC
resolves `settings/pester.runsettings.psd1` relative to its own bundled module root and does not
consume the repo copy, so repo-level `CodeCoverage.Path` registration is inert under the MCP path.
Every coverage figure in this feature's evidence therefore comes only from this command.

EXIT_CODE: 0

Output Summary:

- Tests Passed: 2786, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0. Duration 149.32s.
- Pester command-coverage headline (printed by the runner): `Covered 95.83% / 0%. 7,555 analyzed
  Commands in 65 Files.` The `/ 0%` term is the branch figure, which Pester does not measure.
- Baseline LINE coverage, computed per the plan's Coverage extraction method
  (`covered / (covered + missed)` summed over `<counter type="LINE">` per `<class sourcefilename=>`)
  from `artifacts/pester/powershell-coverage.xml`:
  - **OVERALL LINE COVERAGE: 95.97%** (5168 covered, 217 missed, 5385 total lines).
  - Distinct `sourcefilename` values: 59.
- `<class sourcefilename=` element count in the preserved report: 65 (some source files contribute
  more than one `<class>` element, which is why the distinct-file count is 59).
- Preserved baseline report copy:
  `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/evidence/baseline/powershell-coverage.baseline.2026-08-19T10-23.xml`
  Copied before any later run could overwrite `artifacts/pester/powershell-coverage.xml`
  (the runsettings uses one fixed `OutputPath` and `artifacts/` is gitignored, so this copy is the
  only recoverable baseline for the P7-T5 per-file comparison).
