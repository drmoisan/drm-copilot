# Coverage delta ([P5-T8])

Timestamp: 2026-10-08T18-33
Command: derived from evidence/baseline/p0-coverage.md, evidence/qa-gates/p5-coverage.md, and evidence/qa-gates/p5-changed-lines.md (no new command)
EXIT_CODE: 0
Output Summary: every POST_LINE_PCT is at least 85 (93.62, 97.01, 100, 88.06); every changed-code figure covers all executable changed lines; no DELTA is negative.

.claude/hooks/enforce-completion-consistency.ps1: BASELINE_LINE_PCT=92.13 POST_LINE_PCT=93.62 DELTA=+1.49 CHANGED_COVERED=26 of 26
.claude/hooks/enforce-completion-helpers.ps1: BASELINE_LINE_PCT=93.02 POST_LINE_PCT=97.01 DELTA=+3.99 CHANGED_COVERED=24 of 24
.codex/hooks/enforce-completion-consistency.ps1: BASELINE_LINE_PCT=100 POST_LINE_PCT=100 DELTA=0 CHANGED_COVERED=26 of 26
.codex/hooks/enforce-completion-helpers.ps1: BASELINE_LINE_PCT=79.07 POST_LINE_PCT=88.06 DELTA=+8.99 CHANGED_COVERED=24 of 24

Observation: the baseline of .codex/hooks/enforce-completion-helpers.ps1 was below 85 (LINE_PCT_BELOW_85 in [P0-T13]); the post-change value clears the threshold.
