---
name: fill-feature-docs
description: Invoke the prd-feature worker to produce feature-document outputs from issue and research inputs.
---

# Fill Feature Docs Skill

This direct-use wrapper delegates feature-document work to the `prd-feature` worker.

## Inputs

- Feature folder issue and research context
- Existing spec and user-story files when present

For a numeric `spec.md` acceptance criterion, the research context must contain complete `## Numeric Derivation Evidence` with `Family`, `Inclusion Rules`, `Exclusion Rules`, `Member Set`, `Primary Count`, and an independently constructed agreeing `Cross-check Count`. The worker must omit a numeric assertion if that record is not available or does not agree.

## Output Paths

- `docs/features/active/<feature>/spec.md`
- `docs/features/active/<feature>/user-story.md`

## Worker Routing

- Worker: `prd-feature`
- Require the worker to report the authoritative `research-path` when a numeric acceptance criterion is written.
