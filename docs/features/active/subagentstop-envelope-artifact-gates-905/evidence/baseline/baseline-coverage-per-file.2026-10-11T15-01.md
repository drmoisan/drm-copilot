# Baseline per-file line coverage ([P0-T25], issue #905)

Timestamp: 2026-10-11T15-01
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-covparse.ps1 artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: .claude/hooks/validate-discovery-artifact-gate.ps1 92.65% (63/68); .claude/hooks/validate-pr-author-output.ps1 100.00% (39/39); .claude/hooks/validate-prd-feature-output.ps1 98.15% (53/54); .claude/hooks/validate-task-researcher-output.ps1 90.00% (90/100, refreshed value; spec line 329). Each line SOURCEFILE_MATCHES: 1.

```text
COVERAGE-XML: artifacts/pester/powershell-coverage.xml
COVERAGE: .claude/hooks/validate-discovery-artifact-gate.ps1 | 92.65 | covered=63 | missed=5 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/validate-pr-author-output.ps1 | 100.00 | covered=39 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/validate-prd-feature-output.ps1 | 98.15 | covered=53 | missed=1 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/validate-task-researcher-output.ps1 | 90.00 | covered=90 | missed=10 | SOURCEFILE_MATCHES: 1
```
