# docs-reference-generator (Issue #1024)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/docs-reference-generator/ (Issue #1024)
- Parent epic: #1019 (documentation-estate-tooling, wave 1, complexity band C3)

- Issue: #1024
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1024
- Last Updated: 2026-10-30
## Problem / Why

The documentation-estate-tooling epic inventories the documentable surface of a destination
repository (CLI commands and options, HTTP routes, configuration keys, public symbols and
architecture components) into a revision-pinned surface inventory snapshot. Reference pages for
that surface are still written by hand, so they drift from the code, and a regeneration step that
overwrote whole pages would destroy hand-written prose. One consumer repository measured the gap by
hand: a feature epic changed 138 `src/` files while only 4 of 79 documentation pages were edited.

## Proposed Behavior

Add a deterministic reference-page renderer to `packages/docs-runtime` (`drm_copilot_docs`) under
`drm_copilot_docs/reference/`, exposed as the console command `dev.docs.generate-reference`.

- `page_plan.py` maps surface elements to reference pages per the docs profile.
- `render_cli.py`, `render_http.py`, `render_config.py` and `render_api.py` render the element
  families into Markdown.
- `markers.py` parses and merges marker-delimited generated blocks
  (`<!-- docs:generated:start id=<element-id> -->` and `<!-- docs:generated:end id=<element-id> -->`),
  preserving all prose outside the markers and removing (and reporting) the block of an element that
  no longer exists.
- `front_matter.py` emits front matter conforming to `schemas/docs/v1/page-metadata.schema.json`
  (`diataxis_mode: reference`, `surface_refs`).
- `writer.py` performs the I/O; without `--write` the command writes nothing and prints the planned
  changes (dry-run diff).
- Pure cores take in-memory inputs; I/O stays in the thin CLI and writer modules.

Depends on 1020 (profile models, surface models, `surface-inventory-snapshot` schema) and 1021
(page-metadata schema and the `drm_copilot_docs_check` checker). Downstream 900007 wraps the
command as the MCP tool `generate_docs_reference`.

## Acceptance Criteria (early draft)

- [ ] Rendering the same snapshot twice is byte-identical (property test).
- [ ] Prose outside generated markers is preserved across regeneration (property test); a removed element's block is removed and reported.
- [ ] Every generated page passes `drm_copilot_docs_check` with zero findings (integration test).
- [ ] Without `--write` the command writes nothing and prints the planned changes.
- [ ] Line coverage >= 85% and branch coverage >= 75%.

## Constraints & Risks

- Framework code is domain-neutral; no consumer identifier appears in framework source.
- Tests create no temporary files; property tests use the repository's seeded `Draw` generator
  pattern (`hypothesis` is not an approved dependency).
- Root `pyproject.toml` `[tool.poetry.scripts]` is an append-only shared edit point with other
  wave-1 children.
- Generated-block HTML comments may interact with the PyMarkdown inline-HTML rule (md033) in the
  1021 base configuration.

## Test Conditions to Consider

- [ ] Unit coverage areas: page plan, each renderer, marker parse/merge, front matter, writer dry-run
- [ ] Integration scenarios: generated pages checked with `drm_copilot_docs_check`
- [ ] CLI/API examples: `dev.docs.generate-reference` with and without `--write`

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/docs-reference-generator/` folder from the template
