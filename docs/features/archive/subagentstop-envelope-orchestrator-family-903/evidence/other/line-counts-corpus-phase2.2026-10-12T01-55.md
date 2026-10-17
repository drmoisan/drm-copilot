# Line Counts and Porcelain after the Corpus Block ([P2-T17])

Timestamp: 2026-10-12T01-55
Command: git status --porcelain; sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/line-counts.ps1 <S-PROD-6> <S-CORPUS-HOST-4>
EXIT_CODE: 0
Output Summary: Every porcelain path is in S-ALLOW (two S-PROD-6 files, two S-CORPUS-HOST-4 files, and feature-folder paths). LINECOUNT-SUMMARY OverLimitCount=0.

Porcelain:
 M .claude/hooks/validate-executor-output.ps1
 M .claude/hooks/validate-planner-output.ps1
 M docs/features/active/subagentstop-envelope-orchestrator-family-903/plan.2026-10-11T07-59.md
 M tests/scripts/claude-hooks/validate-executor-output.Tests.ps1
 M tests/scripts/claude-hooks/validate-planner-output.Tests.ps1
?? docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/commit-push-phase2.2026-10-12T01-25.md
?? docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/corpus-rule-changes.2026-10-12T01-27.md
?? docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/corpus-setup.2026-10-12T01-27.md
?? docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/
?? docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/regression-testing/corpus-phase2-regression.2026-10-12T01-52.md

Line counts:
.claude/hooks/validate-orchestrator-output.ps1 LineCount=316
.claude/hooks/validate-orchestrator-output-routing.ps1 LineCount=170
.claude/hooks/validate-orchestrator-output-resolution.ps1 LineCount=309
.claude/hooks/validate-executor-output.ps1 LineCount=296
.claude/hooks/validate-planner-output.ps1 LineCount=420
.claude/hooks/validate-required-artifact-output.ps1 LineCount=171
tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 LineCount=330
tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 LineCount=200
tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 LineCount=400
tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 LineCount=43
LINECOUNT-SUMMARY OverLimitCount=0
