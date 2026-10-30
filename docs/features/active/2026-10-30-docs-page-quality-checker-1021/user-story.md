# `2026-10-30-docs-page-quality-checker` — User Story

- Issue: #1021
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30
- Parent: #1019 (epic `documentation-estate-tooling`, wave 0, epic child 900002)
- Work Mode: full-feature
- Spec: `spec.md` (authoritative for the schema, finding codes, report shape, and rules)

## Story Statement

- As a consumer-repository maintainer, I want to install `drm-copilot-docs-check` and run
  `dev.docs.check` over my documentation pages, so that missing metadata, broken links or anchors,
  Diataxis mode drift, and orphan pages are reported deterministically and fail my build.
- As a consumer-repository maintainer, I want a domain-neutral base PyMarkdown and Vale
  configuration with a vocabulary file that I own, so that I can adopt Markdown quality checks
  without inheriting another organization's terms.
- As the maintainer of the downstream reference generator (epic sibling 900006), I want a precise,
  fixed page-metadata schema and finding-code catalog, so that every page the generator emits
  passes the checker with zero findings.

## Problem / Why

A destination repository that adopts the documentation-estate tooling has no framework-provided
way to check the structural quality of its documentation pages. Pages can lack ownership and
review metadata, carry broken relative links or missing heading anchors, drift from their declared
Diataxis mode, or become orphans that no other page links to. One consumer repository built a
bespoke checker for these conditions; the framework needs a domain-neutral, consumer-installable
equivalent. No Markdown QC configuration (PyMarkdown or Vale) exists on `main`, so the framework
also has no base configuration a consumer can adopt.

## Personas & Scenarios

- Persona: consumer-repository maintainer
  - Maintains a repository that adopts the documentation-estate tooling and owns its `docs/` tree.
  - Cares about pages that carry an owner and review date, links that resolve, and pages that are
    reachable from an entry page.
  - Constraints: installs Python packages as a wheel into the repository's own interpreter; does
    not have this repository's Poetry environment; must keep product vocabulary in a file the
    consumer controls.
  - Goals: a single command with a stable exit code for CI and a stable JSON report for tooling.
    Frustrations: bespoke checkers that drift, nondeterministic output, and base styles that embed
    another organization's terms.
- Persona: downstream reference-generator maintainer (epic sibling 900006)
  - Emits reference pages with front matter (`diataxis_mode: reference`, `surface_refs`) and
    generated-block markers.
  - Cares about a schema and rule set that do not change under the generator.
  - Constraints: must not emit headings that begin with `How to` or `Step <n>`.
  - Goal: an integration test in which every generated page passes the checker with zero findings.
- Scenario: consumer CI run
  - The maintainer installs the wheel and runs `dev.docs.check --root docs --format json` in CI.
  - A page lacks `last_reviewed` and links to a removed heading. The command prints
    `FRONT_MATTER_FIELD_MISSING` and `LINK_ANCHOR_MISSING` findings naming the page, sorted by the
    documented key, and exits `1`.
  - The maintainer adds the field and fixes the link; the next run prints no findings and exits `0`.
- Scenario: consumer adopts the base configuration
  - The maintainer copies `extensions/drm-copilot/resources/templates/docs-quality/` into the
    repository by hand, following the package README, adds product terms to
    `styles/config/vocabularies/Project/accept.txt`, and runs
    `pymarkdown --config .pymarkdown.json scan docs` and `vale docs`.
- Scenario: generator integration
  - The generator renders reference pages whose front matter conforms to
    `schemas/docs/v1/page-metadata.schema.json`, with generated-block markers and no instructional
    headings, and runs the checker over them; it reports zero findings.

## Acceptance Criteria

- [ ] Missing or malformed front-matter fields, a broken relative link, a missing heading anchor, a Diataxis mode mismatch and an orphan page each produce a distinct finding code naming the file.
- [ ] `dev.docs.check` exits 0 on a clean page set and non-zero when any finding is present; JSON output ordering is deterministic.
- [ ] No consumer vocabulary or repository name ships in the base Vale style; vocabulary is a consumer-owned file.
- [ ] The package imports nothing from `drm_copilot_docs` (independent installability).
- [ ] Line coverage >= 85% and branch coverage >= 75% for `drm_copilot_docs_check`.
- [ ] A test fixture page set containing a page with `diataxis_mode: reference`, schema-conforming front matter, `<!-- docs:generated:start id=... -->` and `<!-- docs:generated:end id=... -->` markers, and no heading beginning `How to` or `Step <n>`, reachable from an entry page, produces zero findings and exit code 0.
- [ ] `packages/docs-page-check/README.md` documents wheel installation, the finding codes, the Diataxis heading prefixes, and manual adoption of `extensions/drm-copilot/resources/templates/docs-quality/`, including that PyMarkdown requires `--config .pymarkdown.json`.

## Non-Goals

- No push-down command copies `resources/templates/docs-quality/` into a consumer repository in
  this feature; adoption is manual per the package README, and automated delivery is left to a
  later epic child.
- Mechanical judgment of prose correctness.
- Running PyMarkdown or Vale in this repository.
- A published distribution channel for the wheel.
- Enforcement of the surface element-identifier grammar in `surface_refs`.
