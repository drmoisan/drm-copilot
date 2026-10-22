# End-to-End Discovery and Parity Workflow

The workflow is a fixed sequence of nine canonical workflows carried out by four constrained
roles. Every step reads the version 2 domain profile ([`domain-profile.md`](domain-profile.md))
and produces artifacts governed by the version 2 schemas
([`artifacts-and-schemas.md`](artifacts-and-schemas.md)). No step contains domain-specific
behavior and no step asserts that a consumer's implementation passes.

## Roles

| Role | Owns | Tools |
|---|---|---|
| `legacy-parity-analyst` | Source inventory, feature contracts, coverage ledger, parity matrix | `read_discovery_source`, `run_discovery_repo_inventory`, `create_discovery_artifact`, `update_discovery_artifact`, `link_discovery_evidence`, `finalize_discovery_agent` |
| `runtime-characterization-analyst` | Runtime characterization scenarios and their evidence | `read_discovery_source`, `create_discovery_artifact`, `update_discovery_artifact`, `link_discovery_evidence`, `finalize_discovery_agent` |
| `requirements-reconciler` | Unspecified behavior, product decisions, acceptance specifications | `read_discovery_source`, `update_discovery_artifact`, `link_discovery_evidence`, `run_discovery_scenario_generation`, `finalize_discovery_agent` |
| `migration-coverage-reviewer` | Coverage, validation and completion review | `read_discovery_source`, `validate_discovery_artifacts`, `run_discovery_report`, `finalize_discovery_agent` |

The canonical role contracts are `.github/agents/<role>.agent.md`; the Claude personas
`.claude/agents/<role>.md` and the Codex bases `.codex/agents/<role>.toml` (with the generated
`-c1`, `-c2`, `-c3`, `-c3-elevated` and `-c4` variants) are produced from them by the
deterministic conversion described in [`maintainer-guide.md`](maintainer-guide.md). A role
holds no Write grant: every artifact mutation flows through the controlled MCP tools, and
the native hooks in [`enforcement.md`](enforcement.md) attest its start, authorize each call
and validate its output.

## The nine canonical workflows

Each workflow is a skill (`.github/skills/<name>/SKILL.md`, mirrored to
`.claude/skills` and `.agents/skills`) that routes to exactly one role and names its exact
output boundary.

| Workflow | Role | Produces |
|---|---|---|
| `initialize-discovery-workspace` | migration-coverage-reviewer | The draft profile, scope and collection templates (`init`), then activation (`configure --activate`). |
| `inventory-legacy-system` | legacy-parity-analyst | `inventory-snapshot` records from the enabled analyzers; a confirmed `scope`. |
| `extract-feature-contract` | legacy-parity-analyst | `feature-contract` drafts and the `coverage-ledger` dispositions that link components to features. |
| `characterize-runtime-behavior` | runtime-characterization-analyst | `runtime-characterization-scenario` plans, observations, runs and `evidence-reference` links. |
| `reconcile-parity-matrix` | requirements-reconciler | The `parity-matrix` entries binding source contracts to target implementation records per dimension. |
| `review-discovery-coverage` | migration-coverage-reviewer | Validation in `discovery-complete` or `parity-complete` mode and the coverage, parity and completion reports. |
| `adjudicate-unspecified-behavior` | requirements-reconciler | `unspecified-behavior` records and the `product-decision` records that resolve them. |
| `generate-acceptance-scenarios` | requirements-reconciler | `acceptance-specification` artifacts (`legacy-characterization` or `target-acceptance`) rendered as Markdown or Gherkin. |
| `validate-discovery-artifacts` | migration-coverage-reviewer | A validation receipt for the selected mode; the only path that can satisfy a completion gate. |

## The seven aliases

`discovery-workflow`, `discovery-repo-inventory`, `discovery-coverage-ledger`,
`discovery-runtime-characterization`, `discovery-parity-matrix`,
`discovery-behavior-reconciliation` and `discovery-validate-artifacts` are thin dispatch
skills kept for compatibility. Each names the canonical workflows it dispatches to and
carries no procedure, tool list or authority of its own.

## Sequence

1. **Initialize and activate.** `init` writes the draft profile, scope and collections
   from the staged templates without overwriting existing files; the engineer completes
   the profile; `configure --activate` validates it, writes the workspace locator and the
   protected activation. Until activation every native hook treats the workspace as
   inactive and ordinary behavior applies.
2. **Inventory and scope.** The enabled analyzers produce inventory snapshots over the
   configured production and test roots; the scope is confirmed against them.
3. **Contracts and coverage.** Feature contracts are drafted from inventory and source
   reads; every component in scope receives a coverage disposition.
4. **Runtime characterization.** Scenarios are planned with explicit `unknown`
   expectations, executed under the profile's runtime capability, and recorded with
   evidence.
5. **Parity.** The parity matrix binds each required feature to the target's
   implementation records per client, platform, mode and dimension.
6. **Reconciliation.** Unspecified or contradictory behavior is recorded and resolved by
   approved product decisions; approvals are scoped and owned.
7. **Acceptance.** Acceptance specifications are generated only from verified source facts
   or approved decisions; unresolved criteria stay `pending`.
8. **Validation and completion.** `validate-all` in `discovery-complete` or
   `parity-complete` mode produces the receipt the completion gates and the planning gate
   verify; the completion report states what remains.

## Planning linkage

Implementation planning in a consumer repository is gated on discovery: the profile's
`completion_gates.planning_prerequisite` (`none`, `discovery-complete` or
`parity-complete`) names the validation receipt the native planning gate requires before an
atomic-planner or orchestrator delegation may start. See [`enforcement.md`](enforcement.md).
