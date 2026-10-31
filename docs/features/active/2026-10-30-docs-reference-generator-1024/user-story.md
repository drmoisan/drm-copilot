# `docs-reference-generator` — User Story

- Issue: #1024
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-31
- Parent: #1019 (epic `documentation-estate-tooling`, wave 2; depends on 1020 and 1021)
- Work Mode: full-feature
- Spec: `spec.md` version 0.4, the reconciliation revision against the current 1021 and 1020 contracts under owner decision P2 (authoritative for the command contract, `-Json` result, finding codes, marker grammar, merge algorithm, page-plan rules, module design and property-test table). The spec supersedes the Python design named in `issue.md` `## Proposed Behavior`.

## Story Statement

- As a consumer-repository maintainer, I want to run
  `Invoke-DocsCommand.ps1 -Command generate-reference` against my docs profile and surface
  inventory snapshot, using only PowerShell 7, so that reference pages for CLI commands, HTTP
  routes, configuration keys and public symbols are regenerated from the inventory instead of
  drifting from the code.
- As a documentation author, I want regeneration to replace only the marker-delimited generated
  blocks, so that the prose I write around them is never moved or overwritten, and I am told when a
  block is removed because its element no longer exists.
- As a reviewer, I want the command to print the planned changes and write nothing unless I pass
  `-Write`, so that I can inspect the diff before any page changes.
- As the maintainer of the downstream MCP tool `generate_docs_reference` (epic sibling 900007), I
  want a fixed option set, the shared 0/1/2/3 exit codes and a `-Json` envelope that validates
  against a committed schema, so that the tool can invoke the command and return structured results
  without parsing prose.

## Problem / Why

The documentation-estate-tooling epic inventories the documentable surface of a destination
repository (CLI commands and options, HTTP routes, configuration keys, public symbols and
architecture components) into a revision-pinned surface inventory snapshot. Reference pages for
that surface are still written by hand, so they drift from the code, and a regeneration step that
overwrote whole pages would destroy hand-written prose. One consumer repository measured the gap by
hand: a feature epic changed 138 `src/` files while only 4 of 79 documentation pages were edited.

Pushed-down helpers must be PowerShell or bash (owner directive), so the generator ships as
PowerShell modules under `.claude/lib/docs/` and needs no Python or Node.js runtime in the
destination repository.

## Personas & Scenarios

- Persona: consumer-repository maintainer
  - Owns a repository that has adopted the documentation-estate tooling, with a docs profile and a
    surface inventory snapshot produced by the `inventory` subcommand.
  - Cares about reference pages that match the current surface and pass the `check` subcommand.
  - Constraints: receives the docs lib through the Claude push-down; needs PowerShell 7.4; must
    link new reference pages from an entry page; owns the profile's owners, audiences and directory
    modes.
  - Goals: one deterministic command whose output does not change when nothing changed.
    Frustrations: hand-maintained reference pages that fall behind the code.
- Persona: documentation author
  - Writes explanatory prose, examples and caveats around reference entries.
  - Cares that regeneration never deletes or reorders that prose.
  - Constraints: must not edit inside generated blocks, because those lines are replaced.
- Persona: downstream MCP tool maintainer (900007)
  - Wraps the command as `generate_docs_reference`, launching
    `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command generate-reference -Json`
    and reading exactly one envelope from stdout.
  - Cares that options, exit codes, finding codes and `result` keys (exactly `mode`,
    `output_directory`, `pages`, `summary`, `unrendered`) are fixed and that the envelope
    validates against `schemas/docs/v1/docs-command-envelope.schema.json`.
- Scenario: first generation
  - The maintainer runs the command. The profile names `docs/reference` as the reference
    directory. The command exits 0, lists `create docs/reference/cli-reference.md` and the other
    family pages with diff hunks, prints a note that each new page must be linked from an entry
    page, and ends with `dry run, nothing written`.
  - The maintainer runs the command again with `-Write`; the pages are created, the maintainer
    links them from `docs/README.md`, and `-Command check` reports zero findings.
- Scenario: regeneration after a surface change
  - A command option is removed and a new HTTP route is added. The author has added prose between
    two generated blocks on the CLI page.
  - A dry run shows the option's block removed (with a `REFERENCE_BLOCK_REMOVED` finding) and the
    new route block added to the HTTP page; the author's prose does not appear in any hunk.
  - `-Write` applies the changes; a second run reports every page as `none`.
- Scenario: protected failure
  - An author accidentally deletes an end marker. The command reports
    `REFERENCE_MARKER_UNBALANCED` naming the page and line, marks that page `blocked`, exits 1, and
    writes nothing, so no prose is lost.
- Scenario: concurrent edit
  - A page changes on disk between planning and writing. The command reports
    `REFERENCE_WRITE_CONFLICT` for that page, writes no later page, and exits 1.

## Acceptance Criteria

Pester criteria run locally through `Invoke-PoshQCTest` and in CI under the required check
`poshqc / PowerShell QC` (shards on `windows-latest`).

- [ ] Rendering the same snapshot twice is byte-identical, including under a shuffled snapshot element order (seeded Pester property test over seeds `11, 23, 47, 101, 211`, plus a command-level test comparing written page texts and `-Json` envelope bytes; `poshqc / PowerShell QC`).
- [ ] Prose outside generated markers is preserved across regeneration: a seeded property test on `Merge-DocsReferenceBlock` shows that lines outside blocks keep their relative order, prose segments stay byte-identical when the identifier set is unchanged, and a second merge changes nothing (`poshqc / PowerShell QC`).
- [ ] A removed element's block is removed and reported: its identifier appears in `result.pages[].blocks.removed` and one `REFERENCE_BLOCK_REMOVED` info finding names it in `related_ids` (Pester, `poshqc / PowerShell QC`).
- [ ] Every generated page passes the 1021 `check` subcommand with zero findings, for new pages and after regeneration over pages with author prose (Pester integration test with an in-memory context and an entry page linking each generated page; `poshqc / PowerShell QC`).
- [ ] Emitted front matter is `---`, one `<key>: <JSON value>` line per field, `---`, and validates against the 1021 page-metadata schema (`urn:drm-copilot:docs:1.0.0:page-metadata`) through 1021 `Test-DocsPageFrontMatter` with the composed schema set (through `Get-DocsPageComposedSchemaSet` when 1021 uses its own schema gate), with no `owner`, `audience`, `last_reviewed` or `surface_refs` pattern pinned by 1024, and valid existing `owner`, `audience`, `last_reviewed`, `title` and `extensions` values are preserved (Pester, `poshqc / PowerShell QC`).
- [ ] `-Json` output for dry-run, write, exit-1, exit-2 and exit-3 runs validates against `schemas/docs/v1/docs-command-envelope.schema.json` and has the keys `command`, `exit_code`, `findings`, `ok`, `result` (Pester, `poshqc / PowerShell QC`).
- [ ] Without `-Write` nothing is written and the planned changes are printed: the in-memory context records no write, the exit code is 0, text output shows each page line and diff hunks, and the `-Json` result has `mode` `dry-run` with status `planned` (Pester, `poshqc / PowerShell QC`).
- [ ] With `-Write`, changed pages are written only through the command context's `WriteText` in ordinal path order, and an immediate second run writes nothing and reports action `none` for every page (Pester, `poshqc / PowerShell QC`).
- [ ] A write conflict stops writing at that page with status `conflict`, gives later pages `not-attempted`, and exits 1 with `REFERENCE_WRITE_CONFLICT`; a write exception exits 3 with `REFERENCE_WRITE_FAILED` and a null result (Pester, `poshqc / PowerShell QC`).
- [ ] Usage errors exit 2 with only `DOCS_CLI_ARGUMENTS`; an absent profile or snapshot exits 1 (`DOCS_PROFILE_MISSING`, `REFERENCE_SNAPSHOT_MISSING`); a read failure other than absence exits 3 with only `DOCS_CLI_RUNTIME`; any `error` finding exits 1 with no write (Pester, `poshqc / PowerShell QC`).
- [ ] A marker anomaly (malformed, duplicate, unbalanced, mismatched, inside front matter) or an unclosed fence blocks only the affected page with the code listed in the spec's finding-code catalog (Pester, `poshqc / PowerShell QC`).
- [ ] Each public pure function has a seeded property-style Pester test, explicitly including `Resolve-DocsReferenceOutputDirectory`, `Get-DocsReferenceCandidatePagePath`, `Format-DocsReferenceSourceLine`, `Split-DocsReferenceFrontMatter`, `ConvertFrom-DocsReferencePageText` and `Get-DocsReferenceReportLine`, with the seed in the test name (`poshqc / PowerShell QC`).
- [ ] Generated pages are the fixed family pages `cli-reference.md`, `http-reference.md`, `config-reference.md` and `api-reference.md`; `architecture-component` elements are counted, not rendered; no index page is generated (Pester, `poshqc / PowerShell QC`).
- [ ] No rendered heading begins, case-insensitively, with `how to ` or `step <n>` (the headings 1021 reports on a reference page as `DOCS_PAGE_MODE_INSTRUCTION_HEADING`), and every marker is a standalone line with blank lines inside and outside the block (Pester, `poshqc / PowerShell QC`).
- [ ] Each new `DocsReference*.psm1` module and the edited `Invoke-DocsCommand.ps1` are byte-identical to their push-down copies, each new module is listed in the Claude `core.json`, and the existing push-down contract tests pass unmodified.
- [ ] No Python or TypeScript file is added or modified, and no new test creates a temporary file.
- [ ] Pester line coverage is at least 85% for each new module under `.claude/lib/docs/`, with no production file excluded from measurement.

## Non-Goals

- A drift-check mode (900008 reads the dry-run result instead).
- A generated index page or a reserved generated-block identifier; consumers link pages from their
  own entry page.
- Rendering `architecture-component` elements.
- Changes to the 1020 or 1021 schemas or modules (contract needs are routed as coordination
  items).
- The MCP tool itself (900007).
- Running an external Markdown linter or Vale.
- Any Python or TypeScript code.
