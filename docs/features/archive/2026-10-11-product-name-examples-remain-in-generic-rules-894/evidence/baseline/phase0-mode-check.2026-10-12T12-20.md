Timestamp: 2026-10-12T12-20
Command: git grep --no-index -h -c "^## Acceptance Criteria$" -- issue.md; git grep --no-index -h -c -F "Work Mode: minor-audit" -- issue.md; git grep --no-index -h -c -F "[ ]" -- issue.md; git grep --no-index -h -c -F "[x]" -- issue.md; git ls-files --cached --others -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894
EXIT_CODE: 0
Output Summary:
- AC heading count: 1 (exit 0)
- Work Mode minor-audit count: 1 (exit 0)
- "[ ]" count: 10 (exit 0)
- "[x]" count: no output, exit 1 (pass condition)
- git ls-files listing (exit 0): issue.md, plan.2026-10-11T09-43.md, research/research.2026-10-11T13-50.md; neither spec.md nor user-story.md present.
Result: all preconditions hold.
