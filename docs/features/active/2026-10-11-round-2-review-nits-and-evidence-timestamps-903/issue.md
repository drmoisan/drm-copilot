# Round-2 review nits and evidence timestamps (Issue #903)

- Work Mode: minor-audit
- Issue: #903
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/903
- Branch: bug/round-2-review-nits-and-evidence-timestamps-903
- Lifecycle record: docs/features/potential/promoted/2026-10-11-round-2-review-nits-and-evidence-timestamps.md (on ref origin/docs/followups-2026-10-11; cited, not copied)

## Problem / Why

Issue #903 has two parts.

- **P7 (evidence timestamps).** Evidence filenames under `<FEATURE>/evidence/<kind>/` carry the plan-time stamp instead of the time each file is written, and internal `Timestamp:` lines mix time zones within one feature folder. The canonical rule (`.claude/skills/evidence-and-timestamp-conventions/SKILL.md:49`) says the `Timestamp` value is *local* time and says nothing about the filename stamp. `sh`/WSL `date` reads UTC and Windows `Get-Date` reads local time (-04:00), so both zones appear in the #849 evidence. No skill tells planners to fix a plan-time stamp, but planners do so on their own, reading `atomic-plan-contract` `:204` (no placeholders in asserted tokens) and `:213` ("Fix the evidence in the plan") as requiring it. Executors then follow those paths verbatim. Samples: #849, #841, #846 (a composed stamp `2026-10-09T09-00` that matches no write time), #744, #519, #675, #670, #559. #847 already uses the write-time placeholder form successfully.
- **P8 (review notes).** Accepted non-blocking review notes from round-2 items #793, #797, #845, #846, #565, #736, #732, and #737 remain open. The research inputs verified each note's current location and selected either a fix or a no-change disposition.

Research inputs:
- `research/p7-evidence-timestamps-903.2026-10-11T15-05.md`
- `research/p8a-review-nits-793-797-845-846-903.2026-10-11T11-00.md`
- `research/p8b-review-nits-565-736-732-737-903.2026-10-11T10-52.md`

The research agents could not read a host clock. The research filename stamps are estimates, not clock readings.

## Implementation Intent

- **P7.** Edit the six `evidence-and-timestamp-conventions` copies (three root surfaces `.claude`, `.agents`, `.github` and their three bundle mirrors under `extensions/drm-copilot/resources/`). Replace the local-time sentence with a UTC sentence and add a `### Evidence Filename Timestamp` subsection inside `## ISO-8601 Timestamp Format`. Add `## Evidence Filename Timestamps in Plans` to the six `atomic-plan-contract` copies. The filename shape `yyyy-MM-ddTHH-mm` stays unchanged with no zone suffix, so no parser changes. Plan files (America/New_York, stamped by feature-folder tooling) and the review artifact set (shared stamp, enforced by `validate-feature-review-coverage.ps1:412-425`) are excluded from the rule. Update `TIMESTAMP_SOURCE_BLOCK` and add `tests/scripts/dev_tools/test_evidence_timestamp_contracts.py`. Do not rename existing evidence files. Do not edit personas, hooks, parsers, or policy documents.
- **P8.** Apply the fixes selected in the P8a/P8b research (see `## Note Dispositions`). Each fix is pinned by a named test or a concrete observation. Notes with a no-change recommendation get a recorded disposition and reason only. #846 CR-7 gets a superseding correction note; the timestamped #846 artifact is not edited.
- Only #797 CR-1, #565 CR-8, #565 CR-2, #736 O-4, #732 CR-2, and #732 CR-6 change production behavior. All other fixes change test structure, diagnostics, comments, or documentation. For those, the plan records a fail-before exception (precedent: #846 spec A8).

## Acceptance Criteria

### P7 — Evidence-timestamp conventions

- [x] AC-1: In all six `evidence-and-timestamp-conventions` `SKILL.md` copies (`.claude/skills/`, `.agents/skills/`, `.github/skills/`, and their mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/`, `extensions/drm-copilot/resources/customizations/.github/skills/`), the `## ISO-8601 Timestamp Format` section states that the `Timestamp` value is UTC read from the host system clock and is written without a zone suffix. It names the UTC clock commands, and the section no longer contains `local time`. Pinned by `test_evidence_skill_states_utc_timestamp_source` and `test_evidence_skill_omits_local_time_wording` in `tests/scripts/dev_tools/test_evidence_timestamp_contracts.py`.
- [x] AC-2: The same section in all six copies contains a `### Evidence Filename Timestamp` subsection. It states that the filename stamp of every artifact under `<FEATURE>/evidence/<kind>/` is the UTC time at which that file is written and is never a plan-time stamp. It states that plans name such artifacts `<name>.<timestamp>.md`, and that a consuming task selects the lexicographically greatest file matching `<name>.*.md`. It states that plan files and the review artifact set (`policy-audit`, `code-review`, `feature-audit`, `remediation-inputs`) are outside the rule, and that existing evidence files whose names carry a plan-time stamp are not renamed. Pinned by `test_evidence_skill_requires_write_time_filename_stamp`.
- [x] AC-3: Each evidence-skill root copy is byte-identical to its bundle mirror (`test_edited_surface_matches_bundled_mirror` in `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`). The UTC sentence and the `### Evidence Filename Timestamp` text are the same in the `.claude`, `.agents`, and `.github` copies, verified by the parametrized tests in AC-1 and AC-2 asserting the same fragments on all three.
- [x] AC-4: All six `atomic-plan-contract` `SKILL.md` copies contain a `## Evidence Filename Timestamps in Plans` section. It states that plans name evidence artifacts `<name>.<timestamp>.md`, never fix a plan-time stamp in an evidence filename, and identify consumed artifacts by the derivation in `evidence-and-timestamp-conventions`, and that asserted search tokens remain concrete. Pinned by `test_atomic_plan_contract_forbids_plan_time_evidence_stamp` (three root copies) and `test_atomic_plan_contract_matches_bundled_mirror` (three source/bundle pairs, byte identity asserted unconditionally).
- [x] AC-5: `TIMESTAMP_SOURCE_BLOCK` in `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` is updated to the UTC sentence, or moved with its test into the new module (one option, not both), and `test_evidence_skill_states_timestamp_system_clock_source` passes against the edited skills.
- [x] AC-6: `tests/scripts/dev_tools/test_evidence_timestamp_contracts.py` exists with the five tests named in AC-1, AC-2, and AC-4. Evidence records tests 1-4 failing (exit code 1) before the skill edits and passing (exit code 0) after them.
- [x] AC-7: No existing evidence file is renamed or deleted. `git diff --name-status origin/main` lists no `R` or `D` entry under `docs/features/**/evidence/**`. No P7 edit touches `.claude/agents/atomic-planner.md`, `.claude/agents/atomic-executor.md`, `.codex/agents/*.toml`, `.github/agents/*.agent.md`, `.claude/hooks/**`, `.codex/hooks/**`, `scripts/dev_tools/pr_context/**`, `extensions/drm-copilot/src/lib/pr-context/**`, or the feature-folder/plan stamp tooling.

### P8 — Review notes

#793 (`tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py`)

- [x] AC-8: #793 L20 — `test_enum_site_accepts_every_valid_string_status` is parametrized over `sorted(validator.VALID_MERGE_STATUS)` with one node per status and a per-status assertion message. A fail-before exception is recorded (test-structure change).
- [x] AC-9: #793 L21 — `test_completion_site_reports_non_string_merge_status` is parametrized on `value` only over a new `NON_STRING_ROWS` constant (ids `list`, `dict`, `int`, `bool`), the unused `expected_repr` column is removed from it, and `VALUE_ROWS` remains in use by `test_enum_site_reports_non_string_merge_status`. A fail-before exception is recorded.
- [x] AC-10: #793 L22 — The no-change disposition and its reason are recorded in `## Note Dispositions` of this file.

#797

- [x] AC-11: #797 CR-1 — `is_file_shaped_component` in `scripts/dev_tools/_blast_radius_token_shapes.py` and `Test-FileShapedComponent` in `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` reject a non-ASCII extension before lower-casing. The pattern text and `.claude/rules/parallel-orchestration.md` are unchanged, and the bundled PSM1 mirror is byte-identical (`git diff --no-index --exit-code`). Rows `kelvin-sign-extension` and `dotted-capital-i-extension` (built with `chr(...)` / `[char]0x...`) expecting `False` are added to `FILE_SHAPE_CASES` in `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` and to `Predicate cases` in `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1`. The fail-before outcome observed for each row in each runtime is recorded. The research expectation (Kelvin fails in both runtimes; dotted capital I fails in Pester only) is unverified reasoning. `test_blast_radius_parity.py`, `test_blast_radius_historical_runs.py`, and `BlastRadius.HistoricalRuns.Tests.ps1` pass with no pinned corpus value changed.
- [x] AC-12: #797 CR-4 — The bare `assert` statements at the review-cited lines of `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` carry messages naming expected and observed values. The literal `18` is unchanged. A fail-before exception is recorded.

#845 (`tests/scripts/dev_tools/test_workflow_npm_token_guard.py`)

- [x] AC-13: #845 CR-1 — Patterns and finder helpers move to a new `tests/scripts/dev_tools/npm_token_guard_test_support.py`, test functions stay in `test_workflow_npm_token_guard.py`, and both files are under 500 lines. A comparison of `pytest --collect-only -q` node-id sets before and after shows every pre-split id present afterward, plus only the residual ids added under AC-14 and AC-15.
- [x] AC-14: #845 CR-2 — `test_find_npm_token_assignments_pins_documented_residuals` pins the residual rows `residual-single-equals-shell-test-reported` (`[1]`), `residual-bash-regex-match-reported` (`[1]`), and `residual-bash-append-not-reported` (`[]`), with a docstring citing the #845 spec non-goal. A fail-before exception is recorded (characterization rows).
- [x] AC-15: #845 CR-3 — The same test pins `accepted-double-equals-narrowing-not-reported` (`NPM_TOKEN==value` -> `[]`), with a docstring citing the #845 backward-compatibility section. A fail-before exception is recorded.

#846

- [x] AC-16: #846 CR-1 — `test_main_returns_one_with_qt009_when_git_exits_nonzero` in `tests/scripts/dev_tools/test_check_quality_tiers.py` is parametrized on `empty-stderr` and `whitespace-only-stderr` and asserts the exact line `QT009: cannot list tracked files: git ls-files exited with code 128`. That literal is the research-corrected form; the review literal omitted the prefix. A fail-before exception is recorded.
- [x] AC-17: #846 CR-2 — `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` replaces each `[^}]*` assertion with an indentation-bounded `Get-BraceBlockText` block check (non-empty, `::error::` followed by `exit 1`). Pass evidence comes from the CI `poshqc-test-results` artifact.
- [x] AC-18: #846 CR-3 — The duplicated `exit 1` assertions in the poll-step It block of the same file are consolidated into one It block, and the other It block keeps its `exit 0`, `$LASTEXITCODE`, exact-version, and ref-guard assertions. Pass evidence comes from CI.
- [x] AC-19: #846 CR-4 — The same file asserts that the poll-step `if:` is inline (`'^\s+if:\s*[^\s>|]'`). Pass evidence comes from CI.
- [x] AC-20: #846 CR-5 — In `extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts`, the `CommandHandler` type alias is moved below the imports and the third test has an `// Assert` marker. The file's Jest suite passes.
- [x] AC-21: #846 CR-6 — `extensions/drm-copilot/test/subagent-tree-command-test-support.ts` uses `WORKSPACE_ROOT = "C:\\Users\\example\\repos\\drm-copilot"` and `MATCHING_DIR = "c--users-example-repos-drm-copilot"`. `subagent-tree-command.test.ts` and `subagent-tree-command.quick-pick.test.ts` pass.
- [x] AC-22: #846 CR-7 — A superseding note `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/other/closure-dispositions-correction.<timestamp>.md` exists. It names #903, quotes the prior rationales for `#734 CR-1` and `#723 N3` verbatim, and gives the corrected text. `git diff --stat origin/main` shows no change to `closure-dispositions.2026-10-09T09-00.md`. The disposition is recorded in `## Note Dispositions`.

#565

- [x] AC-23: #565 CR-8 — In both `{.claude,.codex}/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` and their bundle mirrors, the issue-number lookup uses the keyed form only when a cited folder matches no record, and keeps the bare-hash fallback when zero folders are cited. New `M8f` rows (epic and parallel legs) in both `enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1` suites expect `deny` with predicate `target-record`. Existing `M8`, `M8h`, `M8m`, and the mode-resolution "resolves the target by issue_num" row still pass. The fail-before (allow on current code) is derived from code reading and must be confirmed by a run.
- [x] AC-24: #565 CR-9 — The no-change disposition is recorded in `## Note Dispositions`, citing `evidence/other/spec-deviation-gate-main-files.2026-10-08T21-02.md` in the #565 folder. Neither gate main file is edited.
- [x] AC-25: #565 CR-2 — The `Find-FeatureFolderCandidate` trim set in all four `feature-folder-resolution.ps1` copies adds `)`, `]`, `>`, `*`, `_`, and the doc comment is updated. Both `feature-folder-resolution.Tests.ps1` suites extend `S06` with these characters plus composite rows `(docs/features/active/x)` -> `x` and `**docs/features/active/x**` -> `x`. `H01` (Claude/Codex SHA256 equality) passes.
- [x] AC-26: #565 CR-6 — The no-change disposition and reason (the catch bodies are executed by the #786 `hook-import-failure-exemptions.FailClosed.Tests.ps1` suites) are recorded in `## Note Dispositions`. The CI per-file coverage result for the nine catch-body lines is recorded, and any line still uncovered is listed under `## Operator Follow-ups` for the owning epic rather than tested here.

#736

- [x] AC-27: #736 O-4 — `.claude/hooks/enforce-completion-consistency.ps1` and its bundle mirror define `Invoke-CompletionConsistencyEntryPoint`, which converts any exception into a deny decision carrying `COMPLETION_CONSISTENCY_BLOCKED`. The script tail calls it, and the three S1 tail statements checked by `HookGuardShape.Helpers.ps1` are unchanged. Two new rows in the `Entrypoint transport` context of `tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1` cover a throwing reader (deny, no throw) and a benign payload (allow).

#732 (`enforce-orchestration-preimplementation-gate-targets.ps1`, four copies)

- [x] AC-28: #732 CR-2 — The `GIT_*` relocation check uses an identifier-boundary regex on the raw segment text. `U11` is kept. New `U11b` rows (`git add docs/legit_dir-notes.md`, `MY_GIT_DIR=1 git add a.ps1`) resolve. `U11c` (`$env:GIT_DIR=...`) yields `git-relocation`. `U11d` records that a standalone-word mention still denies. The four-copy parity suite passes.
- [x] AC-29: #732 CR-3 — A shared `Resolve-OrchestrationEpicTargetOutcome` (readiness predicate injected as a script block) replaces the duplicated epic-scope tails in both `enforce-orchestration-preimplementation-gate-epic-scope.ps1` files. New targets rows cover each outcome, including an exact-string assertion for the session-root deny reason. The EpicScope and EpicScopeTargets suites pass unchanged on both surfaces. If the full preimplementation-gate suite set does not pass on both surfaces, the fix is deferred and the deferral is recorded in `## Note Dispositions`.
- [x] AC-30: #732 CR-4 — No line in any targets copy exceeds 120 characters after the change. Emitted deny-reason text is byte-identical (existing targets, EpicScopeTargets, and parity suites pass).
- [x] AC-31: #732 CR-5 — `Get-OrchestrationTargetResult` is renamed to `New-OrchestrationTargetResult` in all four copies with a justified `PSUseShouldProcessForStateChangingFunctions` suppression. A case-insensitive search for `Get-OrchestrationTargetResult` outside `docs/` returns no match. `run_poshqc_analyze` reports zero findings for the four copies.
- [x] AC-32: #732 CR-6 — `Get-OrchestrationGitSelectorTarget` returns `Rule = 'git-command-word-missing'` when the token array has no `git`. A new targets row with `-Token @('status')` pins it.
- [x] AC-33: #732 CR-9 — `.agents/skills/epic-plan/SKILL.md` `## Integration Commit Form` and its bundle mirror document the one-paragraph multi-message trailer form. `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` asserts `one-paragraph multi-message form`, and the bundle parity pytest passes.

#737

- [x] AC-34: #737 F-1 — `Get-EpicStateIsolationDirectCommand` in `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` treats conditional, loop, try, and trap ancestors as nested, except the exact single-clause `if (Get-Command <Name> ...)` guard whose name matches the mocked target. New rows in `enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1` cover `if ($false) { Mock ... }` (finding), `try { Mock ... }` (finding), the matching guard and helper shapes (no finding), and a mismatched name (finding). Withhold condition: if the full-population run of `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` raises any new finding in a suite owned by #901 or by the concurrent epic `subagentstop-envelope`, that suite is not edited, F-1 is withheld, and the withhold is recorded in `## Note Dispositions` and `## Operator Follow-ups`.
- [x] AC-35: #737 F-2 — `Get-EpicStateIsolationHookDotSource` no longer falls back to the first dot-source, and `Get-EpicStateIsolationFinding` emits `no dot-source loads the hook` when dot-sources exist but none is identified. A new Branches row pins it, and the AC-8 rows in `enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1` still pass. Withhold condition: the same as AC-34.
- [x] AC-36: #737 F-3 — The no-code-change disposition and reason are recorded in `## Note Dispositions`. A header paragraph in `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` states the `hooks/<name>.ps1` literal-convention limit, and the detector follow-up is listed under `## Operator Follow-ups`.
- [x] AC-37: #737 F-4 — The `DEV-2` row in `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` iterates every candidate tool name admitted by the `enforce-epic-wave-barrier.ps1` registrations and fails on any non-null decision. No production file is changed.
- [x] AC-38: #737 F-5 — `tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1` defines `Assert-FamilySetEqual`, uses it in the equality rows (`Should -Not -Throw`) and the divergent row (`Should -Throw`), and the `AC-19` no-interpreter row still passes.
- [x] AC-39: #737 F-6 — The no-code-change disposition and reason are recorded in `## Note Dispositions`. Header lines in `EpicStateIsolation.Discovery.Helpers.ps1` name `$script:EpicStateParseCache` as a deliberate, deterministic, test-session-only exception.
- [x] AC-40: #737 N-1 — The stale parenthetical referring to a nonexistent scan-root rows file is removed from the header of `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1`.
- [x] AC-41: #737 N-2 — The `Register-EpicStateBaselineMock` comment in `EpicStateIsolation.Baseline.Helpers.ps1` documents `-Surface 'Codex'` semantics. `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` is unchanged (`git diff --stat` shows no change).
- [x] AC-42: #737 I-3 — The no-change disposition and reason are recorded in `## Note Dispositions`. None of the four 500-line files listed in the P8b research is modified.

### Cross-cutting

- [x] AC-43: No production or test file created or modified by this item exceeds 500 lines (Markdown exempt). This includes `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1`, `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`, and the targets file, verified by a line count recorded in evidence.
- [x] AC-44: No file under `.claude/rules/` or `.github/instructions/` is modified (`git diff --name-only origin/main` lists none).
- [x] AC-45: No enforcement hook under `.claude/hooks/` or `.codex/hooks/` gains a Python invocation. The existing no-Python-invocation suites (`enforcement-hooks-no-python-invocation.Tests.ps1`) pass.
- [x] AC-46: Python toolchain passes on all changed Python files: `poetry run black --check`, `poetry run ruff check`, `poetry run pyright`, and `poetry run pytest -q` (full suite). Line coverage is at least 85% and branch coverage at least 75% for `scripts.dev_tools._blast_radius_token_shapes`.
- [x] AC-47: TypeScript toolchain passes from `extensions/drm-copilot` on the changed test files: `npx prettier --check`, `npx eslint`, `npx tsc -p tsconfig.jest.json --noEmit`, and `npx jest` for the affected suites.
- [x] AC-48: PowerShell toolchain passes through the PoshQC MCP tools only (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`) on every changed `.ps1`/`.psm1` file and suite, with no sh/bash/pwsh wrapper. Per-test results and per-file line coverage (at least 85%) for changed production PowerShell files are taken from the PR CI Pester artifacts and recorded in evidence.
- [x] AC-49: Every edited file with a bundle mirror under `extensions/drm-copilot/resources/` is byte-identical to that mirror. `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and `test_minor_audit_acceptance_criteria_contracts.py` pass.
- [x] AC-50: No edit touches the passages or files reserved in `## Concurrency Constraints`. `git diff origin/main` shows no change to `.claude/hooks/enforce-pr-author-skill*.ps1` or Codex counterparts, and no change to scratch-file guidance or CI-gate passages in orchestration skills.

## Dependencies / Risks

- **Shared files with #899.** `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` (P7 edits `:89-93`; #899 CI-gate tests are at `:139-239`) and `.agents/skills/epic-plan/SKILL.md` (#732 CR-9 edits near line 74; #899's `requires_ci_gate` passage is at line 163). The hunks are separate, but blast radius reports `same_file`, so the plan must sequence or flag them.
- **`publish-mcp-npm.yml`.** #846 CR-2/CR-4 assertions read this workflow. If #899 changes its error blocks or poll `if:`, re-run `PublishMcpNpmWorkflow.Tests.ps1` on the merged result.
- **Concurrent epic `subagentstop-envelope`.** #737 F-1/F-2 change the guard predicate that judges suites in that epic's family (`hook-dependency-failure*`, `hook-import-failure-exemptions.FailClosed.Tests.ps1`, `validate-orchestrator-output*.Tests.ps1`). The withhold condition in AC-34/AC-35 applies. The epic's actual file list was not inspected; the P8b research identifies the owner as likely, not verified.
- **Line budgets.** `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` is at 500 lines and must not be edited. The Claude `-modes.ps1` reaches about 498 after #565 CR-8. `EpicStateIsolation.Helpers.ps1` reaches about 493 after F-1/F-2. `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` is at 500 and is not edited.
- **Behavior tightening.** #565 CR-8 now denies a prompt that cites a renamed folder and carries only a bare `#<n>` (remedy: keyed `issue_num:`). #797 CR-1 narrows acceptance for non-ASCII extensions only.
- **Refactor risk.** #732 CR-3 (medium) refactors a gate decision path and is conditional on the full preimplementation-gate suite set passing on both surfaces.
- **Unverified expectations.** Fail-before outcomes for #797 CR-1, #565 CR-8, #565 CR-2, and #732 CR-2/CR-6 come from code reading and Unicode case-mapping reasoning, not from runs. The executor records observed outcomes.
- **PoshQC MCP output.** MCP results carry no per-test output or coverage text. Per-row and per-file claims for PowerShell depend on CI artifacts.
- **Clock reads for P7-compliant evidence.** The executor reads UTC with `pwsh -NoProfile -Command "Get-Date -AsUTC -Format yyyy-MM-ddTHH-mm"`. If a worktree text guard refuses `pwsh`, it uses `sh -c 'date -u +%Y-%m-%dT%H-%M'`.

## Verification Steps

1. P7: run tests 1-4 of `tests/scripts/dev_tools/test_evidence_timestamp_contracts.py` before the skill edits (expected exit code 1), then run `poetry run pytest tests/scripts/dev_tools/test_evidence_timestamp_contracts.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py -q` after them.
2. P8 Python: black, ruff, pyright, and targeted pytest on the #793, #797, #845, and #846 CR-1 files, with `--cov=scripts.dev_tools._blast_radius_token_shapes --cov-branch` for #797 CR-1. For #845 CR-1, capture `--collect-only -q` before and after and compare node-id sets.
3. P8 TypeScript (from `extensions/drm-copilot`): `npx prettier --check`, `npx eslint`, `npx tsc -p tsconfig.jest.json --noEmit`, `npx jest test/subagent-tree-command.quick-pick.test.ts test/subagent-tree-command.test.ts`.
4. P8 PowerShell: `run_poshqc_format`, `run_poshqc_analyze`, and `run_poshqc_test` on every changed PowerShell file and its suites, including all preimplementation-gate suites on both surfaces (mode-resolution, mode-routing, TargetFolder, WorktreeResolution, EpicScope, EpicScopeTargets, targets, targets parity) and the full-population EpicStateIsolation Discovery suite.
5. Mirrors: `git diff --no-index --exit-code` between each edited source and its bundle mirror, plus the pytest push-down contract suites.
6. Full loop: `poetry run pytest -q`, then read per-test results and per-file coverage from the PR CI artifacts (`poshqc-test-results`, Pester coverage).
7. Observations: `git diff --name-status origin/main` for AC-7, AC-44, and AC-50, and a line count of every changed code file for AC-43.

## Evidence Checklist
- [ ] baseline
- [ ] targeted verification
- [ ] end-state

## Note Dispositions

Source review artifacts (paths relative to `docs/features/active/`):

| Key | Review artifact |
|---|---|
| R793 | `2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/code-review.2026-10-09T01-30.md` |
| R797 | `2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/code-review.2026-10-09T07-51.md` |
| R845 | `2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/code-review.2026-10-09T21-30.md` |
| R846 | `2026-10-08-bug-burndown-2026-09-29-review-nits-846/code-review.2026-10-10T03-00.md` |
| R565 | `2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/code-review.2026-10-08T20-57.md` |
| R736 | `2026-09-27-completion-consistency-codex-copy-and-fail-open-divergence-736/code-review.2026-10-08T22-30.md` |
| R732 | `2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/code-review.2026-10-09T05-42.md` |
| R737 | `2026-09-27-hook-test-isolation-remaining-gaps-737/code-review.2026-10-09T06-46.md` |
| R786 | `2026-09-29-hook-preexisting-imports-fail-open-786/code-review.*.md` (three review passes) |
| R787 | `2026-09-29-validate-orchestrator-output-session-relative-read-787/code-review.2026-10-09T00-12.md` |
| R850 | `2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/code-review.2026-10-09T01-12.md` |

| Note id | Source | Action | Reason or owner |
|---|---|---|---|
| #793 L20 | R793 | fix | Parametrize over `sorted(validator.VALID_MERGE_STATUS)` (AC-8). |
| #793 L21 | R793 | fix | `NON_STRING_ROWS`; drop unused `expected_repr` column (AC-9). |
| #793 L22 | R793 | no action | `build_read_text_stub` is already imported from the sibling test module by three other modules, so the sibling-import form is an established pattern. Moving it would touch at least four test files outside this item's scope. A decoupling refactor into a `*_test_support.py` module is listed under Operator Follow-ups. |
| #793 L24 | R793 | no action | Operator decision 2026-10-11: closed as no action |
| #797 CR-1 | R797 | fix | ASCII guard before lower-casing in Python and PowerShell; pattern and rule unchanged (AC-11). Reviewer option A was rejected because it would edit `.claude/rules/parallel-orchestration.md`, which is owned by #894. |
| #797 CR-2 | R797 | out of scope | Owner: issue #894 (bug-burndown-2026-10-11 run). |
| #797 CR-3 | R797 | no action | Operator decision 2026-10-11: closed as no action |
| #797 CR-4 | R797 | fix | Assert messages (AC-12). |
| #845 CR-1 | R845 | fix | Move detection logic to `npm_token_guard_test_support.py` (AC-13). The reviewer's test-module split was rejected because it adds test-to-test coupling. |
| #845 CR-2 | R845 | fix | Residual rows (AC-14). |
| #845 CR-3 | R845 | fix | `==` narrowing row (AC-15). |
| #846 CR-1 | R846 | fix | Exact QT009 line, with the research-corrected literal (AC-16). |
| #846 CR-2 | R846 | fix | Indentation-bounded block helper (AC-17). |
| #846 CR-3 | R846 | fix | Consolidate duplicated `exit 1` assertions (AC-18). |
| #846 CR-4 | R846 | fix | Inline `if:` assertion (AC-19). |
| #846 CR-5 | R846 | fix | Type alias placement and `// Assert` marker (AC-20). |
| #846 CR-6 | R846 | fix | Neutral `WORKSPACE_ROOT` (AC-21). The related `workspace-encoding.test.ts` paths are listed under Operator Follow-ups. |
| #846 CR-7 | R846 | no action (correction note) | The timestamped artifact `closure-dispositions.2026-10-09T09-00.md` is not edited. A superseding `closure-dispositions-correction.<timestamp>.md` note is added, following #846's own convention of adding superseding summaries rather than editing timestamped evidence (AC-22). |
| #565 CR-2 | R565 | fix | Extend trim set in four copies (AC-25). |
| #565 CR-6 | R565 | no action | Since the review, #786 (PR #881) added in-process tests in both `hook-import-failure-exemptions.FailClosed.Tests.ps1` suites that execute these catch bodies. Those suites belong to the concurrent epic's family. Coverage is confirmed from CI (AC-26). CI result (run https://github.com/drmoisan/drm-copilot/actions/runs/38410234897, `evidence/qa-gates/ps-catch-lines.2026-10-13T14-29.md`): 8 of the 9 catch-body lines covered, 1 uncovered (`.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:41`, also uncovered at baseline); routed under Operator Follow-up 7. |
| #565 CR-8 | R565 | fix | Keyed-only fallback when a cited folder matches no record (AC-23). |
| #565 CR-9 | R565 | no action | Reverting the gate-main edit would reopen #565 CR-1. The deviation is already recorded as accepted in `evidence/other/spec-deviation-gate-main-files.2026-10-08T21-02.md` of the #565 folder. |
| #565 CR-10 | R565 | no action | Operator decision 2026-10-11: closed as no action |
| #736 O-4 | R736 | fix | `Invoke-CompletionConsistencyEntryPoint` fails closed (AC-27). |
| #736 O-5 | R736 | no action | Operator decision 2026-10-11: closed as no action |
| #732 CR-2 | R732 | fix | Identifier-boundary regex (AC-28). |
| #732 CR-3 | R732 | fix (conditional) | Shared epic-target outcome function; deferred and recorded here if the full gate suite set does not pass on both surfaces (AC-29). |
| #732 CR-4 | R732 | fix | Wrap the 14 lines over 120 characters (AC-30). |
| #732 CR-5 | R732 | fix | Rename to `New-OrchestrationTargetResult` (AC-31). |
| #732 CR-6 | R732 | fix | `IndexOf` -1 guard (AC-32). |
| #732 CR-9 | R732 | fix | Document multi-`-m` trailer form in `.agents` epic-plan skill (AC-33). |
| #737 F-1 | R737 | withheld | Conditional ancestors count as nested (AC-34). Withheld if the population run raises a new finding in a #901 or epic-owned suite. Withheld on 2026-10-13: the Discovery suite reported findings for seven suites in CI run 38404520141, and the four F-1/F-2 files were restored to PHASE0 content (commit 4e8d9f92d; `evidence/qa-gates/f1-f2-decision.2026-10-13T13-44.md`). Flagged suites are listed under Operator Follow-up 10. |
| #737 F-2 | R737 | withheld | No first-dot-source fallback (AC-35). Same withhold condition. Withheld together with F-1 on 2026-10-13; every finding carried the F-2 literal `no dot-source loads the hook` (`evidence/qa-gates/f1-f2-decision.2026-10-13T13-44.md`). |
| #737 F-3 | R737 | no action (comment only) | Extending the detector would add a second classifier family and new population members, including suites owned by others, which is out of proportion for this item. A header comment documents the limit (AC-36), and the detector work is an Operator Follow-up. |
| #737 F-4 | R737 | fix | DEV-2 row iterates admitted tool names (AC-37). |
| #737 F-5 | R737 | fix | `Assert-FamilySetEqual` (AC-38). |
| #737 F-6 | R737 | no action (comment only) | Keying by content hash would still be mutable script-scope state, and removing the memo re-parses hook files across about 182 suites. A header note documents the exception (AC-39). |
| #737 N-1 | R737 | fix | Remove stale header parenthetical (AC-40). |
| #737 N-2 | R737 | fix (helper doc only) | The call-site file is at 500 lines, and the same form appears in 195 calls across 25 Claude suites. Only the helper comment is changed (AC-41). |
| #737 I-3 | R737 | no action | No fix in this item touches the four 500-line files, and splitting them now would be an unrelated refactor (AC-42). |
| #786 (all notes) | R786 | out of scope | Owner: concurrent epic `subagentstop-envelope` (branch `epic/subagentstop-envelope-integration`). |
| #787 CR-1 | R787 | out of scope | Owner: concurrent epic `subagentstop-envelope` (branch `epic/subagentstop-envelope-integration`). |
| #787 CR-3 | R787 | out of scope | Owner: concurrent epic `subagentstop-envelope` (branch `epic/subagentstop-envelope-integration`). |
| #787 CR-4 | R787 | no action | Operator decision 2026-10-11: closed as no action |
| #787 CR-7 | R787 | out of scope | Owner: concurrent epic `subagentstop-envelope` (branch `epic/subagentstop-envelope-integration`). |
| #850 (all notes) | R850 | out of scope | Owner: issue #901 (bug-burndown-2026-10-11 run). |

## Ownership of #903 Parts

| Part | Closed by |
|---|---|
| P7 (evidence-timestamp conventions) | This item |
| P8 notes from #793, #797 (CR-1, CR-4), #845, #846, #565, #736, #732, #737 listed above as fix or no action | This item |
| #850 notes | Issue #901 (bug-burndown-2026-10-11 run) |
| #797 CR-2 | Issue #894 (bug-burndown-2026-10-11 run) |
| #786 notes and #787 CR-1, CR-3, CR-7 | Concurrent epic `subagentstop-envelope` (`epic/subagentstop-envelope-integration`) |
| #793 L24, #797 CR-3, #736 O-5, #565 CR-10, #787 CR-4 | Operator no-action closures (2026-10-11) |

Close #903 only after every owner above has delivered. Merging this item alone does not close #903.

## Operator Follow-ups

These items need an operator decision. They are not implemented here, and this item creates no new GitHub issues.

1. **`NPM_TOKEN+=${{ secrets.X }}` gap (#845 research).** The append form escapes all four finders in `test_workflow_npm_token_guard.py`. Closing it (`\bNPM_TOKEN\s*\+?=(?!=)`) changes behavior and reverses a #845 spec non-goal. This item only pins the current behavior (AC-14).
2. **`extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts` host-specific paths (related to #846 CR-6).** About 30 lines carry the host-specific user segment. They are outside the CR-6 scope.
3. **Branch numbering.** Confirm whether `bug/subagentstop-envelope-orchestrator-family-903` is mis-numbered, since it collides with this issue number.
4. **#737 F-3.** Detection of `Join-Path <root-variable> '<name>.ps1'` hook loads and `ProcessStartInfo` suites with variable-built paths.
5. **#737 N-2.** Optional rename of `-Surface` to `-Scope` across all consuming suites (25+ suites, including the concurrent epic's), coordinated with that epic.
6. **#737 F-6.** If test-session memo caches should be a named exception in the PowerShell rule, that is a `.claude/rules/powershell.md` / `.github/instructions/` change outside this item.
7. **#565 CR-6.** Any catch-body line that CI coverage still shows uncovered is routed to the owner of `hook-import-failure-exemptions.FailClosed.Tests.ps1`. CI run 38410234897 shows one such line: `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:41` (`ci` 0).
8. **#732 CR-1 (UNC path leg, Medium).** Not in #903 scope and still open in the current tree.
9. **#793 L22.** An optional refactor that moves `build_valid_epic_state` and `build_read_text_stub` into a `*_test_support.py` module.
10. **#737 F-1/F-2 withhold.** If either fix is withheld under AC-34/AC-35, record the affected suites here for the owning item. Both were withheld (`evidence/qa-gates/f1-f2-decision.2026-10-13T13-44.md`). Suites flagged by the Discovery guard with F-1/F-2 applied, and their owners: `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1` (owner unknown); `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1` (owner unknown, possible #901 link); `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` (concurrent epic `subagentstop-envelope`); `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` (concurrent epic); `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` (#901, inferred); `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` (owner unknown); `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` (concurrent epic).
11. **#737 I-3.** Split the four 500-line test files before their next edit, as the review recommends. The P8b research did not check exhaustively whether other files are also at 500 lines.
12. **Stale `skipif` reason** in `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py:11-15` ("gitignored and unavailable in CI"), which `.gitignore` no longer supports. The new P7 mirror test covers the `atomic-plan-contract` `.agents` pair unconditionally; the skip itself is unchanged.

## Concurrency Constraints

- Keep edits local to the files named in the Acceptance Criteria and the research change lists.
- **#900:** do not touch scratch-file guidance passages in orchestration skills or in the `atomic-planner`/`atomic-executor` personas. P7 makes no persona edit.
- **#901:** do not touch the pr-author hook family (`.claude/hooks/enforce-pr-author-skill*.ps1` and Codex counterparts) or any suite that #901 owns. This includes suites newly flagged by the #737 F-1/F-2 population run.
- **#899:** do not touch CI-gate passages. Shared files flagged by the research:
  - `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`: P7 edits only `TIMESTAMP_SOURCE_BLOCK` (`:89-93`, or `:395-406` if moved); the #899 CI-gate tests are at `:139-239`.
  - `.agents/skills/epic-plan/SKILL.md`: #732 CR-9 edits `## Integration Commit Form` (near line 74); #899's `requires_ci_gate` passage is at line 163.
  - `.github/workflows/publish-mcp-npm.yml`: not edited here. Re-check #846 CR-2/CR-4 assertions if #899 changes it.
- **Concurrent epic `subagentstop-envelope`:** do not edit `validate-orchestrator-output*`, `hook-dependency-failure*`, or `hook-import-failure-exemptions.FailClosed.Tests.ps1` suites.
- **#894:** do not edit `.claude/rules/parallel-orchestration.md` or its mirror.
- Scratch files used by the plan include the issue number, for example `SCRATCH/903/`.
