---
epic: documentation-estate-tooling
integration_branch: epic/documentation-estate-tooling-integration
created_at: 2026-10-30T20:10:00Z
# PLANNING STATE. issue_num values of the form 9000NN are placeholders until each child's
# promotion receipt is back-filled; depends_on uses issue_num values. The final resolved manifest
# replaces every placeholder before the kickoff artifact is written.
intent:
  epic_type: enabler
  business_outcome_hypothesis: A consumer repository can inventory its documentable surface, generate reference pages, author narrative pages through constrained roles, and prove documentation correspondence with a docs-complete receipt, without bespoke per-repository tooling, manual counting of drift, or a Python or Node.js runtime for the pushed-down helpers.
  leading_indicators:
    - A fixture repository with one undocumented command and one stale page fails docs-complete validation naming both elements, and passes after the ledger and page are updated.
    - Reference pages generated twice from the same inventory snapshot are byte-identical, and hand-written prose outside generated blocks survives regeneration.
    - No consumer identifier appears in framework source.
  nfrs:
    - Framework code is domain-neutral; all repository specificity is runtime configuration in the docs profile.
    - Pushed-down skills, skill helpers, hooks and libs are PowerShell (or bash); TypeScript is used only for MCP tools; the epic adds no new Python.
    - Analyzers are read-only, lexical, bounded and deterministic; no analyzer executes, compiles or installs consumer code.
    - Line coverage >= 85% on new PowerShell (Pester; no branch gate) and line >= 85% / branch >= 75% on new TypeScript; files stay within the 500/700/800 line tiers.
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

## Owner Directive: Implementation Language (2026-10-30, refined)

Received through the coordinator during planning; the refined wording replaces the first
directive and binds every child:

> Avoid new Python (existing Python is tolerated: reuse, call or extend in place only). The
> language depends on where the new code runs: (1) anything pushed down to destination repos,
> meaning skills, skill helpers, hooks and libs, must be PowerShell or bash, never TypeScript and
> never Python; (2) TypeScript is ONLY for MCP commands (tools in the MCP server package) and
> extension commands. So a new helper that a skill calls is PowerShell (or bash); a new MCP tool
> or VS Code extension command is TypeScript. Re-classify every planned artifact of every child
> under this rule (a page checker or analyzer that a skill invokes is a pushed-down helper, so
> PowerShell or bash, unless it is exposed as an MCP command, in which case the MCP wrapper is
> TypeScript and the logic it calls must still be reachable from a PowerShell or bash skill path),
> record the classification in each plan, and surface any case that cannot follow it as an owner
> question rather than deciding it yourself.

Consequences applied in this document:

- Withdrawn: the Python package design (`packages/docs-runtime` as `drm_copilot_docs`,
  `packages/docs-page-check` as `drm_copilot_docs_check`, `dev.docs.*` Poetry console commands, a
  Python wheel build script) and the interim TypeScript runtime design (`extensions/drm-copilot/src/docs/`
  and a `drm-copilot-docs` npm bin), which ran pushed-down logic in TypeScript.
- Children 1020, 1021, 900003, 900005 and 900006 were prepared, or were being prepared, against a
  withdrawn design. Each is re-prepared with one planner revision against this document.
- Every child plan carries an artifact classification table: each new or edited file, its class
  (`pushed-down helper/lib`, `hook`, `skill`, `agent`, `MCP tool`, `extension command`,
  `schema/config/data`, `test`, `documentation`), its language, and the rule that permits it.

### Artifact classes for this epic

| Class | Language | Location |
|---|---|---|
| Pushed-down helper/lib (profile, schemas, analyzers, checker, ledger, generator, surface delta) | PowerShell modules | `.claude/lib/docs/`, mirrored byte-identical to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` |
| Helper entry point called by skills, CI and the MCP wrapper | PowerShell script | `.claude/lib/docs/Invoke-DocsCommand.ps1` |
| Hook | PowerShell | `.claude/hooks/`, mirrored to the push-down tree |
| Skill, agent | Markdown | `.claude/skills/`, `.claude/agents/` and generated mirrors |
| MCP tool wrapper | TypeScript | `extensions/drm-copilot/src/` (bundled into `packages/mcp-server`) |
| Schema, example, configuration | JSON/YAML/INI data | `schemas/docs/v1/`, `examples/docs/v1/`, consumer configuration templates |
| Test | Pester for PowerShell, Jest for TypeScript | `tests/scripts/claude-lib/docs/`, `tests/scripts/claude-hooks/`, `extensions/drm-copilot/test/` |

## Assumptions Pending Owner Confirmation

None of the following has been approved by the owner. Each is a provisional default.

- **A1 - Analyzer scope.** Python/configuration analyzers (900003) and TypeScript/.NET analyzers
  (900004) are both in the epic as separate features, both implemented as PowerShell lexical
  scanners. No other feature depends on 900004, so it may land later; stacks outside the built-in
  set enter through the discovery extension-result manifest format.
- **A2 - Docs-site build.** A docs-site build (MkDocs or similar) is out of scope.
- **A3 - Issue #5 `markdown-toolchain`.** This epic stays separate from issue #5. No Markdown QC
  configuration exists on `main` at planning time (no `.pymarkdown*`, `.markdownlint*`,
  `.vale.ini` or `styles/` at the repository root). 1021 ships base configuration data for an
  external Markdown linter and a base Vale style; the choice of linter is owner question Q3.
- **A4 - Integration branch.** `epic/documentation-estate-tooling-integration` starts from
  `origin/main`, which contains the merged discovery runtime (#980, PR #1014).
- **A5 - Placement and distribution (planner decision under the refined directive).** All
  pushed-down logic is PowerShell under `.claude/lib/docs/`, following the existing
  `.claude/lib/<area>/*.psm1` pattern (for example `.claude/lib/mermaid/`), delivered by the
  existing push-down of the `claude-customizations` tree. PowerShell is chosen over bash because
  the existing lib, hook and Pester coverage infrastructure is PowerShell. A destination repository
  needs PowerShell 7 only.
- **A6 - MCP placement (planner decision).** All docs MCP tools are delivered by one feature
  (900007). Each tool is a TypeScript wrapper that invokes
  `.claude/lib/docs/Invoke-DocsCommand.ps1`, so the same logic is reachable from skills, CI and
  MCP.
- **A7 - Discovery reuse (planner decision).** The JSON schemas under `schemas/discovery/v2/` and
  the PowerShell modules under `.claude/lib/discovery-validation/` may be reused. The Python
  discovery runtime is not called by the docs helpers, because that would require Python in the
  destination repository; an existing discovery inventory snapshot or extension-result manifest
  JSON may be imported as data.
- **A8 - No new third-party PowerShell modules (planner decision).** Helpers use PowerShell 7
  built-ins only (for example `ConvertFrom-Json`, `Test-Json`). A helper that cannot reasonably
  work without a new module (for example a YAML parser) records an owner question instead.

## Owner Questions Raised by the Refined Directive

- **Q1 - JSON Schema validation in PowerShell.** `Test-Json -Schema` in PowerShell 7 may not
  resolve cross-file `$ref` into `schemas/discovery/v2/common.schema.json`. Provisional default:
  1020's research determines this; if it does not, schemas are self-contained (definitions
  copied into `schemas/docs/v1/common.schema.json`) rather than adding a validator dependency.
- **Q2 - Lexical analysis in PowerShell.** Python, TypeScript and C# surface extraction in
  PowerShell is lexical and slower than a parser; unclassified constructs become diagnostics.
  Alternative: bash is no better suited. Provisional default: PowerShell lexers with size bounds.
- **Q3 - External Markdown linter for consumers.** PyMarkdown needs Python; markdownlint needs
  Node.js; both are external tools, not code this epic writes. Provisional default: ship a
  markdownlint configuration as optional data and keep `Invoke-DocsCommand.ps1 check` as the
  required gate, so no linter is a hard dependency.
- **Q4 - Consumer CI shell.** The consumer workflow template assumes `pwsh` on the runner
  (preinstalled on GitHub-hosted runners). Provisional default: accept.

## Scope

| Wave | issue_num | Feature | Band | Purpose |
|---|---|---|---|---|
| 0 | 1020 | docs-profile-and-artifact-schemas | C3 | Docs profile, versioned schemas, surface element model, analyzer registry, `Invoke-DocsCommand.ps1` entry and push-down registration. |
| 1 | 1021 | docs-page-quality-checker | C3 | PowerShell page checker (front matter, links/anchors, Diataxis mode, orphans) with base linter and Vale configuration data. |
| 1 | 900003 | docs-surface-analyzers-python-config | C4 | PowerShell lexical analyzers for Python CLI, HTTP route, public API, configuration and architecture surfaces; `inventory` subcommand. |
| 1 | 900004 | docs-surface-analyzers-typescript-dotnet | C4 | PowerShell lexical analyzers for TypeScript CLI/route/export and .NET route/config/public-type surfaces; extension-manifest import. |
| 1 | 900005 | docs-coverage-ledger-and-receipt | C4 | PowerShell coverage ledger, parity matrix, evidence pins and staleness, `docs-complete` receipt. |
| 2 | 900006 | docs-reference-generator | C3 | PowerShell deterministic reference-page renderer with marker-delimited generated blocks. |
| 3 | 900007 | docs-mcp-tools | C3 | TypeScript MCP tool wrappers over `Invoke-DocsCommand.ps1`. |
| 2 | 900008 | docs-enforcement-and-ci | C3 | Consumer workflow template, surface-delta helper, opt-in integration-PR gate hook, feature-review check. |
| 4 | 900009 | docs-authoring-workflow | C4 | Four documentation roles, eight skills, page templates, mirrored to all surfaces. |
| 5 | 900010 | documentation-estate-template-and-onboarding | C3 | `documentation-estate` epic template, onboarding docs, end-to-end Pester fixture test. |

## Non-Goals

- Runtime characterization and acceptance-scenario generation for documentation.
- Protected-authority-store hook enforcement for documentation artifacts (the receipt is
  CI-verified; stronger enforcement can follow later).
- Mechanical judgment of prose correctness. Tools prove a page exists, carries metadata and pins a
  current symbol; the reviewer role judges accuracy.
- A docs-site build (A2).
- Markdown QC adoption for this repository's own documentation (issue #5, A3).
- Changes to the Python discovery runtime. A defect found there is filed separately.
- New Python code of any kind, and TypeScript outside MCP tools and extension commands. Existing
  repository Python tooling (for example the mirror generators `scripts/dev_tools/agentic_sync.py`
  and `scripts/dev_tools/generate_codex_agent_variants.py`, or the plan validator) may still be
  called.

## Shared Design

### Naming contract (fixed for all children)

- Helper root: `.claude/lib/docs/`; PowerShell modules named `Docs<Area>.psm1`; one entry script
  `Invoke-DocsCommand.ps1 -Command <subcommand> [arguments]` with a subcommand dispatch table
  (1020). Push-down mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`
  (byte-identical; 1020 confirms whether the Codex customization tree also carries libs).
- Tests: Pester under `tests/scripts/claude-lib/docs/<Module>.Tests.ps1`, following
  `tests/scripts/claude-lib/mermaid/`; hook tests under `tests/scripts/claude-hooks/`; MCP tests
  under `extensions/drm-copilot/test/`.
- Subcommands and owners: `init`, `validate-profile` (1020); `check` (1021); `inventory` (900003;
  900004 adds analyzers only); `coverage`, `update-ledger`, `validate` (900005);
  `generate-reference` (900006); `surface-delta` (900008). Each owner adds its own command module
  and one dispatch-table row.
- Exit codes for every subcommand: 0 success, 1 findings or validation failure, 2 usage or input
  error; `-Json` switch emits machine-readable output.
- Schemas: `schemas/docs/v1/<name>.schema.json`; examples: `examples/docs/v1/`.
- MCP tools (900007): `run_docs_check`, `run_docs_inventory`, `run_docs_coverage`,
  `update_docs_ledger`, `generate_docs_reference`, `validate_docs_artifacts`.
- Roles (900009): `docs-architect`, `docs-author`, `docs-reconciler`, `docs-coverage-reviewer`.
- Surface element kinds: `cli-command`, `cli-option`, `http-route`, `config-key`, `public-symbol`,
  `architecture-component`. Element identifiers are deterministic, derived from kind, path and
  declaration (the rule mirrors the discovery runtime's findings identities).
- Ledger dispositions: `documented` (requires at least one page binding), `excluded` (requires a
  rationale), `deferred` (requires an owner and a target).
- Parity dimensions: `exists`, `accurate`, `example_present`, `owner_assigned`, `diataxis_mode`.
- Page front matter fields: `owner`, `last_reviewed`, `audience`, `diataxis_mode`, `surface_refs`.
- Diataxis mode values: `tutorial`, `how-to`, `reference`, `explanation`.
- Generated-block markers: `<!-- docs:generated:start id=<element-id> -->` and
  `<!-- docs:generated:end id=<element-id> -->`.

### Decisions carried from the first preparation of 1020 and 1021 (language-independent)

- A seventh schema file, `schemas/docs/v1/common.schema.json` (definitions only, `$id`
  `urn:drm-copilot:docs:1.0.0:common`), holds shared definitions; the six artifact schema names
  are unchanged. Evidence pins are stored as one collection document.
- The neutrality test configures consumer identifiers only as SHA-256 digests, never as text.
- `extensions/drm-copilot/resources/templates/` is not a push-down root. Consumer configuration
  and the 900008 workflow template are delivered either through a tree a push-down command copies
  or by `Invoke-DocsCommand.ps1 init` writing them; 1020's re-preparation decides which, and
  1021/900008 follow it.
- Execution should run in the item worktree, not an isolated executor worktree, because the batch
  budget otherwise denies the fourth production file.
- `quality-tiers.yml` exists at the repository root; new code areas are classified there if its
  schema covers `.claude/lib` directories (research confirms).

### Reuse

- Language-neutral data: `schemas/discovery/v2/common.schema.json`,
  `evidence-reference.schema.json`, `validation-receipt.schema.json`,
  `extension-result-manifest.schema.json`, `inventory-snapshot.schema.json`.
- PowerShell: `.claude/lib/discovery-validation/` (for example encoding and payload helpers) and
  the lexical-scanner pattern of `.claude/lib/mermaid/MermaidLineScanner.psm1`; each child's
  research names the exact functions it reuses.
- Analyzer guarantees documented in `docs/engineering/legacy-discovery-and-parity/analyzers.md`
  (captured inputs, deterministic identities, no value leakage, bounded parsing, diagnostics over
  guesses) are requirements for the PowerShell analyzers.
- Python modules under `packages/discovery-runtime/src/drm_copilot_discovery/` are design
  references only.

### Cross-feature conflict surface

Children create disjoint new modules. Shared, append-only edit points:
`.claude/lib/docs/Invoke-DocsCommand.ps1` dispatch table (1020, 1021, 900003, 900005, 900006,
900008), `.claude/lib/docs/DocsAnalyzerRegistry.psm1` (900003, 900004), any push-down manifest or
parity list that enumerates mirrored files (every child that adds a module), and
`quality-tiers.yml` if applicable. Append-only conflicts are resolved inside the child's
remediation loop.

## Child Feature Specifications

Each specification lists the planned files, acceptance criteria and complexity band. Every new
PowerShell module under `.claude/lib/docs/` has a byte-identical push-down copy and a Pester test
module; those are implied and not repeated per file. Research may refine module names but may not
change the naming contract without an epic-level update. No test creates temporary files: pure
functions take in-memory path-to-content hashtables and I/O stays in thin command functions.

### 1020 - docs-profile-and-artifact-schemas (wave 0, C3)

Band rationale: defines the contracts every other child consumes (schemas, element model,
analyzer registry, entry script and push-down registration).

Files (create): `.claude/lib/docs/DocsProfile.psm1` (profile model, load and validate),
`DocsSchema.psm1` (schema loading and validation, Q1), `DocsSurface.psm1` (element kinds and
deterministic identities), `DocsAnalyzerRegistry.psm1` (analyzer contract and registry),
`DocsProfileCommands.psm1` (`init`, `validate-profile`), `Invoke-DocsCommand.ps1` (entry and
dispatch table); `schemas/docs/v1/docs-profile.schema.json`,
`surface-inventory-snapshot.schema.json`, `docs-coverage-ledger.schema.json`,
`docs-parity-matrix.schema.json`, `docs-evidence-pin.schema.json`,
`docs-validation-receipt.schema.json`, `common.schema.json`; `examples/docs/v1/` (one per artifact
schema); Pester suites including a neutrality test and an identity determinism test.

Files (edit): push-down registration for the new lib directory and schemas (research identifies
the manifest or parity test that enumerates mirrored files).

Acceptance criteria:
- Every example under `examples/docs/v1/` validates against its schema; each schema rejects a
  missing required field and an unknown disposition or element kind.
- `Invoke-DocsCommand.ps1 -Command validate-profile` exits 0 for the example profile and 1 with a
  message naming the failing field for an invalid profile; `-Command init` emits a starter profile
  that validates.
- Element identifiers are deterministic over a seeded set of inputs.
- A neutrality test fails when a configured consumer identifier digest matches text under
  `.claude/lib/docs/` or `schemas/docs/`.
- The push-down copy is byte-identical to the source.
- No new Python or TypeScript file is added; the plan's classification table shows every file's
  class and language.
- Pester line coverage >= 85% for `.claude/lib/docs/`.

### 1021 - docs-page-quality-checker (wave 1, C3)

Band rationale: rule logic plus configuration data crossing schema, helper and consumer-config
boundaries.

Files (create): `.claude/lib/docs/DocsPageFrontMatter.psm1` (bounded front-matter parser for the
documented field subset), `DocsPageLinks.psm1` (relative links and heading anchors),
`DocsPageDiataxis.psm1`, `DocsPageOrphans.psm1`, `DocsPageCheck.psm1` (configuration, report and the
`check` command); `schemas/docs/v1/page-metadata.schema.json`; base consumer configuration data
(Markdown linter configuration per Q3, `.vale.ini`, `styles/DocsBase/` rules, empty
consumer-owned vocabulary) at the delivery path chosen by 1020.

Files (edit): `Invoke-DocsCommand.ps1` (one row).

Acceptance criteria:
- Missing or malformed front-matter fields, a broken relative link, a missing heading anchor, a
  Diataxis mode mismatch and an orphan page each produce a distinct finding code naming the file.
- `-Command check` exits 0 on a clean page set and 1 when any finding is present; `-Json` output
  ordering is deterministic.
- The page-check modules import nothing from the ledger, analyzer or reference modules.
- No consumer vocabulary or repository name ships in the base configuration.
- Pester line coverage >= 85%.

### 900003 - docs-surface-analyzers-python-config (wave 1, C4)

Band rationale: lexical extraction of Python and configuration surfaces in PowerShell without a
Python parser (Q2); ambiguity in what counts as public surface; research-heavy.

Files (create): `.claude/lib/docs/DocsPythonTokens.psm1` (bounded Python lexer),
`DocsAnalyzerPythonCli.psm1` (argparse, Click, Typer), `DocsAnalyzerPythonHttp.psm1` (FastAPI and
Flask route decorators), `DocsAnalyzerPythonApi.psm1` (`__all__` and public top-level
definitions), `DocsAnalyzerConfigFiles.psm1` (`pyproject.toml` script and tool tables, `.env` keys
without values, JSON Schema properties, YAML keys; bounded key scanners),
`DocsAnalyzerArchitecture.psm1` (packages, modules and import edges; optional import of an existing
discovery inventory snapshot JSON), `DocsInventory.psm1` (revision-pinned snapshot with input
digests, and the `inventory` command).

Files (edit): `DocsAnalyzerRegistry.psm1` (append), `Invoke-DocsCommand.ps1` (row).

Acceptance criteria:
- Each analyzer emits the expected elements for an in-memory fixture covering argparse, Click,
  Typer, FastAPI, Flask, `pyproject.toml`, `.env`, JSON Schema and YAML inputs.
- Re-running over identical bytes produces a byte-identical snapshot.
- No configuration value is exported; only keys and shapes.
- An input above the size bound, or a construct the lexer cannot classify, yields a diagnostic,
  not a partial or guessed result.
- The snapshot validates against `surface-inventory-snapshot.schema.json`.
- Pester line coverage >= 85%.

### 900004 - docs-surface-analyzers-typescript-dotnet (wave 1, C4)

Band rationale: lexical extraction for two further ecosystems in PowerShell; ambiguous boundaries
(decorators, minimal APIs, re-exports). No feature depends on it (A1).

Files (create): `.claude/lib/docs/DocsTypeScriptTokens.psm1`, `DocsAnalyzerTypeScriptCli.psm1`
(Commander and yargs), `DocsAnalyzerTypeScriptHttp.psm1` (Express and Fastify),
`DocsAnalyzerTypeScriptExports.psm1`, `DocsCSharpTokens.psm1`, `DocsAnalyzerDotnetHttp.psm1`
(attribute routes and minimal-API `Map*` calls), `DocsAnalyzerDotnetConfig.psm1`
(`appsettings*.json` keys), `DocsAnalyzerDotnetApi.psm1` (public types and members),
`DocsExtensionImport.psm1` (other stacks through discovery extension-result manifest JSON).

Files (edit): `DocsAnalyzerRegistry.psm1` (append).

Acceptance criteria:
- Each analyzer emits the expected elements for in-memory TypeScript and C# fixtures.
- An extension-result manifest whose captured-input digest does not match is rejected with a
  diagnostic; a matching manifest is merged as inert data.
- Determinism and bounded-input diagnostics as in 900003.
- Pester line coverage >= 85%.

### 900005 - docs-coverage-ledger-and-receipt (wave 1, C4)

Band rationale: the correspondence core; staleness and receipt semantics carry the epic's gate
invariant.

Files (create): `.claude/lib/docs/DocsLedger.psm1` (models and disposition rules),
`DocsParity.psm1` (matrix rules and scoring), `DocsEvidencePins.psm1`, `DocsStaleness.psm1`,
`DocsReceipt.psm1`, `DocsValidation.psm1` (modes `profile`, `ledger`, `matrix`, `docs-complete`),
`DocsLedgerMutation.psm1` (single write boundary), `DocsLedgerCommands.psm1` (`coverage`,
`update-ledger`, `validate`, coverage report).

Files (edit): `Invoke-DocsCommand.ps1` (three rows).

Acceptance criteria:
- A ledger missing a disposition for any inventoried element fails validation naming the element;
  `excluded` without rationale and `deferred` without owner or target fail.
- A pin whose recorded digest differs from the current snapshot marks the bound page stale.
- `-Command validate -Mode docs-complete` emits a receipt on success; with one undocumented element
  and one stale page it exits 1 and the message names both.
- Ledger and matrix writes happen only through `DocsLedgerMutation.psm1`; `update-ledger` is the
  only mutating subcommand.
- Pester line coverage >= 85%.

### 900006 - docs-reference-generator (wave 2, C3)

Band rationale: deterministic rendering with a merge invariant (prose preservation).

Files (create): `.claude/lib/docs/DocsReferencePlan.psm1`, `DocsReferenceRender.psm1` (CLI, HTTP,
configuration and API renderers; split if it exceeds the file-size guidance),
`DocsReferenceMarkers.psm1`, `DocsReferenceWriter.psm1` (front matter conforming to
`page-metadata.schema.json`, dry-run diff, and the `generate-reference` command).

Files (edit): `Invoke-DocsCommand.ps1` (row).

Acceptance criteria:
- Rendering the same snapshot twice is byte-identical.
- Prose outside generated markers is preserved across regeneration; a removed element's block is
  removed and reported.
- Every generated page passes the 1021 checker with zero findings (Pester integration test).
- Without `-Write` the command writes nothing and prints the planned changes.
- Pester line coverage >= 85%.

### 900007 - docs-mcp-tools (wave 3, C3)

Band rationale: cross-language contract (TypeScript MCP wrappers over PowerShell helpers) following
the existing MCP tool pattern for PowerShell-backed tools.

Files (create), under `extensions/drm-copilot/src/`: `mcp-docs-tool-definitions.ts`,
`mcp-handlers/docs-handlers.ts`, `mcp-tool-inputs-docs.ts`, `repo-automation-execute-docs.ts`
(invokes `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1`); Jest tests under
`extensions/drm-copilot/test/`.

Files (edit): `extensions/drm-copilot/src/mcp-tools.ts`,
`extensions/drm-copilot/src/repo-automation-tool-names.ts`; every existing test that enumerates the
MCP tool set (research identifies them and the plan records each disposition).

Acceptance criteria:
- Each of the six tools validates its input, invokes the matching subcommand with `-Json`, and
  returns structured output including the exit code and findings.
- Invalid input is rejected before any process starts.
- `update_docs_ledger` is the only mutating tool and routes through `-Command update-ledger`.
- No logic beyond argument mapping and result parsing lives in TypeScript; every operation is
  reachable from a skill through `Invoke-DocsCommand.ps1`.
- Jest line coverage >= 85% and branch coverage >= 75% on the new modules.

### 900008 - docs-enforcement-and-ci (wave 2, C3)

Band rationale: gate behavior across CI template, hook and review agent; alters an existing
review contract.

Files (create): consumer reusable workflow `_docs-quality.yml` (runs `Invoke-DocsCommand.ps1`
`check` and `validate -Mode docs-complete` with `pwsh`) at the delivery path decided by 1020;
`.claude/lib/docs/DocsSurfaceDelta.psm1` (`surface-delta -Base <ref>`);
`.claude/hooks/enforce-docs-complete-gate.ps1` (opt-in; denies the epic integration-to-`main`
merge unless a passing receipt pins the head revision); Pester suites for both.

Files (edit): `.claude/settings.json` (hook registration), `.claude/agents/feature-review.md` and
its mirrors on the Codex, Copilot and push-down surfaces (surface-change-without-ledger-change
check), `Invoke-DocsCommand.ps1` (row).

Acceptance criteria:
- With the gate disabled (default) the hook allows every call; enabled, it denies when the receipt
  is absent, failing, or pinned to another revision, and the deny text names the reason.
- `surface-delta` reports an added CLI command with no ledger change and reports nothing when the
  ledger records it.
- The workflow template requires `pwsh` only.
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
  `docs-reconcile-behavior`, `docs-review-coverage`, `docs-validate`. Skills call
  `Invoke-DocsCommand.ps1` or the MCP tools; any new skill helper is PowerShell.
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
  `command-reference.md`, `workflow.md`
- `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` (in-memory fixture
  repository with one undocumented command and one stale page)
- A Pester test that the template manifest has a cycle-free DAG under the epic manifest rules

Acceptance criteria:
- The end-to-end test runs inventory, ledger, generation and `docs-complete` validation; it fails
  naming the undocumented command and the stale page, and passes after both are fixed.
- The template is accepted by `/epic-plan` as a manifest path.
- The onboarding guide documents every subcommand and MCP tool with an example and states the
  destination-repository prerequisite (PowerShell 7).

## Decomposition Rationale

- Contracts first: 1020 fixes the schemas, element model, analyzer registry and entry script so
  the wave-1 features build in parallel against stable contracts.
- 1021 depends on 1020 because its `check` subcommand registers in 1020's entry script and its
  schema references 1020's `common` definitions (an edge added with the language directive; under
  the withdrawn Python design 1021 was an independent package in wave 0).
- 900006 depends on 1021 because generated pages must satisfy the page-metadata schema and checker.
- 900007 waits for the subcommands it wraps; 900004 is excluded because it adds analyzers behind
  the existing `inventory` subcommand.
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

- Lexical Python, TypeScript and C# scanning in PowerShell is less precise and slower than a
  parser; unclassified constructs surface as diagnostics (Q2).
- PowerShell `Test-Json` schema support may be insufficient for cross-file references (Q1).
- Append-only conflicts in `Invoke-DocsCommand.ps1`, the analyzer registry and push-down file
  lists across wave-1 children.
- Lexical analyzers cannot see dynamic registration; such elements surface as diagnostics.
