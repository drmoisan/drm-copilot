# Gold Standard: pr-context-artifacts

## Objective

PR context artifact locations and refresh rules. Use when generating, reading, or inlining pr_context summary/appendix artifacts. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Canonical Artifact Locations: Summary: `artifacts/pr_context.summary.txt`.
- **OB-2** Refresh Rule: If the artifacts are missing or stale relative to the current branch state, re-generate them using the repo’s PR context collector.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Canonical Artifact Locations, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Refresh Rule, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-1, OB-2) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
