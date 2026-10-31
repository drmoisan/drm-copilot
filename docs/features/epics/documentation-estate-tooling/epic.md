---
epic: documentation-estate-tooling
integration_branch: epic/documentation-estate-tooling-integration
created_at: 2026-10-30T20:10:00Z
# PLANNING STATE. All issue_num values are real issues (placeholders back-filled 2026-10-30); each child
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
    - Pushed-down skills, skill helpers, hooks and libs are PowerShell (or bash); TypeScript is used only for MCP tools; the only new Python is the owner-approved Python-native analyzer shipped in the python pack (D3).
    - Analyzers are read-only, lexical, bounded and deterministic; no analyzer executes, compiles or installs consumer code.
    - Line coverage >= 85% on new PowerShell (Pester; no branch gate) and line >= 85% / branch >= 75% on new TypeScript; files stay within the 500/700/800 line tiers.
features:
  - issue_num: 1020
    feature_folder: 2026-10-30-docs-profile-and-artifact-schemas-1020
    depends_on: []
  - issue_num: 1021
    feature_folder: 2026-10-30-docs-page-quality-checker-1021
    depends_on: [1020]
  - issue_num: 1022
    feature_folder: 2026-10-30-docs-surface-analyzers-python-config-1022
    depends_on: [1020]
  - issue_num: 1033
    feature_folder: 2026-10-30-docs-surface-analyzers-typescript-dotnet-1033
    depends_on: [1020]
  - issue_num: 1023
    feature_folder: 2026-10-30-docs-coverage-ledger-and-receipt-1023
    depends_on: [1020]
  - issue_num: 1024
    feature_folder: 2026-10-30-docs-reference-generator-1024
    depends_on: [1020, 1021]
  - issue_num: 1036
    feature_folder: 2026-10-30-docs-mcp-tools-1036
    depends_on: [1021, 1022, 1023, 1024]
  - issue_num: 1034
    feature_folder: 2026-10-30-docs-enforcement-and-ci-1034
    depends_on: [1021, 1023]
  - issue_num: 1037
    feature_folder: 2026-10-30-docs-authoring-workflow-1037
    depends_on: [1036]
  - issue_num: 1038
    feature_folder: 2026-10-30-documentation-estate-template-and-onboarding-1038
    depends_on: [1034, 1037]
  - issue_num: 1031
    feature_folder: 2026-10-30-docs-surface-analyzer-python-native-1031
    depends_on: [1022]
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
- Children 1020, 1021, 1022, 1023 and 1024 were prepared, or were being prepared, against a
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

## Owner Decisions (2026-10-30, received through the coordinator)

- **Assumptions A1-A8: confirmed as written below.**
- **D1 - Planning cycles.** The PowerShell rewrite counts as a new planning cycle for every
  superseded child (1021, 1022, 1023, 1024): each gets a fresh allowance of one planner revision
  and the single-pass preflight. 1024's new plan must address its halted preflight (a property test
  for each pure function).
- **D3 - Language-native analyzer exception.** A language-native analyzer is allowed when it
  analyzes that same language and is pushed down only with that language's pack. The PowerShell
  text scanner remains the always-available baseline and keeps its documented precision limit,
  recorded as `deferred` with an owner in the coverage ledger. The Python-native analyzer (Python
  `ast`, written in Python, listed in the python pack manifest, tested under the Python gates) is
  in the first release as new child 1031, depending on 1022. C# and TypeScript native analyzers
  are later, optional children; 1033 stays the baseline TypeScript/.NET scanner. The inventory
  snapshot and the ledger record the analysis method (`native` or `scanner`) per element.
- **D4 - Linting.** Optional by default: configuration data only; no required Node or Python
  linter (settles Q3).
- **D5 - Contracts.** `docs-complete` fails closed when the snapshot has no revision (settles Q5).
  An element digest covers the declaration's source lines, not the whole file. The JSON output
  envelope gets its own schema. `Test-Json` cross-file `$ref` is tested first, with self-contained
  schemas as the fallback (1020 tested it; it fails by default, so the fallback is in effect).
- Q6-Q10 (raised by 1020) were not addressed by these decisions; their provisional defaults stand.
- The language rule is otherwise unchanged.

### Amendment of 1020 required by D3 and D5

1020 was cleared before these decisions. Its schemas and contracts gain: an `analysis_method`
field (`native` | `scanner`) on inventory elements and ledger entries; the declaration-lines
digest rule; `schemas/docs/v1/docs-command-envelope.schema.json` for the `-Json` envelope; and a
1031 anchor in `DocsAnalyzerRegistry.psm1`. 1020 is re-planned once for this requirements change
(a new cycle under D1).

Consequences for other children: 1022 and 1033 record `analysis_method: scanner` and the
declaration-lines digest; 1023 records `analysis_method` per ledger entry and supports the
scanner precision limit as a `deferred` entry with an owner; every subcommand's `-Json` output
validates against the envelope schema.

## Assumptions (confirmed by the owner 2026-10-30)

- **A1 - Analyzer scope.** Python/configuration analyzers (1022) and TypeScript/.NET analyzers
  (1033) are both in the epic as separate features, both implemented as PowerShell lexical
  scanners. No other feature depends on 1033, so it may land later; stacks outside the built-in
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
  (1036). Each tool is a TypeScript wrapper that invokes
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

Status: Q1 resolved by test (fallback in effect); Q3 settled by D4; Q5 settled by D5; Q2 settled by
D3 (scanner baseline plus language-native analyzers per pack); Q4 and Q6-Q10 stand on their
provisional defaults.

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
- **Q5 - Unpinned snapshot.** `docs-complete` fails when the inventory snapshot carries no
  revision. Provisional default: fail closed.
- **Q6 - Runtime schema location (from 1020).** Provisional default: canonical `schemas/docs/v1/`
  plus a parity-tested copy under `.claude/lib/docs/schemas/v1/`.
- **Q7 - Codex reach (from 1020).** Provisional default: the docs lib ships in the Claude bundle
  only; a `.codex/lib/docs/` mirror would need a TypeScript change and an in-place edit of existing
  Python.
- **Q8 - PowerShell floor (from 1020).** Provisional default: require PowerShell 7.4 (Draft
  2020-12 `Test-Json`) and fail closed below it.
- **Q9 - Tier (from 1020).** Provisional default: `.claude/lib/docs` is T3.
- **Q11 - Python-invocation guard (from 1031).** `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
  forbids Python invocation from `.claude/lib` with an empty allowlist. Provisional default: one
  explicit allowlist entry for `DocsAnalyzerPythonNative.psm1`, citing D3, in a form the guard
  detects (whether that form supports a timeout is open).
- **Q12 - Packaging strips Python (from 1031).** `.vscodeignore` (`**/*.py`) and
  `packages/mcp-server/prepack.cjs` remove all Python from the VSIX and npm package. Provisional
  default: a narrow carve-out for `.claude/lib/docs/python/**`, with the pinning test updated.
- **Q13 - Host-dependent inventory (from 1031).** Provisional default: `-AnalysisMethod
  auto|native|scanner`, default `auto`; `native` fails closed when unavailable.
- **Q14 - Full-tree push-down ships the Python helper everywhere (from 1031).** Provisional
  default: accept and document; only the python pack manifest lists it.
- **Q10 - `init` writes into consumer `.github/workflows/` and root dotfiles (from 1020).**
  Provisional default: only with `-Write`, never overwriting an existing file without `-Force`.

## Scope

| Wave | issue_num | Feature | Band | Purpose |
|---|---|---|---|---|
| 0 | 1020 | docs-profile-and-artifact-schemas | C3 | Docs profile, versioned schemas, surface element model, analyzer registry, `Invoke-DocsCommand.ps1` entry and push-down registration. |
| 1 | 1021 | docs-page-quality-checker | C3 | PowerShell page checker (front matter, links/anchors, Diataxis mode, orphans) with base linter and Vale configuration data. |
| 1 | 1022 | docs-surface-analyzers-python-config | C4 | PowerShell lexical analyzers for Python CLI, HTTP route, public API, configuration and architecture surfaces; `inventory` subcommand. |
| 1 | 1033 | docs-surface-analyzers-typescript-dotnet | C4 | PowerShell lexical analyzers for TypeScript CLI/route/export and .NET route/config/public-type surfaces; extension-manifest import. |
| 1 | 1023 | docs-coverage-ledger-and-receipt | C4 | PowerShell coverage ledger, parity matrix, evidence pins and staleness, `docs-complete` receipt. |
| 2 | 1024 | docs-reference-generator | C3 | PowerShell deterministic reference-page renderer with marker-delimited generated blocks. |
| 3 | 1036 | docs-mcp-tools | C3 | TypeScript MCP tool wrappers over `Invoke-DocsCommand.ps1`. |
| 2 | 1034 | docs-enforcement-and-ci | C3 | Consumer workflow template, surface-delta helper, opt-in integration-PR gate hook, feature-review check. |
| 4 | 1037 | docs-authoring-workflow | C4 | Four documentation roles, eight skills, page templates, mirrored to all surfaces. |
| 5 | 1038 | documentation-estate-template-and-onboarding | C3 | `documentation-estate` epic template, onboarding docs, end-to-end Pester fixture test. |
| 2 | 1031 | docs-surface-analyzer-python-native | C3 | Python-native (`ast`) analyzer for Python surfaces, shipped in the python pack, with scanner fallback (D3). |

## Non-Goals

- Runtime characterization and acceptance-scenario generation for documentation.
- Protected-authority-store hook enforcement for documentation artifacts (the receipt is
  CI-verified; stronger enforcement can follow later).
- Mechanical judgment of prose correctness. Tools prove a page exists, carries metadata and pins a
  current symbol; the reviewer role judges accuracy.
- A docs-site build (A2).
- Markdown QC adoption for this repository's own documentation (issue #5, A3).
- Changes to the Python discovery runtime. A defect found there is filed separately.
- New Python code other than the D3 Python-native analyzer (1031), and TypeScript outside MCP
  tools and extension commands. C# and TypeScript native analyzers (later, optional children). Existing
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
- Subcommands and owners: `init`, `validate-profile` (1020); `check` (1021); `inventory` (1022;
  1033 adds analyzers only); `coverage`, `update-ledger`, `validate` (1023);
  `generate-reference` (1024); `surface-delta` (1034). Each owner adds its own command module
  and one dispatch-table row.
- Exit codes for every subcommand: 0 success, 1 findings or validation failure, 2 usage or input
  error, 3 internal or I/O error; `-Json` switch emits the envelope defined below.
- Schemas: `schemas/docs/v1/<name>.schema.json`; examples: `examples/docs/v1/`.
- MCP tools (1036): `run_docs_check`, `run_docs_inventory`, `run_docs_coverage`,
  `update_docs_ledger`, `generate_docs_reference`, `validate_docs_artifacts`.
- Roles (1037): `docs-architect`, `docs-author`, `docs-reconciler`, `docs-coverage-reviewer`.
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
  and the 1034 workflow template are delivered either through a tree a push-down command copies
  or by `Invoke-DocsCommand.ps1 init` writing them; 1020's re-preparation decides which, and
  1021/1034 follow it.
- Execution should run in the item worktree, not an isolated executor worktree, because the batch
  budget otherwise denies the fourth production file.
- `quality-tiers.yml` exists at the repository root; new code areas are classified there if its
  schema covers `.claude/lib` directories (research confirms).

### PowerShell contracts from the re-preparation of 1020 (binding; authoritative text in 1020 spec.md `## Decisions Later Children Must Honor`)

- `Invoke-DocsCommand.ps1` dispatch table and `DocsAnalyzerRegistry.psm1` carry one anchor comment
  per later owner; each child adds rows under its own anchor only, with literal module joins.
  Dispatch uses `[scriptblock]`-typed parameters declared in the same file, because the existing
  test `enforcement-hooks-no-python-invocation.Tests.ps1` rejects `&` calls through a variable,
  member or expression in `.claude/lib`.
- Exit code 2 carries finding `DOCS_CLI_ARGUMENTS`, exit code 3 carries `DOCS_CLI_RUNTIME`. `-Json`
  prints canonical JSON `{command, exit_code, findings, ok, result}`; the envelope has no schema
  file.
- Pure functions take strings and hashtables; all file and clock access goes through one command
  context built by `Invoke-DocsCommand.ps1`, whose only write function is `Write-DocsFileText`.
- Element identifiers are `<kind>-<sha256>` over canonical JSON of `{declaration, kind, path}` plus
  a line feed, using `ConvertTo-DiscoveryCanonicalJson`. JSON is parsed with System.Text.Json into
  ordinal hashtables with duplicate-key detection.
- Schemas: `schemas/docs/v1/` is canonical; a parity-tested runtime copy ships under
  `.claude/lib/docs/schemas/v1/`. `DocsSchema.psm1` inlines the docs-common `$defs` in memory,
  because `Test-Json` rejects external `$ref` by default (Q1 resolved). `format: date-time` is not
  enforced, so timestamps use a `pattern`. Field-level messages come from
  `Get-DocsSchemaStructuralFinding`; schema constraints that must name a failing field stay within
  its keyword subset.
- The consumer profile is JSON at `docs/documentation-estate/docs-profile.json`; YAML is rejected.
- Consumer configuration and the 1034 workflow template are written by
  `Invoke-DocsCommand.ps1 -Command init` from templates under `.claude/lib/docs/templates/`; 1021
  and 1034 each add one template row.
- Every new `.claude/lib/docs/` file is listed in the Claude `pack-manifests/core.json` and
  mirrored byte-identically. `.claude/lib/docs` is T3 in `quality-tiers.yml`.
- Execution runs in the item worktree under an exempt-route checkpoint (batch budget).

### Generator contracts from the PowerShell preparation of 1024 (binding)

- `generate-reference [-Profile] [-Snapshot] [-OutputDirectory] [-Write] [-Json]`; dry run is the
  default and performs no write. Exit 1 means error findings and nothing written; exit 3 covers a
  write conflict or failure. `result` is `{mode, pages, summary, unrendered}`. Output is
  byte-identical regardless of the clock.
- Anchor labels in 1020's dispatch table still carry placeholder numbers (for example
  `900006: generate-reference`); children locate their anchor by subcommand token. Owner question
  Q15: where the shared `path_or_glob` matcher lives (provisional default: a 1020 amendment, with a
  1024-local fallback).
- Two independent 1024 preparations cleared preflight during a relaunch. The pushed set
  (`285786ec4`) is kept; the duplicate set remains unpushed on the relaunch worktree branch and was
  not deleted.

### Page-check contracts from the PowerShell preparation of 1021 (binding)

- Page-metadata schema `urn:drm-copilot:docs:1.0.0:page-metadata` (fields `owner`,
  `last_reviewed`, `audience`, `diataxis_mode`, `surface_refs`, `title`, `extensions`; no required
  list); front matter is `---`, one `<key>: <JSON value>` line per field, `---`. The `DOCS_PAGE_*`
  finding-code prefix is reserved to 1021. `check` result is `{page_count, profile_path, roots}`.
- If 1020 does not compose `page-metadata` into its schema set, 1021 uses its own schema gate
  (`Get-DocsPageComposedSchemaSet`); a direct caller of `Get-DocsPageCheckFinding` or
  `Test-DocsPageFrontMatter` then passes the composed set through that function.
- `init -Write` writes `.markdownlint.json`, `.vale.ini`, `.vale/styles/DocsBase/*.yml` and an
  empty `accept.txt`, all or nothing.

Cross-child reconciliation found during 1021's preflight (to be resolved before execution):
- 1024's cleared spec and plan still use pre-PowerShell 1021 names (`DX-NO-INSTRUCTION`,
  `PAGE_ORPHANED`, root and entry-page check options) and pin their own `owner` and `surface_refs`
  patterns. 1024 needs one reconciliation revision against the 1021 contracts above.
- Glob matching differs between 1021 and 1024 for `[!x]` negation (Q15).
- 1020: the structural schema walk ignores `patternProperties` (false unknown-property finding on
  non-empty `extensions`); an empty `accept.txt` may throw under strict mode if read with
  `Get-Content -Raw`; `init` template rows use absolute `Source` paths while the context's
  `ReadText` accepts relative paths only.

### Enforcement notes from the two preparations of 1034

- The pushed preparation (`20e9aa408`, `PREFLIGHT: ALL CLEAR`) is kept. A concurrent relaunch
  produced a second preparation that halted (`validator_failed`) and stays unpushed on its own
  worktree branch.
- The halted preparation found a PowerShell module-visibility defect: a hook that imports only
  `DocsCompleteGate.psm1` cannot call functions that module merely imports from a sibling (for
  example `DocsSchema.psm1`). The kept plan's hook calls only the `DocsCompleteGate.psm1` predicates,
  which use sibling helpers inside their own module scope, so the defect does not appear to apply.
  Execution of 1034 must still confirm that every function the hook calls is exported by a module
  the hook imports.
- Contracts: `surface-delta` options `-Base`, `-BaseSnapshot`, `-BaseLedger`, `-Profile`; finding
  `DOCS_SURFACE_DELTA_UNLEDGERED`; gate opt-in `completion_gates.integration_pr_gate.enabled`
  (default false), receipt at `artifact_paths.validation_receipt`, deny prefix
  `DOCS_COMPLETE_GATE_BLOCKED:`. 1023 must persist `revision`, `mode`, `repository`,
  `validation_result` and `id` in the receipt.

### Native-analyzer contracts from the preparation of 1031 (binding)

- The Python helper emits raw facts only (kind, path, declaration, line span); PowerShell computes
  every identifier and declaration-lines digest with the shared 1020/1022 functions, so the
  identity rule has one implementation.
- Native analysis covers only `.py` files for `python-cli`, `python-http`, `python-public-api` and
  `python-architecture`; Python floor 3.10; interpreter run as `-I -B -X utf8`, UTF-8 JSON in,
  ASCII-escaped JSON out. The helper lives under `.claude/lib/docs/python/`.
- Preconditions 1020/1022 must provide: the 1031 registry anchor (own provider table, because the
  registry rejects duplicate identifiers), `analysis_method`, the declaration-lines digest function
  and per-kind line-range rules, a shared fixture path, a process member on the command context,
  and an `information` severity in `New-DocsDiagnostic`.
- Conflict to resolve in 1020: its planned manifest test (every file under `.claude/lib/docs/` is
  listed in core) must exclude `.claude/lib/docs/python/`, which only the python pack lists.

### Command contract decisions from the first preparation of 1023 (language-independent)

- Exit codes: 0 pass, 1 findings, 2 usage or input error, 3 internal or I/O error (extends the
  naming-contract set above for every subcommand).
- `-Json` output is an envelope `{command, ok, exit_code, findings, result}` with findings in a
  fixed order.
- `validate` takes a mode (`profile`, `ledger`, `matrix`, `docs-complete`) and a required revision.
  `update-ledger` takes an operation (`set-disposition`, `remove-entry`, `pin`, `unpin`,
  `set-dimension`, `sync-refs`), is a dry run unless a write switch is given, and is the only
  subcommand that changes the ledger, matrix or pins.
- The receipt is always returned in `result`; persisting it needs an explicit write-receipt switch
  through the mutation boundary. The receipt identifier is derived from its content excluding the
  issue time. 1036's `validate_docs_artifacts` does not persist receipts; 1034 reads a
  persisted receipt.
- Pin states: `current`, `digest-changed`, `element-missing`; a page is stale when any pin is not
  current. Digests are compared as opaque values.
- `docs-complete` fails when the snapshot revision is null (`DOCS_SNAPSHOT_UNPINNED`). Owner
  question Q5.
- Open: whether the element digest covers the whole file or the declaration's source lines
  (research recommends declaration lines; 1022 decides with 1023), and whether the JSON envelope
  gets a schema.

### Analyzer decisions from the first preparation of 1022 (language-independent)

- Analyzer identifiers: `python-cli`, `python-http`, `python-public-api`, `config-files`,
  `python-architecture`. 1033 uses distinct identifiers.
- Ownership: console-script tables (`[project.scripts]`, `[tool.poetry.scripts]`,
  `[project.gui-scripts]`) belong to `python-cli`; `config-files` owns `[tool.*]` keys, `.env`
  keys, JSON Schema `properties` and YAML keys.
- Size bound: 1 MiB per input file; a larger input is a diagnostic.
- Only template environment files are read (`.env.example`, `.sample`, `.template`, `.dist`);
  other environment files are neither read nor hashed and produce one informational diagnostic.
- Registry and dispatch-table form: 1020 writes `DocsAnalyzerRegistry.psm1` and the
  `Invoke-DocsCommand.ps1` dispatch table with one entry per line and the closing delimiter on its
  own line, so later children append without changing an existing line. Contract tests that
  enumerate registered analyzers or subcommands assert membership, not set equality.

### Generator decisions from the first preparation of 1024 (language-independent)

- Fixed family pages: `cli-reference.md`, `http-reference.md`, `config-reference.md`,
  `api-reference.md`; `architecture-component` elements are not rendered and are reported as a
  count. No index page is generated; the consumer links generated pages from an entry page.
- Output directory: the single profile Diataxis directory entry with mode `reference`, or an
  explicit output-directory argument. Dry run is the default; a write switch performs writes.
- Path matching for profile `path_or_glob` entries: exact, or prefix plus `/`, or case-sensitive
  glob; first match wins. 1023 uses the same rule.
- Each generated-block marker is a standalone line with blank lines inside and outside the block.
- Identifier patterns: profile audience identifiers and the page-metadata `audience` pattern must
  agree. 1020 and 1021 adopt one pattern, `^[a-z0-9][a-z0-9-]*$`, for audience identifiers in both
  schemas (the first preparation left them inconsistent).
- The first preparation halted at preflight on missing property tests for six pure functions; the
  re-preparation plan includes a property test per pure function from the start.

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
`.claude/lib/docs/Invoke-DocsCommand.ps1` dispatch table (1020, 1021, 1022, 1023, 1024,
1034), `.claude/lib/docs/DocsAnalyzerRegistry.psm1` (1022, 1033), any push-down manifest or
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

### 1022 - docs-surface-analyzers-python-config (wave 1, C4)

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

### 1033 - docs-surface-analyzers-typescript-dotnet (wave 1, C4)

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
- Determinism and bounded-input diagnostics as in 1022.
- Pester line coverage >= 85%.

### 1023 - docs-coverage-ledger-and-receipt (wave 1, C4)

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

### 1024 - docs-reference-generator (wave 2, C3)

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

### 1036 - docs-mcp-tools (wave 3, C3)

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

### 1034 - docs-enforcement-and-ci (wave 2, C3)

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

### 1037 - docs-authoring-workflow (wave 4, C4)

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
- Every skill references only MCP tools and subcommands defined in 1020-1036.
- Mirror and push-down parity tests pass for all new agents and skills.
- The SubagentStop check blocks a role output that lacks its required result fields.

### 1038 - documentation-estate-template-and-onboarding (wave 5, C3)

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

### 1031 - docs-surface-analyzer-python-native (wave 2, C3)

Band rationale: a bounded Python `ast` analyzer behind an existing contract; the precision and
classification rules come from 1022, and the new work is the cross-language handoff (PowerShell
inventory to a pack-shipped Python helper) and pack packaging. Owner-approved exception D3.

Scope split with 1022 (planner decision): 1022 is the PowerShell text scanner for Python and
configuration surfaces and is always available. 1031 adds a native analyzer for the Python
surfaces only (`python-cli`, `python-http`, `python-public-api`, `python-architecture`); the
`config-files` analyzer stays scanner-only. When the python pack is installed and a Python
interpreter is available, `inventory` runs the native analyzer for those four identifiers and
records `analysis_method: native`; otherwise it falls back to the scanner and records
`analysis_method: scanner`. The native analyzer emits the same element kinds, identifiers and
declaration-lines digests as the scanner, so ledger pins stay valid when the method changes.

Files (create):
- Python helper (written in Python, using only the standard library `ast`) under the docs lib in
  the location the python pack ships (research confirms the pack layout); it reads in-memory
  sources passed as JSON on standard input and writes elements as JSON on standard output.
- PowerShell adapter `.claude/lib/docs/DocsAnalyzerPythonNative.psm1` that detects the pack and
  interpreter, invokes the helper, validates its output and falls back to the scanner.
- Python tests under the repository's Python test tree and Pester tests for the adapter.

Files (edit): `extensions/drm-copilot/resources/claude-customizations/pack-manifests/python.json`
(and the Codex pack manifest if the python pack carries libs there), `DocsAnalyzerRegistry.psm1`
(append under the 1031 anchor), `pack-manifests/core.json` for the PowerShell adapter.

Acceptance criteria:
- For the 1022 Python fixture, the native analyzer emits the same element identifiers as the
  scanner for every construct both classify, and additionally classifies the constructs the
  scanner reports as diagnostics.
- Without the python pack or without an interpreter, `inventory` succeeds with the scanner and
  records `analysis_method: scanner`; no error is raised.
- The helper never imports or executes analyzed code (`ast.parse` only).
- The Python helper is listed only in the python pack manifest; the core pack contains no Python.
- Python line coverage >= 85% and branch coverage >= 75%; Pester line coverage >= 85%.

## Decomposition Rationale

- Contracts first: 1020 fixes the schemas, element model, analyzer registry and entry script so
  the wave-1 features build in parallel against stable contracts.
- 1021 depends on 1020 because its `check` subcommand registers in 1020's entry script and its
  schema references 1020's `common` definitions (an edge added with the language directive; under
  the withdrawn Python design 1021 was an independent package in wave 0).
- 1024 depends on 1021 because generated pages must satisfy the page-metadata schema and checker.
- 1036 waits for the subcommands it wraps; 1033 is excluded because it adds analyzers behind
  the existing `inventory` subcommand.
- 1034 depends on the checker and the receipt only.
- 1037 depends on the MCP tools its roles are restricted to.
- 1038 composes everything and depends on the authoring workflow and enforcement.
- 1031 depends on 1022 (analyzer identifiers, element kinds, fixtures and the fallback target)
  and transitively on 1020; it lands in wave 2, the earliest wave its dependencies allow. No
  feature depends on 1031, because the scanner keeps every downstream feature working without it.

## Planned Waves

Computed with `scripts/dev_tools/epic_wave_computation.py`:

- Wave 0: 1020
- Wave 1: 1021, 1022, 1033, 1023
- Wave 2: 1024, 1034, 1031
- Wave 3: 1036
- Wave 4: 1037
- Wave 5: 1038

Execution concurrency cap (`max_parallel_features`): 3, set by the coordinator's pacing directive.

## Risks

- Lexical Python, TypeScript and C# scanning in PowerShell is less precise and slower than a
  parser; unclassified constructs surface as diagnostics (Q2).
- PowerShell `Test-Json` schema support may be insufficient for cross-file references (Q1).
- Append-only conflicts in `Invoke-DocsCommand.ps1`, the analyzer registry and push-down file
  lists across wave-1 children.
- Lexical analyzers cannot see dynamic registration; such elements surface as diagnostics.
