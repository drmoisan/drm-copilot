# Baseline — Targeted Pester Coverage for enforce-evidence-locations.ps1 (Issue #227)

Timestamp: 2026-06-24T13-55

Command: Scoped Pester run (New-PesterConfiguration) over tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 with CodeCoverage.OutputFormat='JaCoCo' and CodeCoverage.Path scoped to the root hook (.claude/hooks/enforce-evidence-locations.ps1) and the Claude mirror (extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1). Run via Pester 5.6.1.

Note on scope: the bundled mcp__drm-copilot__run_poshqc_test coverage scope
(scripts/powershell/PoshQC/settings/pester.runsettings.psd1) does NOT instrument
enforce-evidence-locations.ps1. A scoped New-PesterConfiguration run is therefore
required to obtain per-file numeric line coverage for this hook. Pester's coverage
engine emits LINE/INSTRUCTION counters only; JaCoCo BRANCH counters are not produced
for PowerShell, so branch coverage is unavailable and only line coverage is reported.

EXIT_CODE: 0

Output Summary:
- Pester result: TotalCount=10, Passed=10, Failed=0, Skipped=0. Suite is green.
- Baseline LINE coverage for .claude/hooks/enforce-evidence-locations.ps1:
  covered=22, missed=5, total=27 => 81.48% (matches plan-stated 81.5%, 22/27).
- Uncovered (missed) lines: 146, 148, 149, 152, 154 — the entry-point dispatch
  block (try/catch around Invoke-EvidenceLocationDecision; Write-Error/exit 1;
  ConvertTo-Json/Write-Output; exit 0). These are unreachable from dot-sourced
  unit tests because the dot-source guard returns before the dispatch tail.
- Branch coverage: not produced by Pester for PowerShell (line coverage only).
- The Claude mirror shows 0% in the same run because the test dot-sources only the
  root path; the mirror's coverage is validated indirectly through byte-equality
  with the root file (P3-T5).

Baseline determination: 81.48% line coverage, below the uniform 85% threshold —
this is Finding 1, the blocking shortfall this remediation resolves.
