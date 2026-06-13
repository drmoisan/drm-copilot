---
name: test-files-count-against-500-cap
description: The 500-line file cap applies to test files as well as production files; QA phases must scan all changed/created production AND test files.
metadata:
  type: feedback
  scope: general
---

The `.claude/rules/general-code-change.md` 500-line file cap applies to test files as well as production files. Only throwaway scripts, raw text fixtures, and Markdown are exempt. When a plan adds substantial tests, Phase 0 baseline and final QA tasks must scan ALL changed/created test files (not only production files) and assert each is <= 500 lines.

**Why:** A plan that adds tests but only size-checks production files can create a remediation cycle when test files cross the cap — the only finding raised during feature-review.

**How to apply:** When briefing the planner for any change that adds tests, require the QA phase to include a line-count assertion across all changed/created production AND test files. If a test file would exceed the cap, split it into a sibling test module before reporting completion.
