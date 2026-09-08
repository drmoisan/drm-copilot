# collect-pr-context-omits-claude-tree (User Story)

- **Issue:** #633
- **Work Mode:** full-bug
- **Last Updated:** 2026-09-06

## Why this file exists despite `full-bug` mode

Per `.claude/skills/acceptance-criteria-tracking/SKILL.md` and
`.claude/skills/feature-promotion-lifecycle/SKILL.md`, a `full-bug` feature normally
expects `spec.md` only, with `user-story.md` "optional/absent by default" and present
"only if the requirements explicitly justify it." This file exists because this feature
folder is a prepared child of the `cleanup-merged-worktrees-hardening` epic, and
`scripts/dev_tools/epic_planner_readiness.py` requires `issue.md`, `spec.md`, and
`user-story.md` to all be present in every prepared epic child folder for the epic
planner's readiness check to pass, independent of the child's own work-mode marker. This
file is therefore an epic-preparation infrastructure requirement, not a signal that this
bug has product-facing user-story content beyond what `spec.md` already captures.
`spec.md` remains the sole acceptance-criteria source for this `full-bug` feature, per the
AC Source Resolution table in `.claude/skills/acceptance-criteria-tracking/SKILL.md`.

## Story (for completeness)

As a reviewer of a pull request generated through `collect_pr_context`, I want the
"Changed files overview" section to list every changed file, so that I can review the
full scope of a changeset without needing to separately consult a raw diff appendix for
files the overview silently omitted.

**Current behavior:** the overview only lists a changed file if it is a rename, ends in
`.py`/`.ps1`, or starts with `docs/`/`.github`, or contains the substring `AGENTS`. Every
other changed file — including `.claude/**` skills/rules/agents documentation, all
TypeScript source and test files, shell scripts, and JSON/YAML configuration — is
silently omitted.

**Desired behavior:** every changed, non-renamed file is enumerated in exactly one of
the overview's buckets.

This story does not introduce new acceptance criteria beyond those already enumerated
in `spec.md`'s "Acceptance Criteria" section; it exists solely to satisfy the epic
readiness tooling's structural expectation and to give the epic planner a one-line
description of user-facing intent alongside the technical spec.
