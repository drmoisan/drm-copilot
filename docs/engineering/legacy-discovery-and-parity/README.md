# Legacy Discovery and Parity

The `legacy-discovery-and-parity` capability is a reusable, domain-neutral framework for
agentic discovery of legacy-system behavior and source-to-target parity definition. A
repository migrating a legacy application to a modern architecture uses it to inventory
current behavior, characterize runtime behavior, define source-to-target parity, reconcile
unspecified or contradictory behavior into product decisions, and generate acceptance
specifications, all through validated, versioned artifacts whose meaning is owned by one
installed Python engine and whose authority is verified by native host hooks.

This directory is the capability-level documentation. A consumer installs the three
published packages (the Python wheel, the VS Code extension or the standalone MCP server,
and the native customization bundle for its host) and operates the full capability without
a checkout of this repository. Each page below covers one area end to end.

## Domain-Neutrality Invariant

**Invariant: the framework contains no domain-specific behavior.** All domain specificity
(the system under discovery, its repositories, clients, platforms, modes, analyzers,
artifact locations and completion gates) is supplied at runtime through the version 2
domain profile described in [`domain-profile.md`](domain-profile.md). Consumer names appear
only in the separated example documents under `examples/` (added with the publication
handoff) and in the feature delivery records; they are never framework behavior.

## Ownership

| Owner | Owns |
|---|---|
| Framework (this repository) | The Python engine and its staged schemas and templates, the TypeScript gateway client in the extension and the standalone MCP server, the native hooks and shared PowerShell helpers for Claude Code, Codex and GitHub Copilot, the four discovery roles, nine workflows and seven aliases, and this documentation. |
| Consumer repository | Its domain profile, scope, inventory snapshots, feature contracts, coverage ledger, runtime characterization, evidence, unspecified-behavior and product-decision records, source snapshots, implementation records, parity matrix, acceptance specifications and reports; its target architecture and implementation tests. |

Framework output never asserts that a consumer's implementation passes; see
[`artifacts-and-schemas.md`](artifacts-and-schemas.md) for the criteria-versus-test-pass
separation.

## Audience

- **Consumer-repository engineer**: read [`workflow.md`](workflow.md) for the end-to-end
  sequence, [`domain-profile.md`](domain-profile.md) to author the profile,
  [`running-the-workflow.md`](running-the-workflow.md) and
  [`cli-reference.md`](cli-reference.md) to invoke the capability, and
  [`artifacts-and-schemas.md`](artifacts-and-schemas.md) for what is produced and
  validated. [`consumer-onboarding.md`](consumer-onboarding.md) covers local setup.
- **Host or platform operator**: read [`architecture.md`](architecture.md) and
  [`enforcement.md`](enforcement.md) for the engine, gateway, protected authority store and
  the native controls each host supports.
- **Framework maintainer**: read [`maintainer-guide.md`](maintainer-guide.md) for how the
  bundles, packages and mirrors are regenerated and verified, and
  [`migration.md`](migration.md) for the version 1 to version 2 path.

## Topic Pages

| Page | Covers |
|---|---|
| [`architecture.md`](architecture.md) | The reusable architecture: Python engine, TypeScript gateway client, native hooks, protected authority store, and the host flows (no runtime, manual, combined, separate, multi-client). |
| [`workflow.md`](workflow.md) | The four constrained roles, nine canonical workflows and seven aliases, and the end-to-end sequence from initialization to acceptance specifications. |
| [`domain-profile.md`](domain-profile.md) | The version 2 domain profile: fields, states, completion gates, analyzers and the planning prerequisite. |
| [`artifacts-and-schemas.md`](artifacts-and-schemas.md) | The version 2 artifact kinds, status and version semantics, frozen version 1 schemas, validation modes, receipts, evidence pins and safe extensions. |
| [`analyzers.md`](analyzers.md) | The repository, .NET and optional Office/VSTO analyzers, what they observe and their limits. |
| [`running-the-workflow.md`](running-the-workflow.md) | The three invocation surfaces (CLI, MCP tools, VS Code commands) and the gateway contract behind them. |
| [`cli-reference.md`](cli-reference.md) | Every console command, MCP tool, VS Code command and gateway operation. |
| [`enforcement.md`](enforcement.md) | The native controls per host, the protected receipts they verify, inactive compatibility and the planning gate. |
| [`migration.md`](migration.md) | Migrating version 1 artifacts and workspaces to version 2, snapshot transport and inventory import. |
| [`consumer-onboarding.md`](consumer-onboarding.md) | Installing the packages, pushing down the native customizations, initializing and activating a workspace. |
| [`maintainer-guide.md`](maintainer-guide.md) | Regenerating bundles, building the wheel and packages, mirrors and manifests, and the tests that pin them. |
| `examples/` | Separated consumer examples (added with the publication handoff); the only place consumer names appear. |

## Capability Provenance

This capability was delivered by issue #980 and its predecessors. The feature folder under
`docs/features/` carries the plan, evidence and traceability for that delivery; this
documentation set is the durable capability-level layer and links to code, schema and
template paths rather than to feature folders.
