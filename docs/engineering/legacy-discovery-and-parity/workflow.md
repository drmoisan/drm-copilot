# End-to-End Discovery/Parity Workflow

This page describes the discovery/parity workflow as a single end-to-end sequence: what
happens from workspace initialization through validated artifacts to the terminal outputs
(rendered reports and generated acceptance scenarios). It summarizes the sequence at
capability level and links to each owning feature's own reference documentation instead
of restating command flags, hook I/O contracts, or parser internals.

See the [domain-neutrality invariant](README.md#domain-neutrality-invariant): every stage
below operates only on the domain profile's configuration; no stage contains
domain-specific behavior.

## The Seven-Stage Sequence

The workflow is a seven-stage pipeline, orchestrated end to end by the umbrella
`discovery-workflow` skill (`.claude/skills/discovery-workflow/SKILL.md`) and reachable
stage by stage through the CLI, MCP, and VS Code surfaces documented in
[`running-the-workflow.md`](running-the-workflow.md).

1. **Workspace initialization and profile load.** A consumer repository scaffolds a
   discovery workspace (`dev.discovery.init`) from the bundled init templates, then
   authors its domain profile as described in [`domain-profile.md`](domain-profile.md).
   Every later stage reads the domain profile to resolve the legacy source location, the
   target location, the technology stack, and the artifact output location; no stage
   hardcodes a domain-specific path or technology.
2. **Repository inventory.** The language-neutral repository/project inventory analyzer
   (`dev.discovery.inventory`) runs against the domain profile's source and target roots,
   plus stack-specific analyzers selected generically by the profile's declared technology
   stack (the .NET analyzer, `dev.discovery.dotnet`, and the VSTO/Office analyzer,
   `dev.discovery.vsto`). Driven by the `discovery-repo-inventory` skill.
3. **Coverage ledger.** Feature contracts and the coverage ledger are derived from the
   inventory output. Driven by the `discovery-coverage-ledger` skill
   (`.claude/skills/discovery-coverage-ledger/SKILL.md`).
4. **Runtime characterization.** Observed runtime behavior of the legacy application is
   captured as characterization scenarios with supporting evidence references. Driven by
   the `discovery-runtime-characterization` skill and the `runtime-characterization-analyst`
   agent persona.
5. **Parity matrix.** The parity matrix is built (or refreshed) from the feature contracts
   and runtime-characterization evidence, defining source-to-target parity. Driven by the
   `discovery-parity-matrix` skill and the `legacy-parity-analyst` agent persona.
6. **Behavior reconciliation.** Unspecified or contradictory behavior surfaced by the
   parity matrix is captured and reconciled into product-decision records. Driven by the
   `discovery-behavior-reconciliation` skill and the `requirements-reconciler` agent
   persona.
7. **Validation gate.** Every artifact produced by stages 2 through 6 is validated against
   its declared JSON schema (see [`artifacts-and-schemas.md`](artifacts-and-schemas.md))
   before the workflow is considered complete for that stage. Driven by the
   `discovery-validate-artifacts` skill; enforced automatically by the completion-gate
   hooks described in `artifacts-and-schemas.md`.

The `migration-coverage-reviewer` agent persona reviews the coverage ledger and parity
outputs across stages 3 through 6 rather than owning a single stage.

## Terminal Outputs

Once validated artifacts exist, the workflow produces two kinds of terminal output:

- **Reports rendered** from the validated artifacts: a coverage report, a parity report,
  and a completion report (see [`running-the-workflow.md`](running-the-workflow.md) for
  the exact commands).
- **Acceptance scenarios generated** from a feature contract, a parity matrix, and a
  runtime-characterization scenario together, producing executable acceptance scenarios
  for the migration effort.

## What This Page Does Not Cover

This page does not restate parser internals, hook input/output contracts, schema field
tables, or command flag references. Those are owned by the functional features that
deliver them and documented in their own reference docs, most of which live under
`docs/features/active/` at the time of writing (link-drift is possible once the epic
completes and folders move to `docs/features/completed/`; the topic pages below prefer
linking to durable code, schema, and template paths for that reason).
