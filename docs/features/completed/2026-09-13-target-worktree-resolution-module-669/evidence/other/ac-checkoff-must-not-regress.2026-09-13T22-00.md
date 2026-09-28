# AC Check-Off — Must not regress (4 criteria; spec.md and user-story.md)

Timestamp: 2026-09-17T08:48:29-04:00 (file write time)
Command: per-criterion review against the named evidence, then '- [ ] ' -> '- [x] ' for the lines between '### Must not regress (carried verbatim from the epic)' and the next heading in spec.md and user-story.md (criterion text unchanged)
EXIT_CODE: 0
Output Summary: 4 of 4 criteria verified and checked off in both files.

| # | Criterion | Verified by |
| --- | --- | --- |
| 1 | Gates must still deny when a required document is genuinely absent. | evidence/qa-gates/scope-boundary.2026-09-13T22-00.md: no file under .claude/hooks/, .codex/hooks/, or extensions/drm-copilot/src/ changed, so every gate's deny path is unchanged by this feature; the final MCP test run ([P4-T5]) shows no new failure in the hook suites |
| 2 | Do not weaken the pre-implementation gate's pathspec, option, or metacharacter restrictions. | scope-boundary: the pre-implementation gate hook and its helper siblings are unchanged |
| 3 | Do not widen the merge gate's matcher as a side effect of fixes 1-3. | scope-boundary: the merge gate hooks are unchanged |
| 4 | Epic and standalone topologies must behave exactly as now when cwd and target coincide. | evidence/regression-testing/worktree-target-resolution-suite.2026-09-13T22-00.md: the four "required matrix row: cwd ..., own target resolves to SessionRoot" regression-guard rows written by [P2-T6] and persisted by [P2-T10] (Status SessionRoot, WorktreeRoot equal to SessionRoot, ReasonCode null, one candidate) |
