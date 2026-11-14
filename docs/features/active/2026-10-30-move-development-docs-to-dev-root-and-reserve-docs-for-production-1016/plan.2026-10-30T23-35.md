# 2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production - Plan (Stage B)

- **Issue:** #1016 (epic #1018 child 7, wave 4)
- **Parent (optional):** epic #1018 (`docs/features/epics/shared-agent-harness-layer/epic.md`)
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14 (planning refresh under OD-1; replaces the revision that cleared preflight on 2026-10-31)
- **Status:** Draft (stage B, post-decision)
- **Version:** 1.0
- **Work Mode:** full-feature
- **Branch:** `feature/dev-docs-root-migration-phases-2-3-1016`
- **Stage:** B (Phase 3 of #1016: apply, rename, flip, dependent updates). Stage A is `plan.2026-10-30T18-59.md` in the same folder; its tool contract (`REPORT_CATEGORIES`, `SUMMARY_COUNTS`, `CONSUMED_CHOICES`, `RECORD_ONLY_KEYS`, `REQUIRED_CHOICE_CONDITIONS`, the `kept` list, the retained-production-docs category) is consumed unchanged.

## Required References

Policy files are plain paths, not relative links, because this plan moves during its own execution: `.github/instructions/general-code-change.instructions.md`, `general-unit-test.instructions.md`, and the Python, PowerShell and TypeScript code-change and unit-test instruction files in the same folder. Tool routes, the test-execution launcher, command-text restrictions, the batch budget, hook context and CI shape are owned by the `execution-environment` skill and are not restated.

## Scope and Conventions

- Requirements: `spec.md` (`### Stage B — post-decision plan (Phase 3: move, rename, flip, updates)`, `## Behavior`, `## Decision File`, `## Language Classification`, `## Execution Preconditions`, `## Contract Tests`, `## Orchestrator Rulings (preparation)` R1 to R6, `## Owner Decisions (preparation)` H2, `## Autonomous Decisions (planning refresh 2026-11-14, OD-1)` A1 to A15, `## Acceptance Criteria` -> `### Stage B — move, rename and flip` and `### Epic-level criteria owned by this child`), `user-story.md` scenarios (c) and (d), research sections 4 to 9 and 11.
- Execution split (ruling R5): run 1 executes [P0-T1] through [P2-T5] and ends after the checkpoint handoff record; the orchestrator then updates the checkpoint; run 2 executes [P3-T1] through [P5-T7] against the plan at its post-move path.
- Owner-answer branches are closed by A2 to A14. Remaining halts: H2 (a `commit_split` other than `single` halts at [P0-T2] with `BLOCKED: owner-answer-commit-split-halt` and the H2 re-approval message), ruling R2 (a `remove_fallback` of `remove` or an `extension_command` of `yes` halts at [P0-T2] with `BLOCKED: owner-answer-re-plan`), and the [P1-T3] stops.
- Orchestrator-owned, not plan tasks: the decision file (A14), the precondition record, the checkpoint path update between runs, `stage_timing` evidence (`<FEATURE>/evidence/other/stage-timing.<timestamp>.json`, `orchestrate` skill), the OD-1 relay and records, commits after run 1, and the push.
- Test cadence follows `## Test Cadence (Mandatory)` of the `atomic-plan-contract` skill: a task check after each task (`<FEATURE>/evidence/other/task-check.P<N>-T<M>.<timestamp>.md`; the Pester selection runs through the launcher `pester` suite with `-TestPath`), and each `[phase-gate]` task records `<FEATURE>/evidence/qa-gates/phase-gate.P<N>.<timestamp>.md`. Gates are parallel-only: one `Invoke-PoshQCParallelTest`, one `pytest -n auto`, Jest through its normal workers, each through the test-execution launcher, one suite at a time, re-run only after a fix; no serial, single-process, shuffled or reversed run; integration and golden lanes run in CI only. A launcher exit 75 is a queue timeout and the gate is re-run.
- Evidence: `<FEATURE>/evidence/<kind>/<name>.<timestamp>.md` stamped with the UTC write time read from the clock; a consumer selects the lexicographically greatest match; append-only; each command artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`; no absolute path or host name; scratch locations are recorded as the token `SCRATCH`.

## Terms and Defined Sets

Each set is defined once here and named identically wherever it is used.

- `OLD_FEATURE` = `docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016`. `NEW_FEATURE` = `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production`, or `.dev/active/<target>` when `DECISIONS` renames `OLD_FEATURE` to another target. `<FEATURE>` is `OLD_FEATURE` through the `TOOL` call of [P2-T2] and `NEW_FEATURE` afterwards; the plan file moves with it.
- `SCRATCH` resolves to `<session scratchpad>/issue-1016/`; scratch file names start with `issue-1016-`; launchers, derived decision files and coverage reports live there.
- `INTEGRATION` = `origin/epic/shared-agent-harness-layer-integration`. `BASE` = the merge base of `INTEGRATION` and `HEAD`, computed when the task runs (ruling R6); the `origin/main` re-check uses the merge base of `origin/main` and `HEAD`. No commit identifier is written in this plan.
- `TOOL` = the branch build `packages/mcp-server/out/mcp-server.js` run with the `migrate-development-docs` subcommand from a `sh` launcher under `SCRATCH` (A8), built by [P1-T1] through the stage A route.
- `DECISIONS` = the lexicographically greatest `<FEATURE>/evidence/other/folder-rename-decisions.*.json`, written by the orchestrator (A14) and always passed by explicit path. `FRESH_DRY_RUN` = the newest `dev-docs-migration-dry-run.*.json` written by [P1-T1]. `RENAME_MAP` = the mechanical renames of `FRESH_DRY_RUN` plus every `rename` entry of `DECISIONS`.
- `DECIDED_VALUES` (the twelve `global_decisions` strings the orchestrator writes from A2 to A12): `discovery_templates_target` `.dev/discovery/templates`; `in_tree_rewrite_scope` `links-only`; `commit_split` `single`; `absent_key_resolves` `docs/features`; `discovery_runtime_resource_key` `keep`; `rules_mirrors_editable` `no`; `remove_fallback` `no`; `run_source` `branch-build`; `allow_list_tool` `none`; `extension_command` `no`; `file_size_excluded_segment` `no`; `plan_template_link_depth` `three-level`.
- `HELD_RULE` (A13): a held item with reason `non-matching` takes `rename` to its `candidate`; every item with reason `multi-folder-issue`, `formatter-error` or `collision` takes `keep`; `kept` folders need no entry.
- `MAPPING_PREFIXES` = `docs/features/`, `docs/research/`, `docs/engineering/`, `docs/discovery/`. `PRODUCTION_ROOTS` = `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`, `extensions/drm-copilot/src`.
- `LEDGER_FALLBACK_ROWS` = `docs/features/templates/` to `.dev/templates/`, and `docs/engineering/` to `.dev/engineering/` (the only `docs/` prefixes the stored patches and revert blocks name at planning time).
- `LEDGER_PINNED` = the files derived by [P1-T2]: each path the ledger chain reads (`Read-ProcessReductionChainInput`) outside the ledger folder, where a stored-patch hunk's post-image lines (context included) or a revert block's `Current` text contains a `MAPPING_PREFIXES` occurrence, or contains a relative Markdown link whose source or target moves.
- `FROZEN_SURFACES` = the paths of `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (`.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`).
- `REWRITE_EXCLUSIONS` (the required `rewrite_exclusions` members): (1) `tests/fixtures/**` (R3); (2) `**/evidence/**` and `docs/engineering/process-reductions/**` (A3); (3) mapping records: the promoted record, this feature's spec, user story, research and plans, child 2's spec, research and plan; (4) fallback-support surfaces: child 2's resolver and matcher modules and their tests (child 2's merged file list), `config/ci-docs-only-paths.json` and `CI_SCOPE_SUITES`; (5) A6 policy Stay: `.claude/rules/*.md`, `.github/instructions/*.md`, their bundle copies and generator sources; (6) the six execution-environment brief copies and `.github/workflows/README.md`; (7) A5: `packages/discovery-runtime/**` and `scripts/dev_tools/build_discovery_runtime.py`; (8) A15: `scripts/dev-tools/ProcessReductionChain.psm1`, `scripts/dev-tools/ProcessReductionLedger.psm1`, `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1`, `FROZEN_SURFACES` and every `LEDGER_PINNED` file; (9) the `exclude` rows of [P1-T3]; closed under copies: every mirror, bundle copy or generated output of a member, and the generator source of a generated member, that a `CONTRACT_TESTS` suite compares with it.
- `STAY_ENTRIES` = the `REWRITE_EXCLUSIONS` files inside `PRODUCTION_ROOTS` plus child 2's recorded Stay rows; the allowlist of [P4-T5].
- `CI_SCOPE_SUITES` = `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`, `CiChangeScope.Tests.ps1`, `Invoke-CiChangeScope.Tests.ps1`, `Invoke-CiChangeScopeMergeBase.Tests.ps1`, `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`.
- `CONTRACT_TESTS` = spec `## Contract Tests` (the execution-environment brief `## Contract Tests That Pin Mirrored Files` list plus the extra modules it names), `CI_SCOPE_SUITES`, the five `ProcessReduction*.Tests.ps1` suites, `planning-contract-wording.Tests.ps1`, `review-verdict-skill-contract.Tests.ps1`, `hook-docs-estate-context.Parity.Tests.ps1` and `hook-docs-only-diff.InitWorkflowParity.Tests.ps1`.
- `HAND_EDIT_TARGETS` = every file a task of Phases 1 and 3 edits by hand. `UPDATE_SET` = every test that a Phase 3 task names as updated, plus the tests of the `manual` rows of [P1-T3].

## Language Classification

Owner rule (epic `## Shared Design`): no new Python; existing Python edited in place only; pushed-down code is PowerShell or bash; TypeScript only for MCP tools and extension commands; hooks never invoke Python.

| Planned artifact | Language | Rule status |
| --- | --- | --- |
| Moves, renames, prefix rewrites, link recomputation (stage A tool, run from the branch build) | TypeScript, unchanged | conforms |
| `Read-ProcessReductionChainInput` legacy read fallback in `scripts/dev-tools/ProcessReductionChain.psm1` | existing PowerShell, in place | conforms |
| Canonical-input source mapping in `scripts/dev_tools/build_discovery_runtime.py`; `resolve_default_template_root` in `scripts/dev_tools/discovery/init_models.py` | existing Python, in place | conforms (A5 premise correction below) |
| Routing config (three copies), `config/blast-radius.json`, epic manifest, template bundle copy, brief copies | JSON, Markdown | not code |
| Test updates (Jest, Pytest, Pester) | existing test files | conforms |
| `sh` launchers and derived decision files under `SCRATCH` | shell, JSON | not committed |

A5 premise correction: `RESOURCE_ROOTS` in `build_discovery_runtime.py` is both the repository source root and the approval prefix of the staged member key, and `resolve_default_template_root` joins `docs`, `discovery` and `templates` as segments, so A2's move cannot hold without an in-place Python edit. The plan keeps A5's intent (resource key, staged `_resources/**` bytes, `init_projection.py` and the package version unchanged) with the two in-place edits of [P3-T7].

## Ledger Decision (A15)

Branch: move. `docs/engineering/process-reductions/` moves with `docs/engineering/` and every ledger file stays byte-identical (exclusion member 2). The Stay branch is rejected because the tool contract has no move exclusion (a Stay folder needs stage A reopened) and because the stored patches name `docs/features/templates/**` paths that move under D-6 wherever the ledger lives. No ledger entry or stored patch is edited. The chain passes through two measures: [P1-T5] adds a read-only fallback that reads a recorded path absent from the tree from its `LEDGER_FALLBACK_ROWS` location while keeping the recorded key, and `REWRITE_EXCLUSIONS` keeps every `LEDGER_PINNED` file and `FROZEN_SURFACES` byte-identical, because re-baselining a `PINNED_FROZEN_SURFACE_HASHES` digest is an edit inside the `0010` stored-patch hunk.

| Ledger test | Disposition |
| --- | --- |
| `ProcessReductionChain.Ledger.Tests.ps1` (`PRC-LEDGER-CHAIN-HOLDS`, `PRC-LEDGER-END-STATE-RECORDED`, `PRC-README-REVERT-ORDER-STATED`, `PRC-LEDGER-SUBCHAIN-HOLDS`, `PRC-LEDGER-NO-EXCEPTIONS`) | README path literal tool-rewritten; passes through the fallback and the exclusions; the oracle in every gate |
| `ProcessReductionChain.Tests.ps1` | excluded (in-memory keys equal the module default); `PRC-READ-COLLECTS-INPUT` unchanged; fallback cases added in [P1-T5] |
| `ProcessReductionLedger.Tests.ps1`, `ProcessReductionLedger.Replay.Tests.ps1`, `ProcessReductionLedger.Index.Tests.ps1` | tool-rewritten real-folder reads and skill token; a class `X` row in [P1-T3] when the token mirrors a `LEDGER_PINNED` copy |
| `ReviewVerdictEligibility.PullRequest.Tests.ps1` "refuses the listing" | tool-rewritten together with `ReviewVerdictEligibility.psm1` |
| `review-verdict-skill-contract.Tests.ps1`, `planning-contract-wording.Tests.ps1` | tool-rewritten with their surfaces, or class `X` in [P1-T3] |

## Existing Tests Asserting Changed Behavior

| Test | Disposition |
| --- | --- |
| `test_orchestration_routing_config_parity.py` `test_canonical_and_bundled_routing_config_are_byte_identical` (compares two copies) | unchanged; [P3-T2] flips all three and compares the third directly |
| `test_blast_radius_config_tolerance_keys.py` `test_self_hosted_path_roots_match_pinned_directory_list` | updated in [P3-T3] |
| `test_class_two_bundled_path_roots_are_empty`; `BlastRadius.KeyPartition.Tests.ps1` "declares an empty bundled path_roots list" | unchanged (R1) |
| `test_single_pass_preflight_contracts.py` `test_plan_templates_carry_premortem_skeleton` | fails after the apply (feature link recomputed in the moved template only); passes after [P3-T4] |
| `test_single_pass_preflight_contracts.py` `test_contract_requires_final_phase_self_review` | tool-rewritten with the contract copies, or class `X` in [P1-T3] |
| `test_parallel_orchestrator_surface_contracts.py` `test_frozen_epic_surface_matches_pinned_baseline_digest` | unchanged (`FROZEN_SURFACES` excluded) |
| `SECTION_OBLIGATION_CASES` case `kickoff-feature-folder-and-issue-number` (`KICKOFF_IDENTITY_FRAGMENTS`) | tool-rewritten with `.claude/skills/parallel-orchestrate/SKILL.md`; a `manual` row in [P1-T3] when the expectations file is `LEDGER_PINNED` |
| `test_execution_environment_brief_contracts.py` `test_brief_copies_are_byte_identical`, `test_architecture_doc_lists_brief` | unchanged; [P3-T8] edits six copies identically |
| `claude-architecture-doc.Tests.ps1` (segment-joined `'docs'`, `'engineering'`) | updated in [P3-T6] |
| `test_discovery_documentation_contracts.py` `DOC`, `test_handoff_reconciles_the_built_artifacts`, `test_handoff_carries_no_stale_installed_host_limit` (glob `*-980`) | updated in [P3-T6] |
| `discovery/test_init_models.py` `test_resolve_default_template_root_returns_expected_path` | updated in [P3-T7] |
| `test_build_discovery_runtime.py`, `test_build_discovery_runtime_io.py` | case added in [P3-T7]; existing cases unchanged |
| `discovery/test_domain_neutrality.py` `_TEMPLATE_ROOT`; `tests/discovery_runtime/test_package_contract.py` | tool-rewritten real read; class `X` against the excluded package |
| `test_blast_radius_write_intent.py` `FOLDER_GLOB`, `test_write_intent_fixture_reproduces_expected_radius` | class `X` (R3); requires an explicit `docs/features` root pin ([P1-T3] stops if absent) |
| `test_parallel_issue_adoption_skill_contracts.py` `test_rule_doc_states_origin_conditional_potential_record` | class `X` against `.claude/rules/orchestrator-state.md` (A6) |
| `test_new_potential_bug_entry.py` `test_create_bug_entry_falls_back_to_workspace_when_no_template_root` | classified in [P1-T3]; edited in [P3-T6] when `manual` |
| Readers of the repository routing config that assert the resolved root (child 2's folder-creation and promotion suites) | class `R` rows of [P1-T3]; updated in [P3-T2] |
| `CI_SCOPE_SUITES`; `hook-docs-estate-context.Parity.Tests.ps1`; `hook-docs-only-diff.InitWorkflowParity.Tests.ps1` | unchanged (A1: the docs-estate hooks and `.claude/lib/docs/` hold no `MAPPING_PREFIXES` occurrence at planning; `config/ci-docs-only-paths.json` excluded) |

## Execution Preconditions

- Spec `## Execution Preconditions` applies: children 1 to 6 and 8 to 10 merged into `INTEGRATION`; stage A complete; no wait on the closed parallel run `bugs-1001-1002-1003-1006` or #1013.
- The orchestrator writes `<FEATURE>/evidence/other/stage-b-preconditions.<timestamp>.md` recording, each `PASS` or `FAIL`: no open pull request touches `docs/features/**` or the spec overlap files (its `gh` query and result); the item worktree runs without isolation; `artifacts/orchestration/orchestrator-state.json` there selects the `large` route and is not terminal.
- The orchestrator writes `DECISIONS` with `DECIDED_VALUES`, `HELD_RULE` decisions and `REWRITE_EXCLUSIONS` globs. [P1-T4] stops when a required member is missing; the orchestrator then writes a superseding decision file with a later stamp and resumes at [P0-T2].

## Commit and Check-off Protocol ([P2-T1], [P2-T3])

Apply mode refuses while tracked files have uncommitted changes. Each commit task checks itself off before staging, commits with a message file under `SCRATCH`, then requires `git status --porcelain --untracked-files=no` to print nothing. No task writes a tracked change between [P2-T1] and the `TOOL` call of [P2-T2]. A refused or failed commit reverts the task's own check-off, leaves other changes in place and stops with `BLOCKED: commit-denied`; a failed commit never reverses the apply.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Execution Gate and Baselines

- [ ] [P0-T1] Verify the execution preconditions after a fetch of `origin`: the newest `stage-b-preconditions.*.md` records every field `PASS`; each child of spec `## Execution Preconditions` has a pull request merged into `INTEGRATION`; when `INTEGRATION` is not an ancestor of `HEAD`, merge it without editing the message (a conflict aborts and stops); `.claude/skills/test-execution-policy/scripts/run-test-suite.sh` and `config/test-execution-policy.json` exist; stage A is present (`extensions/drm-copilot/src/lib/development-docs-migration/`, `migrate_development_docs` in `REPO_AUTOMATION_TOOLS`, `extensions/drm-copilot/src/migrate-development-docs-cli.ts`, a `stage-a-handoff.*.md` and its dry-run JSON).
  - Acceptance: `<FEATURE>/evidence/baseline/stage-b-gate.<timestamp>.md` lists each item `PASS`; any failure stops with `BLOCKED: stage-b-precondition` before any edit.
- [ ] [P0-T2] Check `DECISIONS` against spec `## Decision File`: `version` 1; `dry_run_report` names an existing stage A JSON; `source_digest` present; `global_decisions` equal `DECIDED_VALUES`; `decisions` equal `HELD_RULE` applied to that JSON's held items. Halts before any edit: `commit_split` other than `single` writes `<FEATURE>/evidence/other/commit-split-halt.<timestamp>.md` and stops with `BLOCKED: owner-answer-commit-split-halt` and the H2 message "Re-run the migration dry run and approve a new decision file before stage B continues."; `remove_fallback` `remove` or `extension_command` `yes` stops with `BLOCKED: owner-answer-re-plan` (R2); any other difference stops with `BLOCKED: decision-file-mismatch`.
  - Acceptance: `<FEATURE>/evidence/baseline/decision-file-check.<timestamp>.md` records the selected file name, one `PASS` row per key and the held-item count with zero mismatches.
- [ ] [P0-T3] Re-check `## Citation Register` on `HEAD`; child 2's exports (`parseFeatureFolderName`, `formatFeatureFolderName`, `stripDateFirstPrefix`, `developmentDocsPath`, `resolveDevelopmentDocsRoot`, `KNOWN_DEVELOPMENT_DOCS_ROOTS`) against child 2's spec signatures and child 2's recorded Stay allowlist evidence; the child 3 generator inventory (each generator, its sources, outputs and check form; a `HAND_EDIT_TARGETS` member that is a generated output stops); A1 coexistence (`docs/documentation-estate/` absent; `.claude/lib/docs/`, `hook-docs-estate-context.ps1` and `hook-docs-only-diff.ps1` with no `MAPPING_PREFIXES` occurrence); the overlap files changed upstream per ref from each merge base; the physical line count of every `HAND_EDIT_TARGETS` file.
  - Acceptance: `<FEATURE>/evidence/baseline/tree-recheck.<timestamp>.md` holds one `PRESENT`/`MOVED` row per register entry, one `MATCH`/`DIFFERS` row per export, the generator inventory and the counts; any `MOVED`, `DIFFERS`, generated hand-edit target or docs-estate occurrence stops with `BLOCKED: re-plan-required`.
- [ ] [P0-T4] Capture the static baselines: TypeScript (Prettier check, `lint`, `typecheck`, dependency-cruiser), Python (Black check, Ruff, Pyright) and PowerShell (formatter check, `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` run directly).
  - Acceptance: one artifact per step, `<FEATURE>/evidence/baseline/<language>-<step>.<timestamp>.md`, with the four fields and the finding count; pre-existing drift is listed, not repaired.
- [ ] [P0-T5] Run the `Phase 0 baseline` Jest gate once with coverage through the launcher `jest` suite over `extensions/drm-copilot/test/`.
  - Acceptance: `<FEATURE>/evidence/baseline/ts-test-coverage.<timestamp>.md` records the `Test Suites:` and `Tests:` pass and fail counts, the totals and the per-file line and branch coverage summary (kept under `SCRATCH` for [P5-T5]).
- [ ] [P0-T6] Run the `Phase 0 baseline` pytest gate once through the launcher `pytest` suite with `-n auto --cov=scripts --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1016-coverage-baseline.json`.
  - Acceptance: `<FEATURE>/evidence/baseline/py-test-coverage.<timestamp>.md` records pass and fail counts, the `TOTAL` percentage and the JSON line and branch totals.
- [ ] [P0-T7] Run the `Phase 0 baseline` Pester gate once through the launcher `pester` suite (`Invoke-PoshQCParallelTest` from `scripts/powershell/PoshQC/PoshQC.psd1`).
  - Acceptance: `<FEATURE>/evidence/baseline/ps-test-coverage.<timestamp>.md` records `ExitCode`, pass and fail counts and per-file line coverage from the sources the `execution-environment` skill names, copied to `SCRATCH` for [P5-T5].

### Phase 1 — Pre-Apply Derivations and Ledger Read Fallback

- [ ] [P1-T1] Build `TOOL` through the stage A route, then run it in `dry-run` mode with `DECISIONS` and `report_directory` `OLD_FEATURE/evidence/other`; compare `source_digest` in `FRESH_DRY_RUN` with `DECISIONS`.
  - Acceptance: the report pair exists; `<FEATURE>/evidence/baseline/digest-comparison.<timestamp>.md` records both digests and `MATCH`, zero unmapped entries and the retained-documentation list; a mismatch stops with `BLOCKED: source-digest-mismatch`, a non-zero unmapped count with `BLOCKED: unmapped-entry`.
- [ ] [P1-T2] Derive `LEDGER_PINNED` over `docs/engineering/process-reductions/` from `Read-ProcessReductionChainInput` in `scripts/dev-tools/ProcessReductionChain.psm1`, `Get-ProcessReductionPatchHunk` and `Get-ProcessReductionLanding` run read-only from a `SCRATCH` launcher; check that every chain path under `docs/` starts with a `LEDGER_FALLBACK_ROWS` prefix; intersect `LEDGER_PINNED` with `HAND_EDIT_TARGETS` at the region level.
  - Acceptance: `<FEATURE>/evidence/other/ledger-pinned.<timestamp>.md` lists each pinned file with its entry, hunk or block and the matched occurrence; an uncovered `docs/` path or a hand edit inside a recorded region stops with `BLOCKED: re-plan-required` naming the entry and path.
- [ ] [P1-T3] Derive the divergent-literal rows: candidates are the tracked test files outside `tests/fixtures/` that a `git grep -l -E` over `tests` and `extensions/drm-copilot/test` lists for `docs/(features|research|engineering|discovery)/`, plus segment-joined and glob readers (`'docs'` or `"docs"` joined with an area, globs such as `*-980`). Classify each literal by the root its production code resolves: `R` (repository config or real files: `tool-rewritten`, or `manual` when segment-joined), `I` (injected `docs/features` root: `exclude`), `A` (absent key resolves `docs/features` under A4: `exclude`), `X` (compared with text of a `REWRITE_EXCLUSIONS` file, or with a production result another test compares with such text: `exclude`), `H` (hard-coded production root outside `STAY_ENTRIES`: stop); a module with mixed classes is `exclude` plus `manual`. Name rows for `test_blast_radius_write_intent.py` (record whether its tests pin a `docs/features` root explicitly), `test_parallel_issue_adoption_skill_contracts.py`, `test_new_potential_bug_entry.py`, `test_package_contract.py` and the five ledger suites.
  - Acceptance: `<FEATURE>/evidence/other/divergent-literal-derivation.<timestamp>.md` records the commands, their output and one row per candidate with class and disposition; every `manual` row names [P3-T6]; an `H` row, an `X` row whose compared production result resolves the configured root, or an absent write-intent root pin stops with `BLOCKED: re-plan-required`.
- [ ] [P1-T4] Check that `DECISIONS` `rewrite_exclusions` plus the tool's built-in exclusions cover every `REWRITE_EXCLUSIONS` member, with the package paths re-derived by `git ls-files packages/discovery-runtime`.
  - Acceptance: `<FEATURE>/evidence/other/rewrite-exclusion-coverage.<timestamp>.md` lists each member with its matching glob; an unmatched member stops with `BLOCKED: exclusion-amendment-required`.
- [ ] [P1-T5] In `scripts/dev-tools/ProcessReductionChain.psm1`, add the internal function `Resolve-ProcessReductionLivePath` (a recorded repository-relative path that is absent is read from its `LEDGER_FALLBACK_ROWS` location; a present path, or one no row matches, is returned unchanged) and use it in `Read-ProcessReductionChainInput` for the ledger root and each live read, keeping every `LiveText` key and the `LedgerPath` default unchanged. Add to `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1`: "PRC-READ-FALLBACK-MOVED-TEMPLATE" (absent `docs/features/templates/x.md` read from `.dev/templates/x.md` under the recorded key), "PRC-READ-FALLBACK-LEDGER-ROOT" (ledger read from `.dev/engineering/process-reductions` with entry keys under `docs/engineering/process-reductions/`), "PRC-READ-FALLBACK-BOTH-ABSENT" (`$null`).
  - Existing tests: `PRC-READ-COLLECTS-INPUT` unchanged (its mocked paths exist or match no row); the other `ProcessReductionChain.Tests.ps1` cases and `ProcessReductionChain.Ledger.Tests.ps1` unchanged (the fallback triggers only for absent paths).
  - Acceptance: the task-check Pester run of both files reports 0 failed with the three new cases passing.
- [ ] [P1-T6] [phase-gate] Run stages 1 to 6 across the repository per `## Test Cadence (Mandatory)`, writing `<FEATURE>/evidence/qa-gates/phase-gate.P1.<timestamp>.md`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase-gate.P1.<timestamp>.md` records one clean pass with 0 failed per gate, including `ProcessReductionChain.Ledger.Tests.ps1`.

### Phase 2 — Apply and Handoff (end of run 1)

- [ ] [P2-T1] Commit the pre-apply state under the protocol: `OLD_FEATURE/plan.2026-10-30T23-35.md`, `DECISIONS`, the Phase 0 and Phase 1 evidence under `OLD_FEATURE/evidence/`, and the [P1-T5] edits to `scripts/dev-tools/ProcessReductionChain.psm1` and its test.
  - Acceptance: `git status --porcelain --untracked-files=no` prints nothing after the commit.
- [ ] [P2-T2] Run `TOOL` in `apply` mode with `rename_decisions_path` `OLD_FEATURE/evidence/other/<DECISIONS basename>` and `report_directory` `SCRATCH/apply-1/`, then copy the report pair into `<FEATURE>/evidence/other/` with its names unchanged.
  - Acceptance: exit 0; `NEW_FEATURE/plan.2026-10-30T23-35.md` exists and `OLD_FEATURE` does not; the copied report lists the moves, renames, rewritten files with occurrence counts, protected occurrences and untracked files; a refusal stops with `BLOCKED: apply-refused` and its reason.
- [ ] [P2-T3] Commit the apply result under the protocol: `git add -u`, `docs/README.md` when created, and `<FEATURE>/evidence/`.
  - Acceptance: `<FEATURE>/evidence/other/apply-commit.<timestamp>.md` records the `R100`, other `R`, `A`, `M` and `D` counts of `git diff -M --name-status HEAD~1 HEAD` (`R100` above zero) and that `git status --porcelain` lists no tracked change.
- [ ] [P2-T4] [phase-gate] Run stages 1 to 6, writing `<FEATURE>/evidence/qa-gates/phase-gate.P2.<timestamp>.md`. The unit stage passes when every failing test is in `UPDATE_SET` and every other test passes; an auto-fix restarts the loop.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase-gate.P2.<timestamp>.md` lists each failing test with its `UPDATE_SET` task, and 0 failures outside `UPDATE_SET`, `ProcessReductionChain.Ledger.Tests.ps1` included.
- [ ] [P2-T5] Write the checkpoint handoff record `<FEATURE>/evidence/other/checkpoint-path-handoff.<timestamp>.md` (ruling R5): old and new `<FEATURE>`, old and new plan path, the moved `DECISIONS` path and the apply commit identifier from `git rev-parse HEAD`, stating that the orchestrator updates the checkpoint feature-folder fields before run 2.
  - Acceptance: `<FEATURE>/evidence/other/checkpoint-path-handoff.<timestamp>.md` holds the six values; run 1 reports complete at this task.

### Phase 3 — Flip and Dependent Updates (run 2)

- [ ] [P3-T1] Verify the orchestrator-written `<FEATURE>/evidence/other/checkpoint-path-update.*.md` (newest) records checkpoint feature-folder fields equal to `NEW_FEATURE`.
  - Acceptance: the record exists and names `NEW_FEATURE`; absence stops with `BLOCKED: checkpoint-path-update-pending`.
- [ ] [P3-T2] Set `development_docs_root` to `.dev` in `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json` and `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json`; update the class `R` rows of [P1-T3] that assert the resolved root to expect `.dev`.
  - Acceptance: the three copies are byte-identical (compared directly); `test_canonical_and_bundled_routing_config_are_byte_identical` and every updated reader pass in the task check; no `exclude` row file is edited.
- [ ] [P3-T3] Insert `.dev` into `path_roots` of `config/blast-radius.json` between `.codex` and `.devcontainer` and into `PINNED_SELF_HOSTED_PATH_ROOTS` in `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py`; leave the bundle copy's empty `path_roots` (R1).
  - Acceptance: `test_self_hosted_path_roots_match_pinned_directory_list`, `test_class_two_bundled_path_roots_are_empty` and "declares an empty bundled path_roots list" pass.
- [ ] [P3-T4] Make each bundle copy under `extensions/drm-copilot/resources/feature-templates/` byte-identical to its moved `.dev/templates/<kind>/plan.yyyy-MM-ddTHH-mm.md`, so the feature template carries the three-level `.github/instructions/` links (A11).
  - Acceptance: `test_plan_templates_carry_premortem_skeleton` passes; `<FEATURE>/evidence/other/template-link-check.<timestamp>.md` records that each `.github/instructions/` link resolved from `.dev/active/<folder>/` names an existing file.
- [ ] [P3-T5] In `.dev/epics/shared-agent-harness-layer/epic.md` front matter, set each `feature_folder` value that names a folder in `RENAME_MAP` to its renamed basename (child 2 included).
  - Acceptance: `<FEATURE>/evidence/other/epic-manifest-check.<timestamp>.md` records each changed value and that it names a directory under `.dev/active`, `.dev/completed` or `.dev/archive`; `test_epic_kickoff_contract.py` passes.
- [ ] [P3-T6] Apply the `manual` rows of [P1-T3]: in `claude-architecture-doc.Tests.ps1` build the document path from `.dev` and `engineering` with `Join-Path`; in `test_discovery_documentation_contracts.py` join `DOC` from `.dev` and `engineering` and locate the issue 980 handoff by `0980-*/handoff.md` across `.dev/active`, `.dev/completed` and `.dev/archive`; edit every other listed literal (including `test_new_potential_bug_entry.py` and the `KICKOFF_IDENTITY_FRAGMENTS` entry when listed) to the root its test resolves.
  - Acceptance: `<FEATURE>/evidence/other/manual-literal-edits.<timestamp>.md` lists each edited file and test with 0 failures in the task check.
- [ ] [P3-T7] A5 premise correction: in `scripts/dev_tools/build_discovery_runtime.py` read canonical inputs keyed under `docs/discovery/templates` from `.dev/discovery/templates` (keys, `RESOURCE_ROOTS`, staged members and `resource-manifest.json` unchanged), with the case `test_canonical_template_inputs_read_from_moved_source_directory` in `tests/scripts/dev_tools/test_build_discovery_runtime_io.py`; in `scripts/dev_tools/discovery/init_models.py` return `.dev/discovery/templates` from `resolve_default_template_root`, with `test_resolve_default_template_root_returns_expected_path` updated.
  - Acceptance: both modules' suites, `test_domain_neutrality.py` and `test_package_contract.py` pass; the build script's verification mode reports no drift; `packages/discovery-runtime` shows no change against `BASE`.
- [ ] [P3-T8] Update the execution-environment brief (`.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md` and their bundle copies under `extensions/drm-copilot/resources/`) where a stated fact changed: for each brief bullet naming a `MAPPING_PREFIXES` path and citing a production file, compare the literal with that file after the apply, and edit the six copies identically outside every recorded ledger region; when no fact changed, record `no change`.
  - Acceptance: `<FEATURE>/evidence/other/brief-fact-check.<timestamp>.md` lists each bullet, the cited file and `UNCHANGED` or `UPDATED`; `test_brief_copies_are_byte_identical`, `test_brief_ci_section_names_jobs_and_required_contexts` and `documentation-workflow.CommitStage.Tests.ps1` pass.
- [ ] [P3-T9] [phase-gate] Run stages 1 to 6 with the key at `.dev` in `config/orchestration-routing.json`, including every generator check of the [P0-T3] inventory.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase-gate.P3.<timestamp>.md` records one clean pass with 0 failed in each gate and each generator check exit 0.

### Phase 4 — Post-Apply Verification

This phase writes evidence only and carries no `[phase-gate]` task; a fix found here restarts at [P3-T9].

- [ ] [P4-T1] Verify the layout and A1: the top-level entries of `git ls-files .dev` are `potential`, `active`, `completed`, `archive`, `epics`, `parallel`, `templates`, `research`, `engineering`, `discovery` and `backlog.md`; `git ls-files docs` lists only `docs/README.md` (no docs profile here); `docs/README.md` contains the token `production`.
  - Acceptance: `<FEATURE>/evidence/other/layout-check.<timestamp>.md` records both listings and `PASS` per condition.
- [ ] [P4-T2] Compare the folder names under `.dev/active`, `.dev/completed` and `.dev/archive` with those `RENAME_MAP` and the `keep` and `kept` entries predict, and the names under `.dev/potential`, `.dev/epics`, `.dev/parallel` and `.dev/research` with their pre-move names; counts come from `FRESH_DRY_RUN`.
  - Acceptance: `<FEATURE>/evidence/other/folder-rename-comparison.<timestamp>.md` records expected and observed counts and zero mismatches.
- [ ] [P4-T3] Verify that every `REWRITE_EXCLUSIONS` file kept its bytes: `git diff -M --name-status BASE HEAD` shows each one only as `R100`, as an `A` line added on this branch, or not at all, with `git status --porcelain` recorded; `tests/fixtures`, the ledger folder and `FROZEN_SURFACES` show no `M` line.
  - Acceptance: `<FEATURE>/evidence/other/exclusion-integrity.<timestamp>.md` records zero excluded files with an `M` or inexact `R` line.
- [ ] [P4-T4] Ruling R4: derive `SCRATCH/post-apply/issue-1016-post-apply-decisions.json` from the moved `DECISIONS` (`decisions` empty; each `rewrite_exclusions` glob mapped through the spec mapping table, longest prefix first, then `RENAME_MAP`), place a copy of `FRESH_DRY_RUN` beside it, and run `TOOL` in `dry-run` mode with `report_directory` `<FEATURE>/evidence/other`; compare its broken-link list with `FRESH_DRY_RUN` mapped through `RENAME_MAP`.
  - Acceptance: `<FEATURE>/evidence/other/post-apply-dry-run-check.<timestamp>.md` records zero moves, zero renames, zero rewrite candidates under `links-only` outside the mapped exclusions, an unchanged protected-occurrence count, and zero links broken by the move.
- [ ] [P4-T5] Search `PRODUCTION_ROOTS` (`.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`, `extensions/drm-copilot/src`) with `git grep -n -E` for `docs.(features|research|engineering|discovery)` and for `["']docs["']`, and classify every match against `STAY_ENTRIES` and child 2's resolver constants and matcher unions.
  - Acceptance: `<FEATURE>/evidence/other/production-root-search.<timestamp>.md` records the commands, the output, the allowlist and zero unclassified matches.

### Phase 5 — Final QA Loop and Self-Review

A failure or auto-fix restarts at [P5-T1]; all Phase 5 artifacts come from one clean pass.

- [ ] [P5-T1] Run the static stages per language: TypeScript in `extensions/drm-copilot/` (Prettier check, `lint`, `typecheck`, dependency-cruiser), Python (Black check, Ruff, Pyright), PowerShell (formatter check, `Invoke-ScriptAnalyzer` direct run).
  - Acceptance: `<FEATURE>/evidence/qa-gates/ts-static.<timestamp>.md`, `py-static.<timestamp>.md` and `ps-static.<timestamp>.md` record each step with exit 0 and 0 findings; Prettier prints `All matched files use Prettier code style!`, Black prints `would be left unchanged` with no `would reformat`, Pyright prints `0 errors`.
- [ ] [P5-T2] Run the Jest gate once with coverage through the launcher `jest` suite over `extensions/drm-copilot/test/`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/ts-test-coverage.<timestamp>.md` records 0 failed, the totals, per-file coverage and child 2's write-scope checker suite under `extensions/drm-copilot/test/lib/development-docs/` passing all three directions.
- [ ] [P5-T3] Run the pytest gate once through the launcher `pytest` suite with `-n auto --cov=scripts --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1016-coverage-final.json`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/py-test-coverage.<timestamp>.md` records 0 failed, the `TOTAL` percentage, the JSON totals and the `CONTRACT_TESTS` Python modules passing.
- [ ] [P5-T4] Run the Pester gate once through the launcher `pester` suite, including `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/ps-test-coverage.<timestamp>.md` records `ExitCode` 0, 0 failed and per-file line coverage, with the `CONTRACT_TESTS` Pester suites passing.
- [ ] [P5-T5] Compare coverage: hand-edited production files (`scripts/dev-tools/ProcessReductionChain.psm1`, `scripts/dev_tools/build_discovery_runtime.py`, `scripts/dev_tools/discovery/init_models.py`) meet 85% line and, for Python and TypeScript, 75% branch; files changed only by the tool show no per-file drop against the Phase 0 baselines; no language total drops.
  - Acceptance: `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md` lists baseline and final values per file and per total with zero violations; a missing value makes the outcome remediation-required.
- [ ] [P5-T6] Record scope, size and decisions: `git diff --name-status BASE HEAD` with `git status --porcelain` shows no added `.py` file; every changed production, test and script file is at most 800 lines and no `config/file-size-baseline.json` entry grew; one row per OQ-1 to OQ-13 and A1 to A15 names the implementing task or `no change` and its test or evidence.
  - Acceptance: `<FEATURE>/evidence/qa-gates/scope-size-decisions.<timestamp>.md` records zero new `.py` files, zero files above 800 and no blank decision row.
- [ ] [P5-T7] Self-review: walk the policy-audit, code-review and feature-audit templates under `.dev/templates/policy_audit/` and every stage B criterion of `spec.md` against the diff from `BASE` plus `git status --porcelain`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` has one PASS, FAIL or N/A row per item and no FAIL row; a FAIL is fixed, the loop restarts at [P5-T1], and the file is rewritten.

## Citation Register

Re-checked by [P0-T3].

- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`: `PINNED_FROZEN_SURFACE_HASHES`, `KICKOFF_IDENTITY_FRAGMENTS`, `SECTION_OBLIGATION_CASES`. `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`: `test_frozen_epic_surface_matches_pinned_baseline_digest`.
- `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py`: `PINNED_SELF_HOSTED_PATH_ROOTS`, `test_self_hosted_path_roots_match_pinned_directory_list`, `test_class_two_bundled_path_roots_are_empty`; `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`.
- `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`: `test_canonical_and_bundled_routing_config_are_byte_identical`; the three `orchestration-routing.json` copies.
- `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py`: `test_plan_templates_carry_premortem_skeleton`, `test_contract_requires_final_phase_self_review`; `docs/features/templates/<kind>/plan.yyyy-MM-ddTHH-mm.md` and `extensions/drm-copilot/resources/feature-templates/<kind>/plan.yyyy-MM-ddTHH-mm.md`.
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`: `test_brief_copies_are_byte_identical`, `test_brief_ci_section_names_jobs_and_required_contexts`, `test_architecture_doc_lists_brief`.
- `scripts/dev-tools/ProcessReductionChain.psm1`: `Read-ProcessReductionChainInput`, `Get-ProcessReductionMappedSource`, `Get-ProcessReductionPatchHunk`, `Get-ProcessReductionLanding`; `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1` `PRC-READ-COLLECTS-INPUT`; `ProcessReductionChain.Ledger.Tests.ps1`.
- `scripts/dev_tools/build_discovery_runtime.py`: `RESOURCE_ROOTS`, `ResourceAllowlist`; `scripts/dev_tools/discovery/init_models.py`: `resolve_default_template_root`.
- `tests/scripts/dev_tools/test_discovery_documentation_contracts.py`: `DOC`, `test_handoff_reconciles_the_built_artifacts`, `test_handoff_carries_no_stale_installed_host_limit`; `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`.
- `tests/scripts/dev_tools/test_blast_radius_write_intent.py` `FOLDER_GLOB`; `test_parallel_issue_adoption_skill_contracts.py` `test_rule_doc_states_origin_conditional_potential_record`; `test_new_potential_bug_entry.py` `test_create_bug_entry_falls_back_to_workspace_when_no_template_root`.
- `.claude/hooks/hook-docs-estate-context.ps1`, `.claude/hooks/hook-docs-only-diff.ps1`, `.claude/lib/docs/`, `config/ci-docs-only-paths.json`.
- Consumed, not yet on this branch: child 2's resolver exports and Stay allowlist evidence (#1035), child 3's generators, child 10's (#1051) docs tools, stage A's tool and dry-run JSON.

## Pre-Mortem

- Review checklists: a reviewer finds a stale `docs/` literal or a broken link; [P4-T5] classifies every production-root match against `STAY_ENTRIES`, [P4-T4] proves zero remaining candidates and zero links broken by the move, and [P5-T7] walks the three templates and every stage B criterion.
- Coverage: [P5-T5] holds `ProcessReductionChain.psm1`, `build_discovery_runtime.py` and `init_models.py` to the thresholds and every tool-rewritten production file to no per-file drop against [P0-T5] to [P0-T7]; no exclusion entry is added.
- Mirror parity: routing copies ([P3-T2]), template bundle copies ([P3-T4]), exclusions closed under copies (`REWRITE_EXCLUSIONS`), generators ([P3-T9]); the execution-environment brief is updated in all six byte-identical copies by [P3-T8] wherever a fact it states (for example the `docs/features` roots of the post-fan-in allowance bullet) changed.
- File size: [P0-T3] records counts; `ProcessReductionChain.psm1` and its test grow by one function and three cases; [P5-T6] checks the 800-line limit and the baseline file.
- Test isolation: the gates are one `Invoke-PoshQCParallelTest`, one `pytest -n auto` and Jest through its normal workers, through the launcher, at [P0-T5] to [P0-T7], each phase gate and [P5-T2] to [P5-T4], re-run only after a fix; no serial, single-process, shuffled or reversed run; new cases mock `Test-Path` and `Get-Content` and create no file; an order dependence is fixed on both sides.
- CI-only behavior: `.dev` paths use exact case and `Join-Path` for the Linux hook-suite job; no CRLF fixture; no test diffs against `origin/main`; the apply commit touches paths outside the docs-only allowlist, so CI runs in full.
- Evidence: the folder moves itself; `<FEATURE>` switches at the [P2-T2] tool call, [P2-T5] and [P3-T1] bound the two runs, `DECISIONS` is passed by explicit path, the mapping records under `**/evidence/**` are excluded from rewrites, and evidence is append-only.

## Size Justification

The plan has 39 tasks, within the legacy pair of 40 tasks and 400 lines that applies to this pre-cutoff plan file and above the 20-task target, because one change covers a self-moving folder split into two executor runs (R5), a commit protocol around the apply, three-language baselines and final gates, the ledger fallback, and mechanical derivations of the exclusion set that no single task can carry. The revision removed the owner-answer branch tasks that A2 to A14 closed.

## Assumptions

- Batch budget: Phases 1 and 3 edit at most three production PowerShell or Python files by hand; the `large` route checkpoint recorded in the precondition file covers the rest. Tool and generator writes are not counted.
- Hook context: hooks run from the default branch; non-isolated execution in the item worktree is required (precondition record).
