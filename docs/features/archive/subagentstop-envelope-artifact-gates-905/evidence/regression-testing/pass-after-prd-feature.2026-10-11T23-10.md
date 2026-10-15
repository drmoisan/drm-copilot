# Pass-after: validate-prd-feature-output (plan [P6-T2], issue #905)

Timestamp: 2026-10-11T23-10
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-scoped.ps1 tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1
EXIT_CODE: 0
Output Summary: SUMMARY: passed=54 failed=0 skipped=0 notrun=0; CONTAINER-ERRORS: 0. A `PASSED-TEST:` line is present for each of F1 to F12 (12 lines in the Coverage suite), each of the 25 R2 rows, and each of the four prd-feature R3 rows (29 R2 and R3 lines).

```text
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | allows a spec without numeric acceptance criteria
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | detects a numeric spec acceptance criterion
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | does not count numeric boxes outside Acceptance Criteria
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects a numeric claim without a complete research record
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects a research record whose independent cross-check disagrees
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | accepts an independently exhaustive complete-family research record
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects an invalid envelope and a blank assistant message
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects missing and nonexistent spec paths
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | accepts a nonnumeric spec without research evidence
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects numeric specs with missing or nonexistent research paths
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | accepts matching numeric provenance and extracts artifact labels
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects every missing numeric-evidence field and a missing section
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | rejects copied-count, duplicate-search, member-set, scope, and narrow-pattern records
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on all with a digit cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on all with a word cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on exactly with a digit cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on exactly with a word cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on the with a digit cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on the with a word cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on these with a digit cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on these with a word cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on those with a digit cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 triggers on those with a word cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a threshold
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a comparator
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on an exit code
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on an issue or PR number
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a line number or file:line
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on an AC or task identifier
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a version
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a date or timestamp
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a section reference
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on zero
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a unit of size or duration
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a count citing .claude/rules/
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a count citing .github/instructions/
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a count citing .github/copilot-instructions.md
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R2 does not trigger on a non-noun word after the cardinal
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R3 accepts the exhaustive scope entire worktree
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R3 accepts the exhaustive scope whole worktree with all directories
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R3 accepts the exhaustive scope entire repository accepted before R3
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | R3 rejects the exhaustive scope the hooks folder
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a stderr reason when last_assistant_message lacks an existing spec-path
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 0 when last_assistant_message carries an existing spec-path whose spec has no derived numeric criterion
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | blocks when spec-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with the empty-message reason when last_assistant_message is an empty string
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason for empty stdin
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason for malformed stdin
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason when last_assistant_message is absent
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | keeps validating when stop_hook_active is true
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a stderr reason when the spec-path file cannot be read
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 in a separate process when the stdin envelope lacks a spec-path
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 0 without a research-path when the acceptance criteria contain only non-derived numerals
PASSED-TEST: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | exits 2 with a stderr reason when the research-path file cannot be read
BLOCK-ERRORS: 0
CONTAINER-ERRORS: 0
SUMMARY: passed=54 failed=0 skipped=0 notrun=0
```
