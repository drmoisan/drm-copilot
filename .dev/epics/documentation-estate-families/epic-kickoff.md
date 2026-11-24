# Epic Kickoff: documentation-estate-families

Planned by epic-planner on 2026-11-23T07:00:00Z. All child features are prepared: issues promoted, active
folders created, research complete, spec/user-story written, atomic plans approved, preflight
ALL CLEAR. Planning state: artifacts/orchestration/epic-planner-state.json (branch:
epic/documentation-estate-families-integration). Epic issue: #1217.

## Invocation Prompt

Run `/epic-run documentation-estate-families` to execute this epic, or paste the prompt below.

Use the epic-orchestrator subagent to execute the prepared epic at
.dev/epics/documentation-estate-families/epic.md. The integration branch
epic/documentation-estate-families-integration already contains every prepared feature folder and approved atomic
plan; child features resume at atomic execution from their committed plan-path rather than
re-planning. Execute per the epic-orchestrate skill: wave-scheduled child orchestrator runs in
isolated worktrees, merge-on-green fan-in to the integration branch, and the final
integration-to-main PR. epic_issue_num: 1217.

## Feature Summary

| issue_num | feature_folder | wave | complexity | plan-path |
| --- | --- | --- | --- | --- |
| 1218 | .dev/active/1218-docs-family-profile-model | 0 | C3 | .dev/active/1218-docs-family-profile-model/plan.2026-11-23T00-38.md |
| 1219 | .dev/active/1219-docs-prose-markdown-lint | 0 | C3 | .dev/active/1219-docs-prose-markdown-lint/plan.2026-11-23T00-38.md |
| 1222 | .dev/active/1222-docs-family-page-templates | 0 | C2 | .dev/active/1222-docs-family-page-templates/plan.2026-11-23T00-39.md |
| 1221 | .dev/active/1221-docs-family-gate-and-ia | 1 | C3 | .dev/active/1221-docs-family-gate-and-ia/plan.2026-11-23T00-39.md |
| 1220 | .dev/active/1220-docs-review-cadence | 2 | C3 | .dev/active/1220-docs-review-cadence/plan.2026-11-23T00-39.md |
| 1223 | .dev/active/1223-docs-epic-scale-routing | 2 | C2 | .dev/active/1223-docs-epic-scale-routing/plan.2026-11-23T00-39.md |

## Execution Notes

- Read the `## Shared Design` section of the epic manifest before wave 0. It records three
  decisions made during preparation: the family check lives in the docs validation step
  (`DocsValidation.psm1` through a new `DocsFamilyCheck.psm1`), not in `DocsCompleteGate.psm1`;
  #1220 places its overdue-blocking option in the same step; and `alerts-catalog` pages are
  reference mode inside the `operations` family directory.
- Each child plan verifies in Phase 0 that its upstream work is on the integration branch.
- #1221 edits five production PowerShell modules plus bundle copies; run it in its item worktree
  under an active checkpoint so the batch-budget hook admits the edits.
- #1223 warns that committing the docs-complete receipt on the integration branch may be denied
  while the epic checkpoint exists; confirm before the final step.
- #1218 open item: no test fails if `.agents/skills/docs-init/references/standard.md` misses the
  new families item (AC19); its final self-review checks it.
- Unrelated defect noted during #1221 preparation, to be filed as its own issue: a docs command
  with more than 100 findings exits 0 with output that breaks its schema.
- Owner constraints for every child: no new Python; parallel-only test runs; append-only evidence
  with clock timestamps; fix related findings inside the item; pre-mortem and self-review before
  every push; 800-line hard file limit; no temp files in tests.
