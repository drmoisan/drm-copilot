# Minor-audit inputs (P0-T2)

Timestamp: 2026-10-16T00-24
Command: grep -c -F -e "- Work Mode: minor-audit" issue.md
EXIT_CODE: 0
Output Summary: counts 1 (Work Mode marker), 1 (## Acceptance Criteria heading), 8 (unchecked "- [ ] AC-" items). Feature folder lists issue.md, plan.2026-10-15T17-44.md, research/; neither spec.md nor user-story.md present.

Command: grep -c -F -e "## Acceptance Criteria" issue.md
EXIT_CODE: 0
Output: 1

Command: grep -c -F -e "- [ ] AC-" issue.md
EXIT_CODE: 0
Output: 8

Command: ls docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936
EXIT_CODE: 0
Output: issue.md, plan.2026-10-15T17-44.md, research/
