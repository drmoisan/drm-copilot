# 2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production - Plan

- **Issue:** #1016 (epic #1018, child 2: Phase 1 only)
- **Parent (optional):** epic #1018 (`docs/features/epics/shared-agent-harness-layer/epic.md`)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T17-11
- **Status:** Ready for preflight (revision 1 after preflight round 1)
- **Version:** 1.1
- **Work Mode:** full-feature (acceptance criteria from `spec.md` and `user-story.md`)
- **Branch:** `feature/dev-docs-root-resolver-phase1-1016`

## Required References

- Policy order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, then `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/powershell.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md` (canonical sources under `.github/instructions/`).
- Requirements (feature-folder relative): `issue.md`, `spec.md`, `user-story.md`, `research/research.2026-10-30T21-15.md`, `research/parallel-run-blast-radius-bugs-1001-1002-1003-1006.txt`.
- Environment facts (tool routes, PowerShell route, batch budget, CI shape, contract tests, isolation checks): the `execution-environment` skill. This plan does not restate them.

## Execution Preamble

- `<FEATURE>` is `docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016`. Evidence goes to `<FEATURE>/evidence/<kind>/<name>.<timestamp>.md` with the write-time UTC stamp.
- SCRATCH resolves to `<session scratchpad>/issue-1016/`; scratch file names start with `issue-1016-`. Evidence records the token `SCRATCH`, never a host path.
- Route: this child exceeds the per-session cap in every language (about 40 PowerShell, 28 Python and 25 TypeScript production files, plus bundle mirrors that also count). Execution uses the `large` route described in `## Batch Budget` of the `execution-environment` skill; the item worktree checkpoint selects it before Phase 1.
- Scope diffs anchor on the merge base of `origin/main` and `HEAD`.
- Invariant for every consumer task: with the default root `docs/features`, every user-facing message, error string, written path and exit status is byte-identical to today. Matchers accept the union of both known roots regardless of the configured value; writers use the resolved root through the area map.
- Command text: `.claude/hooks/enforce-promotion-mcp-only.ps1` denies any Bash command text that contains the promotion-script file name of P6-T11 (`PROMOTION_MCP_ONLY_BLOCKED`), including read-only commands. P0-T4 and P6-T11 inspect and compare the two copies with Read and Grep, or through a launcher script under `SCRATCH` whose command text names only the launcher; Pester runs of its suites use the branch-current `Invoke-PoshQCTest` route of the brief.
- Override recorded: `spec.md` names `evidence/coverage/` for coverage evidence. EVIDENCE_LOCATION_OVERRIDE_REJECTED: `<FEATURE>/evidence/coverage/` replaced with `<FEATURE>/evidence/qa-gates/`.

## Recorded Decisions (planner interpretations)

- D-P1. Python resolver and parser are added in place to `scripts/dev_tools/json_config.py` (delegation settles OQ-2). No new Python file under `scripts/`, no `pyproject.toml` entry.
- D-P2. `validate-required-artifact-output.ps1` `ConvertTo-ArtifactSpec` splits on `|` with `-split '\|', 3`, so the contracted pattern `^(?:docs/features|\.dev)/active/.+/spec\.md$` would be cut at its alternation. The parser changes to: token before the first `|`, description after the last `|`, pattern between (P6-T10). Existing three-part specs parse identically.
- D-P3 (supersedes the round-1 "param block only" reading). `scripts/dev-tools/new-potential-entry.ps1` and `extensions/drm-copilot/resources/templates/new-potential-entry.ps1` differ today in three regions: `Get-AuthorName` (only the `scripts/dev-tools` copy has the `-GetCommand` git-availability guard), the `$workspace` assignment (the `scripts/dev-tools` copy uses two parents of `$PSScriptRoot`, the bundled copy uses `(Get-Location).Path`), and trailing blank lines. Spec S-14 is not amended: P6-T11 makes the copies byte-identical. Unified content: `Get-AuthorName` keeps the guarded form; `$workspace` is two parents of `$PSScriptRoot` when the script directory's leaf is `dev-tools` and its parent's leaf is `scripts`, and `(Get-Location).Path` otherwise, so each copy resolves the workspace exactly as it does today; one trailing newline.
- D-P4. `RepoAutomationService.newPotentialEntry` appends `-DevelopmentDocsRoot <root>` only when the resolved root differs from the default, so `repo-automation-dispatch.test.ts` (exact argv) stays unchanged; a new test proves `.dev` is passed when configured and present.
- D-P5. The TypeScript resolver accepts a structural reader type (`exists`, `isDirectory`, `readTextFile`) that `FileSystem` satisfies, so seams such as `FolderFileSystem` adapt without a `vscode` or real-disk dependency. Probe order: `exists` on the routing file first (false gives R-1 without a read), then `readTextFile`; `isDirectory` only when the value is `.dev`. Existing suites whose `FileSystem` fakes throw `not used` from `exists` or `isDirectory` and whose unit under test now resolves the root (the `InMemoryFileSystem` fakes in `test/lib/new-potential-bug-entry.test.ts` and `test/lib/new-potential-bug-entry-service-call.test.ts`, and the fake in `test/lib/validate/evidence-locations.test.ts` when the P4-T4 hint resolves through that seam) have that fake method answer from the fake's own file map; their case assertions are unchanged.
- D-P6. The potential-to-issue status line uses `formatFeatureFolderName(issue, stripDateFirstPrefix(potential stem))`; when the formatter rejects the stem (N-5), it falls back to today's sanitized `featurePath` token under the resolved active area, so promotion never fails on the status line.
- D-P7. `.claude/lib/development-docs` is a new `.claude/lib/<name>` project, so `quality-tiers.yml` gains a T3 entry (rule R4 of `scripts/dev_tools/quality_tiers_contract.py`).
- D-P8. `.codex/hooks/hook-docs-only-diff.ps1` is the Codex twin of the Claude hook and receives the same `.dev/` change.
- D-P9. Existing date-first and issue-less folders keep their names; issue-less creation keeps today's slug (OQ-4).
- D-P10. `PotentialFileSystem` (`promotion-filesystem.ts`) has no directory probe. `promotePotential` resolves the root through a local adapter over its injected `fs` seam (`exists` serves both the existence and the directory probe, `readText` reads the routing file under `workspacePath`); `promotion-filesystem.ts` is unchanged.
- D-P11. The shared corpus fixture `valid-large-waives-feature-folder-dev-root.json` is added only after all three feature-folder-record validators accept `.dev` (P6-T13), because the three parity suites run every file in `tests/fixtures/orchestrator_state_issue_adoption/`. Until then each runtime proves `.dev` acceptance with an in-memory case.

## Conflict Re-Check Inventory

Files and anchors this plan edits that appear in research section 9. P0-T2 checks every row; P9-T1 re-checks the blast-radius rows.

| File | Anchor |
| --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `Test-FeatureDocumentationOrEvidencePath`, `Test-OrchestrationReady` |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `Test-FeatureDocumentationOrEvidencePath`, `Test-OrchestrationReady` |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | `$script:EpicScopeManifestPattern`, `Get-EpicCommandLegReadinessFailure` |
| `.claude/lib/blast-radius/BlastRadius.psm1` (and bundle copy) | `$script:FeatureFolderRoot`, `$script:FeatureFolderPrefix` |
| `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` (and bundle copy) | `$script:FeatureCorpusPrefix` |
| `.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1` (and bundle copy) | `Test-FeatureFolderGlob` |
| `scripts/dev_tools/compute_blast_radius.py` | `FEATURE_FOLDER_ROOT`, `FEATURE_FOLDER_PREFIX` |
| `scripts/dev_tools/_blast_radius_token_shapes.py` | `FEATURE_CORPUS_PREFIX` |
| `scripts/dev_tools/_blast_radius_write_intent.py` | `_FEATURE_FOLDER_PREFIX` |
| `.claude/agents/epic-orchestrator.md`, `parallel-orchestrator.md`, `parallel-planner.md` (and bundle copies) | frontmatter `tools:` entries naming `docs/features/epics/**` or `docs/features/parallel/**` |
| `.claude/settings.json` (and bundle copy) | `permissions.allow` entry `Edit(docs/**)` |
| execution-environment brief, six copies | heading `## CI Shape and Required Checks` |
| `extensions/drm-copilot/jest.config.cjs` | `coverageThreshold` |
| both `pack-manifests/core.json` | `paths` array |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | `PINNED_FROZEN_SURFACE_HASHES` |
| `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` | `UNMODIFIED_SURFACE_GUARDS` |
| read only: `scripts/dev_tools/generate_codex_agent_variants.py`, `config/poshqc-coverage.json`, `config/file-size-baseline.json`, `extensions/drm-copilot/package.json`, `extensions/drm-copilot/CHANGELOG.md` | `CORE_FAMILIES`; file presence |

## Implementation Plan (Atomic Tasks)

### Phase 0 — Execution Gate, Policy Reads and Baselines

- [ ] [P0-T1] Confirm the parallel run `bugs-1001-1002-1003-1006` has merged: fetch `origin`; for each of issues #1001, #1002, #1003 and #1006 record the merged pull request (number and merge commit from `gh`) and that the merge commit is an ancestor of `origin/main`; record that every such merge commit is also an ancestor of `HEAD`.
  - Acceptance: `<FEATURE>/evidence/baseline/merge-gate.<timestamp>.md` (Timestamp, Command, EXIT_CODE, Output Summary) lists four merged items. If any item is unmerged, record `STOP: PARALLEL_RUN_NOT_MERGED`; if merged but not in `HEAD`, record `STOP: BRANCH_SYNC_REQUIRED` for the orchestrator. Either STOP ends execution before P0-T2.
- [ ] [P0-T2] Re-check every row of `## Conflict Re-Check Inventory` at the merge base of `origin/main` and `HEAD`: file present at that ref and each anchor found in it by a fixed-string search at that ref.
  - Then re-run the production-consumer inventory search at the same merge base (the roots and patterns of P10-T1). Each file with a hit must be named in research `## 2. Inventory of production consumers`, named in a task of this plan, or covered by a P10-T1 Stay row.
  - Acceptance: `<FEATURE>/evidence/baseline/conflict-recheck.<timestamp>.md` holds one PASS/MOVED row per file and anchor, and one row per consumer file with hits (NAMED or NEW). Any MOVED row records the old and new location, and any NEW row records the file and pattern; either records `STOP: REPLAN_REQUIRED`, and no file is edited after a STOP.
- [ ] [P0-T3] Read the policy files in the order of `## Required References`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` carries `Timestamp:`, `Policy Order:` and the list of files read.
- [ ] [P0-T4] Record physical line counts (method from `execution-environment` `## Preflight Defect Classes the Validator Cannot See`) for every existing production file this plan edits that is at or above 500 lines, and record the regions in which the two `new-potential-entry.ps1` copies differ, compared with Read and Grep (command-text restriction in `## Execution Preamble`).
  - Acceptance: `<FEATURE>/evidence/baseline/file-size.<timestamp>.md` lists each file with its count and tier, and the three divergent regions named in D-P3 (or records any further region, which P6-T11 then also unifies).
- [ ] [P0-T5] Capture the Python static baseline: Black in check mode, Ruff, Pyright over `scripts/` and `tests/`.
  - Acceptance: `<FEATURE>/evidence/baseline/python-static.<timestamp>.md` with one Command/EXIT_CODE/Output Summary block per tool (finding counts).
- [ ] [P0-T6] Capture the Python test baseline with coverage for every module in `## Coverage Targets`, using dotted `--cov=` arguments (for example `--cov=scripts.dev_tools.json_config`), `--cov-branch`, `--cov-report=term-missing` and `--cov-report=json:SCRATCH/issue-1016-baseline-coverage.json`.
  - Acceptance: `<FEATURE>/evidence/baseline/python-tests.<timestamp>.md` records pass/fail counts and numeric line and branch percentages per module, branch figures read from the JSON report.
- [ ] [P0-T7] Capture the TypeScript static baseline in `extensions/drm-copilot/`: Prettier check mode, `npm run lint`, `npm run typecheck`.
  - Acceptance: `<FEATURE>/evidence/baseline/typescript-static.<timestamp>.md` with one block per tool.
- [ ] [P0-T8] Capture the Jest coverage baseline (`npm run test:coverage` in `extensions/drm-copilot/`).
  - Acceptance: `<FEATURE>/evidence/baseline/typescript-tests.<timestamp>.md` records suite and test counts and per-file line and branch percentages for every TypeScript file in `## Coverage Targets`, read from `extensions/drm-copilot/coverage/lcov.info` (the `test:coverage` script prints only `text-summary` totals).
- [ ] [P0-T9] Capture the PowerShell static baseline: PoshQC format check and a direct `Invoke-ScriptAnalyzer` run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`. `Invoke-PoshQCFormat` has no check mode, so the format check runs the branch-current `Invoke-PoshQCFormat` with a no-op `-WriteFile` script block (no file is rewritten) and reads its logged lines.
  - Acceptance: `<FEATURE>/evidence/baseline/powershell-static.<timestamp>.md` records the count of `Formatted:` lines from the format check and the analyzer finding count by severity.
- [ ] [P0-T10] Capture the Pester baseline through branch-current `Invoke-PoshQCTest` (route per the brief).
  - Acceptance: `<FEATURE>/evidence/baseline/powershell-tests.<timestamp>.md` records pass/fail counts from `artifacts/pester/pester-junit.xml` and per-file line coverage from `artifacts/pester/powershell-coverage.xml` for every PowerShell file in `## Coverage Targets`.

### Phase 1 — Configured Key, Resolvers and Parsers

- [ ] [P1-T1] Add the flat top-level entry `"development_docs_root": "docs/features"` to `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json` and `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` with byte-identical text.
  - Tests: `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` unchanged (byte parity only). Routing loaders (`load_routing_matrix`, `loadRoutingMatrix`) ignore unknown top-level keys; their suites are unchanged.
  - Acceptance: the parity test passes; three files hash equal.
- [ ] [P1-T2] Create `extensions/drm-copilot/src/lib/development-docs/root.ts` exporting `DEVELOPMENT_DOCS_ROOT_KEY`, `DEFAULT_DEVELOPMENT_DOCS_ROOT`, `KNOWN_DEVELOPMENT_DOCS_ROOTS`, `DevelopmentDocsRoot`, `DevelopmentDocsArea`, `resolveDevelopmentDocsRoot`, `developmentDocsPath`, `knownRootPrefixes` per `spec.md` `### TypeScript`, with R-1 to R-8 semantics and the area map (D-P5 reader type); errors name `config/orchestration-routing.json`, the key and the value. Add `"./src/lib/development-docs/root.ts"` to `coverageThreshold` in `extensions/drm-copilot/jest.config.cjs` with `lines: 85`, `branches: 75`.
  - Tests: new `extensions/drm-copilot/test/lib/development-docs/root.test.ts` with in-memory fakes: R-1 to R-8, every area under both roots, unknown area error, prefixes for every area.
  - Acceptance: suite passes; file coverage meets its threshold.
- [ ] [P1-T3] Create `extensions/drm-copilot/src/lib/development-docs/feature-folder-name.ts` exporting `FeatureFolderName`, `parseFeatureFolderName`, `formatFeatureFolderName`, `stripDateFirstPrefix` per `spec.md` `### Feature-folder name rules (D-18, D-19)`, reusing `NAME_PATTERN` from `src/lib/new-active-feature-folder/models.ts`; add its `coverageThreshold` entry.
  - Tests: new `extensions/drm-copilot/test/lib/development-docs/feature-folder-name.test.ts` asserting F-1 to F-6 and N-1 to N-5 by name.
  - Acceptance: suite passes; threshold met.
- [ ] [P1-T4] Add `extensions/drm-copilot/test/lib/development-docs/no-vscode-import.test.ts`, which reads each `.ts` file under `src/lib/development-docs/` through a repository-relative forward-slash path and fails on any `vscode` import or require.
  - Acceptance: test passes and fails when a `vscode` import is added locally (observation recorded in the P10-T6 artifact).
- [ ] [P1-T5] Extend `scripts/dev_tools/json_config.py` in place with `DEVELOPMENT_DOCS_ROOT_KEY`, `DEFAULT_DEVELOPMENT_DOCS_ROOT`, `KNOWN_DEVELOPMENT_DOCS_ROOTS`, `resolve_development_docs_root`, `development_docs_path`, `known_root_prefixes` per `spec.md` `### Python`, with injected `read_text` and `is_dir`; add a module docstring that describes the module as repository layout configuration (the module has no docstring today).
  - Tests: new `tests/scripts/dev_tools/test_json_config_development_docs.py` (injected readers only): R-1 to R-8, area map under both roots, unknown area error, prefixes. `tests/scripts/dev_tools/test_json_config.py` unchanged.
  - Acceptance: both modules pass.
- [ ] [P1-T6] Add `FeatureFolderName`, `parse_feature_folder_name`, `format_feature_folder_name`, `strip_date_first_prefix` to `scripts/dev_tools/json_config.py` with the same rules as P1-T3, holding its own copy of the `NAME_PATTERN` expression so `json_config` keeps importing nothing from `scripts.dev_tools`.
  - Tests: F-1 to F-6 and N-1 to N-5 in `tests/scripts/dev_tools/test_json_config_development_docs.py`.
  - Acceptance: tests pass; no new file under `scripts/` (`git status --porcelain -- scripts` lists no untracked path).
- [ ] [P1-T7] Create `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` following `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, with `Resolve-DevelopmentDocsRoot` (returns an object with `Succeeded`, `Root`, `Reason`; I/O only through `-ReadText` and `-TestDirectory`), `Get-DevelopmentDocsPath`, `Get-DevelopmentDocsKnownRootPrefix`, `Get-DevelopmentDocsKnownRootPattern` (regex-escaped union, both separators).
  - Tests: new `tests/scripts/claude-lib/development-docs/DevelopmentDocsRoot.Tests.ps1`: R-1 to R-8, area map, unknown area, pattern matches forward and back slash samples under both roots.
  - Acceptance: suite passes.
- [ ] [P1-T8] Add `ConvertFrom-FeatureFolderName` and `ConvertTo-FeatureFolderName` to the same module with the P1-T3 rules.
  - Tests: F-1 to F-6 and N-1 to N-5 in `DevelopmentDocsRoot.Tests.ps1`.
  - Acceptance: suite passes; module stays under 500 lines.

### Phase 2 — PowerShell Module Publication

- [ ] [P2-T1] Copy `DevelopmentDocsRoot.psm1` byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/development-docs/` and `extensions/drm-copilot/resources/lib/development-docs/`.
  - Acceptance: three files hash equal; `ClaudeLibModuleConvention.Tests.ps1` passes.
- [ ] [P2-T2] Add `.claude/lib/development-docs` with tier T3 and a rationale to `quality-tiers.yml` (D-P7).
  - Tests: `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` unchanged and passing.
  - Acceptance: the tier classification check passes.
- [ ] [P2-T3] Add `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` to the `paths` array of `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and `.codex/lib/development-docs/DevelopmentDocsRoot.psm1` to `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, keeping the Codex file in the shape `render_manifest` in `generate_codex_agent_variants.py` writes (two-space JSON, trailing newline) so the P7-T4 `--check` reports no drift.
  - Acceptance: `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py` pass.
- [ ] [P2-T4] Add `[".codex/lib/development-docs", "lib/development-docs"]` to `VIRTUAL_RESOURCE_DIRECTORIES` in `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts` and the equal tuple to `scripts/dev_tools/push_down_codex_and_agents_customizations.py`.
  - Tests: add a publication case to `extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts` (asserts `VIRTUAL_ROOT_FOLDERS` contains `.codex/lib/development-docs`); add a `shouldCopy` row for `lib/development-docs/DevelopmentDocsRoot.psm1` to `extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts`; `tests/scripts/dev_tools/test_push_down_codex_and_agents_virtual_paths.py` passes unchanged or gains the parallel case.
  - Acceptance: the three suites pass.

### Phase 3 — Folder Creation, Status Line and Parser Delegation

- [ ] [P3-T1] In `extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts` (`buildFolderSlug`, `findPotentialFile`) and `flow.ts` (`createActiveFolder`, promoted-record helper), route promoted, templates, epics and active paths through `developmentDocsPath` and name issue folders with `formatFeatureFolderName` (no issue: today's slug; epics: `<epics area>/<slug>`).
  - Tests updated (issue-supplied expectations only): `test/lib/new-active-feature-folder/io.test.ts` `describe("buildFolderSlug")` (`notes-240` becomes `0240-notes`), `flow.test.ts` (`notes-feature-240` becomes `0240-notes-feature`); issue-less and epic cases unchanged. New cases: issue 1016 with stem `2026-10-30-foo` gives `1016-foo`; issue 42 gives `0042-<feature>`; `.dev` configured and present writes under `.dev/active`, absent writes under `docs/features/active`.
  - Acceptance: both suites pass.
- [ ] [P3-T2] Update issue-supplied folder expectations in `test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts`, `test/extension.new-active-feature-folder.test.ts` and `test/extension.new-active-feature-folder-inprocess.test.ts` (search each for `-<digits>` folder names); record each test's disposition.
  - Acceptance: the three suites pass; dispositions listed in the P10-T13 self-review.
- [ ] [P3-T3] In `scripts/dev_tools/new_active_feature_folder_io.py` (`build_folder_slug`, `find_potential_file`) and `new_active_feature_folder_flow.py`, apply the P3-T1 routing and naming; argparse help keeps today's text under the default root.
  - Tests updated: `test_new_active_feature_folder.py` (`test_build_folder_slug_uses_potential_and_issue_number`, the `2025-12-23-json-quality-63` and `bug-case-77` expectations), `test_new_active_feature_folder_part2.py` (`refactor-test-88`, `auto-test-42`), `test_new_active_feature_folder_part4.py` (`2026-02-22-testing-missing-mock-injections-42`); parts 3 and 5 unchanged. New cases mirror P3-T1.
  - Acceptance: all five modules pass.
- [ ] [P3-T4] In `extensions/drm-copilot/src/lib/potential-to-issue/content.ts` `updateMetadataLines` and `promotion.ts`, build the status line per D-P6 under the resolved active area and the promoted directory through `developmentDocsPath(root, "potential/promoted")`, resolving the root per D-P10.
  - Tests updated: `test/lib/potential-to-issue/content.test.ts` and `promotion.test.ts` status-line expectations (`Feature_Title` cases) move to the D-P6 form under `docs/features/active/`; a new case asserts `Promoted -> docs/features/active/1016-foo/`. New `promotion.test.ts` cases with the in-memory routing file set to `.dev`: `.dev` present gives `destination` under `<workspace>/.dev/potential/promoted/` and a status line `Promoted -> .dev/active/1016-foo/`; `.dev` absent gives `destination` under `<workspace>/docs/features/potential/promoted/` and `Promoted -> docs/features/active/1016-foo/`.
  - Acceptance: suites pass, including `promotion.matrix.test.ts` and `promotion.move-verification.test.ts` unchanged.
- [ ] [P3-T5] Apply P3-T4 in `scripts/dev_tools/potential_to_issue_content.py` and `potential_to_issue.py`.
  - Tests updated: `test_potential_to_issue_content.py`, `test_potential_to_issue.py` status-line expectations; new `1016-foo` case.
  - Acceptance: both pass; TypeScript and Python status strings for the same input are equal.
- [ ] [P3-T6] Make `resolveNameFromFeatureFoldername` in `src/lib/resolve/file-prompt-variables.ts` delegate to `parseFeatureFolderName`.
  - Tests: `test/lib/resolve/file-prompt-variables.test.ts` existing cases unchanged; new issue-first case `1016-foo-bar` resolves `foo-bar`.
  - Acceptance: suite passes.
- [ ] [P3-T7] Make `_resolve_name_from_feature_foldername` in `scripts/dev_tools/resolve_execute_plan_prompt.py` and `resolve_file_prompt.py`, and the issue extraction behind `_TRAILING_ISSUE_IN_FEATURE_DIR_PATTERN` in `plan_progress_report.py`, delegate to `parse_feature_folder_name`; `--active-root` default comes from `development_docs_path`.
  - Tests: `test_resolve_execute_plan_prompt.py`, `test_resolve_file_prompt.py`, `test_plan_progress_report.py` existing cases unchanged; each gains an issue-first case.
  - Acceptance: three modules pass.

### Phase 4 — TypeScript Consumers

- [ ] [P4-T1] Replace `ACTIVE_FEATURE_DOCS_DIRECTORY` and `POTENTIAL_DOCS_DIRECTORY` in `src/extension-command-helpers.ts` with resolver calls, and route the potential and template joins in `src/lib/new-potential-bug-entry.ts`.
  - Tests: `test/extension-command-helpers.test.ts`, `test/lib/new-potential-bug-entry*.test.ts` existing cases unchanged (the `InMemoryFileSystem` fakes in `new-potential-bug-entry.test.ts` and `new-potential-bug-entry-service-call.test.ts` gain map-backed `exists` and `isDirectory` per D-P5); two new `createBugEntry` cases in `new-potential-bug-entry.test.ts` with the in-memory routing file set to `.dev`: `.dev` present writes under `<workspace>/.dev/potential/`; `.dev` absent writes under `<workspace>/docs/features/potential/`.
  - Acceptance: suites pass.
- [ ] [P4-T2] Make `RepoAutomationService.newPotentialEntry` in `src/repo-automation-service.ts` resolve the root through its injected `fileSystem` and pass `-DevelopmentDocsRoot` per D-P4.
  - Tests: `test/repo-automation-dispatch.test.ts`, `test/extension.workflow-commands.test.ts` (`newPotentialEntry passes the bundled script path and short-name args`) and `test/extension.integration.test.ts` (`newPotentialEntry succeeds in a workspace without docs/features/templates using bundled templates`) unchanged (default argv per D-P4); new `test/repo-automation-service.new-potential-entry-root.test.ts` asserts `.dev` is passed when configured and present.
  - Acceptance: the three existing suites and the new suite pass.
- [ ] [P4-T3] Route `src/lib/pr-context/feature-docs.ts`, `render-feature-excerpts.ts`, `verification-evidence.ts` (writers through resolver), `summary-helpers.ts` `isScopingDoc` (union) and `collector-core.ts` docs bucket (add `.dev/`).
  - Tests: existing pr-context suites unchanged; new `.dev` cases in `collector-core.test.ts` and `verification-evidence.test.ts`.
  - Acceptance: pr-context suites pass.
- [ ] [P4-T4] Route `src/lib/validate/epic-orchestrator-state-resolution.ts`, `parallel-orchestrator-state-cohort-barrier.ts`, `epic-planner-readiness-integrity.ts`, `epic-kickoff-artifact.ts` and `parallel-kickoff-artifact.ts` (`MANIFEST_RE`), `orchestrator-state-issue-adoption.ts` (`POTENTIAL_RECORD_PREFIX`) to the union, and `evidence-locations.ts` hint through the resolver.
  - Tests: existing validate suites unchanged; new `test/lib/validate/development-docs-matchers.test.ts` holds one `.dev` acceptance case per routed file.
  - Acceptance: validate suites pass.
- [ ] [P4-T5] Make `FEATURE_FOLDER_PATH_PATTERN` in `src/lib/validate/orchestrator-state-feature-folder-record.ts` accept `docs/features/active/<folder>` and `.dev/active/<folder>`; `ERROR_FEATURE_FOLDER_PATH_FORMAT` text unchanged. No corpus fixture is added here (D-P11).
  - Tests: `test/lib/validate/orchestrator-state-issue-adoption-feature-folder.test.ts` existing cases unchanged; new in-memory case: a record and checkpoint `feature-folder` of `.dev/active/2026-09-29-sample-feature-509` yield no error. Parity suites `orchestrator-state-issue-adoption-parity.test.ts`, `test_orchestrator_state_issue_adoption_parity.py` and `OrchestratorStateIssueAdoption.Parity.Tests.ps1` unchanged: the corpus is unchanged at this task and no existing fixture uses a `.dev` path.
  - Acceptance: the feature-folder suite and the TypeScript parity suite pass.
- [ ] [P4-T6] Add `.dev/**/*.json` to `GOVERNED_GLOBS` in `src/lib/json-config.ts`; in `src/lib/file-system.ts` export `compileGlob` and add the named constant `GLOB_MATCHES_DOT_ENTRIES` with a comment stating dot entries match.
  - Tests: `test/lib/file-system.test.ts` asserts `compileGlob` matches `.dev/active/x/spec.md` for `**` and `**/*.md`; `.dev` discovery cases in `json-config.test.ts` (`iterGovernedFiles`), `validate/json-validator.test.ts`, `validate/evidence-locations.test.ts`, `pr-context/verification-evidence.test.ts`, `pr-context/feature-docs.test.ts` (feature-docs-parsers glob), and `push-down/claude-blast-radius-derive.test.ts` asserting `isExcludedDirectoryName(".dev")` is `true`.
  - Acceptance: suites pass with in-memory fakes only.

### Phase 5 — Python Consumers

- [ ] [P5-T1] Route `scripts/dev_tools/new_potential_bug_entry.py`, `copy_research_to_issue.py` (`ACTIVE_ISSUE_START_DIR`), `atomic_executor/cli.py`, `atomic_executor/prompt_builder.py` through `development_docs_path`; `atomic_executor/cli_workspace.py` help and `atomic_executor/feature_resolver.py` messages from the resolver.
  - Tests: existing suites unchanged; one `.dev` case each in `tests/scripts/dev_tools/test_new_potential_bug_entry.py` and `test_copy_research_to_issue.py`.
  - Acceptance: affected test modules pass.
- [ ] [P5-T2] Route `scripts/dev_tools/pr_context/feature_docs.py`, `render_feature_excerpts.py`, `verification_evidence.py`, `summary_helpers.py` (union) and `collector.py` (add `.dev/` bucket), matching P4-T3.
  - Tests: existing pr_context suites unchanged; `.dev` cases in `tests/scripts/dev_tools/pr_context/test_verification_evidence.py` and new `tests/scripts/dev_tools/test_pr_context_dev_root.py` (collector bucket, summary helper).
  - Acceptance: pr_context tests pass.
- [ ] [P5-T3] Route `epic_planner_readiness.py`, `epic_kickoff_contract.py` and `parallel_kickoff_contract.py` (`MANIFEST_RE`), `_orchestrator_state_issue_adoption.py` (`POTENTIAL_RECORD_PREFIX`), `_epic_orchestrator_state_resolution.py`, `_parallel_orchestrator_state_cohort_barrier.py` to the union and `validate_evidence_locations.py` hint through the resolver.
  - Tests: existing suites unchanged; new `tests/scripts/dev_tools/test_development_docs_matchers.py` holds one `.dev` case per routed file.
  - Acceptance: affected modules pass; TypeScript parity suites for the same validators pass.
- [ ] [P5-T4] Make `FEATURE_FOLDER_PATH_PATTERN` in `scripts/dev_tools/_orchestrator_state_feature_folder_record.py` accept both roots; `ERROR_FEATURE_FOLDER_PATH_FORMAT` text unchanged.
  - Tests: `test_orchestrator_state_issue_adoption_feature_folder.py` existing cases unchanged (including `test_require_complete_text_accepts_adopted_feature_folder`, which reads `valid-large-waives-feature-folder-with-record.json`); new in-memory case mirroring P4-T5. `test_orchestrator_state_issue_adoption_parity.py` unchanged: the corpus is unchanged until P6-T13 (D-P11).
  - Acceptance: the feature-folder module and the Python parity module pass.
- [ ] [P5-T5] Add `.dev/**/*.json` to `GOVERNED_GLOBS` in `scripts/dev_tools/json_config.py`.
  - Tests: `test_json_config.py` gains `test_iter_governed_files_finds_dev_json` using `mem_fs_path` and a membership assertion; existing tests unchanged.
  - Acceptance: module passes.

### Phase 6 — PowerShell Consumers

Every hook that imports the module uses the guarded import pattern; Codex hooks import `.codex/lib/development-docs/` first and `.claude/lib/development-docs/` second (pattern in `.codex/hooks/enforce-discovery-planning-gate.ps1`).

- [ ] [P6-T1] Route `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` (`$script:FeatureFolderPattern`), `EpicScopeReadiness.psm1` (`$script:EpicManifestPattern`), `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` (`$script:LifecyclePrefixes`) and `OrchestratorStateIssueAdoption.psm1` (`$script:POTENTIAL_RECORD_PREFIX`) to the union.
  - Tests: existing suites unchanged; one `.dev` case each in their existing test files. `OrchestratorStateIssueAdoption.Parity.Tests.ps1` unchanged and passing (corpus unchanged until P6-T13).
  - Acceptance: suites pass.
- [ ] [P6-T2] Route `OrchestratorStateFeatureFolderRecord.psm1` (`$script:FEATURE_FOLDER_PATH_PATTERN`) to the union; `$script:ERROR_PATH_FORMAT` text unchanged.
  - Tests: `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.Tests.ps1` existing cases unchanged; new in-memory case in `Describe 'feature_folder_record rule 11a'` mirroring P4-T5. `OrchestratorStateIssueAdoption.Tests.ps1` (reads no corpus file) and `OrchestratorStateIssueAdoption.Parity.Tests.ps1` unchanged (corpus unchanged until P6-T13).
  - Acceptance: the three suites pass.
- [ ] [P6-T3] Route `Test-FeatureDocumentationOrEvidencePath` and `Test-OrchestrationReady` in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and its Codex twin, the exempt prefix list in both `enforce-orchestration-preimplementation-gate-helpers.ps1`, the epic regex in both `-modes.ps1`, and `$script:EpicScopeManifestPattern` in `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` to the union.
  - Tests: existing gate suites unchanged; new `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.DevRoot.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-dev-root.Tests.ps1` assert `.dev/active/` and `.dev/epics/` paths are recognized alongside `docs/features` forms; the helpers `Parity` suite (`enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`, which hash-compares the two helpers with their bundle copies) passes after P6-T12.
  - Acceptance: suites pass; the helpers `Parity` suite passes after P6-T12.
- [ ] [P6-T4] Route `Test-IsUnderResearchRoot` and the Pre-Mortem applicability test in `.claude/hooks/validate-task-researcher-output.ps1` to both roots and both research roots; messages unchanged.
  - Tests: new cases in `validate-task-researcher-output.Tests.ps1` for `.dev/active/x/research/` and `.dev/research/`.
  - Acceptance: the three task-researcher suites pass.
- [ ] [P6-T5] Route `.claude/hooks/enforce-completion-helpers.ps1` (prefix union; existence check against the resolved root), `enforce-completion-consistency.ps1` (message), `enforce-parallel-drift-gate.ps1` (`$script:ActiveFeatureRoot` from the resolver), `enforce-prd-feature-before-planner-helpers.ps1` (prefix and token regex union), `enforce-parallel-cohort-barrier.ps1` (message), and the Codex `enforce-completion-helpers.ps1` and `enforce-completion-consistency.ps1`.
  - Tests: existing completion, drift-gate, prd-feature and cohort suites unchanged; `.dev` cases in `enforce-parallel-drift-gate.FolderResolution.Tests.ps1` and `enforce-completion-consistency.Tests.ps1`.
  - Acceptance: suites pass; `enforce-completion-consistency-codex.Tests.ps1` hash parity passes after P6-T12.
- [ ] [P6-T6] Route `.claude/hooks/enforce-feature-folder-order.ps1`, `validate-executor-output.ps1` (`preflight-fix-record` prefix), `validate-feature-review-coverage-rules.ps1`, `validate-feature-review-coverage.ps1` (messages) to the union, and make the callers of `feature-folder-resolution.ps1` pass the known-root pattern into `Find-FeatureFolderCandidate` and `ConvertTo-FeatureFolderBasename`; apply the byte-identical change to `.codex/hooks/feature-folder-resolution.ps1`.
  - Tests: both `feature-folder-resolution.Tests.ps1` suites gain `.dev` cases and keep twin parity; `enforce-feature-folder-order.Tests.ps1` and `validate-executor-output.Preflight.Tests.ps1` unchanged.
  - Acceptance: suites pass.
- [ ] [P6-T7] Route `.codex/hooks/enforce-epic-planning-only.ps1` (union), `authorize-root-epic-invocation.ps1` (kickoff path from the resolver), `record-subagent-routing-attestation.ps1`, `validate-feature-review-coverage.ps1`, `.codex/scripts/epic-child-launch-runtime.ps1` (writers) and `epic-child-launch-contract.ps1` (union; message unchanged).
  - Tests: existing Codex suites unchanged; `.dev` cases in `epic-child-launch-hardening.Tests.ps1` and `validate-feature-review-coverage.Coverage.Tests.ps1`.
  - Acceptance: suites pass.
- [ ] [P6-T8] Add `tests/scripts/claude-hooks/enforce-parallel-drift-gate.DevelopmentDocsRoot.Tests.ps1`: malformed routing JSON and an out-of-set value each make the hook fail closed with a reason containing `config/orchestration-routing.json` and `development_docs_root`.
  - Acceptance: suite passes.
- [ ] [P6-T9] Accept `.dev/` alongside `docs/` in `Get-DocsOnlyDiffTextViolation` and the path check before it in `.claude/hooks/hook-docs-only-diff.ps1` and `.codex/hooks/hook-docs-only-diff.ps1` (D-P8; message text unchanged).
  - Tests: new `.dev` cases in `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` and `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`; `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` unchanged.
  - Acceptance: suites pass.
- [ ] [P6-T10] Change `ConvertTo-ArtifactSpec` in `.claude/hooks/validate-required-artifact-output.ps1` per D-P2.
  - Tests: `validate-required-artifact-output.Tests.ps1` and `.Reentry.Tests.ps1` existing cases unchanged; new case parses the contracted `spec-path` spec and matches `.dev/active/x/spec.md`.
  - Acceptance: suites pass.
- [ ] [P6-T11] Make `scripts/dev-tools/new-potential-entry.ps1` and `extensions/drm-copilot/resources/templates/new-potential-entry.ps1` byte-identical with the unified content of D-P3, plus `-DevelopmentDocsRoot` (`ValidateSet` of the two roots, default `docs/features`) from which the potential target, workspace template and backlog paths derive; add the same parameter to `scripts/dev-tools/link-feature-docs.ps1` for its generated links. Inspect and compare the copies per the command-text restriction in `## Execution Preamble`.
  - Existing tests and callers, with disposition: in `tests/scripts/dev-tools/new-potential-entry.Tests.ps1`, the `Test-ValidShortName`, `Get-AuthorName` (including `falls back to USERNAME environment variable when git is unavailable`, which needs the guarded form), `Convert-TemplateContent` and `Invoke-VSCodeOpen` Describe blocks, and `contains all expected function definitions`, `validates parameter declaration`, `contains the parent-directory guard block before copying the template in both production scripts` and `uses reuse-window CLI invocation without Start-Process inside Invoke-VSCodeOpen in both production scripts` are unchanged (the unified text keeps every asserted function, parameter and block). `new-potential-entry.TemplateRoot.Tests.ps1` (`uses the supplied template root when the bundled potential template exists`, `falls back to the workspace template when the supplied template root lacks the potential template`) is unchanged: the `scripts/dev-tools` copy still resolves the workspace two parents above `$PSScriptRoot`. `.vscode/tasks.json` (`Dev: 1 New Potential Entry`, no new argument) and `RepoAutomationService.newPotentialEntry` with `repo-automation-dispatch.test.ts`, `extension.workflow-commands.test.ts` and `extension.integration.test.ts` are unchanged (argv per D-P4; the bundled copy still uses the current location). The promotion hook suites (`enforce-promotion-mcp-only.Tests.ps1`, `enforce-promotion-mcp-only.TriggerScoping.Tests.ps1`, `hook-command-parser.AcceptanceCases.Tests.ps1`, the two Codex suites) and the push-down rewrite tests assert only the file name and are unchanged.
  - New tests: `tests/scripts/dev-tools/new-potential-entry.CopyParity.Tests.ps1` asserts equal SHA-256 hashes of the two copies; `new-potential-entry.TemplateRoot.Tests.ps1` gains a `.dev` case (`-DevelopmentDocsRoot .dev` targets `.dev/potential/`) and a bundled-copy case asserting the target under a mocked `Get-Location`; `link-feature-docs.Tests.ps1` gains a `.dev` case.
  - Acceptance: the four suites pass; the two copies hash equal.
- [ ] [P6-T12] Mirror every `.claude/` and `.codex/` file edited in Phase 6 to its bundle copy under `extensions/drm-copilot/resources/claude-customizations/` or `resources/codex-and-agents-customizations/`.
  - Acceptance: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_pack_manifest_dependency_closure.py`, `hook-dependency-guard-completeness.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1` pass.
- [ ] [P6-T13] Add the shared corpus fixture `tests/fixtures/orchestrator_state_issue_adoption/valid-large-waives-feature-folder-dev-root.json` (keys `name`, `notes`, `checkpoint`, `expected_errors`; `name` equals the file stem; modeled on `valid-large-waives-feature-folder-with-record.json` with the checkpoint `feature-folder` and the record `path` both `.dev/active/2026-09-29-sample-feature-509`; `expected_errors` empty). This runs after P4-T5, P5-T4 and P6-T2, so all three validators accept `.dev` (D-P11).
  - Tests, with disposition: the three parity suites `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts`, `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py` and `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1` are unchanged in source and each discovers the new file (one file more than before this task, above the `MINIMUM_CORPUS_COUNT` of 48; the on-disk count check still holds) and asserts no routing error for it.
  - Acceptance: the three parity suites pass.

### Phase 7 — Write-Scope Literal Contract (D-16)

- [ ] [P7-T1] Create `extensions/drm-copilot/src/lib/development-docs/write-scopes.ts` with the types, rule tables and expansion functions of `spec.md` `## Write-scope literal contract (D-16)`; add its `coverageThreshold` entry.
  - Tests: new `test/lib/development-docs/write-scopes.test.ts` asserts every rule-table row and both example outputs.
  - Acceptance: suite passes; threshold met.
- [ ] [P7-T2] Add the `.dev` literal beside each contracted literal (same leading-slash spelling) in the `tools:` lists of `.claude/agents/` `atomic-planner.md`, `task-researcher.md`, `prd-feature.md`, `feature-review.md`, `status-updater.md`, `epic-review.md`, `epic-planner.md`, `epic-orchestrator.md`, `parallel-orchestrator.md`, `parallel-planner.md`; replace the `prd-feature` and `epic-review` `-RequiredArtifact` patterns with the expanded union patterns; mirror all ten bundle copies.
  - Tests updated: `test_completion_gate_documentation_contracts.py` `test_feature_review_agent_grants_mcp_artifact_validator` expected tuple gains `Write(/.dev/active/**)` after the `docs/features` entry. Containment tests (`test_parallel_planner_surface_contracts.py`, `checkpoint-hygiene-skill-contract.Tests.ps1`, `test_parallel_orchestrator_permission_contracts.py`) unchanged.
  - Acceptance: those suites and `test_push_down_claude_resource_contracts.py` pass.
- [ ] [P7-T3] Add `Edit(.dev/**)` after `Edit(docs/**)` in `permissions.allow` of `.claude/settings.json` and its bundle copy.
  - Acceptance: resource contract and `discovery-capability.Tests.ps1` pass.
- [ ] [P7-T4] Add the `.dev` literals to `.codex/agents/atomic-planner.toml`, `prd-feature.toml`, `feature-review.toml`, `status-updater.toml`, `epic-review.toml`; run `scripts/dev_tools/generate_codex_agent_variants.py` once (variants, bundle copies, Codex `core.json`) and then with `--check`.
  - Acceptance: `--check` exits 0 reporting no drift; `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py` and `test_push_down_codex_and_agents_resource_contracts.py` pass.
- [ ] [P7-T5] Add `extensions/drm-copilot/test/lib/development-docs/write-scopes.contract.test.ts` implementing the three directions of `spec.md` `### Checker test (three directions)`; reverse coverage maps variant files (`-c1` to `-c4`, `-c3-elevated`) to their base agent; reads use forward-slash repository-relative paths.
  - Acceptance: suite passes, and fails when one `.dev` literal is removed locally (observation recorded in the P10-T6 artifact).
- [ ] [P7-T6] Re-baseline the `.claude/agents/epic-orchestrator.md` digest in `PINNED_FROZEN_SURFACE_HASHES` (`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`) with a dated `RE-BASELINED by issue #1016` comment stating that only the `tools:` list gained `.dev` literals.
  - Acceptance: `test_parallel_orchestrator_surface_contracts.py` and `test_parallel_planner_surface_contracts.py` pass.

### Phase 8 — CI Docs-Only Scope and Brief

- [ ] [P8-T1] Add include prefix `.dev/` and exclude prefixes `.dev/templates/`, `.dev/potential/template.md`, `.dev/engineering/`, `.dev/discovery/` to `config/ci-docs-only-paths.json`; existing entries unchanged.
  - Tests updated in `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`: 'starts every include prefix with docs/' becomes docs/ or .dev/; 'configures exactly the D3 include prefixes and extensions' gains `.dev/`; new rows call `Test-CiDocsOnlyPath` for `.dev/active/x/spec.md` (docs-only) and `.dev/templates/x.md`, `.dev/potential/template.md`, `.dev/engineering/x.md`, `.dev/discovery/x.md` (not). `CiChangeScope.Tests.ps1`, `Invoke-CiChangeScope.Tests.ps1`, `Invoke-CiChangeScopeMergeBase.Tests.ps1`, `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` unchanged.
  - Acceptance: the five suites pass.
- [ ] [P8-T2] Update the allowlist sentence in `## CI Shape and Required Checks` of the execution-environment brief in all six byte-identical copies (`.claude/skills/`, `.agents/skills/`, `.github/skills/` and their bundle copies) and `### Allowlist` under `## Change-Scope Decision (Issue #962)` in `.github/workflows/README.md` to list the `.dev/` prefix and its exclusions.
  - Acceptance: six copies hash equal; `test_execution_environment_brief_contracts.py` passes.

### Phase 9 — Blast-Radius Consumers

- [ ] [P9-T1] Re-run the P0-T2 check for the blast-radius rows of `## Conflict Re-Check Inventory` at the current merge base.
  - Acceptance: `<FEATURE>/evidence/other/conflict-recheck-blast-radius.<timestamp>.md` all PASS; a MOVED row records `STOP: REPLAN_REQUIRED` and Phase 9 stops.
- [ ] [P9-T2] Route `$script:FeatureFolderRoot` (resolver) and `$script:FeatureFolderPrefix` (union) in `.claude/lib/blast-radius/BlastRadius.psm1`, `$script:FeatureCorpusPrefix` in `BlastRadiusTokenShape.psm1` and `Test-FeatureFolderGlob` in `BlastRadiusWriteIntent.psm1` (union); mirror the three bundle copies.
  - Tests: existing blast-radius Pester suites unchanged; `.dev` cases in `BlastRadius.Tests.ps1` and `BlastRadiusTokenShape.Tests.ps1`.
  - Acceptance: suites and resource contracts pass.
- [ ] [P9-T3] Apply the same routing to `FEATURE_FOLDER_ROOT`/`FEATURE_FOLDER_PREFIX` in `scripts/dev_tools/compute_blast_radius.py`, `FEATURE_CORPUS_PREFIX` in `_blast_radius_token_shapes.py` and `_FEATURE_FOLDER_PREFIX` in `_blast_radius_write_intent.py`.
  - Tests: existing blast-radius Python suites and `blast_radius_parity_test_support.py` parity unchanged; `.dev` cases in `test_blast_radius_token_shapes.py` and `test_blast_radius_write_intent.py`.
  - Acceptance: suites pass.

### Phase 10 — Final QA, Evidence and Self-Review

- [ ] [P10-T1] Run the residual search over `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`, `extensions/drm-copilot/src` for `docs/features`, `docs[\\/]+features`, the Python split form `"docs" / "features"` and the TypeScript split form `"docs", "features"`, and the part-index forms `parts[1] === "features"` and `parts[1] == "features"`.
  - Acceptance: `<FEATURE>/evidence/other/residual-search.<timestamp>.md` records commands, output and an allowlist of Stay rows (resolver constants, prose, help citations, `build_discovery_runtime.py` `RESOURCE_ROOTS`, and the tracked coverage annotation file `scripts/dev_tools/pr_context/render.py,cover`, which is not a production source file); every hit is on the allowlist.
- [ ] [P10-T2] Verify the scope boundary: no `.dev/` path exists (`git status --porcelain` and a tree listing), `development_docs_root` is `docs/features` in all three copies, no folder under `docs/features/` is renamed (a name-status diff with rename detection, anchored on the merge base, shows no rename row), no migration command or new `pyproject.toml` entry exists.
  - Acceptance: `<FEATURE>/evidence/other/scope-boundary.<timestamp>.md` all PASS.
- [ ] [P10-T3] Run Black in check mode, Ruff and Pyright; on any failure or fix, restart the loop from formatting.
  - Acceptance: `<FEATURE>/evidence/qa-gates/python-static.<timestamp>.md` records exit 0 for each and Black's unchanged-files summary.
- [ ] [P10-T4] Run the full Pytest suite, then the coverage run of P0-T6 against `## Coverage Targets` with `--cov-report=json:SCRATCH/issue-1016-final-coverage.json`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/python-tests.<timestamp>.md` records zero failures and per-module line and branch percentages.
- [ ] [P10-T5] Run Prettier in check mode, `npm run lint` and `npm run typecheck` in `extensions/drm-copilot/`; restart on any failure or fix.
  - Acceptance: `<FEATURE>/evidence/qa-gates/typescript-static.<timestamp>.md` with exit 0 for each.
- [ ] [P10-T6] Run `npm run test:coverage` in `extensions/drm-copilot/`; record the P1-T4 and P7-T5 negative observations.
  - Acceptance: `<FEATURE>/evidence/qa-gates/typescript-tests.<timestamp>.md` records zero failures, every `coverageThreshold` met, and line and branch percentages for each file in `## Coverage Targets`, read from `extensions/drm-copilot/coverage/lcov.info`.
- [ ] [P10-T7] Run the PoshQC format check (no-op `-WriteFile` form of P0-T9) and the direct analyzer run of P0-T9; restart on any finding.
  - Acceptance: `<FEATURE>/evidence/qa-gates/powershell-static.<timestamp>.md` records no `Formatted:` line (every file logs `Already formatted:`) and zero Error and Warning findings.
- [ ] [P10-T8] Run Pester over `tests/scripts` through branch-current `Invoke-PoshQCTest` with coverage.
  - Acceptance: `<FEATURE>/evidence/qa-gates/powershell-tests.<timestamp>.md` records zero failures from the JUnit file and line coverage of `DevelopmentDocsRoot.psm1` at or above 85% and of each changed PowerShell file from the coverage XML.
- [ ] [P10-T9] Run every contract test in `## Contract Tests That Pin Mirrored Files` of the brief, plus `test_orchestration_routing_config_parity.py`, `test_push_down_codex_and_agents_virtual_paths.py`, `test_quality_tiers_contract_classification.py`, `ClaudeLibModuleConvention.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`, and the Codex generator `--check`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/contract-tests.<timestamp>.md` records each pass.
- [ ] [P10-T10] Run the isolation checks of the brief's `## Test Isolation Checks`: seeded shuffled Jest run, reversed-order run of the new and changed Python test modules in one process, three-seed shuffled file-order Pester run of the touched suites, and a fresh single-process Pester run over `tests/scripts`.
  - Acceptance: `<FEATURE>/evidence/regression-testing/isolation.<timestamp>.md` records each seed, file order and a zero-failure result; any order dependence is fixed on both sides and every seed re-run.
- [ ] [P10-T11] Compare baseline and final coverage per language and per file in `## Coverage Targets`, and report changed-line coverage from the term-missing output against the merge-base diff hunks.
  - Acceptance: `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md` shows no per-file regression, new files at or above 85% line (and 75% branch for Python and TypeScript), changed-line coverage at or above 85%.
- [ ] [P10-T12] Record physical line counts of every new or changed production and test file against the tiers.
  - Acceptance: `<FEATURE>/evidence/qa-gates/file-size.<timestamp>.md` shows none above 800; `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` passes.
- [ ] [P10-T13] Walk the policy-audit, code-review and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base, including the test-disposition list of P3-T2 and every Recorded Decision.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` has one PASS, FAIL or N/A row per checklist item and no FAIL row (a FAIL is fixed, the QA loop re-run, and the review rewritten).

## Coverage Targets

- Python (dotted): `scripts.dev_tools.json_config`, `.new_active_feature_folder_flow`, `.new_active_feature_folder_io`, `.new_potential_bug_entry`, `.potential_to_issue`, `.potential_to_issue_content`, `.copy_research_to_issue`, `.atomic_executor.cli`, `.atomic_executor.prompt_builder`, `.atomic_executor.cli_workspace`, `.atomic_executor.feature_resolver`, `.plan_progress_report`, `.pr_context.feature_docs`, `.pr_context.render_feature_excerpts`, `.pr_context.verification_evidence`, `.pr_context.summary_helpers`, `.pr_context.collector`, `.epic_planner_readiness`, `.epic_kickoff_contract`, `.parallel_kickoff_contract`, `._orchestrator_state_issue_adoption`, `._orchestrator_state_feature_folder_record`, `._epic_orchestrator_state_resolution`, `._parallel_orchestrator_state_cohort_barrier`, `.resolve_execute_plan_prompt`, `.resolve_file_prompt`, `.validate_evidence_locations`, `.push_down_codex_and_agents_customizations`, `.compute_blast_radius`, `._blast_radius_token_shapes`, `._blast_radius_write_intent` (each prefixed `scripts.dev_tools`).
- TypeScript: new `src/lib/development-docs/root.ts`, `feature-folder-name.ts`, `write-scopes.ts`, and every `src/` file edited in Phases 2 to 4.
- PowerShell: `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` and every PowerShell file edited in Phases 6 and 9.

## Language Choices

| Component | Language | Cost | Risk |
| --- | --- | --- | --- |
| Resolver, parser, write-scope modules | TypeScript, no `vscode` import | one `coverageThreshold` entry per file; P1-T4 guard | MCP bundle shims `vscode`; guarded by test |
| Write-scope checker | TypeScript Jest | reads repository files by relative path | Linux CI path case and separators; forward-slash joins only |
| PowerShell resolver | PowerShell module | three copies, two manifests, tier entry, Codex publication | new hook import dependency; guarded import pattern |
| Python resolver and parser | Python, in place in `scripts/dev_tools/json_config.py` | docstring widens; consumers import `json_config` | none new; no new Python file, script, tool, generator, checker or entry point (owner directive) |
| Enforcement hooks | PowerShell | none | hooks do not invoke Python |

## Pre-Mortem

- Review checklists: a reviewer finds a consumer still hard-coding `docs/features` or a changed message; P10-T1 residual search with a recorded allowlist, the byte-identical-message invariant, and P10-T13 self-review over all three templates.
- Coverage: new TypeScript files lack thresholds or Python figures come from a path-form `--cov`; P1-T2, P1-T3, P7-T1 add per-file `coverageThreshold` entries, Python uses dotted `--cov` with `--cov-branch` and JSON branch figures, Pester line coverage is read from `artifacts/pester/powershell-coverage.xml`, and P10-T11 compares against Phase 0.
- Mirror parity: the two `new-potential-entry.ps1` copies made byte-identical with a hash test (P6-T11), module copies (P2-T1), pack manifests (P2-T3), Codex publication (P2-T4), hook bundle copies (P6-T12, P9-T2), agent and settings copies (P7-T2, P7-T3), generator run and `--check` (P7-T4), hash re-baseline (P7-T6), and the execution-environment brief update in all six byte-identical copies (P8-T2), which this plan requires because it changes the docs-only allowlist fact the brief states.
- File size: P0-T4 records files at or above 500 lines before editing; new logic lives in the new modules; P10-T12 confirms no file above 800.
- Test isolation: resolvers take injected readers in all runtimes and no test reads the real routing file or probes for `.dev`; P10-T10 runs a seeded shuffled Jest run, a reversed-order run of the changed Python test modules, and a three-seed shuffled Pester file-order run, each seed recorded.
- CI-only behavior: the checker and `.dev` fixtures use forward-slash relative paths and no drive letters; no test diffs against `origin/main`; Linux hook suites use `Join-Path` and exact case; the allowlist file change triggers a full CI run.
- Evidence: every artifact under `<FEATURE>/evidence/<kind>/` with Timestamp, Command, EXIT_CODE and Output Summary; the `evidence/coverage/` path in `spec.md` is overridden to `qa-gates`; Phase 0 gate artifacts precede any edit.

## Acceptance Criteria Traceability

Spec criteria are numbered in document order (S-1 to S-42); user-story criteria map onto them.

| AC | Tasks |
| --- | --- |
| S-1 routing key | P1-T1 |
| S-2, S-3, S-4 resolver R-1 to R-8 | P1-T2, P1-T5, P1-T7 |
| S-5, S-6 area map and prefixes | P1-T2, P1-T5, P1-T7 |
| S-7 no `vscode` | P1-T4 |
| S-8 Python in place, no Python hook | P1-T5, P1-T6, P10-T2, P10-T9 |
| S-9 full suites, limited expectation changes | P3-T1 to P3-T5, P10-T4, P10-T6, P10-T8 |
| S-10 residual search | P10-T1 |
| S-11 `.dev` writes in folder creation, bug entry, promotion | P3-T1, P3-T4, P4-T1 |
| S-12 feature-folder record matchers | P4-T5, P5-T4, P6-T2, P6-T13 |
| S-13 gate and researcher matchers | P6-T3, P6-T4 |
| S-14 `new-potential-entry.ps1` (byte-identical copies, D-P3) | P6-T11, P4-T2 |
| S-15 fail-closed hook | P6-T8 |
| S-16, S-17 CI docs-only config and suites | P8-T1 |
| S-18 `hook-docs-only-diff.ps1` | P6-T9 |
| S-19 brief and workflow README | P8-T2 |
| S-20 `GOVERNED_GLOBS` | P4-T6, P5-T5 |
| S-21, S-22, S-23 dot-folder handling | P4-T6 |
| S-24, S-25 parser cases | P1-T3, P1-T6, P1-T8 |
| S-26 parser delegation | P3-T6, P3-T7 |
| S-27, S-28 folder creation and epics | P3-T1, P3-T2, P3-T3 |
| S-29 status line | P3-T4, P3-T5 |
| S-30 to S-34 write-scope contract | P7-T1 to P7-T6, P6-T10 |
| S-35 to S-38 mirrors, manifests, Codex | P2-T1 to P2-T4, P6-T12, P10-T9 |
| S-39 scope boundary | P10-T2 |
| S-40 coverage thresholds | P10-T6, P10-T8, P10-T11 |
| S-41 toolchain and file size | P10-T3 to P10-T8, P10-T12 |
| S-42 Phase 0 gate evidence | P0-T1, P0-T2 |

## Size Justification

This child is one cross-runtime contract change: one configured key read by about 93 production consumers in three runtimes, plus mirrors, a write-scope contract and CI scope. The owner decided the child is not split. Each task covers one consumer group with its tests so that each binary outcome stays checkable, which requires 77 canonical tasks (above the guideline of 40) in about 370 lines (within the 400-line guideline). Files produced by the Codex generator run count as one task (P7-T4).

## Open Questions / Notes

- OQ-1, OQ-3, OQ-4 and OQ-5 from `spec.md` are applied as recorded there; package version bumps are not part of this child.
- D-P3 now follows the literal "equal text" wording of S-14 (orchestrator decision after preflight round 1); the unified `$workspace` rule keeps each copy's current resolution.
- `.dev/backlog.md` becomes docs-only under the spec's `.dev/` include, while `docs/features/backlog.md` is not docs-only today; recorded for the owner, not changed.
