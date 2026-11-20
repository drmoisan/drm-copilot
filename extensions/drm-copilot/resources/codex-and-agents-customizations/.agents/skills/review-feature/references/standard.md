# Gold Standard: review-feature

## Objective

Invoke the feature-review worker to produce feature-audit artifacts for an active feature folder. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Inputs: The skill takes the active feature folder path and the existing implementation, evidence and requirement files under the same folder.
- **OB-2** Output Paths: When the active review scope is a selected version folder such as `.dev/active/<feature>/v2/`, write the review artifacts into that selected version folder rather than the parent feature root.
- **OB-3** Worker Routing: The review is routed to the `feature-review` worker.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Output Paths, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Worker Routing, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-1, OB-2, OB-3) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
