# `docs-reference-generator` — User Story

- Issue: #1024
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30
- Parent: #1019 (epic `documentation-estate-tooling`, wave 2)
- Work Mode: full-feature
- Spec: `spec.md` (authoritative for the command contract, result shape, finding codes, marker grammar, merge algorithm, page-plan rules, module inventory and acceptance criteria AC-01 to AC-22)

## Story Statement

- As a consumer-repository maintainer, I want to run
  `Invoke-DocsCommand.ps1 -Command generate-reference` against my docs profile and surface
  inventory snapshot, so that reference pages for CLI commands, HTTP routes, configuration keys and
  public symbols are regenerated from the inventory instead of drifting from the code, using only
  PowerShell 7 in my repository.
- As a documentation author, I want regeneration to replace only the marker-delimited generated
  blocks, so that the prose I write around them is never moved or overwritten, and I am told when a
  block is removed because its element no longer exists.
- As a reviewer, I want the command to print the planned changes and write nothing unless I pass
  `-Write`, so that I can inspect the diff before any page changes.
- As the maintainer of a downstream consumer of this command (the MCP tool
  `generate_docs_reference`, the authoring workflow, the onboarding template, or the enforcement
  workflow), I want a fixed option set, exit-code table and a `-Json` envelope that validates
  against a committed schema, so that I can invoke the command and read structured results without
  parsing prose.

## Problem / Why

The documentation-estate-tooling epic inventories the documentable surface of a destination
repository (CLI commands and options, HTTP routes, configuration keys, public symbols and
architecture components) into a revision-pinned surface inventory snapshot. Reference pages for
that surface are still written by hand, so they drift from the code, and a regeneration step that
overwrote whole pages would destroy hand-written prose. One consumer repository measured the gap by
hand: a feature epic changed 138 `src/` files while only 4 of 79 documentation pages were edited.

The first design of this feature targeted a Python package and was withdrawn by the epic's
implementation-language directive: logic pushed down to destination repositories is PowerShell
under `.claude/lib/docs/`. Its preparation also halted because six pure functions lacked property
tests; this revision requires a property test for every pure function.

## Personas & Scenarios

- Persona: consumer-repository maintainer
  - Owns a repository that has adopted the documentation-estate tooling through the Claude
    push-down, with a docs profile and a surface inventory snapshot produced by
    `Invoke-DocsCommand.ps1 -Command inventory`.
  - Cares about reference pages that match the current surface and pass
    `Invoke-DocsCommand.ps1 -Command check`.
  - Constraints: PowerShell 7.4 or later; must link new reference pages from an entry page; owns
    the profile's owners, audiences and directory modes.
  - Goals: one deterministic command whose output does not change when nothing changed.
- Persona: documentation author
  - Writes explanatory prose, examples and caveats around reference entries.
  - Cares that regeneration never deletes or reorders that prose.
  - Constraints: must not edit inside generated blocks, because those lines are replaced.
- Persona: downstream tool maintainer (MCP tool, authoring workflow, onboarding template,
  enforcement workflow)
  - Invokes `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command
    generate-reference -Json ...` and reads exactly one envelope from stdout.
  - Cares that options, exit codes, result keys, family page names and the marker grammar are
    fixed, and that a run without `-Write` has no side effect.
- Scenario: first generation
  - The maintainer runs `-Command generate-reference`. The profile names `docs/reference` as the
    single reference directory. The command exits 0, lists `create docs/reference/cli-reference.md`
    and the other family pages with region diffs, and prints a note that each new page must be
    linked from an entry page. Nothing is written.
  - The maintainer runs the command again with `-Write`; the pages are created, the maintainer
    links them from `docs/README.md`, and `-Command check` reports zero findings.
- Scenario: regeneration after a surface change
  - A command option is removed and a new HTTP route is added. The author has added prose between
    two generated blocks on the CLI page.
  - A dry run shows the option's block removed (with a `DOCS_REFERENCE_BLOCK_REMOVED` finding) and
    the new route block added to the HTTP page; the author's prose is unchanged in the diff.
  - `-Write` applies the changes; a second run reports every page as `none` and writes nothing.
- Scenario: protected failure
  - An author accidentally deletes an end marker. The command reports
    `DOCS_REFERENCE_MARKER_UNBALANCED` naming the page and line, marks that page `blocked`, exits 1,
    and writes nothing, so no prose is lost.
- Scenario: concurrent edit
  - A page changes on disk between planning and writing. The digest re-check detects it, the
    command stops with `DOCS_REFERENCE_WRITE_CONFLICT`, exits 3, and reports the pages written
    before the stop.

## Acceptance Criteria

Each item maps onto the `spec.md` acceptance criteria named in parentheses; it is verified when
those spec items are verified.

- [ ] US-01 Rendering the same snapshot twice is byte-identical, independent of element order and of the day the command runs (spec AC-01).
- [ ] US-02 Prose outside generated markers is preserved across regeneration, and a removed element's block is removed and reported with `DOCS_REFERENCE_BLOCK_REMOVED` (spec AC-02, AC-03).
- [ ] US-03 Every generated page passes the 1021 checker with zero findings in a Pester integration test that uses no temporary files, for new pages and after regeneration over author prose (spec AC-04).
- [ ] US-04 Without `-Write` the command writes nothing and prints the planned changes; with `-Write` it writes changed pages in path order through the single write primitive, and a second run writes nothing (spec AC-05, AC-06).
- [ ] US-05 A concurrent change or write failure stops writing with exit 3 and one finding naming the page; any `error` finding exits 1 with nothing written; usage errors exit 2 (spec AC-07, AC-08).
- [ ] US-06 The `-Json` envelope validates against `schemas/docs/v1/docs-command-envelope.schema.json` for every exit code and carries a fixed result shape (spec AC-09).
- [ ] US-07 Generated front matter conforms to `schemas/docs/v1/page-metadata.schema.json`, sets `diataxis_mode: reference` and `surface_refs`, and preserves valid author-maintained values (spec AC-10).
- [ ] US-08 Pages are planned as the fixed family files under the profile's reference directory or an explicit output directory, with marker anomalies blocking only the affected page (spec AC-11, AC-12).
- [ ] US-09 Every pure function, including the six named by the halted preflight, has a property test over a fixed seed list whose failure output prints the seed (spec AC-13, AC-14).
- [ ] US-10 The command is registered by one dispatch row under its own anchor, and every new module is mirrored byte-identically and listed in the Claude core pack manifest (spec AC-15, AC-16).
- [ ] US-11 The modules follow the lib conventions, perform all file and clock access through the command context, and the tests create no temporary files (spec AC-17, AC-18).
- [ ] US-12 No Python, TypeScript or new third-party module is introduced, no consumer identifier appears in framework source, and no new file exceeds 800 logical lines (spec AC-19, AC-20).
- [ ] US-13 Pester line coverage is at least 85% for each new production file, with evidence under `<FEATURE>/evidence/qa-gates/`, and the PowerShell QC checks pass in CI (spec AC-21, AC-22).

## Non-Goals

- A separate drift-check mode; a dry run whose pages all report `none` serves that purpose.
- A generated index page or a reserved generated-block identifier; consumers link pages from their
  own entry page.
- Rendering `architecture-component` elements.
- Changes to 1020 or 1021 schemas or modules.
- The MCP tool itself (900007).
- Running an external Markdown linter or Vale.
