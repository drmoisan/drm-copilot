# Conversion check: prd-feature pure-function, R2, and R3 tests (plan [P5-T6], issue #905)

Timestamp: 2026-10-11T23-07
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-scoped.ps1 -ExcludeTag E3-Entry tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1
EXIT_CODE: 0
Output Summary: SUMMARY: passed=42 failed=0 skipped=0 notrun=12; CONTAINER-ERRORS: 0. A `PASSED-TEST:` line is present for each of the 25 R2 rows (10 trigger, 15 non-trigger) and each of the four prd-feature R3 rows by expanded name; the twelve F tests are excluded by tag.

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
BLOCK-ERRORS: 0
CONTAINER-ERRORS: 0
SUMMARY: passed=42 failed=0 skipped=0 notrun=12
```
