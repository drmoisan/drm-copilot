# 2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production - Plan (Stage B)

- **Issue:** #1016
- **Parent (optional):** epic #1018 (`docs/features/epics/shared-agent-harness-layer/epic.md`), child 7, wave 4
- **Owner:** drmoisan
- **Last Updated:** 2026-10-31
- **Status:** Draft (revision 1 after stage B preflight)
- **Version:** 0.2
- **Work Mode:** full-feature
- **Stage:** B (post-decision; Phase 3 of #1016: apply, rename, flip, dependent updates). Stage A is `plan.2026-10-30T18-59.md` in the same folder.
- **Requirements:** `spec.md` ("Stage B", "Owner stop", "Design Rule for Unresolved Owner Questions", "Behavior", "Exclusions", "Refusal rules", "Decision File", "Language Classification", "Execution Preconditions", "Contract Tests", "Orchestrator Rulings (preparation)" R1 to R5, "Acceptance Criteria" -> "Stage B" and "Epic-level criteria owned by this child"), `user-story.md` (scenarios (c) and (d)), `research/research.2026-10-30T23-24.md` (sections 4 to 9 and 11), child 2 spec `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/spec.md`.
- **Execution split (spec ruling R5):** stage B is delegated as two executor runs. Run 1 executes [P0-T1] through [P2-T6] and ends after the checkpoint handoff record. The orchestrator then updates the checkpoint. Run 2 executes [P3-T1] through [P8-T15] against the plan at its post-move path. [P2-T6] and [P3-T1] are therefore run boundaries, not mid-run waits.

## Required References

Policy files are listed as plain paths, not relative links, because this plan moves during its own execution and is excluded from link recomputation as a mapping record.

- `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`
- `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`
- `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`
- `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`
- Tool routes, launchers, command-text restrictions, the batch budget, hook context and CI shape: the `execution-environment` skill. This plan does not restate them.

## Terms

- `OLD_FEATURE` = `docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016`.
- `NEW_FEATURE` = `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production`, unless `DECISIONS` carries a `rename` entry whose `source` is `OLD_FEATURE`, in which case `NEW_FEATURE` is `.dev/active/<that target>`.
- `<FEATURE>` = `OLD_FEATURE` for every task in Phase 0 and Phase 1; `NEW_FEATURE` for [P2-T2] and every later task. [P2-T1] reads from `OLD_FEATURE` and writes its report under `SCRATCH`.
- Plan path: `OLD_FEATURE/plan.2026-10-30T23-35.md` until [P2-T1] completes, then `NEW_FEATURE/plan.2026-10-30T23-35.md`. Checkbox updates from [P2-T1] onward go to the new path only.
- `DECISIONS` = the lexicographically greatest `<FEATURE>/evidence/other/folder-rename-decisions.*.json`, written by the orchestrator. Every owner answer is read from its `global_decisions`, `rewrite_exclusions` and `decisions` members; the plan assumes no answer to OQ-1 to OQ-13.
- `FRESH_DRY_RUN` = the lexicographically greatest `OLD_FEATURE/evidence/other/dev-docs-migration-dry-run.*.json` written by [P1-T5] (after the move, the same basename under `NEW_FEATURE`).
- `RENAME_MAP` = the approved folder rename map: the mechanical renames listed in `FRESH_DRY_RUN` plus every `rename` entry of `DECISIONS`.
- `BASE` = the merge base of `origin/epic/shared-agent-harness-layer-integration` and `HEAD` (the pull-request base of this child). `MAIN_BASE` = the merge base of `origin/main` and `HEAD`, used only by the [P0-T5] re-check. Neither is ever written in this plan as a commit identifier.
- `APPLY_COMMIT` = the last commit of Phase 2: the commit created by [P2-T5] under `BRANCH-OQ-12` = `moves-then-rewrites`, or by [P2-T3] under `single`. [P2-T6] records its identifier in evidence; this plan never writes it.
- `SCRATCH` = `<session scratchpad>/issue-1016/`. Every scratch file, launcher, staged copy, derived decision file and coverage report lives there; file names start with `issue-1016-`. Evidence records the token `SCRATCH`, never a host path.
- `TOOL` = the migration tool invocation selected by `BRANCH-OQ-7` in [P1-T1]: the published-release `npx` subcommand pinned to the release version recorded in the orchestrator precondition file, or the branch-built bundle launched from a `sh` script under `SCRATCH`. Routes per the `execution-environment` skill.
- `BRANCH-OQ-n` = the branch value recorded for owner question n in `decision-branch-map.<timestamp>.md` by [P1-T1].

## Commit and Check-off Protocol (Phases 1 and 2)

The tool's apply mode refuses while tracked files have uncommitted changes (spec "Refusal rules"), and the executor's check-off of a task is itself a tracked change to this plan file. The following protocol is explicitly authorized for the three commit tasks [P1-T6], [P2-T3] and [P2-T5]:

1. Before staging, the commit task checks itself off in the plan file. Check-offs of earlier tasks that are not yet committed are already in the working tree and are staged with it, so they are part of the same commit.
2. After the commit, the task runs `git status --porcelain --untracked-files=no` and requires empty output. Untracked evidence written after the commit (for example the commit record) is allowed, because the refusal covers tracked changes only.
3. No task runs between a commit task and the apply that follows it: [P2-T1] follows [P1-T6] directly, and [P2-T4] follows [P2-T3] directly. Neither apply task writes a tracked change before it calls `TOOL`.
4. Unwind when a commit is refused or fails: the task reverts its own check-off in the plan file, leaves every other staged and working-tree change in place, runs no further task, and stops with `BLOCKED: commit-denied` and the refusal text. The orchestrator resolves the cause and resumes at the same commit task. A failed commit in Phase 2 never reverses the apply.

Consequence for [P2-T3]: the plan file reaches the move commit with the check-offs of [P2-T1] to [P2-T3], so it is the one allowed inexact rename (`R` below 100) in that commit.

## Evidence Path Schedule

| Tasks | Evidence root |
| --- | --- |
| [P0-T1] to [P1-T6] | `OLD_FEATURE/evidence/<kind>/` (these files move with the folder in [P2-T1]) |
| [P2-T1] | report under `SCRATCH/apply-1/` only; no write under `OLD_FEATURE` or `NEW_FEATURE` |
| [P2-T2] to the end | `NEW_FEATURE/evidence/<kind>/` only; no task writes under `OLD_FEATURE` after the move |

The orchestrator, not this plan, updates `artifacts/orchestration/orchestrator-state.json` to `NEW_FEATURE` between run 1 and run 2 (ruling R5) and records that in `NEW_FEATURE/evidence/other/checkpoint-path-update.<timestamp>.md`; [P3-T1] verifies it. No task of this plan writes under `artifacts/orchestration/`.

## Language Classification

Owner rule (epic `## Shared Design`): no new Python; existing Python is extended in place only; anything pushed down is PowerShell or bash; TypeScript only for MCP tools and extension commands; owner exception E2.

| Planned artifact | Runs where | Language | Rule status |
| --- | --- | --- | --- |
| Moves, renames, prefix and link rewrites | migration tool (stage A, TypeScript MCP package) | TypeScript, unchanged in stage B | conforms |
| Routing-config flip (three copies), `config/blast-radius.json` | repository and bundles | JSON | not code |
| Plan template link depth (two copies), `docs/README.md`, root docs, epic manifest, prose | repository and bundles | Markdown | not code |
| `.vscode/tasks.json` defaults | repository | JSON | not code |
| `resolve_default_template_root` in `scripts/dev_tools/discovery/init_models.py` | repository | existing Python, in-place edit | conforms |
| `scripts/dev_tools/build_discovery_runtime.py` source mapping (`BRANCH-OQ-4` = `keep`); `build_identity.py` member prefix in `packages/discovery-runtime/src/drm_copilot_discovery/` (`change`) | published Python package and its build script | existing Python, in-place edit | conforms |
| Default-root constants of child 2 (only under `BRANCH-OQ-3` = `.dev`) | TypeScript resolver, `scripts/dev_tools/json_config.py`, `DevelopmentDocsRoot.psm1` | existing files of each language | conforms |
| `Get-FileSizeExcludedSegment` (only under `BRANCH-OQ-10` = `yes`) | pushed-down lib and Codex hook | existing PowerShell | conforms |
| Test updates (Jest, Pytest, Pester) | repository | existing test files only | conforms |
| `sh` launchers, helpers and the derived decision file | agent session under `SCRATCH`, not committed | shell, JSON | conforms (not pushed down) |
| Extension command (only if `BRANCH-OQ-9` = `yes`) | extension | TypeScript | not designed here: accepted halt branch under ruling R2, see [P1-T1] |

No artifact requires a new Python file, a new PowerShell hook or a new bash script.

## Existing Tests Asserting Changed Behavior

Found by searching `tests/` and `extensions/drm-copilot/test/` for the changed symbols, file names and asserted paths. "Tool-rewritten" means the stage A prefix rule rewrites the literal in the apply step; the task named re-runs the test. A forward-slash literal in a test is rewritten whatever root the test resolves, so the tests whose rewritten literals would diverge from that root are derived mechanically in [P1-T3].

| Test | Asserts | Disposition |
| --- | --- | --- |
| `test_orchestration_routing_config_parity.py` `test_canonical_and_bundled_routing_config_are_byte_identical` | routing copies byte-identical | unchanged; passes because [P4-T1] flips all copies |
| `test_blast_radius_config_tolerance_keys.py` `test_self_hosted_path_roots_match_pinned_directory_list` | `PINNED_SELF_HOSTED_PATH_ROOTS` equals self-hosted `path_roots` | updated in [P4-T3] (adds `.dev`) |
| `test_blast_radius_config_tolerance_keys.py` `test_class_two_bundled_path_roots_are_empty`; `BlastRadius.KeyPartition.Tests.ps1` "declares an empty bundled path_roots list" | bundled `path_roots` is `[]` (Class 2, issue #722) | unchanged; [P4-T3] leaves the bundle copy empty (ruling R1) |
| `test_single_pass_preflight_contracts.py` `test_plan_templates_carry_premortem_skeleton` | template and bundle copy byte-identical | tool-rewritten path; passes after [P4-T4] edits both copies identically |
| `test_single_pass_preflight_contracts.py` `test_contract_requires_final_phase_self_review` | contract copies carry the `policy_audit` template path token | tool-rewritten in both test and contracts; re-run in [P7-T6] |
| `test_parallel_orchestrator_surface_contracts.py` `test_frozen_epic_surface_matches_pinned_baseline_digest` | `PINNED_FROZEN_SURFACE_HASHES` digests | updated in [P6-T2] |
| `KICKOFF_IDENTITY_FRAGMENTS` consumers in `test_parallel_orchestrator_surface_contracts.py` | identity fragment present in the kickoff surface | tool-rewritten in both; verified in [P6-T3] |
| `parallel_orchestrator_surface_test_support.py` `STATUS_TEMPLATE_RELATIVE` consumers | real read of the parallel status template | tool-rewritten; re-run in [P7-T6] |
| `test_execution_environment_brief_contracts.py` `test_architecture_doc_lists_brief` | real read of the architecture document | tool-rewritten path; re-run in [P7-T6] |
| `discovery/test_init_models.py` `test_resolve_default_template_root_returns_expected_path` | segment-joined template root | updated in [P5-T1] |
| `discovery/test_domain_neutrality.py` `_TEMPLATE_ROOT` | real read of discovery templates | tool-rewritten to the OQ-1 target; re-run in [P5-T1] |
| `test_discovery_documentation_contracts.py` `DOC`, `test_handoff_reconciles_the_built_artifacts`, `test_handoff_carries_no_stale_installed_host_limit` | segment-joined `docs/engineering` and `docs/features/active` reads, glob `*-980` | updated in [P5-T3] (renamed `0980-` prefix, area resolved by glob over the three areas) |
| `claude-architecture-doc.Tests.ps1` (every `It` that joins `'docs'` and `'engineering'`) | segment-joined real read | updated in [P5-T2] |
| `test_build_discovery_runtime.py` `test_schema_closure_resolves_local_urns_and_ignores_template_payloads` | in-memory `docs/discovery/templates/example.yaml` payload is ignored by schema closure | tool-rewritten; unaffected because the closure ignores non-schema payloads whatever their path |
| `test_build_discovery_runtime.py`, `test_build_discovery_runtime_io.py` | `RESOURCE_ROOTS`, `ResourceAllowlist` and canonical input reads | under `BRANCH-OQ-4` = `keep`, a source-mapping case is added in [P5-T4]; under `change`, re-run in [P5-T4] |
| `tests/scripts/dev_tools/test_new_potential_bug_entry.py` (in-memory `/workspace` with `docs/features/templates/bug/potential_bug.md` and `docs/features/potential` literals; segment-joined copy in `test_create_bug_entry_falls_back_to_workspace_when_no_template_root`) | created file and template paths under an in-memory workspace | classified in [P1-T3]: excluded from rewrite and unchanged when its literals would diverge from the resolved root, otherwise tool-rewritten with the segment-joined copy edited in [P4-T6] |
| Every other test file whose forward-slash literals would diverge from the root it resolves (injected `docs/features` configuration, or absent configuration under `BRANCH-OQ-3` = `docs/features`) | paths under an in-memory or injected root | derived in [P1-T3]; each is a `rewrite_exclusions` member checked in [P1-T4] or a manual edit in [P4-T7] |
| `FileSizePolicy.Tests.ps1`, `codex-hooks/file-size-policy.Tests.ps1` | excluded segment list | updated in [P5-T6] only under `BRANCH-OQ-10` = `yes` |
| `test_push_down_codex_and_agents_resource_contracts.py` `EXPECTED_DRM_COPILOT_TOOLS` | Codex `enabled_tools` | updated in [P5-T7] only under `BRANCH-OQ-8` including Codex |
| Child 2 R-1/R-2 tests (`root.test.ts`, Python `json_config` tests, `DevelopmentDocsRoot.Tests.ps1`) | absent key resolves the default | updated in [P4-T2] only under `BRANCH-OQ-3` = `.dev` |
| Folder-creation and promotion tests that read the repository routing config (`flow.test.ts`, `io.test.ts`, `content.test.ts`, `promotion.test.ts`, `test_potential_to_issue*.py`; exact set derived in [P1-T2] and [P1-T3]) | resolved root equals `docs/features` | updated in [P4-T1] to expect `.dev` |
| CI change-scope suites (`CiDocsOnlyPathsConfig.Tests.ps1`, `CiChangeScope.Tests.ps1`, `Invoke-CiChangeScope.Tests.ps1`, `Invoke-CiChangeScopeMergeBase.Tests.ps1`, `CiChangeScopeWorkflow.Tests.ps1`) | `docs/` and `.dev/` allowlist entries | unchanged; excluded from rewrite ([P1-T4]); re-run in [P7-T7] |

## Implementation Plan (Atomic Tasks)

### Phase 0 — Execution Gate, Anchors and Baselines

- [ ] [P0-T1] Read the policy files in the `policy-compliance-order` sequence (`CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/powershell.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, then the `.github/instructions/` files listed under Required References) and the `execution-environment` skill.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` carries `Timestamp:`, `Policy Order:` and the list of every file read.
- [ ] [P0-T2] Verify the orchestrator-written precondition file, the lexicographically greatest `<FEATURE>/evidence/other/stage-b-preconditions.*.md`. It must record, each as `PASS`: the parallel run `bugs-1001-1002-1003-1006` merged to `main`; epic children 1 to 6 merged into `epic/shared-agent-harness-layer-integration`; stage A complete; no open pull request touching `docs/features/**` or the spec "Execution Preconditions" overlap files (the orchestrator's `gh` query and its result); execution in the item worktree without isolation with `artifacts/orchestration/orchestrator-state.json` on the `large` route and not terminal (the batch-budget assumption below); the release version when the run source is a published release. The executor runs no `gh` command.
  - Acceptance: `<FEATURE>/evidence/baseline/stage-b-gate.<timestamp>.md` lists each field with `PASS`; a missing file or a non-`PASS` field stops the run with `BLOCKED: stage-b-precondition` before any edit.
- [ ] [P0-T3] Verify that stage A is present on this branch: the modules under `extensions/drm-copilot/src/lib/development-docs-migration/` exist, `REPO_AUTOMATION_TOOLS` in `extensions/drm-copilot/src/repo-automation-tool-names.ts` contains `migrate_development_docs`, `extensions/drm-copilot/src/migrate-development-docs-cli.ts` exists, and a stage A report `<FEATURE>/evidence/other/dev-docs-migration-dry-run.*.json` exists.
  - Acceptance: `<FEATURE>/evidence/baseline/stage-a-presence.<timestamp>.md` lists each item as found; any absence stops the run with `BLOCKED: stage-a-incomplete`.
- [ ] [P0-T4] Select `DECISIONS` and verify its shape against spec "Decision File": `version` equals 1; `dry_run_report` names an existing stage A JSON report; `source_digest` is present; all twelve `global_decisions` keys (`discovery_templates_target`, `in_tree_rewrite_scope`, `commit_split`, `absent_key_resolves`, `discovery_runtime_resource_key`, `rules_mirrors_editable`, `remove_fallback`, `run_source`, `allow_list_tool`, `extension_command`, `file_size_excluded_segment`, `plan_template_link_depth`) are non-empty strings; `rewrite_exclusions` and `decisions` are arrays; every held item in the named report has one `decisions` entry.
  - Acceptance: `<FEATURE>/evidence/baseline/decision-file-check.<timestamp>.md` records the selected file name and one `PASS` row per check; any failure stops the run with `BLOCKED: decision-file-incomplete` for the orchestrator.
- [ ] [P0-T5] Re-check every anchor this plan names (every path and symbol in the "Existing Tests Asserting Changed Behavior" table, the Language Classification table and the Planner citations) against `HEAD` after fetching `origin`; confirm that the merge base of `origin/epic/shared-agent-harness-layer-integration` and `HEAD` equals the integration-branch tip (the branch contains all merged children) and record `MAIN_BASE` for the `origin/main` re-check the spec requires; confirm child 2's exports `parseFeatureFolderName`, `formatFeatureFolderName`, `stripDateFirstPrefix`, `developmentDocsPath`, `resolveDevelopmentDocsRoot` and `KNOWN_DEVELOPMENT_DOCS_ROOTS` match child 2's spec signatures, and that the routing-config parity test covers all three copies.
  - Acceptance: `<FEATURE>/evidence/baseline/anchor-recheck.<timestamp>.md` has one row per anchor with `FOUND` or `MOVED`; any `MOVED` row, a stale integration merge base, or a signature mismatch stops the run with `BLOCKED: re-plan-required`.
- [ ] [P0-T6] Build the generator inventory after children 3 to 6: each generator script (including `scripts/dev_tools/generate_codex_agent_variants.py` and `scripts/dev_tools/build_discovery_runtime.py`), its source set, its output set and its `--check` or verification form; and, for each surface this plan edits by hand, whether it is a generator source or a generated output.
  - Acceptance: `<FEATURE>/evidence/baseline/generator-inventory.<timestamp>.md` lists every generator with its check form, and every hand-edited path in Phases 4 and 5 is classified `source` or `not generated`; a hand edit planned on a generated output stops the run with `BLOCKED: re-plan-required`.
- [ ] [P0-T7] Capture the TypeScript static baseline in `extensions/drm-copilot/`: Prettier check, ESLint, `tsc --noEmit`, and dependency-cruiser.
  - Acceptance: one artifact per step, `<FEATURE>/evidence/baseline/ts-<step>.<timestamp>.md`, each with `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`; Prettier check success prints `All matched files use Prettier code style!`.
- [ ] [P0-T8] Capture the TypeScript test baseline: Jest with coverage in `extensions/drm-copilot/` and the root TypeScript tests.
  - Acceptance: `<FEATURE>/evidence/baseline/ts-jest-coverage.<timestamp>.md` and `<FEATURE>/evidence/baseline/ts-root-tests.<timestamp>.md` carry the four fields; the Jest `Output Summary:` records pass and fail counts and the numeric `All files` line and branch percentages, and the per-file coverage summary is kept under `SCRATCH` for [P8-T8].
- [ ] [P0-T9] Capture the Python static baseline: Black in check mode, Ruff, Pyright.
  - Acceptance: one artifact per step, `<FEATURE>/evidence/baseline/py-<step>.<timestamp>.md`, with the four fields; the Black `Output Summary:` records the `would be left unchanged` count and any `would reformat` count.
- [ ] [P0-T10] Capture the Python test baseline with `--cov=scripts --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1016-coverage-baseline.json`.
  - Acceptance: `<FEATURE>/evidence/baseline/py-pytest-coverage.<timestamp>.md` carries the four fields, pass and fail counts, the `TOTAL` line percentage, and the line and branch totals read from the JSON report.
- [ ] [P0-T11] Capture the PowerShell static baseline: formatter check and `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, read from a direct run as the `execution-environment` skill requires.
  - Acceptance: `<FEATURE>/evidence/baseline/ps-<step>.<timestamp>.md` per step with the four fields; the analyzer summary records the finding count.
- [ ] [P0-T12] Capture the PowerShell test baseline: a single-process `Invoke-PoshQCTest` run over `tests/scripts` with coverage.
  - Acceptance: `<FEATURE>/evidence/baseline/ps-pester-coverage.<timestamp>.md` carries the four fields, pass and fail counts read from `artifacts/pester/pester-junit.xml`, and the numeric line coverage read from `artifacts/pester/powershell-coverage.xml`, copied to `SCRATCH` for the per-file comparison in [P8-T8].

### Phase 1 — Pre-Apply Derivations and Digest Gate

- [ ] [P1-T1] Map each `global_decisions` value to one plan branch and record `BRANCH-OQ-n: <value>` lines: OQ-1 a repository-relative directory under `.dev/`; OQ-2 `references-and-links`, `links-only` or `none`; OQ-3 `docs/features` or `.dev`; OQ-4 `keep` or `change`; OQ-5 `yes` or `no`; OQ-6 `no` or `remove`; OQ-7 `published <version>` or `branch-build`, plus bump timing `stage-b` or `later`; OQ-8 `none`, `claude`, `codex` or `both`; OQ-9 `no` or `yes`; OQ-10 `yes` or `no`; OQ-11 `three-level` or the exact link form the answer names; OQ-12 `single` or `moves-then-rewrites`.
  - Acceptance: `<FEATURE>/evidence/other/decision-branch-map.<timestamp>.md` has twelve `BRANCH-OQ-` lines. A value that maps to no branch stops the run with `BLOCKED: owner-answer-unmappable`. `BRANCH-OQ-6` = `remove` and `BRANCH-OQ-9` = `yes` are accepted halt branches under spec ruling R2, not plan gaps: either stops the run before any edit with `BLOCKED: owner-answer-re-plan` and re-enters planning for one plan revision.
- [ ] [P1-T2] Build the real-file-reader inventory: search `tests/`, `extensions/drm-copilot/test/` and the production roots for path segments joined as separate literals (`'docs'` or `"docs"` followed by `features`, `research`, `engineering` or `discovery`) and for globs over the area directories (for example `*-980`), which the prefix rule does not rewrite; give each match a disposition (tool-rewritten, manual in a named task, or unaffected).
  - Acceptance: `<FEATURE>/evidence/other/real-file-reader-inventory.<timestamp>.md` includes the rows for `resolve_default_template_root`, `test_resolve_default_template_root_returns_expected_path`, `claude-architecture-doc.Tests.ps1`, `test_discovery_documentation_contracts.py` and `test_new_potential_bug_entry.py`, plus the repository-config readers updated in [P4-T1]; every manual row names one of [P4-T6], [P4-T7], [P5-T1], [P5-T2] or [P5-T3].
- [ ] [P1-T3] Derive the divergent-literal test set. Candidates are the tracked files under `tests/` and `extensions/drm-copilot/test/`, outside `tests/fixtures/`, that `git grep -l -E 'docs/(features|research|engineering|discovery)/' -- tests extensions/drm-copilot/test` lists. For each candidate, read the production code its tests call and classify each test by the root it resolves: `R` (the repository routing configuration or real repository files), `I` (an injected configuration or explicit root of `docs/features`), `A` (an in-memory workspace with no routing configuration, so the absent-key default applies) or `H` (production code that hard-codes `docs` and `features` segments or a `docs/features` literal). Record the disposition for both OQ-3 branches: all `R` is `tool-rewritten`; all `I` is `exclude`; all `A` is `exclude` under `docs/features` and `tool-rewritten` under `.dev`; mixed classes are `exclude` plus `manual` ([P4-T7]); a segment-joined literal in a `tool-rewritten` file is `manual`. Classify `tests/scripts/dev_tools/test_new_potential_bug_entry.py` explicitly, with [P4-T6] as its manual task.
  - Acceptance: `<FEATURE>/evidence/other/divergent-literal-derivation.<timestamp>.md` records the command, its full output and one row per candidate with its class, both branch dispositions and the disposition selected by `BRANCH-OQ-3`; it contains a row for `test_new_potential_bug_entry.py`; every selected `manual` row names [P4-T6] or [P4-T7]; any `H` row stops the run with `BLOCKED: re-plan-required` naming the production module (a writer that ignores the configured root).
- [ ] [P1-T4] Derive the required rewrite-exclusion set and check that `DECISIONS` `rewrite_exclusions` or the tool's built-in exclusions match every member: `tests/fixtures/**` (ruling R3; it covers `tests/fixtures/**/*.json` and `tests/fixtures/blast_radius/historical-runs/**`); the mapping records (the promoted record, this feature's spec, user story, research and plans, child 2's spec, research and plan); child 2's resolver and matcher modules and their tests (from child 2's merged file list); `config/ci-docs-only-paths.json`; the CI change-scope suites named above; the six execution-environment brief copies; `.github/workflows/README.md`; every selected `exclude` row of [P1-T3]; the generated discovery-runtime outputs `packages/discovery-runtime/src/drm_copilot_discovery/_resources/**` and `packages/discovery-runtime/src/drm_copilot_discovery/_build_manifest.json` (both `BRANCH-OQ-4` values; [P5-T4] owns them); under `BRANCH-OQ-4` = `keep`, also `packages/discovery-runtime/src/drm_copilot_discovery/init_projection.py`, `packages/discovery-runtime/resource-manifest.json` and `scripts/dev_tools/build_discovery_runtime.py`, whose `docs/discovery/templates` literals are the unchanged packaged key; and, when `BRANCH-OQ-5` = `no`, `.claude/rules/plan-acceptance-gates.md`, `parallel-orchestration.md`, `orchestrator-state.md`, their bundle copies and their generator sources. The discovery-runtime paths are re-derived with `git ls-files packages/discovery-runtime` before the check.
  - Acceptance: `<FEATURE>/evidence/other/rewrite-exclusion-coverage.<timestamp>.md` lists each required path or glob with the matching exclusion; any unmatched member stops the run with `BLOCKED: exclusion-amendment-required` for the orchestrator (the exclusions are not part of `source_digest`).
- [ ] [P1-T5] Run `TOOL` in `dry-run` mode with `DECISIONS` and `report_directory` `OLD_FEATURE/evidence/other`, then compare `source_digest` in `FRESH_DRY_RUN` with `source_digest` in `DECISIONS`.
  - Acceptance: the report pair `dev-docs-migration-dry-run.<timestamp>.md` and `.json` exists; `<FEATURE>/evidence/baseline/digest-comparison.<timestamp>.md` (the stage B gate record that spec "Acceptance Criteria" -> "Stage B" places under `evidence/baseline/`) records both digests and `MATCH`; a mismatch stops the run with `BLOCKED: source-digest-mismatch` and nothing is applied (the orchestrator repeats the owner stop). The report also lists zero unmapped entries; a non-zero count stops the run with `BLOCKED: unmapped-entry`.
- [ ] [P1-T6] Commit the pre-apply state under the Commit and Check-off Protocol: check off [P1-T6] in the plan file, stage this plan file, `DECISIONS` and every evidence file written by Phase 0 and Phase 1, and commit with a message file under `SCRATCH`.
  - Acceptance: after the commit, `git status --porcelain --untracked-files=no` prints nothing, and `git diff --name-only BASE HEAD -- OLD_FEATURE` lists the plan file and the Phase 0 and Phase 1 evidence files; a refused or failed commit follows the protocol unwind and stops the run with `BLOCKED: commit-denied`.

### Phase 2 — Apply (Moves, Renames, Rewrites)

- [ ] [P2-T1] With no tracked change since [P1-T6], run `TOOL` in `apply` mode with `rename_decisions_path` set to `OLD_FEATURE/evidence/other/<DECISIONS basename>` and `report_directory` `SCRATCH/apply-1/`. Under `BRANCH-OQ-12` = `single` the call performs moves, renames and rewrites; under `moves-then-rewrites` it performs moves and renames only.
  - Acceptance: exit status 0; `NEW_FEATURE/plan.2026-10-30T23-35.md` exists and `OLD_FEATURE` no longer exists on disk; a refusal stops the run with `BLOCKED: apply-refused` and the refusal reason. From this task on, `<FEATURE>` is `NEW_FEATURE`.
- [ ] [P2-T2] Copy the apply report pair from `SCRATCH/apply-1/` into `<FEATURE>/evidence/other/` with its tool-written file names unchanged.
  - Acceptance: both files exist under `<FEATURE>/evidence/other/` and list the moves, renames, untracked files and (under `single`) the rewritten files with occurrence counts.
- [ ] [P2-T3] Commit the first apply result under the Commit and Check-off Protocol: check off [P2-T3], stage with `git add -u` plus `docs/README.md` when present and `<FEATURE>/evidence/`, without staging the untracked files the report lists, and commit with a message file under `SCRATCH`.
  - Acceptance: `<FEATURE>/evidence/other/apply-commit-1.<timestamp>.md` records the counts of `R100`, other `R`, `A`, `M` and `D` lines from `git diff -M --name-status HEAD~1 HEAD` and that `git status --porcelain --untracked-files=no` prints nothing. Under `moves-then-rewrites` every line is `R100` except one inexact `R` line for the plan file (it carries the check-offs of [P2-T1] to [P2-T3]), an `A` line for `docs/README.md` when the call created it, and `A` lines under `<FEATURE>/evidence/`; under `single` the `R100` count is greater than zero (renames recorded for unchanged files).
- [ ] [P2-T4] Under `BRANCH-OQ-12` = `moves-then-rewrites`, with no tracked change since [P2-T3], run `TOOL` in `apply` mode a second time with `rename_decisions_path` under `<FEATURE>/evidence/other/` and `report_directory` `SCRATCH/apply-2/`, and copy the report pair into `<FEATURE>/evidence/other/`. Under `single` this task is authorized to record `N/A (BRANCH-OQ-12: single)` without running.
  - Acceptance: under `moves-then-rewrites`, exit status 0 and the copied report lists rewrites only (zero moves); under `single`, `<FEATURE>/evidence/other/apply-2-not-applicable.<timestamp>.md` records the branch value.
- [ ] [P2-T5] Under `BRANCH-OQ-12` = `moves-then-rewrites`, commit the rewrites under the Commit and Check-off Protocol: check off [P2-T5], stage with `git add -u` plus `<FEATURE>/evidence/`, and commit. Under `single` this task is authorized to record `N/A (BRANCH-OQ-12: single)`.
  - Acceptance: under `moves-then-rewrites`, `<FEATURE>/evidence/other/apply-commit-2.<timestamp>.md` records that `git diff -M --name-status HEAD~1 HEAD` holds only `M` lines (the plan file among them) and `A` lines under `<FEATURE>/evidence/`, and that `git status --porcelain --untracked-files=no` prints nothing; under `single`, the not-applicable record from [P2-T4] names this task too.
- [ ] [P2-T6] Write the checkpoint handoff record for the orchestrator and end run 1 (ruling R5): old and new `<FEATURE>`, old and new plan path, the new `DECISIONS` path, and the `APPLY_COMMIT` identifier from `git rev-parse HEAD`, with the statement that the orchestrator updates the feature-folder fields of `artifacts/orchestration/orchestrator-state.json` before run 2 and that this plan writes nothing under `artifacts/orchestration/`.
  - Acceptance: `<FEATURE>/evidence/other/checkpoint-path-handoff.<timestamp>.md` exists with the six values; the executor reports run 1 complete at this task.

### Phase 3 — Post-Move Verification

- [ ] [P3-T1] At the start of run 2, verify the orchestrator-written `<FEATURE>/evidence/other/checkpoint-path-update.*.md` (lexicographically greatest) records that the checkpoint's feature-folder fields equal `NEW_FEATURE`.
  - Acceptance: the file exists and names `NEW_FEATURE`; absence stops the run with `BLOCKED: checkpoint-path-update-pending`.
- [ ] [P3-T2] Verify the target layout: the top-level entries of `git ls-files .dev` are `potential`, `active`, `completed`, `archive`, `epics`, `parallel`, `templates`, `research`, `engineering`, `backlog.md` and the top directory of `BRANCH-OQ-1`; `git ls-files docs` lists `docs/README.md` and no mapped source; `docs/README.md` contains the token `production`.
  - Acceptance: `<FEATURE>/evidence/other/layout-check.<timestamp>.md` records both listings and `PASS` for each condition.
- [ ] [P3-T3] Compare the post-apply folder names under `.dev/active`, `.dev/completed` and `.dev/archive` with the expected names derived from `RENAME_MAP` and the `keep` entries of `DECISIONS`, and compare the folder names under `.dev/potential`, `.dev/epics`, `.dev/parallel` and `.dev/research` with their pre-move names.
  - Acceptance: `<FEATURE>/evidence/other/folder-rename-comparison.<timestamp>.md` records the expected count, the observed count and zero mismatches.
- [ ] [P3-T4] Verify that every file in the [P1-T4] exclusion set kept its content: `git diff -M --name-status BASE HEAD` shows each excluded file only as `R100` (moved), as an `A` line for a file first added on this branch after `BASE` (for example this feature's plans), or not at all.
  - Acceptance: `<FEATURE>/evidence/other/exclusion-integrity.<timestamp>.md` records zero excluded files with an `M` line or an inexact `R` line; `git status --porcelain` is recorded alongside.

### Phase 4 — Flip and Configuration

- [ ] [P4-T1] Set `development_docs_root` to `.dev` in `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json` and `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json`, and update the repository-config readers from [P1-T2] and the class `R` rows of [P1-T3] that assert the resolved root `docs/features` to expect `.dev`.
  - Acceptance: the three copies are byte-identical; `test_canonical_and_bundled_routing_config_are_byte_identical` and every updated reader pass; the files with a selected `exclude` disposition in [P1-T3] are not edited by this task.
- [ ] [P4-T2] Under `BRANCH-OQ-3` = `.dev`, set the default-root constant to `.dev` in child 2's TypeScript resolver, `scripts/dev_tools/json_config.py` and `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` (with its bundle copy and Codex twin per [P0-T5]) and update the R-1 and R-2 cases in `root.test.ts`, the Python `json_config` tests and `DevelopmentDocsRoot.Tests.ps1`. Under `BRANCH-OQ-3` = `docs/features` this task is authorized to record `no change`.
  - Acceptance: under `.dev`, the updated R-1 and R-2 cases pass in all three runtimes; under `docs/features`, `<FEATURE>/evidence/other/oq3-no-change.<timestamp>.md` records the branch value and that `git diff --name-only BASE HEAD` lists none of those files, with `git status --porcelain` recorded.
- [ ] [P4-T3] Implement spec ruling R1: insert `.dev` into `path_roots` of the self-hosted `config/blast-radius.json` in ordinal order (after `.codex`, before `.devcontainer`), keep `docs`, and update `PINNED_SELF_HOSTED_PATH_ROOTS` in `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py` to match. Do not edit `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`; its Class 2 `path_roots` stays `[]`.
  - Acceptance: `test_self_hosted_path_roots_match_pinned_directory_list`, `test_class_two_bundled_path_roots_are_empty` and the Pester case "declares an empty bundled path_roots list" in `BlastRadius.KeyPartition.Tests.ps1` pass, and `<FEATURE>/evidence/other/blast-radius-check.<timestamp>.md` records that `git diff --name-only BASE HEAD` does not list the bundle copy, with `git status --porcelain` recorded.
- [ ] [P4-T4] Set the `.github/instructions/` link form in `.dev/templates/feature/plan.yyyy-MM-ddTHH-mm.md` and `extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md` (`## Required References`) per `BRANCH-OQ-11`: `three-level` uses three parent segments; otherwise the exact form the answer names.
  - Acceptance: both copies are byte-identical; `test_plan_templates_carry_premortem_skeleton` passes; under `three-level`, each link resolved from `.dev/templates/feature/` (the same depth as `.dev/active/<folder>/`) names an existing file, recorded in `<FEATURE>/evidence/other/template-link-check.<timestamp>.md`.
- [ ] [P4-T5] Set the child 2 `feature_folder` value in `.dev/epics/shared-agent-harness-layer/epic.md` front matter to the renamed child 2 basename from [P3-T3].
  - Acceptance: `<FEATURE>/evidence/other/epic-manifest-check.<timestamp>.md` records that the front matter parses, the child 2 value equals a directory name present under `.dev/active`, `.dev/completed` or `.dev/archive`, and `test_epic_kickoff_contract.py` passes.
- [ ] [P4-T6] Apply the [P1-T3] disposition of `tests/scripts/dev_tools/test_new_potential_bug_entry.py`. When the selected disposition is `tool-rewritten`, replace the segment-joined template path in `test_create_bug_entry_falls_back_to_workspace_when_no_template_root` with segments that name the same file as the tool-rewritten forward-slash template literals in the module (`.dev`, `templates`, `bug`, `potential_bug.md`). When it is `exclude`, this task is authorized to record `no change`.
  - Acceptance: every test in `test_new_potential_bug_entry.py` passes; under `exclude`, `<FEATURE>/evidence/other/new-potential-bug-entry-no-change.<timestamp>.md` records the disposition and that [P3-T4] lists the module with no `M` line.
- [ ] [P4-T7] Edit every other selected `manual` row of [P1-T3]: in each listed file, set each listed literal to the root its test resolves (`.dev` for class `R`, and for class `A` under `BRANCH-OQ-3` = `.dev`; `docs/features` for class `I`). When [P1-T3] lists no other `manual` row, this task is authorized to record `no change`.
  - Acceptance: `<FEATURE>/evidence/other/manual-literal-edits.<timestamp>.md` lists each edited file and the test run that passes for it, or records `no change` with the empty row count.

### Phase 5 — Residual References and Decision-Dependent Updates

- [ ] [P5-T1] Update `resolve_default_template_root` in `scripts/dev_tools/discovery/init_models.py` to return the `BRANCH-OQ-1` directory, and update `test_resolve_default_template_root_returns_expected_path` in `tests/scripts/dev_tools/discovery/test_init_models.py` to the same segments.
  - Acceptance: that test and `tests/scripts/dev_tools/discovery/test_domain_neutrality.py` pass; the returned path names an existing directory.
- [ ] [P5-T2] Replace the segment-joined `'docs'`, `'engineering'` path in every `It` block of `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` with `.dev` and `engineering` segments built with `Join-Path`.
  - Acceptance: `claude-architecture-doc.Tests.ps1` passes with zero failures in its JUnit result.
- [ ] [P5-T3] Update `tests/scripts/dev_tools/test_discovery_documentation_contracts.py`: `DOC` joins `.dev` and `engineering`; `test_handoff_reconciles_the_built_artifacts` and `test_handoff_carries_no_stale_installed_host_limit` locate the issue 980 handoff by globbing `0980-*/handoff.md` across `.dev/active`, `.dev/completed` and `.dev/archive`.
  - Acceptance: every test in that module passes.
- [ ] [P5-T4] Discovery runtime packaging per `BRANCH-OQ-4`. Under `keep`: the packaged key `docs/discovery/templates` stays in `RESOURCE_ROOTS`, `packages/discovery-runtime/resource-manifest.json`, `TEMPLATE_ROOT` in `init_projection.py`, the staged `_resources/**` tree and `_build_manifest.json` (all excluded in [P1-T4]); add to `scripts/dev_tools/build_discovery_runtime.py` a mapping from the packaged key prefix to the moved repository directory that holds the v2 templates, used where canonical inputs are read, with a new case `test_canonical_template_inputs_read_from_moved_source_directory` in `tests/scripts/dev_tools/test_build_discovery_runtime_io.py`. Under `change`: the tool owns the `TEMPLATE_ROOT`, `RESOURCE_ROOTS` and `resource-manifest.json` literals, and this task confirms each names the moved directory; edit by hand the `_resources/docs/discovery/templates/` member prefix in `packages/discovery-runtime/src/drm_copilot_discovery/build_identity.py`, which the token-boundary rule does not rewrite; then regenerate `_resources/**`, `_resources/manifest.json` and `_build_manifest.json` with one write-mode run of the build script.
  - Acceptance: `test_build_discovery_runtime.py` and `test_build_discovery_runtime_io.py` pass (under `keep`, including the new case); the build script's verification mode reports no drift; under `keep`, `git diff --name-only BASE HEAD -- packages/discovery-runtime` prints nothing, with `git status --porcelain` recorded; an edit outside the named files stops the run with `BLOCKED: re-plan-required`.
- [ ] [P5-T5] Verify and correct the root references rewritten by the tool: the layout sentence under the `docs/features/` bullet of `README.md` (now `.dev/`) names the `.dev` areas; the epic-kickoff path in `AGENTS.md` (or its generator source per [P0-T6]); the `.vscode/tasks.json` input default and task details; and the `pyproject.toml` comment path names an existing file.
  - Acceptance: `<FEATURE>/evidence/other/root-reference-check.<timestamp>.md` records each reference and the existing target it resolves to; zero unresolved.
- [ ] [P5-T6] Under `BRANCH-OQ-10` = `yes`, add `.dev` to `Get-FileSizeExcludedSegment` in `.claude/lib/file-size-policy/FileSizePolicy.psm1`, `.codex/hooks/file-size-policy.ps1` and both bundle copies, with a `.dev` case in `FileSizePolicy.Tests.ps1` and `codex-hooks/file-size-policy.Tests.ps1`. Under `no` this task is authorized to record `no change`.
  - Acceptance: under `yes`, both suites pass on the Linux hook-suite shape (case-exact names, `Join-Path`); under `no`, `<FEATURE>/evidence/other/oq10-no-change.<timestamp>.md` records the branch value.
- [ ] [P5-T7] Under `BRANCH-OQ-8` naming `claude`, add `mcp__drm-copilot__migrate_development_docs` to `permissions.allow` in `.claude/settings.json` (source per [P0-T6]) and its bundle copy; naming `codex`, add `migrate_development_docs` to `enabled_tools` in `.codex/config.toml`, its bundle copy and `EXPECTED_DRM_COPILOT_TOOLS`. Under `none` this task is authorized to record `no change`.
  - Acceptance: the push-down resource contract tests pass; under `none`, `<FEATURE>/evidence/other/oq8-no-change.<timestamp>.md` records the branch value.
- [ ] [P5-T8] Under `BRANCH-OQ-7` bump timing `stage-b`, increment the patch version in `extensions/drm-copilot/package.json` and `packages/mcp-server/package.json` and add an `extensions/drm-copilot/CHANGELOG.md` entry naming the `.dev` flip. Under `later` this task is authorized to record `no change`.
  - Acceptance: under `stage-b`, the packaging tests under `extensions/drm-copilot/test/packaging/` pass; under `later`, `<FEATURE>/evidence/other/oq7-no-bump.<timestamp>.md` records the branch value.
- [ ] [P5-T9] Verify the `BRANCH-OQ-5` outcome for the three rules files and their copies: under `yes`, the tool-rewritten text is identical in each source and its copies; under `no`, `git diff --name-only BASE HEAD` lists none of them.
  - Acceptance: `<FEATURE>/evidence/other/oq5-rules-check.<timestamp>.md` records the branch value and the result, with `git status --porcelain` recorded.

### Phase 6 — Generators and Pins

- [ ] [P6-T1] Run every generator from [P0-T6] in write mode, then in `--check` or verification mode, including `scripts/dev_tools/generate_codex_agent_variants.py`.
  - Acceptance: `<FEATURE>/evidence/other/generator-check.<timestamp>.md` records each check run with `EXIT_CODE: 0`, and `git status --porcelain` is unchanged by a second write-mode run.
- [ ] [P6-T2] For each path in `PINNED_FROZEN_SURFACE_HASHES` (`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`) whose bytes differ from `BASE`, replace its SHA-256 digest with the digest of the current file and add a comment block beginning `RE-BASELINED by issue #1016` that states the cause and date.
  - Acceptance: `test_frozen_epic_surface_matches_pinned_baseline_digest` passes for every entry; an entry whose bytes are unchanged keeps its digest.
- [ ] [P6-T3] Verify each `KICKOFF_IDENTITY_FRAGMENTS` entry appears verbatim in the rewritten kickoff surface, and update a fragment in the same change when the surface text changed.
  - Acceptance: `test_parallel_orchestrator_surface_contracts.py`, `test_parallel_planner_surface_contracts.py`, `test_parallel_kickoff_contract.py` and `test_epic_kickoff_contract.py` pass.

### Phase 7 — Post-Apply Verification

- [ ] [P7-T1] Implement spec ruling R4. Derive `SCRATCH/post-apply/issue-1016-post-apply-decisions.json` mechanically from the moved `DECISIONS`: `decisions` set to `[]`; each `rewrite_exclusions` glob mapped through the spec mapping table (longest prefix first, `docs/discovery/` to `BRANCH-OQ-1`) and then through `RENAME_MAP` for a renamed folder basename that follows a `.dev/<area>/` prefix; when `BRANCH-OQ-2` is `links-only` or `none`, the new prefixes of the moved trees added as exclusions, because their in-tree references were intentionally left; all other members unchanged, with a copy of `FRESH_DRY_RUN` placed beside it. Run `TOOL` in `dry-run` mode with that file as `rename_decisions_path` and `report_directory` `<FEATURE>/evidence/other`. Dry-run mode applies none of the apply-mode refusals in spec "Refusal rules".
  - Acceptance: `<FEATURE>/evidence/other/post-apply-dry-run-check.<timestamp>.md` records the derived exclusion list and the report counts: zero moves, zero renames and zero files to rewrite outside the excluded files; every held item is a `keep` decision mapped through `RENAME_MAP` or a rule-5 kept name; a non-zero count is a failed task.
- [ ] [P7-T2] Compare the broken-link list of the [P7-T1] report with that of `FRESH_DRY_RUN`, mapping old paths through `RENAME_MAP` and the mapping table.
  - Acceptance: `<FEATURE>/evidence/other/link-check.<timestamp>.md` records both counts and zero links broken by the move.
- [ ] [P7-T3] Search the production roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts` and `extensions/drm-copilot/src` with `git grep -n -E` for `docs.(features|research|engineering|discovery)` and for the segment form `["']docs["']`, and classify every match against child 2's Stay allowlist, its resolver constants and matcher unions, and the [P1-T4] exclusion set.
  - Acceptance: `<FEATURE>/evidence/other/production-root-search.<timestamp>.md` records the commands, the full output, the allowlist and zero unclassified matches.
- [ ] [P7-T4] Verify the D-15 fixtures are frozen (ruling R3 excludes all of `tests/fixtures/**`) and still pass through the fallback: `git diff --name-only BASE HEAD -- tests/fixtures` prints nothing and `git status --porcelain -- tests/fixtures` prints nothing; run the suites that load `tests/fixtures` (found by searching the test trees for `fixtures`) with the key at `.dev`.
  - Acceptance: `<FEATURE>/evidence/other/fixtures-frozen.<timestamp>.md` records both empty outputs and the suite list with zero failures.
- [ ] [P7-T5] Run child 2's write-scope checker suite under `extensions/drm-copilot/test/lib/development-docs/` with the key at `.dev`.
  - Acceptance: all three directions pass, and the run is recorded in `<FEATURE>/evidence/other/write-scope-check.<timestamp>.md`.
- [ ] [P7-T6] Run the Python contract tests from spec "Contract Tests": the push-down resource, pack-manifest completeness and dependency-closure tests, `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py`, `test_claude_rules_frontmatter.py`, `test_parallel_orchestrator_surface_contracts.py`, `test_quality_checks_workflow_contracts.py`, `test_push_down_issue_824_follow_ups.py`, `test_typescript_toolchain_instruction_contracts.py`, `test_execution_environment_brief_contracts.py`, `test_orchestration_routing_config_parity.py`, `test_single_pass_preflight_contracts.py` and every `test_*contract*.py` that carried a `docs/features` fragment at `BASE`.
  - Acceptance: `<FEATURE>/evidence/other/contract-tests-python.<timestamp>.md` lists every module with zero failures.
- [ ] [P7-T7] Run the Pester contract suites `claude-architecture-doc.Tests.ps1` and `hook-dependency-guard-completeness.Tests.ps1` and the five CI change-scope suites.
  - Acceptance: `<FEATURE>/evidence/other/contract-tests-pester.<timestamp>.md` records zero failures read from the JUnit file.
- [ ] [P7-T8] Verify no fact stated by the execution-environment brief changed: `git diff --name-only BASE HEAD` lists none of the six brief copies, `.github/workflows/README.md` or `config/ci-docs-only-paths.json`, with `git status --porcelain` recorded; `test_brief_copies_are_byte_identical` and `test_brief_ci_section_names_jobs_and_required_contexts` pass.
  - Acceptance: `<FEATURE>/evidence/other/brief-unchanged.<timestamp>.md` records both observations and the passing tests.

### Phase 8 — Final QA Loop and Self-Review

Restart from [P8-T1] whenever a step fails or changes a file; all Phase 8 artifacts come from one clean pass.

- [ ] [P8-T1] Run the TypeScript stages 1 to 4 in `extensions/drm-copilot/` (Prettier check, ESLint, `tsc --noEmit`, dependency-cruiser) with the key at `.dev`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/ts-<step>.<timestamp>.md` per step with the four fields and `EXIT_CODE: 0`; Prettier prints `All matched files use Prettier code style!`.
- [ ] [P8-T2] Run Jest with coverage in `extensions/drm-copilot/` and the root TypeScript tests.
  - Acceptance: `<FEATURE>/evidence/qa-gates/ts-jest-coverage.<timestamp>.md` and `ts-root-tests.<timestamp>.md` record zero failures and the numeric `All files` line and branch percentages.
- [ ] [P8-T3] Run the Python stages 1 to 3: Black in check mode, Ruff, Pyright.
  - Acceptance: `<FEATURE>/evidence/qa-gates/py-<step>.<timestamp>.md` per step with `EXIT_CODE: 0`; Black reports no `would reformat`; Pyright reports `0 errors`.
- [ ] [P8-T4] Run Pytest with `--cov=scripts --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1016-coverage-final.json`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/py-pytest-coverage.<timestamp>.md` records zero failures, the `TOTAL` percentage and the JSON line and branch totals.
- [ ] [P8-T5] Run the PowerShell formatter check and `Invoke-ScriptAnalyzer` with the PoshQC settings file.
  - Acceptance: `<FEATURE>/evidence/qa-gates/ps-<step>.<timestamp>.md` per step; zero analyzer findings; the formatter check reports no file needing change.
- [ ] [P8-T6] Run a fresh single-process `Invoke-PoshQCTest` over `tests/scripts` with coverage (the CI shape), including `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/ps-pester-coverage.<timestamp>.md` records zero failures from `artifacts/pester/pester-junit.xml` and the numeric line coverage from `artifacts/pester/powershell-coverage.xml`.
- [ ] [P8-T7] Run stages 6 and 7: every generator check from [P0-T6] again and the integration suites (`extensions/drm-copilot/test/extension.integration.test.ts` and the Python and Pester integration suites present at `BASE`).
  - Acceptance: `<FEATURE>/evidence/qa-gates/contract-integration.<timestamp>.md` records each command with `EXIT_CODE: 0`.
- [ ] [P8-T8] Compute coverage deltas in two sets. Plan-edited files: the Python, TypeScript and PowerShell production files in `git diff --name-only APPLY_COMMIT` plus untracked production files from `git status --porcelain` (the edits of Phases 4 to 6). Tool-only files: the production files the apply reports list as rewritten that are not in the plan-edited set. Each plan-edited Python and TypeScript file must reach 85% line and 75% branch coverage, and each plan-edited PowerShell file 85% line coverage. Each tool-only file must not fall below its own baseline line and branch values from [P0-T8], [P0-T10] and [P0-T12]. Each language total must not fall below its baseline.
  - Acceptance: `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md` lists both sets with the derivation commands, baseline and post-change values per file and per language total, no plan-edited file under threshold, no tool-only file below its baseline and no total regression; a missing value makes the outcome remediation-required.
- [ ] [P8-T9] Run a seeded shuffled Jest run (`--randomize` with a recorded `--seed`).
  - Acceptance: `<FEATURE>/evidence/regression-testing/jest-shuffle.<timestamp>.md` records the seed and zero failures.
- [ ] [P8-T10] Run the changed Python test modules in reversed order in one process.
  - Acceptance: `<FEATURE>/evidence/regression-testing/pytest-reversed.<timestamp>.md` records the module order and zero failures.
- [ ] [P8-T11] Run the touched Pester suites in one process with a seeded shuffled file order for three seeds.
  - Acceptance: `<FEATURE>/evidence/regression-testing/pester-shuffle.<timestamp>.md` records each seed, its file order and zero failures.
- [ ] [P8-T12] Check file size: every changed production, test and script file has at most 800 logical lines (`wc -l`), and no `config/file-size-baseline.json` entry grew.
  - Acceptance: `<FEATURE>/evidence/qa-gates/file-size.<timestamp>.md` lists each file with its count and zero files above 800.
- [ ] [P8-T13] Verify no Python file was added by this child: `git diff --name-status --diff-filter=A BASE HEAD` lists no `.py` path and `git status --porcelain` lists no untracked `.py` path. `BASE` is the only anchor, so commits of other children already on the integration branch are not attributed to this child.
  - Acceptance: `<FEATURE>/evidence/qa-gates/no-new-python.<timestamp>.md` records both outputs with zero `.py` additions.
- [ ] [P8-T14] Record the decision completion table: for OQ-1 to OQ-13, the `BRANCH-OQ-` value (OQ-13, which has no `global_decisions` key: the `DECISIONS` `decisions` entry count), the implementing task or `no change`, and the named test or evidence artifact.
  - Acceptance: `<FEATURE>/evidence/qa-gates/stage-b-decision-completion.<timestamp>.md` has thirteen rows and none is blank.
- [ ] [P8-T15] Walk the policy-audit, code-review and feature-audit templates under `.dev/templates/policy_audit/` (moved from `docs/features/templates/policy_audit/`) against `git diff BASE HEAD`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` has one PASS, FAIL or N/A row per checklist item and no FAIL row; a FAIL row is fixed, the loop restarts at [P8-T1], and the self-review is rewritten.

## Pre-Mortem

- Review checklists: a reviewer finds a stale `docs/features` literal or a broken link. Prevented by [P7-T3] (production-root search including the segment-joined form, classified against child 2's allowlist), [P7-T2] (link comparison), [P5-T5] (root references) and [P8-T15].
- Coverage: few production files change by hand. [P8-T8] holds each plan-edited Python, TypeScript and PowerShell file to 85% line and 75% branch (PowerShell line only) and each file changed only by the tool's rewrite to no regression against its own baseline from [P0-T8], [P0-T10] and [P0-T12]; no exclusion entry is added.
- Mirror parity: routing-config copies ([P4-T1]), template copies ([P4-T4]), FileSizePolicy copies ([P5-T6]), allowlist copies ([P5-T7]), generated surfaces and discovery-runtime outputs ([P6-T1], [P5-T4]) and resource contracts ([P7-T6]). The execution-environment brief states the CI docs-only allowlist, which this plan does not change (`docs/` entries stay for the fallback release, and `BRANCH-OQ-6` = `remove` halts in [P1-T1] under ruling R2); the six copies are excluded from rewrite ([P1-T4]) and [P7-T8] proves them unchanged, so no brief-update task is required.
- File size: no new module; [P8-T12] checks every changed file; `.dev` versus the `docs` exempt segment is decided by `BRANCH-OQ-10` in [P5-T6].
- Test isolation: [P8-T9] seeded shuffled Jest run with the seed recorded, [P8-T10] reversed-order run of the changed Python test modules, [P8-T11] seeded shuffled Pester file order with three seeds recorded, and [P8-T6] fresh single-process Pester run; real-file readers are inventoried in [P1-T2] and tests with divergent rewritten literals in [P1-T3].
- CI-only behavior: Linux hook suites are case-sensitive, so `.dev` paths use exact case and `Join-Path` ([P5-T2], [P5-T6]); `.gitattributes` `eol=lf` normalizes the moved files and no CRLF fixture is added; no test diffs against `origin/main`; the move commit runs full CI because it touches paths outside the docs-only allowlist.
- Evidence: the folder renames itself. The Evidence Path Schedule fixes which tasks write under `OLD_FEATURE` and which under `NEW_FEATURE`; [P2-T1] writes only under `SCRATCH`; the Commit and Check-off Protocol keeps the tree clean before each apply; [P2-T6] and [P3-T1] bound the two executor runs of ruling R5; `DECISIONS` is always passed by explicit path.

## Assumptions

- Batch budget: Phases 4 and 5 may edit more than three non-test PowerShell or Python production files in one worktree. The run assumes the `large` route checkpoint in the item worktree without isolation, recorded by the orchestrator and verified in [P0-T2] (`execution-environment` skill, `## Batch Budget`). Files written by the tool or a generator are not counted.
- Hook context: hooks on an isolated subagent are `main`'s copies, which may not yet accept `.dev` paths; the same non-isolated execution requirement covers this.
- The tool's prefix rewrite updates every forward-slash literal at a token boundary in tests, prose and configuration, whatever root the surrounding code resolves. Segment-joined literals and globs need manual edits ([P1-T2]); literals that would diverge from the resolved root are excluded or edited by hand ([P1-T3], [P4-T6], [P4-T7]). A literal preceded by `/` (for example `_resources/docs/discovery/templates/` in `build_identity.py`) is not at a token boundary and is not rewritten.

## Size Justification

The plan exceeds 40 tasks and 400 lines because one change covers a self-moving feature folder split across two executor runs, a commit split chosen at run time with a commit protocol that keeps the tree clean before each apply, twelve owner-answer branches each with an explicit no-change record, mechanical derivations of the exclusion set and of the tests whose rewritten literals diverge, three languages of baseline and final QA with per-step evidence, and the isolation runs. Mechanical updates are grouped by tool call and generator run, not by file.

## Open Questions / Notes

- Spec ruling R1 settles the blast-radius bundle copy: only the self-hosted `config/blast-radius.json` and `PINNED_SELF_HOSTED_PATH_ROOTS` gain `.dev` ([P4-T3]).
- Spec ruling R2: `BRANCH-OQ-6` = `remove` and `BRANCH-OQ-9` = `yes` are accepted halt branches in [P1-T1] that re-enter planning.
- Spec ruling R3: `tests/fixtures/**` is a required exclusion ([P1-T4]), so [P7-T4] observes an empty diff.
- Spec ruling R4: the post-apply dry run uses a derived decision file ([P7-T1]).
- Spec ruling R5: two executor runs, split at [P2-T6] and [P3-T1].
- The child 7 `feature_folder` hint in the epic manifest is back-filled by the orchestrator at fan-in and is not edited by this plan.
