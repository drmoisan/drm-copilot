# documentation-estate-template-and-onboarding (#1038) - Research

- Issue: #1038 (epic #1019 child, manifest placeholder 900010, wave 5, band C3)
- Branch: `feature/documentation-estate-template-and-onboarding-1038`
- Preparation mode: true
- Tree read: the epic integration branch plus this item's promotion commit (agent worktree)
- Timestamp note: the file-name stamp was not read from a host clock (the task-researcher role has
  no shell); the orchestrator should confirm or rename it.

## Scope and Sources

Binding requirements were read from `docs/features/epics/documentation-estate-tooling/epic.md`
(sections `## Owner Directive: Implementation Language (2026-10-30, refined)`,
`### Artifact classes for this epic`, `## Owner Decisions`, `### Amendment of 1020 required by D3
and D5`, `### Naming contract (fixed for all children)`, `### PowerShell contracts from the
re-preparation of 1020`, the 1022/1023/1024 decision sections, and `### 900010 -
documentation-estate-template-and-onboarding`), from the 1020 `spec.md` section `## Decisions
Later Children Must Honor`, and from the specs and plans of 1021, 1022, 1023, 1024 and 1034 on this
tree. The owner decisions of 2026-10-30 supplied in the delegation prompt are binding and override
conflicting epic text.

## Executive Summary

1. No executable `/epic-plan` manifest parser exists. `/epic-plan` is an agent procedure: the
   `epic-planner` agent reads the manifest against the frontmatter schema in
   `.claude/skills/epic-orchestrate/SKILL.md` (`## Epic Dependency Manifest`). The only executable
   DAG rules are on checkpoint JSON (`_validate_dependency_waves` in
   `scripts/dev_tools/validate_epic_planner_state.py`, using `compute_wave_numbers` and
   `EpicWaveCycleError` from `scripts/dev_tools/epic_wave_computation.py`, with a TypeScript twin
   `extensions/drm-copilot/src/lib/validate/epic-wave-computation.ts`). "Accepted by `/epic-plan`
   as a manifest path" can therefore be verified only as structural conformance to that schema plus
   those checkpoint rules.
2. No PowerShell function parses an epic manifest or checks DAG acyclicity. The Pester DAG test
   must carry a minimal, bounded in-test parser and checker (test code). The PowerShell CI shards
   install no Python, so the test cannot call the Python reference.
3. The template subfolder `epic/documentation-estate/` is not picked up by any existing command.
   `copyTemplate` (`extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts`) and its Python
   twin (`scripts/dev_tools/new_active_feature_folder_io.py`) copy only `epic.md` and
   `epic-status.md` for the `epic` type. The folder ships inside the extension and the MCP server
   package (`packages/mcp-server/prepack.cjs` copies `resources`), but no command or tool exposes
   it. Consumer delivery is an owner question (OQ-A).
4. Every upstream contract the end-to-end test calls is unmerged and, on this tree, only partly
   re-prepared: the 1020 spec is the PowerShell design (version 0.3) but lacks the D3/D5 amendment
   (`analysis_method`, declaration-lines digest, envelope schema); the 1021, 1022, 1023 and 1024
   specs and plans still describe the withdrawn Python package design; 1034 has a draft spec only;
   900004, 900007, 900009 and 900011 have no folder on this tree. The 900010 plan must begin with a
   Phase 0 that re-derives every upstream symbol from the merged integration branch and halts on
   divergence.
5. This child adds no production code: one template pair (Markdown), five onboarding pages
   (Markdown) and Pester tests. Nothing needs push-down mirroring, a pack-manifest entry, a
   `quality-tiers.yml` entry or an execution-environment brief update.

## Current State Analysis

### Tree inventory relevant to this child

| Path | State on this tree |
|---|---|
| `.claude/lib/docs/` | absent (1020 not merged) |
| `schemas/docs/v1/`, `examples/docs/v1/` | absent |
| `tests/scripts/claude-lib/docs/` | absent |
| `docs/engineering/documentation-estate/` | absent |
| `extensions/drm-copilot/resources/feature-templates/epic/` | `epic.md`, `epic-status.md` only |
| `docs/features/templates/epic/` | `epic.md`, `epic-status.md` (workspace fallback twin; no parity test found) |
| `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/` | `issue.md`, `spec.md` (template-level draft), `user-story.md` (template-level draft), `plan.2026-10-30T18-59.md` (unfilled template) |

Defects in this item's folder that the planner must correct:

- `plan.2026-10-30T18-59.md` is the unfilled template; its `[P0-T1]` names the Python policies,
  which do not apply (no Python is in scope).
- `user-story.md` `## Acceptance Criteria` splits wrapped criteria into separate checkboxes (one
  criterion becomes three boxes), so checkbox counts do not match criteria.
- `issue.md` names the native analyzer child by placeholder; the prompt maps it to issue 1031.

### Upstream preparation state on this tree

| Child | Folder on this tree | Spec state |
|---|---|---|
| 1020 profile and schemas | yes | PowerShell design, version 0.3; no `analysis_method`, no declaration-lines digest rule, envelope "has no schema file" (pre-D3/D5) |
| 1021 page checker | yes | withdrawn Python design (`dev.docs.*`, `packages/docs-runtime`) |
| 1022 Python/config scanner | yes | withdrawn Python design |
| 1023 ledger and receipt | yes | withdrawn Python design (finding codes and semantics are language-independent and reused below) |
| 1024 reference generator | yes | withdrawn Python design |
| 1034 enforcement and CI | yes | draft spec (Behavior and Constraints only) |
| 900004 (prompt: 1033) TypeScript/.NET scanner | no | epic text only |
| 900007 docs MCP tools | no | epic text only |
| 900009 (prompt: 1037) authoring workflow | no | epic text only |
| 900011 (prompt: 1031) Python-native analyzer | no | epic text only |

A search for `analysis_method` and `docs-command-envelope` under `docs/features/` matches only
the epic and this item's own documents, confirming that no child spec on this tree carries the D3
or D5 amendment yet.

### Recorded conflicts (later owner decision wins)

1. **Envelope schema.** Epic `### PowerShell contracts from the re-preparation of 1020` and 1020
   spec `#### Exit codes and the -Json envelope` say the envelope has no schema file. Owner
   decision D5 gives it `schemas/docs/v1/docs-command-envelope.schema.json`. D5 wins; the
   onboarding command reference documents the envelope by that schema.
2. **`analysis_method`.** 1020 spec v0.3 schemas have no `analysis_method`. D3 and the epic
   `### Amendment of 1020` add it to inventory elements and ledger entries. D3 wins.
3. **Element digest.** 1023 spec leaves "whole file or declaration lines" open (its open question
   Q1). D5 fixes declaration lines.
4. **PowerShell floor.** Epic A5 and the epic 900010 acceptance criterion say "PowerShell 7"; 1020
   OQ-3 provisional default (epic Q8) requires 7.4 and fails closed below it with
   `DOCS_RUNTIME_UNSUPPORTED`. The prompt and `issue.md` state 7.4; owner decision item (2) left
   Q6-Q10 on provisional defaults, so 7.4 applies.
5. **Owner anchors.** 1020 spec dispatch and registry anchors use earlier placeholder numbers
   (`900003` for the Python scanner now 1022, `900006` for the generator now 1024, `900008` for
   surface-delta now 1034). The epic manifest uses 1022/1024/1034. Phase 0 must read the anchors as
   merged, not as written in either document.
6. **Placeholder mapping.** The manifest on this tree still lists 900004, 900007, 900009, 900010
   and 900011; the prompt maps 900004 to 1033, 900009 to 1037, 900010 to 1038 and 900011 to 1031,
   and gives no number for 900007. The back-fill is pending; the 900010 plan must cite issue
   numbers from the manifest as merged at execution.
7. **Envelope command field.** The 1023 Python-design envelope used console names
   (`dev.docs.validate`); the 1020 PowerShell design uses the subcommand name (`validate`). The
   PowerShell form applies.

## Q1 - How `/epic-plan` consumes a manifest path

Verified sources: `.claude/skills/epic-plan/SKILL.md` (`argument-hint: "[epic objective or
epic-manifest-path]"`, `## Decomposition and Wave Design`), `.claude/agents/epic-planner.md`
(`## Completion Requirements` item 1: the manifest "parses against the `epic-orchestrate` schema
with a cycle-free dependency graph"), `.claude/skills/epic-orchestrate/SKILL.md`
(`## Epic Dependency Manifest`, `## Wave Assignment`).

Required frontmatter (YAML block between `---` fences at the top of the file):

| Key | Rule |
|---|---|
| `epic` | epic slug |
| `integration_branch` | `epic/<epic-slug>-integration` (the readiness check in `scripts/dev_tools/epic_planner_readiness.py` requires exactly this form for the checkpoint) |
| `created_at` | ISO-8601 timestamp |
| `intent` (optional) | when present: `epic_type` in {`business`, `enabler`}, non-empty `business_outcome_hypothesis`, optional string lists `leading_indicators`, `nfrs` |
| `features[]` | each `issue_num` (int, primary key, unique), `feature_folder` (resolvable hint basename, unique), `depends_on` (list of `issue_num` values; legacy folder basenames resolve through the union index) |

Manifest rules (`epic-orchestrate` schema and `_validate_dependency_waves`):

- Every `depends_on` entry resolves through the union of the `issue_num` set and the
  `feature_folder` set to another `features[]` entry; an unresolved entry or a duplicate
  `feature_folder` is a malformed manifest.
- `issue_num` values are unique (checkpoint validator).
- Waves: `wave(f) = 0` when `depends_on(f)` is empty, else `1 + max(wave(d))`; a node revisited
  while in progress is a cycle (`EpicWaveCycleError`).
- `compute_wave_numbers` treats a dependency that is not a key as having no dependencies
  (`manifest.get(feature_folder, ())`), so resolution must be checked before waves are computed.
  The in-test checker must preserve that order.
- The Markdown body is narrative and is not machine-parsed.

Placeholders: the epic expresses unknown child issues as integer placeholders of the form `9000NN`
with a leading YAML comment ("PLANNING STATE ... placeholders until each child's promotion receipt
is back-filled"), and `/epic-plan` back-fills them (`## Decomposition and Wave Design`, final
paragraph). The generic template `epic/epic.md` uses non-parseable tokens (`<int>`, `<iso8601>`,
`<epic-slug>`), so it is a scaffold, not an acceptable manifest. To be "accepted as a manifest
path", the documentation-estate template must use parseable values throughout: a concrete slug
(recommended `documentation-estate`), `integration_branch: epic/documentation-estate-integration`,
a valid ISO-8601 `created_at` with a comment instructing replacement, `9000NN` integer placeholders
with the same planning-state comment, and unique slug-form `feature_folder` hints.

Existing PowerShell reuse: none. `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`
(`Get-OrchestratorStateEpicWaveBarrierError`) and `.claude/hooks/enforce-epic-wave-barrier.ps1`
(`Test-EpicWaveBarrierDependenciesMerged`) evaluate merge status in checkpoint JSON; they neither
parse YAML frontmatter nor compute waves or cycles. `.claude/lib/worktree-resolution/EpicScopeReadiness.psm1`
is checkpoint-based. The frontmatter readers under `.claude/lib/bash/` (`parallel-yaml-scan.sh`,
`parallel-manifest-validate.sh`) serve parallel manifests in bash. `Get-MermaidFrontmatter` in
`.claude/lib/mermaid/MermaidValidation.psm1` extracts a flat key set only. The 1021
`DocsPageFrontMatter.psm1` is planned as a bounded parser for the page-metadata field subset and
does not cover nested sequences.

Python dependency check: `.github/workflows/_poshqc.yml` contains no `setup-python`, `poetry` or
`python` step, and no Pester suite under `tests/scripts` invokes Python (matches in
`enforcement-hooks-no-python-invocation.Tests.ps1` and `HostVerification.Tests.ps1` are fixture
text or mocks). A Pester test therefore must not call `epic_wave_computation.py`.

Decision: the DAG test carries a minimal parser and checker in a test-support module (class
`test`). A new pushed-down helper (for example a `DocsEpicManifest.psm1`) would be permitted by the
language rule (PowerShell under `.claude/lib/docs/`) but has no runtime consumer, adds a core
manifest entry, mirror copy, coverage obligation and tier impact, and is rejected (see
`## Candidate Approaches`).

## Q2 - How feature templates are delivered and selected

- `buildTemplateRoot` (`extensions/drm-copilot/src/repo-automation-service-workflows.ts`) returns
  `<extensionRoot>/resources/feature-templates`; `RepoAutomationService` passes it as
  `templateRoot`. `flow.ts` (`extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts`)
  resolves `<templateRoot>/<featureType>` or, without a template root, the workspace
  `docs/features/templates/<featureType>`. Valid types are `feature`, `refactor`, `epic`, `bug`.
- For `epic`, `copyTemplate` copies only `epic.md` and `epic-status.md`; other types copy the whole
  tree. A new `epic/documentation-estate/` subfolder is therefore never copied and cannot be
  selected; no argument selects an epic variant. The Python twin behaves the same.
- `resources/feature-templates` is not a push-down root: no pack manifest under
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/` names it, and the
  push-down completeness tests (`test_push_down_claude_pack_manifest_completeness.py`) walk only the
  `claude-customizations/.claude` tree.
- Packaging: `.vscodeignore` excludes only `resources/scripts/**`, so the subfolder ships in the
  VSIX; `packages/mcp-server/prepack.cjs` copies `resources` into the MCP server package. Shipping
  is automatic; selection is not.
- Tests enumerating feature-template files, with disposition:

| Test | What it pins | Disposition |
|---|---|---|
| `extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts` ("for epic copies only epic.md and epic-status.md") | epic copy set, in-memory seed | unaffected (seeded fake file system) |
| `extensions/drm-copilot/test/lib/new-active-feature-folder/flow.test.ts`, `docs.test.ts` | epic scaffold and stamping | unaffected (seeded) |
| `tests/scripts/dev_tools/test_new_active_feature_folder_part2.py` | Python twin epic scaffold | unaffected (in-memory) |
| `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` (`_FT`, `_TEMPLATES = ("bug", "feature", "refactor")`) | plan templates | unaffected (epic not enumerated) |
| `extensions/drm-copilot/test/extension.integration.test.ts`, `repo-automation-dispatch.test.ts`, `new-active-feature-folder-fs-harness.ts`, `extension.workflow-commands.test.ts`, `extension.new-*-inprocess.test.ts` | template-root forwarding | unaffected (path strings only) |
| `tests/scripts/dev-tools/new-potential-entry*.Tests.ps1` | potential template root | unaffected |

- Consumption of the existing epic template: `epic.md` is copied and stamped into
  `docs/features/epics/<slug>/epic.md`; `epic-status.md` is a generated projection regenerated by
  `epic-orchestrator` from `artifacts/orchestration/epic-orchestrator-state.json` and is never
  hand-authored. The documentation-estate pair is `epic.md` and `README.md`; it should not include
  an `epic-status.md`, and its `README.md` should state how to place `epic.md` at
  `docs/features/epics/<slug>/epic.md` (the path the readiness check expects) before running
  `/epic-plan`.

## Q3 - `docs/engineering/` conventions

- Precedent: `docs/engineering/legacy-discovery-and-parity/` uses a `README.md` with sections
  `## Domain-Neutrality Invariant`, `## Ownership`, `## Audience`, `## Topic Pages` (a table of
  page links and coverage), and `## Capability Provenance` (feature delivery recorded once; pages
  link to code, schema and template paths rather than feature folders). It also has
  `architecture.md`, `workflow.md`, `consumer-onboarding.md` and `cli-reference.md`, matching the
  page names this child adds (the child uses `command-reference.md`).
- Consumer names in that precedent appear only in one separated example page; this child ships no
  example page with consumer names.
- No repository index links `docs/engineering/` pages (root `README.md` has none).
- Contract tests on `docs/engineering/`: `tests/scripts/dev_tools/test_discovery_documentation_contracts.py`
  pins only the legacy-discovery page set (and one reference in `claude-code-architecture.md`);
  `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` pins
  `docs/engineering/claude-code-architecture.md`. Neither enumerates other directories. Do not edit
  `claude-code-architecture.md` (pinned) unless a task names that test.
- CI: `_docs-validation.yml` checks only `README.md` and `LICENSE` presence (brief,
  `## Evidence and Documentation Rules`); there is no Markdown lint or link check. `docs/engineering/`
  is not on the docs-only allowlist (`tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1` asserts no
  include prefix covers it), so a change there produces a full CI run, which this child needs
  anyway for its Pester suites.
- Because no CI check validates these pages, the plan should add a Pester documentation contract
  (see `## Testing Implications`) rather than a Python test (no new Python).

## Q4 - Pester conventions, scan and coverage membership, CI job

- Layout follows `tests/scripts/claude-lib/mermaid/`: `#Requires -Version 7.0`,
  `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`, a help block stating
  that the suite reads no file it does not need, starts no process and creates no temporary file,
  `BeforeAll` resolving the module path relative to `$PSScriptRoot`, Arrange-Act-Assert bodies.
  1020 adds `tests/scripts/claude-lib/docs/` with `Docs.TestSupport.psm1` (in-memory command
  context and schema-set builders) and an `AfterAll` module-removal rule after dot-sourcing
  `Invoke-DocsCommand.ps1`.
- `config/poshqc-scan.json` `test.scanFolders` is `scripts`, `tests/powershell`, `tests/scripts`;
  new suites under `tests/scripts/claude-lib/docs/` are discovered with no config change.
- `config/poshqc-coverage.json` `roots` already include `.claude/lib`; this child adds no
  production PowerShell, so no change. The coverage population is derived by `Invoke-PoshQCTest`.
- CI: the suites run with coverage on `windows-latest` in `poshqc / PowerShell QC shard 1`,
  `shard 2` or `shard 3` (automatic assignment), aggregated by the required check
  `poshqc / PowerShell QC`. They are not under `tests/scripts/claude-hooks` or
  `tests/scripts/codex-hooks`, so `poshqc / PowerShell hook suites (Linux)` does not run them; every
  Pester acceptance criterion must name `poshqc / PowerShell QC` and must not cite `ubuntu-latest`
  (`.claude/skills/atomic-plan-contract/SKILL.md`, Pester runner rule).

## Q5 - Upstream contracts the end-to-end test calls

Precondition: the 900010 plan executes only after 1020, 1021, 1022, 1023, 1024, 1034, 900007 and
900009 (and transitively every earlier child) have merged into
`epic/documentation-estate-tooling-integration`. 900004 and 900011 are not dependencies of 900010
(manifest `depends_on: [1034, 900009]`), but 900011 is wave 2 and normally merged before wave 5;
the end-to-end test must not depend on its presence (see the scanner pin below).

Source tags: [1020-spec] verified in the 1020 spec on this tree; [epic] epic naming contract;
[1023-py] language-independent content of the withdrawn-design 1023 spec, to be re-confirmed in the
PowerShell re-preparation; [UNVERIFIED] not determinable on this tree. Every row is "per epic naming
contract or child spec; re-verify at execution".

| Contract | Value | Source |
|---|---|---|
| Entry script | `.claude/lib/docs/Invoke-DocsCommand.ps1 -Command <subcommand> [-Json] [-Help] [-RepositoryRoot <path>] [arguments]` | [1020-spec] |
| In-process seam | dot-source the script (body guarded by `$MyInvocation.InvocationName -ne '.'`), call `Invoke-DocsCommandCli -Command -Json -Help -RepositoryRoot -CommandArgument [-Context]` returning `@{ ExitCode; Stdout; Stderr }` | [1020-spec] |
| Command context | `[pscustomobject]` with `RepositoryRoot`, `ReadText`, `ReadBytes`, `TestFile`, `ListFile`, `WriteText` (`param($RelativePath, $Text, $Mode)`, `create` or `overwrite`), `UtcNow`; real context only from `New-DocsCommandContext`; only write primitive `Write-DocsFileText` | [1020-spec] |
| Test context builder | `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1`: scriptblocks over a path-to-text hashtable, a write log, a fixed clock | [1020 plan `P3-T2`]; function names [UNVERIFIED]; whether `WriteText` updates the map so later `ReadText`/`ListFile` see the write is [UNVERIFIED] and is required by this test |
| Envelope | canonical JSON `{command, exit_code, findings, ok, result}`, `command` is the subcommand name; schema `schemas/docs/v1/docs-command-envelope.schema.json` | [1020-spec] plus D5 |
| JSON parsing | `ConvertFrom-DocsJsonText` (never `ConvertFrom-Json` for artifacts) | [1020-spec] |
| Exit codes | 0 success, 1 findings, 2 usage (`DOCS_CLI_ARGUMENTS`), 3 internal (`DOCS_CLI_RUNTIME`, `DOCS_RUNTIME_UNSUPPORTED`) | [1020-spec], [epic] |
| Identity | `Get-DocsElementId -Kind -Path -Declaration`; `cli-command` declaration is the full command path | [1020-spec] |
| Profile | JSON at `docs/documentation-estate/docs-profile.json`; keys used: `surface_selection`, `artifact_paths.{inventory_snapshot, coverage_ledger, parity_matrix, evidence_pins, validation_receipt}`, `completion_gates.docs_complete.{allow_deferred, max_stale_pages, required_parity_dimensions}`, `page_owners`, `documentation_roots`, `diataxis_policy.directory_modes` | [1020-spec] |
| `inventory` | owner 1022; selects analyzers from the profile; optional revision argument, absent means `revision: null`; PowerShell argument names [UNVERIFIED] (withdrawn design used `--revision`, `--analyzer`, `--output`) | [epic], [1022 withdrawn spec] |
| `analysis_method` | `native` or `scanner` on each inventory element and each ledger entry | D3, epic amendment; field placement [UNVERIFIED] until 1020 is re-planned |
| Native analyzer fallback | with the python pack and an interpreter, `inventory` runs the native analyzer for `python-cli`, `python-http`, `python-public-api`, `python-architecture`; otherwise scanner | [epic] 900011 (issue 1031); detection seam [UNVERIFIED] |
| `update-ledger` | operations `set-disposition`, `remove-entry`, `pin`, `unpin`, `set-dimension`, `sync-refs`; dry run unless a write switch; actor kind and id required; only mutating subcommand | [epic], [1023-py] |
| `validate` | modes `profile`, `ledger`, `matrix`, `docs-complete`; required revision; receipt always in `result`; write-receipt switch persists | [epic], [1023-py] |
| `generate-reference` | owner 1024; family pages `cli-reference.md`, `http-reference.md`, `config-reference.md`, `api-reference.md`; output directory from the single `reference` directory mode or an explicit argument; dry run unless write | [epic], [1024 withdrawn spec] |
| Undocumented element code | `DOCS_LEDGER_MISSING_DISPOSITION`: message names kind, declaration and element id; `related_ids` the element id, `related_paths` its path | [1023-py] |
| Stale page code | `DOCS_PAGE_STALE`: warning in `matrix`; in `docs-complete` an error only when the stale-page count exceeds `max_stale_pages`; message names the page path and, per non-current pin, declaration, element id and status (`digest-changed` or `element-missing`) | [1023-py] |
| Unpinned snapshot | `DOCS_SNAPSHOT_UNPINNED` when the snapshot revision is null (fails closed) | [1023-py], D5 |
| Other `docs-complete` errors the fixture must avoid | `DOCS_MATRIX_ROW_MISSING` (documented binding without a matrix row), `DOCS_PAGE_MISSING`, `DOCS_PARITY_REQUIRED_DIMENSION`, `DOCS_DEFERRED_NOT_ALLOWED`, `DOCS_REVISION_MISMATCH` | [1023-py] |
| Receipt | `docs-validation-receipt`: `mode`, `repository`, `revision` (non-null), `inputs`, `counts.{elements_total, undocumented, stale_pages, by_disposition, by_kind}`, `validation_result` `pass` or `fail`, `findings`, `issued_at`, `writer` | [1020-spec], [1023-py] |
| Staleness rule | a page is stale when any pin on it is not `current`; digest compared as an opaque value; under D5 the digest covers the declaration's source lines | [1023-py], D5 |

Contracts from children not on this tree (take from the epic only; per epic naming contract;
re-verify at execution):

- 1034: `surface-delta -Base <ref>`, `.claude/lib/docs/DocsSurfaceDelta.psm1`, opt-in hook
  `.claude/hooks/enforce-docs-complete-gate.ps1` keyed on
  `completion_gates.integration_pr_gate.enabled`, consumer workflow `_docs-quality.yml` delivered
  by `init`.
- 1033 (900004): analyzers behind `inventory` only (`DocsAnalyzerTypeScript*`, `DocsAnalyzerDotnet*`,
  `DocsExtensionImport.psm1`); records `analysis_method: scanner`.
- 1037 (900009): roles `docs-architect`, `docs-author`, `docs-reconciler`,
  `docs-coverage-reviewer`; skills `documentation-workflow`, `docs-init`, `docs-inventory-surface`,
  `docs-plan-ia`, `docs-author-page`, `docs-reconcile-behavior`, `docs-review-coverage`,
  `docs-validate`.
- 1031 (900011): `DocsAnalyzerPythonNative.psm1` adapter plus a Python helper in the python pack.
- 900007: TypeScript wrappers invoking `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1
  -Command <name> -Json`.

Handling citations to files that do not yet exist: the plan's Phase 0 carries one task per
upstream contract group (entry seam and context, test-support builders, `inventory` arguments and
`analysis_method`, `update-ledger` operations and switches, `validate` modes and receipt,
`generate-reference` arguments, finding codes, dispatch-table rows, MCP tool names). Each task
reads the merged file and records the actual symbol or value in an evidence file under
`<FEATURE>/evidence/baseline/`. On any divergence from the plan text, the executor halts with a
blocked report rather than adapting the test silently; the orchestrator routes a single plan
revision. Preflight in preparation mode cannot resolve these symbols, so the plan states that its
upstream citations are provisional and are bound by Phase 0.

## Q6 - Subcommands and MCP tools to document

| Subcommand | Owner (manifest) | Notes for the example |
|---|---|---|
| `init` | 1020 | dry run by default; `-Write`, `-Force`; writes the starter profile and template rows (1021 configuration, 1034 workflow) |
| `validate-profile` | 1020 | `-Profile <relative path>` |
| `check` | 1021 | page checker; findings per file |
| `inventory` | 1022 (1033 adds analyzers; 1031 adds the native Python path) | pass a full revision so `docs-complete` can pass |
| `coverage` | 1023 | read-only report |
| `update-ledger` | 1023 | six operations; dry run unless write |
| `validate` | 1023 | `-Mode profile|ledger|matrix|docs-complete`, revision required, write-receipt switch |
| `generate-reference` | 1024 | dry run unless write |
| `surface-delta` | 1034 | `-Base <ref>` |

| MCP tool | Owner | Maps to |
|---|---|---|
| `run_docs_check` | 900007 | `check` |
| `run_docs_inventory` | 900007 | `inventory` |
| `run_docs_coverage` | 900007 | `coverage` |
| `update_docs_ledger` | 900007 | `update-ledger` (only mutating tool) |
| `generate_docs_reference` | 900007 | `generate-reference` |
| `validate_docs_artifacts` | 900007 | `validate`; never persists receipts |

`init`, `validate-profile` and `surface-delta` have no MCP tool in the naming contract; the
command reference should state this rather than imply parity. `validate -Mode profile` overlaps
`validate-profile`; the reference should state which to use.

Examples must not invent argument spellings: every example is written after Phase 0 records the
merged option names, and the documentation contract test (below) derives the subcommand list from
the merged dispatch table.

## Q7 - Mirroring, manifests, tiers, brief, file size

- Push-down mirroring: none. The template is under `extensions/drm-copilot/resources/` but outside
  `claude-customizations/` and `codex-and-agents-customizations/`; no pack manifest or byte-parity
  test covers `feature-templates/`. Onboarding pages are repository documentation. No
  `docs/features/templates/epic/documentation-estate/` twin is needed, because the workspace
  fallback also copies only `epic.md` and `epic-status.md` for epics and no test compares the two
  template trees.
- Pack manifests: none (no `.claude/lib/docs/` file is added).
- `quality-tiers.yml`: none; `extensions/drm-copilot` is already classified and this child adds
  no project.
- Execution-environment brief: no update; no CI job, required check, tool route or batch-budget
  rule changes.
- Batch budget: no production PowerShell or Python file is created, and test files never count, so
  direct mode suffices; the epic's item-worktree guidance still applies because the end-to-end test
  must run against the merged integration branch.
- File size: Markdown is exempt. The end-to-end suite will be the largest file; keep fixture text
  and the stateful in-memory context in a test-support module so each Pester file stays below the
  500-line guidance (hard limit above 800; `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`
  and `.claude/hooks/enforce-file-size-limit.ps1`).

## Candidate Approaches

### DAG verification

- **A (selected): in-test bounded parser and checker.** A test-support module reads the committed
  template text once (`Get-Content -Raw`; reading a committed file is not a temporary file),
  extracts the frontmatter between the first two `---` fences, parses a fixed YAML subset
  (top-level scalar keys, the optional `intent` block, a `features:` block sequence of mappings
  with `issue_num`, `feature_folder`, `depends_on` as a flow sequence of integers, `#` comments)
  and fails closed on anything else. Pure functions: `ConvertFrom-*` (text to records),
  `Test-*` (schema rules, uniqueness, resolution through the union index, self-edge), and a wave
  function implementing the longest-path formula with in-progress cycle detection. Advantages: no
  production surface, no Python, deterministic, matches repository test-location rules.
  Limitation: a second implementation of the formula exists in test code; mitigated by positive
  controls and by asserting the waves stated in the template body.
- **B (rejected): pushed-down `.claude/lib/docs/DocsEpicManifest.psm1`.** Permitted by the
  language rule but no runtime consumer; adds core manifest, mirror, coverage and tier work.
- **C (rejected): pytest calling `compute_wave_numbers`.** Exact reference, but new Python test
  code contradicts "avoid new Python", and a Pester test cannot call Python in the PowerShell
  shards.

### End-to-end orchestration

- **A (selected): in-process through `Invoke-DocsCommandCli` with one stateful in-memory context.**
  Exercises the real dispatch table, argument parsing, envelopes and exit codes without a process
  or a file.
- **B (rejected): calling command functions directly.** Skips the dispatch and argument contract
  that the onboarding documentation describes.
- **C (rejected): `pwsh -File` subprocess against a fixture directory.** Requires files on disk
  (prohibited) and an external process.

### Template delivery

- **A (selected for this child): ship the pair at the epic-specified path; `README.md` instructs
  copying `epic.md` to `docs/features/epics/<slug>/epic.md`; raise OQ-A.**
- **B (owner question): an `init` template row** under `.claude/lib/docs/templates/` would deliver
  it, but 1020 commits anchors only for 1021 and 1034, so a new anchor is a 1020 contract change.
- **C (owner question): an extension command or MCP argument selecting an epic variant** is
  TypeScript (permitted as an extension command) but changes `copyTemplate`, its Python twin
  (existing Python may be edited in place only) and several tests.

## Behavior Semantics

### Template content

- Frontmatter: as in Q1, with a `features[]` DAG of the shape wave 0 foundation (profile through
  `init`, information architecture, page templates, page metadata, docs CI through the `init`
  workflow row), wave 1 page families (for example reference via `generate-reference`, how-to,
  tutorial, explanation and architecture), and one final exit-gate child depending on every page
  family, whose acceptance is a passing `validate -Mode docs-complete` receipt pinned to the head
  revision and, optionally, enabling `completion_gates.integration_pr_gate.enabled` (1034 hook).
  The planner decides whether wave 0 is one child or several; the DAG test asserts the shape
  (every foundation child at wave 0, every page family at wave 1, the gate child alone at the last
  wave and depending on all page families).
- Body: goal, scope, non-goals, shared design (naming of roles and skills per 900009, the
  `analysis_method` meaning, lint optional per D4), decomposition and a `## Planned Waves` list
  that the DAG test compares with computed waves.
- Neutrality: no consumer identifier, no repository-specific paths beyond the docs profile
  default.

### End-to-end scenario (success and failure conditions)

1. Arrange an in-memory repository: a docs profile with one `reference` directory mode, a page
   owner, `max_stale_pages: 0`, `allow_deferred: false`, and `required_parity_dimensions` limited to
   dimensions the test sets; one Python source declaring command A (a construct the 1022 scanner
   classifies).
2. Baseline: `inventory` with revision R1; `update-ledger set-disposition` A `documented` bound to
   the reference page; `generate-reference` with write; `update-ledger pin` A to the page;
   `set-dimension` for each required dimension; `sync-refs`; `validate -Mode docs-complete` at R1
   exits 0. This proves the fixture is valid before the defect is introduced.
3. Introduce both defects: change a source line inside A's declaration range without changing A's
   declaration text (digest changes, identifier does not), and add command B. `inventory` at R2;
   `sync-refs` so reference warnings do not mask the result.
4. Fail: `validate -Mode docs-complete` at R2 exits 1; findings contain
   `DOCS_LEDGER_MISSING_DISPOSITION` whose `related_ids` hold B's identifier and whose message names
   B's declaration, and `DOCS_PAGE_STALE` whose `related_paths` hold the page path and whose
   message names A; the receipt in `result` has `validation_result` `fail`, `counts.undocumented`
   1 and `counts.stale_pages` 1.
5. Fix: record B (documented with a binding, then pin and dimension, or excluded with a
   rationale), re-pin A, regenerate, `sync-refs`; `validate -Mode docs-complete` at R2 exits 0
   with `validation_result` `pass`.
6. `analysis_method`: every snapshot element and every ledger entry carries `analysis_method`
   equal to `scanner` (pinned, see below).
7. Fail-closed check (D5): an `inventory` without revision followed by `docs-complete` yields
   `DOCS_SNAPSHOT_UNPINNED`.

Ordering rules: each step consumes the previous step's writes through the same context; the clock
is fixed; revisions are fixed 40-hex constants. Which source lines fall inside A's declaration
range depends on 1022's line-range rule [UNVERIFIED]; Phase 0 records it.

Scanner pin: native analysis starts a Python process (prohibited in unit tests), and a
`windows-latest` runner may have an interpreter while a local host may not. The test must force the
scanner path through the detection seam that 1031 exposes (or use a profile analyzer selection that
excludes the native adapter) and assert `scanner`. If 1031 exposes no seam, that is a divergence for
Phase 0 to report.

## Requirements Mapping

| Acceptance criterion (issue) | Design | Verification |
|---|---|---|
| End-to-end inventory, ledger, generation, `docs-complete`; fails naming both; passes after fix; `analysis_method` recorded | Scenario above in `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` with a support module | Pester, job `poshqc / PowerShell QC` |
| Template accepted by `/epic-plan` as a manifest path | Parseable frontmatter conforming to the `epic-orchestrate` schema; recommended rewording: "the template frontmatter conforms to the `epic-orchestrate` manifest schema and the checkpoint DAG rules" | DAG and schema suite |
| Cycle-free DAG under the epic manifest rules | In-test checker: required keys, `integration_branch` form, `intent` rules, unique `issue_num` and `feature_folder`, union-index resolution, no self-edge, acyclic, waves equal the body's `## Planned Waves`; positive controls on in-memory mutations (a two-node cycle, an unresolved reference, a duplicate `issue_num`) each produce a failure | Pester (for example `tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1`) |
| Onboarding documents every subcommand and MCP tool with an example; PowerShell 7.4; python pack enables native analyzer; linting optional | Five pages; `command-reference.md` has one heading and one fenced example per subcommand and per tool | Pester documentation contract: subcommand names from `Get-DocsCommandTable` of the merged entry script, tool names from the merged 900007 definitions file (path recorded in Phase 0), plus literal checks for `7.4`, the python pack statement and the optional-lint statement |
| No test creates temporary files | In-memory contexts; committed files read once | Scan of new test files for `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName`, `$env:TEMP` |
| No consumer identifier in source or documentation (constraint) | Neutral text | Reuse the 1020 neutrality helper and digest list over the template and the five pages, if the helper is importable (location [UNVERIFIED]); otherwise a support-module copy of the digest scan |

Proposed new and edited files are listed in `## Artifact Classification`. No production file is
edited.

## Numeric Derivation Evidence

Recommendation: spec acceptance criteria name subcommands and tools rather than asserting counts.
The records below support narrative counts only.

### Claim 1: the docs subcommand family has nine members

- Complete Family: every `Invoke-DocsCommand.ps1` subcommand defined by the epic and its children.
- Exhaustive Search Scope: `docs/features/epics/documentation-estate-tooling/epic.md` and
  `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md`.
- Inclusion Rules: a name registered or reserved in the dispatch table or listed as a subcommand
  with an owner.
- Exclusion Rules: `validate` modes and `update-ledger` operations (arguments, not subcommands);
  MCP tool names.
- Primary Search Strategy or Query Expression: read the epic `### Naming contract` bullet
  "Subcommands and owners".
- Primary Member Set: init, validate-profile, check, inventory, coverage, update-ledger, validate,
  generate-reference, surface-delta.
- Primary Count: 9.
- Cross-check Search Strategy or Query Expression: read the 1020 spec `#### Dispatch table` rows
  and owner anchor comments.
- Cross-check Member Set: init, validate-profile (rows); check; inventory; coverage, update-ledger,
  validate; generate-reference; surface-delta (anchors).
- Cross-check Count: 9.
- Member-set Comparison: identical after normalization. Assertion supported for narrative use.

### Claim 2: the docs MCP tool family has six members

- Complete Family: every docs MCP tool.
- Exhaustive Search Scope: `docs/features/` (all files).
- Inclusion Rules: a `snake_case` tool name of the docs MCP surface.
- Exclusion Rules: existing non-docs MCP tools.
- Primary Search Strategy or Query Expression: epic `### Naming contract` bullet "MCP tools
  (900007)".
- Primary Member Set: run_docs_check, run_docs_inventory, run_docs_coverage, update_docs_ledger,
  generate_docs_reference, validate_docs_artifacts.
- Primary Count: 6.
- Cross-check Search Strategy or Query Expression: content search for the six names across
  `docs/features/` excluding the naming-contract line.
- Cross-check Member Set: validate_docs_artifacts, update_docs_ledger, run_docs_coverage (1023
  spec and research), generate_docs_reference (1024 spec, issue and user story).
- Cross-check Count: 4.
- Member-set Comparison: disagree (`run_docs_check` and `run_docs_inventory` appear only in the
  naming contract). The numeric assertion is withheld; the documentation contract test derives the
  tool set from the merged 900007 source at execution.

## Testing Implications

- Suites (Pester 5, `tests/scripts/claude-lib/docs/`): the end-to-end suite; the template DAG and
  schema suite; a documentation contract suite for the five onboarding pages. Support modules hold
  fixture text (joined with explicit line feeds), the stateful in-memory context (if the 1020
  builder does not keep writes visible), and the manifest parser.
- Each suite removes imported `Docs*` and `DiscoveryEncoding` modules in `AfterAll`.
- Assertions name codes, `related_ids`, `related_paths`, exit codes and receipt fields; message
  assertions use containment of the declaration and page path only.
- Positive controls prove each new check can fail (DAG mutations; documentation contract over an
  in-memory page missing one subcommand).
- Coverage: no new production file; the end-to-end suite adds coverage to `.claude/lib/docs/`
  files and must not lower any changed-line figure. Per-file coverage is read from
  `artifacts/pester/powershell-coverage.xml`.
- Isolation runs per the brief `## Test Isolation Checks`: at least three seeded shuffled
  file-order runs of the touched suites in one process (seed and order recorded) and a fresh
  single-process run over `tests/scripts`, recorded under `<FEATURE>/evidence/regression-testing/`.

## Artifact Classification

Rule references: R1 = language rule clause (1) (pushed-down helpers, hooks, libs are PowerShell
or bash); R2 = clause (2) (TypeScript only for MCP and extension commands; none here); D = epic
`### Artifact classes for this epic` (data, test and documentation rows).

| File | Class | Language | Permitting rule |
|---|---|---|---|
| `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` (create) | schema/config/data (template manifest) | Markdown with YAML frontmatter | D |
| `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/README.md` (create) | documentation | Markdown | D |
| `docs/engineering/documentation-estate/README.md`, `architecture.md`, `consumer-onboarding.md`, `command-reference.md`, `workflow.md` (create) | documentation | Markdown | D |
| `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` (create) | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1` (create; name is a recommendation) | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` (create; name is a recommendation) | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/*.TestSupport.psm1` for this child (create, one or more) | test (support module) | PowerShell | D |
| `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/**` (spec, user story, plan, evidence) | documentation | Markdown | D |

No pushed-down helper, hook, skill, agent, MCP tool, extension command, Python or TypeScript file is
created or edited. Every artifact follows the language rule.

## Owner Questions

- **OQ-A - Template delivery to a consumer.** The template ships inside the extension and MCP
  server package but no command selects it, so a consumer cannot obtain it without copying it by
  hand. Options: (a) documented manual copy (no code; provisional default for this child);
  (b) an `init` template row under a new 900010 anchor in `Get-DocsInitTemplate` (a 1020 contract
  change, PowerShell, R1); (c) an extension command or tool argument selecting an epic variant
  (TypeScript under R2, plus an in-place edit of the existing Python twin). Each language choice is
  permitted; the question is scope and contract ownership.
- **OQ-B - Wording of the `/epic-plan` criterion.** No executable `/epic-plan` parser exists; a
  live run needs an agent delegation and cannot run in CI. Provisional default: verify by schema
  conformance and the DAG suite, and reword the criterion accordingly.

No artifact of this child conflicts with the language rule.

## Contracts This Child Introduces

No child depends on 900010. Contracts recorded for later work:

- Template path `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/`
  holding `epic.md` and `README.md`, with slug `documentation-estate`, integration branch
  `epic/documentation-estate-integration`, and `9000NN` placeholder issue numbers.
- The template frontmatter stays within the YAML subset the DAG suite parses; a later edit that
  leaves it fails closed.
- Onboarding page set `docs/engineering/documentation-estate/{README,architecture,consumer-onboarding,command-reference,workflow}.md`;
  a later child that adds a subcommand or MCP tool must add its example to `command-reference.md`,
  because the documentation contract derives the expected set from the dispatch table and tool
  definitions.

## Automation Feasibility

All work is automatable with no human interaction expected: the template and pages are authored
files; every check is a Pester suite runnable through `Invoke-PoshQCTest` and in
`poshqc / PowerShell QC`; isolation runs are scripted. Two prerequisites are outside this child's
control: every dependency must be merged into the integration branch before execution, and OQ-A
and OQ-B must be answered or left on their provisional defaults. Facts this researcher could not
verify without `git` or `gh` (the merged upstream symbols) are bound by the plan's Phase 0.

## Pre-Mortem

- Review checklists: a reviewer can find documented argument spellings that differ from the merged
  code, or an acceptance criterion claiming `/epic-plan` acceptance with no executable proof.
  Mitigation: Phase 0 records merged symbols before any page is written; the documentation contract
  suite derives names from the dispatch table and tool definitions; the `/epic-plan` criterion is
  reworded to schema conformance (OQ-B).
- Coverage: no new production file, so no per-file floor applies to this child; the risk is a
  changed-line regression report if an upstream file changes during rebase. Mitigation: record a
  baseline from `artifacts/pester/powershell-coverage.xml` on the integration branch before the
  first change and compare after.
- Mirror parity: not applicable; no file under `claude-customizations/` or
  `codex-and-agents-customizations/` is created, no pack manifest changes, no
  `docs/features/templates/` twin is required, and no execution-environment brief fact changes.
- File size: the end-to-end suite can exceed the 500-line guidance with fixture text. Mitigation:
  fixture text, the stateful context and the manifest parser live in support modules; each file is
  measured with a physical line count before review.
- Test isolation: dot-sourcing the entry script leaks `Docs*` modules and script-scope state into
  later suites in shard and single-process runs. Mitigation: `AfterAll` removes every imported
  module; three seeded shuffled file-order runs and one fresh single-process run over
  `tests/scripts` are recorded.
- CI-only behavior: a `windows-latest` runner may provide a Python interpreter, which would switch
  the analyzer to `native` and change `analysis_method`; `Test-Json` behavior depends on the
  runner's PowerShell release. Mitigation: pin the scanner through the 1031 detection seam and
  assert codes and fields, not `Test-Json` wording; the suites run only in
  `poshqc / PowerShell QC` shards, never in the Linux hook job.
- Evidence: Phase 0 symbol records, baseline and post-change coverage, isolation runs and the
  forbidden-token scan must exist under `<FEATURE>/evidence/<kind>/` with `Timestamp`, `Command`,
  `EXIT_CODE` and `Output Summary`, stamped at write time; PoshQC MCP results carry no output, so
  counts come from the JUnit and coverage files.
