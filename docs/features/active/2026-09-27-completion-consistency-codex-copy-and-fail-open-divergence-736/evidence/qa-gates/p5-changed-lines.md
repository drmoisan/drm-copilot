# Changed-line coverage, final pass ([P5-T7])

Timestamp: 2026-10-08T18-32
Command: CHANGED_LINES_EXTRACT with BASE_SHA 991aae0a180a09d504b59bc9460ec4b00b85d11b (plan template, run unchanged)
EXIT_CODE: 0
Output Summary: four CHANGED_LINES lines, every uncovered value is 0, no COVERAGE_SELECT_COUNT line. The first pass printed uncovered=1 (line 248, the no-old_string branch of Invoke-SingleOccurrenceEdit) for both helper files; the loop restarted after one row was added to each EditSemantics suite.

CHANGED_LINES .claude/hooks/enforce-completion-consistency.ps1 total=84 executable=26 uncovered=0 lines=
CHANGED_LINES .claude/hooks/enforce-completion-helpers.ps1 total=105 executable=24 uncovered=0 lines=
CHANGED_LINES .codex/hooks/enforce-completion-consistency.ps1 total=88 executable=26 uncovered=0 lines=
CHANGED_LINES .codex/hooks/enforce-completion-helpers.ps1 total=105 executable=24 uncovered=0 lines=
