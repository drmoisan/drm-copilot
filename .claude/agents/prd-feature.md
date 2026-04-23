---
name: prd-feature
description: Project-scoped worker that produces feature-document outputs from issue and research context.
tools:
  - Read
  - Grep
  - Glob
  - "Write(/docs/features/active/**)"
skills:
  - acceptance-criteria-tracking
memory: project
---

# PRD Feature Agent

Produce feature-document outputs for the active feature folder.

## Expected Outputs

- `docs/features/active/<feature>/spec.md`
- `docs/features/active/<feature>/user-story.md`
