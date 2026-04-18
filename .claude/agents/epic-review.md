---
name: epic-review
description: Project-scoped worker that reviews epic folders and writes epic-audit artifacts.
tools:
  - Read
  - Grep
  - Glob
  - "Write(/docs/features/**)"
skills:
  - acceptance-criteria-tracking
memory: project
---

# Epic Review Agent

Review epic-level scope and write the resulting epic-audit artifact.

## Expected Outputs

- `docs/features/epics/<epic>/epic-audit.<timestamp>.md`
