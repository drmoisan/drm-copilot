# `2026-10-30-docs-surface-analyzers-python-config` — User Story

- Issue: #1022
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T22-55

## Revision Note

This is the PowerShell re-preparation of issue #1022 under owner decision D1. The Python package
design (a `dev.docs.inventory` Poetry console script, a `cli_inventory.py` module, Python analyzer
modules and Pytest suites) is withdrawn. The inventory is now the `inventory` subcommand of
`.claude/lib/docs/Invoke-DocsCommand.ps1`, implemented as PowerShell text scanners that need
PowerShell 7.4 only. The design is stated in `spec.md` of this folder.

## Story Statement

- As a documentation owner of a Python repository, I want `Invoke-DocsCommand.ps1 -Command inventory` to list the command-line commands and options, HTTP routes, public symbols, configuration keys and architecture components my repository exposes, so that I can measure documentation coverage against an inventory instead of counting surface by hand.
- As a maintainer who runs the inventory in CI, I want the snapshot to be byte-identical for identical inputs, pinned to a revision and to input digests, and to need no Python or Node.js runtime, so that a change in the snapshot always means a change in the repository surface and the check runs wherever PowerShell 7.4 runs.
- As a security-conscious repository owner, I want the inventory to record configuration keys and their shapes but never their values, and never to read a plain `.env` secrets file, so that running the inventory cannot leak secrets into an artifact.
- As the owner of the coverage ledger, I want every element to state that it was found by the scanner and to carry a digest of its own declaration lines, and I want the scanner's precision limit stated as a complete list, so that I can record the limit as a deferred entry with an owner and so that an edit elsewhere in a file does not mark unrelated pages stale.

## Problem / Why

The documentation-estate-tooling epic (#1019) needs an inventory of the documentable surface of a
destination repository before a coverage ledger, parity matrix or reference pages can be built.
Issue #1020 defines the surface element model, the analyzer registry, the command entry script and
the `surface-inventory-snapshot` schema, but no analyzer produces surface elements. Without
analyzers for Python command-line interfaces, HTTP routes, public APIs, configuration files and
architecture, the documentation tooling cannot report what a Python repository exposes, and
documentation drift must be counted by hand.

Pushed-down helpers must be PowerShell or bash (epic owner directive), so the analyzers are lexical
PowerShell scanners. They are the always-available baseline (D3); a Python-native analyzer
delivered later by 900011 may replace them for Python surfaces when the python pack is installed,
using the same identifiers and digests.

## Personas & Scenarios

- Persona: Documentation owner
  - Maintains reference and how-to pages for a Python service with a Click or Typer command-line
    interface, a FastAPI or Flask HTTP API and `pyproject.toml` tool configuration.
  - Cares about knowing which commands, options, routes and configuration keys have no page.
  - Constraint: cannot install or run the application in the documentation workflow; the inventory
    must work from source text alone.
  - Frustration: surface lists maintained by hand fall out of date after each release.
- Persona: CI maintainer
  - Owns the pipeline that compares snapshots between revisions (epic child 900008).
  - Cares about deterministic output, clear exit codes, a machine-readable `-Json` envelope and
    bounded resource use.
  - Constraint: the runner provides `pwsh`; no Python interpreter or Node.js runtime may be
    required.
- Persona: Coverage-ledger owner
  - Records a disposition for every element (epic child 1023).
  - Cares about knowing which elements a lexical scanner cannot see and about stable digests per
    declaration.
- Scenario: First inventory of a repository
  - The documentation owner has a docs profile (from `-Command init`) whose `surface_selection`
    names the source roots and element kinds.
  - They run `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command inventory -Write`.
  - The command lists the files under the source roots, skips excluded paths, does not read a plain
    `.env` file (reporting it with a warning diagnostic), and runs the five registered analyzers.
  - A router whose prefix comes from a settings object appears as `GET <dynamic>/items/{item_id}`
    with a diagnostic, so the owner sees the route and knows the prefix was not resolvable
    lexically.
  - The command writes a snapshot that validates against the inventory schema and exits 0, or 1 if
    a blocking diagnostic (for example an unterminated string or an input above 1 MiB) is present.
- Scenario: Narrowed run during review
  - The CI maintainer runs `... -Command inventory -Analyzer python-cli -Revision <full object id> -Json`
    to inventory only the command-line surface at the checked-out commit.
  - If they name an analyzer that is not registered, or one whose element kinds the profile does not
    select, the command exits 2 and the envelope names the identifier.
  - Running the same command twice on the same commit with the same clock value produces identical
    bytes.
- Scenario: Edit outside a declaration
  - A developer changes the body of a Click command function without changing its decorators or
    signature.
  - The command element's `source_sha256` is unchanged, so pages pinned to that command stay
    current; changing an option decorator changes that option's digest.

## Acceptance Criteria

- [ ] Running the five analyzers over in-memory fixtures covering the nine input families argparse, Click, Typer, FastAPI, Flask, `pyproject.toml`, `.env` (template-style), JSON Schema and YAML yields exactly the expected commands, options, routes, public symbols, configuration keys and architecture components, asserted by Pester suites under `tests/scripts/claude-lib/docs/`.
- [ ] A Typer command without an explicit name appears under its default name (function name lower-cased with underscores converted to hyphens), a command with an explicit name appears under that name, and an attached console script's name is the root of its command tree.
- [ ] A route whose prefix cannot be resolved lexically still appears in the inventory with the literal `<dynamic>` prefix segment and a diagnostic, and every other construct listed in the spec's `## Precision Limit` produces its named diagnostic rather than missing output without explanation.
- [ ] An input above the 1 MiB size bound, or a Python input containing a construct the lexer cannot classify, yields a diagnostic and contributes no elements, rather than a partial or guessed result.
- [ ] Re-running the inventory over identical bytes, profile, revision and clock value produces a byte-identical snapshot, proven by a seeded property test that prints its seed on failure.
- [ ] No configuration value appears in the snapshot; only keys and shapes are recorded, and a plain `.env` file is never read or hashed and is reported by an `env-file-not-captured` diagnostic naming its path.
- [ ] The snapshot validates against `surface-inventory-snapshot.schema.json` and records the SHA-256 digest and size of every captured input.
- [ ] Every element records `analysis_method: scanner`.
- [ ] An element's `source_sha256` changes when a line inside its declaration changes and does not change when a line outside its declaration changes or when only line endings change.
- [ ] `-Command inventory` exits 0 with no blocking diagnostic, 1 with a blocking diagnostic or an invalid profile, 2 for a usage error (including an unregistered `-Analyzer` identifier or one whose analyzer produces none of the profile's selected element kinds, named in the finding), and 3 for a runtime failure, and the `-Json` output of every exit path validates against `schemas/docs/v1/docs-command-envelope.schema.json`.
- [ ] Without `-Write` the command writes nothing; with `-Write` it writes only the snapshot at the profile's `artifact_paths.inventory_snapshot`.
- [ ] The analyzers and the `inventory` subcommand are registered only under the 1022 anchors of `DocsAnalyzerRegistry.psm1` and `Invoke-DocsCommand.ps1`, and every new file is copied byte-identically to the push-down tree and listed in `pack-manifests/core.json`.
- [ ] No file under `.claude/lib/docs/` invokes a Python or other interpreter (`enforcement-hooks-no-python-invocation.Tests.ps1` passes), and the feature adds no Python, TypeScript, hook, skill, agent or MCP file, as shown by the plan's artifact classification table.
- [ ] Pester line coverage is at least 85% for each new `.claude/lib/docs/` file, measured by the `poshqc / PowerShell QC shard` jobs on `windows-latest` and enforced by the required check `poshqc / PowerShell QC`.

## Non-Goals

- Executing, importing or installing consumer code, or resolving surface that exists only at run
  time (plugin loading, settings-driven registration, `getattr`-based registration); such sites
  become diagnostics or are listed as undetectable in the precision limit.
- The Python-native analyzer (900011), TypeScript and .NET analyzers (900004), the coverage ledger
  (1023), reference page generation (1024), MCP tools (900007) and CI enforcement or surface deltas
  (900008).
- External distribution dependencies and the import of an existing discovery inventory snapshot
  (deferred to the coordinator).
- Class members as public symbols; module-to-module edges other than static `import` statements.
- Reading Git history or proving that working-copy bytes equal a revision; `-Revision` is recorded
  as supplied.
- Capturing plain `.env` or other non-template env files, or exporting any configuration value.
- Any Python, TypeScript or third-party PowerShell module, or any change to 1020 contracts beyond
  the anchored registry and dispatch rows and the `core.json` append.
