# Final per-file line coverage (plan [P12-T7], AC-25, issue #905)

Timestamp: 2026-10-12T00-10
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-covparse.ps1 -Xml <SCRATCHPAD>/final-powershell-coverage.xml
EXIT_CODE: 0
Output Summary: SHA256 of `<SCRATCHPAD>/final-powershell-coverage.xml` = C76CEB4E2F09054AD3E0A33A00369FCB2877C61A870E49B8203765C503421C58, equal to the [P12-T5] COPY-SHA256 value. Four COVERAGE lines, each with SOURCEFILE_MATCHES: 1: validate-discovery-artifact-gate.ps1 100.00; validate-pr-author-output.ps1 100.00; validate-prd-feature-output.ps1 100.00; validate-task-researcher-output.ps1 98.06. Every value is at least 85.00.

```text
COVERAGE-XML: <SCRATCHPAD>/final-powershell-coverage.xml
COVERAGE: .claude/hooks/validate-discovery-artifact-gate.ps1 | 100.00 | covered=63 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/validate-pr-author-output.ps1 | 100.00 | covered=32 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/validate-prd-feature-output.ps1 | 100.00 | covered=65 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/validate-task-researcher-output.ps1 | 98.06 | covered=101 | missed=2 | SOURCEFILE_MATCHES: 1
```
