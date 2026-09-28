# Phase 0 — Requirements Sources (issue #554)

Timestamp: 2026-08-26T10-18

## Documents Read In Full

1. `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md` (999 lines)
2. `docs/features/active/preimplementation-gate-blocks-epic-execution-554/issue.md` (111 lines)
3. `docs/features/active/preimplementation-gate-blocks-epic-execution-554/research/2026-08-26T09-30-preimplementation-gate-epic-execution-554-research.md` (957 lines)

## Acceptance-Criteria Source Resolution

Work mode is `full-bug`, persisted as `- Work Mode: full-bug` in `issue.md`. Under
`.claude/skills/acceptance-criteria-tracking/SKILL.md`, `full-bug` resolves the authoritative
acceptance-criteria source to `spec.md` only.

`spec.md` is therefore the **sole** acceptance-criteria source for this feature. `issue.md` carries
the issue body, the amendment pointer, and a precedence note; its `## Acceptance Criteria` section is
an explicit pointer that states "Do not check items off here." Nothing is checked off in `issue.md`.

## user-story.md

`user-story.md` is **deliberately absent** and its absence is **not a blocker**.

Verified by directory listing: `docs/features/active/preimplementation-gate-blocks-epic-execution-554/`
contains `evidence/`, `issue.md`, `plan.2026-08-26T08-40.md`, `research/`, and `spec.md`. No
`user-story.md` exists.

The justification is stated in `spec.md` section "Document Role and the Absent User Story": the
defect is a decision-procedure fault inside a `PreToolUse` enforcement hook, with no user-facing
narrative, no persona whose goal changes, and no externally observable surface other than whether an
orchestration delegation is permitted to proceed. Under work mode `full-bug` the AC source is
`spec.md` only, so a user story would introduce a second, non-authoritative requirement source.

## Acceptance-Criteria Item Count

Acceptance-criteria items found in the spec's `## Acceptance Criteria` section: **35**

Command used to count:

```bash
awk '/^## Acceptance Criteria/,/^\*\*Total acceptance-criteria/' \
  docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md \
  | grep -c '^- \[ \]'
```

Result: `35`. This agrees with the spec's own closing statement, "**Total acceptance-criteria items:
35.** All are unchecked at authoring time."

## Precedence Recorded

The maintainer amendment comment of 2026-08-26 supersedes the original issue body's Expected Behavior
on one point: the readiness source is resolved from the recognized mode marker via a fixed table and
is **never** resolved from a path parsed out of the prompt. A prompt-declared checkpoint path is a
cross-check operand only; a disagreement denies.
