# docs-surface-analyzers-python-config (Issue #1022)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/docs-surface-analyzers-python-config/ (Issue #1022)
- Parent epic: #1019 (documentation-estate-tooling, wave 1, complexity band C4)
- Depends on: #1020 (docs-profile-and-artifact-schemas)

- Issue: #1022
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1022
- Last Updated: 2026-10-30
## Problem / Why

The documentation-estate-tooling epic (#1019) needs an inventory of the documentable surface of a
destination repository before a coverage ledger, parity matrix or reference pages can be built. Issue
#1020 defines the surface element model, the analyzer protocol and registry table, and the
`surface-inventory-snapshot` schema, but no analyzer yet produces surface elements. Without analyzers
for Python command-line interfaces, HTTP routes, public APIs, configuration files and architecture, the
`dev.docs.inventory` command cannot report what a Python repository exposes, and documentation drift
must be counted by hand.

## Proposed Behavior

Add read-only, lexical, bounded and deterministic analyzers under
`packages/docs-runtime/src/drm_copilot_docs/analyzers/`, and the `dev.docs.inventory` command:

- `python_cli.py`: argparse, Click and Typer commands and options, extracted with Python `ast` parsing
  and no execution.
- `python_http.py`: FastAPI and Flask route decorators.
- `python_public_api.py`: `__all__` and public top-level definitions.
- `config_files.py`: `pyproject.toml` scripts and tool tables, `.env` keys without values, JSON Schema
  properties and YAML keys.
- `architecture.py`: packages, modules and dependency edges, reusing
  `drm_copilot_discovery.analyzer.dependency_python`.
- `snapshot_builder.py`: a revision-pinned snapshot using discovery input capture.
- `packages/docs-runtime/src/drm_copilot_docs/cli_inventory.py`: `dev.docs.inventory --analyzer <id>`.

Pure analyzer cores take in-memory path-to-content mappings; I/O stays in the thin CLI module. The
analyzers reuse `drm_copilot_discovery` analyzer input capture, finding identities and
`dependency_python` as a library without changing discovery behavior. Registry entries are appended
to the `analyzer_contract.py` registry table created by #1020, and the `dev.docs.inventory` script is
appended to the root `pyproject.toml`.

## Acceptance Criteria (early draft)

- [ ] Each analyzer emits the expected elements for an in-memory fixture covering argparse, Click, Typer, FastAPI, Flask, `pyproject.toml`, `.env`, JSON Schema and YAML inputs.
- [ ] Re-running over identical bytes produces a byte-identical snapshot (property test).
- [ ] No configuration value is exported; only keys and shapes.
- [ ] An input above the size bound yields a diagnostic, not a partial result.
- [ ] The snapshot validates against `surface-inventory-snapshot.schema.json` and records the captured input digests.
- [ ] Line coverage >= 85% and branch coverage >= 75% for the analyzers.

## Constraints & Risks

- The naming contract in the epic manifest `## Shared Design` section is fixed; this feature may not
  change it.
- Analyzers never execute, compile or install consumer code; dynamic registration is not visible to a
  lexical analyzer and surfaces as a diagnostic.
- Execution depends on #1020 merging into the epic integration branch; this feature builds on the
  contracts #1020 plans and does not re-create them.
- `analyzer_contract.py` is also extended by the TypeScript/.NET analyzer feature; edits to it are
  append-only. The root `pyproject.toml` scripts table is shared with sibling features and is edited
  append-only.
- No test creates temporary files.
- Property tests use deterministic `itertools` enumerations, because `hypothesis` is not an approved
  dependency.

## Test Conditions to Consider

- [ ] Unit coverage areas: each analyzer, snapshot builder, size bound, value redaction, CLI.
- [ ] Integration scenarios: snapshot validates against the inventory snapshot schema.
- [ ] CLI/API examples: `dev.docs.inventory --analyzer <id>`.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/docs-surface-analyzers-python-config/` folder from the template
