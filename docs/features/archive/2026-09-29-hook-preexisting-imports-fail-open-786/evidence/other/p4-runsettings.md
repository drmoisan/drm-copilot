# Runsettings Registration ([P4-T7])

Timestamp: 2026-10-09T23-20

Branch taken: skip branch (CODECOVERAGE_PATH: absent in p0-runsettings-coverage-path.md) - not applicable (RS-2).

Neither scripts/powershell/PoshQC/settings/pester.runsettings.psd1 nor its bundled copy carries a CodeCoverage.Path key; the coverage population is derived from config/poshqc-coverage.json, whose roots include .claude/hooks and .codex/hooks, so both helper copies enter the coverage denominator without a runsettings edit. No runsettings file was written.
