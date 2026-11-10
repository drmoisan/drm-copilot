# documentation-coverage-and-parity (Potential)

- Date captured: 2026-10-24
- Author: Dan Moisan
- Status: Draft

## Problem / Why

Consumer repositories that adopt drm-copilot can produce comprehensive documentation through
the existing epic pipeline, but nothing in the framework measures whether that documentation
stays in correspondence with the code. The evidence comes from one consumer repository:

- A comprehensive-documentation epic built a docs-as-code estate: information architecture,
  seven page templates, owner/review metadata, a repo-local `docs_check` package, PyMarkdown,
  and a docs CI gate. Diataxis-mode and Vale prose gates followed in a later pull request.
- A subsequent feature epic merged 138 changed `src/` files (98 new modules) while only 4 of
  79 production documentation pages were edited. The gap was discovered and measured by hand
  afterwards.
- A CLI epic required a one-off fail-closed surface-enumeration probe to reconcile CLI docs
  against the merged command surface.

Each reconciliation was bespoke. Documentation drift is detected after merge, by manual
counting, and the tooling that detects it lives only in one consumer repository.

The `legacy-discovery-and-parity` capability (#980, branch
`feature/legacy-discovery-and-parity-980`) already solves the structurally identical problem for
migrations: a domain-neutral engine that inventories a source surface, records a disposition
for every element in a coverage ledger, binds each element to a target in a parity matrix
pinned to a revision, and issues validation receipts that gate planning. Documentation
coverage is the same problem with "code surface" as the source and "documentation pages" as
the target.

## Proposed Behavior

Add a sibling capability, `documentation-coverage-and-parity`, that reuses the discovery
runtime's primitives rather than introducing a new engine.

| Discovery primitive (#980) | Documentation counterpart |
|---|---|
| Version 2 domain profile (all domain specificity supplied at runtime) | Docs profile: audiences, documentation roots, surfaces to document, page owners, Diataxis policy, completion gates. |
| Inventory analyzers and revision-pinned inventory snapshots | Surface analyzers: CLI parser/help surface, HTTP route registrations, configuration files and schemas, architecture components. |
| Coverage ledger with a disposition per component | Every surface element is `documented`, `excluded` (with rationale) or `deferred`. |
| Parity matrix per dimension | Each surface element bound to its page(s) per dimension: exists, accurate, example present, owner assigned, Diataxis mode. |
| Evidence references and revision policy | Each documented claim pins the symbol and revision it describes; a changed symbol marks the page stale. |
| Unspecified behavior and product decisions | Ambiguous or undocumented code behavior is routed to a decision owner before prose is written. |
| Validation receipt and `planning_prerequisite` gate | A `docs-complete` validation mode whose receipt can gate an epic's final integration PR when the surface changed without a ledger update. |
| Constrained roles | Surface analyst, docs reconciler, docs coverage reviewer, with no direct Write grant to ledger artifacts. |

Companion deliverables:

1. Port the consumer repository's page-level checker (a `docs_check` package: front-matter
   metadata, relative links, Diataxis mode audit) and the Vale style approach into the
   framework as a consumer-installable component. Repository-specific vocabulary and tuning
   stay consumer-owned.
2. Add a `documentation-estate` epic template for `/epic-plan`: research blueprint as input,
   foundation feature (IA, templates, metadata, docs CI) as wave 0, the documentation families
   with their dependency edges, and the coverage receipt as the epic exit gate.

Explicitly out of scope initially: runtime characterization, acceptance-scenario generation,
and the full protected-authority-store hook enforcement. A CI-verified receipt is expected to
be sufficient for documentation; stronger enforcement can be added later if needed.

## Acceptance Criteria (early draft)

- [ ] A docs profile schema exists under the framework's versioned schemas and contains no
      consumer-specific names (domain-neutrality invariant, as in #980).
- [ ] At least the CLI, HTTP route and configuration-file surface analyzers produce
      revision-pinned inventory snapshots for a fixture repository.
- [ ] A documentation coverage ledger requires a disposition for every inventoried surface
      element; `excluded` requires a rationale.
- [ ] A documentation parity matrix binds surface elements to pages per configured dimension.
- [ ] A `docs-complete` validation mode emits a receipt; a surface change after the pinned
      revision without a ledger update fails validation.
- [ ] The page-level checker (metadata, links, Diataxis mode) is available to consumers
      without copying source from the consumer repository.
- [ ] A `documentation-estate` epic template is consumable by `/epic-plan`.
- [ ] Consumer names appear only in a separated example, never in framework behavior.

## Constraints & Risks

- **Sequencing with #980.** The shared primitives (profile, ledger, matrix, receipt, evidence
  pins) are easiest to keep domain-neutral before #980 merges. Generalizing after merge risks
  migration-specific assumptions becoming embedded in shared types.
- **Analysis basis.** This entry is based on the #980 capability documentation
  (`docs/engineering/legacy-discovery-and-parity/`) and module inventory, not on a review of
  the implementation. Reuse feasibility must be confirmed during research.
- **Surface analyzers are stack-specific.** CLI and route extraction differ per framework
  (argparse, Click, FastAPI, ASP.NET, Commander). The initial set should be scoped and the
  extension-result-manifest path from #980 used for others.
- **Accuracy is partially unverifiable mechanically.** The engine can prove a page exists and
  pins a current symbol; it cannot prove prose is correct. The reconciler/reviewer roles carry
  that judgment.
- **Scale.** The combined scope (capability, checker port, epic template) likely passes the
  epic-worthiness gate; assess before routing.

## Test Conditions to Consider

- [ ] Unit: profile validation, ledger disposition rules, staleness detection on symbol change,
      Diataxis mode rules (property tests for pure rules).
- [ ] Integration: end-to-end inventory -> ledger -> matrix -> `docs-complete` receipt on a
      fixture repository with a deliberately undocumented command and a stale page.
- [ ] CLI/API examples: `docs-complete` validation via console command and MCP tool; gate
      failure message naming the uncovered surface elements.
- [ ] Domain-neutrality: framework source contains no consumer identifiers.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/documentation-coverage-and-parity/` folder from the template
