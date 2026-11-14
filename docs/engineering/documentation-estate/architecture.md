# Documentation Estate Architecture

This page describes how the documentation-estate helpers are organized. It is written for
contributors who change the tooling.

## Helper Root and Entry Script

All helpers live under `.claude/lib/docs/` and are PowerShell modules that require PowerShell 7.4
or later. The single entry script is `.claude/lib/docs/Invoke-DocsCommand.ps1`. Its dispatch table,
returned by `Get-DocsCommandTable`, has one row per subcommand: the row names the subcommand, the
module and command function that implement it, and the options the subcommand accepts (`value`,
`multi` or `switch`). The entry script imports a row's module only when that row is selected.

`Invoke-DocsCommandCli` parses the arguments, runs the command function and returns the exit code,
standard output and standard error. The top-level body of the entry script runs only when the
script is not dot-sourced, so tests dot-source it and call `Invoke-DocsCommandCli` in process.

## Command Context

Every subcommand reads and writes through one command context object. Its members are
`RepositoryRoot`, `ReadText`, `ReadBytes`, `TestFile`, `ListFile`, `WriteText`, `UtcNow` and
`InvokeProcess`, plus `ResolveRevision` and `ReadRevisionText` for revision-aware commands. The real
context reads and writes under the repository root; tests pass an in-memory context. The only
filesystem write primitive is `Write-DocsFileText`, which the real `WriteText` member calls, so no
module writes a file directly.

## Schemas

The artifact schemas are published under `schemas/docs/v1/` with a byte-identical runtime copy
under `.claude/lib/docs/schemas/v1/`: the docs profile, the surface inventory snapshot, the coverage
ledger, the parity matrix, the evidence pins, the validation receipt, page metadata, the shared
definitions, and the `-Json` command envelope (`docs-command-envelope.schema.json`).

## Analyzers

`inventory` runs the analyzers registered in `.claude/lib/docs/DocsAnalyzerRegistry.psm1`. The
registry has a scanner provider table and a native provider table.

- Scanner analyzers (PowerShell, lexical, no process): `python-cli`, `python-http`,
  `python-public-api`, `config-files`, `python-architecture`, `typescript-cli`, `typescript-http`,
  `typescript-exports`, `dotnet-http`, `dotnet-config`, `dotnet-public-api` and `extension-import`.
- Native analyzers (the optional python pack, run through `.claude/lib/docs/python/`):
  `python-cli`, `python-http`, `python-public-api` and `python-architecture`.

Every snapshot element and every ledger entry carries `analysis_method`, with value `native` when
the native Python analyzer found the element and `scanner` when the PowerShell scanner found it.
`inventory -AnalysisMethod` selects `auto` (the default: native when available, otherwise
scanner), `native` or `scanner`. Analyzers read source text only; none executes, compiles or
installs the code it reads.

## Element Identity and the Declaration-Lines Digest

An element is identified by its kind, path and declaration. Each element also records the line
range of its declaration and `source_sha256`, the digest of those lines. When a line inside the
range changes while the declaration stays the same, the identifier is unchanged and the digest
changes, which is how a page that documents the element becomes stale.

## Ledger, Parity Matrix, Evidence Pins and Receipt

- The coverage ledger records one disposition per element (`documented`, `excluded` or
  `deferred`) and the pages bound to it.
- The parity matrix records, per element and page, the state of each parity dimension
  (`exists`, `accurate`, `example_present`, `owner_assigned`, `diataxis_mode`).
- An evidence pin records the element digest and revision at which a page was confirmed. A pin
  whose element digest no longer matches makes the page stale (`DOCS_STALE_PAGE`, status
  `digest-changed`).
- `update-ledger` is the only command that changes these three artifacts.
- `validate` checks the artifacts in one of four modes (`profile`, `ledger`, `matrix`,
  `docs-complete`). In `docs-complete` mode it applies the completion gates of the profile and
  returns a validation receipt whose `validation_result` is `pass` or `fail`; `-WriteReceipt`
  persists it.

## Generated Blocks

`generate-reference` writes reference pages from the inventory snapshot. Generated content sits
between the marker lines `<!-- docs:generated:start id=<element-id> -->` and
`<!-- docs:generated:end id=<element-id> -->`; prose outside the markers is preserved when the pages
are regenerated, and regeneration from the same snapshot is byte-identical.

## MCP Wrappers

Six docs MCP tools wrap the subcommands that agents call: `run_docs_check`, `run_docs_inventory`,
`run_docs_coverage`, `update_docs_ledger`, `generate_docs_reference` and `validate_docs_artifacts`.
They run the workspace's `Invoke-DocsCommand.ps1 -Json` and return its envelope. Their definitions
are in `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts`.

## Opt-In Hook

`.claude/hooks/enforce-docs-complete-gate.ps1` is a PreToolUse hook that denies a `gh pr merge` of
an epic integration branch into `main` when the docs profile sets
`completion_gates.integration_pr_gate.enabled` to `true` and the persisted `docs-complete` receipt
does not pass at the pull request head revision. Its deny reasons start with
`DOCS_COMPLETE_GATE_BLOCKED:`. With no profile, or with the key not set to `true`, the hook allows
every command. It is a policy-level control, not a security boundary.
