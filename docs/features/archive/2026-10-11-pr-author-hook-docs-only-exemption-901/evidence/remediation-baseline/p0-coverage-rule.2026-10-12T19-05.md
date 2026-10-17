# P0-T3 Coverage reading rule and targets

Timestamp: 2026-10-12T19-40
Command: grep -c '^COVERAGE_TARGET: ' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-ci-pending.2026-10-11T10-38.md
EXIT_CODE: 0
CMD2_EXIT_CODE: 0 (grep -c '^COVERAGE_READ_RULE: ' ...)
Output Summary:
- Counts printed 4 and 1: four COVERAGE_TARGET lines and one COVERAGE_READ_RULE line, copied verbatim below.

COVERAGE_TARGET: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 threshold=85.00
COVERAGE_TARGET: .claude/hooks/enforce-pr-author-skill-helpers.ps1 threshold=85.00
COVERAGE_TARGET: .claude/hooks/enforce-pr-author-skill.ps1 threshold=85.00
COVERAGE_TARGET: .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 threshold=85.00
COVERAGE_READ_RULE: per file, the LINE counter of the class whose package name joined with its sourcefilename equals the repository-relative path; covered / (covered + missed) * 100 >= 85.00
