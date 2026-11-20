# Epic Kickoff: push-down-payload-correctness

Planned by epic-planner on 2026-09-29T16:30. All child features are prepared: issues promoted,
active folders created, research complete, spec/user-story written, atomic plans approved,
preflight ALL CLEAR. Planning state: artifacts/orchestration/epic-planner-state.json (branch:
epic/push-down-payload-correctness-integration).

Epic issue: #770 (`epic_issue_num: 770`). The integration-to-main pull request uses #770 as its
canonical issue number.

## Invocation Prompt

Run `/epic-run push-down-payload-correctness` to execute this epic, or paste the prompt below.

Use the epic-orchestrator subagent to execute the prepared epic at
docs/features/epics/push-down-payload-correctness/epic.md. The integration branch
epic/push-down-payload-correctness-integration already contains every prepared feature folder and
approved atomic plan; child features resume at atomic execution from their committed plan-path
rather than re-planning. Execute per the epic-orchestrate skill: wave-scheduled child orchestrator
runs in isolated worktrees, merge-on-green fan-in to the integration branch, and the final
integration-to-main PR. epic_issue_num: 770. Before launching wave 2 (#621), resolve the
ROOT_FOLDERS precondition item under "Execution Notes" in
docs/features/epics/push-down-payload-correctness/epic-kickoff.md.

## Feature Summary

| issue_num | feature_folder | wave | complexity | plan-path |
| --- | --- | --- | --- | --- |
| 507 | 2026-08-22-push-down-root-folders-divergence-507 | 0 | C3 | docs/features/active/2026-08-22-push-down-root-folders-divergence-507/plan.2026-09-29T14-13.md |
| 763 | 2026-09-28-parallel-skills-invoke-unbundled-python-clis-763 | 0 | C3 | docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/plan.2026-09-29T14-14.md |
| 508 | 2026-08-22-blast-radius-config-has-no-merge-decorator-508 | 1 | C3 | docs/features/active/2026-08-22-blast-radius-config-has-no-merge-decorator-508/plan.2026-09-29T14-14.md |
| 621 | 2026-09-29-push-down-destination-exclusion-manifest-621 | 2 | C4 | docs/features/active/2026-09-29-push-down-destination-exclusion-manifest-621/plan.2026-09-29T14-15.md |

## Execution Notes

0. **Dependencies.** #508 depends on #507, and #621 depends on #507 and #508. #763 has no
   dependencies.

1. **#621 ROOT_FOLDERS precondition: possible false block. Resolve before wave 2.** The #621
   Phase 1 precondition reads only the single line that declares `ROOT_FOLDERS` in
   `scripts/dev_tools/push_down_claude_customizations.py`. #507 plan task P5-T1 writes that
   declaration on one line, `ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"), Path("config"))`,
   which is about 72 characters and within the formatter line limit. The precondition therefore
   holds if #507 lands as planned. If #507's merged code splits the tuple across several lines,
   #621 blocks at Phase 1. Before launching #621, do one of the following:
   - Confirm that the merged #507 declaration is on a single line.
   - Have `atomic-planner` revise the #621 precondition to the reviewer's suggested form
     (`grep -n -A 3 -e '^ROOT_FOLDERS'`), then re-run preflight.

   The suggested fix is recorded in the archived #621 child checkpoint.
2. **#508 migration: operator decision point.** #508 introduces a destination-owned
   `config/blast-radius.local.json` overlay that is merged on every push. Migration is
   documentation-only. A destination that hand-edited `config/blast-radius.json` loses those edits
   on its first push after #508 lands unless it first moves them into
   `config/blast-radius.local.json`. The push emits no warning. The operator must decide whether
   the documentation-only migration is acceptable before #508 merges into the integration
   branch, or before the integration branch merges to main. If it is not acceptable, #508's
   scope must widen, for example by adding a summary warning. That requires a plan revision and
   a new preflight.
3. **#507 PR content (AC25).** The #507 pull request must reference #507 and #764 part 2, and
   must state that #764 part 1 (missing `Test-ModifiedWorkflowNeedsGreenRun.ps1`) is out of
   scope. #507's scope also grew during preparation. It ports the routing merge and the
   blast-radius derivation to Python, and it reads `config/` from the extension bundle.
4. **#508 and #507 interaction.** #508's spec accepts a Python/TypeScript blast-radius derivation
   gap that #507 now closes. No #508 acceptance criterion depends on that gap. #508 plan task
   P0-T4 blocks unless #507's `config` root is present, which the wave ordering guarantees.
5. **Follow-ups (recorded, not promoted).** These are potential entries only. Promote them
   separately if wanted:
   - `docs/features/potential/2026-09-29-issue-507-python-push-down-divergence-follow-ups.md`:
     the Python `.gitignore` managed-block merge, and the Python CLI publishing gitignored
     `.claude/worktrees/**` and `.claude/state/**`.
   - `docs/features/potential/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups.md`:
     FU-763-1 through FU-763-5. FU-763-4 is already tracked by #734.
6. **Archived preparation checkpoints.** The archived checkpoints are gitignored and local to
   the planning worktree:
   `artifacts/orchestration/handoff/orchestrator-state.issue-<507|508|621|763>.2026-09-29T16-21.json`.
