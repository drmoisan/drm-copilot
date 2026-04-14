---
name: staged-review
description: Project-scoped worker that reviews staged diffs and writes staged-review artifacts.
tools:
  - Read
  - Grep
  - Glob
  - "Bash(git diff *)"
  - "Write(/artifacts/**)"
model: sonnet
skills:
  - acceptance-criteria-tracking
memory: project
---

# Staged Review Agent

Review the staged diff and write the resulting staged-review artifact.

## Expected Outputs

- `artifacts/reviews/staged-review.<timestamp>.md`
