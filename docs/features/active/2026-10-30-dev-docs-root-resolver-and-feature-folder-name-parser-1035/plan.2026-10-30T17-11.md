# 2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser - Plan

- **Issue:** #1035 (epic #1018, child 2: Phase 1 of #1016 only; references #1016 and does not close it — no Closes, Fixes or Resolves line for #1016 in any commit or pull request)
- **Parent (optional):** epic #1018 (`docs/features/epics/shared-agent-harness-layer/epic.md`)
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14
- **Status:** Ready for preflight (preparation-mode refresh against the current contract)
- **Version:** 2.0
- **Work Mode:** full-feature (acceptance criteria from `spec.md` and `user-story.md`)
- **Branch:** `feature/dev-docs-root-resolver-phase1-1035`

## Required References

- Requirements (feature-folder relative): `issue.md`, `spec.md` (including `## Refresh Amendments (2026-11-14)`), `user-story.md`, `research/research.2026-10-30T21-15.md`.
- Environment facts (tool routes, launchers, PowerShell route, batch budget, hook context, CI shape, contract tests, isolation checks): the `execution-environment` skill. This plan does not restate them.
- Policy reading order: the `policy-compliance-order` skill; no Phase 0 policy-read task.

## Execution Preamble

- `<FEATURE>` is `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035`. Evidence goes to `<FEATURE>/evidence/<kind>/<name>.<timestamp>.md` with the write-time UTC stamp read from the clock; a consumer selects the lexicographically greatest `<name>.*.md`. Evidence is append-only.
- SCRATCH resolves to `<session scratchpad>/issue-1035/`; scratch file names start with `issue-1035-`. Evidence records the token `SCRATCH`, never a host path.
- Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task (evidence `<FEATURE>/evidence/other/task-check.P<N>-T<M>.<timestamp>.md`), and the `[phase-gate]` task closing each phase from Phase 1 to Phase 8 runs stages 1 to 6 with the three parallel gates. All test runs are parallel-only; integration and golden suites run in CI only.
- Route: this child exceeds the per-session cap in every language. Execution uses the `large` route of `## Batch Budget` in the `execution-environment` skill; the item worktree checkpoint selects it before Phase 1.
- Scope diffs anchor on the merge base of `origin/main` and `HEAD`.
- Invariant for every consumer task: with the default root `docs/features`, every user-facing message, error string, written path and exit status is byte-identical to today. Matchers accept the union of both known roots regardless of the configured value; writers use the resolved root through the area map.
- Mirror rule: every task that edits a file with a bundle copy, Codex twin or Codex source copy writes every copy in the same task, so no task check or gate sees a half-mirrored pair.
- Command text: `.claude/hooks/enforce-promotion-mcp-only.ps1` denies any Bash command text that names the promotion-script file of P5-T11 (`PROMOTION_MCP_ONLY_BLOCKED`), including read-only commands. P0-T1 and P5-T11 compare its two copies with Read and Grep, or through a launcher under `SCRATCH` whose command text names only the launcher.
- EVIDENCE_LOCATION_OVERRIDE_REJECTED: `<FEATURE>/evidence/coverage/` replaced with `<FEATURE>/evidence/qa-gates/` (spec amendment A-7 now states the canonical kind).

## Recorded Decisions (planner interpretations)

- D-P1. The Python resolver and parser are added in place to `scripts/dev_tools/json_config.py`. No new Python file under `scripts/` or `tests/`, no `pyproject.toml` entry. New Python tests go into existing modules (orchestrator decision AD-3); every receiving module stays under 700 lines, and `tests/scripts/dev_tools/test_atomic_executor_cli.py` (near 800) receives no case.
- D-P2. `ConvertTo-ArtifactSpec` in `.claude/hooks/validate-required-artifact-output.ps1` splits on `|` with a three-part limit, which would cut the contracted pattern at its alternation. It changes to: token before the first `|`, description after the last `|`, pattern between (P5-T10). Existing three-part specs parse identically.
- D-P3. The two `new-potential-entry.ps1` copies still differ in `Get-AuthorName` (only the `scripts/dev-tools` copy has the `-GetCommand` guard), the `$workspace` assignment (two parents of `$PSScriptRoot` versus `(Get-Location).Path`) and trailing blank lines. P5-T11 makes them byte-identical: guarded `Get-AuthorName`; `$workspace` is two parents of `$PSScriptRoot` when the script directory leaf is `dev-tools` under `scripts`, and `(Get-Location).Path` otherwise; one trailing newline.
- D-P4. `RepoAutomationService.newPotentialEntry` appends `-DevelopmentDocsRoot <root>` only when the resolved root differs from the default, so the exact-argv suites stay unchanged.
- D-P5. The TypeScript resolver accepts a structural reader (`exists`, `isDirectory`, `readTextFile`) that `FileSystem` satisfies. Probe order: `exists` on the routing file (false gives R-1 without a read), then `readTextFile`; `isDirectory` only when the value is `.dev`. Fakes that throw from `exists` or `isDirectory` in suites whose unit now resolves the root answer from their own file map; case assertions are unchanged.
- D-P6. The potential-to-issue status folder is `formatFeatureFolderName(issue, stripDateFirstPrefix(potential stem))`; when the formatter rejects the stem (N-5), it falls back to today's sanitized `featurePath` token. `updateMetadataLines` and `update_metadata_lines` keep taking the folder token and gain the active-area text; the caller computes the token.
- D-P7. `.claude/lib/development-docs` gets a T3 entry in `quality-tiers.yml` (rule R4 of `scripts/dev_tools/quality_tiers_contract.py`).
- D-P8. `.codex/hooks/hook-docs-only-diff.ps1` receives the same `.dev/` change as its Claude twin.
- D-P9. Existing date-first and issue-less folders keep their names; issue-less creation keeps today's slug (OQ-4).
- D-P10. `PotentialFileSystem` has no directory probe; `promotePotential` resolves the root through a local adapter over its injected `fs` (`exists` serves both probes); `promotion-filesystem.ts` is unchanged. The Python promotion uses its injected `fs` the same way.
- D-P11. The shared corpus fixture with a `.dev` folder is added only after all three record validators accept `.dev` (P5-T12); until then each runtime proves acceptance with an in-memory case.
- D-P12 (AD-2). The run `bugs-1001-1002-1003-1006` and item #1013 have merged; the merge gate, the conflict re-check tasks and table, and every STOP that waited on that run are removed (spec amendment A-1).
- D-P13. Seventeen newly inventoried files are classified in spec "Consumers inventoried at the 2026-11-14 refresh": seven routed (Phase 6 and P5-T7), ten Stay rows on the P9-T1 allowlist. `scripts/dev-tools/ProcessReductionChain.psm1` stays: it maps bundle template mirrors to this repository's tracked source for the ledger replay, and routing it would make `ProcessReductionChain.Ledger.Tests.ps1` depend on configuration.
- D-P14. Parser delegation keeps today's results: `resolveNameFromFeatureFoldername` and both Python `_resolve_name_from_feature_foldername` return the parsed `feature` for a date-first name with an issue and for an issue-first name, and the whole name otherwise (so `feature-123` still returns `feature-123`).
- D-P15. The CI docs-only additions mirror the per-area allowlist of issue #973 (spec amendment A-3).
- D-P16. Whole-root matchers use the new `Get-DevelopmentDocsKnownRoot` (spec amendment A-4). Pure dot-sourced helpers (`enforce-epic-merge-gate-review.ps1`, `hook-epic-fan-in.ps1`) call it as a call-time dependency that the dot-sourcing hook imports with the guarded pattern; Codex hooks import `.codex/lib/development-docs/` first and `.claude/lib/development-docs/` second (pattern in `.codex/hooks/enforce-discovery-planning-gate.ps1`).

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baselines

- [ ] [P0-T1] Record physical line counts (method in the brief's `## Preflight Defect Classes the Validator Cannot See`) of every existing production and test file this plan edits that is at or above 500 lines, and the regions in which `scripts/dev-tools/new-potential-entry.ps1` and `extensions/drm-copilot/resources/templates/new-potential-entry.ps1` differ.
  - Acceptance: `<FEATURE>/evidence/baseline/file-size.<timestamp>.md` lists each file with count and tier and the three regions of D-P3; any further region is listed and P5-T11 unifies it.
- [ ] [P0-T2] Capture the Python static baseline over `scripts/dev_tools/` and `tests/scripts/dev_tools/` (configuration in `pyproject.toml`): Black in check mode, Ruff, Pyright.
  - Acceptance: `<FEATURE>/evidence/baseline/python-static.<timestamp>.md` with Timestamp, Command, EXIT_CODE and Output Summary (finding count) per tool.
- [ ] [P0-T3] Capture the `Phase 0 baseline` of the Python gate (configuration in `pyproject.toml`, suites under `tests/scripts/dev_tools/`): one `pytest -n auto` run with line and branch coverage and a JSON report under `SCRATCH`.
  - Acceptance: `<FEATURE>/evidence/baseline/python-tests.<timestamp>.md` records pass and fail counts, the repo-wide percentages and the line and branch percentage of each Python file in `## Coverage Targets`, read from the JSON report.
- [ ] [P0-T4] Capture the TypeScript static baseline in `extensions/drm-copilot/`: Prettier check, lint, typecheck.
  - Acceptance: `<FEATURE>/evidence/baseline/typescript-static.<timestamp>.md` with one block per tool.
- [ ] [P0-T5] Capture the `Phase 0 baseline` of the Jest gate in `extensions/drm-copilot/`: one coverage run through the normal parallel workers.
  - Acceptance: `<FEATURE>/evidence/baseline/typescript-tests.<timestamp>.md` records suite and test counts and the line and branch percentage of each TypeScript file in `## Coverage Targets`, read from `extensions/drm-copilot/coverage/lcov.info`.
- [ ] [P0-T6] Capture the PowerShell static baseline: the branch-current `Invoke-PoshQCFormat` with a no-op `-WriteFile` script block (no file rewritten) and a direct `Invoke-ScriptAnalyzer` run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
  - Acceptance: `<FEATURE>/evidence/baseline/powershell-static.<timestamp>.md` records the count of `Formatted:` log lines and the analyzer findings by severity.
- [ ] [P0-T7] Capture the `Phase 0 baseline` of the Pester gate over `tests/scripts/`: one `Invoke-PoshQCParallelTest` run from `scripts/powershell/PoshQC/PoshQC.psd1` (route and result files per the brief's `## PowerShell Route and PoshQC MCP Limits`).
  - Acceptance: `<FEATURE>/evidence/baseline/powershell-tests.<timestamp>.md` records the returned `ExitCode`, pass and fail counts (each failing test by name when non-zero), and the line coverage of each PowerShell file in `## Coverage Targets`.

### Phase 1 — Configured Key, Resolvers, Parsers and Publication

- [ ] [P1-T1] Add the flat top-level entry `"development_docs_root": "docs/features"` to `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json` and `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json`, byte-identical.
  - Existing tests: `test_orchestration_routing_config_parity.py`, `test_codex_topology_policy_config_parity.py`, `test_codex_model_policy_config_parity.py`, `OrchestratorStateRoutingMatrix.Tests.ps1` and `ModelRouting.Parity.Tests.ps1` read named keys or byte parity and are unchanged; the routing loaders ignore unknown top-level keys.
  - Acceptance: those suites pass and the three files hash equal.
- [ ] [P1-T2] Create `extensions/drm-copilot/src/lib/development-docs/root.ts` with the exports of spec `### TypeScript`, R-1 to R-8, the area map, the unknown-area error and D-P5; errors name `config/orchestration-routing.json`, the key and the value. Add `"./src/lib/development-docs/root.ts"` to `coverageThreshold` in `extensions/drm-copilot/jest.config.cjs` with the line threshold 85 and the branch threshold 75.
  - Tests: new `extensions/drm-copilot/test/lib/development-docs/root.test.ts` with in-memory fakes and one case titled by each rule ID (`R-1` to `R-8`, each R-4 input: other string, blank, non-string, backslash, leading `/`, `..` segment), the R-2 case asserting `isDirectory` is never called (OQ-1), one case per area per root, `unknown area`, and `knownRootPrefixes` for every area.
  - Acceptance: suite passes; the file meets its threshold.
- [ ] [P1-T3] Create `extensions/drm-copilot/src/lib/development-docs/feature-folder-name.ts` (`FeatureFolderName`, `parseFeatureFolderName`, `formatFeatureFolderName`, `stripDateFirstPrefix`) per spec `### Feature-folder name rules (D-18, D-19)`, reusing `NAME_PATTERN` from `src/lib/new-active-feature-folder/models.ts`; add its `coverageThreshold` entry.
  - Tests: new `test/lib/development-docs/feature-folder-name.test.ts` with cases titled `F-1` to `F-6`, `N-1` to `N-5` (N-3: 0, negative, non-integer; N-4: 10000; N-5: empty, pattern failure, `\d{2}-\d{2}-` prefix), `stripDateFirstPrefix`, and trailing-issue removal (stem `2026-10-30-foo-1016` with issue 1016 gives `1016-foo`).
  - Acceptance: suite passes; threshold met.
- [ ] [P1-T4] Add `test/lib/development-docs/no-vscode-import.test.ts`, which reads each `.ts` file under `src/lib/development-docs/` by repository-relative forward-slash path and fails on any `vscode` import or require.
  - Acceptance: passes, and fails when a `vscode` import is added locally (observation recorded in the P9-T6 artifact).
- [ ] [P1-T5] Extend `scripts/dev_tools/json_config.py` in place with `DEVELOPMENT_DOCS_ROOT_KEY`, `DEFAULT_DEVELOPMENT_DOCS_ROOT`, `KNOWN_DEVELOPMENT_DOCS_ROOTS`, `resolve_development_docs_root`, `development_docs_path`, `known_root_prefixes` (spec `### Python`; injected `read_text` and `is_dir`) and a module docstring describing repository layout configuration.
  - Tests: in `tests/scripts/dev_tools/test_json_config.py`, parametrized cases named by rule ID as in P1-T2 (R-3 and R-4 assert the message names the file, key and value), the area map under both roots, unknown area, prefixes, and `test_json_config_imports_no_dev_tools_module` (AST: no `scripts.dev_tools` import). Existing tests unchanged.
  - Acceptance: module passes.
- [ ] [P1-T6] Add `FeatureFolderName`, `parse_feature_folder_name`, `format_feature_folder_name`, `strip_date_first_prefix` to `scripts/dev_tools/json_config.py` with the P1-T3 rules and its own copy of the `NAME_PATTERN` expression.
  - Tests: the P1-T3 cases, parametrized, in `tests/scripts/dev_tools/test_json_config.py`.
  - Acceptance: module passes; `git status --porcelain` lists no untracked path under `scripts/` or `tests/scripts/dev_tools/`.
- [ ] [P1-T7] Create `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` per `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` with `Resolve-DevelopmentDocsRoot` (object with `Succeeded`, `Root`, `Reason`; I/O only through `-ReadText` and `-TestDirectory`), `Get-DevelopmentDocsPath`, `Get-DevelopmentDocsKnownRoot`, `Get-DevelopmentDocsKnownRootPrefix`, `Get-DevelopmentDocsKnownRootPattern`; write byte-identical copies to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/development-docs/` and `extensions/drm-copilot/resources/lib/development-docs/`.
  - Tests: new `tests/scripts/claude-lib/development-docs/DevelopmentDocsRoot.Tests.ps1` with cases titled by rule ID (R-3 and R-4 assert `Succeeded` false and a `Reason` naming file, key and value), area map, unknown area, known roots in order, and the pattern matching forward- and back-slash samples under both roots.
  - Acceptance: suite and `ClaudeLibModuleConvention.Tests.ps1` pass; three copies hash equal.
- [ ] [P1-T8] Add `ConvertFrom-FeatureFolderName` and `ConvertTo-FeatureFolderName` to `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` and both copies with the P1-T3 rules.
  - Tests: the P1-T3 cases in `DevelopmentDocsRoot.Tests.ps1`.
  - Acceptance: suite passes; module under 500 lines; copies hash equal.
- [ ] [P1-T9] Add `.claude/lib/development-docs` with tier T3 and a rationale to `quality-tiers.yml` (D-P7).
  - Acceptance: `test_quality_tiers_contract_classification.py` passes unchanged.
- [ ] [P1-T10] Add `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` to the `paths` of `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and `.codex/lib/development-docs/DevelopmentDocsRoot.psm1` to `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` in the two-space JSON shape `render_manifest` writes, so the generator check reports no drift.
  - Acceptance: `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py` pass.
- [ ] [P1-T11] Add the pair `.codex/lib/development-docs` to `lib/development-docs` to `VIRTUAL_RESOURCE_DIRECTORIES` in `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts` and in `scripts/dev_tools/push_down_codex_and_agents_customizations.py`.
  - Tests: a case in `test/lib/push-down/codex-agents-customizations.test.ts` asserting `VIRTUAL_ROOT_FOLDERS` contains `.codex/lib/development-docs`; a `shouldCopy` row for `lib/development-docs/DevelopmentDocsRoot.psm1` in `test/packaging/mcp-server-prepack.test.ts`; publication and stored-mirror byte-identity cases for development-docs in `tests/scripts/dev_tools/test_push_down_codex_and_agents_virtual_paths.py` (modeled on the epic-wave cases).
  - Acceptance: the three suites pass.
- [ ] [P1-T12] [phase-gate] Run stages 1 to 6 per `## Test Cadence (Mandatory)` over `scripts/`, `.claude/`, `.codex/`, `extensions/drm-copilot/` and `tests/`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase-gate.P1.<timestamp>.md` records one clean pass of every stage, including the Codex generator check.

### Phase 2 — Folder Creation, Status Line and Parser Delegation

- [ ] [P2-T1] In `extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts` (`buildFolderSlug`, `findPotentialFile`) and `flow.ts` (`createActiveFolder`), route promoted, templates, epics and active paths through `developmentDocsPath` and name issue folders with `formatFeatureFolderName` (no issue: today's slug; epics: `<epics area>/<slug>`).
  - Changed behavior, asserting tests: `io.test.ts` `describe("buildFolderSlug")` (`notes-240` becomes `0240-notes`), `flow.test.ts` and `new-active-feature-folder-service-call.test.ts` (`notes-feature-240` becomes `0240-notes-feature`) are updated; `test/extension.new-active-feature-folder.test.ts` and `extension.new-active-feature-folder-inprocess.test.ts` are searched for issue-suffixed folder names and each match is updated or recorded as unaffected; `findPotentialFile` cases and `createActiveFolder epic creation (single home)` are unchanged.
  - New cases: issue 1016 with stem `2026-10-30-foo` gives `1016-foo`; issue 42 gives `0042-<feature>`; no issue keeps the slug; `.dev` configured and present writes under `.dev/active`, absent under `docs/features/active`; an epic under `.dev/epics` when `.dev` is present.
  - Acceptance: the five suites pass.
- [ ] [P2-T2] In `scripts/dev_tools/new_active_feature_folder_io.py` (`build_folder_slug`, `find_potential_file`) and `new_active_feature_folder_flow.py`, apply the P2-T1 routing and naming; argparse help is unchanged under the default.
  - Changed behavior, asserting tests: `test_build_folder_slug_uses_potential_and_issue_number` and the `2025-12-23-json-quality-63` and `bug-case-77` expectations in `test_new_active_feature_folder.py`, `refactor-test-88` and `auto-test-42` in `_part2.py`, and `2026-02-22-testing-missing-mock-injections-42` in `_part4.py` are updated; `_part3.py`, `_part5.py`, `_launcher.py`, `_markdown_escape.py`, `_models_coverage.py` and `_bug_template_preserved.py` are searched and recorded unchanged or updated. New cases mirror P2-T1 in `test_new_active_feature_folder.py`.
  - Acceptance: every `test_new_active_feature_folder*.py` module passes.
- [ ] [P2-T3] Add the D-P6 status-folder helper to `extensions/drm-copilot/src/lib/potential-to-issue/content.ts`, give `updateMetadataLines` the active-area text, and in `promotion.ts` resolve the root per D-P10, route the promoted directory through `developmentDocsPath(root, "potential/promoted")` and pass the helper's token.
  - Changed behavior, asserting tests: `promotion.test.ts` status expectation `Feature_Title` becomes `0123-sample` (potential stem `sample`); `content.test.ts` `updateMetadataLines` cases are unchanged (they pass the token); `promotion.matrix.test.ts` and `promotion.move-verification.test.ts` are unchanged.
  - New cases: helper `1016-foo` and N-5 fallback in `content.test.ts`; in `promotion.test.ts`, `.dev` present gives a destination under `<workspace>/.dev/potential/promoted/` and `Promoted -> .dev/active/1016-foo/`, `.dev` absent gives `docs/features` forms.
  - Acceptance: the potential-to-issue suites pass.
- [ ] [P2-T4] Apply P2-T3 in `scripts/dev_tools/potential_to_issue_content.py` and `potential_to_issue.py`.
  - Changed behavior, asserting tests: the status assertion in `test_potential_to_issue.py` becomes `0123-sample`; `test_potential_to_issue_content.py` direct `update_metadata_lines` cases are unchanged; new helper, fallback and `1016-foo` cases go into those two modules.
  - Acceptance: every `test_potential_to_issue*.py` module passes; the TypeScript and Python status strings for the same input are equal.
- [ ] [P2-T5] Make `resolveNameFromFeatureFoldername` in `src/lib/resolve/file-prompt-variables.ts` delegate to `parseFeatureFolderName` per D-P14.
  - Tests: existing cases in `test/lib/resolve/file-prompt-variables.test.ts` unchanged (including the dated, `feature-123` and versioned `v2` cases); new issue-first case `1016-foo-bar` resolves `foo-bar`.
  - Acceptance: suite passes.
- [ ] [P2-T6] Make `_resolve_name_from_feature_foldername` in `scripts/dev_tools/resolve_execute_plan_prompt.py` and `resolve_file_prompt.py` (D-P14), and the issue extraction behind `_TRAILING_ISSUE_IN_FEATURE_DIR_PATTERN` in `plan_progress_report.py`, delegate to `parse_feature_folder_name`; the `--active-root` default comes from `development_docs_path`.
  - Tests: existing cases in `test_resolve_execute_plan_prompt.py`, `test_resolve_file_prompt.py` and `test_plan_progress_report.py` unchanged; each gains an issue-first case.
  - Acceptance: the three modules pass.
- [ ] [P2-T7] [phase-gate] Run stages 1 to 6 per `## Test Cadence (Mandatory)` over `scripts/`, `.claude/`, `.codex/`, `extensions/drm-copilot/` and `tests/`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase-gate.P2.<timestamp>.md` records one clean pass.

### Phase 3 — TypeScript Consumers

- [ ] [P3-T1] Replace `ACTIVE_FEATURE_DOCS_DIRECTORY` and `POTENTIAL_DOCS_DIRECTORY` in `src/extension-command-helpers.ts` with resolver calls, and route the potential and template joins in `src/lib/new-potential-bug-entry.ts`.
  - Tests: `test/extension-command-helpers.test.ts` and `test/lib/new-potential-bug-entry*.test.ts` existing cases unchanged (the `InMemoryFileSystem` fakes of `new-potential-bug-entry.test.ts` and `new-potential-bug-entry-service-call.test.ts` gain map-backed `exists` and `isDirectory`, D-P5); two `createBugEntry` cases: `.dev` present writes under `<workspace>/.dev/potential/`, absent under `<workspace>/docs/features/potential/`.
  - Acceptance: suites pass.
- [ ] [P3-T2] Make `RepoAutomationService.newPotentialEntry` in `src/repo-automation-service.ts` resolve the root through its injected `fileSystem` and pass `-DevelopmentDocsRoot` per D-P4.
  - Tests: `test/repo-automation-dispatch.test.ts`, `newPotentialEntry passes the bundled script path and short-name args` in `test/extension.workflow-commands.test.ts` and the `newPotentialEntry` case of `test/extension.integration.test.ts` unchanged (default argv); new `test/repo-automation-service.new-potential-entry-root.test.ts` asserts `.dev` is passed when configured and present, and not passed by default.
  - Acceptance: the four suites pass.
- [ ] [P3-T3] Route `src/lib/pr-context/feature-docs.ts` and `render-feature-excerpts.ts` (part-index matchers to the union, base and promoted directories through the resolver), `verification-evidence.ts` (resolver), `summary-helpers.ts` `isScopingDoc` (union) and the `collector-core.ts` docs bucket (add `.dev/`).
  - Tests: existing pr-context suites unchanged; `.dev` cases in `collector-core.test.ts`, `verification-evidence.test.ts` and `feature-docs.test.ts`.
  - Acceptance: pr-context suites pass.
- [ ] [P3-T4] Route to the union `src/lib/validate/epic-orchestrator-state-resolution.ts`, `parallel-orchestrator-state-cohort-barrier.ts`, `epic-planner-readiness-integrity.ts` (prefixes; manifest and kickoff paths through the resolver), `MANIFEST_RE` in `epic-kickoff-artifact.ts` and `parallel-kickoff-artifact.ts`, and `POTENTIAL_RECORD_PREFIX` in `orchestrator-state-issue-adoption.ts`; the `evidence-locations.ts` hint comes from the resolver. Messages unchanged.
  - Tests: existing validate suites unchanged; new `test/lib/validate/development-docs-matchers.test.ts` holds one `.dev` case per routed file.
  - Acceptance: validate suites pass.
- [ ] [P3-T5] Make `FEATURE_FOLDER_PATH_PATTERN` in `src/lib/validate/orchestrator-state-feature-folder-record.ts` accept `docs/features/active/<folder>` and `.dev/active/<folder>`; `ERROR_FEATURE_FOLDER_PATH_FORMAT` unchanged; no corpus fixture here (D-P11).
  - Tests: existing cases of `orchestrator-state-issue-adoption-feature-folder.test.ts` unchanged; new in-memory case: record and checkpoint `feature-folder` `.dev/active/2026-09-29-sample-feature-509` yield no error. `orchestrator-state-issue-adoption-parity.test.ts` unchanged.
  - Acceptance: both suites pass.
- [ ] [P3-T6] Add `.dev/**/*.json` to `GOVERNED_GLOBS` in `src/lib/json-config.ts`; in `src/lib/file-system.ts` export `compileGlob` and add the named constant `GLOB_MATCHES_DOT_ENTRIES` with a comment stating dot entries match.
  - Tests: `test/lib/file-system.test.ts` asserts `compileGlob` matches `.dev/active/x/spec.md` for `**` and `**/*.md`; `.dev` discovery cases in `json-config.test.ts` (`iterGovernedFiles`), `validate/json-validator.test.ts`, `validate/evidence-locations.test.ts`, `pr-context/verification-evidence.test.ts`, `pr-context/feature-docs.test.ts` (the `feature-docs-parsers.ts` glob); `push-down/claude-blast-radius-derive.test.ts` asserts `isExcludedDirectoryName(".dev")` is `true`.
  - Acceptance: suites pass with in-memory fakes only.
- [ ] [P3-T7] [phase-gate] Run stages 1 to 6 per `## Test Cadence (Mandatory)` over `scripts/`, `.claude/`, `.codex/`, `extensions/drm-copilot/` and `tests/`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase-gate.P3.<timestamp>.md` records one clean pass.

### Phase 4 — Python Consumers

- [ ] [P4-T1] Route `scripts/dev_tools/new_potential_bug_entry.py`, `copy_research_to_issue.py` (`ACTIVE_ISSUE_START_DIR`), `atomic_executor/cli.py` and `atomic_executor/prompt_builder.py` through `development_docs_path`; `atomic_executor/cli_workspace.py` help and `atomic_executor/feature_resolver.py` messages from the resolver.
  - Tests: existing suites unchanged (`test_atomic_executor_cli.py` receives no case, D-P1); one `.dev` case each in `test_new_potential_bug_entry.py` and `test_copy_research_to_issue.py`.
  - Acceptance: affected modules pass.
- [ ] [P4-T2] Route `scripts/dev_tools/pr_context/feature_docs.py`, `render_feature_excerpts.py`, `verification_evidence.py`, `summary_helpers.py` (union) and `collector.py` (add `.dev/` bucket), matching P3-T3.
  - Tests: existing suites unchanged; `.dev` cases in `tests/scripts/dev_tools/pr_context/test_verification_evidence.py`, `tests/scripts/dev_tools/test_feature_docs.py` and `tests/scripts/dev_tools/test_collect_pr_context.py` (collector bucket, summary helper).
  - Acceptance: modules pass.
- [ ] [P4-T3] Route to the union `scripts/dev_tools/epic_planner_readiness.py` (prefixes; manifest and kickoff paths through the resolver), `MANIFEST_RE` in `epic_kickoff_contract.py` and `parallel_kickoff_contract.py`, `POTENTIAL_RECORD_PREFIX` in `_orchestrator_state_issue_adoption.py`, `_LIFECYCLE_PREFIXES` in `_epic_orchestrator_state_resolution.py` and the prefix tuple in `_parallel_orchestrator_state_cohort_barrier.py`; the `validate_evidence_locations.py` hint comes from the resolver.
  - Tests: existing suites unchanged; one in-memory `.dev` case each in `test_epic_planner_readiness.py`, `test_epic_kickoff_contract.py`, `test_parallel_kickoff_contract.py`, `test_orchestrator_state_issue_adoption.py`, `test_epic_cross_dependency_validation.py`, `test_parallel_cohort_barrier_parity.py` and `test_validate_evidence_locations.py`.
  - Acceptance: modules pass; the TypeScript parity suites for these validators pass.
- [ ] [P4-T4] Make `FEATURE_FOLDER_PATH_PATTERN` in `scripts/dev_tools/_orchestrator_state_feature_folder_record.py` accept both roots; `ERROR_FEATURE_FOLDER_PATH_FORMAT` unchanged.
  - Tests: existing cases of `test_orchestrator_state_issue_adoption_feature_folder.py` unchanged; new in-memory case mirroring P3-T5; `test_orchestrator_state_issue_adoption_parity.py` unchanged (D-P11).
  - Acceptance: both modules pass.
- [ ] [P4-T5] Add `.dev/**/*.json` to `GOVERNED_GLOBS` in `scripts/dev_tools/json_config.py`; `EXCLUDE_GLOBS` unchanged (spec amendment A-5).
  - Tests: `test_iter_governed_files_finds_dev_json` in `test_json_config.py` (the `mem_fs_path` fixture, a `.dev/research/x.json` file) and a membership assertion.
  - Acceptance: module passes.
- [ ] [P4-T6] [phase-gate] Run stages 1 to 6 per `## Test Cadence (Mandatory)` over `scripts/`, `.claude/`, `.codex/`, `extensions/drm-copilot/` and `tests/`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase-gate.P4.<timestamp>.md` records one clean pass.

### Phase 5 — PowerShell Consumers (research inventory)

Each hook that imports the module uses the guarded import pattern and Codex hooks follow D-P16; each task writes every copy per the mirror rule.

- [ ] [P5-T1] Route to the union `$script:FeatureFolderPattern` in `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`, `$script:EpicManifestPattern` in `EpicScopeReadiness.psm1`, `$script:LifecyclePrefixes` in `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` and `$script:POTENTIAL_RECORD_PREFIX` in `OrchestratorStateIssueAdoption.psm1`.
  - Tests: existing suites unchanged; one `.dev` case each in `WorktreeTargetResolution.Tests.ps1`, `EpicScopeReadiness.Tests.ps1`, `OrchestratorStateEpicWaveBarrier.Tests.ps1` and `OrchestratorStateIssueAdoption.Tests.ps1`; both `Parity` suites unchanged.
  - Acceptance: suites pass.
- [ ] [P5-T2] Route `$script:FEATURE_FOLDER_PATH_PATTERN` in `.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1` to the union; `$script:ERROR_PATH_FORMAT` unchanged.
  - Tests: new in-memory case in `Describe 'feature_folder_record rule 11a'` of `OrchestratorStateFeatureFolderRecord.Tests.ps1`; `OrchestratorStateIssueAdoption.Parity.Tests.ps1` unchanged.
  - Acceptance: suites pass.
- [ ] [P5-T3] Route to the union `Test-FeatureDocumentationOrEvidencePath` and `Test-OrchestrationReady` in both `enforce-orchestration-preimplementation-gate.ps1`, the exempt prefix list in both `-helpers.ps1`, `Get-EpicOrchestrationReadinessFailure` in both `-modes.ps1`, and `$script:EpicScopeManifestPattern` in `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`.
  - Tests: existing gate suites unchanged; new `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.DevRoot.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-dev-root.Tests.ps1` assert `.dev/active/` and `.dev/epics/` paths are recognized alongside the `docs/features` forms; `enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` and `enforce-orchestration-preimplementation-gate.Parity.Tests.ps1` pass.
  - Acceptance: suites pass.
- [ ] [P5-T4] Route `Test-IsUnderResearchRoot` and the Pre-Mortem applicability check in `Invoke-TaskResearcherOutputValidation` of `.claude/hooks/validate-task-researcher-output.ps1` to both roots and both research roots (`.dev/research/` exempt from the Pre-Mortem as `docs/research/` is); messages unchanged.
  - Tests: cases in `validate-task-researcher-output.Tests.ps1` for `.dev/active/x/research/` and `.dev/research/`; `.PreMortem.Tests.ps1` gains the `.dev/research/` exemption case.
  - Acceptance: the four task-researcher suites pass.
- [ ] [P5-T5] Route `Test-IsValidFeatureFolder` in `.claude/hooks/enforce-completion-helpers.ps1` and its `.codex/hooks/` twin (prefix union, existence against the resolved root), the messages of both `enforce-completion-consistency.ps1` and of `enforce-parallel-cohort-barrier.ps1`, `$script:ActiveFeatureRoot` in `enforce-parallel-drift-gate.ps1` (resolver; a failed resolution denies through the hook's existing fail-closed dependency path with a reason carrying the resolver `Reason`, which P5-T8 asserts), and `ConvertTo-PrdFeatureFolderToken` and `Find-PrdFeatureFolderCandidate` in `enforce-prd-feature-before-planner-helpers.ps1` (union).
  - Tests: existing completion, drift, prd-feature and cohort suites unchanged; `.dev` cases in `enforce-parallel-drift-gate.FolderResolution.Tests.ps1`, `enforce-completion-consistency.Tests.ps1` and `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`; `enforce-completion-consistency-codex.Tests.ps1` passes.
  - Acceptance: suites pass.
- [ ] [P5-T6] Route `Test-IsFeaturePlanPath` in `.claude/hooks/enforce-feature-folder-order.ps1`, the `preflight-fix-record` prefix in `validate-executor-output.ps1`, `Get-ReviewArtifactInfo` in `validate-feature-review-coverage-rules.ps1` and the messages of `validate-feature-review-coverage.ps1` to the union; callers of `feature-folder-resolution.ps1` pass the known-root pattern into `Find-FeatureFolderCandidate` and `ConvertTo-FeatureFolderBasename`, with the byte-identical change in `.codex/hooks/feature-folder-resolution.ps1`.
  - Tests: both `feature-folder-resolution.Tests.ps1` suites gain `.dev` cases and keep twin parity; `.dev` cases in `enforce-feature-folder-order.Tests.ps1` and `validate-feature-review-coverage.Tests.ps1`; `validate-executor-output.Preflight.Tests.ps1` gains a `.dev` record case.
  - Acceptance: suites pass.
- [ ] [P5-T7] Route `.codex/hooks/enforce-epic-planning-only.ps1` (union), `authorize-root-epic-invocation.ps1` (reference regex union; kickoff path from the resolver), `record-subagent-routing-attestation.ps1` (kickoff path), `feature-review-coverage-target.ps1` (`Get-CodexReviewPolicyAuditPath` and `Select-CodexReviewPolicyAudit` union; `AUDIT_NOT_NAMED` unchanged), `.codex/scripts/epic-child-launch-runtime.ps1` (resolver) and `epic-child-launch-contract.ps1` (union; message unchanged).
  - Tests: existing Codex suites unchanged; `.dev` cases in `epic-child-launch-hardening.Tests.ps1` and `feature-review-coverage-target.Tests.ps1`.
  - Acceptance: suites pass.
- [ ] [P5-T8] Add `tests/scripts/claude-hooks/enforce-parallel-drift-gate.DevelopmentDocsRoot.Tests.ps1`: malformed routing JSON and an out-of-set value each make the hook fail closed with a reason containing `config/orchestration-routing.json` and `development_docs_root`, through injected readers.
  - Acceptance: suite passes.
- [ ] [P5-T9] Accept `.dev/` as a whole alongside `docs/` in `Get-DocsOnlyDiffTextViolation` and its path check in `.claude/hooks/hook-docs-only-diff.ps1` and `.codex/hooks/hook-docs-only-diff.ps1` (D-P8, OQ-3; message unchanged).
  - Tests: `.dev/active/x/spec.md` and `.dev/engineering/x.md` cases in both `hook-docs-only-diff.Tests.ps1`; `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` unchanged.
  - Acceptance: suites pass.
- [ ] [P5-T10] Change `ConvertTo-ArtifactSpec` in `.claude/hooks/validate-required-artifact-output.ps1` per D-P2.
  - Tests: existing cases of `validate-required-artifact-output.Tests.ps1` and `.Reentry.Tests.ps1` unchanged; a new case parses the contracted `spec-path` spec and matches `.dev/active/x/spec.md`.
  - Acceptance: suites pass.
- [ ] [P5-T11] Make `scripts/dev-tools/new-potential-entry.ps1` and `extensions/drm-copilot/resources/templates/new-potential-entry.ps1` byte-identical (D-P3) with `-DevelopmentDocsRoot` (`ValidateSet` of the two roots, default `docs/features`) for the potential target, template and backlog paths; add the same parameter to `scripts/dev-tools/link-feature-docs.ps1`.
  - Existing tests: `new-potential-entry.Tests.ps1` Describe blocks and its static-text cases are unchanged (the unified text keeps every asserted function, parameter and block, including the guarded `Get-AuthorName` that `falls back to USERNAME environment variable when git is unavailable` needs); `new-potential-entry.TemplateRoot.Tests.ps1` existing cases unchanged; `.vscode/tasks.json`, the promotion hook suites and the push-down rewrite tests assert only the file name and are unchanged.
  - New tests: `tests/scripts/dev-tools/new-potential-entry.CopyParity.Tests.ps1` (equal SHA-256 of the two copies); `.dev` and bundled-copy (`Get-Location` mocked) cases in `new-potential-entry.TemplateRoot.Tests.ps1`; a `.dev` case in `link-feature-docs.Tests.ps1`.
  - Acceptance: the four suites pass.
- [ ] [P5-T12] Add `tests/fixtures/orchestrator_state_issue_adoption/valid-large-waives-feature-folder-dev-root.json` (keys `name`, `notes`, `checkpoint`, `expected_errors`; `name` equals the stem; modeled on `valid-large-waives-feature-folder-with-record.json` with checkpoint `feature-folder` and record `path` `.dev/active/2026-09-29-sample-feature-509`; `expected_errors` empty).
  - Tests: `orchestrator-state-issue-adoption-parity.test.ts`, `test_orchestrator_state_issue_adoption_parity.py` and `OrchestratorStateIssueAdoption.Parity.Tests.ps1` are unchanged in source; each discovers one file more (above `MINIMUM_CORPUS_COUNT`; the on-disk count check holds) and reports no error for it.
  - Acceptance: the three parity suites pass.
- [ ] [P5-T13] [phase-gate] Run stages 1 to 6 per `## Test Cadence (Mandatory)` over `scripts/`, `.claude/`, `.codex/`, `extensions/drm-copilot/` and `tests/`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase-gate.P5.<timestamp>.md` records one clean pass.

### Phase 6 — PowerShell Consumers (refresh inventory)

- [ ] [P6-T1] Route `Test-EpicMergeGateReviewFeatureFolder` in `.claude/hooks/enforce-epic-merge-gate-review.ps1` and its `.codex/hooks/` twin to every member of `Get-DevelopmentDocsKnownRoot` (D-P16; `Unresolved` detail unchanged); both `enforce-epic-merge-gate.ps1` import the module with the guarded pattern.
  - Tests: a `.dev/active/x` case in `tests/scripts/codex-hooks/enforce-epic-merge-gate-review.Tests.ps1`; `enforce-epic-merge-gate.ReviewGuard.Tests.ps1`, `.ReviewPaths.Tests.ps1` and `hook-dependency-guard-completeness.Tests.ps1` pass unchanged.
  - Acceptance: suites pass; the file stays under 800 lines.
- [ ] [P6-T2] Route `Get-EpicFanInStatusDocRelativePath` (a declared status path is accepted under either root; with none, the `docs/features` form is derived) and `Get-EpicMergedFeatureRoots` (prefix strip and roots under both roots) in both `hook-epic-fan-in.ps1`; both `enforce-orchestration-preimplementation-gate-epic-scope.ps1` import the module.
  - Tests: `.dev` cases in `tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1`; `enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1`, `.MergedFollowUp.Tests.ps1`, `.EpicScopeHelperParity.Tests.ps1` and the Codex `-epic-fan-in` and `-merged-follow-up` suites pass unchanged.
  - Acceptance: suites pass.
- [ ] [P6-T3] Route `Get-EpicCrossDependencyPrerequisitePr` (union) and `Read-EpicCrossManifestText` (resolver) in `.claude/lib/epic-wave/EpicCrossDependency.psm1`, importing the sibling module with `-ErrorAction Stop`.
  - Tests: `.dev` cases in `EpicCrossDependency.Tests.ps1`; `EpicCrossDependency.Adapters.Tests.ps1` and the stored-mirror case of `test_push_down_codex_and_agents_virtual_paths.py` pass.
  - Acceptance: suites pass.
- [ ] [P6-T4] Route in `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` the template paths and the path in `Get-ParallelAdmissionRecordedEdge` (resolver), and the `-RunFolder` check of `Get-ParallelAdmissionUsageError` and the slug strip of `Invoke-ParallelAdmissionRecord` (union); usage text unchanged.
  - Tests: `.dev` run-folder cases in `Invoke-ParallelAdmission.Tests.ps1`; `.Integration.Tests.ps1` and `.PrecedenceGate.Tests.ps1` unchanged.
  - Acceptance: suites pass.
- [ ] [P6-T5] Route `$script:FeatureRoot`, `$script:PotentialRoot`, `$script:PotentialTemplate` and `$script:ActiveFolderPattern` with `Test-ReviewVerdictFeatureFolder`, `Test-ReviewVerdictRecordsOnlyPath`, `Test-ReviewVerdictRecordsPrPath` and `Get-ReviewVerdictPromotionPrDecision` in `.claude/lib/review-verdict/ReviewVerdictEligibility.psm1` to the union, keeping the matched root; details unchanged.
  - Tests: `.dev` cases in `ReviewVerdictEligibility.Review.Tests.ps1` and `.PullRequest.Tests.ps1`; `ReviewVerdict.Manifest.Tests.ps1` passes.
  - Acceptance: suites pass.
- [ ] [P6-T6] Resolve the default `EvidenceRoot` of `scripts/dev-tools/Get-StageTimingReport.ps1` from `Resolve-DevelopmentDocsRoot` (throw on a failed resolution), adding no parameter and no function.
  - Tests: `STR-ENTRY-HAS-NO-PARAMETER-OTHER-THAN-ROOT-AND-NO-FUNCTIONS` and the other `Get-StageTimingReport.Tests.ps1` cases unchanged; new AST case `STR-ENTRY-DEFAULT-ROOT-FROM-RESOLVER` asserts the default branch calls `Resolve-DevelopmentDocsRoot`.
  - Acceptance: suite passes.
- [ ] [P6-T7] [phase-gate] Run stages 1 to 6 per `## Test Cadence (Mandatory)` over `scripts/`, `.claude/`, `.codex/`, `extensions/drm-copilot/` and `tests/`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase-gate.P6.<timestamp>.md` records one clean pass.

### Phase 7 — Write-Scope Literal Contract (D-16)

- [ ] [P7-T1] Create `extensions/drm-copilot/src/lib/development-docs/write-scopes.ts` with the types, rule tables and expansion functions of spec `## Write-scope literal contract (D-16)`; add its `coverageThreshold` entry.
  - Tests: new `test/lib/development-docs/write-scopes.test.ts` asserts every rule-table row and both example outputs.
  - Acceptance: suite passes; threshold met.
- [ ] [P7-T2] Add the `.dev` literal beside each contracted literal (same leading-slash spelling) in the `tools:` lists of `.claude/agents/` `atomic-planner.md`, `task-researcher.md`, `prd-feature.md`, `feature-review.md`, `status-updater.md`, `epic-review.md`, `epic-planner.md`, `epic-orchestrator.md`, `parallel-orchestrator.md`, `parallel-planner.md`; replace the `prd-feature` and `epic-review` `-RequiredArtifact` patterns with the expanded union patterns; write the ten bundle copies; re-baseline the `.claude/agents/epic-orchestrator.md` digest in `PINNED_FROZEN_SURFACE_HASHES` with a dated `RE-BASELINED by issue #1035` comment stating only the `tools:` list changed.
  - Tests: `test_feature_review_agent_grants_mcp_artifact_validator` expected tuple gains `Write(/.dev/active/**)` after the `docs/features` entry; `test_parallel_planner_surface_contracts.py`, `checkpoint-hygiene-skill-contract.Tests.ps1` and `test_parallel_orchestrator_permission_contracts.py` use containment and are unchanged.
  - Acceptance: those suites, `test_parallel_orchestrator_surface_contracts.py` and `test_push_down_claude_resource_contracts.py` pass.
- [ ] [P7-T3] Add `Edit(.dev/**)` after `Edit(docs/**)` in `permissions.allow` of `.claude/settings.json` and its bundle copy.
  - Acceptance: `claude-settings.Tests.ps1` and the resource contract pass.
- [ ] [P7-T4] Add the `.dev` literals to `.codex/agents/atomic-planner.toml`, `prd-feature.toml`, `feature-review.toml`, `status-updater.toml` and `epic-review.toml` and their bundle copies; run `scripts/dev_tools/generate_codex_agent_variants.py` once and then with `--check`.
  - Acceptance: the check exits 0 reporting no drift; `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py` and `test_push_down_codex_and_agents_resource_contracts.py` pass.
- [ ] [P7-T5] Add `test/lib/development-docs/write-scopes.contract.test.ts` implementing the three directions of spec `### Checker test (three directions)`; reverse coverage maps Codex variant files (`-c1` to `-c4`, `-c3-elevated`) to their base agent; reads use forward-slash repository-relative paths.
  - Acceptance: passes, and fails when one `.dev` literal is removed locally (observation recorded in the P9-T6 artifact).
- [ ] [P7-T6] [phase-gate] Run stages 1 to 6 per `## Test Cadence (Mandatory)` over `scripts/`, `.claude/`, `.codex/`, `extensions/drm-copilot/` and `tests/`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase-gate.P7.<timestamp>.md` records one clean pass, including the generator check.

### Phase 8 — CI Docs-Only Scope, Brief and Blast Radius

- [ ] [P8-T1] Add the include prefixes `.dev/active/`, `.dev/archive/`, `.dev/completed/`, `.dev/epics/`, `.dev/parallel/`, `.dev/potential/`, `.dev/research/` and the exclude prefix `.dev/potential/template.md` to `config/ci-docs-only-paths.json` (D-P15).
  - Changed behavior, asserting tests in `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`: `starts every include prefix with docs/ (AC-15)` becomes docs/ or .dev/; `configures exactly the D3 include prefixes and extensions (AC-15)` gains the seven `.dev` prefixes; `does not let any include prefix cover <Path>` gains `.dev/templates/`, `.dev/engineering/`, `.dev/discovery/`; `lists <Prefix> as an exclude prefix` gains `.dev/potential/template.md`; new rows call `Test-CiDocsOnlyPath` for `.dev/active/x/spec.md` (docs-only) and `.dev/templates/x.md`, `.dev/potential/template.md`, `.dev/engineering/x.md`, `.dev/discovery/x.md` (not). `CiChangeScope.Tests.ps1`, `Invoke-CiChangeScope.Tests.ps1`, `Invoke-CiChangeScopeMergeBase.Tests.ps1` and `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` unchanged.
  - Acceptance: the five suites pass.
- [ ] [P8-T2] Update the execution-environment brief in all six byte-identical copies (`.claude/skills/`, `.agents/skills/`, `.github/skills/` and their bundle copies): the allowlist sentence of `## CI Shape and Required Checks` lists the `.dev` prefixes and exclusion, and the post-fan-in and merged-feature follow-up item of `## Hook Execution Context` names the `.dev` forms; update `### Allowlist` under `## Change-Scope Decision (Issue #962)` in `.github/workflows/README.md`.
  - Acceptance: six copies hash equal; `test_execution_environment_brief_contracts.py`, `parallel-gate-wording.Tests.ps1`, `planning-contract-wording.Tests.ps1`, `test-cadence-wording.Tests.ps1` and `ProcessReductionChain.Ledger.Tests.ps1` pass.
- [ ] [P8-T3] Route `$script:FeatureFolderRoot` (resolver) and `$script:FeatureFolderPrefix` (union) in `.claude/lib/blast-radius/BlastRadius.psm1`, `$script:FeatureCorpusPrefix` in `BlastRadiusTokenShape.psm1` and `Test-FeatureFolderGlob` in `BlastRadiusWriteIntent.psm1` (union), with their bundle copies.
  - Tests: existing blast-radius suites unchanged; `.dev` cases in `BlastRadius.Tests.ps1`, `BlastRadiusTokenShape.Tests.ps1` and `BlastRadiusWriteIntent.Tests.ps1`.
  - Acceptance: suites and resource contracts pass.
- [ ] [P8-T4] Apply the same routing to `FEATURE_FOLDER_ROOT` and `FEATURE_FOLDER_PREFIX` in `scripts/dev_tools/compute_blast_radius.py`, `FEATURE_CORPUS_PREFIX` in `_blast_radius_token_shapes.py` and `_FEATURE_FOLDER_PREFIX` in `_blast_radius_write_intent.py`.
  - Tests: existing suites and `blast_radius_parity_test_support.py` parity unchanged; `.dev` cases in `test_blast_radius_token_shapes.py` and `test_blast_radius_write_intent.py`.
  - Acceptance: suites pass.
- [ ] [P8-T5] [phase-gate] Run stages 1 to 6 per `## Test Cadence (Mandatory)` over `scripts/`, `.claude/`, `.codex/`, `extensions/drm-copilot/` and `tests/`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase-gate.P8.<timestamp>.md` records one clean pass.

### Phase 9 — Final QA, Evidence and Self-Review

- [ ] [P9-T1] Run the residual search, including untracked files (a plain recursive search or `git grep --untracked`, so files this plan creates are searched before they are committed), over `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts` and `extensions/drm-copilot/src` for `docs/features`, the separator regex form, the escaped-slash regex form of `MANIFEST_RE` and `FEATURE_FOLDER_PATH_PATTERN` (matched by the regular expression `docs.{1,2}features`, which needs no backslash literal), the Python split form `"docs" / "features"`, the TypeScript split form `"docs", "features"`, and the part-index forms `parts[1] === "features"` and `parts[1] == "features"`.
  - Acceptance: `<FEATURE>/evidence/other/residual-search.<timestamp>.md` records the commands, output and the Stay allowlist (resolver constants, prose and help citations, `build_discovery_runtime.py` `RESOURCE_ROOTS`, `scripts/dev_tools/pr_context/render.py,cover`, the Python `EXCLUDE_GLOBS` entry, and the ten Stay rows of D-P13); every hit is on the allowlist.
- [ ] [P9-T2] Verify the scope boundary: no `.dev/` path exists (porcelain status and a tree listing), `development_docs_root` is `docs/features` in all three copies, no folder under `docs/features/` is renamed (a name-status diff with rename detection from the merge base shows no rename row), no new file under `scripts/` or `tests/scripts/dev_tools/` with a `.py` suffix, no `pyproject.toml` change, no file under `docs/engineering/process-reductions/` changed, and no Closes, Fixes or Resolves line for #1016.
  - Acceptance: `<FEATURE>/evidence/other/scope-boundary.<timestamp>.md` all PASS.
- [ ] [P9-T3] Run Black in check mode, Ruff and Pyright over `scripts/dev_tools/` and `tests/scripts/dev_tools/` (configuration in `pyproject.toml`); restart from formatting on any failure or fix.
  - Acceptance: `<FEATURE>/evidence/qa-gates/python-static.<timestamp>.md` records exit 0 and finding count per tool and Black's unchanged-files summary.
- [ ] [P9-T4] Run the Python gate once (configuration in `pyproject.toml`, suites under `tests/scripts/dev_tools/`): `pytest -n auto` with line and branch coverage and a JSON report under `SCRATCH`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/python-tests.<timestamp>.md` records zero failures and the repo-wide and per-file line and branch percentages of `## Coverage Targets`.
- [ ] [P9-T5] Run Prettier in check mode, lint and typecheck in `extensions/drm-copilot/`; restart on any failure or fix.
  - Acceptance: `<FEATURE>/evidence/qa-gates/typescript-static.<timestamp>.md` with exit 0 and finding count per tool.
- [ ] [P9-T6] Run the Jest gate in `extensions/drm-copilot/` once with coverage; record the P1-T4 and P7-T5 negative observations.
  - Acceptance: `<FEATURE>/evidence/qa-gates/typescript-tests.<timestamp>.md` records zero failures, every `coverageThreshold` met, and per-file line and branch percentages of `## Coverage Targets` from `extensions/drm-copilot/coverage/lcov.info`.
- [ ] [P9-T7] Run the PoshQC format check (no-op `-WriteFile` form of P0-T6) and the direct analyzer run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`; restart on any finding.
  - Acceptance: `<FEATURE>/evidence/qa-gates/powershell-static.<timestamp>.md` records no `Formatted:` line (every file logs `Already formatted:`) and zero Error and Warning findings.
- [ ] [P9-T8] Run the Pester gate over `tests/scripts/` once: one `Invoke-PoshQCParallelTest` from `scripts/powershell/PoshQC/PoshQC.psd1`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/powershell-tests.<timestamp>.md` records `ExitCode` 0, zero failures from the merged JUnit file and line coverage of each PowerShell file in `## Coverage Targets` from the merged coverage XML.
- [ ] [P9-T9] Run the order-dependence check `Invoke-PoshQCLeakScan -Root` (from `scripts/powershell/PoshQC/PoshQC.psd1`, allowlist `config/poshqc-leak-allowlist.json`) through the launcher route of the brief, and the check mode of `scripts/dev_tools/generate_codex_agent_variants.py`.
  - Acceptance: `<FEATURE>/evidence/regression-testing/leak-scan.<timestamp>.md` records exit 0 for both; a finding is fixed on both sides (leaker and victim) and P9-T8 re-runs.
- [ ] [P9-T10] Compare per file and repo-wide the P9-T4, P9-T6 and P9-T8 figures with the `Phase 0 baseline` artifacts under `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/evidence/baseline/`, and report changed-line coverage from the merge-base diff hunks.
  - Acceptance: `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md` shows no new failing test, no per-file or repo-wide drop, new files at or above 85% line (75% branch for Python and TypeScript), changed lines at or above 85%.
- [ ] [P9-T11] Record physical line counts of every new or changed production and test file against the tiers and `config/file-size-baseline.json`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/file-size.<timestamp>.md` shows none above 800 and lists any at or above 700; `FileSizePolicy.RepoGate.Tests.ps1` passed in P9-T8.
- [ ] [P9-T12] Walk the policy-audit, code-review and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base, including every changed-behavior test disposition and Recorded Decision.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` has one PASS, FAIL or N/A row per checklist item and no FAIL row (a FAIL is fixed, the QA loop re-run and the review rewritten).

## Coverage Targets

- Python (each prefixed `scripts.dev_tools`): `json_config`, `new_active_feature_folder_flow`, `new_active_feature_folder_io`, `new_potential_bug_entry`, `potential_to_issue`, `potential_to_issue_content`, `copy_research_to_issue`, `atomic_executor.cli`, `atomic_executor.prompt_builder`, `atomic_executor.cli_workspace`, `atomic_executor.feature_resolver`, `plan_progress_report`, `pr_context.feature_docs`, `pr_context.render_feature_excerpts`, `pr_context.verification_evidence`, `pr_context.summary_helpers`, `pr_context.collector`, `epic_planner_readiness`, `epic_kickoff_contract`, `parallel_kickoff_contract`, `_orchestrator_state_issue_adoption`, `_orchestrator_state_feature_folder_record`, `_epic_orchestrator_state_resolution`, `_parallel_orchestrator_state_cohort_barrier`, `resolve_execute_plan_prompt`, `resolve_file_prompt`, `validate_evidence_locations`, `push_down_codex_and_agents_customizations`, `compute_blast_radius`, `_blast_radius_token_shapes`, `_blast_radius_write_intent`.
- TypeScript: new `src/lib/development-docs/root.ts`, `feature-folder-name.ts`, `write-scopes.ts`, and every `src/` file edited in Phases 1 to 3.
- PowerShell: `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` and every PowerShell file edited in Phases 5, 6 and 8.

## Language Choices

| Artifact | Language | Reason |
| --- | --- | --- |
| Resolver, parser, write-scope modules and checker | TypeScript, no `vscode` import | MCP tools and extension commands consume them; child 3 imports the rule table |
| PowerShell resolver module | PowerShell | hooks and libs are PowerShell; hooks never invoke Python |
| Python resolver and parser | Python, in place in `scripts/dev_tools/json_config.py` | existing Python consumers read the key; no new Python file (owner rule) |
| Python tests | existing modules only (AD-3) | no new Python file |
| Hook and lib consumers | PowerShell | existing files |
| Configuration and agent literals | JSON, Markdown, TOML | existing files |

## Pre-Mortem

- Review checklists: a reviewer finds a consumer still hard-coding `docs/features` or a changed message; the P9-T1 residual search with its allowlist, the byte-identical-message invariant, the spec rule traceability below, and P9-T12 over all three templates prevent it.
- Coverage: new TypeScript files lack thresholds or a per-file figure drops; P1-T2, P1-T3 and P7-T1 add `coverageThreshold` entries, Python figures come from the JSON report of the one gate run, Pester line coverage from the merged coverage XML, and P9-T10 compares each gate with its `Phase 0 baseline`.
- Mirror parity: each editing task writes every bundle copy, Codex twin and Codex source copy (mirror rule); P5-T11 adds a hash test for the two `new-potential-entry.ps1` copies; P1-T10 and P1-T11 publish the module; P7-T4 runs the generator and its check; P7-T2 re-baselines the frozen hash in the same task; and P8-T2 updates the execution-environment brief in all six byte-identical copies, because this plan changes the docs-only allowlist and the post-fan-in allowance facts the brief states.
- File size: P0-T1 records files at or above 500 lines; `enforce-epic-merge-gate-review.ps1` (near 700) gains only a call change because its import lands in `enforce-epic-merge-gate.ps1`; new logic lives in new modules; Python tests avoid `test_atomic_executor_cli.py`; P9-T11 confirms none above 800.
- Test isolation: resolvers take injected readers in all runtimes and no test reads the real routing file or probes for `.dev`; the gates are one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run and Jest through its normal parallel workers, each re-run only after a fix; P9-T9 runs `Invoke-PoshQCLeakScan`, and any order dependence is fixed on both sides.
- CI-only behavior: the checker and `.dev` fixtures use forward-slash relative paths with no drive letters; no test diffs against `origin/main`; Codex hook suites run on the Linux job, so new cases use `Join-Path` and exact case; the allowlist change itself triggers a full CI run.
- Evidence: every artifact sits under `<FEATURE>/evidence/<kind>/` with Timestamp, Command, EXIT_CODE and Output Summary, a clock-read write-time stamp, append-only; no host path or scratchpad path is recorded.

## Spec Rule Traceability

Each row names the implementing task and the test that fails if the rule breaks. Case titles carry the rule ID.

| Spec rule, parameter or boundary | Task | Failing test |
| --- | --- | --- |
| R-1 to R-8, each R-4 input, errors naming file, key and value | P1-T2, P1-T5, P1-T7 | `root.test.ts`, `test_json_config.py`, `DevelopmentDocsRoot.Tests.ps1` (case `R-<n>`) |
| OQ-1 (absent key, no `.dev` probe) | P1-T2, P1-T5, P1-T7 | the `R-2` cases assert the directory probe is not called |
| PowerShell typed failure (`Succeeded`, `Reason`) | P1-T7 | `R-3` and `R-4` cases of `DevelopmentDocsRoot.Tests.ps1` |
| Area map rows under both roots; unknown-area error | P1-T2, P1-T5, P1-T7 | per-area and `unknown area` cases in the three resolver suites |
| Known-root prefixes; pattern with both separators; known roots in order | P1-T2, P1-T5, P1-T7 | prefix, pattern and known-root cases in the three suites |
| F-1 to F-6; N-1 to N-5; formatter padding, date-prefix strip, trailing-issue removal | P1-T3, P1-T6, P1-T8 | `feature-folder-name.test.ts`, `test_json_config.py`, `DevelopmentDocsRoot.Tests.ps1` |
| No `vscode` import in `src/lib/development-docs/` | P1-T4 | `no-vscode-import.test.ts` (negative observation in P9-T6) |
| `json_config` imports nothing from `scripts.dev_tools` | P1-T5 | `test_json_config_imports_no_dev_tools_module` |
| Issue-supplied folder `<NNNN>-<feature>`; issue-less slug (OQ-4); epic `<epics area>/<slug>` | P2-T1, P2-T2 | `io.test.ts`, `flow.test.ts` (`createActiveFolder epic creation (single home)`), `test_new_active_feature_folder.py` |
| Writers under `.dev` when configured and present, else `docs/features` | P2-T1, P2-T3, P3-T1 | `.dev` cases of `flow.test.ts`, `promotion.test.ts`, `new-potential-bug-entry.test.ts` |
| Status line `Promoted -> <active area>/<NNNN>-<feature>/` and D-P6 fallback | P2-T3, P2-T4 | `promotion.test.ts`, `content.test.ts`, `test_potential_to_issue.py`, `test_potential_to_issue_content.py` |
| Parser delegation (D-P14) | P2-T5, P2-T6 | issue-first cases of `file-prompt-variables.test.ts`, `test_resolve_execute_plan_prompt.py`, `test_resolve_file_prompt.py`, `test_plan_progress_report.py` |
| Matchers accept the union independent of the configured value | P3-T3 to P3-T5, P4-T2 to P4-T4, P5-T1 to P5-T7, P6-T1 to P6-T5, P8-T3, P8-T4 | the `.dev` case named in each task |
| Feature-folder record validators accept both roots | P3-T5, P4-T4, P5-T2, P5-T12 | the in-memory cases and the three parity suites |
| Gate and researcher matchers (`.dev/active/`, `.dev/epics/`, `.dev/research/`) | P5-T3, P5-T4 | `enforce-orchestration-preimplementation-gate.DevRoot.Tests.ps1`, the Codex `-dev-root` suite, `validate-task-researcher-output.Tests.ps1` |
| Fail-closed hook reason naming file and key | P5-T8 | `enforce-parallel-drift-gate.DevelopmentDocsRoot.Tests.ps1` |
| `hook-docs-only-diff.ps1` treats `.dev/` as a whole (OQ-3) | P5-T9 | both `hook-docs-only-diff.Tests.ps1` |
| `new-potential-entry.ps1` parameter, default and equal copies; root passed by the service | P5-T11, P3-T2 | `new-potential-entry.CopyParity.Tests.ps1`, `new-potential-entry.TemplateRoot.Tests.ps1`, `repo-automation-service.new-potential-entry-root.test.ts` |
| Refresh-inventory consumers (A-2) | P5-T7, P6-T1 to P6-T6, P9-T1 | the `.dev` case named in each task; the residual-search allowlist |
| CI docs-only include prefixes, `.dev/potential/template.md` exclude, non-docs-only `.dev` areas (OQ-3, A-3) | P8-T1 | `CiDocsOnlyPathsConfig.Tests.ps1` rows |
| Brief and workflow README state the allowlist | P8-T2 | `test_execution_environment_brief_contracts.py` (`test_brief_copies_are_byte_identical`) |
| `GOVERNED_GLOBS` gains `.dev/**/*.json` | P3-T6, P4-T5 | `json-config.test.ts`, `test_iter_governed_files_finds_dev_json` |
| Dot-folder constant and each `RealFileSystem.glob` consumer; `isExcludedDirectoryName(".dev")` | P3-T6 | `file-system.test.ts` and the five consumer suites; `claude-blast-radius-derive.test.ts` |
| D-16 types, rule-table rows and example outputs | P7-T1 | `write-scopes.test.ts` |
| Literal-set rule and the three checker directions | P7-T2 to P7-T5 | `write-scopes.contract.test.ts` (negative observation in P9-T6) |
| `-RequiredArtifact` union patterns parse and match | P5-T10, P7-T2 | `validate-required-artifact-output.Tests.ps1` new case; checker root coverage |
| Frozen-surface re-baseline with dated comment | P7-T2 | `test_parallel_orchestrator_surface_contracts.py` |
| Module copies, publication entry, pack manifests, tier entry | P1-T7 to P1-T11 | `ClaudeLibModuleConvention.Tests.ps1`, `test_push_down_codex_and_agents_virtual_paths.py`, manifest completeness and closure tests, `test_quality_tiers_contract_classification.py` |
| Hooks never invoke Python | all PowerShell tasks | `enforcement-hooks-no-python-invocation.Tests.ps1` |
| Scope boundary (no `.dev/`, default key, no rename, no migration, no new Python file) | P9-T2 | the scope-boundary checks of P9-T2 |

## Acceptance Criteria Traceability

Spec criteria are numbered in document order (S-1 to S-42). User-story criteria, numbered in document order, map as follows: maintainer U-1 to S-1, U-2 to S-2 to S-4, U-3 to S-8, U-4 to S-9, U-5 to S-10, U-6 to S-12, U-7 to S-17, U-8 to S-16, U-9 to S-21, U-10 to S-22 to S-24, U-11 to S-36 to S-39, U-12 to S-41 and S-42; destination U-13 to S-2 to S-4, U-14 to S-15, U-15 to S-28, U-16 to S-25 and S-26, U-17 to S-40; generator U-18 to S-31, U-19 to S-32, U-20 to S-33, U-21 to S-34 and S-35.

| AC | Tasks |
| --- | --- |
| S-1 routing key | P1-T1 |
| S-2 to S-4 resolver R-1 to R-8 | P1-T2, P1-T5, P1-T7 |
| S-5, S-6 area map, prefixes, pattern | P1-T2, P1-T5, P1-T7 |
| S-7 no `vscode` | P1-T4 |
| S-8 Python in place, no Python hook | P1-T5, P1-T6, P9-T2, P9-T8 |
| S-9 full suites, limited expectation changes | P2-T1 to P2-T4, P9-T4, P9-T6, P9-T8 |
| S-10 residual search | P9-T1 |
| S-11 `.dev` writes | P2-T1, P2-T3, P3-T1 |
| S-12 record validators | P3-T5, P4-T4, P5-T2, P5-T12 |
| S-13 gate and researcher matchers | P5-T3, P5-T4 |
| S-14 `new-potential-entry.ps1` | P5-T11, P3-T2 |
| S-15 fail-closed hook | P5-T8 |
| S-16 refresh-inventory consumers | P5-T7, P6-T1 to P6-T6, P9-T1 |
| S-17, S-18 CI docs-only config and suites | P8-T1 |
| S-19 `hook-docs-only-diff.ps1` | P5-T9 |
| S-20 brief and workflow README | P8-T2 |
| S-21 `GOVERNED_GLOBS` | P3-T6, P4-T5 |
| S-22 to S-24 dot-folder handling | P3-T6 |
| S-25, S-26 parser cases | P1-T3, P1-T6, P1-T8 |
| S-27 parser delegation | P2-T5, P2-T6 |
| S-28, S-29 folder creation and epics | P2-T1, P2-T2 |
| S-30 status line | P2-T3, P2-T4 |
| S-31 to S-35 write-scope contract | P7-T1 to P7-T5, P5-T10 |
| S-36 to S-39 mirrors, manifests, Codex | P1-T7 to P1-T11, P5-T1 to P5-T11, P6-T1 to P6-T5, P8-T2, P8-T3 |
| S-40 scope boundary | P9-T2 |
| S-41 coverage thresholds | P9-T4, P9-T6, P9-T8, P9-T10 |
| S-42 toolchain and file size | P1-T12, P2-T7, P3-T7, P4-T6, P5-T13, P6-T7, P7-T6, P8-T5, P9-T3 to P9-T11 |

## Size Justification

This child is one cross-runtime contract change: one configured key read by about 100 production consumers in three runtimes (the research inventory plus the seven routed refresh-inventory files), with mirrors, a write-scope contract and CI scope. The owner decided the child is not split. Each task covers one consumer group with its tests so that each binary outcome stays checkable, and the current contract adds a `[phase-gate]` task to each of eight phases; the result is 82 canonical tasks (above the legacy guideline of 40 for this plan stamp) in about 403 physical lines (above the legacy 400 by the traceability tables that the design check requires). The Codex generator run counts as one task (P7-T4).

## Open Questions / Notes

- OQ-1, OQ-3, OQ-4 and OQ-5 of `spec.md` are applied as recorded there; package version bumps are not part of this child (extension and MCP stay at 1.2.3 until epic fan-in).
- Hook registration runs through one PreToolUse dispatcher per runtime (`.claude/hooks/pretooluse-dispatch.json` and its Codex twin); this plan adds no hook and changes no registration, only module imports inside existing hooks.
- Whether `.dev` records are excluded from Python JSON governance is left to child 7 with the flip (spec amendment A-5).
