# Gold Standard: adjudicate-unspecified-behavior

## Objective

Draft traceable proposals for unresolved behavior and separate them from root-owned approval. Use when asked to adjudicate contradictory or undocumented behavior and derive explicitly requested acceptance criteria. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Inputs: The skill takes explicit human-facing workflow selections rather than additional service-request fields, namely the required `profile`, `unresolved_ids`, `interpretations`, `evidence_refs` and `decision_owner` and the optional `approval_record` and `derived_acceptance`, and neither an omitted input nor a profile root creates authority.
- **OB-2** Routing: The root prepares and launches the `requirements-reconciler` logical role, which the skill never auto-launches, the existing resolver selects the exact deployment, model, effort and profile hash under the existing C1-C4 ceiling and execution context, the skill chooses no model, does not self-launch, creates no other scheduler and promotes no ordinary discovery action into an issue, and its production-write count is zero.
- **OB-3** Exact output boundary: Only the prepared required outputs may be created or replaced, and the artifact kinds `product-decision`, `product-decision-collection`, `unspecified-behavior`, `unspecified-behavior-collection`, `acceptance-specification`, `acceptance-view` and `required-output-manifest` are maximum workflow caps rather than instructions to create every kind, with each prepared output row binding `artifact_kind`, `id`, `path`, `format` and `expected_sha256` and the profile keys serving as maximum configured locations, not write grants.
- **OB-4** Prerequisites: Missing or malformed configuration blocks delegation.
- **OB-5** Step-by-Step Workflows: Validate the explicit inputs and selected configuration.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Routing, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Exact output boundary, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Prerequisites, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Step-by-Step Workflows, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
