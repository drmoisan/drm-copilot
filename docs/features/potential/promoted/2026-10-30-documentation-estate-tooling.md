# documentation-estate-tooling (Issue #1019)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/documentation-estate-tooling/ (Issue #1019)
- Type: Epic
- Derived from: staged potential entry `2026-10-24-documentation-coverage-and-parity` (correspondence
  half), extended with the generation half requested by the owner.

- Issue: #1019
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1019
- Last Updated: 2026-10-30
## Problem / Why

Goal stated by the owner: create a set of utilities that can create comprehensive documentation for
a destination repository.

Consumer repositories that adopt drm-copilot can produce documentation through the existing epic
pipeline, but the framework provides no utility that inventories a destination repository's
documentable surface, generates reference pages from it, or measures whether documentation stays in
correspondence with the code. The evidence comes from one consumer repository:

- A comprehensive-documentation epic built a docs-as-code estate: information architecture, seven
  page templates, owner/review metadata, a repo-local `docs_check` package, PyMarkdown, and a docs
  CI gate. Diataxis-mode and Vale prose gates followed in a later pull request.
- A subsequent feature epic merged 138 changed `src/` files (98 new modules) while only 4 of 79
  production documentation pages were edited. The gap was discovered and measured by hand
  afterwards.
- A CLI epic required a one-off fail-closed surface-enumeration probe to reconcile CLI docs against
  the merged command surface.

Each reconciliation was bespoke. Documentation drift is detected after merge, by manual counting,
and the tooling that detects it lives only in one consumer repository.

The `legacy-discovery-and-parity` capability (#980, merged to `main` by PR #1014) solves the
structurally identical problem for migrations: a domain-neutral engine
(`packages/discovery-runtime`, import name `drm_copilot_discovery`) that inventories a source
surface, records a disposition for every element in a coverage ledger, binds each element to a
target in a parity matrix pinned to a revision, and issues validation receipts. Documentation
coverage is the same problem with "code surface" as the source and "documentation pages" as the
target.

## Proposed Behavior

Two halves, delivered as one epic (`documentation-estate-tooling`):

1. **Generation.** Inventory the destination repository's documentable surface (CLI commands and
   options, HTTP routes, configuration keys, public API symbols, architecture components), plan an
   information architecture, generate deterministic reference pages from the inventory, and support
   agent-authored narrative pages (tutorials, how-to guides, explanations) through constrained
   roles and skills.
2. **Correspondence.** Record a disposition for every surface element in a documentation coverage
   ledger, bind elements to pages in a parity matrix, pin each documented claim to the symbol and
   revision it describes so a changed symbol marks the page stale, and emit a `docs-complete`
   validation receipt that can gate CI and an epic's final integration pull request.

| Discovery primitive (#980) | Documentation counterpart |
|---|---|
| Version 2 domain profile | Docs profile: audiences, documentation roots, surfaces to document, page owners, Diataxis policy, completion gates. |
| Inventory analyzers and revision-pinned inventory snapshots | Surface analyzers: CLI, HTTP routes, configuration, public API, architecture components. |
| Coverage ledger with a disposition per component | Every surface element is `documented`, `excluded` (with rationale) or `deferred` (with owner and target). |
| Parity matrix per dimension | Each surface element bound to its page(s) per dimension: exists, accurate, example present, owner assigned, Diataxis mode. |
| Evidence references and revision policy | Each documented claim pins the symbol and revision it describes; a changed symbol marks the page stale. |
| Unspecified behavior and product decisions | Ambiguous or undocumented code behavior is routed to a decision owner before prose is written. |
| Validation receipt | A `docs-complete` validation mode whose receipt can gate an epic's final integration pull request. |
| Constrained roles | Docs architect, docs author, docs reconciler, docs coverage reviewer, with no direct Write grant to ledger artifacts. |

Companion deliverables:

1. A consumer-installable page-quality checker (front-matter metadata, relative links and anchors,
   Diataxis mode audit, orphan pages) with a base PyMarkdown configuration and a base Vale style.
   Repository-specific vocabulary and tuning stay consumer-owned.
2. A `documentation-estate` epic template consumable by `/epic-plan`.

The child-feature decomposition, file lists, and acceptance criteria are recorded in
`docs/features/epics/documentation-estate-tooling/epic.md`.

## Acceptance Criteria (epic level)

- [ ] A docs profile schema exists under `schemas/docs/v1/` and contains no consumer-specific names.
- [ ] Python CLI, HTTP route, and configuration-file surface analyzers produce revision-pinned
      inventory snapshots for a fixture repository.
- [ ] A documentation coverage ledger requires a disposition for every inventoried surface element;
      `excluded` requires a rationale.
- [ ] A documentation parity matrix binds surface elements to pages per configured dimension.
- [ ] A `docs-complete` validation mode emits a receipt; a surface change after the pinned revision
      without a ledger update fails validation.
- [ ] A deterministic reference-page generator renders pages from an inventory snapshot and
      preserves hand-written prose outside generated marker blocks.
- [ ] The page-level checker is available to consumers without copying source from the consumer
      repository.
- [ ] Documentation roles and skills are available on the Claude, Codex, and Copilot surfaces and in
      the push-down payload.
- [ ] A `documentation-estate` epic template is consumable by `/epic-plan`.
- [ ] Consumer names appear only in a separated example, never in framework behavior.

## Out of Scope

- Runtime characterization and acceptance-scenario generation.
- Protected-authority-store hook enforcement for documentation artifacts.
- Judging prose correctness mechanically (the reviewer role carries that judgment).
- A docs-site build (MkDocs or similar). ASSUMPTION pending owner confirmation.

## Constraints & Risks

- Builds on the merged discovery runtime as a library; documentation-specific types live beside it
  in a separate package rather than reshaping shared discovery types.
- Surface analyzers are stack-specific; stacks outside the built-in set enter through the
  discovery extension-result manifest.
- Accuracy is partially unverifiable mechanically; the tools prove a page exists and pins a current
  symbol.

## Next Step

- [ ] Promote to GitHub issue (epic)
