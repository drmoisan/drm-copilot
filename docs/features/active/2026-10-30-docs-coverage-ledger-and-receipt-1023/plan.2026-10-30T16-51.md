# docs-coverage-ledger-and-receipt - Plan

- **Issue:** #1023
- **Parent (optional):** #1019 (epic documentation-estate-tooling, wave 1, band C4)
- **Depends on:** #1020 (docs-profile-and-artifact-schemas, including its D3/D5 amendment; planned, not executed in this tree)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.3 (PowerShell design; new planning cycle under owner decision D1; replaces the withdrawn Python plan in place)
- **Work Mode:** full-feature (AC sources: `spec.md` `## Acceptance Criteria`, 33 items S1-S33, and `user-story.md` `## Acceptance Criteria`, 23 items U1-U23, numbered in document order)
- **Design source:** `research/2026-10-30T22-40-docs-coverage-ledger-and-receipt-powershell-addendum.md`; where it differs from `spec.md` version 0.3 (precision limits as marked ledger entries, `DOCS_CLI_RUNTIME` for commit conflicts, owner questions OQ-1 to OQ-5), `spec.md` governs.

## Required References

- Policy order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, and the `.github/` sources they mirror.
- Requirements: `spec.md`, `user-story.md`, the design source above, the epic `docs/features/epics/documentation-estate-tooling/epic.md` sections `## Owner Directive: Implementation Language (2026-10-30, refined)` (with `### Artifact classes for this epic`), `## Owner Decisions (2026-10-30, received through the coordinator)`, `### Amendment of 1020 required by D3 and D5`, the heading beginning `### PowerShell contracts from the re-preparation of 1020`, and `### 1023 - docs-coverage-ledger-and-receipt (wave 1, C4)`; the 1020 `spec.md` section `## Decisions Later Children Must Honor`; and the 1020 amendment research `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/research/2026-10-30T22-35-docs-profile-amendment-d3-d5-addendum-research.md` (branch `feature/docs-profile-and-artifact-schemas-1020`).
- Environment: tool routes, launchers, command-text restrictions, the batch budget, hook context, CI shape, and the PoshQC MCP limits are owned by the `execution-environment` skill and are not restated here.
- The requirement originates in one consumer repository; no identifier of that repository appears in any file this plan creates or edits.

## Execution Context

- Precondition (dependency): 1020 with its D3/D5 amendment is merged into `epic/documentation-estate-tooling-integration`, and the orchestrator has merged that branch into `feature/docs-coverage-ledger-and-receipt-1023` before [P0-T1]. In this tree `.claude/lib/docs/` does not exist; [P0-T1] proves the merged surface and stops the run otherwise. This plan never creates or edits a 1020 file other than the three dispatch rows of [P4-T2] and their bundle copy.
- Route: the feature writes eight production modules, eight bundle copies, and two entry-script copies, above the direct-mode cap in the `execution-environment` skill section `## Batch Budget`. Execution runs in the item worktree under a non-terminal exempt-route checkpoint as that section describes, never in an isolated executor worktree.
- Terms: `FEATURE` is `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023`; `LIB` is `.claude/lib/docs`; `BUNDLE` is `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs`; `TESTS` is `tests/scripts/claude-lib/docs`; `MERGE_BASE` is the merge base of `origin/epic/documentation-estate-tooling-integration` and `HEAD`, which anchors every scope diff.
- `SCRATCH` is `<session scratchpad>/issue-1023/`; every scratch script and report lives under it with a name starting `issue-1023-`. Evidence records the literal token `SCRATCH`, never a host path. Evidence files are `<name>.<timestamp>.md` with the UTC write time; a consumer selects the lexicographically greatest match.
- Pester route: branch-current runs per the `execution-environment` section `## PowerShell Route and PoshQC MCP Limits`. Counts come from `artifacts/pester/pester-junit.xml` and per-file line coverage from the LINE counter of each file in `artifacts/pester/powershell-coverage.xml`, never from a PoshQC MCP summary.
- Suite acceptance (used by every Pester task): the branch-current run of the named suites reports `failures="0"` and `errors="0"` in `artifacts/pester/pester-junit.xml` with a non-zero test count, and the named evidence file under `FEATURE/evidence/regression-testing/` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the passed and failed counts. CI proof: the suites run with coverage on `windows-latest` in `poshqc / PowerShell QC shard 1`, `shard 2`, and `shard 3`, aggregated by the required check `poshqc / PowerShell QC`; no criterion cites `ubuntu-latest`.
- Module rules (every new module): the help sentence carries the token `imports its siblings with -ErrorAction Stop`; `Set-StrictMode -Version Latest` then `$ErrorActionPreference = 'Stop'`; sibling imports only as literal `Join-Path -Path $PSScriptRoot -ChildPath '<literal>'` with `-ErrorAction Stop`; context members are passed to `[scriptblock]` parameters and invoked as `& $WriteText`, never `& $Context.<Member>`; `New-` functions carry the `PSUseShouldProcessForStateChangingFunctions` suppression with the justification of `New-EpicScopeResult` in `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`; identifier and path comparisons are ordinal and case-sensitive and every sort uses `[System.StringComparer]::Ordinal`; scores use integer arithmetic; `Merge-` and `Get-...Without...` functions return new structures and never mutate inputs; JSON is parsed only with `ConvertFrom-DocsJsonText`.
- Test rules (every new suite): in-memory contexts only, no temporary file, no token forbidden by `.claude/hooks/check-powershell-test-purity.ps1`, assertions on codes, pointers, severities and identifiers rather than `Test-Json` message text, forward-slash relative paths, and an `AfterAll` that removes every `Docs*` module.
- Plan validation: the installed `mcp__drm-copilot__validate_orchestration_artifacts` tool (`artifact_type: plan`) or the branch-current CLI `scripts/dev_tools/validate_orchestration_artifacts.py` `plan` subcommand, per the `execution-environment` section `## MCP Surfaces Run the Installed Extension`.

## Design Notes (planner refinements recorded for review)

- Command suites form a family to stay under the file-size tiers: `TESTS/DocsLedgerCommands.Tests.ps1` (arguments, input loading, dispatch rows, `coverage`), `TESTS/DocsLedgerCommands.UpdateLedger.Tests.ps1`, and `TESTS/DocsLedgerCommands.Validate.Tests.ps1`. Where an AC names `DocsLedgerCommands.Tests.ps1`, it denotes this family; the traceability table names the file.
- `TESTS/DocsLedger.TestSupport.psm1` builds on the 1020 `TESTS/Docs.TestSupport.psm1` exports recorded by [P0-T1]. It adds `New-DocsLedgerTestContext` (ordinal path-to-bytes map; records every `ReadBytes`, `TestFile`, `ListFile`, and `WriteText` call in order; `WriteText` stores the text so a later read returns it; optional injected `ReadBytes` and `WriteText` failures; `UtcNow` of `Kind` `Utc`, overridable), fixture builders for the profile, snapshot, ledger, matrix, and pin collection, `Get-DocsLedgerTestSchemaSet` (composes the committed runtime schema copies through `Read-DocsSchemaSet` and `Get-DocsComposedSchemaSet`), `$script:DocsPropertySeed` with the seeds 11, 1023, and 65537, and `Get-DocsLedgerTestShuffle -Item -Seed` (seeded `[System.Random]` Fisher-Yates). Every property `It` iterates those seeds and states `seed=<n>` in each `-Because`.
- Property tests live in `TESTS/<Module>.Properties.Tests.ps1`; the receipt identity property lives in `TESTS/DocsReceipt.Tests.ps1` because S10 names that suite. `## Pure Function Property Map` lists all 48 pure functions.
- `Get-DocsArtifactPin` returns `$null` for `-Bytes $null` (absent artifact) and `New-DocsValidationReceipt` sorts the non-null pins, so S11's absent-artifact case is provable in `DocsReceipt.Tests.ps1`.
- `Invoke-DocsArtifactWrite` reports a throwing `WriteText` as a failed plan (status unchanged, message kept) and stops; the commands map both a `conflict` and a write failure to exit 3 with one `DOCS_CLI_RUNTIME` finding whose message names the path and status and whose `related_paths` holds that path and every path already written.
- Each command function formats `Context.UtcNow` with `ConvertTo-DocsTimestampText` after argument validation and before any read, so a non-UTC clock is exit 3 in all three subcommands. The injected write-failure case of S22 applies to `update-ledger -Write` and `validate -WriteReceipt`; `coverage` receives no write scriptblock, which [P4-T3] and [P5-T1] prove.
- Finding codes owned by 1023 for the staleness and completion gate: `DOCS_STALE_PAGE` (`Get-DocsStalenessFinding`) and `DOCS_BOUND_PAGE_MISSING` (`Get-DocsCompletionGateFinding`). The page-check prefix that the epic section `### Page-check contracts from the PowerShell preparation of 1021 (binding)` reserves to 1021 is not used by any 1023 code; spec `## Contracts Later Children Must Honor` records the two names for 1038.
- Pre-approved splits are used only when a module would exceed 500 logical lines: rules of `DocsLedger.psm1` move to `LIB/DocsLedgerRules.psm1` and the coverage report of `DocsLedgerCommands.psm1` to `LIB/DocsCoverageReport.psm1`, each with its own suite, bundle copy, and `core.json` line; the evidence of the creating task records the split.

## Artifact Classification

Rules: R1 = epic language rule clause (1), pushed-down skills, helpers, hooks and libs are PowerShell or bash; D = epic `### Artifact classes for this epic` rows for schema/config/data, test, and documentation. "Avoid new Python" applies to every row; no row uses clause (2).

| File | Change | Class | Language | Permitting rule |
|---|---|---|---|---|
| `LIB/DocsLedger.psm1`, `LIB/DocsParity.psm1`, `LIB/DocsEvidencePins.psm1`, `LIB/DocsStaleness.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `LIB/DocsReceipt.psm1`, `LIB/DocsValidation.psm1`, `LIB/DocsLedgerMutation.psm1`, `LIB/DocsLedgerCommands.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `LIB/Invoke-DocsCommand.ps1` | edit (three rows under the 1023 anchor) | pushed-down helper/lib (entry) | PowerShell | R1 |
| `LIB/DocsLedgerRules.psm1`, `LIB/DocsCoverageReport.psm1` | create only if a split is needed | pushed-down helper/lib | PowerShell | R1 |
| `BUNDLE/` copies of every file in the rows above | create or edit (byte-identical) | pushed-down helper/lib (mirror) | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | edit (one `paths` entry per new `LIB` file) | schema/config/data | JSON | D |
| `TESTS/DocsLedger.TestSupport.psm1`, `TESTS/DocsLedger.TestSupport.Tests.ps1` | create | test | PowerShell (Pester) | D |
| `TESTS/<Module>.Tests.ps1` and `TESTS/<Module>.Properties.Tests.ps1` for the eight modules, the two `DocsLedgerCommands.*.Tests.ps1` siblings, `TESTS/DocsWriteBoundary.Tests.ps1`, `TESTS/DocsCompleteIntegration.Tests.ps1` | create | test | PowerShell (Pester) | D |
| `TESTS/Invoke-DocsCommand.Tests.ps1` (1020) | edit only under the condition in `## Existing Tests Affected` | test | PowerShell (Pester) | D |
| `FEATURE/**` (plan, evidence, AC check-off in `spec.md` and `user-story.md`) | create / edit | documentation | Markdown | D |

No hook, skill, agent, MCP tool, extension command, schema, example, Python, or TypeScript file is created or edited, and `quality-tiers.yml`, `config/poshqc-coverage.json`, and `config/poshqc-scan.json` are unchanged. Every artifact follows the language rule; no language owner question arises.

## Existing Tests Affected

[P0-T3] re-runs this search after the merge; a hit outside this table that asserts an exact dispatch-row set, an exact `core.json` path set, or an exact `LIB` file set stops the run.

| Test | Behavior it asserts | Task | Disposition |
|---|---|---|---|
| `TESTS/Invoke-DocsCommand.Tests.ps1` (1020) | `Test-DocsCommandTable` has no finding for the committed table; anchor order read from the script text; `-Help` lists the table rows | [P4-T2] | Unchanged when [P0-T1] records no exact row-count, row-set, or help-text assertion; otherwise updated in [P4-T2], test file only, to expect the three 1023 rows in addition to the rows present at `MERGE_BASE`, because the 1023 rows are added by design under the 1023 anchor |
| `TESTS/Docs.Manifest.Tests.ps1` (1020) | every `LIB` file is listed once in `core.json` and SHA-256 identical in `BUNDLE` | [P6-T2] | Unchanged; gains eight cases that pass once [P6-T1] and [P6-T2] land |
| `TESTS/DocsNeutrality.Tests.ps1` (1020) | no configured consumer identifier digest in any `LIB` file | [P6-T2] | Unchanged; gains one case per new file |
| `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` | every `.psm1` under `.claude/lib` states `$script:ConventionToken` and the strict-mode pair | [P6-T2] | Unchanged; gains eight modules |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (`It 'reports no Python invocation beyond the allowlist across the guarded tree'`, `It 'ships an empty allowlist'`) | no dynamic invocation under `.claude/lib`; empty allowlist | [P6-T2] | Unchanged; the module rules keep the new files finding-free |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` | every distributable `.claude` file is bundled with equal text | [P7-T7] | Unchanged; satisfied by [P6-T1] |
| `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py::test_claude_manifest_powershell_dependency_closure`, `::test_every_psscriptroot_occurrence_is_recognized`, `::test_scanned_source_floor` | every `$PSScriptRoot` dependency of a manifested file is manifested | [P7-T7] | Unchanged; literal joins and [P6-T2] satisfy it |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest` | bundled agents, hooks, and skills are manifested | [P7-T7] | Unchanged; it does not enumerate `lib` |
| `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` (`it("lists every bundled .claude agent, skill, and hook file in some pack manifest")`) | walks the bundled `lib` tree recursively; every file is manifested | [P7-T8] | Unchanged; satisfied by [P6-T2] |
| `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | no file above 800 lines outside the baseline | [P7-T9] | Unchanged |

## Owner Questions (unresolved inputs; this plan decides none)

- OQ-1 (ownership of `Test-DocsPathOrGlobMatch` and `Get-DocsPageOwner`): [P2-T3] proceeds on the default, 1023 owns both in `DocsParity.psm1`.
- OQ-2 (`docs.precision-limit` marker in `extensions`): [P1-T2], [P1-T3], and [P4-T4] proceed on the default, the marker is used as the spec states.
- OQ-3 (`FINDINGS_LIMIT` severity): [P3-T1], [P3-T3], [P4-T3], [P4-T5], and [P4-T6] proceed on the default: exit codes and `validation_result` come from the unbounded set, receipt `findings` use `Get-DocsOrderedFinding -Limit` with the finding count, and fixtures that assert envelope validity stay under 100 findings; the exit-0 envelope case above 100 findings remains the known defect R2.
- OQ-4 (committed receipt versus head revision): [P3-T1] proceeds on the neutral contract, `Get-DocsReceiptGateDecision` compares with the supplied `-HeadRevision`.
- OQ-5 (receipt counts for precision limits): [P3-T1] and [P4-T3] proceed on the default, receipt `counts` exclude precision-limit entries and `by_analysis_method` appears only in the `coverage` result.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Precondition, Policy Reads, and Baseline Capture

- [ ] [P0-T1] Precondition: verify, read-only, that the merged 1020 surface is present. Checks: `git merge-base --is-ancestor origin/epic/documentation-estate-tooling-integration HEAD` exits 0; `LIB` and `BUNDLE` each hold `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSchema.psm1`, `DocsSurface.psm1`, `DocsAnalyzerRegistry.psm1`, `DocsProfile.psm1`, `DocsProfileCommands.psm1`, and `Invoke-DocsCommand.ps1`; `schemas/docs/v1/` and `LIB/schemas/v1/` hold `common`, the six artifact schemas, and `docs-command-envelope.schema.json`; the snapshot `$defs/element` and ledger `$defs/entry` list `analysis_method` in `required` and snapshot `analyzers[]` items carry it; docs common defines `analysis-method` and `extensions`; `Get-DocsSchemaName` includes `docs-command-envelope`; each consumed function in spec `### Modules (.claude/lib/docs/)` ("Consumed 1020 functions") plus `Get-DocsCommandTable`, `Test-DocsCommandTable`, `ConvertFrom-DocsCommandArgument`, `New-DocsCommandContext`, `Write-DocsFileText`, `Invoke-DocsCommandCli`, `ConvertTo-DocsEnvelopeText`, `ConvertTo-DocsReportText`, and `New-DocsDiagnostic` is defined; the anchor `# --- 1023: coverage, update-ledger, validate ---` occurs once in each entry-script copy with no row beneath it; `TESTS` holds `Docs.TestSupport.psm1`, `Invoke-DocsCommand.Tests.ps1`, `Docs.Manifest.Tests.ps1`, and `DocsNeutrality.Tests.ps1`.
  - Facts recorded for later tasks: the exports of `Docs.TestSupport.psm1`; how 1020 command functions obtain the composed schema set; whether `Write-DocsFileText` mode `create` fails on an existing file (R3); the `ConvertFrom-DocsCommandArgument` value for repeated `multi` tokens; the `FINDINGS_LIMIT` severity and bound; the row-count, row-set, and help-text assertions of `Invoke-DocsCommand.Tests.ps1`; and the envelope schema constraint on `command`.
  - Acceptance: `FEATURE/evidence/baseline/phase0-1020-precondition.<timestamp>.md` records `Timestamp:`, one row per check marked `PRESENT`, `MISSING`, or `RENAMED`, and the recorded facts. Every row `PRESENT` and an envelope `command` constraint that admits `coverage`, `update-ledger`, and `validate` are required to continue; otherwise the run stops as `BLOCKED at [P0-T1]`, no later task starts, and the gap is reported to the orchestrator as a 1020 dependency defect.
- [ ] [P0-T2] Read in order `CLAUDE.md`, `.github/copilot-instructions.md`, `.claude/rules/general-code-change.md`, `.github/instructions/general-code-change.instructions.md`, `.claude/rules/general-unit-test.md`, `.github/instructions/general-unit-test.instructions.md`, `.claude/rules/powershell.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/quality-tiers.md`, then `spec.md`, `user-story.md`, the design source, the epic and 1020 sections in `## Required References`, and `.claude/skills/execution-environment/SKILL.md`.
  - Acceptance: `FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md` records `Timestamp:`, `Policy Order:`, and the list of files read.
- [ ] [P0-T3] Search the test trees `tests/` and `extensions/drm-copilot/test/` (tracked and untracked files) for the tokens `Invoke-DocsCommand`, `Get-DocsCommandTable`, `lib/docs`, `core.json`, and `DocsLedger`, and assign each hit a disposition from `## Existing Tests Affected` or "unchanged" with the reason that it asserts no behavior this plan changes.
  - Acceptance: `FEATURE/evidence/baseline/existing-test-dispositions.<timestamp>.md` lists every hit with its disposition. A hit that asserts an exact dispatch-row set, an exact `core.json` path set, or an exact `LIB` file set and is absent from `## Existing Tests Affected` stops the run as `BLOCKED at [P0-T3]` for a planner revision.
- [ ] [P0-T4] Capture the formatting baseline, check-only: a script `SCRATCH/issue-1023-format-check.ps1` compares `Invoke-Formatter` output (settings `scripts/powershell/PoshQC/settings/pssa.settings.psd1`) with the text of every `.ps1` and `.psm1` under `LIB` and `TESTS` and writes nothing to the tree.
  - Acceptance: `FEATURE/evidence/baseline/baseline-format.<timestamp>.md` records the four fields with the checked-file count and the differing-file count; `git status --porcelain` output is identical before and after the run. A non-zero count is recorded as pre-existing and not repaired here.
- [ ] [P0-T5] Capture the analyzer baseline with a direct `Invoke-ScriptAnalyzer` run over `LIB` and `TESTS` (recursive) with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
  - Acceptance: `FEATURE/evidence/baseline/baseline-pssa.<timestamp>.md` records the four fields and the finding count by rule name.
- [ ] [P0-T6] Capture the Pester and coverage baseline with a branch-current `Invoke-PoshQCTest` run over the default scan folders (the CI shape).
  - Acceptance: `FEATURE/evidence/baseline/baseline-pester-coverage.<timestamp>.md` records the four fields, the passed, failed, and skipped counts from the JUnit file, the names of any failing tests (pre-existing), the line coverage of each 1020 file under `LIB` and the total from the coverage file as numbers, and states that the eight 1023 modules are absent (new-code baseline: not present).
- [ ] [P0-T7] Capture the push-down contract baseline: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -q`, then `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`.
  - Acceptance: `FEATURE/evidence/baseline/baseline-push-down-contracts.<timestamp>.md` and `FEATURE/evidence/baseline/baseline-codex-generator-check.<timestamp>.md` each record the four fields; the first carries the passed and failed counts and the names of any failing tests.
- [ ] [P0-T8] Capture the Jest manifest-completeness baseline: run `test/lib/push-down/claude-pack-manifest-completeness.test.ts` through the `node run-jest.cjs` route in `extensions/drm-copilot/`.
  - Acceptance: `FEATURE/evidence/baseline/baseline-jest-pack-completeness.<timestamp>.md` records the four fields and the passed and failed counts.

### Phase 1 — Test Support and the Ledger Module

- [ ] [P1-T1] Create `TESTS/DocsLedger.TestSupport.psm1` per `## Design Notes` and `TESTS/DocsLedger.TestSupport.Tests.ps1`. The fixture snapshot holds one element of each of the six kinds built with 1020 `New-DocsSurfaceElement` (mixed-case declarations, both `analysis_method` values), one scanner and one native analyzer, and one precision-limit diagnostic built with `New-DocsDiagnostic` and then given the `docs.precision-limit` marker in its `extensions` member (the 1020 constructor `New-DocsDiagnostic -Code -Path -Message -AnalyzerId [-Blocking]` takes no extensions argument); the fixture profile sets `artifact_paths`, `documentation_roots`, `page_owners`, and `completion_gates.docs_complete`.
  - Tests: `It 'records every context call in order'`, `It 'returns written text on a later ReadBytes'`, `It 'raises the injected read and write failures'`, `It 'fixture snapshot produces no finding from Test-DocsArtifactText'`, `It 'fixture profile loads without an error finding'`, `It 'shuffle is a permutation and deterministic per seed'`.
  - Acceptance (suite form): `DocsLedger.TestSupport.Tests.ps1`; evidence `p1-test-support`.
- [ ] [P1-T2] Create `LIB/DocsLedger.psm1` with `ConvertTo-DocsSnapshotView`, `Test-DocsPrecisionLimitDiagnostic`, `Get-DocsPrecisionLimitElementId`, `New-DocsLedgerEntry`, `New-DocsPrecisionLimitEntry`, and `New-DocsLedgerDocument` (imports `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSurface.psm1`), plus `TESTS/DocsLedger.Tests.ps1` and the six properties of `## Pure Function Property Map` in `TESTS/DocsLedger.Properties.Tests.ps1`.
  - Behavior: spec `### Function contracts (summary)` and `### Scanner precision limits (D3)`.
  - Tests: `It 'rebuilds every element keyed by element_id'`, `It 'reports DOCS_SNAPSHOT_ELEMENT_INVALID at the element pointer for a tampered element id'`, `It 'reports DOCS_SNAPSHOT_LIMIT_INVALID for an unknown marker element_kind'`, `It 'reports DOCS_SNAPSHOT_LIMIT_INVALID for a marked diagnostic with null path'`, `It 'reports DOCS_SNAPSHOT_LIMIT_INVALID for a marked diagnostic from a native analyzer'`, `It 'reports DOCS_SNAPSHOT_LIMIT_INVALID when the precision-limit id equals an element id'`, `It 'ignores diagnostics without the marker'`, `It 'derives the precision-limit id with Get-DocsElementId over kind, path and diagnostic id'`, `It 'copies element_id, kind and analysis_method and sorts bindings with a null anchor first'`, `It 'builds a deferred scanner precision-limit entry with the marker'`, `It 'builds an empty ledger whose id depends on the repository id'`; every built entry and document produces no finding from `Test-DocsArtifactText -ArtifactKind 'docs-coverage-ledger'`.
  - Acceptance (suite form): `DocsLedger.Tests.ps1`, `DocsLedger.Properties.Tests.ps1`; evidence `p1-ledger-core`.
- [ ] [P1-T3] Add `Get-DocsLedgerEntryCompanionFinding` and `Get-DocsLedgerFinding` to `LIB/DocsLedger.psm1` (or `LIB/DocsLedgerRules.psm1` under the split rule), with tests in `TESTS/DocsLedger.Tests.ps1` and their properties.
  - Behavior: the ledger rows of spec `### Finding codes`, emitted through `Get-DocsOrderedFinding`.
  - Tests: `It 'reports DOCS_LEDGER_MISSING_DISPOSITION naming kind, declaration and element id'` (also asserts `related_ids` and `related_paths`), `It 'reports DOCS_LEDGER_RATIONALE_REQUIRED for excluded without rationale'`, `It 'reports DOCS_LEDGER_OWNER_REQUIRED and DOCS_LEDGER_TARGET_REQUIRED for deferred without owner or target'`, `It 'reports DOCS_LEDGER_BINDING_REQUIRED for documented without binding'`, `It 'reports DOCS_LEDGER_DUPLICATE_ENTRY'`, `It 'reports DOCS_LEDGER_ORPHAN_ENTRY for an unmarked unknown id'`, `It 'reports DOCS_LEDGER_KIND_MISMATCH'`, `It 'reports DOCS_LEDGER_SNAPSHOT_REF as a warning'`, `It 'reports DOCS_LEDGER_ANALYSIS_METHOD_CHANGED as a warning'`, `It 'reports DOCS_LEDGER_LIMIT_UNRECORDED naming analyzer, code, path, diagnostic id and element id'`, `It 'reports DOCS_LEDGER_LIMIT_MISMATCH for a non-deferred, non-scanner, unmarked or differing limit entry'`, `It 'reports DOCS_LEDGER_LIMIT_RESOLVED as a warning'`.
  - Acceptance (suite form): `DocsLedger.Tests.ps1`, `DocsLedger.Properties.Tests.ps1`; evidence `p1-ledger-rules`.
- [ ] [P1-T4] Add `Merge-DocsLedgerEntry`, `Get-DocsLedgerWithoutEntry`, and `Merge-DocsLedgerSnapshotRef` to `LIB/DocsLedger.psm1`, with tests in `TESTS/DocsLedger.Tests.ps1` and their properties.
  - Tests: `It 'replaces or inserts by element_id and sorts entries'`, `It 'leaves the input ledger unchanged'` (canonical JSON before and after), `It 'removes only the named entry including a precision-limit entry'`, `It 'sync sets snapshot_ref and refreshes analysis_method of element entries only'`.
  - Acceptance (suite form): `DocsLedger.Tests.ps1`, `DocsLedger.Properties.Tests.ps1`; evidence `p1-ledger-operations`.

### Phase 2 — Evidence Pins, Staleness, and Parity

- [ ] [P2-T1] Create `LIB/DocsEvidencePins.psm1` with `Get-DocsPinId`, `New-DocsEvidencePin`, `New-DocsPinCollectionDocument`, `Get-DocsPinFinding`, `Merge-DocsEvidencePin`, and `Get-DocsPinSetWithoutPin`, plus `TESTS/DocsEvidencePins.Tests.ps1` and `TESTS/DocsEvidencePins.Properties.Tests.ps1`.
  - Tests: `It 'derives pin_id with Get-DocsStableId over element_id, page_path and symbol'`, `It 'copies source_sha256 as an opaque value and allows a null revision'`, `It 'reports DOCS_PIN_INCONSISTENT for a tampered identity'`, `It 'reports DOCS_PIN_INCONSISTENT for a wrong pin_id'`, `It 'reports DOCS_PIN_INCONSISTENT for a duplicate pin_id'`, `It 'replaces a pin with the same pin_id'`, `It 'removes the pins of one element and page'`; built pins and collections produce no finding from `Test-DocsArtifactText -ArtifactKind 'docs-evidence-pin'`.
  - Acceptance (suite form): both suites; evidence `p2-evidence-pins`.
- [ ] [P2-T2] Create `LIB/DocsStaleness.psm1` with `Get-DocsPinStatus`, `Get-DocsStalePage`, and `Get-DocsStalenessFinding` (imports `DocsFinding.psm1`, `DocsEvidencePins.psm1`), plus `TESTS/DocsStaleness.Tests.ps1` and `TESTS/DocsStaleness.Properties.Tests.ps1`.
  - Tests: `It 'returns digest-changed when digests differ'`, `It 'returns element-missing when no current element has the id'`, `It 'returns current for equal digests'`, `It 'ignores a revision difference'`, `It 'lists a page exactly when one of its pins is not current'`, `It 'names page path, declaration, element id and status in DOCS_STALE_PAGE'`.
  - Acceptance (suite form): both suites; evidence `p2-staleness`.
- [ ] [P2-T3] Create `LIB/DocsParity.psm1` with `Get-DocsParityDimension`, `Test-DocsPathOrGlobMatch`, `Get-DocsPageOwner`, `New-DocsParityRow`, `New-DocsParityMatrixDocument`, `Get-DocsScoreBasisPoint`, and `Measure-DocsParityScore`, plus `TESTS/DocsParity.Tests.ps1` and `TESTS/DocsParity.Properties.Tests.ps1` (OQ-1 default).
  - Behavior: the glob is translated to an anchored .NET regular expression without `IgnoreCase`; `-like` and `[WildcardPattern]` are not used.
  - Tests: `It 'matches the enumerated path_or_glob table'` (exact, prefix plus slash, star across slash, question mark, class, negated class, letter-case difference not matching), `It 'returns the first matching page owner'`, `It 'creates a row with every dimension not-assessed'`, `It 'computes the integer basis-point floor and null for a zero denominator'`, `It 'counts per dimension summing to the row count'`; rows and documents produce no finding from `Test-DocsArtifactText -ArtifactKind 'docs-parity-matrix'`.
  - Acceptance (suite form): both suites; evidence `p2-parity-core`.
- [ ] [P2-T4] Add `Get-DocsMatrixFinding`, `Merge-DocsParityDimension`, `Get-DocsMatrixWithoutBinding`, `Merge-DocsMatrixPinRemoval`, and `Merge-DocsMatrixRef` to `LIB/DocsParity.psm1`, with tests in `TESTS/DocsParity.Tests.ps1` and their properties.
  - Tests: one `It` per code naming it (`DOCS_MATRIX_UNBOUND_ROW`, `DOCS_MATRIX_ROW_MISSING`, `DOCS_MATRIX_DUPLICATE_ROW`, `DOCS_MATRIX_PIN_UNKNOWN`, `DOCS_MATRIX_ACCURACY_UNPINNED`, `DOCS_MATRIX_EXISTS_INCONSISTENT`, `DOCS_MATRIX_OWNER_INCONSISTENT`, `DOCS_MATRIX_LEDGER_REF` as a warning), `It 'reports no finding for a consistent matrix'`, `It 'creates an absent row and derives sorted evidence_pin_ids'`, `It 'removes rows of one element and page'`, `It 'removes one pin id from every row'`, `It 'sets snapshot_ref and ledger_ref'`.
  - Acceptance (suite form): both suites; evidence `p2-parity-matrix`.

### Phase 3 — Receipt, Write Boundary Module, and Validation Modes

- [ ] [P3-T1] Create `LIB/DocsReceipt.psm1` with `ConvertTo-DocsTimestampText`, `Get-DocsWriterVersion`, `Get-DocsArtifactPin`, `Get-DocsReceiptId`, `Measure-DocsReceiptCount`, `New-DocsValidationReceipt`, and `Get-DocsReceiptGateDecision` (imports `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSchema.psm1`, `DocsSurface.psm1`), plus `TESTS/DocsReceipt.Tests.ps1` and `TESTS/DocsReceipt.Properties.Tests.ps1` (OQ-4 and OQ-5 defaults).
  - Tests: `It 'formats the invariant UTC timestamp and throws for a non-Utc Kind'`, `It 'returns writer version 1.0.0'`, `It 'pins raw bytes with Get-DocsBytesSha256Hex and pins nothing for absent bytes'`, `It 'sorts inputs by artifact_kind then path'`, the receipt identity property of the map, `It 'counts zeros where the mode reads no input and excludes precision-limit entries'`, `It 'builds pass and fail receipts that produce no finding from Test-DocsArtifactText'`, `It 'returns receipt-invalid for unparsable or schema-invalid text'`, `It 'returns mode-not-docs-complete'`, `It 'returns result-fail'`, `It 'returns revision-mismatch including a letter-case-only difference'`, `It 'allows a passing docs-complete receipt pinned to the revision'`.
  - Acceptance (suite form): both suites; evidence `p3-receipt`.
- [ ] [P3-T2] Create `LIB/DocsLedgerMutation.psm1` with `Get-DocsArtifactWritePlan` and `Invoke-DocsArtifactWrite` (imports `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSurface.psm1`; no 1023 module), plus `TESTS/DocsLedgerMutation.Tests.ps1` and `TESTS/DocsLedgerMutation.Properties.Tests.ps1`.
  - Behavior: spec `### Function contracts (summary)` and `## Design Notes`; the only 1023 function that invokes a write scriptblock.
  - Tests: `It 'marks unchanged text skipped and changed text planned'`, `It 'dry run invokes none of ReadBytes, TestFile and WriteText'`, `It 'creates an absent document only after TestFile returns false'`, `It 'reports conflict when a document expected absent exists'`, `It 'overwrites only when the re-read digest equals BeforeSha256'`, `It 'reports conflict on a digest mismatch, stops, and lists written paths'`, `It 'stops on a throwing WriteText and reports the failed path'`, `It 'writes in ordinal path order and never writes skipped plans'`.
  - Acceptance (suite form): both suites; evidence `p3-mutation`.
- [ ] [P3-T3] Create `LIB/DocsValidation.psm1` with `Get-DocsValidationMode`, `Get-DocsValidationInputKind`, and `Invoke-DocsValidation` for the `profile` and `ledger` modes (signature of design source section 4.6), plus `TESTS/DocsValidation.Tests.ps1` and the two mode properties in `TESTS/DocsValidation.Properties.Tests.ps1`.
  - Tests: `It 'profile mode returns ConvertFrom-DocsProfileText findings'`, `It 'returns a null receipt when the profile does not load'`, `It 'reports DOCS_INPUT_UNREADABLE for an absent snapshot or ledger'`, `It 'reports schema findings for a schema-invalid ledger'`, `It 'reports DOCS_REVISION_MISMATCH for a differing non-null snapshot revision'`, `It 'fails validation_result on an error beyond the finding bound'`, `It 'raises the receipt defect guard for a receipt that fails its schema'`, `It 'returns a schema-valid receipt pinned to the revision in profile and ledger modes on pass and fail'`.
  - Acceptance (suite form): both suites; evidence `p3-validation-ledger`.
- [ ] [P3-T4] Add the `matrix` and `docs-complete` modes and `Get-DocsCompletionGateFinding` to `LIB/DocsValidation.psm1`, with tests in `TESTS/DocsValidation.Tests.ps1` and the remaining two properties.
  - Tests: `It 'matrix mode reports DOCS_STALE_PAGE as a warning'`, `It 'reports DOCS_SNAPSHOT_UNPINNED for a null snapshot revision in docs-complete'`, `It 'reports DOCS_PARITY_REQUIRED_DIMENSION for fail and not-assessed'`, `It 'reports DOCS_BOUND_PAGE_MISSING for a bound page outside the page-path set'`, `It 'makes DOCS_STALE_PAGE an error only above max_stale_pages'` (below, equal, above), `It 'passes deferred and precision-limit entries with allow_deferred true and reports DOCS_DEFERRED_NOT_ALLOWED with false'`, `It 'returns a schema-valid receipt pinned to the revision in matrix and docs-complete modes on pass and fail'`.
  - Acceptance (suite form): both suites; evidence `p3-validation-complete`.

### Phase 4 — Command Module and Dispatch Rows

- [ ] [P4-T1] Create `LIB/DocsLedgerCommands.psm1` with `Test-DocsUpdateLedgerArgument`, `Test-DocsValidateArgument`, and `Read-DocsLedgerInputSet`, plus `TESTS/DocsLedgerCommands.Tests.ps1` and `TESTS/DocsLedgerCommands.Properties.Tests.ps1` (two argument properties).
  - Tests: `It 'returns one DOCS_CLI_ARGUMENTS finding for an option outside the operation set'` (each operation), `It 'rejects Element with Limit and Limit with a non-deferred disposition'`, `It 'rejects a repeated Page value'`, `It 'rejects invalid Element, Limit, Revision, ActorId, Owner, Page and relative path values'`, `It 'rejects WriteReceipt outside docs-complete'`, `It 'returns null for valid arguments'`, `It 'returns null for an absent artifact and propagates other read failures'`, `It 'builds the ordinal page-path set from ListFile over documentation_roots'`.
  - Acceptance (suite form): both suites; evidence `p4-arguments`.
- [ ] [P4-T2] Insert the three rows of spec `### Dispatch rows (Invoke-DocsCommand.ps1)` directly under `# --- 1023: coverage, update-ledger, validate ---` in `LIB/Invoke-DocsCommand.ps1`; no other line changes. Add to `TESTS/DocsLedgerCommands.Tests.ps1`: `It 'Get-DocsCommandTable carries the coverage, update-ledger and validate rows bound to DocsLedgerCommands.psm1'` and `It 'Test-DocsCommandTable returns no finding for the committed table'`.
  - Existing tests: `TESTS/Invoke-DocsCommand.Tests.ps1` per `## Existing Tests Affected`, with the disposition [P0-T1] selected.
  - Acceptance (suite form): `DocsLedgerCommands.Tests.ps1`, `Invoke-DocsCommand.Tests.ps1`; evidence `p4-dispatch`; and `git diff --numstat MERGE_BASE -- .claude/lib/docs/Invoke-DocsCommand.ps1` reports 3 added and 0 deleted, recorded in the same evidence file.
- [ ] [P4-T3] Add `Invoke-DocsCoverageCommand`, `Get-DocsCoverageReport`, and `ConvertTo-DocsCoverageReportLine` to `LIB/DocsLedgerCommands.psm1` (or `LIB/DocsCoverageReport.psm1` under the split rule), with tests through `Invoke-DocsCommandCli` and a recording context in `TESTS/DocsLedgerCommands.Tests.ps1` and the two report properties (OQ-3 and OQ-5 defaults).
  - Tests: `It 'returns totals with by_analysis_method, undocumented, deferred, precision_limits, stale_pages and parity'`, `It 'marks an unrecorded precision limit recorded false'`, `It 'lists every element as undocumented and exits 0 without ledger, matrix or pins'`, `It 'makes zero WriteText calls'`, `It 'exits 1 with DOCS_INPUT_UNREADABLE and null result for an absent snapshot'`, `It 'exits 1 for a schema-invalid snapshot'`, `It 'exits 2 with one DOCS_CLI_ARGUMENTS before any read'` (unknown option, missing value, invalid relative path), `It 'exits 3 with one DOCS_CLI_RUNTIME for an injected read failure and a non-UTC clock'`, `It 'emits an envelope with no finding from Test-DocsArtifactText docs-command-envelope'`, `It 'produces byte-identical Json stdout for identical runs'`, `It 'prints finding lines and the summary line without Json'`.
  - Acceptance (suite form): `DocsLedgerCommands.Tests.ps1`, `DocsLedgerCommands.Properties.Tests.ps1`; evidence `p4-coverage`.
- [ ] [P4-T4] Add `Invoke-DocsUpdateLedgerCommand` with `set-disposition` (element and `-Limit`), `remove-entry`, the newly-introduced rule, dry-run planning, and created-document headers, with `TESTS/DocsLedgerCommands.UpdateLedger.Tests.ps1` (OQ-2 default).
  - Tests: `It 'plans the ledger write and makes no WriteText call without Write'`, `It 'records analysis_method from the current element'`, `It 'removes matrix rows and pins of a dropped binding'`, `It 'exits 1 naming the missing rationale for excluded and writes nothing'`, `It 'exits 1 naming the missing owner or target for deferred'`, `It 'exits 0 when only pre-existing errors for other elements exist and carries no error finding'`, `It 'set-disposition Limit writes the deferred scanner entry and clears DOCS_LEDGER_LIMIT_UNRECORDED'`, `It 'remove-entry removes the entry, rows and pins'`, `It 'exits 1 with DOCS_UPDATE_TARGET_INVALID for an absent element or limit'`, `It 'creates a document with the 1020 header and a repository-derived id'`.
  - Acceptance (suite form): `DocsLedgerCommands.UpdateLedger.Tests.ps1`; evidence `p4-update-ledger-dispositions`.
- [ ] [P4-T5] Add `pin`, `unpin`, `set-dimension`, `sync-refs`, and the `-Write` commit path through `Invoke-DocsArtifactWrite` to `Invoke-DocsUpdateLedgerCommand`, with tests in `TESTS/DocsLedgerCommands.UpdateLedger.Tests.ps1`.
  - Tests: `It 're-pins the same element and page under the same pin_id and clears staleness'`, `It 'unpin removes the pin and its id from every row'`, `It 'set-dimension creates the row and derives evidence_pin_ids'`, `It 'sync-refs refreshes analysis_method and sets both refs'`, `It 'rejects pin, unpin and set-dimension on a precision-limit id'`, `It 'writes only through Invoke-DocsArtifactWrite with Write'`, `It 'exits 3 with one DOCS_CLI_RUNTIME naming the path on a digest conflict'` (written paths in `related_paths`), `It 'exits 3 for an injected write failure, an injected read failure and a non-UTC clock'`, `It 'emits schema-valid byte-identical Json envelopes'`, `It 'prints the summary line without Json'`.
  - Acceptance (suite form): `DocsLedgerCommands.UpdateLedger.Tests.ps1`; evidence `p4-update-ledger-pins`.
- [ ] [P4-T6] Add `Invoke-DocsValidateCommand` to `LIB/DocsLedgerCommands.psm1`, with `TESTS/DocsLedgerCommands.Validate.Tests.ps1`.
  - Tests: `It 'makes zero WriteText calls without WriteReceipt in every mode'`, `It 'writes only the receipt at validation_receipt on pass and on fail with WriteReceipt'` (the written text, parsed with `ConvertFrom-DocsJsonText`, carries `id`, `mode`, `repository`, `revision`, and `validation_result` equal to those of the receipt in `result`; these are the fields the 1034 hook reads), `It 'pins the receipt revision to the Revision argument'`, `It 'exits 2 for WriteReceipt with any other mode'`, `It 'reports DOCS_LEDGER_LIMIT_UNRECORDED in ledger mode'`, `It 'exits 1 with DOCS_SNAPSHOT_UNPINNED for a null snapshot revision in docs-complete'`, `It 'exits 1 with null result when the profile does not load'`, `It 'exits 2 for a missing Mode, an invalid Revision and an unknown option before any read'`, `It 'exits 3 for an injected read failure, a receipt write failure and a non-UTC clock'`, `It 'emits schema-valid byte-identical Json envelopes'`, `It 'prints the summary line without Json'`.
  - Acceptance (suite form): `DocsLedgerCommands.Validate.Tests.ps1`; evidence `p4-validate`.

### Phase 5 — Write-Boundary Proof and Integration

- [ ] [P5-T1] Create `TESTS/DocsWriteBoundary.Tests.ps1` with a pure helper `Find-DocsWritePrimitive -SourceText -Path` over the PowerShell parser AST, applied to every `.ps1` and `.psm1` under `LIB` read once into memory.
  - Tests: `It 'finds no filesystem write primitive outside Write-DocsFileText'` (the primitives and the allowlist reason "init create-only and explicit overwrite" of S21), `It 'invokes a WriteText scriptblock only inside Invoke-DocsArtifactWrite'`, `It 'accesses the WriteText member only in DocsLedgerCommands.psm1 among 1023 modules'`, `It 'references Invoke-DocsArtifactWrite only from DocsLedgerCommands.psm1'`, `It 'reports a write call in an in-memory source string'` (positive control).
  - Acceptance (suite form): `DocsWriteBoundary.Tests.ps1`; evidence `p5-write-boundary`.
- [ ] [P5-T2] Create `TESTS/DocsCompleteIntegration.Tests.ps1` over one recording in-memory context: profile with `allow_deferred` false and `max_stale_pages` 0, snapshot pinned to a full revision, one element without an entry, one pin whose digest differs; commands run through `Invoke-DocsCommandCli`.
  - Tests: `It 'exits 0 with a pass receipt on the complete fixture'`, `It 'exits 1 with a fail receipt naming the undocumented element and the stale page'` (declaration, element id, page path), `It 'exits 0 with a pass receipt after set-disposition Write and pin Write'`.
  - Acceptance (suite form): `DocsCompleteIntegration.Tests.ps1`; evidence `p5-integration`.

### Phase 6 — Push-Down Registration

- [ ] [P6-T1] Create the bundle copies with one copy script `SCRATCH/issue-1023-mirror.sh`: each new `LIB` module (and any split module) to `BUNDLE`, and `LIB/Invoke-DocsCommand.ps1` over its `BUNDLE` copy.
  - Acceptance: `git status --porcelain --untracked-files=all -- extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs` lists exactly the new module copies and the modified entry script; each copy's SHA-256 equals its source; `FEATURE/evidence/other/bundle-mirror.<timestamp>.md` records the listing and digests. Any later edit to a `LIB` file re-runs this script.
- [ ] [P6-T2] Append one `paths` entry per new `LIB` file to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, after the existing `.claude/lib/docs/` entries, each exactly once.
  - Acceptance (suite form): `TESTS/Docs.Manifest.Tests.ps1`, `TESTS/DocsNeutrality.Tests.ps1`, `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`; evidence `p6-registration`.

### Phase 7 — Final QA Loop, Scope Checks, and Self-Review

- [ ] [P7-T1] Run the check-only formatting comparison of [P0-T4] over every `.ps1` and `.psm1` this feature created or edited (`LIB`, `BUNDLE`, `TESTS`).
  - Acceptance: the differing-file count is 0 and `FEATURE/evidence/qa-gates/qa-format.<timestamp>.md` records the four fields. A non-zero count is repaired with `Invoke-PoshQCFormat` over those folders, [P6-T1] is re-run, and the loop restarts at [P7-T1]. CI: `poshqc / PowerShell QC static`.
- [ ] [P7-T2] Run `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `LIB` and the 1023 files under `TESTS`.
  - Acceptance: the finding count is 0 and `FEATURE/evidence/qa-gates/qa-pssa.<timestamp>.md` records the four fields; any finding is fixed and the loop restarts at [P7-T1]. CI: `poshqc / PowerShell QC static`.
- [ ] [P7-T3] Run the branch-current `Invoke-PoshQCTest` over the default scan folders with coverage (the CI shape and the fresh single-process run over `tests/scripts`).
  - Acceptance: the JUnit file reports `failures="0"` and `errors="0"`, or only failures [P0-T6] recorded as pre-existing; `FEATURE/evidence/qa-gates/qa-pester-coverage.<timestamp>.md` records the four fields, the counts, and the line coverage of every new `LIB` file and of `LIB/Invoke-DocsCommand.ps1` as numbers. CI: `poshqc / PowerShell QC` (`windows-latest`).
- [ ] [P7-T4] Compare coverage: baseline [P0-T6] against [P7-T3].
  - Acceptance: `FEATURE/evidence/qa-gates/coverage-delta.<timestamp>.md` records the 1020 per-file baseline and post-change figures, the total before and after, and for each new `LIB` file a line coverage of at least 85; `LIB/Invoke-DocsCommand.ps1` is not below its baseline and its three new rows are covered. A figure below its floor is remediation-required, not PASS. Pester measures no branch coverage, so no branch gate applies.
- [ ] [P7-T5] Run the touched Pester suites (every suite under `TESTS`) in one process in seeded shuffled file order, three runs with the seeds 101, 202, and 303.
  - Acceptance: each run reports 0 failures in its JUnit file; `FEATURE/evidence/regression-testing/isolation-shuffled-pester.<timestamp>.md` records each seed, its file order, and its counts. An order dependence is fixed on both sides and every seed re-run.
- [ ] [P7-T6] Check test purity over the 1023 files under `TESTS`: search them for `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `env:TEMP`, `env:TMP`, `Start-Process`, and `Start-Sleep`, and confirm each suite holds an `AfterAll` block that removes the `Docs*` modules.
  - Acceptance: the search prints no line and exits 1; `FEATURE/evidence/qa-gates/qa-test-purity.<timestamp>.md` records the four fields with `ExpectedExitCode: 1`, the file count, and the suites lacking `AfterAll` (none).
- [ ] [P7-T7] Re-run the push-down contract command and the Codex generator check of [P0-T7].
  - Acceptance: both exit 0 with 0 failed tests, or only failures [P0-T7] recorded as pre-existing; `FEATURE/evidence/qa-gates/qa-push-down-contracts.<timestamp>.md` and `FEATURE/evidence/qa-gates/qa-codex-generator-check.<timestamp>.md` record the four fields. CI: `quality-checks7 / Code Quality & Tests (3.10)` through `(3.13)`.
- [ ] [P7-T8] Re-run the Jest manifest-completeness suite of [P0-T8].
  - Acceptance: 0 failed; `FEATURE/evidence/qa-gates/qa-jest-pack-completeness.<timestamp>.md` records the four fields. CI: `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)` and `(ubuntu-latest)`.
- [ ] [P7-T9] Count logical lines of every file this feature created or edited under `LIB`, `BUNDLE`, and `TESTS`, then run `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` alone through the Pester route.
  - Acceptance: no file exceeds 800 lines, each module above 500 lines carries a split or a recorded reason, and the suite reports 0 failures; `FEATURE/evidence/qa-gates/qa-file-size.<timestamp>.md` records the per-file counts and the suite result.
- [ ] [P7-T10] Verify scope with `git diff --name-status MERGE_BASE HEAD` and `git status --porcelain --untracked-files=all`.
  - Acceptance: every listed path is covered by `## Artifact Classification`; nothing under `schemas/`, `examples/`, `LIB/schemas/`, `.claude/lib/discovery-validation/`, `config/`, `packages/`, or `quality-tiers.yml` and no other 1020 module is listed; `git diff --numstat MERGE_BASE HEAD` reports 3 added and 0 deleted for each entry-script copy; `FEATURE/evidence/qa-gates/qa-scope.<timestamp>.md` records the `MERGE_BASE` derivation, both outputs, and the numstat rows.
- [ ] [P7-T11] Run the forbidden-token scan with `SCRATCH/issue-1023-forbidden-token-scan.sh`: it collects every created or changed path from `git diff --name-only MERGE_BASE HEAD` and `git status --porcelain --untracked-files=all` (status columns stripped, deleted paths dropped), adds every file under `FEATURE`, and runs `grep -n -i -E 'r[g]f|fore[c]ast'` over them.
  - Acceptance: grep prints no line and exits 1; `FEATURE/evidence/qa-gates/qa-forbidden-tokens.<timestamp>.md` records the four fields with `ExpectedExitCode: 1` and the scanned file count. A match is removed and the loop restarts at [P7-T1].
- [ ] [P7-T12] Check off each delivered criterion in `spec.md` and `user-story.md` `## Acceptance Criteria` per the `acceptance-criteria-tracking` skill section `## Check-Off Protocol`, one at a time after its mapped evidence passes; criteria that need the CI run follow `### CI-Dependent Criteria`.
  - Acceptance: every criterion in `## Acceptance Criteria Traceability` is `[x]` with unchanged text or recorded as CI-pending; `FEATURE/evidence/qa-gates/ac-status.<timestamp>.md` carries the `### Acceptance Criteria Status` summary with total, checked, and remaining counts.
- [ ] [P7-T13] Walk `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, and `feature-audit.yyyy-MM-ddTHH-mm.md` against the branch diff from `MERGE_BASE` and every criterion S1-S33 and U1-U23.
  - Acceptance: `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` has one PASS, FAIL, or N/A row per checklist item and per criterion; a FAIL row is fixed, the loop re-run from [P7-T1], and the self-review rewritten; the plan does not complete with a FAIL row.

## Pure Function Property Map

Each property `It` begins `property <function>:` and iterates `$script:DocsPropertySeed` or enumerates its domain exhaustively.

| Function | Task | Suite | Property |
|---|---|---|---|
| `ConvertTo-DocsSnapshotView` | P1-T2 | `DocsLedger.Properties` | element map and findings invariant under element and diagnostic permutation |
| `Test-DocsPrecisionLimitDiagnostic` | P1-T2 | `DocsLedger.Properties` | true exactly when all three marker rules hold (exhaustive) |
| `Get-DocsPrecisionLimitElementId` | P1-T2 | `DocsLedger.Properties` | equals `Get-DocsElementId` over kind, path and diagnostic id and passes `Test-DocsElementId` |
| `New-DocsLedgerEntry` | P1-T2 | `DocsLedger.Properties` | bindings ordinal-sorted; output invariant under binding permutation |
| `New-DocsPrecisionLimitEntry` | P1-T2 | `DocsLedger.Properties` | entry validates for seeded owners, targets and rationales |
| `New-DocsLedgerDocument` | P1-T2 | `DocsLedger.Properties` | id depends only on the repository id |
| `Get-DocsLedgerEntryCompanionFinding` | P1-T3 | `DocsLedger.Properties` | findings equal the companion table over every disposition and field-presence combination |
| `Get-DocsLedgerFinding` | P1-T3 | `DocsLedger.Properties` | missing-disposition findings name exactly the complement of every entry subset; `DOCS_LEDGER_LIMIT_UNRECORDED` names exactly the unrecorded limits of every limit subset; findings and canonical output invariant under entry permutation |
| `Merge-DocsLedgerEntry` | P1-T4 | `DocsLedger.Properties` | sorted, one entry per id, input unchanged |
| `Get-DocsLedgerWithoutEntry` | P1-T4 | `DocsLedger.Properties` | removes exactly the named id; inverse of a merge of a new id |
| `Merge-DocsLedgerSnapshotRef` | P1-T4 | `DocsLedger.Properties` | idempotent; element-entry `analysis_method` equals its element |
| `Get-DocsPinId` | P2-T1 | `DocsEvidencePins.Properties` | injective over seeded triples; stable across calls |
| `New-DocsEvidencePin` | P2-T1 | `DocsEvidencePins.Properties` | built pins yield no `DOCS_PIN_INCONSISTENT` |
| `New-DocsPinCollectionDocument` | P2-T1 | `DocsEvidencePins.Properties` | id depends only on the repository id |
| `Get-DocsPinFinding` | P2-T1 | `DocsEvidencePins.Properties` | findings and canonical output invariant under pin permutation |
| `Merge-DocsEvidencePin` | P2-T1 | `DocsEvidencePins.Properties` | re-pinning keeps one pin with the same `pin_id` |
| `Get-DocsPinSetWithoutPin` | P2-T1 | `DocsEvidencePins.Properties` | removes exactly the pins of the named element and page |
| `Get-DocsPinStatus` | P2-T2 | `DocsStaleness.Properties` | presence by digest by revision product yields the three statuses; revision never matters (exhaustive) |
| `Get-DocsStalePage` | P2-T2 | `DocsStaleness.Properties` | page listed exactly when a pin is not current; ordinal and permutation invariant |
| `Get-DocsStalenessFinding` | P2-T2 | `DocsStaleness.Properties` | one finding per stale page with the requested severity |
| `Get-DocsParityDimension` | P2-T3 | `DocsParity.Properties` | five dimensions in contract order on every call |
| `Test-DocsPathOrGlobMatch` | P2-T3 | `DocsParity.Properties` | agrees with the enumerated table; a letter-case change of a literal character never matches |
| `Get-DocsPageOwner` | P2-T3 | `DocsParity.Properties` | first match wins; appending non-matching entries keeps the owner |
| `New-DocsParityRow` | P2-T3 | `DocsParity.Properties` | every dimension `not-assessed`; row validates |
| `New-DocsParityMatrixDocument` | P2-T3 | `DocsParity.Properties` | id depends only on the repository id |
| `Get-DocsScoreBasisPoint` | P2-T3 | `DocsParity.Properties` | equals the integer floor formula or null for a zero denominator |
| `Measure-DocsParityScore` | P2-T3 | `DocsParity.Properties` | per-dimension counts sum to the row count |
| `Get-DocsMatrixFinding` | P2-T4 | `DocsParity.Properties` | findings and canonical output invariant under row permutation |
| `Merge-DocsParityDimension` | P2-T4 | `DocsParity.Properties` | changes only the named dimension; sorted `evidence_pin_ids` |
| `Get-DocsMatrixWithoutBinding` | P2-T4 | `DocsParity.Properties` | removes exactly the rows of the named element and page |
| `Merge-DocsMatrixPinRemoval` | P2-T4 | `DocsParity.Properties` | no row references the removed pin; other ids keep their order |
| `Merge-DocsMatrixRef` | P2-T4 | `DocsParity.Properties` | idempotent; both refs equal the supplied pins |
| `ConvertTo-DocsTimestampText` | P3-T1 | `DocsReceipt.Properties` | seeded UTC instants round-trip at second precision; every non-Utc Kind throws |
| `Get-DocsWriterVersion` | P3-T1 | `DocsReceipt.Properties` | constant across calls |
| `Get-DocsArtifactPin` | P3-T1 | `DocsReceipt.Properties` | `sha256` equals `Get-DocsBytesSha256Hex` of seeded byte arrays |
| `Get-DocsReceiptId` | P3-T1 | `DocsReceipt.Tests` | unchanged when only `issued_at`, `counts` or `findings` differ; changed when any identity member differs |
| `Measure-DocsReceiptCount` | P3-T1 | `DocsReceipt.Properties` | `by_disposition` sums to entries matching current elements; precision-limit entries excluded |
| `New-DocsValidationReceipt` | P3-T1 | `DocsReceipt.Properties` | receipt validates and inputs are sorted for seeded pins |
| `Get-DocsReceiptGateDecision` | P3-T1 | `DocsReceipt.Properties` | reason follows the fixed precedence over all combinations of the four failure conditions (exhaustive) |
| `Get-DocsArtifactWritePlan` | P3-T2 | `DocsLedgerMutation.Properties` | ordinal-sorted by path; `skipped` exactly when the digest is unchanged |
| `Get-DocsValidationMode` | P3-T3 | `DocsValidation.Properties` | four modes in layering order |
| `Get-DocsValidationInputKind` | P3-T3 | `DocsValidation.Properties` | each mode needs a superset of the previous mode's inputs |
| `Get-DocsCompletionGateFinding` | P3-T4 | `DocsValidation.Properties` | `DOCS_STALE_PAGE` is an error exactly when the stale count exceeds `max_stale_pages` |
| `Invoke-DocsValidation` | P3-T4 | `DocsValidation.Properties` | finding codes of each mode include those of the previous mode; every receipt validates |
| `Test-DocsUpdateLedgerArgument` | P4-T1 | `DocsLedgerCommands.Properties` | one finding exactly when an option is outside the operation set (every operation and option) |
| `Test-DocsValidateArgument` | P4-T1 | `DocsLedgerCommands.Properties` | accepts exactly the four modes with a full revision; `WriteReceipt` only with `docs-complete` |
| `Get-DocsCoverageReport` | P4-T3 | `DocsLedgerCommands.Properties` | undocumented, deferred, excluded and documented partition the current elements |
| `ConvertTo-DocsCoverageReportLine` | P4-T3 | `DocsLedgerCommands.Properties` | one line per listed item plus the fixed lines for seeded reports |

## Acceptance Criteria Traceability

Suites are under `TESTS`; evidence names are under `FEATURE/evidence/regression-testing/` unless a kind is shown.

| AC | Tasks | Proving tests | Evidence |
|---|---|---|---|
| S1, U13 | P1-T3 | `DocsLedger.Tests.ps1` missing-disposition, rationale, owner and target cases | `p1-ledger-rules` |
| S2 | P1-T3 | `DocsLedger.Tests.ps1` duplicate, orphan, kind, snapshot-ref, analysis-method cases | `p1-ledger-rules` |
| S3, U6 | P4-T4, P4-T5 | `DocsLedgerCommands.UpdateLedger.Tests.ps1` analysis_method and sync-refs cases | `p4-update-ledger-dispositions`, `p4-update-ledger-pins` |
| S4, U10 | P1-T3, P4-T4, P4-T6 | `DocsLedger.Tests.ps1` limit-unrecorded case; UpdateLedger `set-disposition Limit` case; Validate ledger-mode case | `p1-ledger-rules`, `p4-update-ledger-dispositions`, `p4-validate` |
| S5 | P1-T2, P1-T3 | `DocsLedger.Tests.ps1` limit-invalid, mismatch, resolved cases | `p1-ledger-core`, `p1-ledger-rules` |
| S6, U11 | P3-T4 | `DocsValidation.Tests.ps1` allow_deferred case | `p3-validation-complete` |
| S7, U3 | P2-T2 | `DocsStaleness.Tests.ps1`, `DocsStaleness.Properties.Tests.ps1` | `p2-staleness` |
| S8, U12 | P5-T2 | `DocsCompleteIntegration.Tests.ps1` | `p5-integration` |
| S9 | P3-T3, P3-T4 | `DocsValidation.Tests.ps1` schema-valid receipt cases | `p3-validation-ledger`, `p3-validation-complete` |
| S10, U17 | P3-T1, P3-T3 | `DocsReceipt.Tests.ps1` identity property and receipt cases; `DocsValidation.Tests.ps1` receipt cases | `p3-receipt`, `p3-validation-ledger` |
| S11 | P3-T1 | `DocsReceipt.Tests.ps1` pin and sort cases | `p3-receipt` |
| S12, U15 | P3-T3, P3-T4, P4-T6 | `DocsValidation.Tests.ps1` unpinned and mismatch cases; Validate unpinned case | `p3-validation-ledger`, `p3-validation-complete`, `p4-validate` |
| S13 | P3-T4 | `DocsValidation.Tests.ps1` gate cases | `p3-validation-complete` |
| S14 | P2-T1, P2-T4 | `DocsParity.Tests.ps1` matrix-code cases; `DocsEvidencePins.Tests.ps1` inconsistency cases | `p2-parity-matrix`, `p2-evidence-pins` |
| S15 | P2-T3 | `DocsParity.Tests.ps1` glob table and owner cases | `p2-parity-core` |
| S16 | P2-T3 | `DocsParity.Tests.ps1` score cases | `p2-parity-core` |
| S17 | P4-T1, P4-T4, P4-T5 | `DocsLedgerCommands.Tests.ps1` argument cases; UpdateLedger operation cases | `p4-arguments`, `p4-update-ledger-dispositions`, `p4-update-ledger-pins` |
| S18, U5 | P4-T4 | UpdateLedger newly-introduced-rule cases | `p4-update-ledger-dispositions` |
| S19, U4, U8 | P3-T2, P4-T4, P4-T5 | `DocsLedgerMutation.Tests.ps1`; UpdateLedger dry-run, write and conflict cases | `p3-mutation`, `p4-update-ledger-pins` |
| S20, U1, U18 | P4-T3, P4-T6 | `DocsLedgerCommands.Tests.ps1` zero-write case; Validate write cases | `p4-coverage`, `p4-validate` |
| S21, U9 | P5-T1 | `DocsWriteBoundary.Tests.ps1` | `p5-write-boundary` |
| S22, U16, U19 | P4-T1, P4-T3, P4-T5, P4-T6 | exit 0/1/2/3 cases in the three command suites | `p4-coverage`, `p4-update-ledger-pins`, `p4-validate` |
| S23 | P4-T3, P4-T5, P4-T6 | envelope schema and determinism cases in the three command suites | `p4-coverage`, `p4-update-ledger-pins`, `p4-validate` |
| S24 | P4-T3, P4-T5, P4-T6 | summary-line cases in the three command suites | `p4-coverage`, `p4-update-ledger-pins`, `p4-validate` |
| S25, U2 | P4-T3 | `DocsLedgerCommands.Tests.ps1` result and absent-ledger cases | `p4-coverage` |
| S26, U20 | P3-T1 | `DocsReceipt.Tests.ps1` gate-decision cases | `p3-receipt` |
| S27 | P4-T2 | `DocsLedgerCommands.Tests.ps1` dispatch-row cases | `p4-dispatch` |
| S28, U22 | P1-T2 through P4-T3, P7-T6 | `## Pure Function Property Map`; purity search | the module evidence files; `qa-gates/qa-test-purity` |
| S29, U21 | P6-T1, P6-T2, P7-T7, P7-T8 | `Docs.Manifest.Tests.ps1`; Python and Jest contract suites | `other/bundle-mirror`, `p6-registration`, `qa-gates/qa-push-down-contracts`, `qa-gates/qa-jest-pack-completeness` |
| S30 | P6-T2, P7-T2 | `ClaudeLibModuleConvention.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`; analyzer run | `p6-registration`, `qa-gates/qa-pssa` |
| S31 | P7-T5, P7-T6, P7-T3 | shuffled runs; purity search; single-process run | `isolation-shuffled-pester`, `qa-gates/qa-test-purity`, `qa-gates/qa-pester-coverage` |
| S32, U23 | P7-T3, P7-T4 | per-file coverage | `qa-gates/qa-pester-coverage`, `qa-gates/coverage-delta` |
| S33 | P7-T9 | `FileSizePolicy.RepoGate.Tests.ps1` | `qa-gates/qa-file-size` |
| U7 | P4-T5 | UpdateLedger re-pin case | `p4-update-ledger-pins` |
| U14 | P4-T6 | Validate WriteReceipt cases | `p4-validate` |

## Pre-Mortem

- Review checklists: a reviewer can flag `& $Context.<Member>` in a module, a `New-` function without the suppression, a culture-sensitive sort or comparison, a finding that does not name its element or page, or a production file excluded from coverage. Prevented by the module rules in `## Execution Context`, the naming assertions in [P1-T3], [P2-T2], and [P5-T2], the no-dynamic-invocation suite in [P6-T2], the analyzer gate in [P7-T2], and the template walk in [P7-T13].
- Coverage: `DocsLedgerCommands.psm1` and the failure branches of `Invoke-DocsArtifactWrite` could fall below 85% line coverage. Prevented by driving every exit code and write status through the recording context with injected read, write, and clock failures ([P3-T2], [P4-T3] through [P4-T6]) and by per-file figures from the coverage file in [P7-T4]; no file is excluded and no branch gate applies to Pester.
- Mirror parity: every new `LIB` file and the edited entry script are copied byte-identically in [P6-T1] and manifested in [P6-T2], proven by `Docs.Manifest.Tests.ps1`, the Python contract suites in [P7-T7], and the Jest completeness suite in [P7-T8]. No fact in the execution-environment brief changes (no CI job, required context, tool route, or batch-budget rule), so no brief-update task is needed.
- File size: `DocsLedgerCommands.psm1`, `DocsValidation.psm1`, and `DocsLedger.psm1` and the command suites are the largest candidates. Prevented by the three-file command suite family, the pre-approved splits in `## Design Notes`, and the per-file counts and repository gate in [P7-T9].
- Test isolation: dot-sourced entry functions, `-Force` imports, and the shared support module can leak state between suites. Prevented by in-memory contexts only, no module-scope state, `AfterAll` removal checked in [P7-T6], seeded shuffled file-order runs of the touched Pester suites with the seeds 101, 202, and 303 in [P7-T5], and the fresh single-process run over `tests/scripts` in [P7-T3]. The seeded shuffled Jest run is not applicable because no TypeScript file is created or changed ([P7-T8] runs an existing suite unchanged), and the reversed-order Python run is not applicable because no Python test module is created or changed.
- CI-only behavior: `Test-Json` behavior on the `windows-latest` PowerShell and shard-only module visibility appear only in `poshqc / PowerShell QC`. Prevented by asserting codes and pointers rather than message text, reading no gitignored `artifacts/` state in any test, in-memory fixtures with forward-slash relative paths and no CRLF file, and the single-process run in [P7-T3].
- Evidence: every evidence path is under `FEATURE/evidence/<kind>/` with a write-time `<timestamp>`, records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records `SCRATCH` instead of a host path; counts come from the JUnit and coverage files, never from MCP summaries; [P7-T11] scans every changed file and the feature folder for the restricted tokens.

## Size Justification

The plan has 43 tasks, above the 40-task guideline, because the epic assigns this one child eight production modules, three subcommands, and 48 pure functions with normative exit-code, envelope, receipt, staleness, and write-boundary contracts, and S28 requires the plan itself to map each pure function to its property test. Splitting the item would separate the receipt and validation modes from the single write boundary and its only caller, which the downstream MCP and CI children consume as one contract.

## Test Plan

- Unit and property: the suites listed per task under `TESTS`, with `## Pure Function Property Map` as the property inventory.
- Integration: `DocsCompleteIntegration.Tests.ps1` ([P5-T2]); the 1020 suites `Invoke-DocsCommand.Tests.ps1`, `Docs.Manifest.Tests.ps1`, and `DocsNeutrality.Tests.ps1`; the push-down contract suites ([P7-T7], [P7-T8]).
- Coverage evidence: baseline `FEATURE/evidence/baseline/baseline-pester-coverage.<timestamp>.md`; post-change `FEATURE/evidence/qa-gates/qa-pester-coverage.<timestamp>.md`; comparison `FEATURE/evidence/qa-gates/coverage-delta.<timestamp>.md`.
