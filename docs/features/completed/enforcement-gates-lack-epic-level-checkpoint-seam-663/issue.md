# enforcement-gates-lack-epic-level-checkpoint-seam (Issue #663)

- Work Mode: full-bug
- Issue: #663
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/663
- Source: GitHub issue body as consolidated on 2026-09-09, mirrored 2026-09-25. The original promoted record is `docs/features/potential/promoted/2026-09-08-pr-author-preflight-has-no-epic-integration-seam.md` (single-gate scope, superseded by the consolidated body).
- Consolidates: #657, #662, #664 (closed 2026-09-09 as consolidated into this issue). Root cause and blast radius are shared, so one fix delivers all of them.

## Summary

Six enforcement gates assume that every orchestration run keeps a single-feature checkpoint at `artifacts/orchestration/orchestrator-state.json` whose `feature-folder` is under `docs/features/active/` and which carries an `issue-num`. An epic run keeps its state in `artifacts/orchestration/epic-orchestrator-state.json`, its home is `docs/features/epics/<slug>/`, and until the manual promotion of #655 an epic owned no GitHub issue at all. Each gate therefore fails closed on the epic's own operations, and the epic `cleanup-merged-worktrees-hardening` (#655) could not open its integration PR, stage its main-sync merge, commit its status projection, or remove its child worktrees without manual intervention.

| # | Gate | What it reads | Epic operation it blocks | Denial observed |
|---|---|---|---|---|
| 1 | `.claude/hooks/enforce-pr-author-skill.ps1` PR-creation preflight | per-feature checkpoint with `--require-pr-creation-ready` | the integration-to-`main` PR | `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` (steps 5-8 pending, wrong issue) |
| 2 | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` check 6 | `epic_mode: true` demands `--base <integration_branch>` | the one PR in an epic whose base is `main` | `EPIC_BASE_BRANCH_MISMATCH` |
| 3 | `.claude/hooks/enforce-model-routing-receipt.ps1` | per-feature `model_routing_receipts[]` only | `Agent(pr-author)` delegation from `epic-orchestrator` | receipt absent where the gate looks (was #662) |
| 4 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` `Test-OrchestrationReady` | `feature-folder` must start with `docs/features/active/` | staging the main-sync merge's conflict resolutions; committing `epic-status.md` | `PREIMPLEMENTATION_GATE_BLOCKED` (was #664) |
| 5 | completion-consistency hook on checkpoint edits | same prefix, plus a `ci_gate.conclusion` it reads from the per-feature shape | appending post-completion evidence to an epic-level checkpoint | `COMPLETION_CONSISTENCY_BLOCKED` |
| 6 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | parallel checkpoint only; no epic fallback (the epic gate has the reciprocal one) | removing a merged child worktree | `PARALLEL_WORKTREE_REMOVAL_BLOCKED` (was #657) |

## Environment

- OS/version: Windows 11 Pro 10.0.26200, Claude Code runtime, PowerShell 7.
- Python version: 3.13 (validator via Poetry) for the readiness and completion validators.
- Command/flags used: `gh pr create --base main --body-file artifacts/pr_body_655.md`; `Agent(pr-author)`; `git add <resolved production path>` during `git merge origin/main`; `git worktree remove <merged child path>`; `Edit` of a completion-asserting `orchestrator-state.json`.
- Data source or fixture: epic #655 execution on 2026-09-07 to 2026-09-09; `artifacts/orchestration/epic-orchestrator-state.json` follow-ups 1, 7, 8, 10 and the main session's provenance block.

## Steps to Reproduce

1. Run any epic to the end of its final wave so the worktree's `orchestrator-state.json` describes a child or a superseded run.
2. From `epic-orchestrator`, attempt in turn: `git worktree remove` on a merged child (gate 6); `Agent(pr-author)` for the integration PR (gates 3, 1, and, with `epic_mode: true`, 2); `git merge origin/main` followed by `git add` of a conflicted production path (gate 4); after completion, an `Edit` appending CI evidence to the checkpoint (gate 5).
3. Observe each denial above.

## Expected Behavior

- One shared resolver maps the caller (`agent_type` on the envelope, or the epic kickoff marker in a delegation prompt) to the checkpoint that governs it: `epic-orchestrator-state.json` for an epic-level operation, the per-feature checkpoint otherwise. Every gate in the table consumes that resolver instead of hard-coding the per-feature path and the `docs/features/active/` prefix.
- `epic-planner` promotes an epic-level issue at planning time (`potential_to_issue` already supports `promotion_type: epic`) and records `epic_issue_num` in the manifest, so the epic's own PR, checkpoint, and closures have a real parent without a manual promotion.
- The epic-orchestrate skill states the checkpoint shape for the integration-PR step, and the base-branch check accepts `--base main` when the epic checkpoint's `epic_merge_pr` is the readiness source.
- Readiness accepts `docs/features/epics/<slug>/` when `route_id` is `epic`; the parallel worktree-removal gate gains the reciprocal epic-checkpoint fallback.

## Actual Behavior

On #655 the main session promoted the epic issue by hand, wrote a per-feature checkpoint describing the integration-PR run keyed to it with `epic_mode: false`, and issued the bookkeeping commit and the sync-merge commit through the PowerShell tool because the Bash-side staging exemption also rejects the mandated `Co-Authored-By` trailer characters. Nine child worktrees were left registered. Every workaround is recorded in that checkpoint's `checkpoint_provenance` block; none altered a gate.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

```
INTEGRATION_PR_CANNOT_BE_OPENED: every available path to satisfying the pr-author PR-creation preflight requires asserting something untrue in a checkpoint.
PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.
COMPLETION_CONSISTENCY_BLOCKED: ... feature-folder value 'docs/features/epics/cleanup-merged-worktrees-hardening' is not a valid feature folder (must be under docs/features/active/ and exist)
PARALLEL_WORKTREE_REMOVAL_BLOCKED (same path had just passed the epic gate)
```

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Every epic stalls at its final PR and leaves its worktrees behind unless a human or the main session intervenes.

## Suspected Cause / Notes

- The gates predate epics or were extended for epic children only; #554 fixed the delegation leg of the preimplementation gate but not its command leg, and #573 fixed the epic gate's fallback to the parallel checkpoint but not the reverse.
- Prior epics (#388, #459, #610) left no record of how their integration PRs passed these gates; the recipe that worked on #655 is in the `epic-integration-pr-needs-epic-issue` memory note.
- Blast radius: the six hook files above plus `enforce-orchestration-preimplementation-gate-helpers.ps1`, their Pester suites under `tests/scripts/claude-hooks/`, the push-down mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` (and the `.codex` copies where a counterpart exists), `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/skills/epic-plan/SKILL.md`, and `.claude/agents/epic-planner.md`. That exceeds a single large-path change budget; plan it as a two-child epic (child A: shared checkpoint resolver and call-site rewiring across the six gates; child B: epic-issue promotion in `epic-planner` and the integration-PR checkpoint contract in the skill) or as one large feature with explicit batch caps.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: Pester cases per gate for the epic-orchestrator caller with the evidence present only in the epic checkpoint (allow), absent (deny), and the per-feature path unchanged for standalone runs; a readiness case for `route_id: epic` with an epics-tree folder; a base-branch case accepting `--base main` under `epic_merge_pr`; a staging-exemption case for a `-m` message containing angle brackets and apostrophes.
- [x] Integration scenario to retest: an epic run that opens its integration PR, stages a main-sync merge conflict, commits its status projection, and removes its merged child worktrees without any tool detour.
- [x] Manual verification notes: rerun the #655 sequence from the recorded provenance block and confirm zero denials.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
