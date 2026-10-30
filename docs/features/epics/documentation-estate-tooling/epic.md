---
epic: documentation-estate-tooling
integration_branch: epic/documentation-estate-tooling-integration
created_at: 2026-10-30T20:10:00Z
# PLANNING STATE. issue_num values of the form 9000NN are placeholders until each child's
# promotion receipt is back-filled; depends_on uses issue_num values. The final resolved manifest
# replaces every placeholder before the kickoff artifact is written.
intent:
  epic_type: enabler
  business_outcome_hypothesis: A consumer repository can inventory its documentable surface, generate reference pages, author narrative pages through constrained roles, and prove documentation correspondence with a docs-complete receipt, without bespoke per-repository tooling or manual counting of drift.
  leading_indicators:
    - A fixture repository with one undocumented command and one stale page fails docs-complete validation naming both elements, and passes after the ledger and page are updated.
    - Reference pages generated twice from the same inventory snapshot are byte-identical, and hand-written prose outside generated blocks survives regeneration.
    - No consumer identifier appears in framework source.
  nfrs:
    - Framework code is domain-neutral; all repository specificity is runtime configuration in the docs profile.
    - Analyzers are read-only, lexical, bounded and deterministic; no analyzer executes, compiles or installs consumer code.
    - Line coverage >= 85% and branch coverage >= 75% on every new Python and TypeScript module; files stay within the 500/700/800 line tiers.
features:
  - issue_num: 1020
    feature_folder: 2026-10-30-docs-profile-and-artifact-schemas-1020
    depends_on: []
  - issue_num: 900002
    feature_folder: docs-page-quality-checker
    depends_on: []
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
    depends_on: [1020, 900002]
  - issue_num: 900007
    feature_folder: docs-mcp-tools
    depends_on: [900002, 900003, 900005, 900006]
  - issue_num: 900008
    feature_folder: docs-enforcement-and-ci
    depends_on: [900002, 900005]
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

## Assumptions Pending Owner Confirmation

None of the following has been approved by the owner. Each is a provisional default.

- **A1 - Analyzer scope.** Python/configuration analyzers (900003) and TypeScript/.NET analyzers
  (900004) are both in the epic as separate features. No other feature depends on 900004, so it may
  land later; stacks outside the built-in set enter through the discovery extension-result
  manifest.
- **A2 - Docs-site build.** A docs-site build (MkDocs or similar) is out of scope.
- **A3 - Issue #5 `markdown-toolchain`.** This epic stays separate from issue #5. It would reuse an
  existing Markdown QC configuration; none exists on `main` at planning time (no `.pymarkdown*`,
  `.vale.ini` or `styles/` at the repository root), so 900002 ships a base PyMarkdown configuration
  and a base Vale style that issue #5 may adopt.
- **A4 - Integration branch.** `epic/documentation-estate-tooling-integration` starts from
  `origin/main`, which contains the merged discovery runtime (#980, PR #1014).
- **A5 - Package placement (planner decision).** Documentation-specific code lives in a new package
  `packages/docs-runtime` (import name `drm_copilot_docs`) that depends on
  `packages/discovery-runtime` (`drm_copilot_discovery`) as a library. Discovery types are reused,
  not reshaped. The page checker is a separate, independently installable package
  `packages/docs-page-check` (`drm_copilot_docs_check`), because consumers may adopt it without the
  ledger engine.
- **A6 - MCP placement (planner decision).** All docs MCP tools are delivered by one feature
  (900007) after the CLI commands they wrap exist, so the shared TypeScript registration files are
  edited once.

## Scope

| Wave | issue_num | Feature | Band | Purpose |
|---|---|---|---|---|
| 0 | 1020 | docs-profile-and-artifact-schemas | C3 | Docs profile, versioned schemas, surface element model, analyzer contract, `drm_copilot_docs` package skeleton. |
| 0 | 900002 | docs-page-quality-checker | C3 | Consumer-installable page checker (front matter, links/anchors, Diataxis mode, orphans) with base PyMarkdown and Vale configuration. |
| 1 | 900003 | docs-surface-analyzers-python-config | C4 | Python CLI, HTTP route, public API, configuration and architecture analyzers; `dev.docs.inventory`. |
| 1 | 900004 | docs-surface-analyzers-typescript-dotnet | C4 | TypeScript CLI/route/export and .NET route/config/public-type analyzers; extension-manifest import. |
| 1 | 900005 | docs-coverage-ledger-and-receipt | C4 | Coverage ledger, parity matrix, evidence pins and staleness, `docs-complete` receipt. |
| 1 | 900006 | docs-reference-generator | C3 | Deterministic reference-page renderer with marker-delimited generated blocks. |
| 2 | 900007 | docs-mcp-tools | C3 | MCP tools wrapping the `dev.docs.*` commands. |
| 2 | 900008 | docs-enforcement-and-ci | C3 | Consumer workflow template, surface-delta check, opt-in integration-PR gate, feature-review check. |
| 3 | 900009 | docs-authoring-workflow | C4 | Four documentation roles, eight skills, page templates, mirrored to all surfaces. |
| 4 | 900010 | documentation-estate-template-and-onboarding | C3 | `documentation-estate` epic template, onboarding docs, end-to-end fixture test. |

## Non-Goals

- Runtime characterization and acceptance-scenario generation for documentation.
- Protected-authority-store hook enforcement for documentation artifacts (the receipt is
  CI-verified; stronger enforcement can follow later).
- Mechanical judgment of prose correctness. Tools prove a page exists, carries metadata and pins a
  current symbol; the reviewer role judges accuracy.
- A docs-site build (A2).
- Markdown QC adoption for this repository's own documentation (issue #5, A3).
- Changes to discovery runtime behavior. A defect found in `drm_copilot_discovery` during this epic
  is filed separately unless a child feature cannot proceed without the fix.

## Shared Design

### Naming contract (fixed for all children)

- Packages: `packages/docs-runtime` (`drm_copilot_docs`), `packages/docs-page-check`
  (`drm_copilot_docs_check`).
- Schemas: `schemas/docs/v1/<name>.schema.json`; examples: `examples/docs/v1/`.
- Console commands (one module per command family, so children edit disjoint modules):
  `dev.docs.init`, `dev.docs.validate-profile` (1020); `dev.docs.check` (900002);
  `dev.docs.inventory` (900003, 900004 adds analyzers only); `dev.docs.coverage`,
  `dev.docs.update-ledger`, `dev.docs.validate` (900005); `dev.docs.generate-reference` (900006);
  `dev.docs.surface-delta` (900008).
- MCP tools (900007): `run_docs_check`, `run_docs_inventory`, `run_docs_coverage`,
  `update_docs_ledger`, `generate_docs_reference`, `validate_docs_artifacts`.
- Roles (900009): `docs-architect`, `docs-author`, `docs-reconciler`, `docs-coverage-reviewer`.
- Surface element kinds: `cli-command`, `cli-option`, `http-route`, `config-key`, `public-symbol`,
  `architecture-component`. Element identifiers are deterministic, derived from kind, path and
  declaration, following `drm_copilot_discovery.analyzer.findings`.
- Ledger dispositions: `documented` (requires at least one page binding), `excluded` (requires a
  rationale), `deferred` (requires an owner and a target).
- Parity dimensions: `exists`, `accurate`, `example_present`, `owner_assigned`, `diataxis_mode`.
- Page front matter fields: `owner`, `last_reviewed`, `audience`, `diataxis_mode`, `surface_refs`.
- Generated-block markers: `<!-- docs:generated:start id=<element-id> -->` and
  `<!-- docs:generated:end id=<element-id> -->`.

### Decisions recorded during preparation of 1020 (binding on later children)

- A seventh schema file, `schemas/docs/v1/common.schema.json` (definitions only, `$id`
  `urn:drm-copilot:docs:1.0.0:common`), holds shared definitions; the six artifact schema names
  are unchanged. Evidence pins are stored as one collection document.
- Diataxis mode values are exactly `tutorial`, `how-to`, `reference`, `explanation` (shared by
  1020 and 900002).
- Schema tests live under `tests/schemas/docs/`.
- `quality-tiers.yml` exists at the repository root; each new package is classified there
  (`packages/docs-runtime` is T2), which also updates the tier classification test.
- Property tests use deterministic `itertools` enumerations; `hypothesis` is not an approved
  dependency.
- Distribution follows the discovery runtime's wheel pattern: a build script stages schema copies
  under the package's `_resources` and writes a wheel; consumers install the discovery and docs
  wheels. This resolves the installation risk below for `drm_copilot_docs`.
- The neutrality test configures consumer identifiers only as SHA-256 digests, never as text.

### Reuse of the merged discovery runtime

Verified present on `origin/main` at planning time and cited for reuse:
`analyzer/input_capture.py` (captured bytes and digests), `analyzer/findings.py` (deterministic
identities), `analyzer/registry.py` and `analyzer/pipeline.py` (analyzer selection pattern),
`analyzer/dependency_python.py`, `analyzer/configuration.py`, `analyzer/csharp_tokens.py`,
`analyzer/csharp_declarations.py`, `extension_results.py` and `extension_validation.py`
(extension-result manifests), `revision_rules.py` and `evidence_rules.py` (revision pins),
`schema_validation.py`, `mutation_io.py` (single mutation boundary), all under
`packages/discovery-runtime/src/drm_copilot_discovery/`; schemas
`schemas/discovery/v2/common.schema.json`, `evidence-reference.schema.json`,
`validation-receipt.schema.json`, `extension-result-manifest.schema.json`. Each child's research
confirms the exact symbols it consumes.

### Cross-feature conflict surface

Children edit disjoint new modules. The shared files that more than one child edits, all
append-only: root `pyproject.toml` `[tool.poetry.scripts]` and path dependencies (1020, 900002,
900003, 900005, 900006, 900008), `poetry.lock` (1020, 900002),
`packages/docs-runtime/src/drm_copilot_docs/analyzer_contract.py` registry table (900003, 900004),
`quality-tiers.yml` and its tier classification test (1020, 900002).
Append-only conflicts are resolved inside the child's remediation loop.

## Child Feature Specifications

Each specification lists the planned files, acceptance criteria and complexity band. Test files
mirror production paths under `tests/` per the repository test-location rule; no test creates
temporary files, so pure cores take in-memory path-to-content mappings and I/O stays in thin CLI
modules. Each child's research may refine file names; it may not change the naming contract above
without an epic-level update.

### 1020 - docs-profile-and-artifact-schemas (wave 0, C3)

Band rationale: defines the contracts every other child consumes (schemas, element model,
analyzer protocol); cross-module invariant work, not research-heavy.

Files (create):
- `packages/docs-runtime/pyproject.toml`, `packages/docs-runtime/README.md`
- `packages/docs-runtime/src/drm_copilot_docs/__init__.py`
- `packages/docs-runtime/src/drm_copilot_docs/profile_models.py` (profile dataclasses: audiences,
  documentation roots, surface selection, page owners, Diataxis policy, completion gates)
- `packages/docs-runtime/src/drm_copilot_docs/profile.py` (load and validate a profile)
- `packages/docs-runtime/src/drm_copilot_docs/schema_validation.py` (docs v1 schema loading with
  references into discovery v2 `common`)
- `packages/docs-runtime/src/drm_copilot_docs/surface_models.py` (surface element kinds, identities)
- `packages/docs-runtime/src/drm_copilot_docs/analyzer_contract.py` (analyzer protocol and
  registry table)
- `packages/docs-runtime/src/drm_copilot_docs/cli.py` (`dev.docs.init`, `dev.docs.validate-profile`)
- `schemas/docs/v1/docs-profile.schema.json`, `surface-inventory-snapshot.schema.json`,
  `docs-coverage-ledger.schema.json`, `docs-parity-matrix.schema.json`,
  `docs-evidence-pin.schema.json`, `docs-validation-receipt.schema.json`
- `examples/docs/v1/docs-profile.example.json` and one example per schema
- `tests/docs_runtime/test_profile.py`, `test_profile_properties.py`, `test_surface_models.py`,
  `test_analyzer_contract.py`, `test_cli.py`, `test_neutrality.py`
- `tests/schemas/docs/ (schema tests)`

Files (edit): `pyproject.toml` (path dependency, two scripts), `poetry.lock`; package registration
wherever the discovery runtime is registered for bundling (research confirms the mechanism).

Acceptance criteria:
- Every example under `examples/docs/v1/` validates against its schema; each schema rejects a
  missing required field and an unknown disposition or element kind.
- `dev.docs.validate-profile` exits 0 for the example profile and non-zero with a message naming
  the failing field for an invalid profile; `dev.docs.init` emits a starter profile that validates.
- Element identifiers are deterministic (property test: same kind, path and declaration yield the
  same identifier; distinct inputs yield distinct identifiers).
- A neutrality test fails when a configured consumer identifier appears under
  `packages/docs-runtime/src/` or `schemas/docs/`.
- Line coverage >= 85% and branch coverage >= 75% for `drm_copilot_docs`.

### 900002 - docs-page-quality-checker (wave 0, C3)

Band rationale: a port of a proven design into a new package with rule logic and configuration
artifacts; bounded but crosses package, schema and push-down boundaries.

Files (create):
- `packages/docs-page-check/pyproject.toml`, `packages/docs-page-check/README.md`
- `packages/docs-page-check/src/drm_copilot_docs_check/__init__.py`, `front_matter.py`, `links.py`
  (relative links and heading anchors), `diataxis.py` (mode rules), `orphans.py`, `config.py`,
  `report.py` (deterministic findings, text and JSON), `cli.py` (`dev.docs.check`)
- `schemas/docs/v1/page-metadata.schema.json`
- Base consumer configuration in the push-down template tree:
  `extensions/drm-copilot/resources/templates/docs-quality/.pymarkdown.json`,
  `extensions/drm-copilot/resources/templates/docs-quality/.vale.ini`,
  `extensions/drm-copilot/resources/templates/docs-quality/styles/DocsBase/` (base rules) and an
  empty consumer-owned vocabulary file
- `tests/docs_page_check/test_front_matter.py`, `test_links.py`, `test_diataxis.py`,
  `test_diataxis_properties.py`, `test_orphans.py`, `test_report.py`, `test_cli.py`

Files (edit): `pyproject.toml` (path dependency, `dev.docs.check`), `poetry.lock`.

Acceptance criteria:
- Missing or malformed front-matter fields, a broken relative link, a missing heading anchor, a
  Diataxis mode mismatch and an orphan page each produce a distinct finding code naming the file.
- `dev.docs.check` exits 0 on a clean page set and non-zero when any finding is present; JSON output
  ordering is deterministic.
- No consumer vocabulary or repository name ships in the base Vale style; vocabulary is a
  consumer-owned file.
- The package imports nothing from `drm_copilot_docs` (independent installability).
- Line coverage >= 85% and branch coverage >= 75% for `drm_copilot_docs_check`.

### 900003 - docs-surface-analyzers-python-config (wave 1, C4)

Band rationale: novel lexical extraction across several frameworks with ambiguity in what counts as
public surface; research-heavy.

Files (create), under `packages/docs-runtime/src/drm_copilot_docs/analyzers/`: `__init__.py`,
`python_cli.py` (argparse, Click, Typer via `ast`, no execution), `python_http.py` (FastAPI and
Flask route decorators), `python_public_api.py` (`__all__` and public top-level definitions),
`config_files.py` (`pyproject.toml` scripts and tool tables, `.env` keys without values, JSON
Schema properties, YAML keys), `architecture.py` (packages, modules and dependency edges reusing
`drm_copilot_discovery.analyzer.dependency_python`), `snapshot_builder.py` (revision-pinned
snapshot using discovery input capture); `packages/docs-runtime/src/drm_copilot_docs/cli_inventory.py`
(`dev.docs.inventory --analyzer <id>`). Tests under `tests/docs_runtime/analyzers/` (one module per
analyzer plus a properties module) and `tests/docs_runtime/test_cli_inventory.py`.

Files (edit): `analyzer_contract.py` (registry entries), `pyproject.toml` (script).

Acceptance criteria:
- Each analyzer emits the expected elements for an in-memory fixture covering argparse, Click,
  Typer, FastAPI, Flask, `pyproject.toml`, `.env`, JSON Schema and YAML inputs.
- Re-running over identical bytes produces a byte-identical snapshot (property test).
- No configuration value is exported; only keys and shapes.
- An input above the size bound yields a diagnostic, not a partial result.
- The snapshot validates against `surface-inventory-snapshot.schema.json` and records the captured
  input digests.
- Line coverage >= 85% and branch coverage >= 75% for the analyzers.

### 900004 - docs-surface-analyzers-typescript-dotnet (wave 1, C4)

Band rationale: lexical extraction for two further ecosystems without executing a compiler;
ambiguous boundaries (decorators, minimal APIs, re-exports). No feature depends on it (A1).

Files (create), under `packages/docs-runtime/src/drm_copilot_docs/analyzers/`: `typescript_cli.py`
(Commander and yargs), `typescript_http.py` (Express and Fastify route registrations),
`typescript_exports.py` (package entry-point exports), `dotnet_http.py` (ASP.NET attribute routes
and minimal-API `Map*` calls, reusing discovery `csharp_tokens` and `csharp_declarations`),
`dotnet_config.py` (`appsettings*.json` keys), `dotnet_public_api.py` (public types and members),
`extension_import.py` (other stacks through discovery extension-result manifests). Tests under
`tests/docs_runtime/analyzers/`.

Files (edit): `analyzer_contract.py` (registry entries).

Acceptance criteria:
- Each analyzer emits the expected elements for an in-memory TypeScript and C# fixture.
- An extension-result manifest whose captured-input digest does not match is rejected with a
  diagnostic; a matching manifest is merged as inert data.
- Determinism property test and bounded-input diagnostic as in 900003.
- Line coverage >= 85% and branch coverage >= 75% for the new analyzers.

### 900005 - docs-coverage-ledger-and-receipt (wave 1, C4)

Band rationale: the correspondence core; staleness and receipt semantics are novel and carry the
epic's gate invariant.

Files (create), under `packages/docs-runtime/src/drm_copilot_docs/`: `ledger_models.py`,
`ledger_rules.py`, `parity_models.py`, `parity_rules.py`, `parity_scoring.py`, `evidence_pins.py`,
`staleness.py`, `receipt.py`, `validation.py` (modes: `profile`, `ledger`, `matrix`,
`docs-complete`), `mutation.py` (single write boundary following discovery `mutation_io`),
`coverage_report.py`, `cli_coverage.py` (`dev.docs.coverage`), `cli_ledger.py`
(`dev.docs.update-ledger`), `cli_validate.py` (`dev.docs.validate`). Tests: one module per
production module under `tests/docs_runtime/`, a properties module for ledger and staleness rules,
and `tests/docs_runtime/test_docs_complete_integration.py`.

Files (edit): `pyproject.toml` (three scripts).

Acceptance criteria:
- A ledger missing a disposition for any inventoried element fails validation naming the element;
  `excluded` without rationale and `deferred` without owner or target fail.
- A pin whose recorded digest differs from the current snapshot marks the bound page stale.
- `dev.docs.validate --mode docs-complete` emits a receipt on success; with one undocumented element
  and one stale page it exits non-zero and the message names both.
- Ledger and matrix writes happen only through `mutation.py`; `dev.docs.update-ledger` is the only
  CLI that mutates the ledger.
- Line coverage >= 85% and branch coverage >= 75%.

### 900006 - docs-reference-generator (wave 1, C3)

Band rationale: deterministic rendering with a merge invariant (prose preservation); bounded.

Files (create), under `packages/docs-runtime/src/drm_copilot_docs/reference/`: `__init__.py`,
`page_plan.py` (element-to-page mapping per profile), `render_cli.py`, `render_http.py`,
`render_config.py`, `render_api.py`, `markers.py` (generated-block parse and merge),
`front_matter.py` (front matter conforming to `page-metadata.schema.json`, `diataxis_mode:
reference`, `surface_refs`), `writer.py` (I/O, dry-run diff);
`packages/docs-runtime/src/drm_copilot_docs/cli_generate.py` (`dev.docs.generate-reference`).
Tests under `tests/docs_runtime/reference/`.

Files (edit): `pyproject.toml` (script).

Acceptance criteria:
- Rendering the same snapshot twice is byte-identical (property test).
- Prose outside generated markers is preserved across regeneration (property test); a removed
  element's block is removed and reported.
- Every generated page passes `drm_copilot_docs_check` with zero findings (integration test).
- Without `--write` the command writes nothing and prints the planned changes.
- Line coverage >= 85% and branch coverage >= 75%.

### 900007 - docs-mcp-tools (wave 2, C3)

Band rationale: cross-language contract (TypeScript tools over Python CLIs) following the
established discovery MCP pattern.

Files (create), under `extensions/drm-copilot/src/`: `mcp-docs-tool-definitions.ts`,
`mcp-handlers/docs-handlers.ts`, `mcp-tool-inputs-docs.ts`, `repo-automation-execute-docs.ts`.
Tests under `extensions/drm-copilot/test/` for each module.

Files (edit): `extensions/drm-copilot/src/mcp-tools.ts`,
`extensions/drm-copilot/src/repo-automation-tool-names.ts`; every existing test that enumerates the
MCP tool set (research identifies them and the plan records each disposition).

Acceptance criteria:
- Each of the six tools validates its input, invokes the matching `dev.docs.*` command, and
  returns structured output including the exit code and findings.
- Invalid input is rejected before any process starts.
- `update_docs_ledger` is the only mutating tool and routes through `dev.docs.update-ledger`.
- TypeScript line coverage >= 85% and branch coverage >= 75% on the new modules.

### 900008 - docs-enforcement-and-ci (wave 2, C3)

Band rationale: gate behavior across CI template, hook and review agent; alters an existing review
contract.

Files (create):
- `extensions/drm-copilot/resources/templates/workflows/_docs-quality.yml` (consumer reusable
  workflow running `dev.docs.check` and `dev.docs.validate --mode docs-complete`)
- `packages/docs-runtime/src/drm_copilot_docs/surface_delta.py`,
  `packages/docs-runtime/src/drm_copilot_docs/cli_surface_delta.py` (`dev.docs.surface-delta --base
  <ref>`: surface elements changed since a base revision without a ledger change)
- `.claude/hooks/enforce-docs-complete-gate.ps1` (opt-in: when the profile enables the integration
  gate, deny the epic integration-to-`main` merge unless a passing receipt pins the head revision;
  PowerShell only, no Python leg)
- Tests: `tests/docs_runtime/test_surface_delta.py`, `test_cli_surface_delta.py`, Pester suite for
  the hook under `tests/scripts/claude-hooks/`

Files (edit): `.claude/settings.json` (hook registration), `.claude/agents/feature-review.md` and its
mirrors on the Codex, Copilot and push-down surfaces (surface-change-without-ledger-change check),
`pyproject.toml` (script).

Acceptance criteria:
- With the gate disabled (default) the hook allows every call; enabled, it denies when the receipt
  is absent, failing, or pinned to another revision, and the deny text names the reason.
- `dev.docs.surface-delta` reports an added CLI command with no ledger change and reports nothing
  when the ledger records it.
- The workflow template passes `actionlint`-equivalent repository checks for workflow files.
- Mirror parity checks pass for the edited `feature-review` surfaces.

### 900009 - docs-authoring-workflow (wave 3, C4)

Band rationale: role design with tool-scope constraints across four runtime surfaces; judgment on
role boundaries and prompt content.

Files (create):
- Agents: `.claude/agents/docs-architect.md`, `docs-author.md`, `docs-reconciler.md`,
  `docs-coverage-reviewer.md`; tool allowlists use the docs MCP tools and grant no direct Write to
  ledger or matrix artifacts; no `memory:` frontmatter (it grants Write and Edit).
- Skills under `.claude/skills/`: `documentation-workflow`, `docs-init`, `docs-inventory-surface`,
  `docs-plan-ia`, `docs-author-page` (with page templates: tutorial, how-to, explanation,
  cli-reference, http-reference, config-reference, api-reference, architecture-overview),
  `docs-reconcile-behavior`, `docs-review-coverage`, `docs-validate`.
- Mirrors generated with the repository generators (`scripts/dev_tools/agentic_sync.py`,
  `scripts/dev_tools/generate_codex_agent_variants.py`): `.github/agents/`, `.github/skills/`,
  `.codex/agents/` variants, `.agents/skills/`, and the push-down trees under
  `extensions/drm-copilot/resources/claude-customizations/` and
  `extensions/drm-copilot/resources/codex-and-agents-customizations/`.
- A SubagentStop output check for the four roles (PowerShell) with a Pester suite.

Files (edit): `config/orchestration-routing.json` (role routing entries), `.claude/settings.json`
(hook registration).

Acceptance criteria:
- Each role's tool list excludes Write and Edit on ledger and matrix paths; a test asserts it.
- Every skill references only MCP tools and commands defined in 900002-900007.
- Mirror and push-down parity tests pass for all new agents and skills.
- The SubagentStop check blocks a role output that lacks its required result fields.

### 900010 - documentation-estate-template-and-onboarding (wave 4, C3)

Band rationale: integration of all prior features into a template, onboarding and an end-to-end
test; mostly composition.

Files (create):
- `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` and
  `README.md` (wave 0 foundation: profile, IA, page templates, metadata, docs CI; wave 1 page
  families; final docs-complete exit gate)
- `docs/engineering/documentation-estate/README.md`, `architecture.md`, `consumer-onboarding.md`,
  `cli-reference.md`, `workflow.md`
- `tests/docs_runtime/test_end_to_end_documentation_estate.py` (in-memory fixture repository with
  one undocumented command and one stale page)
- A test that the template manifest parses under the epic manifest schema

Acceptance criteria:
- The end-to-end test runs inventory, ledger, generation and `docs-complete` validation; it fails
  naming the undocumented command and the stale page, and passes after both are fixed.
- The template parses with a cycle-free DAG and is accepted by `/epic-plan` as a manifest path.
- The onboarding guide documents every `dev.docs.*` command and MCP tool with an example.

## Decomposition Rationale

- Contracts first: 1020 fixes the schemas, element model and analyzer protocol so the four
  wave-1 features build in parallel against stable contracts.
- 900002 is independent (separate package) and runs in wave 0.
- 900006 depends on 900002 because generated pages must satisfy the page-metadata schema and
  checker.
- 900007 waits for the CLIs it wraps; 900004 is excluded from its dependencies because 900004 adds
  analyzers behind the existing `dev.docs.inventory` command.
- 900008 depends on the checker and the receipt only.
- 900009 depends on the MCP tools its roles are restricted to.
- 900010 composes everything and depends on the authoring workflow and enforcement.
- The roles and skills were kept in one feature because the roles preload the skills; most of its
  file volume is generator output.

## Planned Waves

- Wave 0: 1020, 900002
- Wave 1: 900003, 900004, 900005, 900006
- Wave 2: 900007, 900008
- Wave 3: 900009
- Wave 4: 900010

Execution concurrency cap (`max_parallel_features`): 3, set by the coordinator's pacing directive.

## Risks

- Append-only conflicts in `pyproject.toml` and `analyzer_contract.py` across wave-1 children.
- Consumer installation path for the Python packages (how a destination repository runs
  `dev.docs.*` without this repository's Poetry environment) is unresolved; 1020 research must
  establish it, following the discovery runtime's distribution mechanism.
- Lexical analyzers cannot see dynamic registration; such elements surface as diagnostics.
