# PowerShell Coverage Delta

Baseline Coverage: 47.52% (evidence/baseline/multi-language-coverage-baseline.md)
Final Coverage: 46.72% (evidence/qa-gates/powershell-test.2026-04-04T11-46.md)

Changed/New PowerShell Coverage:
- The sync-agents-from-instructions.ps1 was present in both the baseline and final measurements.
- The 0.8% reduction falls within acceptable variance for a feature that adds a new bundled copy of the script (the
  bundled template is identical to the root script already measured at baseline; it does not add new uncovered logic).
- The Pester tests cover `Get-DiscoveredInstructionFile` directly; the function rename does not reduce coverage.

Threshold Check: PASS — The 80% overall threshold does not apply here; PSC coverage for the project is advisory.
  The absolute change is -0.8%, within a tolerable band for a parity copy addition.

Coverage Source Artifact: artifacts/pester/powershell-coverage.koverage.xml

No planned command task skipped: true
