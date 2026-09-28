# Requirements Sources Read — issue #671

Timestamp: 2026-09-17T07-50
Task: [P0-T2]

## Paths read

1. `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md` (723 lines, full read)
2. `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/research/2026-09-13T21-15-preimplementation-gate-worktree-selector-671-research.md` (952 lines, full read)
3. `docs/features/epics/worktree-scoped-state-resolution/epic.md` (377 lines; F2-relevant regions read, plus a content search for `495`, `helpers`, and `surfaces`)

## Acceptance criteria count

Acceptance-criterion count in `spec.md` (checkbox items under `## Acceptance Criteria`, lines 620-643): 24

Checkbox-line census of `spec.md` at this point: 29 lines total matching `- [x] ` or `- [ ] ` (24 acceptance criteria, 4 Impact/Severity lines, 1 Logs/Screenshots line); 2 lines are `- [x] ` (the `Blocker` severity line and the `Attached minimal logs` line), 0 acceptance criteria are checked.

## Corrections this plan carries against the epic manifest

1. The helpers file `enforce-orchestration-preimplementation-gate-helpers.ps1` is 349 lines, not 495. The 495/496 figure belongs to the gate file. No helpers extraction is required.
2. There are four mirror surfaces, not three. The fourth is `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, which is hash-bound by `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.

Observation: the current `epic.md` already records both corrections (line 144, "The preimplementation helpers file is 349 lines, not 495", and line 149, "There are four mirror surfaces, not three"). The line-218 citation in the plan refers to an earlier revision of `epic.md`; the substance of both corrections is unchanged and no further epic edit is in scope for this plan.
