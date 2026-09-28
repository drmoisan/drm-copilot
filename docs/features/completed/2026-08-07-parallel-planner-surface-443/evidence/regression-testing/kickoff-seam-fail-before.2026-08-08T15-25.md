# Fail-Before Reproduction — Producer/Consumer Kickoff Seam

Timestamp: 2026-08-08T15-25

Task: [P0-T10] `[expect-fail]`
Working directory: repository root
Producer: `.claude/skills/parallel-plan/SKILL.md` (fenced `markdown` block under `## Kickoff Artifact`, pre-remediation state)
Consumer: `scripts/dev_tools/parallel_kickoff_contract.py` via the `parallel-kickoff` artifact type

Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts parallel-kickoff artifacts/orchestration/parallel-kickoff-remediation-verification.md`

EXIT_CODE: 1

Output Summary: The reproduction established the defect. The delivered validator rejected a document produced verbatim from the delivered skill template, emitting exactly two error lines:

1. B1 — resume boundary: `Parallel kickoff invocation must structurally name the manifest, plan-home branch, and atomic-execution resume boundary.`
2. B2 — integrity field name: `Parallel kickoff integrity line is invalid: parallel/bugfix-batch-plan head commit: 4a7f1c9e2b8d3a6f0c5e91b47d28a3f6c0e5b91d`

Both expected errors are present and the exit code is 1, so the reproduction satisfies the `[expect-fail]` acceptance criterion.

## Raw Validator Output

```
Parallel kickoff invocation must structurally name the manifest, plan-home branch, and atomic-execution resume boundary.
Parallel kickoff integrity line is invalid: parallel/bugfix-batch-plan head commit: 4a7f1c9e2b8d3a6f0c5e91b47d28a3f6c0e5b91d
```

## Root-Cause Attribution

- **Error 1 (B1).** The template's resume sentence begins `Each item` (`.claude/skills/parallel-plan/SKILL.md:369-371`). `RESUME_RE` at `scripts/dev_tools/parallel_kickoff_contract.py:72-77` admits only `(?:Every item|items)`, so `resume_match` is `None` and the combined manifest/branch/resume error fires even though the manifest path and plan-home branch are both present and correct in the rendered document. `spec.md:451` states the requirement as "each item", so the matcher is the side that deviates from the governing spec.
- **Error 2 (B2).** The template's integrity commit line is `parallel/<slug>-plan head commit: <hex>` (`.claude/skills/parallel-plan/SKILL.md:381`). `INTEGRITY_COMMIT_RE` at `scripts/dev_tools/_parallel_kickoff_tables.py:28-30` requires the field name `planning_commit:`, so `parse_integrity` classifies the line as neither the commit field nor a table row and reports it invalid. `spec.md:459` fixes the field NAME as `planning_commit`, so the template is the side that deviates.

## Substitution Values Used

| Placeholder | Substituted value |
|---|---|
| `<slug>` | `bugfix-batch` |
| `<iso8601>` | `2026-08-08T15:15:00Z` |
| `<hex>` | `4a7f1c9e2b8d3a6f0c5e91b47d28a3f6c0e5b91d` (40 hex characters) |
| six-cell `\| ... \|` row | `\| 443 \| docs/features/active/2026-08-07-parallel-planner-surface-443 \| 0 \| C3 \| feature/parallel-planner-surface-443 \| docs/features/active/2026-08-07-parallel-planner-surface-443/plan.md \|` |
| two-cell `\| ... \|` row | `\| docs/features/active/2026-08-07-parallel-planner-surface-443/plan.md \| 9f2e4c7a1b5d8e0f3a6c9b2d5e8f1a4c7b0d3e6f \|` |

## Full Rendered Document

The document was written to the gitignored path `artifacts/orchestration/parallel-kickoff-remediation-verification.md`.

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

parallel/bugfix-batch-plan head commit: 4a7f1c9e2b8d3a6f0c5e91b47d28a3f6c0e5b91d

| plan-path | plan-hash |
| --- | --- |
| docs/features/active/2026-08-07-parallel-planner-surface-443/plan.md | 9f2e4c7a1b5d8e0f3a6c9b2d5e8f1a4c7b0d3e6f |
```

## Pass-After Counterpart

The pass-after runs are recorded by [P5-T1] and [P5-T2]; the correlation record is written by [P5-T4].
