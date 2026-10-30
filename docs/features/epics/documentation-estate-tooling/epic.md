---
epic: documentation-estate-tooling
integration_branch: epic/documentation-estate-tooling-integration
created_at: 2026-10-30T20:10:00Z
# PLANNING STATE. issue_num values of the form 9000NN are placeholders until each child's
# promotion receipt is back-filled; depends_on uses issue_num values. The final resolved manifest
# replaces every placeholder before the kickoff artifact is written.
intent:
  epic_type: enabler
  business_outcome_hypothesis: A consumer repository can inventory its documentable surface, generate reference pages, author narrative pages through constrained roles, and prove documentation correspondence with a docs-complete receipt, without bespoke per-repository tooling, manual counting of drift, or a Python runtime.
  leading_indicators:
    - A fixture repository with one undocumented command and one stale page fails docs-complete validation naming both elements, and passes after the ledger and page are updated.
    - Reference pages generated twice from the same inventory snapshot are byte-identical, and hand-written prose outside generated blocks survives regeneration.
    - No consumer identifier appears in framework source.
  nfrs:
    - Framework code is domain-neutral; all repository specificity is runtime configuration in the docs profile.
    - New tooling is TypeScript (runtime, CLI, MCP) or PowerShell (hooks); the epic adds no new Python script, module, tool or entry point, so a destination repository needs Node.js only.
    - Analyzers are read-only, lexical, bounded and deterministic; no analyzer executes, compiles or installs consumer code.
    - Line coverage >= 85% and branch coverage >= 75% on every new TypeScript module, line coverage >= 85% on new PowerShell; files stay within the 500/700/800 line tiers.
features:
  - issue_num: 1020
    feature_folder: 2026-10-30-docs-profile-and-artifact-schemas-1020
    depends_on: []
  - issue_num: 1021
    feature_folder: 2026-10-30-docs-page-quality-checker-1021
    depends_on: [1020]
  - issue_num: 900003
    feature_folder: docs-surface-analyzers-python-config
    depends_on: [1020]
  - issue_num: 900004
    feature_folder: docs-surface-analyzers-typescript-dotnet
    depends_on: [1020]
  - issue_num: 900005
    feature_folder: docs-coverage-ledger-and-receipt
    depends_on: [1020]
  - issue_num: 900006
    feature_folder: docs-reference-generator
    depends_on: [1020, 1021]
  - issue_num: 900007
    feature_folder: docs-mcp-tools
    depends_on: [1021, 900003, 900005, 900006]
  - issue_num: 900008
    feature_folder: docs-enforcement-and-ci
    depends_on: [1021, 900005]
  - issue_num: 900009
    feature_folder: docs-authoring-workflow
    depends_on: [900007]
  - issue_num: 900010
    feature_folder: documentation-estate-template-and-onboarding
    depends_on: [900008, 900009]
---

# documentation-estate-tooling - Epic

- Issue: #1019
- Owner: Dan Moisan
- Last Updated: 2026-10-30
- Source potential entry: `docs/features/potential/promoted/2026-10-30-documentation-estate-tooling.md`

## Goal

Create a set of utilities that can create comprehensive documentation for a destination
repository (owner's objective), and prove that the documentation stays in correspondence with the
code. The epic has two halves:

1. **Generation.** Inventory the documentable surface of the destination repository, plan an
   information architecture, generate deterministic reference pages, and author narrative pages
   through constrained documentation roles.
2. **Correspondence.** Record a disposition per surface element in a coverage ledger, bind
   elements to pages in a parity matrix, pin claims to symbols and revisions so changed code marks
   pages stale, and emit a `docs-complete` receipt that can gate CI and an epic's integration pull
   request.

Evidence for the need comes from one consumer repository, where a feature epic changed 138 `src/`
files while only 4 of 79 documentation pages were edited, and the gap was measured by hand.

## Owner Directive: Implementation Language (2026-10-30)

Received through the coordinator during planning and binding on every child:

> Avoid Python scripts. Existing Python in the repo is tolerated and may be reused, extended in
> place or called, but new scripts, tools, checkers, generators, analyzers and CLI entry points
> must be written in TypeScript or PowerShell, to avoid adding environmental dependencies for
> destination repos. Enforcement hooks still must not use Python. If a child cannot reasonably
> avoid new Python, record it as an owner question with the reason and the TypeScript or
> PowerShell alternative.

Consequences applied in this document: the earlier Python package design (`packages/docs-runtime`
as `drm_copilot_docs`, `packages/docs-page-check` as `drm_copilot_docs_check`, `dev.docs.*` Poetry
console commands, a Python wheel build script) is withdrawn. Children 1020, 1021, 900003, 900005
and 900006 were prepared or were being prepared against that design before the directive arrived;
each is re-prepared with one planner revision against this section.

## Assumptions Pending Owner Confirmation

None of the following has been approved by the owner. Each is a provisional default.

- **A1 - Analyzer scope.** Python/configuration analyzers (900003) and TypeScript/.NET analyzers
  (900004) are both in the epic as separate features, both implemented in TypeScript. No other
  feature depends on 900004, so it may land later; stacks outside the built-in set enter through
  the discovery extension-result manifest format.
- **A2 - Docs-site build.** A docs-site build (MkDocs or similar) is out of scope.
- **A3 - Issue #5 `markdown-toolchain`.** This epic stays separate from issue #5. No Markdown QC
  configuration exists on `main` at planning time (no `.pymarkdown*`, `.markdownlint*`,
  `.vale.ini` or `styles/` at the repository root). Under the language directive, 1021 ships a
  base markdownlint configuration (Node-based) instead of a PyMarkdown configuration, plus a base
  Vale style (Vale is a standalone binary and stays optional). Issue #5 may adopt both.
- **A4 - Integration branch.** `epic/documentation-estate-tooling-integration` starts from
  `origin/main`, which contains the merged discovery runtime (#980, PR #1014).
- **A5 - Code placement and distribution (planner decision).** Documentation tooling is TypeScript
  under `extensions/drm-copilot/src/docs/`, so it is compiled with the extension and bundled into
  the existing MCP server package `@danmoisan/drm-copilot-mcp` (`packages/mcp-server`). A second
  `bin` entry, `drm-copilot-docs`, built from `extensions/drm-copilot/src/docs/cli/docs-cli.ts`,
  exposes the CLI, so a destination repository runs
  `npx -p @danmoisan/drm-copilot-mcp drm-copilot-docs <subcommand>` with Node.js only. No new npm
  package or publish pipeline is added.
- **A6 - MCP placement (planner decision).** All docs MCP tools are delivered by one feature
  (900007) after the modules they call exist, so the shared MCP registration files are edited once.
  The tools call the TypeScript modules in process; they do not spawn a CLI.
- **A7 - Discovery reuse (planner decision).** The JSON schemas under `schemas/discovery/v2/` are
  language-neutral and are reused by `$ref`. The Python discovery runtime is not called by the docs
  tooling, because calling it would require Python in the destination repository; a discovery
  inventory snapshot or extension-result manifest that already exists as JSON may be imported as
  data.
- **A8 - Runtime dependencies (planner decision).** The extension and MCP server have one runtime
  dependency (`@modelcontextprotocol/sdk`). JSON Schema validation, front-matter parsing and
  lexical scanning are written without adding a direct runtime dependency unless a child's research
  shows that is unreasonable. In that case the child records an owner question naming the package
  (for example `ajv`, already present transitively through the MCP SDK) instead of adding it.

## Scope

| Wave | issue_num | Feature | Band | Purpose |
|---|---|---|---|---|
| 0 | 1020 | docs-profile-and-artifact-schemas | C3 | Docs profile, versioned schemas, surface element model, analyzer contract, `docs/` module skeleton, `drm-copilot-docs` CLI entry and bin. |
| 1 | 1021 | docs-page-quality-checker | C3 | Page checker (front matter, links/anchors, Diataxis mode, orphans) with base markdownlint and Vale configuration. |
| 1 | 900003 | docs-surface-analyzers-python-config | C4 | TypeScript lexical analyzers for Python CLI, HTTP route, public API, configuration and architecture surfaces; `inventory` subcommand. |
| 1 | 900004 | docs-surface-analyzers-typescript-dotnet | C4 | TypeScript lexical analyzers for TypeScript CLI/route/export and .NET route/config/public-type surfaces; extension-manifest import. |
| 1 | 900005 | docs-coverage-ledger-and-receipt | C4 | Coverage ledger, parity matrix, evidence pins and staleness, `docs-complete` receipt. |
| 2 | 900006 | docs-reference-generator | C3 | Deterministic reference-page renderer with marker-delimited generated blocks. |
| 3 | 900007 | docs-mcp-tools | C3 | MCP tools over the docs modules. |
| 2 | 900008 | docs-enforcement-and-ci | C3 | Consumer workflow template, surface-delta check, opt-in integration-PR gate (PowerShell), feature-review check. |
| 4 | 900009 | docs-authoring-workflow | C4 | Four documentation roles, eight skills, page templates, mirrored to all surfaces. |
| 5 | 900010 | documentation-estate-template-and-onboarding | C3 | `documentation-estate` epic template, onboarding docs, end-to-end fixture test. |

## Non-Goals

- Runtime characterization and acceptance-scenario generation for documentation.
- Protected-authority-store hook enforcement for documentation artifacts (the receipt is
  CI-verified; stronger enforcement can follow later).
- Mechanical judgment of prose correctness. Tools prove a page exists, carries metadata and pins a
  current symbol; the reviewer role judges accuracy.
- A docs-site build (A2).
- Markdown QC adoption for this repository's own documentation (issue #5, A3).
- Changes to the Python discovery runtime. A defect found there is filed separately.
- New Python code of any kind (owner directive). Existing repository Python tooling (for example
  the mirror generators `scripts/dev_tools/agentic_sync.py` and
  `scripts/dev_tools/generate_codex_agent_variants.py`, or the plan validator) may still be called.

## Shared Design

### Naming contract (fixed for all children)

- Source root: `extensions/drm-copilot/src/docs/`; tests mirror it under
  `extensions/drm-copilot/test/docs/` (Jest, ts-jest), following the extension's existing
  `src/` to `test/` layout.
- Module areas: `docs/profile/` (1020), `docs/schema/` (1020), `docs/surface/` (1020),
  `docs/page-check/` (1021), `docs/analyzers/` (900003, 900004), `docs/ledger/` (900005),
  `docs/reference/` (900006), `docs/surface-delta/` (900008), `docs/cli/` (one command module per
  subcommand).
- CLI: one entry `docs/cli/docs-cli.ts` with a subcommand table (1020). Subcommands and owners:
  `init`, `validate-profile` (1020); `check` (1021); `inventory` (900003; 900004 adds analyzers
  only); `coverage`, `update-ledger`, `validate` (900005); `generate-reference` (900006);
  `surface-delta` (900008). Each owner adds one command module and one table row.
- Bin: `drm-copilot-docs` in `packages/mcp-server/package.json`, bundled by the existing esbuild
  step (1020).
- Schemas: `schemas/docs/v1/<name>.schema.json`; examples: `examples/docs/v1/`.
- MCP tools (900007): `run_docs_check`, `run_docs_inventory`, `run_docs_coverage`,
  `update_docs_ledger`, `generate_docs_reference`, `validate_docs_artifacts`.
- Roles (900009): `docs-architect`, `docs-author`, `docs-reconciler`, `docs-coverage-reviewer`.
- Surface element kinds: `cli-command`, `cli-option`, `http-route`, `config-key`, `public-symbol`,
  `architecture-component`. Element identifiers are deterministic, derived from kind, path and
  declaration (the identity rule mirrors the discovery runtime's findings identities).
- Ledger dispositions: `documented` (requires at least one page binding), `excluded` (requires a
  rationale), `deferred` (requires an owner and a target).
- Parity dimensions: `exists`, `accurate`, `example_present`, `owner_assigned`, `diataxis_mode`.
- Page front matter fields: `owner`, `last_reviewed`, `audience`, `diataxis_mode`, `surface_refs`.
- Diataxis mode values: `tutorial`, `how-to`, `reference`, `explanation`.
- Generated-block markers: `<!-- docs:generated:start id=<element-id> -->` and
  `<!-- docs:generated:end id=<element-id> -->`.
- Hooks: PowerShell only.

### Decisions carried from the first preparation of 1020 and 1021 (language-independent)

- A seventh schema file, `schemas/docs/v1/common.schema.json` (definitions only, `$id`
  `urn:drm-copilot:docs:1.0.0:common`), holds shared definitions; the six artifact schema names
  are unchanged. Evidence pins are stored as one collection document.
- The neutrality test configures consumer identifiers only as SHA-256 digests, never as text.
- `extensions/drm-copilot/resources/templates/` is not a push-down root: files there ship in the
  bundle, but no command copies them into a consumer repository. Delivery of consumer
  configuration and the 900008 workflow template must use a path a push-down command copies, or a
  `drm-copilot-docs init` option that writes them; 1020's re-preparation decides which, and
  1021/900008 follow it.
- Property tests use the repository's seeded generator pattern; no new property-testing
  dependency. Under TypeScript, research confirms whether `fast-check` is already approved; if it
  is not, use a seeded deterministic generator.
- Execution should run in the item worktree, not an isolated executor worktree, because the batch
  budget otherwise denies the fourth production file.
- `quality-tiers.yml` exists at the repository root; new code areas are classified there if its
  schema covers extension source directories (research confirms).

Withdrawn with the Python design: Python package tier entries, `itertools`-based Python property
tests, the Python wheel build script, `tests/schemas/docs/` Python schema tests (schema tests move
to Jest), and the PyMarkdown base configuration.

### Reuse of the merged discovery runtime

Language-neutral reuse only (A7): `schemas/discovery/v2/common.schema.json`,
`evidence-reference.schema.json`, `validation-receipt.schema.json`,
`extension-result-manifest.schema.json`, `inventory-snapshot.schema.json`; the documented analyzer
guarantees in `docs/engineering/legacy-discovery-and-parity/analyzers.md` (captured inputs,
deterministic identities, no value leakage, bounded parsing, diagnostics over guesses), which the
TypeScript analyzers adopt as requirements. Python modules under
`packages/discovery-runtime/src/drm_copilot_discovery/` are design references only.

### Cross-feature conflict surface

Children create disjoint new modules. The shared files that more than one child edits, all
append-only: `extensions/drm-copilot/src/docs/cli/docs-cli.ts` subcommand table (1020, 1021,
900003, 900005, 900006, 900008), `extensions/drm-copilot/src/docs/analyzers/` registry module
(900003, 900004), `packages/mcp-server/package.json` and the esbuild script (1020 only),
`quality-tiers.yml` if applicable. Append-only conflicts are resolved inside the child's
remediation loop.

## Child Feature Specifications

Each specification lists the planned files, acceptance criteria and complexity band. File names
below are kebab-case TypeScript modules; each child's research may refine them but may not change
the naming contract without an epic-level update. No test creates temporary files: pure cores take
in-memory path-to-content maps and I/O stays in thin command modules.

### 1020 - docs-profile-and-artifact-schemas (wave 0, C3)

Band rationale: defines the contracts every other child consumes (schemas, element model, analyzer
protocol, CLI entry and distribution).

Files (create), under `extensions/drm-copilot/src/docs/`:
- `profile/profile-models.ts` (audiences, documentation roots, surface selection, page owners,
  Diataxis policy, completion gates), `profile/profile.ts` (load and validate)
- `schema/schema-validation.ts` (docs v1 schema validation, including references into discovery v2
  `common`), `schema/schema-resources.ts` (schema loading from the bundle)
- `surface/surface-models.ts` (element kinds and deterministic identities)
- `analyzers/analyzer-contract.ts` (analyzer interface and registry table)
- `cli/docs-cli.ts` (entry and subcommand table), `cli/init-command.ts`,
  `cli/validate-profile-command.ts`
- `schemas/docs/v1/docs-profile.schema.json`, `surface-inventory-snapshot.schema.json`,
  `docs-coverage-ledger.schema.json`, `docs-parity-matrix.schema.json`,
  `docs-evidence-pin.schema.json`, `docs-validation-receipt.schema.json`, `common.schema.json`
- `examples/docs/v1/` (one example per artifact schema)
- Tests under `extensions/drm-copilot/test/docs/` mirroring each module, a schema test module, a
  property module for identities, and a neutrality test

Files (edit): `packages/mcp-server/package.json` (`bin` entry `drm-copilot-docs`, `files`),
`packages/mcp-server/esbuild-mcp-server.cjs` (second entry point), schema bundling into the
package resources (research confirms the mechanism the discovery schemas use).

Acceptance criteria:
- Every example under `examples/docs/v1/` validates against its schema; each schema rejects a
  missing required field and an unknown disposition or element kind.
- `drm-copilot-docs validate-profile` exits 0 for the example profile and non-zero with a message
  naming the failing field for an invalid profile; `drm-copilot-docs init` emits a starter profile
  that validates.
- Element identifiers are deterministic (property test).
- A neutrality test fails when a configured consumer identifier digest matches text under
  `extensions/drm-copilot/src/docs/` or `schemas/docs/`.
- The bundled `drm-copilot-docs` bin runs under Node.js 18 without Python on the path.
- No new Python file is added; no new direct runtime dependency is added without an owner question.
- Line coverage >= 85% and branch coverage >= 75% for `src/docs/`.

### 1021 - docs-page-quality-checker (wave 1, C3)

Band rationale: rule logic plus configuration artifacts crossing schema, CLI and consumer-config
boundaries.

Files (create), under `extensions/drm-copilot/src/docs/page-check/`: `front-matter.ts` (bounded
front-matter parser for the documented field subset), `links.ts` (relative links and heading
anchors), `diataxis.ts` (mode rules), `orphans.ts`, `config.ts`, `report.ts` (deterministic
findings, text and JSON); `docs/cli/check-command.ts`; `schemas/docs/v1/page-metadata.schema.json`;
base consumer configuration (`.markdownlint-cli2.jsonc`, `.vale.ini`, `styles/DocsBase/` rules and
an empty consumer-owned vocabulary file) at the delivery path chosen by 1020; tests mirrored under
`extensions/drm-copilot/test/docs/page-check/`.

Files (edit): `docs/cli/docs-cli.ts` (one table row).

Acceptance criteria:
- Missing or malformed front-matter fields, a broken relative link, a missing heading anchor, a
  Diataxis mode mismatch and an orphan page each produce a distinct finding code naming the file.
- `drm-copilot-docs check` exits 0 on a clean page set and non-zero when any finding is present;
  JSON output ordering is deterministic.
- `page-check/` imports nothing from `ledger/`, `analyzers/` or `reference/` (enforced by the
  extension's architecture-boundary check or a test).
- No consumer vocabulary or repository name ships in the base configuration.
- Line coverage >= 85% and branch coverage >= 75%.

### 900003 - docs-surface-analyzers-python-config (wave 1, C4)

Band rationale: lexical extraction of Python and configuration surfaces from TypeScript without a
Python parser; ambiguity in what counts as public surface; research-heavy.

Files (create), under `extensions/drm-copilot/src/docs/analyzers/`: `python-tokens.ts` (bounded
Python lexer), `python-cli.ts` (argparse, Click, Typer), `python-http.ts` (FastAPI and Flask route
decorators), `python-public-api.ts` (`__all__` and public top-level definitions),
`config-files.ts` (`pyproject.toml` script and tool tables, `.env` keys without values, JSON Schema
properties, YAML keys; bounded key scanners), `architecture.ts` (packages, modules and import
edges; optional import of an existing discovery inventory snapshot JSON), `snapshot-builder.ts`
(revision-pinned snapshot with input digests); `docs/cli/inventory-command.ts`; tests mirrored
under `extensions/drm-copilot/test/docs/analyzers/`.

Files (edit): `analyzers/analyzer-contract.ts` registry (append), `docs/cli/docs-cli.ts` (row).

Acceptance criteria:
- Each analyzer emits the expected elements for an in-memory fixture covering argparse, Click,
  Typer, FastAPI, Flask, `pyproject.toml`, `.env`, JSON Schema and YAML inputs.
- Re-running over identical bytes produces a byte-identical snapshot (property test).
- No configuration value is exported; only keys and shapes.
- An input above the size bound, or a construct the lexer cannot classify, yields a diagnostic,
  not a partial or guessed result.
- The snapshot validates against `surface-inventory-snapshot.schema.json`.
- Line coverage >= 85% and branch coverage >= 75%.

### 900004 - docs-surface-analyzers-typescript-dotnet (wave 1, C4)

Band rationale: lexical extraction for two further ecosystems without a compiler at runtime;
ambiguous boundaries (decorators, minimal APIs, re-exports). No feature depends on it (A1).

Files (create), under `extensions/drm-copilot/src/docs/analyzers/`: `typescript-tokens.ts`,
`typescript-cli.ts` (Commander and yargs), `typescript-http.ts` (Express and Fastify),
`typescript-exports.ts` (package entry-point exports), `csharp-tokens.ts`, `dotnet-http.ts`
(attribute routes and minimal-API `Map*` calls), `dotnet-config.ts` (`appsettings*.json` keys),
`dotnet-public-api.ts` (public types and members), `extension-import.ts` (other stacks through
discovery extension-result manifest JSON); tests mirrored under
`extensions/drm-copilot/test/docs/analyzers/`.

Files (edit): `analyzers/analyzer-contract.ts` registry (append).

Acceptance criteria:
- Each analyzer emits the expected elements for in-memory TypeScript and C# fixtures.
- An extension-result manifest whose captured-input digest does not match is rejected with a
  diagnostic; a matching manifest is merged as inert data.
- The `typescript` compiler package is not a runtime dependency of the bundle.
- Determinism property test and bounded-input diagnostic as in 900003.
- Line coverage >= 85% and branch coverage >= 75%.

### 900005 - docs-coverage-ledger-and-receipt (wave 1, C4)

Band rationale: the correspondence core; staleness and receipt semantics carry the epic's gate
invariant.

Files (create), under `extensions/drm-copilot/src/docs/ledger/`: `ledger-models.ts`,
`ledger-rules.ts`, `parity-models.ts`, `parity-rules.ts`, `parity-scoring.ts`,
`evidence-pins.ts`, `staleness.ts`, `receipt.ts`, `validation.ts` (modes `profile`, `ledger`,
`matrix`, `docs-complete`), `mutation.ts` (single write boundary), `coverage-report.ts`;
`docs/cli/coverage-command.ts`, `docs/cli/update-ledger-command.ts`, `docs/cli/validate-command.ts`;
tests mirrored under `extensions/drm-copilot/test/docs/ledger/` plus a `docs-complete` integration
test.

Files (edit): `docs/cli/docs-cli.ts` (three rows).

Acceptance criteria:
- A ledger missing a disposition for any inventoried element fails validation naming the element;
  `excluded` without rationale and `deferred` without owner or target fail.
- A pin whose recorded digest differs from the current snapshot marks the bound page stale.
- `drm-copilot-docs validate --mode docs-complete` emits a receipt on success; with one
  undocumented element and one stale page it exits non-zero and the message names both.
- Ledger and matrix writes happen only through `ledger/mutation.ts`; `update-ledger` is the only
  mutating subcommand.
- Line coverage >= 85% and branch coverage >= 75%.

### 900006 - docs-reference-generator (wave 2, C3)

Band rationale: deterministic rendering with a merge invariant (prose preservation).

Files (create), under `extensions/drm-copilot/src/docs/reference/`: `page-plan.ts`,
`render-cli.ts`, `render-http.ts`, `render-config.ts`, `render-api.ts`, `markers.ts`,
`front-matter.ts` (conforming to `page-metadata.schema.json`, `diataxis_mode: reference`,
`surface_refs`), `writer.ts` (I/O, dry-run diff); `docs/cli/generate-reference-command.ts`; tests
mirrored under `extensions/drm-copilot/test/docs/reference/`.

Files (edit): `docs/cli/docs-cli.ts` (row).

Acceptance criteria:
- Rendering the same snapshot twice is byte-identical (property test).
- Prose outside generated markers is preserved across regeneration (property test); a removed
  element's block is removed and reported.
- Every generated page passes the 1021 checker with zero findings (integration test), and the
  generated-block HTML comments do not trip the base markdownlint configuration.
- Without `--write` the command writes nothing and prints the planned changes.
- Line coverage >= 85% and branch coverage >= 75%.

### 900007 - docs-mcp-tools (wave 3, C3)

Band rationale: cross-module contract following the established discovery MCP pattern.

Files (create), under `extensions/drm-copilot/src/`: `mcp-docs-tool-definitions.ts`,
`mcp-handlers/docs-handlers.ts`, `mcp-tool-inputs-docs.ts`; tests under
`extensions/drm-copilot/test/`.

Files (edit): `extensions/drm-copilot/src/mcp-tools.ts`,
`extensions/drm-copilot/src/repo-automation-tool-names.ts`; every existing test that enumerates
the MCP tool set (research identifies them and the plan records each disposition).

Acceptance criteria:
- Each of the six tools validates its input, calls the matching `docs/` module in process, and
  returns structured output including findings and a status.
- Invalid input is rejected before any file is read.
- `update_docs_ledger` is the only mutating tool and routes through `ledger/mutation.ts`.
- Line coverage >= 85% and branch coverage >= 75% on the new modules.

### 900008 - docs-enforcement-and-ci (wave 2, C3)

Band rationale: gate behavior across CI template, hook and review agent; alters an existing
review contract.

Files (create):
- Consumer reusable workflow `_docs-quality.yml` (runs `drm-copilot-docs check` and
  `drm-copilot-docs validate --mode docs-complete` through `npx`), at the delivery path decided by
  1020
- `extensions/drm-copilot/src/docs/surface-delta/surface-delta.ts`,
  `docs/cli/surface-delta-command.ts` (`surface-delta --base <ref>`)
- `.claude/hooks/enforce-docs-complete-gate.ps1` (opt-in; denies the epic integration-to-`main`
  merge unless a passing receipt pins the head revision; reads the receipt JSON, no Python)
- Tests: Jest for surface delta, Pester suite for the hook under `tests/scripts/claude-hooks/`

Files (edit): `.claude/settings.json` (hook registration), `.claude/agents/feature-review.md` and
its mirrors on the Codex, Copilot and push-down surfaces (surface-change-without-ledger-change
check), `docs/cli/docs-cli.ts` (row).

Acceptance criteria:
- With the gate disabled (default) the hook allows every call; enabled, it denies when the receipt
  is absent, failing, or pinned to another revision, and the deny text names the reason.
- `surface-delta` reports an added CLI command with no ledger change and reports nothing when the
  ledger records it.
- The workflow template requires Node.js only.
- Mirror parity checks pass for the edited `feature-review` surfaces.

### 900009 - docs-authoring-workflow (wave 4, C4)

Band rationale: role design with tool-scope constraints across four runtime surfaces.

Files (create):
- Agents: `.claude/agents/docs-architect.md`, `docs-author.md`, `docs-reconciler.md`,
  `docs-coverage-reviewer.md`; tool allowlists use the docs MCP tools and grant no direct Write to
  ledger or matrix artifacts; no `memory:` frontmatter (it grants Write and Edit).
- Skills under `.claude/skills/`: `documentation-workflow`, `docs-init`, `docs-inventory-surface`,
  `docs-plan-ia`, `docs-author-page` (with page templates: tutorial, how-to, explanation,
  cli-reference, http-reference, config-reference, api-reference, architecture-overview),
  `docs-reconcile-behavior`, `docs-review-coverage`, `docs-validate`.
- Mirrors produced by the existing repository generators (existing Python tooling, called, not
  extended): `.github/agents/`, `.github/skills/`, `.codex/agents/` variants, `.agents/skills/`, and
  the push-down trees under `extensions/drm-copilot/resources/claude-customizations/` and
  `extensions/drm-copilot/resources/codex-and-agents-customizations/`.
- A SubagentStop output check for the four roles (PowerShell) with a Pester suite.

Files (edit): `config/orchestration-routing.json` (role routing entries), `.claude/settings.json`
(hook registration).

Acceptance criteria:
- Each role's tool list excludes Write and Edit on ledger and matrix paths; a test asserts it.
- Every skill references only MCP tools and subcommands defined in 1020-900007.
- Mirror and push-down parity tests pass for all new agents and skills.
- The SubagentStop check blocks a role output that lacks its required result fields.

### 900010 - documentation-estate-template-and-onboarding (wave 5, C3)

Band rationale: composition of all prior features into a template, onboarding and an end-to-end
test.

Files (create):
- `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` and
  `README.md` (wave 0 foundation: profile, IA, page templates, metadata, docs CI; wave 1 page
  families; final docs-complete exit gate)
- `docs/engineering/documentation-estate/README.md`, `architecture.md`, `consumer-onboarding.md`,
  `cli-reference.md`, `workflow.md`
- `extensions/drm-copilot/test/docs/end-to-end-documentation-estate.test.ts` (in-memory fixture
  repository with one undocumented command and one stale page)
- A Jest test that the template manifest has a cycle-free DAG under the epic manifest rules

Acceptance criteria:
- The end-to-end test runs inventory, ledger, generation and `docs-complete` validation; it fails
  naming the undocumented command and the stale page, and passes after both are fixed.
- The template is accepted by `/epic-plan` as a manifest path.
- The onboarding guide documents every `drm-copilot-docs` subcommand and MCP tool with an example,
  and states that a destination repository needs Node.js only.

## Decomposition Rationale

- Contracts first: 1020 fixes the schemas, element model, analyzer interface and CLI entry so the
  four wave-1 features build in parallel against stable contracts.
- 1021 depends on 1020 because its `check` subcommand registers in 1020's CLI entry and its
  schema references 1020's `common` definitions (this edge was added with the language directive;
  under the withdrawn Python design 1021 was an independent package in wave 0).
- 900006 depends on 1021 because generated pages must satisfy the page-metadata schema and checker.
- 900007 waits for the modules it calls; 900004 is excluded because it adds analyzers behind the
  existing `inventory` subcommand.
- 900008 depends on the checker and the receipt only.
- 900009 depends on the MCP tools its roles are restricted to.
- 900010 composes everything and depends on the authoring workflow and enforcement.

## Planned Waves

Computed with `scripts/dev_tools/epic_wave_computation.py`:

- Wave 0: 1020
- Wave 1: 1021, 900003, 900004, 900005
- Wave 2: 900006, 900008
- Wave 3: 900007
- Wave 4: 900009
- Wave 5: 900010

Execution concurrency cap (`max_parallel_features`): 3, set by the coordinator's pacing directive.

## Risks

- Lexical Python and C# scanning in TypeScript is less precise than a parser; unclassified
  constructs surface as diagnostics. This is the cost of the no-new-Python directive for 900003
  and 900004.
- Bundle size and cold-start time of `@danmoisan/drm-copilot-mcp` grow with the docs modules.
- Append-only conflicts in `docs/cli/docs-cli.ts` and the analyzer registry across wave-1 children.
- Lexical analyzers cannot see dynamic registration; such elements surface as diagnostics.
