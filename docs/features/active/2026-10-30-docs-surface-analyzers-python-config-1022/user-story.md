# `2026-10-30-docs-surface-analyzers-python-config` — User Story

- Issue: #1022
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T16-46

## Story Statement

- As a documentation owner of a Python repository, I want `dev.docs.inventory` to list the command-line commands and options, HTTP routes, public symbols, configuration keys and architecture components my repository exposes, so that I can measure documentation coverage against an inventory instead of counting surface by hand.
- As a maintainer who runs the inventory in CI, I want the snapshot to be byte-identical for identical inputs and pinned to a revision and to input digests, so that a change in the snapshot always means a change in the repository surface.
- As a security-conscious repository owner, I want the inventory to record configuration keys and their shapes but never their values, and never to read a plain `.env` secrets file, so that running the inventory cannot leak secrets into an artifact.

## Problem / Why

The documentation-estate-tooling epic (#1019) needs an inventory of the documentable surface of a
destination repository before a coverage ledger, parity matrix or reference pages can be built. Issue
#1020 defines the surface element model, the analyzer protocol and registry table, and the
`surface-inventory-snapshot` schema, but no analyzer yet produces surface elements. Without analyzers
for Python command-line interfaces, HTTP routes, public APIs, configuration files and architecture, the
`dev.docs.inventory` command cannot report what a Python repository exposes, and documentation drift
must be counted by hand.

## Personas & Scenarios

- Persona: Documentation owner
  - Maintains reference and how-to pages for a Python service with a Click or Typer command-line
    interface, a FastAPI or Flask HTTP API and `pyproject.toml` tool configuration.
  - Cares about knowing which commands, options, routes and configuration keys have no page.
  - Constraint: cannot install or run the application in the documentation workflow; the inventory
    must work from source text alone.
  - Frustration: surface lists maintained by hand fall out of date after each release.
- Persona: CI maintainer
  - Owns the pipeline that will later compare snapshots between revisions (epic child 900008).
  - Cares about deterministic output, clear exit codes and bounded resource use.
  - Constraint: CI runs Python 3.10 on Linux; the inventory must not depend on the interpreter for
    TOML support or on unordered iteration.
- Scenario: First inventory of a repository
  - The documentation owner has a docs profile (from `dev.docs.init`) whose `surface_selection`
    names the source roots and element kinds.
  - They run `poetry run dev.docs.inventory --output build/inventory.json`.
  - The command reads the files under the source roots, skips excluded paths, does not read a plain
    `.env` file (reporting it as an information diagnostic), and runs the five registered analyzers.
  - A router whose prefix comes from a settings object appears as `GET <dynamic>/items/{item_id}`
    with a warning, so the owner sees the route and knows the prefix was not resolvable lexically.
  - The command writes a snapshot that validates against the inventory schema and exits 0, or 1 if
    a blocking diagnostic (for example a file with a syntax error or an input above 1 MiB) is present.
- Scenario: Narrowed run during review
  - The CI maintainer runs `dev.docs.inventory --analyzer python-cli --revision <full object id>`
    to inventory only the command-line surface at the checked-out commit.
  - If they name an analyzer that is not registered, or one whose element kinds the profile does not
    select, the command exits 2 and names the identifier.
  - Running the same command twice on the same commit with the same clock value produces identical
    bytes.

## Acceptance Criteria

- [ ] Running the five analyzers over an in-memory fixture covering the nine input families argparse, Click, Typer, FastAPI, Flask, `pyproject.toml`, `.env` (template-style), JSON Schema and YAML yields exactly the expected commands, options, routes, public symbols, configuration keys and architecture components.
- [ ] A Typer command without an explicit name appears under the function name with underscores converted to hyphens, and a command with an explicit name appears under that name.
- [ ] A route whose prefix cannot be resolved lexically still appears in the inventory with the literal `<dynamic>` prefix segment and a warning diagnostic, and other dynamic registrations appear as warning diagnostics rather than as missing output without explanation.
- [ ] Re-running the inventory over identical bytes, profile, revision and clock value produces a byte-identical snapshot (property test).
- [ ] No configuration value appears in the snapshot; only keys and shapes are recorded, and a plain `.env` file is never read or hashed and is reported by one information diagnostic naming its path.
- [ ] An input above the 1 MiB size bound yields a diagnostic and contributes no elements and no input digest, rather than a partial result.
- [ ] The snapshot validates against `surface-inventory-snapshot.schema.json` and records the SHA-256 digest and size of every captured input.
- [ ] `dev.docs.inventory --analyzer <id>` limits the run to the named analyzers, and an unregistered id or an id whose analyzer produces none of the profile's selected element kinds exits 2 with a message naming the id.
- [ ] `dev.docs.inventory` exits 0 with no blocking diagnostic, 1 with a blocking diagnostic or an invalid profile, 2 for an invocation error and 3 for a runtime failure.
- [ ] Line coverage >= 85% and branch coverage >= 75% for the analyzers and the `dev.docs.inventory` command module.

## Non-Goals

- Executing, importing or installing consumer code, or resolving surface that exists only at run
  time (plugin loading, settings-driven registration); such sites become diagnostics.
- TypeScript and .NET analyzers (epic child 900004), the coverage ledger (900005), reference page
  generation (900006), MCP tools (900007) and CI enforcement or surface deltas (900008).
- Class members as public symbols; module-to-module edges other than static `import` statements.
- Reading Git history or proving that working-copy bytes equal a revision; `--revision` is recorded
  as supplied.
- Capturing plain `.env` or other non-template env files, or exporting any configuration value.
- Recording the Python interpreter version in the snapshot.
- Adding dependencies (including a declared `tomli`), changing the #1020 contracts beyond the
  appended registry entries and script line, or changing discovery runtime behavior.
