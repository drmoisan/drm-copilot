# Gold Standard: epic-orchestrate

## Objective

Execute a manually authored multi-feature epic through deterministic waves, isolated worktrees, integration-branch fan-in, and a final integration PR. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Early Dependent Starts (early_start): This section applies only to a feature whose manifest entry carries `early_start_on`.
- **OB-2** Cross-Epic Dependencies (cross_epic_depends_on): This section applies only when a feature of the manifest carries `cross_epic_depends_on` (issue.
- **OB-3** Worktree Cleanup: After the child merge SHA is recorded and the epic checkpoint mirrors `merge_status: "merged"`, with the child's `pr_number` and `merge_commit_sha` recorded in the matching `features[]` entry, remove its worktree.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Early Dependent Starts (early_start), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Cross-Epic Dependencies (cross_epic_depends_on), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Worktree Cleanup, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-1, OB-2, OB-3) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
