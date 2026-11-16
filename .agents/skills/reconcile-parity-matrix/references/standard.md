# Gold Standard: reconcile-parity-matrix

## Objective

Reconcile selected feature and client parity against pinned source facts and target evidence. Use when asked to update a parity matrix or identify migration gaps without changing approved decisions. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Inputs: These are human-facing workflow selections, not additional service-request fields.
- **OB-2** Routing: Logical role: `requirements-reconciler`.
- **OB-3** Exact output boundary: These rows are maximum workflow caps, not instructions to create every kind.
- **OB-4** Prerequisites: Missing or malformed configuration blocks delegation.
- **OB-5** Step-by-Step Workflows: Validate the explicit inputs and selected configuration.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Routing, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Exact output boundary, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Prerequisites, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Step-by-Step Workflows, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
