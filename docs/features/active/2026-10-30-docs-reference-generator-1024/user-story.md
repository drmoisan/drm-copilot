# `docs-reference-generator` — User Story

- Issue: #1024
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30
- Parent: #1019 (epic `documentation-estate-tooling`, wave 1, epic child 900006)
- Work Mode: full-feature
- Spec: `spec.md` (authoritative for the CLI contract, report shape, finding codes, marker grammar, merge algorithm and page-plan rules)

## Story Statement

- As a consumer-repository maintainer, I want to run `dev.docs.generate-reference` against my docs
  profile and surface inventory snapshot, so that reference pages for CLI commands, HTTP routes,
  configuration keys and public symbols are regenerated from the inventory instead of drifting
  from the code.
- As a documentation author, I want regeneration to replace only the marker-delimited generated
  blocks, so that the prose I write around them is never moved or overwritten, and I am told when a
  block is removed because its element no longer exists.
- As a reviewer, I want the command to print the planned changes and write nothing unless I pass
  `--write`, so that I can inspect the diff before any page changes.
- As the maintainer of the downstream MCP tool `generate_docs_reference` (epic sibling 900007), I
  want a fixed argument set, exit-code table and single JSON report document, so that the tool can
  validate input, invoke the command and return structured results without parsing prose.

## Problem / Why

The documentation-estate-tooling epic inventories the documentable surface of a destination
repository (CLI commands and options, HTTP routes, configuration keys, public symbols and
architecture components) into a revision-pinned surface inventory snapshot. Reference pages for
that surface are still written by hand, so they drift from the code, and a regeneration step that
overwrote whole pages would destroy hand-written prose. One consumer repository measured the gap by
hand: a feature epic changed 138 `src/` files while only 4 of 79 documentation pages were edited.

## Personas & Scenarios

- Persona: consumer-repository maintainer
  - Owns a repository that has adopted the documentation-estate tooling, with a docs profile and a
    surface inventory snapshot produced by `dev.docs.inventory`.
  - Cares about reference pages that match the current surface and pass `dev.docs.check`.
  - Constraints: installs the docs runtime as a wheel; must link new reference pages from an entry
    page; owns the profile's owners, audiences and directory modes.
  - Goals: one deterministic command whose output does not change when nothing changed.
    Frustrations: hand-maintained reference pages that fall behind the code.
- Persona: documentation author
  - Writes explanatory prose, examples and caveats around reference entries.
  - Cares that regeneration never deletes or reorders that prose.
  - Constraints: must not edit inside generated blocks, because those lines are replaced.
- Persona: downstream MCP tool maintainer (900007)
  - Wraps the command as `generate_docs_reference`, launching it as
    `python -I -m drm_copilot_docs.cli_generate` and reading exactly one JSON document from stdout.
  - Cares that arguments, exit codes and report keys are fixed and versioned (`report_version`
    `1.0.0`).
- Scenario: first generation
  - The maintainer runs `dev.docs.generate-reference`. The profile names `docs/reference` as the
    reference directory. The command exits `0`, lists `create docs/reference/cli-reference.md` and
    the other family pages with unified diffs, and prints a note that each new page must be linked
    from an entry page. Nothing is written.
  - The maintainer runs the command again with `--write`; the pages are created, the maintainer
    links them from `docs/README.md`, and `dev.docs.check` reports zero findings.
- Scenario: regeneration after a surface change
  - A command option is removed and a new HTTP route is added. The author has added prose between
    two generated blocks on the CLI page.
  - A dry run shows the option's block removed (with a `REFERENCE_BLOCK_REMOVED` finding) and the
    new route block added to the HTTP page; the author's prose is unchanged in the diff.
  - `--write` applies the changes; a second run reports every page as `none`.
- Scenario: protected failure
  - An author accidentally deletes an end marker. The command reports
    `REFERENCE_MARKER_UNBALANCED` naming the page and line, marks that page `blocked`, exits `1`,
    and writes nothing, so no prose is lost.

## Acceptance Criteria

- [ ] Rendering the same snapshot twice is byte-identical (property test): for every seed in `SEEDS`, `generate_reference` over a `Draw`-generated profile and snapshot, run twice and run on a `Draw`-shuffled element order, yields identical page bytes for every page and identical `render_json` report bytes.
- [ ] Prose outside generated markers is preserved across regeneration (property test): for every seed in `SEEDS`, `merge_blocks` keeps every non-blank line outside generated blocks in its original order, keeps every prose segment byte-identical when the desired identifier set equals the existing one, and is idempotent.
- [ ] A removed element's block is removed and reported: its identifier appears in the page's `blocks.removed` and one `REFERENCE_BLOCK_REMOVED` finding with severity `info` names it in `related_ids`.
- [ ] Every generated page passes `drm_copilot_docs_check` with zero findings (integration test): `run_check` over the generated pages plus an entry page linking each of them returns exit `0` and `summary.finding_count` `0`, for new pages and after regeneration over pages with author prose.
- [ ] Without `--write` the command writes nothing and prints the planned changes: a recording `PagePort` sees no `create` or `replace` call, the exit code is `0`, and stdout contains the per-page lines and unified diffs (text) or `diff` strings with status `planned` (JSON).
- [ ] Line coverage >= 85% and branch coverage >= 75% for `drm_copilot_docs.reference` and `drm_copilot_docs.cli_generate`.
- [ ] With `--write`, changed pages are created or updated in `path` order, and an immediate second run reports action `none` for every page and makes no write call.
- [ ] A write conflict or write failure stops writing at that page, reports the page statuses and `uncertain_paths` as defined in the spec, and exits `3`.
- [ ] Invocation errors exit `2` with empty stdout and exactly one stderr line; unreadable inputs exit `3` with empty stdout and exactly one stderr line; any `error` finding exits `1` with the full report and no write.
- [ ] `--format json` writes exactly one JSON document with `report_version` `1.0.0` whose key sets match `### JSON report` in the spec.
- [ ] A marker anomaly (malformed, duplicate, unbalanced, mismatched, or inside front matter) blocks only the affected page with the code listed in the spec's finding-code catalog, and no page is written.
- [ ] Emitted front matter validates against the committed page-metadata schema, and valid existing `owner`, `audience`, `last_reviewed`, `title` and `extensions` values are preserved.
- [ ] No rendered heading begins with `How to` or `Step <n>` (property test over drawn declarations).
- [ ] The root and `packages/docs-runtime` `pyproject.toml` files each register `dev.docs.generate-reference` as `drm_copilot_docs.cli_generate:main`, and `poetry check --lock` exits `0`.
- [ ] No new test creates a temporary file, and no module under `drm_copilot_docs/reference/` other than `writer.py` performs file I/O (AST-based test).

## Non-Goals

- A `--check` drift-detection mode.
- A generated reference index page or a reserved generated-block identifier; consumers link pages
  from their own entry page.
- Rendering `architecture-component` elements.
- Changes to the 1020 or 1021 schemas, including audience grammar alignment (recorded as an
  epic-level open item).
- The MCP tool itself (900007).
- Running PyMarkdown or Vale.
