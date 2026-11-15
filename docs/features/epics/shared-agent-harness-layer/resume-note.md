# Resume Note: shared-agent-harness-layer (epic #1018)

Written by epic-planner on 2026-10-31T18-41 (UTC) when planning was paused for quota by owner
instruction. Planning only; no execution has started. Integration branch:
`epic/shared-agent-harness-layer-integration`. Planning checkpoint (gitignored):
`artifacts/orchestration/epic-planner-state.json` in the epic-planner worktree.

## Cleared and fanned in (PREFLIGHT: ALL CLEAR)

| Child | Issue | Wave | Folder | Plan(s) |
| --- | --- | --- | --- | --- |
| 1 survey, contracts, parity matrix | #1025 | 0 | docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025 | plan.2026-10-30T17-06.md (plan A), owner-decision-plan.md (plan B) |
| 2 #1016 Phase 1 | #1035 | 0 | docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035 | plan.2026-10-30T17-11.md |
| 3 generators | #1028 | 1 | docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028 | plan.2026-10-30T18-30.md (96 tasks, H3 revision) |
| 4 push-down consolidation | #1029 | 2 | docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029 | plan.2026-10-30T18-37.md |
| 5 hook parity | #1030 | 2 | docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030 | plan.2026-10-30T18-37.md |
| 6 retirements, thin Copilot layer | #1032 | 3 | docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032 | plan.2026-10-30T18-39.md (58 tasks, H3 revision), plan-agents-branch-a.md, plan-agents-branch-b.md |
| 7 #1016 Phases 2 and 3 | #1016 | 6 | docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016 | plan.2026-10-30T18-59.md (stage A), plan.2026-10-30T23-35.md (stage B) |

No cleared plan has an open preflight defect.

## Not yet prepared (added 2026-10-31)

| Child | Issue | Wave | depends_on | State at pause |
| --- | --- | --- | --- | --- |
| 8 vendored-code coverage carve-out | #1049 | 3 | 1029 | Paused before preflight (updated after its hand-back). Branch `feature/pushed-down-vendored-code-coverage-carve-out-1049`, pushed head 2362ce80f. Folder docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049; research research/research.2026-10-31T18-20.md; plan plan.2026-10-31T14-03.md (54 tasks, plan validators pass). Child checkpoint next_step `S4b_preflight:atomic-executor`, paused_for_quota true, no failure recorded. Known item for preflight: [P4-T13] cites "the AC mapping below", which is not in the plan file. Not yet fanned in. |
| 9 CI workflows per ecosystem pack | #1050 | 4 | 1049, 1028, 1029 | Not started. Promoted record committed. |
| 10 integration MCP tools and skill | #1051 | 5 | 1049, 1050 | Not started. Promoted record committed. |

Promoted records: docs/features/potential/promoted/2026-10-31-pushed-down-vendored-code-coverage-carve-out.md,
2026-10-31-push-down-ci-workflows-per-ecosystem-pack.md, 2026-10-31-push-down-integration-mcp-tools-and-skill.md.

## Decisions already applied

- E1: child 7 adopts #1016; child 2 re-keyed to #1035 (no Closes/Fixes for #1016).
- Child 1 plan B: an owner override to `native` takes precedence over the E3 result and drops
  `target_paths` and `generated_from`.
- Child 3: option (a) — [P1-T22] may add append-only `coverageThreshold` entries to
  `extensions/drm-copilot/jest.config.cjs` after the parallel run merges (PQ-2; attribution
  "decided by coordinator under owner standing instruction" awaits owner ratification).
- Child 6: [P6-T10] uses no regression on changed lines plus at least 85% line and 75% branch
  coverage per remaining changed file.
- Child 7: tests that read the frozen write-intent fixtures must pin a `docs/features` root
  explicitly; recorded in stage B's risk notes ([P1-T3] stops if the pin is absent). Child 2's plan
  does not itself add the pin.
- H3: child 6 retires `sync-agents-from-instructions.ps1`; child 3 redirects the Codex native
  converter.

## Execution-time conditions recorded by the children

- Parallel run `bugs-1001-1002-1003-1006` item #1013 is open; Phase 0 gates stop until it merges or
  leaves the run manifest.
- The integration branch lacks recent `origin/main` merges; the epic orchestrator's per-wave
  main-sync covers this.

## Exact next step

1. Resume #1049 at its executor preflight (single pass, at most one planner revision) with a
   replacement preparation-mode orchestrator that adopts the branch and copies the child checkpoint.
   Owner questions from #1049 carry provisional defaults in its spec (OQ-1: the destination check
   lives in the bundled PoshQC module, run by the PoshQC MCP tools against a destination, rather
   than a module pushed into destinations; OQ-2, OQ-3, OQ-5, OQ-6 yes; OQ-4, OQ-7 deferred); a
   different answer before execution requires re-planning.
2. Prepare #1050, then #1051, each adopting its existing issue, one at a time within the agent cap.
3. Fan in children 8 to 10, back-fill their `feature_folder` values in epic.md, then write
   `artifacts/orchestration/epic-kickoff-shared-agent-harness-layer.md` and its committed copy
   `docs/features/epics/shared-agent-harness-layer/epic-kickoff.md`, set `next_step` to
   `EPIC_EXECUTION_READY`, and run the epic-planner-state validator with
   `require_ready_for_execution`.

---

## Current state (appended 2026-11-14T20-58 UTC; the record above is kept as history)

Planning was refreshed on 2026-11-14 under OD-1 (autonomous mode). `origin/main` was merged into
the integration branch and into every child branch. All ten children were checked for superseded
work and re-planned or prepared. No child was removed. Details per child, decisions and open
defects: `epic.md` sections `## Planning Refresh 2026-11-14` and `### Per-child refresh results`.

Cleared (PREFLIGHT: ALL CLEAR): #1030; #1032 (all four plans); #1051; #1025 plan B; #1016 stage A.

Halted at the one-revision preflight limit, each with its open defects and required changes
recorded: #1025 plan A, #1035, #1028, #1029, #1049, #1050, #1016 stage B.

The epic is not yet execution-ready. The kickoff artifacts are written and list the halted
plans. The planning checkpoint `next_step` is `AWAITING_EXTRA_PLANNER_REVISIONS`.

### Exact next step

1. The main session records one `extra_planner_revision` directive per halted plan in the ledger
   `artifacts/orchestration/owner-directives.jsonl` of that child's worktree (scope: the child
   issue, its branch, step `S4`). The planner subagent cannot write the ledger.
2. Re-run the epic planner. It sends each halted child one planner revision that carries the
   recorded defects, then one confirming preflight. Use at most two child orchestrators at a time.
3. Fan in, set `next_step` to `EPIC_EXECUTION_READY`, update the kickoff status table, and run the
   epic-planner-state validator with `require_ready_for_execution`.

---

## Current state (appended 2026-11-15T18-53 UTC)

The OD-2 extra-revision round is complete. All seven halted plans (#1025 plan A, #1035, #1028,
#1029, #1049, #1050, #1016 stage B) are PREFLIGHT: ALL CLEAR, so every child of the epic is
prepared. Planning checkpoint `next_step` is `EPIC_EXECUTION_READY`, and the kickoff is marked ready.
Scope changes and the one known execution-time gap are recorded in `epic.md` under
`### Extra-revision round 2026-11-15 (OD-2)`.

Next step: the owner runs `/epic-run shared-agent-harness-layer` from the main session, or replays
the prompt in `epic-kickoff.md`.
