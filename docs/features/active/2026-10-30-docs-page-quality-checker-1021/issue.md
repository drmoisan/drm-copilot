# docs-page-quality-checker (Issue #1021)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/docs-page-quality-checker/ (Issue #1021)
- Parent epic: #1019 (documentation-estate-tooling, wave 0, complexity band C3)

- Issue: #1021
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1021
- Last Updated: 2026-10-30
- Work Mode: full-feature

## Problem / Why

A destination repository that adopts the documentation-estate tooling has no framework-provided
way to check the structural quality of its documentation pages. Pages can lack ownership and
review metadata, carry broken relative links or missing heading anchors, drift from their declared
Diataxis mode, or become orphans that no other page links to. One consumer repository built a
bespoke checker for these conditions; the framework needs a domain-neutral, consumer-installable
equivalent. No Markdown QC configuration (PyMarkdown or Vale) exists on `main`, so the framework
also has no base configuration a consumer can adopt.

## Proposed Behavior

Ship a separate, independently installable Python package `packages/docs-page-check` (import name
`drm_copilot_docs_check`) that imports nothing from `drm_copilot_docs`. It provides:

- Front-matter metadata validation against `schemas/docs/v1/page-metadata.schema.json` with the
  fields `owner`, `last_reviewed`, `audience`, `diataxis_mode`, and `surface_refs`.
- Relative-link and heading-anchor checks.
- A Diataxis mode audit (mode rules per declared `diataxis_mode`).
- Orphan-page detection.
- Deterministic findings rendered as text and JSON, each with a distinct finding code naming the
  file.
- A console command `dev.docs.check` that exits 0 on a clean page set and non-zero when any
  finding is present.

Pure checker cores take in-memory path-to-content mappings; file I/O stays in the thin CLI module.
Base consumer configuration ships in the push-down template tree under
`extensions/drm-copilot/resources/templates/docs-quality/`: a base PyMarkdown configuration, a base
Vale configuration, a base Vale style (`styles/DocsBase/`), and an empty consumer-owned vocabulary
file. The design is framework-native, derived from a checker in one consumer repository; no source
from that repository is copied, and consumer vocabulary stays consumer-owned.

## Acceptance Criteria (early draft)

- [ ] Missing or malformed front-matter fields, a broken relative link, a missing heading anchor, a Diataxis mode mismatch and an orphan page each produce a distinct finding code naming the file.
- [ ] `dev.docs.check` exits 0 on a clean page set and non-zero when any finding is present; JSON output ordering is deterministic.
- [ ] No consumer vocabulary or repository name ships in the base Vale style; vocabulary is a consumer-owned file.
- [ ] The package imports nothing from `drm_copilot_docs` (independent installability).
- [ ] Line coverage >= 85% and branch coverage >= 75% for `drm_copilot_docs_check`.

## Constraints & Risks

- Naming contract fixed by the epic: package path, import name, schema path, front-matter fields,
  console command, and template location may not change without an epic-level update.
- The downstream reference generator (epic sibling) emits pages that must pass this checker, so
  the page-metadata schema and finding codes must be specified precisely.
- Tests must not create temporary files.
- Root `pyproject.toml` and `poetry.lock` are shared, append-only edit points with sibling epic
  features.
- The consumer installation and push-down mechanism for the package and base configuration must
  be established by research.

## Test Conditions to Consider

- [ ] Unit coverage areas: front matter, links, anchors, Diataxis rules, orphans, report ordering, CLI exit codes
- [ ] Integration scenarios: CLI over an injected in-memory page set
- [ ] CLI/API examples: `dev.docs.check` text and JSON output

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/docs-page-quality-checker/` folder from the template
