# Coverage Delta ([P7-T7])

Timestamp: 2026-10-12T04-20
Command: sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/changed-line-coverage.ps1 -ReportPath <SCRATCHPAD>/final-coverage-report.txt -BaseRef origin/epic/subagentstop-envelope-integration -Path .claude/hooks/validate-orchestrator-output.ps1,.claude/hooks/validate-orchestrator-output-routing.ps1,.claude/hooks/validate-orchestrator-output-resolution.ps1,.claude/hooks/validate-executor-output.ps1,.claude/hooks/validate-planner-output.ps1,.claude/hooks/validate-required-artifact-output.ps1
EXIT_CODE: 0
Output Summary: six rows, all Result: PASS. Post-change line coverage 98.32 to 100 per file; changed-line coverage 100 on every file. Baseline from evidence/baseline/pester-coverage.2026-10-12T00-02.md; post-change from evidence/qa-gates/pester-coverage.2026-10-12T04-14.md.

| File | Baseline LinePercent | Post-change LinePercent | Threshold | ChangedLinePercent | Result |
|---|---|---|---|---|---|
| .claude/hooks/validate-orchestrator-output.ps1 | 95.42 | 99.09 | 85 | 100 | Result: PASS |
| .claude/hooks/validate-orchestrator-output-routing.ps1 | NEW FILE | 100 | 85 | 100 | Result: PASS |
| .claude/hooks/validate-orchestrator-output-resolution.ps1 | 98.94 | 98.94 | 85 | 100 | Result: PASS |
| .claude/hooks/validate-executor-output.ps1 | 69.91 | 98.32 | 85 | 100 | Result: PASS |
| .claude/hooks/validate-planner-output.ps1 | 97.94 | 99.5 | 85 | 100 | Result: PASS |
| .claude/hooks/validate-required-artifact-output.ps1 | 69.81 | 98.36 | 85 | 100 | Result: PASS |

A9 output:
CHANGED-COVERAGE file=.claude/hooks/validate-orchestrator-output.ps1 AddedLines=76 ChangedExecutable=39 ChangedHit=39 ChangedLinePercent=100
CHANGED-COVERAGE file=.claude/hooks/validate-orchestrator-output-routing.ps1 AddedLines=170 ChangedExecutable=28 ChangedHit=28 ChangedLinePercent=100
CHANGED-COVERAGE file=.claude/hooks/validate-orchestrator-output-resolution.ps1 AddedLines=8 ChangedExecutable=5 ChangedHit=5 ChangedLinePercent=100
CHANGED-COVERAGE file=.claude/hooks/validate-executor-output.ps1 AddedLines=64 ChangedExecutable=29 ChangedHit=29 ChangedLinePercent=100
CHANGED-COVERAGE file=.claude/hooks/validate-planner-output.ps1 AddedLines=56 ChangedExecutable=23 ChangedHit=23 ChangedLinePercent=100
CHANGED-COVERAGE file=.claude/hooks/validate-required-artifact-output.ps1 AddedLines=64 ChangedExecutable=24 ChangedHit=24 ChangedLinePercent=100
