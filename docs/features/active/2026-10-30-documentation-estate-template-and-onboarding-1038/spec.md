# documentation-estate-template-and-onboarding — Spec

- **Issue:** #1038
- **Parent (optional):** #1019 (documentation-estate-tooling, wave 5, band C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-31
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature

## Overview

The documentation-estate-tooling epic (#1019) delivers its capabilities as separate children: the
docs profile, schemas and entry script (1020), the page checker (1021), the scanner analyzers
(1022, 1033), the Python-native analyzer (1031), the coverage ledger and `docs-complete` receipt
(1023), the reference generator (1024), the docs MCP tools (1036), enforcement and CI (1034), and
the authoring workflow (1037). A consumer repository has no single entry point that composes them:
no epic template plans a documentation estate, no onboarding guide documents every subcommand and
MCP tool, and no end-to-end test shows that the pieces work together on one fixture repository.

This child adds one epic template, five onboarding pages and three Pester suites. It adds no
production PowerShell, Python or TypeScript.

Requirement sources, in order of authority: the epic (`## Owner Directive: Implementation
Language`, `## Owner Decisions`, `## Owner Questions Raised by the Refined Directive`, every
contract, decision and enforcement-notes section under `## Shared Design`, and `### 1038 -
documentation-estate-template-and-onboarding`); the specs of 1020, 1021, 1022, 1023, 1024, 1031,
1033, 1034, 1036 and 1037; `issue.md`; and `research/research.2026-10-30T23-29.md`. Where the
research disagrees with the epic, the epic governs (see `## Corrections to the Research`).

## Problem

- A team that wants a documentation estate must assemble the epic plan by hand from the child
  specifications. There is no reusable epic manifest that `/epic-plan` can consume.
- The subcommands of `.claude/lib/docs/Invoke-DocsCommand.ps1` and the docs MCP tools are
  documented only in feature specifications, which are not consumer documentation.
- Each child tests its own module. No test exercises inventory, ledger, generation and
  `docs-complete` validation in sequence through the real dispatch table, so a contract mismatch
  between children would surface only in a consumer repository.

## Scope

1. A `documentation-estate` epic template (`epic.md` with a parseable manifest frontmatter, and a
   `README.md` with usage instructions) under
   `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/`.
2. Onboarding documentation under `docs/engineering/documentation-estate/`: `README.md`,
   `architecture.md`, `consumer-onboarding.md`, `command-reference.md`, `workflow.md`.
3. An end-to-end Pester suite over an in-memory fixture repository with one undocumented command
   and one stale page.
4. A Pester suite that checks the template manifest against the epic manifest rules, including a
   cycle-free dependency graph.
5. A Pester documentation contract suite that checks the onboarding pages against the merged
   dispatch table and the merged MCP tool definitions.

## Non-Goals

- No change to any `.claude/lib/docs/` module, schema, hook, skill, agent, MCP tool or extension
  command. A defect found upstream is routed to the owning child or filed separately.
- No command or tool that selects or copies the epic template into a consumer repository (owner
  question OQ-A; provisional default is a documented manual copy).
- No executable `/epic-plan` manifest parser; `/epic-plan` remains an agent procedure.
- No `docs/features/templates/epic/documentation-estate/` workspace twin.
- No new Python and no new TypeScript. No Python test.
- No consumer identifier in any file of this child.
- No docs-site build (epic A2) and no Markdown linter adoption for this repository (epic A3).

## Design

### Artifact classification

Rule references: D = epic `### Artifact classes for this epic` (data, test and documentation rows);
R1 = owner directive clause (1) (pushed-down artifacts are PowerShell or bash); R2 = clause (2)
(TypeScript only for MCP tools and extension commands; not used here).

| File | Action | Class | Language | Permitting rule |
|---|---|---|---|---|
| `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` | create | schema/config/data (template manifest) | Markdown with YAML frontmatter | D |
| `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/README.md` | create | documentation | Markdown | D |
| `docs/engineering/documentation-estate/README.md`, `architecture.md`, `consumer-onboarding.md`, `command-reference.md`, `workflow.md` | create | documentation | Markdown | D |
| `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` | create | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1` | create | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` | create | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocumentationEstateFixture.TestSupport.psm1` | create | test (support module: fixture text, stateful in-memory context) | PowerShell | D |
| `tests/scripts/claude-lib/docs/EpicManifest.TestSupport.psm1` | create | test (support module: bounded manifest parser and DAG checker) | PowerShell | D |
| `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/**` | create/edit | documentation | Markdown | D |

No pushed-down helper, hook, skill, agent, MCP tool, extension command, Python file or TypeScript
file is created or edited. Every artifact follows the language rule.

### Epic template

`epic.md` frontmatter conforms to the `epic-orchestrate` `## Epic Dependency Manifest` schema with
parseable values throughout (the generic `epic/epic.md` uses tokens such as `<int>` and is a
scaffold, not a manifest):

- `epic: documentation-estate`; `integration_branch: epic/documentation-estate-integration`;
  `created_at` a valid ISO-8601 timestamp preceded by a comment instructing replacement.
- `intent`: `epic_type: enabler`, a non-empty `business_outcome_hypothesis`, and string lists
  `leading_indicators` and `nfrs` (the `docs-complete` receipt passes at the head revision; no
  consumer identifier in documentation; lint optional).
- `features[]`: integer placeholders of the form `9000NN` for `issue_num`, preceded by the
  planning-state comment used by the epic manifest; unique slug-form `feature_folder` hints;
  `depends_on` as flow sequences of `issue_num` values.
- Dependency shape:
  - Wave 0 foundation children with empty `depends_on`: docs profile and `init`; information
    architecture; page templates; page metadata; docs CI (the `init` workflow row from 1034).
  - Wave 1 page-family children, each depending on every foundation child: reference (through
    `generate-reference`), how-to, tutorial, explanation, architecture.
  - One exit-gate child depending on every page-family child, alone in the final wave. Its
    acceptance is a passing `validate -Mode docs-complete -Revision <head> -WriteReceipt` receipt
    pinned to the head revision; enabling `completion_gates.integration_pr_gate.enabled` (1034
    hook) is optional.
- The frontmatter stays within the YAML subset parsed by the DAG suite (top-level scalar keys,
  the `intent` block, a `features:` block sequence of mappings with `issue_num`,
  `feature_folder`, `depends_on`, and `#` comments). Any other construct fails the suite.

`epic.md` body: goal, scope, non-goals, shared design (roles and skills by their 1037 names, the
meaning of `analysis_method`, lint optional per D4, PowerShell 7.4 prerequisite), one child section
per `features[]` entry with acceptance criteria, decomposition rationale, and a `## Planned Waves`
list that the DAG suite compares with computed waves. No `epic-status.md` is shipped; that file is
a generated projection.

`README.md`: copy `epic.md` to `docs/features/epics/<slug>/epic.md` (the path the `/epic-plan`
readiness check expects); if the slug changes, change `epic` and `integration_branch` together;
replace `created_at`; run `/epic-plan docs/features/epics/<slug>/epic.md`, which back-fills the
`9000NN` placeholders. It states that no command copies the template (OQ-A).

Delivery: the folder ships inside the VSIX and the MCP server package with the rest of
`resources/feature-templates/`. `resources/feature-templates/` is not a push-down root, no pack
manifest names it, and `copyTemplate` copies only `epic.md` and `epic-status.md` for the `epic`
type, so the new subfolder changes no existing scaffold behavior.

### Onboarding documentation

Layout follows `docs/engineering/legacy-discovery-and-parity/` (`## Domain-Neutrality Invariant`,
`## Ownership`, `## Audience`, `## Topic Pages`, `## Capability Provenance` in `README.md`). Pages
link to code, schema and template paths, not to feature folders.

- `README.md`: purpose, audience, topic-page table, capability provenance.
- `architecture.md`: helper root `.claude/lib/docs/`, entry script and dispatch table, command
  context (all I/O through one context; only write primitive `Write-DocsFileText`), schemas under
  `schemas/docs/v1/` with the runtime copy under `.claude/lib/docs/schemas/v1/`, analyzer registry
  with scanner and native provider tables, `analysis_method` (`native` or `scanner`) on snapshot
  elements and ledger entries, declaration-lines digest, ledger, parity matrix, evidence pins,
  receipt, generated-block markers, MCP wrappers, the opt-in hook.
- `consumer-onboarding.md`:
  - Required prerequisite: PowerShell 7.4 or later on PATH as `pwsh` (epic Q8 provisional default).
    Below 7.4 every subcommand exits 3 with `DOCS_RUNTIME_UNSUPPORTED`.
  - Optional python pack: installing the python pack, with Python 3.10 or later available, enables
    the native Python analyzer for `python-cli`, `python-http`, `python-public-api` and
    `python-architecture` (D3). Without it `inventory` falls back to the PowerShell scanner and
    records `analysis_method: scanner`. `inventory -AnalysisMethod auto|native|scanner` (default
    `auto`; 1031 provisional OQ-C) controls the choice. A push-down without a pack selection places
    the inert Python helper in every destination (epic Q14, 1031 OQ-D); it is not run without an
    interpreter.
  - Linting is optional (D4): `init -Write` writes `.markdownlint.json`, `.vale.ini`,
    `.vale/styles/DocsBase/*.yml` and an empty `accept.txt` as configuration data; no Node or
    Python linter is required; `check` is the required page gate.
  - Steps: push down the Claude customizations; `init` (dry run), then `init -Write`;
    `validate-profile`; `inventory -Revision <full revision> -Write`; ledger dispositions through
    `update-ledger`; `generate-reference -Write`; `check`; `validate -Mode docs-complete`.
  - Consumer CI: `_docs-quality.yml` delivered by `init`, assuming `pwsh` on the runner (epic Q4).
  - Template use: the manual copy described in the template `README.md` (OQ-A).
- `command-reference.md`: one heading and at least one fenced example per subcommand and per MCP
  tool (see below); the common parameters `-Json`, `-Help`, `-RepositoryRoot`; exit codes 0
  success, 1 findings, 2 usage (`DOCS_CLI_ARGUMENTS`), 3 internal (`DOCS_CLI_RUNTIME`,
  `DOCS_RUNTIME_UNSUPPORTED`); the `-Json` envelope `{command, exit_code, findings, ok, result}`
  governed by `schemas/docs/v1/docs-command-envelope.schema.json`.
- `workflow.md`: the 1037 roles (`docs-architect`, `docs-author`, `docs-reconciler`,
  `docs-coverage-reviewer`) and skills (`documentation-workflow`, `docs-init`,
  `docs-inventory-surface`, `docs-plan-ia`, `docs-author-page`, `docs-reconcile-behavior`,
  `docs-review-coverage`, `docs-validate`); the sequence inventory, plan, author, reconcile,
  review, validate; receipt persistence only from the root session or CI; the opt-in
  integration-PR gate (`completion_gates.integration_pr_gate.enabled`, deny prefix
  `DOCS_COMPLETE_GATE_BLOCKED:`); the `surface-delta` review step.

Subcommands documented (owner; options as bound by the owner's dispatch row):

| Subcommand | Owner | Options |
|---|---|---|
| `init` | 1020 | `-RepositoryId`, `-Profile`, `-Write`, `-Force`; dry run by default |
| `validate-profile` | 1020 | `-Profile` |
| `check` | 1021 | `-Profile`, `-Path` (repeatable); `result` `{page_count, profile_path, roots}` |
| `inventory` | 1022 (1033 analyzers; 1031 native path) | `-Profile`, `-Analyzer` (repeatable), `-Revision`, `-Write`, `-AnalysisMethod` (1031, provisional) |
| `coverage` | 1023 | `-Profile`; read-only |
| `update-ledger` | 1023 | `-Operation` (`set-disposition`, `remove-entry`, `pin`, `unpin`, `set-dimension`, `sync-refs`), `-Element`, `-Limit`, `-Disposition`, `-Page` (repeatable), `-Rationale`, `-Owner`, `-Target`, `-Dimension`, `-State`, `-Claim`, `-ActorKind`, `-ActorId`, `-Profile`, `-Write`; dry run unless `-Write` |
| `validate` | 1023 | `-Mode` (`profile`, `ledger`, `matrix`, `docs-complete`), `-Revision` (required), `-WriteReceipt` (only with `docs-complete`), `-Profile` |
| `generate-reference` | 1024 | `-Profile`, `-Snapshot`, `-OutputDirectory`, `-Write`; dry run by default; `result` `{mode, output_directory, pages, summary, unrendered}` |
| `surface-delta` | 1034 | `-Base`, `-BaseSnapshot`, `-BaseLedger`, `-Profile` (epic enforcement notes) |

MCP tools documented, as named by the epic naming contract and 1036 (MCP form
`mcp__drm-copilot__<name>`): `run_docs_check` (`check`), `run_docs_inventory` (`inventory`, never
writes), `run_docs_coverage` (`coverage`), `update_docs_ledger` (`update-ledger`, the only mutating
tool, writes only with `write: true`), `generate_docs_reference` (`generate-reference`, dry run
only), `validate_docs_artifacts` (`validate`, never persists a receipt). Every tool requires
`workspace_root`. The reference states that `init`, `validate-profile` and `surface-delta` have no
MCP tool, and that `validate -Mode profile` and `validate-profile` overlap (the reference names
`validate-profile` for profile-only checks).

Every option spelling in an example is taken from the merged dispatch rows recorded in Phase 0, not
from this table.

### End-to-end Pester suite

`tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` dot-sources
`.claude/lib/docs/Invoke-DocsCommand.ps1` and calls `Invoke-DocsCommandCli -Command <name> -Json
-CommandArgument <args> -Context <context>` in process with one stateful in-memory context from
`DocumentationEstateFixture.TestSupport.psm1` (path-to-text map whose `WriteText` updates the map
so later `ReadText`, `TestFile` and `ListFile` calls see the write; fixed `UtcNow`; an
`InvokeProcess` fake that records calls). Revisions are fixed 40-hex constants. No process starts,
no file is written, and the envelope is parsed with `ConvertFrom-DocsJsonText`.

Scenario:

1. Arrange: a docs profile at `docs/documentation-estate/docs-profile.json` with one `reference`
   directory mode, a page owner, `completion_gates.docs_complete` with `max_stale_pages: 0`,
   `allow_deferred: false` and `required_parity_dimensions` limited to dimensions the test sets;
   one Python source declaring command A in a construct the 1022 `python-cli` scanner classifies.
2. Baseline at revision R1: `inventory -Revision R1 -AnalysisMethod scanner -Write`;
   `update-ledger -Operation set-disposition` (A `documented`, bound to the reference page);
   `generate-reference -Write`; `update-ledger -Operation pin` (A to the page);
   `update-ledger -Operation set-dimension` per required dimension; `update-ledger -Operation
   sync-refs`; every `update-ledger` call with `-ActorKind tool -ActorId <id> -Write`.
   `validate -Mode docs-complete -Revision R1` exits 0. This proves the fixture is valid before the
   defects are introduced.
3. Introduce both defects: change a source line inside A's declaration line range without changing
   A's declaration (digest changes, identifier does not), and add command B. Run
   `inventory -Revision R2 -AnalysisMethod scanner -Write` and `sync-refs`.
4. Fail: `validate -Mode docs-complete -Revision R2` exits 1; the error finding codes are
   `DOCS_LEDGER_MISSING_DISPOSITION` (its `related_ids` hold B's element identifier and its message
   names B's declaration) and `DOCS_PAGE_STALE` (its `related_paths` hold the page path and its
   message names A's declaration and the status `digest-changed`); the receipt in `result` has
   `validation_result` `fail`.
5. Fix: record B (`documented` with a binding, pin and dimensions), re-pin A, run
   `generate-reference -Write` and `sync-refs`; `validate -Mode docs-complete -Revision R2` exits 0
   with `validation_result` `pass`.
6. `analysis_method`: every snapshot element and every ledger entry in steps 2 to 5 carries
   `analysis_method`, and the value is `scanner`; the `InvokeProcess` fake records no call.
7. Fail closed (D5): `inventory` without `-Revision` followed by `validate -Mode docs-complete`
   yields `DOCS_SNAPSHOT_UNPINNED`.

Scanner pin: `-AnalysisMethod scanner` (1031, provisional OQ-C) never calls the process seam, so the
result does not depend on whether the runner or host has a Python interpreter. If the merged
`inventory` row lacks `-AnalysisMethod`, Phase 0 reports a divergence.

Assertions name codes, `related_ids`, `related_paths`, exit codes and receipt fields; message
assertions use containment of the declaration and page path only.

### Epic template suite

`tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1` reads the committed
template once with `Get-Content -Raw` and uses `EpicManifest.TestSupport.psm1`, which holds pure
functions: a bounded frontmatter parser for the subset above (fails closed on any other construct),
schema checks (required keys, `integration_branch` equal to `epic/<epic>-integration`, `intent`
rules, unique `issue_num`, unique `feature_folder`), resolution of every `depends_on` entry through
the union of the `issue_num` and `feature_folder` sets before wave computation, self-edge
rejection, and wave computation (`wave(f) = 0` for empty `depends_on`, otherwise
`1 + max(wave(d))`) with in-progress cycle detection. The order of resolution before waves
preserves the behavior of `compute_wave_numbers`, which treats an unknown key as having no
dependencies. Positive controls apply in-memory mutations of the template text. No Python is
invoked, because the PowerShell CI shards install none.

### Documentation contract suite

`tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` reads the five committed
pages. It derives the expected subcommand set from `Get-DocsCommandTable` of the dot-sourced entry
script and the expected tool set from the committed `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts`
read as text (path confirmed in Phase 0), and asserts membership: each name has a heading and a
fenced example in `command-reference.md`. It also asserts the literal prerequisite and optional-pack
statements. A positive control runs the same check over an in-memory page missing one subcommand.

### Test conventions

- Pester 5 (`#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`), layout of
  `tests/scripts/claude-lib/mermaid/`, Arrange-Act-Assert, `AfterAll` removal of every imported
  `Docs*` and `DiscoveryEncoding` module.
- Discovery: `config/poshqc-scan.json` already scans `tests/scripts`; coverage roots already
  include `.claude/lib`; no configuration change.
- CI job: `poshqc / PowerShell QC` (shards on `windows-latest`). These suites are not under
  `tests/scripts/claude-hooks`, so the Linux hook job does not run them.
- Each Pester and support file stays below 500 logical lines; fixture text lives in the support
  module.

## File Inventory

| Path | Action | Notes |
|---|---|---|
| `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` | create | template manifest |
| `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/README.md` | create | usage |
| `docs/engineering/documentation-estate/README.md` | create | index |
| `docs/engineering/documentation-estate/architecture.md` | create | |
| `docs/engineering/documentation-estate/consumer-onboarding.md` | create | prerequisites and steps |
| `docs/engineering/documentation-estate/command-reference.md` | create | subcommands and MCP tools |
| `docs/engineering/documentation-estate/workflow.md` | create | roles, skills, gates |
| `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` | create | end-to-end |
| `tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1` | create | manifest and DAG |
| `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` | create | documentation contract |
| `tests/scripts/claude-lib/docs/DocumentationEstateFixture.TestSupport.psm1` | create | test support |
| `tests/scripts/claude-lib/docs/EpicManifest.TestSupport.psm1` | create | test support |

Production files: none. Bundle mirrors: none required. The template already lives under
`extensions/drm-copilot/resources/`, outside `claude-customizations/` and
`codex-and-agents-customizations/`, and no byte-parity test covers `feature-templates/`. The
onboarding pages are repository documentation and are not pushed down. Pack-manifest entries: none,
because no file under `.claude/lib/docs/` is added. `quality-tiers.yml`: no change. Execution
environment brief: no change.

## Cross-Child Contract Dependencies

Manifest dependencies: 1034 and 1037; transitively 1020, 1021, 1022, 1023, 1024 and 1036. 1031 and
1033 are not manifest dependencies; 1031 (wave 2) is merged before wave 5 in the planned order, and
the end-to-end suite depends on its `-AnalysisMethod` option.

| Contract | Owner | Used by |
|---|---|---|
| `Invoke-DocsCommand.ps1` parameters, dot-source guard, `Invoke-DocsCommandCli`, `Get-DocsCommandTable`, command context members, `Write-DocsFileText` | 1020 | end-to-end and documentation contract suites |
| Exit codes 0-3, `DOCS_CLI_ARGUMENTS`, `DOCS_CLI_RUNTIME`, `DOCS_RUNTIME_UNSUPPORTED`; PowerShell 7.4 floor (Q8) | 1020 | onboarding, command reference |
| Envelope `{command, exit_code, findings, ok, result}` and `schemas/docs/v1/docs-command-envelope.schema.json` (D5) | 1020 | command reference |
| `ConvertFrom-DocsJsonText`; `Docs.TestSupport.psm1` in-memory context | 1020 | end-to-end suite |
| `analysis_method` on elements and ledger entries (D3); declaration-lines digest (D5) | 1020, 1022, 1023 | end-to-end suite, architecture page |
| `init` options and `Get-DocsInitTemplate` rows; `init -Write` linter configuration set | 1020, 1021, 1034 | onboarding |
| `check` options and result `{page_count, profile_path, roots}` | 1021 | command reference |
| `inventory` options; analyzer identifiers; per-kind `line_range` rules | 1022 | end-to-end suite |
| `-AnalysisMethod auto|native|scanner`; Python 3.10 floor; fallback rules; OQ-D statement | 1031 | end-to-end suite, onboarding |
| TypeScript and .NET scanners behind `inventory` (`analysis_method: scanner`) | 1033 | architecture page |
| `coverage`, `update-ledger`, `validate` options; finding codes `DOCS_LEDGER_MISSING_DISPOSITION`, `DOCS_PAGE_STALE`, `DOCS_SNAPSHOT_UNPINNED`; receipt fields | 1023 | end-to-end suite, command reference |
| `generate-reference` options, `result` keys `{mode, output_directory, pages, summary, unrendered}`, exit 1 on `REFERENCE_WRITE_CONFLICT`, exit 3 on write failure | 1024 | end-to-end suite, command reference |
| MCP tool names, inputs, `DOCS_MUTATING_TOOLS`, result shape, tool definitions file | 1036 | command reference, documentation contract suite |
| `surface-delta` options, `_docs-quality.yml`, hook `enforce-docs-complete-gate.ps1`, gate key and deny prefix | 1034 | onboarding, workflow page |
| Roles, skills, SubagentStop output check | 1037 | workflow page |

Phase 0: the plan begins by reading each contract group above from the merged integration branch
and recording the actual symbol or value under `<FEATURE>/evidence/baseline/`. On any divergence
from this specification, the executor halts with a blocked report and the orchestrator routes one
plan revision; the executor does not adapt a test silently.

## Corrections to the Research

The research was written before several upstream specifications were re-prepared. The epic governs
where they differ:

- PowerShell floor: the epic 1038 criterion says "PowerShell 7"; Q8 (provisional default) requires
  7.4. This specification uses 7.4.
- Envelope schema: the epic `### PowerShell contracts from the re-preparation of 1020` says the
  envelope has no schema file; D5 gives it `docs-command-envelope.schema.json`. D5 governs.
- `generate-reference`: the research left its options and `result` unverified; the epic
  `### Generator contracts from the PowerShell preparation of 1024` fixes the options, the `result`
  key set `{mode, output_directory, pages, summary, unrendered}` and the exit-code rules.
- `surface-delta`: the 1034 dispatch row lists `-Base` and `-Profile`; the epic enforcement notes
  list `-Base`, `-BaseSnapshot`, `-BaseLedger` and `-Profile`. The epic list governs; Phase 0
  confirms the merged row.
- Native analyzer seam: the research marked it unverified; 1031 defines `inventory
  -AnalysisMethod auto|native|scanner`, which the end-to-end suite uses to pin the scanner.
- Upstream state: the research found most upstream specifications in the withdrawn Python design or
  absent; all upstream children now have PowerShell-design specifications, which this specification
  cites.
- MCP tool owner: the research used placeholder 900007; the owner is 1036, and the tool definitions
  file is `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts`.
- Dependencies: `issue.md` names a placeholder for the authoring workflow; the manifest dependency
  is 1037.
- Dispatch anchors: 1020 uses real issue numbers; the 1024 and 1034 specifications still quote
  earlier placeholder anchors. Children locate anchors by subcommand token (epic), so this child
  depends on subcommand names only.

## Owner Questions

Provisional defaults stand; this child does not wait on them.

- **OQ-A - Template delivery.** No command selects the template. Provisional default: documented
  manual copy. Alternatives: an `init` template row (a 1020 contract change) or an extension
  command argument (TypeScript plus an in-place edit of the existing Python twin).
- **OQ-B - `/epic-plan` criterion.** No executable `/epic-plan` parser exists and a live run needs
  an agent delegation that cannot run in CI. Provisional default: the criterion is verified by
  schema conformance and the DAG suite.

## Acceptance Criteria

- [ ] `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` and `README.md` exist, and no `epic-status.md` exists in that folder.
- [ ] The template is accepted by `/epic-plan` as a manifest path, verified as conformance to the `epic-orchestrate` manifest schema (OQ-B): `DocumentationEstateEpicTemplate.Tests.ps1` asserts that the frontmatter parses, has `epic: documentation-estate`, `integration_branch: epic/documentation-estate-integration`, a valid ISO-8601 `created_at`, an `intent` block meeting the schema rules, unique integer `issue_num` values and unique `feature_folder` values, and that every `depends_on` entry resolves to another `features[]` entry.
- [ ] `DocumentationEstateEpicTemplate.Tests.ps1` proves the template manifest has a cycle-free dependency graph under the epic manifest rules: no self-edge, no cycle, every foundation child at wave 0, every page-family child at wave 1, and the exit-gate child alone in the final wave depending on every page-family child; the computed waves equal the template's `## Planned Waves` list.
- [ ] Positive controls in `DocumentationEstateEpicTemplate.Tests.ps1` apply in-memory mutations of the template text (a two-node cycle, an unresolved `depends_on` entry, a duplicate `issue_num`, a construct outside the parsed YAML subset) and each mutation makes the check fail.
- [ ] The template `README.md` states how to place `epic.md` at `docs/features/epics/<slug>/epic.md`, that `epic` and `integration_branch` change together, and the `/epic-plan` invocation, and states that no command copies the template.
- [ ] The pages `README.md`, `architecture.md`, `consumer-onboarding.md`, `command-reference.md` and `workflow.md` exist under `docs/engineering/documentation-estate/`.
- [ ] `command-reference.md` has a heading and a fenced example for each of the subcommands `init`, `validate-profile`, `check`, `inventory`, `coverage`, `update-ledger`, `validate`, `generate-reference` and `surface-delta`, and `DocumentationEstateOnboarding.Tests.ps1` asserts that every row name returned by `Get-DocsCommandTable` of the merged entry script has such a heading and example.
- [ ] `command-reference.md` has a heading and a fenced example for each docs MCP tool by its exact contract name, and `DocumentationEstateOnboarding.Tests.ps1` asserts that every tool name defined in the merged `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts` has such a heading and example.
- [ ] `command-reference.md` documents the exit codes 0 to 3 with `DOCS_CLI_ARGUMENTS`, `DOCS_CLI_RUNTIME` and `DOCS_RUNTIME_UNSUPPORTED`, the envelope keys `command`, `exit_code`, `findings`, `ok`, `result` with the schema path `schemas/docs/v1/docs-command-envelope.schema.json`, and states that `init`, `validate-profile` and `surface-delta` have no MCP tool, that `update_docs_ledger` is the only mutating tool, and that `validate_docs_artifacts` never persists a receipt.
- [ ] Every option spelling in the command-reference examples matches the merged dispatch row of its subcommand or the merged input table of its MCP tool, as recorded in the Phase 0 evidence.
- [ ] `consumer-onboarding.md` states the destination-repository prerequisite PowerShell 7.4 (Q8 provisional default) and that a lower version exits 3 with `DOCS_RUNTIME_UNSUPPORTED`, and `DocumentationEstateOnboarding.Tests.ps1` asserts the `7.4` statement is present.
- [ ] `consumer-onboarding.md` states that the optional python pack, with Python 3.10 or later, enables the native Python analyzer (D3), that without it `inventory` falls back to the scanner and records `analysis_method: scanner`, the `-AnalysisMethod` choices, and that a push-down without a pack selection ships the inert helper; the documentation contract suite asserts the python pack statement is present.
- [ ] `consumer-onboarding.md` states that linting is optional (D4), names the configuration files `init -Write` writes, and states that `check` is the required page gate; the documentation contract suite asserts the optional-lint statement is present.
- [ ] `workflow.md` names the roles `docs-architect`, `docs-author`, `docs-reconciler`, `docs-coverage-reviewer`, the skills `documentation-workflow`, `docs-init`, `docs-inventory-surface`, `docs-plan-ia`, `docs-author-page`, `docs-reconcile-behavior`, `docs-review-coverage` and `docs-validate`, and the opt-in gate key `completion_gates.integration_pr_gate.enabled`.
- [ ] A positive control in `DocumentationEstateOnboarding.Tests.ps1` runs the membership check over an in-memory command reference missing one subcommand and the check fails naming that subcommand.
- [ ] `EndToEndDocumentationEstate.Tests.ps1` runs `inventory`, `update-ledger`, `generate-reference` and `validate -Mode docs-complete` in process through `Invoke-DocsCommandCli` with one stateful in-memory context, and the baseline at revision R1 exits 0.
- [ ] After the defects are introduced, `validate -Mode docs-complete -Revision R2` exits 1; its error findings are `DOCS_LEDGER_MISSING_DISPOSITION` with the undocumented command's element identifier in `related_ids` and its declaration in the message, and `DOCS_PAGE_STALE` with the stale page path in `related_paths` and the changed command's declaration in the message; the receipt in `result` has `validation_result` `fail`.
- [ ] After both defects are fixed through `update-ledger` and `generate-reference -Write`, `validate -Mode docs-complete -Revision R2` exits 0 and the receipt has `validation_result` `pass`.
- [ ] The end-to-end test records `analysis_method`: it asserts that every inventory snapshot element and every ledger entry produced in the scenario carries `analysis_method` with value `scanner` under `-AnalysisMethod scanner`, and that the `InvokeProcess` fake records no call.
- [ ] `EndToEndDocumentationEstate.Tests.ps1` asserts that `inventory` without `-Revision` followed by `validate -Mode docs-complete` yields `DOCS_SNAPSHOT_UNPINNED` (D5).
- [ ] No test creates temporary files: a scan of every new test and support file finds no `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`, and no new test starts a process.
- [ ] A neutrality scan using the 1020 consumer-identifier digest list reports no match in the template pair or the onboarding pages under `docs/engineering/documentation-estate/`.
- [ ] No file of this child is Python or TypeScript, and no file under `.claude/`, `extensions/drm-copilot/src/` or `extensions/drm-copilot/resources/claude-customizations/` is created or edited.
- [ ] The new suites `EndToEndDocumentationEstate.Tests.ps1`, `DocumentationEstateEpicTemplate.Tests.ps1` and `DocumentationEstateOnboarding.Tests.ps1` pass in the CI job `poshqc / PowerShell QC`, three seeded shuffled file-order runs and one fresh single-process run over `tests/scripts` pass with evidence under `evidence/regression-testing/`, and changed-line coverage of `.claude/lib/docs/` does not decrease against the baseline recorded under `evidence/baseline/`.
- [ ] Every new Pester and support file is below 500 logical lines, and the seven-stage toolchain passes in a single pass.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)

- [ ] Unit coverage areas: template manifest DAG check
- [ ] Integration scenarios: end-to-end inventory, ledger, generation, docs-complete
- [ ] CLI/API examples: every subcommand and MCP tool in the onboarding guide
