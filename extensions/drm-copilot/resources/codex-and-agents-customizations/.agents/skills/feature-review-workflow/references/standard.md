# Gold Standard: feature-review-workflow

## Objective

Feature-branch review workflow for base-branch resolution, PR-context refresh, active feature folder selection, review artifact generation, validator gates, acceptance-criteria check-off, and remediation triggers. Use when authoring or executing PR-style feature reviews. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Required Shared Skills: `policy-compliance-order`.
- **OB-2** Role: Review a feature branch relative to the correct base branch.
- **OB-3** Workflow Contract: Treat the review as a feature-vs-base audit, not an isolated file inspection.
- **OB-4** Policy Rules: If the branch diff modifies any path matching `.github/workflows/`, `scripts/benchmarks/`, or `.github/actions/`, the policy audit emits a Blocking finding unless evidence of a green workflow run against the branch head is present in the remediation inputs.
- **OB-5** Ordered Procedure: Use the supplied base branch when it is present.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Required Shared Skills, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Role, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Workflow Contract, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Policy Rules, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Ordered Procedure, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
