# End-to-End CLI Verification — Rendered Template WITH `## Integrity`

Timestamp: 2026-08-08T15-25

Task: [P5-T1]
Working directory: repository root
Producer: `.claude/skills/parallel-plan/SKILL.md` (post-Phase-2 corrected state)
Consumer: the delivered `parallel-kickoff` artifact type

Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts parallel-kickoff artifacts/orchestration/parallel-kickoff-remediation-verification.md`

EXIT_CODE: 0

Output Summary: PASS with zero error lines emitted. The CLI printed only its success line, `parallel-kickoff validation passed: artifacts/orchestration/parallel-kickoff-remediation-verification.md`, and exited 0. Both errors reproduced by [P0-T10] are gone: the B1 structural-invocation error is removed by the [P1-T1] widening of `RESUME_RE` to `(?:Every item|Each item|items)`, and the B2 integrity-line error is removed by the [P2-T1] template correction to `planning_commit: <hex>`.

## Raw Output

```
parallel-kickoff validation passed: artifacts/orchestration/parallel-kickoff-remediation-verification.md
```

Error lines emitted: 0.

## Substitution Values Used

Identical to the [P3-T2] Python seam-module constants and the [P4-T3] TypeScript constants.

| Placeholder | Substituted value |
|---|---|
| `<slug>` | `bugfix-batch` |
| `<iso8601>` | `2026-08-08T15:15:00Z` |
| `<hex>` | `4a7f1c9e2b8d3a6f0c5e91b47d28a3f6c0e5b91d` |
| six-cell row | `443 / docs/features/active/2026-08-07-parallel-planner-surface-443 / 0 / C3 / feature/parallel-planner-surface-443 / docs/features/active/2026-08-07-parallel-planner-surface-443/plan.md` |
| two-cell row | `docs/features/active/2026-08-07-parallel-planner-surface-443/plan.md / 9f2e4c7a1b5d8e0f3a6c9b2d5e8f1a4c7b0d3e6f` |

## Full Rendered Document

```markdown
# Parallel Kickoff: bugfix-batch

Planned by parallel-planner on 2026-08-08T15:15:00Z. All items are prepared: promoted, active folders created,
research complete, spec and user-story written, atomic plans approved, preflight ALL CLEAR, blast
radii declared and V1/V2-clear. Planning state:
artifacts/orchestration/parallel-planner-state.json (run branch: parallel/bugfix-batch-plan).

## Invocation Prompt

Run `/parallel-run bugfix-batch` to execute this run, or paste the prompt below.

Use the parallel-orchestrator subagent to execute the prepared run whose manifest is
docs/features/parallel/bugfix-batch/parallel.md on the plan-home branch parallel/bugfix-batch-plan. Each item
resumes at atomic execution from its committed plan-path on its own pushed feature branch rather
than re-planning, and each item opens its own pull request against main.

## Item Summary

| issue_num | feature_folder | cohort | complexity | branch | plan-path |
| --- | --- | --- | --- | --- | --- |
| 443 | docs/features/active/2026-08-07-parallel-planner-surface-443 | 0 | C3 | feature/parallel-planner-surface-443 | docs/features/active/2026-08-07-parallel-planner-surface-443/plan.md |

## Integrity

planning_commit: 4a7f1c9e2b8d3a6f0c5e91b47d28a3f6c0e5b91d

| plan-path | plan-hash |
| --- | --- |
| docs/features/active/2026-08-07-parallel-planner-surface-443/plan.md | 9f2e4c7a1b5d8e0f3a6c9b2d5e8f1a4c7b0d3e6f |
```
