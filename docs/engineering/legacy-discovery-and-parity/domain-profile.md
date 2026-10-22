# Authoring the Domain Profile

The version 2 domain profile (`$schema: urn:drm-copilot:discovery:2.0.0:domain-profile`,
`schemas/discovery/v2/domain-profile.schema.json`) is the single configuration contract
through which a consumer supplies all domain specificity. The engine treats every value as
consumer-owned data; it special-cases no path, repository, technology or name.

## Starting point

`dev.discovery.init` writes a draft profile from the staged template
(`docs/discovery/templates/v2/domain-profile.yaml`) to
`docs/migration/discovery/domain-profile.yaml`, together with a draft `scope`, the empty
`unspecified-behaviors` and `product-decisions` collections, and the empty
`coverage-ledger` and `parity-matrix`. Initialization never overwrites an existing file: it
reports `created`, `skipped` or `conflict` per path and supports `--dry-run`. The engineer
completes the draft, then `dev.discovery.configure --activate` validates it and records the
activation.

## Fields

| Field | Meaning |
|---|---|
| `profile_version` (const `2`), `schema_version` (`2.0.0`), `artifact_kind` | Version identity. |
| `profile_state` | `draft` while roots or identities are incomplete; `configured` once activation is permitted. A configured `modernization-target` or `combined` profile must name its related repositories and clients. |
| `system` | `id`, `name` and `role` (`legacy-source`, `modernization-target`, `combined`). |
| `repository` | `id`, `vcs: git`, `revision` and `revision_policy` (`pinned` or `working-tree-at-pin`); every artifact pins the revision it observed. |
| `production_roots`, `test_roots`, `project_entry_points`, `documentation_roots`, `evidence_roots` | Workspace-relative roots the analyzers, source reads and evidence links may touch; nothing outside them is read. |
| `repositories` | Related repositories (`legacy-source` or `modernization-target`) for the separate-repository flow. |
| `clients`, `required_platforms`, `required_modes`, `required_feature_dimensions` | The multi-client matrix every feature contract, parity entry and acceptance specification is assessed against. |
| `runtime` | `capability` (`none`, `manual`, `semi-automated`, `automated`) and `required_feature_ids`, the features that need runtime evidence. |
| `analyzers` | `enabled` identifiers (see [`analyzers.md`](analyzers.md)), `options`, `ignored_paths` and `extension_result_manifests` for separately produced inventories. |
| `excluded_paths` | Paths excluded from scope with a recorded rationale. |
| `artifacts` | The workspace-relative artifact root. |
| `completion_gates` | Eight boolean gates and the `planning_prerequisite`, below. |
| `decision_owners` | Who may approve product decisions; approvals name an owner from this list. |
| `extensions` | Consumer-owned extension data the engine preserves and never interprets. |

## Completion gates and the planning prerequisite

`completion_gates` holds `require_confirmed_scope`, `require_current_inventory`,
`require_all_dispositions`, `require_feature_evidence`, `require_acceptance_scenarios`,
`require_runtime_for_declared_features`, `block_on_unresolved_required_behavior` and
`require_approved_deviations`. The `discovery-complete` and `parity-complete` validation
modes evaluate these gates; a gate set to `false` records a deliberate waiver in the
completion report rather than a pass.

`planning_prerequisite` takes `none`, `discovery-complete` (the template default) or
`parity-complete`. It names the validation mode whose current, passing receipt the native
planning gate requires before an implementation planner or orchestrator may be delegated in
this workspace ([`enforcement.md`](enforcement.md)). `none` records that planning is not
gated on discovery; it is still read from the profile the activation binds, so it cannot be
changed by editing a copy.

## Authoring guidance

- Keep every root inside the repository; the path policy rejects absolute paths, parent
  references and symbolic links that resolve outside the workspace.
- Enable only the analyzers the stack needs; `office-vsto` is an optional adapter that
  runs only when listed.
- Pin `repository.revision` when artifacts must be reproducible across machines; use
  `working-tree-at-pin` while the inventory is being refreshed.
- Treat `profile_state: configured` as a commitment: activation binds the profile bytes, and
  a changed profile fails every receipt check until it is re-validated.

## Version 1 profiles

Version 1 profiles (`profile_version: 1`, `legacy_source.root`, `target.root`,
`technology_stack.legacy`, `artifacts.root`) remain readable through the compatibility
import and are converted by `dev.discovery.migrate`; see [`migration.md`](migration.md).
