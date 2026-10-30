# `2026-10-30-docs-page-quality-checker` — User Story

- Issue: #1021
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30
- Parent: #1019 (epic `documentation-estate-tooling`, child 1021, wave 1, band C3; depends on 1020)
- Work Mode: full-feature
- Spec: `spec.md` (authoritative for the modules, schema, front-matter subset, finding codes, `check` contract and base configuration)
- Revision: the Python package design of the earlier version is withdrawn; this story describes the PowerShell design under `.claude/lib/docs/` (new planning cycle under owner decision D1).

## Story Statement

- As a consumer-repository maintainer, I want to run
  `Invoke-DocsCommand.ps1 -Command check` with PowerShell 7.4 over the documentation roots declared
  in my docs profile, so that missing or malformed page metadata, broken links or anchors, Diataxis
  mode drift and orphan pages are reported deterministically and fail my build, without installing
  Python or Node.js.
- As a consumer-repository maintainer, I want optional, domain-neutral markdownlint and Vale
  configuration that `init` can write for me, with a vocabulary file I own, so that I can adopt
  Markdown linting without inheriting another organization's terms or a required linter runtime.
- As the maintainer of the reference generator (1024), I want a fixed page-metadata schema, a
  documented front-matter subset and a pure checking function, so that every page the generator
  emits passes the checker with zero findings in a Pester integration test.
- As the maintainer of the MCP tools (900007) and the consumer CI workflow (1034), I want a stable
  exit-code contract and a `-Json` envelope that validates against the envelope schema, so that my
  wrappers parse results without reimplementing any rule.

## Problem / Why

A destination repository that adopts the documentation-estate tooling has no framework-provided way
to check the structural quality of its documentation pages. Pages can lack ownership and review
metadata, carry broken relative links or missing heading anchors, drift from their declared
Diataxis mode, or become orphans that no entry page reaches. One consumer repository built a
bespoke checker for these conditions; the framework needs a domain-neutral equivalent that is
delivered by the existing Claude push-down and needs only PowerShell in the destination repository.
No Markdown QC configuration exists on `main`, so the framework also has no base configuration a
consumer can adopt.

## Personas & Scenarios

- Persona: consumer-repository maintainer
  - Owns a repository that receives the `.claude/lib/docs/` push-down and keeps a docs profile at
    `docs/documentation-estate/docs-profile.json`.
  - Cares about pages that carry an owner, a review date, declared audiences and a Diataxis mode,
    links that resolve, and pages reachable from a root entry page.
  - Constraints: PowerShell 7.4 is available; Python and Node.js may not be; product vocabulary must
    stay in a file the consumer controls.
  - Goals: one command with a stable exit code for CI and a stable JSON envelope for tooling.
    Frustrations: bespoke checkers that drift, nondeterministic output, and styles that embed
    another organization's terms.
- Persona: reference-generator maintainer (1024)
  - Emits reference pages with JSON-valued front matter (`diataxis_mode: "reference"`,
    `surface_refs`) and generated-block markers.
  - Constraints: must not emit headings that begin `how to ` or match `^step\s+[0-9]+\b`; audience
    identifiers must match `^[a-z0-9][a-z0-9-]*$` and be declared in the profile.
  - Goal: an integration test in which every generated page passes with zero findings.
- Persona: MCP and CI maintainer (900007, 1034)
  - Invokes `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command check -Json`.
  - Goal: parse `exit_code`, `findings` and `result` from a schema-validated envelope; add no logic.
- Scenario: consumer CI run
  - CI runs `-Command check -Json`. One page lacks `last_reviewed` and links to a removed heading on
    another page. The envelope lists `DOCS_PAGE_FIELD_MISSING` and `DOCS_PAGE_LINK_ANCHOR_MISSING`,
    each with the page path as `artifact_path`, in the documented order, and the exit code is `1`.
  - The maintainer adds the field and fixes the link; the next run reports no findings and exits `0`.
- Scenario: consumer adopts the base configuration
  - The maintainer runs `-Command init` to review the planned writes, then `-Command init -Write`.
    `.markdownlint.json`, `.vale.ini`, the `DocsBase` Vale style and an empty
    `.vale/styles/config/vocabularies/Project/accept.txt` are written; the maintainer adds product
    terms to `accept.txt`. Running markdownlint or Vale stays optional; `check` remains the gate.
- Scenario: generator integration
  - The 1024 integration test renders reference pages plus an entry page that links them and calls
    `Get-DocsPageCheckFinding` on the in-memory page map; it reports zero findings.

## Acceptance Criteria

- [ ] Missing or malformed front-matter fields, a broken relative link, a missing heading anchor, a Diataxis mode mismatch and an orphan page each produce a distinct `DOCS_PAGE_*` finding code whose `artifact_path` names the failing page (`tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1`).
- [ ] `Invoke-DocsCommand.ps1 -Command check` exits 0 on a clean page set and 1 when any finding is present; `-Json` output is byte-identical across repeated runs and across a reversed page-listing order (`DocsPageCheck.Tests.ps1`).
- [ ] The `-Command check -Json` stdout document validates against `schemas/docs/v1/docs-command-envelope.schema.json` (`DocsPageCheck.Tests.ps1`).
- [ ] Generated-block markers, other HTML comments and fenced code produce no link, anchor or Diataxis-step finding, and a fixture page set in the 1024 output shape, linked from its root entry page, produces zero findings and exit code 0 (`DocsPageCheck.Tests.ps1`).
- [ ] `schemas/docs/v1/page-metadata.schema.json` defines the fields `owner`, `last_reviewed`, `audience`, `diataxis_mode` and `surface_refs` (plus optional `title` and `extensions`) with an `audience` item pattern of `^[a-z0-9][a-z0-9-]*$`, and its runtime copy under `.claude/lib/docs/schemas/v1/` is byte-identical (`DocsPageMetadataSchema.Tests.ps1`).
- [ ] The page-check modules import nothing from the ledger, analyzer-implementation or reference modules, proven by the static import-closure test `tests/scripts/claude-lib/docs/DocsPageImportIsolation.Tests.ps1` with a positive control.
- [ ] No consumer vocabulary or repository name ships in the base configuration under `.claude/lib/docs/templates/page-check/`; the Vale vocabulary file ships empty and is consumer-owned; `-Command init -Write` writes each base-configuration file with the bytes of its template (`DocsPageTemplates.Tests.ps1`, `DocsNeutrality.Tests.ps1`).
- [ ] Every new or edited file under `.claude/lib/docs/` is listed in the Claude `pack-manifests/core.json` and its push-down copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` is byte-identical (`Docs.Manifest.Tests.ps1`).
- [ ] No Python or TypeScript file is added or modified by the feature diff.
- [ ] Pester line coverage is at least 85% for each new `DocsPage*.psm1` module, recorded under `<FEATURE>/evidence/coverage/`, and the required check `poshqc / PowerShell QC` (Pester shards on `windows-latest`, with coverage) passes on the pull request head (CI-dependent).

## Non-Goals

- Mechanical judgment of prose correctness (epic non-goal).
- A required Markdown linter: markdownlint and Vale are optional; no Node.js or Python linter is
  installed or run (D4).
- Running markdownlint or Vale on this repository's own documentation (epic A3, issue #5).
- Comparison of `last_reviewed` with the current date.
- Validation of generated-block marker balance or identifiers (owned by 1024).
- MCP wrappers (900007) and the consumer CI workflow (1034).
