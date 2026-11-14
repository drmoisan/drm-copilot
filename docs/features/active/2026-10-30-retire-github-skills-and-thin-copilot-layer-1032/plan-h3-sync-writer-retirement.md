# 2026-10-30-retire-github-skills-and-thin-copilot-layer - H3 Sync-Writer Retirement Plan

- **Issue:** #1032
- **Parent (optional):** epic #1018, child 6
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14
- **Status:** Draft
- **Version:** 0.1 (split from the main plan per spec AD-1)
- **Work Mode:** full-feature
- **Requirements:** `spec.md` `## Scope` item 9, owner decision H3, AD-1, `H3-SURFACES`, AC20, AC21; `user-story.md` US-AC11; research `research/2026-11-14T18-00-refresh-research.md` sections 1.1 and 2.7.

## Required References

- Main plan `plan.2026-10-30T18-39.md` in this folder: `## Terms` (`<FEATURE>`, `MB`, `SCRATCH`, `GATE-RUN`, `LEDGER-STEP`, `GUARD-SUITE`, `LAST-PLAN-CRITERIA`, artifact `Plan:` rule).
- Tool routes, the test-execution launcher, sibling-worktree command shapes and contract tests: `.claude/skills/execution-environment/SKILL.md` (not restated).

## Execution Order

The orchestrator delegates this plan after the main plan completes; it is independent of the branch plan and may run before or after it. Every artifact carries `Plan: plan-h3-sync-writer-retirement.md`.

## Terms

- `SCRATCH`: `<session scratchpad>/issue-1032/`, as in the main plan.
- `WRITER-TOKENS`: the fixed-string tokens `sync-agents-from-instructions` and `syncAgentsFromInstructions`; `GUARD-SUITE` builds them at runtime from parts.
- `H3-REGION-MAP`: the greatest `<FEATURE>/evidence/baseline/h3-ledger-region-map.*.md` (P0-T1); `LEDGER-STEP` applies to any edit it lists as in-region.

## Upstream Assumptions

| ID | Assumption | Task | On mismatch |
| --- | --- | --- | --- |
| UH-1 | The main plan is complete: every task checked and its greatest self-review (`Plan: plan.2026-10-30T18-39.md`) has no FAIL row. | P0-T1 | Stop |
| UH-2 | Every `H3-SURFACES` anchor is present at `MB`: the writer script, template and Pester suite; `drmCopilotExtension.syncAgentsFromInstructions` in `contributes.commands`; `registerSyncAgentsFromInstructionsCommand` and its call in `registerRepoAutomationAdminCommands`; the catalog entries keyed `scripts/dev_tools/sync-agents-from-instructions.ps1` and their tests; the `Dev: Sync AGENTS.md from Instructions` task; the `config/poshqc-shard-weights.json` key; the two README sections; `## [Unreleased]` in `extensions/drm-copilot/CHANGELOG.md`. Child 3 has not edited the writer (owner decision H3). | P0-T1 | Stop |

## Language Classification

| Planned artifact | Change | Classification |
| --- | --- | --- |
| Writer script, its template, its Pester suite | Delete | PowerShell; removed, no new code |
| `repo-automation-command-registration-admin.ts`, `reference-rewrites.ts`, `package.json` and the Jest suites | Edit in place | TypeScript extension-command and push-down code and tests; permitted |
| `push_down_copilot_customizations_rewrites.py` and its test | Edit in place | Existing Python, tolerated (not pushed down) |
| `.vscode/tasks.json`, `config/poshqc-shard-weights.json`, `README.md`, `extensions/drm-copilot/README.md`, `CHANGELOG.md` | Edit | JSON configuration and Markdown |
| `GUARD-SUITE` writer checks | Edit in place | PowerShell test |

No artifact adds Python; nothing pushed down is TypeScript or Python; no hook invokes Python; no case needs an owner language decision.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Gate and Baseline

- [ ] [P0-T1] Confirm UH-1 and UH-2 at `MB`, build `H3-REGION-MAP` for every edit target of Phase 1 (including the four `.vscode/tasks.json` revert blocks of entry 0001), and run fixed-string searches for each `WRITER-TOKENS` token over tracked files outside `docs/features/`.
  - Acceptance: `<FEATURE>/evidence/baseline/h3-recheck.<timestamp>.md` records each assumption as `holds` or `differs` (any `differs` records `blocked: premise_falsified`); `<FEATURE>/evidence/baseline/h3-ledger-region-map.<timestamp>.md` marks each target `in-region` or `outside`; `<FEATURE>/evidence/baseline/writer-reference-baseline.<timestamp>.md` lists each matching file and count.
- [ ] [P0-T2] Capture static baselines: TypeScript (Prettier check, ESLint, `typecheck` script) over the two production files under `extensions/drm-copilot/src` and four Jest suites; Python (Black check, Ruff, Pyright) over `scripts/dev_tools/push_down_copilot_customizations_rewrites.py` and its test; PowerShell (PSScriptAnalyzer and formatter comparison) over `GUARD-SUITE`.
  - Acceptance: one artifact per step, `<FEATURE>/evidence/baseline/h3-static-baseline-<language>-<step>.<timestamp>.md`, each with `Timestamp:`, `Command:`, `EXIT_CODE:` and the finding count in `Output Summary:`.
- [ ] [P0-T3] Run the pytest `Phase 0 baseline` `GATE-RUN` over `tests/scripts` and the other configured test roots with line and branch coverage and a JSON report under `SCRATCH`.
  - Acceptance: `<FEATURE>/evidence/baseline/h3-pytest-baseline.<timestamp>.md` records pass and fail counts, repository-wide coverage, and line and branch coverage of `scripts/dev_tools/push_down_copilot_customizations_rewrites.py`.
- [ ] [P0-T4] Run the Jest `Phase 0 baseline` `GATE-RUN` of `extensions/drm-copilot` with coverage.
  - Acceptance: `<FEATURE>/evidence/baseline/h3-jest-baseline.<timestamp>.md` records pass and fail counts and the line and branch coverage of `src/repo-automation-command-registration-admin.ts` and `src/lib/push-down/reference-rewrites.ts`.
- [ ] [P0-T5] Run the Pester `Phase 0 baseline` `GATE-RUN` over the scan folders of `config/poshqc-scan.json`.
  - Acceptance: `<FEATURE>/evidence/baseline/h3-pester-baseline.<timestamp>.md` records `ExitCode`, pass and fail counts (including `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` as the pre-deletion record), repository-wide line coverage, and the line coverage of `scripts/dev-tools/sync-agents-from-instructions.ps1` or `not in coverage population` when `config/poshqc-coverage.json` does not derive it.

### Phase 1 — Retire the Writer

- [ ] [P1-T1] Delete `scripts/dev-tools/sync-agents-from-instructions.ps1`, `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1` and `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` (which asserts only the writer and its template identity, so it is deleted with them), and remove the key `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` from `config/poshqc-shard-weights.json`. `PoshQC.ShardWeights.Tests.ps1` reads in-memory documents and is unchanged; the shard completeness count follows discovery.
  - Acceptance: Glob returns no file for the three paths; `config/poshqc-shard-weights.json` parses and holds no `WRITER-TOKENS` token; `PoshQC.ShardWeights.Tests.ps1` passes.
- [ ] [P1-T2] Remove the extension command: delete `registerSyncAgentsFromInstructionsCommand` and its call in `registerRepoAutomationAdminCommands`, drop `executeBundledScript` from that file's `./command-runtime` import (`getWorkspaceRoot` stays), and delete the `contributes.commands` entry in `extensions/drm-copilot/package.json`. Asserting tests deleted because they assert only the removed command: `activate registers drmCopilotExtension.syncAgentsFromInstructions` in `extension.test.ts` and in `extension.workflow-commands.test.ts`, `syncAgentsFromInstructions runs the bundled PowerShell template against the active workspace root` in `extension.integration.test.ts`, `syncAgentsFromInstructions runs the bundled PowerShell script with the workspace root` in `extension.workflow-commands.test.ts`. Unchanged (unaffected): `repo-automation-command-registration-admin.test.ts`, `registers the seven existing command ids and the six new ones`, `test_cli_reference_lists_every_discovery_mcp_tool_and_command`, and the `coverageThreshold` entry for the admin file; no test counts `contributes.commands`.
  - Acceptance: the three extension suites and `repo-automation-command-registration-admin.test.ts` pass; the five edited files hold no `WRITER-TOKENS` token.
- [ ] [P1-T3] Remove the catalog entry keyed `scripts/dev_tools/sync-agents-from-instructions.ps1` from `buildRewriteCatalog` in `reference-rewrites.ts` (doc comment: six Python catalog entries) and the matching `RewriteTarget` from `build_rewrite_catalog` in `push_down_copilot_customizations_rewrites.py`. Behavior: a pushed-down file naming the script keeps the reference and reports it unmatched. Tests: `contains all seven catalog entries keyed by normalized reference` becomes `contains all six catalog entries keyed by normalized reference` without the key (updated); `rewrites the sync-agents-from-instructions reference` and `test_sync_agents_script_reference_rewrites_to_live_command` are deleted (assert only the removed rewrite); `reports unmatched references without rewriting them, in first-seen order`, `test_push_down_reports_unmatched_script_references_without_rewrite`, `test_build_rewrite_catalog_contains_expected_command_targets` and `test_rewrite_text_references_reports_unique_unmatched_references` are unchanged (other keys).
  - Acceptance: `reference-rewrites.test.ts`, `test_push_down_copilot_customizations_rewrites.py` and `test_push_down_copilot_customizations_helpers.py` pass, including `contains all six catalog entries keyed by normalized reference`; the four edited files hold no `WRITER-TOKENS` token.
- [ ] [P1-T4] Remove the task labelled `Dev: Sync AGENTS.md from Instructions` from `.vscode/tasks.json`, applying `LEDGER-STEP` when `H3-REGION-MAP` lists it in-region. No test reads the repository `tasks.json` (`test_validate_json.py`, `test_json_config.py` and `json-config.test.ts` build their own fixtures; unchanged).
  - Acceptance: `.vscode/tasks.json` parses, holds no `Sync AGENTS.md` and no `WRITER-TOKENS` token, and has one `"label":` fewer than at `MB`; `LEDGER-CHAIN-TESTS` pass.
- [ ] [P1-T5] Update documentation: remove the command item under `Customization conversion and publishing:` and `### Sync AGENTS.md from instructions` from `README.md`; remove the item from `## VS Code Commands` and `## Sync AGENTS.md from Instructions` from `extensions/drm-copilot/README.md`; add `### Removed` under `## [Unreleased]` in `extensions/drm-copilot/CHANGELOG.md` with one entry stating that the `Sync AGENTS.md from Instructions` command and its bundled script were removed by issue #1032 because `AGENTS.md` is hand-authored (no `WRITER-TOKENS` token).
  - Acceptance: both READMEs hold no `WRITER-TOKENS` token and no `Sync AGENTS.md from`; the CHANGELOG holds `### Removed` and `Sync AGENTS.md from Instructions` between `## [Unreleased]` and the next `## [` heading.
- [ ] [P1-T6] Extend `GUARD-SUITE` with checks `CLR-WRITER-FILES-ABSENT` (the three deleted paths absent), `CLR-WRITER-COMMAND-ABSENT` (no `WRITER-TOKENS` token in `package.json`, the admin file, `reference-rewrites.ts`, the Python rewrites module, `.vscode/tasks.json`, `config/poshqc-shard-weights.json`) and `CLR-WRITER-CHANGELOG` (the `### Removed` entry under `## [Unreleased]`), each a pure function over reader-seam text with one `-REJECTS` negative case, tokens built at runtime.
  - Acceptance: `GUARD-SUITE` passes in the task check, including every `-REJECTS` case, and holds no `WRITER-TOKENS` literal.
- [ ] [P1-T7] [phase-gate] Run stages 1 to 6 across the repository per `## Test Cadence (Mandatory)`, with the unit stage as the three `PARALLEL-GATES` runs, writing `<FEATURE>/evidence/qa-gates/phase-gate.P1.<timestamp>.md`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase-gate.P1.<timestamp>.md` carries `Plan: plan-h3-sync-writer-retirement.md` and one clean pass of every stage.

### Phase 2 — Final QA, Evidence and Self-Review

- [ ] [P2-T1] Run the final static loop per language over the files this plan changed under `extensions/drm-copilot/src`, `extensions/drm-copilot/test`, `scripts/dev_tools` and `tests/scripts` (TypeScript, Python, PowerShell as in P0-T2), restarting from the format step on any failure or change.
  - Acceptance: `<FEATURE>/evidence/qa-gates/h3-final-static-<language>.<timestamp>.md` per language records each step's command, exit code 0 and zero findings.
- [ ] [P2-T2] Run the pytest, Jest (`extensions/drm-copilot`) and Pester (`config/poshqc-scan.json` folders) `GATE-RUN`s with coverage.
  - Acceptance: `<FEATURE>/evidence/regression-testing/h3-pytest-final.<timestamp>.md`, `h3-jest-final.<timestamp>.md` and `h3-pester-final.<timestamp>.md` each record zero failures, the pass count and coverage; the Pester record shows `GUARD-SUITE` and `LEDGER-CHAIN-TESTS` passing and no run of the deleted suite.
- [ ] [P2-T3] Write the coverage comparison for `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts`, `extensions/drm-copilot/src/lib/push-down/reference-rewrites.ts` and `scripts/dev_tools/push_down_copilot_customizations_rewrites.py` from P0-T3, P0-T4 and P2-T2: per file the baseline and final line and branch percentages and the changed-line result (`no added lines` for removal-only edits); a whole-file decrease caused by removing covered code is recorded, not failed.
  - Acceptance: `<FEATURE>/evidence/qa-gates/h3-coverage-delta.<timestamp>.md` shows per file final line coverage of at least 85%, branch coverage of at least 75%, and no regression on changed lines.
- [ ] [P2-T4] Classify every `WRITER-TOKENS` hit of a repeat of the P0-T1 search as `historical` (`docs/research/`) or `example` (`.github/agents/atomic_planning.agent.md`, `.github/agents/powershell-atomic-planning.agent.md` and their bundle copies); list added files and any `LEDGER-RECORDS` file this plan modified with its commit subject tokens; write the completion record.
  - Acceptance: `<FEATURE>/evidence/other/writer-reference-classification.<timestamp>.md` lists every hit with zero unclassified and none in a file Phase 1 edited; `<FEATURE>/evidence/qa-gates/h3-end-state.<timestamp>.md` records no added `*.py` file, no pushed-down TypeScript or Python, and a `reduction:` token for every modified ledger entry; `<FEATURE>/evidence/other/plan-completion-h3.<timestamp>.md` records the completion.
- [ ] [P2-T5] Check off AC20, AC21 and US-AC11; when the greatest `plan-completion-branch.*.md` exists, also check off `LAST-PLAN-CRITERIA` against the three plans' gate, coverage and end-state artifacts, writing `<FEATURE>/evidence/other/plan-order.<timestamp>.md` (E3 result path, selected branch, order of the executed plans).
  - Acceptance: AC20, AC21 and US-AC11 are `[x]`; `LAST-PLAN-CRITERIA` are `[x]` exactly when the branch completion record exists, with the plan-order record written.
- [ ] [P2-T6] Walk the policy-audit, code-review and feature-audit templates under `docs/features/templates/policy_audit/` against this plan's commits.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` carries `Plan: plan-h3-sync-writer-retirement.md` and one PASS, FAIL or N/A row per checklist item with no FAIL row; a FAIL is fixed and the loop restarts at P2-T1.

## Spec Traceability

| Spec element | Task | Check that fails if broken |
| --- | --- | --- |
| Execution Preconditions H3 anchor re-check; owner decision H3 | P0-T1 | Phase 0 stop |
| `H3-SURFACES` script, template, Pester suite; AC20 file clause | P1-T1 | `CLR-WRITER-FILES-ABSENT` |
| Shard-weight key | P1-T1 | `CLR-WRITER-COMMAND-ABSENT` |
| Extension command and `package.json` entry; AC20 | P1-T2 | `CLR-WRITER-COMMAND-ABSENT`; extension suites |
| Rewrite catalog entries (TypeScript and Python); unmatched-reference behavior | P1-T3 | `contains all six catalog entries keyed by normalized reference`; `reports unmatched references without rewriting them, in first-seen order` |
| VS Code task | P1-T4 | `CLR-WRITER-COMMAND-ABSENT` |
| README sections; `### Removed` CHANGELOG entry | P1-T5 | `CLR-WRITER-CHANGELOG`; P1-T5 acceptance |
| Invariant "no script, command or task writes `AGENTS.md`" | P1-T1 to P1-T4 | `CLR-WRITER-*` checks |
| AC21; `STALE-REFERENCE-CLASSES` `historical` and `example` | P2-T4 | classification acceptance |
| AC16 (H3 files); AC17; AC18; AC19 | P0-T3 to P0-T5, P2-T1 to P2-T4 | gate runs; coverage delta; `FileSizePolicy.RepoGate.Tests.ps1` |
| AC4 order record; `LAST-PLAN-CRITERIA` | P2-T5 | plan-order record |

## Pre-Mortem

- Review checklists: a removed extension command needs a changelog entry and a classification of remaining references; P1-T5 adds `### Removed`, P2-T4 classifies every writer hit, and P2-T6 walks all three templates.
- Coverage: the edits only remove code from `repo-automation-command-registration-admin.ts`, `reference-rewrites.ts` and `push_down_copilot_customizations_rewrites.py`; P2-T3 records baseline and final values per file and requires no regression on changed lines with at least 85% line and 75% branch; the deleted PowerShell leaves the denominator.
- Mirror parity: the template is deleted with its source in P1-T1; no fact of the execution-environment brief changes (it names neither the writer nor its command, job, route or budget), so no brief-update task applies; the ledger step is P1-T4 under `LEDGER-STEP` when `H3-REGION-MAP` lists the task in-region.
- File size: every edit removes lines except the `GUARD-SUITE` extension, which stays under 500 lines; `FileSizePolicy.RepoGate.Tests.ps1` runs in each Pester gate.
- Test isolation: one `Invoke-PoshQCParallelTest`, one `pytest -n auto` and Jest through its normal workers at baseline, phase gate and final QA, each re-run only after a fix; no serial, single-process, shuffled or reversed run.
- CI-only behavior: the deleted Pester suite leaves the shard completeness count through discovery; `GUARD-SUITE` uses `Join-Path` and exact-case paths; `LEDGER-CHAIN-TESTS` run in the PowerShell shards and in the P1-T4 task check.
- Evidence: every artifact is `<name>.<timestamp>.md` under `<FEATURE>/evidence/<kind>/`, stamped at write time, append-only, carrying `Plan:`; scratch locations are recorded as `SCRATCH`.
