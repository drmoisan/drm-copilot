# 2026-09-27-orchestration-completion-gate-and-tooling-friction (Spec)

- **Issue:** #744
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-30T03-18
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (acceptance criteria source: this file only; no `user-story.md`)
- **Research:** `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/research/research.2026-09-30T03-25.md`
- **Baseline:** `origin/main` at `ae7c7779` (PR #784 merge), per research

## Context

Friction points in the orchestration tooling recurred across the three parallel runs of 2026-09-25 to 2026-09-27. Each one cost a remediation or relay step. `issue.md` lists nine steps. Research re-verified each against current `main` and classified it as still reproducible, already resolved, investigation-only, or belonging to another item. This spec plans work only for the still-reproducible steps retained in this item (steps 1 on the Codex surface, 3, 5, 6a, and the step 9 documentation sentence). The remaining steps are recorded with evidence in the sections `## Already resolved`, `## Investigation-only findings`, and `## Deferred to other items`, so that no step is dropped silently.

Environment:
- OS/version: Windows 11, Claude Code
- Python version: repository default (Poetry environment)
- Command/flags used: `validate_orchestration_artifacts.py`, the MCP tools, and the parallel-orchestrator merge gate
- Data source or fixture: the followups-2026-09-27 completion report; coordinator observations

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Repro & Evidence

Steps to Reproduce (from `issue.md`):
1. The completion check requires `ci_gate.verified_at`, which the orchestration skill never mentions (#709).
2. The strict completion check demands promotion receipts from items taken in by issue number, which were never promoted in-run (#710).
3. CI-dependent AC check-offs pushed after the parent's merge never reach main. #710's AC-8 commit `81726a3b` was stranded, and the parent cannot commit from the coordinator root. Mitigated in-prompt ("the child owns CI-dependent check-offs and pushes them before reporting done"); not yet codified in the skill.
4. The MCP `run_poshqc_test` tool overwrites the coverage file using the INSTALLED extension's settings, so newly registered files drop out; it takes no settings argument (#707 CR-3).
5. The `feature-review` agent has no MCP artifact validator (#714).
6. `collect_pr_context` pairs a file's last command with its first expected exit code, so intentional fail-before evidence is labelled "fail" (#708). It also listed `#AC-1`..`#AC-4` as auto-close issues (#706 FU-706-8).
7. Local and CI coverage report different missed-line counts (1114 vs 1129), not investigated (#712).
8. The batch-budget hook needs a reset between batches (#709 CR-9).
9. Evidence timestamps run 4-18 minutes later than the commits that contain them (#706 FU-706-6).

Expected: documented, validator-consistent completion requirements; tools that respect the repository's own configuration; evidence labelled correctly.

Actual: as above.

Classification (from research, re-verified against the files cited below):

| Step | Classification in this spec | Section |
|---|---|---|
| 1 (Claude surface) | Already resolved | `## Already resolved` |
| 1 (Codex surface) | In scope, documentation only | Problem 1 |
| 2 | Deferred | `## Deferred to other items` |
| 3 | In scope, documentation/procedure | Problem 2 |
| 4 | Deferred | `## Deferred to other items` |
| 5 | In scope, agent frontmatter and body | Problem 3 |
| 6a | In scope, one Python behaviour change | Problem 4 |
| 6b | Already resolved | `## Already resolved` |
| 7 | Investigation-only | `## Investigation-only findings` |
| 8 | Already resolved | `## Already resolved` |
| 9 (cause) | Investigation-only | `## Investigation-only findings` |
| 9 (documentation sentence) | In scope, documentation only | Problem 5 |

## Problem Statements and Root Causes (retained steps)

### Problem 1 — Step 1, Codex surface: `ci_gate` completion object undocumented

Problem: the Codex orchestrate skill does not name the `ci_gate` object or its required keys, so a Codex-run orchestrator cannot write a checkpoint that passes the completion check from the skill alone.

Evidence:
- All three validators require the same key set. Python: `scripts/dev_tools/validate_orchestrator_state.py:109` declares `CI_GATE_KEYS = ("conclusion", "head_sha", "verified_at")`, enforced by `_validate_completion_ci_gate` (`:192-223`) and invoked at `:472-473` when `route_requires_ci_gate` is true. TypeScript: `extensions/drm-copilot/src/lib/validate/orchestrator-state-completion.ts:29`. PowerShell: `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1:72`.
- `pr_gate` keys: `scripts/dev_tools/_orchestrator_state_routing.py:12` declares `PR_GATE_KEYS = ("pr_number", "pr_url", "head_branch", "head_sha")`.
- `.agents/skills/orchestrate/SKILL.md:436-441` ("CI Green Gate") states only that the checkpoint "must record the checked head SHA and CI result". The completion list at `:284-296` omits `ci_gate` and `pr_gate`. The Codex runtime validates through the TypeScript MCP port, which requires `verified_at`.
- Bundled mirror: `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`.

Root cause: validator requirements were added to the Claude orchestrate skill (since #229) but were not carried to the parallel Codex skill.

### Problem 2 — Step 3: CI-dependent acceptance-criteria check-offs stranded after the parent merge

Problem: an acceptance criterion whose verification depends on CI of the PR head (for example #710 AC-8, `docs/features/completed/preimplementation-helpers-backslash-chain-operator-710/spec.md:213`) can only be checked off after S9. No skill states who checks it off or when, so the check-off was pushed after the parent's merge (commit `81726a3b`) and never reached `main`. The parent cannot commit from the coordinator root.

Evidence (research codification search; no rule found):
- `.claude/skills/parallel-orchestrate/SKILL.md:568-569` and `.claude/agents/parallel-orchestrator.md:276-277` require each item's AC to be checked off "by that item's own run", with no timing rule relative to CI or merge.
- `.claude/skills/acceptance-criteria-tracking/SKILL.md:71` requires check-off "as soon as the corresponding plan task passes verification"; `:81-87` states orchestrators do not check off AC. No CI-dependent case is defined.
- `.claude/skills/orchestrate/SKILL.md:337` (PR Creation Gate condition 2) requires all AC to pass before PR creation, which a CI-dependent AC cannot satisfy before CI exists.
- `.claude/skills/parallel-orchestrate/SKILL.md:318-326`: the parent merges on child DONE after confirming `ci_green`; nothing requires the child's final pushed head to include the check-off.

Root cause: PR Creation Gate condition 2 and the S9 procedure were written without a CI-dependent AC case, so the check-off falls to an unspecified step after DONE. The mitigation exists only in delegation prompts.

### Problem 3 — Step 5: the Claude `feature-review` agent has no MCP artifact validator

Problem: `.claude/agents/feature-review.md:5-11` grants `Read`, `Grep`, `Glob`, `Bash(git diff *)`, `Bash(git log *)`, and `Write(/docs/features/active/**)`, but no validator. The workflow skill requires validation (`.claude/skills/feature-review-workflow/SKILL.md:127`, `:140`, `:175`), so the reviewer cannot comply and the coordinator must validate on its behalf.

Evidence: the MCP validator supports `policy-audit`, `code-review`, and `feature-audit` (`extensions/drm-copilot/src/mcp-tool-definitions.ts:411-413`; `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts:273-277`). The Codex (`.codex/agents/feature-reviewer.toml:31`) and Copilot (`.github/agents/feature-review.agent.md:6`) reviewers already have it. Other Claude agents use the tool name `mcp__drm-copilot__validate_orchestration_artifacts` (for example `.claude/agents/orchestrator.md:28`).

Root cause: the Claude agent tool allowlist was not updated when the workflow skill added the validation requirement.

### Problem 4 — Step 6a: Python PR-context collector pairs the last command with the first expectation

Problem: in `scripts/dev_tools/pr_context/verification_evidence.py:122-130`, `Timestamp`, `Command`, and `EXIT_CODE` are assigned unconditionally (last occurrence wins) while `ExpectedExitCode` is guarded (first occurrence wins). A file with several gates is parsed as the last command and last exit code against the first expectation, so intentional fail-before evidence is labelled `fail` (#708, `docs/features/completed/completion-consistency-edit-reads-relative-checkpoint-708/code-review.2026-09-27T08-50.md:50`, `:79`).

Evidence:
- The TypeScript collector (`extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:128-146`) is first-occurrence-wins for all four fields; the MCP `collect_pr_context` path does not reproduce the defect.
- The TypeScript comments at `:110-111` ("Mirrors Python ... first occurrence wins for required fields") and `:126-127` ("mirrors the Python dict-first-write semantics") describe a Python behaviour that does not exist.
- The divergence is pinned as runtime-specific: shape-06 in `tests/scripts/dev_tools/pr_context/test_verification_evidence.py:30-40`, `:77-83` and in `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts:168-174`, `:218-221`.
- The skill rule `.claude/skills/evidence-and-timestamp-conventions/SKILL.md:121` states first-occurrence-wins for `ExpectedExitCode` in both parsers.
- Unpromoted potential entry describing the same defect: `docs/features/potential/2026-08-20-pr-context-duplicate-required-key-precedence-divergence.md` (Status: Draft). It recommends converging Python on first-occurrence-wins and correcting the TypeScript comment. This item satisfies that entry; its lifecycle disposition is an orchestrator decision and is not performed by this spec.

Root cause: the Python parse loop never guarded required-field assignment, and the TypeScript port documented a parity it did not have.

### Problem 5 — Step 9, documentation sentence: timestamp source unstated

Problem: `.claude/skills/evidence-and-timestamp-conventions/SKILL.md:44-47` defines only the timestamp format; it states no time source. Evidence timestamps in #706 were 4-18 minutes later than their commits. The cause analysis is in `## Investigation-only findings`; the only change in this item is one sentence stating the source.

Root cause (inferred, not verified): the writing agent composed a plausible value instead of reading the clock.

## Requirements

### R1 — Codex `ci_gate` documentation (Problem 1)
- R1.1: `.agents/skills/orchestrate/SKILL.md` "CI Green Gate" names the top-level `ci_gate` object and its required keys `conclusion`, `head_sha`, and `verified_at`; states that `verified_at` is the ISO-8601 time S9 recorded the result, that DONE requires `conclusion` equal to `success` and `head_sha` equal to the current PR head SHA; and cites `scripts/dev_tools/validate_orchestrator_state.py` `CI_GATE_KEYS` as the authority.
- R1.2: the same section names the `pr_gate` object and its keys `pr_number`, `pr_url`, `head_branch`, `head_sha`, citing `scripts/dev_tools/_orchestrator_state_routing.py` `PR_GATE_KEYS`.
- R1.3: the completion list in the same file (currently `:284-296`) includes `ci_gate` and `pr_gate` entries.
- R1.4: the bundled mirror is byte-identical to the edited file.

### R2 — CI-dependent AC ownership (Problem 2)
- R2.1 (definition): a CI-dependent acceptance criterion is one whose verification requires the result of CI on the PR head.
- R2.2 (ownership): the item's own orchestrator run (the child) owns check-off of CI-dependent AC. The parent never commits check-offs from the coordinator root.
- R2.3 (PR Creation Gate reconciliation): `.claude/skills/orchestrate/SKILL.md` PR Creation Gate condition 2 states that it is satisfied when every AC passes except CI-dependent AC, which are listed as pending-CI in the AC verification artifact and are checked off under S9 before DONE. This is a clarification of condition 2, not an additional condition.
- R2.4 (S9 step): `.claude/skills/orchestrate/SKILL.md` S9 adds a step after `ci_gate.conclusion == "success"`: when CI-dependent AC exist, check them off in the item's own worktree, commit, push to the PR branch, and re-run S9 against the new head SHA so that `ci_gate.head_sha` equals the final PR head before DONE. A failed re-run enters the existing CI-failure remediation loop; the cap of 3 is unchanged.
- R2.5 (parent merge): `.claude/skills/parallel-orchestrate/SKILL.md` "Per-Item Merge to Main (Merge-on-Green)" step 2 and its "Completion Requirements", and `.claude/agents/parallel-orchestrator.md` (near `:276-277`), state that before `gh pr merge` the parent confirms that `headRefOid` equals the child's reported `ci_gate.head_sha` and that the child reported no pending CI-dependent AC. When either check fails, the parent does not merge and does not commit the check-off itself.
- R2.6 (AC-tracking skills): `.claude/skills/acceptance-criteria-tracking/SKILL.md`, `.agents/skills/acceptance-criteria-tracking/SKILL.md`, and `.github/skills/acceptance-criteria-tracking/SKILL.md` each gain a "CI-dependent criteria" rule within the existing Check-Off Protocol content: owner (the item's own orchestrator run), timing (after S9 success, before DONE), and the requirement that the check-off commit is pushed and re-verified.
- R2.7 (Codex orchestrate): `.agents/skills/orchestrate/SKILL.md` "CI Green Gate" carries the same child-ownership and push-then-re-verify rule. Codex has no parallel-orchestrate skill (research glob found none); no Codex parent surface is created.
- R2.8 (preservation): every fragment asserted by `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` remains present verbatim, including `MERGE_ON_GREEN_FRAGMENTS` (`:197-203`), whose last entry is "`.claude/skills/orchestrate/SKILL.md` is **not modified by this feature**". That sentence refers to the earlier parallel-orchestrator-surface feature. A clarifying sentence may follow the pinned paragraph stating that issue #744 later amended the child's S9 and PR Creation Gate condition 2 for CI-dependent AC; the pinned text itself is not edited. No heading is added, removed, renamed, or reordered in `.claude/skills/parallel-orchestrate/SKILL.md` or `.claude/agents/parallel-orchestrator.md` (heading layout is pinned by `test_orchestrate_skill_first_thirteen_headings_match_required_layout` and `test_agent_body_contains_exactly_the_nine_required_headings`), and no literal from `PRESCRIPTIVE_EPIC_LITERALS` (`tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py:55-59`) is introduced.
- R2.9: every bundled mirror of an edited file is byte-identical to its source.

### R3 — feature-review validator (Problem 3)
- R3.1: `.claude/agents/feature-review.md` frontmatter `tools:` includes `"mcp__drm-copilot__validate_orchestration_artifacts"`. Existing entries are unchanged.
- R3.2: the agent body instructs the reviewer to validate each artifact it writes with that tool, using `artifact_type` `policy-audit`, `code-review`, and `feature-audit` respectively, to fix a validator failure in the same review, and to report artifact paths only after validation passes.
- R3.3: the bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md` is byte-identical.

### R4 — Python collector first-occurrence parity (Problem 4)
- R4.1: `parse_verification_evidence_markdown` in `scripts/dev_tools/pr_context/verification_evidence.py` takes `Timestamp`, `Command`, `EXIT_CODE`, and `ExpectedExitCode` from their first occurrence. Later occurrences, including empty later values, are ignored.
- R4.2: artifacts with at most one occurrence of each field produce records identical to the pre-change parser.
- R4.3: the one-record-per-file contract, the record type, the normalization rules, and the rendered PR body format are unchanged.
- R4.4: the TypeScript parser (`extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts`) has no behaviour change. Its comments at `:110-111` and `:126-127` are corrected so that they describe first-occurrence-wins in both runtimes accurately and no longer reference "dict-first-write" semantics.
- R4.5: shape-06 in both test tables expects the first value and joins the cross-runtime agreement set; the runtime-specific exclusion comments are removed.
- R4.6: each copy of the evidence-and-timestamp-conventions skill states, in "Evidence Artifact Schema (Machine-Checkable)", that the first occurrence of `Timestamp`, `Command`, `EXIT_CODE`, and `ExpectedExitCode` forms the record in both the Python and the TypeScript parser, so an artifact recording several gates reports its first gate. The existing `ExpectedExitCode` rule text at `:121-122` remains.

### R5 — Timestamp source sentence (Problem 5)
- R5.1: each copy of the evidence-and-timestamp-conventions skill adds one sentence to the "ISO-8601 Timestamp Format" section with this content: "The `Timestamp` value is local time read from the host system clock when the recorded command runs (for example `Get-Date -Format yyyy-MM-ddTHH-mm`); the agent never composes or estimates it." This combines the orchestrator's wording with the research-supported example command. It is documentation only; no validator or hook change.

## Non-Goals

- No change to completion-gate logic in any validator (Python, TypeScript, PowerShell); step 2 is deferred.
- No change to the PoshQC module, its settings files, `config/poshqc-scan.json`, or the `run_poshqc_test` MCP tool; step 4 is deferred and no fix is specified here.
- No change to batch-budget hooks (step 8 is resolved).
- No change to issue-reference parsing (step 6b is resolved).
- No coverage configuration change (step 7 is investigation-only).
- No per-gate parsing of evidence files (research approach B for 6a is rejected).
- No TypeScript behaviour change in the PR-context collector; comments only.
- No edit to `.claude/agents/epic-orchestrator.md` or `.claude/skills/epic-orchestrate/SKILL.md`, whose digests are pinned by `test_frozen_epic_surface_matches_pinned_baseline_digest`.
- No lifecycle operation on `docs/features/potential/2026-08-20-pr-context-duplicate-required-key-precedence-divergence.md` by the implementing agents; disposition is left to the orchestrator.
- No change to `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.
- No extension rebuild or reinstall; repository tests are the verification mechanism.

## Constraints

- File size: no production, test, or reusable script file exceeds 500 lines. `tests/scripts/dev_tools/pr_context/test_verification_evidence.py` is near 400 lines, so new parser cases go in a new module. Markdown documentation files are exempt.
- No temporary files in tests: parser tests use inline markdown strings; documentation contract tests read committed repository files only.
- Coverage: line coverage >= 85% and branch coverage >= 75% for the Python measurement (`pyproject.toml` `source = ["src", "scripts/dev_tools"]`); changed lines in `verification_evidence.py` are fully covered; no regression on changed lines.
- Bundle-mirror parity: every edited file that has a bundled mirror under `extensions/drm-copilot/resources/{claude-customizations,codex-and-agents-customizations,customizations}/` is updated byte-identically in the same change.
- Mandatory toolchain loop (format, lint, type check, architecture, unit, contract, integration) passes in a single pass for Python and TypeScript.
- Dependencies: no new dependency. `hypothesis` is not declared in `pyproject.toml` (search returned no match), so no property-based test is added; the first-occurrence property is covered by explicit example cases.
- Repository-relative paths only in all artifacts.
- Known local-only failure: the Claude bundle parity test can fail locally on gitignored `.claude/state/` files (issue #510); CI is the authoritative run for that test.

## Files to Change

Documentation and agent surfaces:
- `.agents/skills/orchestrate/SKILL.md` (R1, R2.7)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md` (mirror)
- `.claude/skills/orchestrate/SKILL.md` (R2.3, R2.4)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` (mirror)
- `.claude/skills/parallel-orchestrate/SKILL.md` (R2.5, R2.8)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` (mirror)
- `.claude/agents/parallel-orchestrator.md` (R2.5)
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md` (mirror)
- `.claude/skills/acceptance-criteria-tracking/SKILL.md` (R2.6)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md` (mirror)
- `.agents/skills/acceptance-criteria-tracking/SKILL.md` (R2.6)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md` (mirror)
- `.github/skills/acceptance-criteria-tracking/SKILL.md` (R2.6)
- `extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md` (mirror)
- `.claude/agents/feature-review.md` (R3)
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md` (mirror)
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (R4.6, R5)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (mirror)
- `.agents/skills/evidence-and-timestamp-conventions/SKILL.md` (R4.6, R5)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/SKILL.md` (mirror)
- `.github/skills/evidence-and-timestamp-conventions/SKILL.md` (R4.6, R5)
- `extensions/drm-copilot/resources/customizations/.github/skills/evidence-and-timestamp-conventions/SKILL.md` (mirror)

Code:
- `scripts/dev_tools/pr_context/verification_evidence.py` (R4.1; one guarded assignment in the parse loop)
- `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` (R4.4; comments only)

Tests:
- `tests/scripts/dev_tools/pr_context/test_verification_evidence.py` (shape-06 expectation and comments, R4.5)
- `tests/scripts/dev_tools/pr_context/test_verification_evidence_first_occurrence.py` (new; R4.1, R4.2)
- `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts` (shape-06 comments; exclusion removed, R4.5)
- `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` (new; R1, R2, R3, R4.6, R5, mirror identity)

Functions impacted: `parse_verification_evidence_markdown` (Python). No CLI flag, schema, or configuration key changes.

## Backward Compatibility and Data Impact

- Evidence discovery is limited to `docs/features/active/<feature>/` (`verification_evidence.py:90`, `verification-evidence.ts:90`), so the Python change alters rendering only for active features whose artifacts duplicate a required key. The potential entry records six such artifacts in its measured corpus at the time; that figure is a quotation, not an acceptance assertion.
- Checkpoint schema, validator behaviour, and MCP tool schemas are unchanged.
- Rollback: revert the commit; no data migration.

## Test Strategy

Regression and fail-before:
- New Python test `test_two_gate_file_pairs_first_command_with_first_expectation` in `tests/scripts/dev_tools/pr_context/test_verification_evidence_first_occurrence.py`: a file with a first gate `Command: a`, `EXIT_CODE: 1`, `ExpectedExitCode: 1` followed by a second gate `Command: b`, `EXIT_CODE: 0`, parses to command `a`, exit code `1`, expectation `1`, result `pass`. Run against the unmodified parser first and record the failing run under `<FEATURE>/evidence/regression-testing/` with `ExpectedExitCode: 1`; then record the passing run.

Unit tests (pytest), same new module:
- `test_duplicated_timestamp_takes_first_occurrence`
- `test_duplicated_command_takes_first_occurrence`
- `test_duplicated_exit_code_takes_first_occurrence`
- `test_empty_second_command_does_not_make_record_unparseable`
- `test_single_occurrence_record_is_unchanged` (parametrized over the existing single-occurrence shapes from `SHAPE_CASES`, asserting equality with the expected records already pinned there)

Unit tests (Jest): `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts` existing cases, including "keeps the first occurrence for a duplicated required key", pass unchanged in behaviour; shape-06 comments no longer describe a runtime-specific exclusion.

Documentation contract tests (pytest, new module `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`, reading committed files only):
- `test_codex_ci_green_gate_names_ci_gate_keys_from_validator` (imports `CI_GATE_KEYS` from `scripts.dev_tools.validate_orchestrator_state` and asserts each key and the `ci_gate` name appear in the "CI Green Gate" section)
- `test_codex_ci_green_gate_names_pr_gate_keys_from_validator` (imports `PR_GATE_KEYS`)
- `test_codex_completion_list_includes_ci_gate_and_pr_gate`
- `test_orchestrate_pr_creation_gate_condition_two_excludes_ci_dependent_ac`
- `test_orchestrate_s9_requires_ci_dependent_checkoff_push_and_rerun`
- `test_parallel_orchestrate_merge_requires_head_sha_match_and_no_pending_ci_ac`
- `test_parallel_orchestrator_agent_states_child_owns_ci_dependent_checkoffs`
- `test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule` (parametrized over the `.claude`, `.agents`, and `.github` copies)
- `test_codex_orchestrate_states_ci_dependent_checkoff_rule`
- `test_feature_review_agent_grants_mcp_artifact_validator` (parses frontmatter `tools:`)
- `test_feature_review_agent_body_validates_each_review_artifact_type`
- `test_evidence_skill_states_first_occurrence_for_all_schema_fields` (parametrized over the source copies)
- `test_evidence_skill_states_timestamp_system_clock_source` (parametrized over the source copies)
- `test_edited_surface_matches_bundled_mirror` (parametrized over each source/mirror pair in "Files to Change"; byte identity)

Existing suites that must pass unchanged:
- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` (fragments, headings, epic literals, frozen digests)
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
- `tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py`
- `tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py`

Toolchain commands: Python via `poetry run` (Black, Ruff, Pyright, pytest with `--cov` on the `scripts/dev_tools` package and branch coverage); TypeScript in `extensions/drm-copilot` (Prettier, ESLint, TSC, Jest). Evidence is written to `<FEATURE>/evidence/qa-gates/` and `<FEATURE>/evidence/regression-testing/`.

Manual validation: none required.

## Acceptance Criteria

- [ ] AC-1: `.agents/skills/orchestrate/SKILL.md` "CI Green Gate" names the `ci_gate` object with required keys `conclusion`, `head_sha`, `verified_at` and the DONE conditions on `conclusion` and `head_sha`, citing `CI_GATE_KEYS` in `scripts/dev_tools/validate_orchestrator_state.py`. Verified by `test_codex_ci_green_gate_names_ci_gate_keys_from_validator`.
- [ ] AC-2: the same section names the `pr_gate` object with keys from `PR_GATE_KEYS`, and the file's completion list includes `ci_gate` and `pr_gate`. Verified by `test_codex_ci_green_gate_names_pr_gate_keys_from_validator` and `test_codex_completion_list_includes_ci_gate_and_pr_gate`.
- [ ] AC-3: `.claude/skills/orchestrate/SKILL.md` PR Creation Gate condition 2 states that CI-dependent AC are listed as pending-CI and are checked off under S9 before DONE, as a clarification of condition 2. Verified by `test_orchestrate_pr_creation_gate_condition_two_excludes_ci_dependent_ac`.
- [ ] AC-4: `.claude/skills/orchestrate/SKILL.md` S9 requires, after `conclusion == "success"`, checking off CI-dependent AC in the item's own worktree, committing, pushing to the PR branch, and re-running S9 so `ci_gate.head_sha` equals the final head before DONE, with a failed re-run entering the existing remediation loop. Verified by `test_orchestrate_s9_requires_ci_dependent_checkoff_push_and_rerun`.
- [ ] AC-5: `.claude/skills/parallel-orchestrate/SKILL.md` requires the parent to confirm `headRefOid` equals the child's reported `ci_gate.head_sha` and that no CI-dependent AC is pending before `gh pr merge`, and states the parent never commits check-offs from the coordinator root. Verified by `test_parallel_orchestrate_merge_requires_head_sha_match_and_no_pending_ci_ac`.
- [ ] AC-6: `.claude/agents/parallel-orchestrator.md` states the same child-ownership and pre-merge head-SHA rule. Verified by `test_parallel_orchestrator_agent_states_child_owns_ci_dependent_checkoffs`.
- [ ] AC-7: the `.claude`, `.agents`, and `.github` acceptance-criteria-tracking skills each define the CI-dependent criteria rule (owner, timing, push and re-verify), and `.agents/skills/orchestrate/SKILL.md` states the child-ownership rule. Verified by `test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule` and `test_codex_orchestrate_states_ci_dependent_checkoff_rule`.
- [ ] AC-8: every fragment in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` remains present, heading layouts and frozen epic digests are unchanged, and no prescriptive epic literal is introduced. Verified by `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` passing with `parallel_orchestrator_surface_expectations.py` unmodified (confirmed by `git diff --name-only origin/main`).
- [ ] AC-9: `.claude/agents/feature-review.md` frontmatter `tools:` includes `mcp__drm-copilot__validate_orchestration_artifacts` with existing entries unchanged. Verified by `test_feature_review_agent_grants_mcp_artifact_validator`.
- [ ] AC-10: `.claude/agents/feature-review.md` body instructs validation of each artifact with `artifact_type` `policy-audit`, `code-review`, and `feature-audit` before reporting paths. Verified by `test_feature_review_agent_body_validates_each_review_artifact_type`.
- [ ] AC-11: the Python parser pairs the first `Command`/`EXIT_CODE` with the first `ExpectedExitCode` in a multi-gate file; the regression test failed against the unmodified parser and passes after the fix, with both runs recorded under `<FEATURE>/evidence/regression-testing/`. Verified by `test_two_gate_file_pairs_first_command_with_first_expectation`.
- [ ] AC-12: the Python parser takes the first occurrence of `Timestamp`, `Command`, and `EXIT_CODE`, and an empty later `Command` value does not make the record unparseable. Verified by `test_duplicated_timestamp_takes_first_occurrence`, `test_duplicated_command_takes_first_occurrence`, `test_duplicated_exit_code_takes_first_occurrence`, and `test_empty_second_command_does_not_make_record_unparseable`.
- [ ] AC-13: single-occurrence artifacts parse to records identical to the pre-change parser, and `test_collect_pr_context_expected_exit.py` passes unchanged. Verified by `test_single_occurrence_record_is_unchanged` and the existing `test_eleven_shape_fixture_table` cases other than shape-06.
- [ ] AC-14: shape-06 expects the first value in both the Python and TypeScript tables, the runtime-specific exclusion comments are removed, and the TypeScript parser comments no longer claim Python "dict-first-write" semantics. Verified by `test_eleven_shape_fixture_table[shape-06]`, the Jest suite `verification-evidence.test.ts`, and the code-review artifact.
- [ ] AC-15: each source copy of the evidence-and-timestamp-conventions skill states first-occurrence-wins for all four schema fields and the Timestamp system-clock sentence in R5.1. Verified by `test_evidence_skill_states_first_occurrence_for_all_schema_fields` and `test_evidence_skill_states_timestamp_system_clock_source`.
- [ ] AC-16: every edited source file with a bundled mirror is byte-identical to that mirror. Verified by `test_edited_surface_matches_bundled_mirror`, `test_push_down_claude_resource_contracts.py` (CI run authoritative per issue #510), and `test_push_down_codex_and_agents_resource_contracts.py`.
- [ ] AC-17: no file in the deferred scope changes: none under `scripts/dev_tools/_orchestrator_state_routing.py`, `extensions/drm-copilot/src/lib/validate/`, `.claude/lib/orchestrator-state/`, `scripts/powershell/PoshQC/`, `extensions/drm-copilot/resources/powershell/PoshQC/`, `config/`, or `.claude/hooks/`. Verified by `git diff --name-only origin/main` recorded under `<FEATURE>/evidence/qa-gates/`.
- [ ] AC-18: Python line coverage >= 85% and branch coverage >= 75%, with changed lines in `scripts/dev_tools/pr_context/verification_evidence.py` covered. Verified by the pytest coverage report recorded under `<FEATURE>/evidence/qa-gates/`.
- [ ] AC-19: the full toolchain loop passes in a single pass for Python and TypeScript. Verified by QA gate evidence under `<FEATURE>/evidence/qa-gates/` and by S9 CI on the PR head.

## Already resolved

No work is planned for these steps.

- Step 1, Claude surface (`ci_gate.verified_at`): documented in `.claude/skills/orchestrate/SKILL.md` S9 step 3 (`:277`, which runs `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, emitting `verified_at` at `:11`, `:51`, `:216`) and "Checkpoint Schema — CI Gate Fields" (`:293`, `:312`). Present since #229: `docs/features/completed/2026-06-24-missing-ci-gate-parser-script-229/evidence/baseline/phase0-s9-contract.md:14` (Timestamp 2026-06-24T17-40) transcribes `verified_at`. The Python, TypeScript, and PowerShell key sets are identical. Research notes that the Claude "Completion Requirements" section (`:214-221`) does not cross-reference the `ci_gate` sections; this is a navigation gap, not an omission, and no change is planned.
- Step 6b (`#AC-N` listed as auto-close issues): resolved by #622 (PR #703; commits `a27d1513`, `58b93e12`). Evidence: `scripts/dev_tools/pr_context/models.py:26` and `extensions/drm-copilot/src/lib/pr-context/models.ts:55` share `ISSUE_REFERENCE_PATTERN = (?<!\w)#\d+(?!\w)`, which requires a digit immediately after `#`; rejection tests `tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py:49-63` and `extensions/drm-copilot/test/lib/pr-context/issue-reference-pattern.test.ts:28`. The #706 observation is consistent with a pre-#622 installed extension. No extension rebuild is needed; the repository tests are the evidence.
- Step 8 (batch-budget reset between batches): resolved by #769 (PR #772, commit `53413fd1`) and #773 (PR #780, commit `daf9c403`). Evidence: `.claude/hooks/enforce-powershell-batch-budget.ps1:16-23`, `:293-295`, `:384-398` exempt non-terminal `large`, `remediation`, and `preparation` routes from counting; the shared route helper `.claude/hooks/enforce-batch-budget-route.ps1:94-139` is also dot-sourced by `.claude/hooks/enforce-python-batch-budget.ps1:63`, `:398`. The `small` route remains capped by design. The stale-checkpoint limitation at `enforce-powershell-batch-budget.ps1:51-53` is mitigated by checkpoint hygiene (#673) and is not a reset requirement.

## Investigation-only findings

No code change is made for these findings.

- Step 7 (local 1114 vs CI 1129 missed lines, #712): `docs/features/completed/unused-npm-token-secret-712/evidence/qa-gates/final-pytest-coverage.2026-09-27T09-20.md:9` (local `TOTAL 15841 1114 5760 573 91%`) and `:46` (CI `TOTAL 15841 1129 5760 573 91%`). Statements, branches, and partial branches are identical, so the measured file set and branch structure are identical and only the executed-statement set differs. Production code contains platform- and environment-conditional paths (for example `scripts/dev_tools/atomic_executor/cli_workspace.py:241-264`, `scripts/dev_tools/tk_dialog_helpers.py:133-159`, `scripts/dev_tools/push_down_copilot_customizations.py:330`, and `shutil.which` probes), and the local run also saw untracked `.claude/state/` files. The pattern is consistent with environment-conditional execution rather than a measurement defect. Exact per-file attribution was not performed; it would require diffing per-file `coverage.json` from both environments. Both environments pass the uniform thresholds, and the #712 no-regression comparison was local-versus-local, which is like-for-like.
- Step 9 cause analysis (timestamps 4-18 minutes later than commits, #706 FU-706-6): `docs/features/completed/cleanup-report-registration-lost-false-positive-706/code-review.2026-09-27T10-48.md:39` and `evidence/qa-gates/ci-shell-coverage.2026-09-27T10-48.md:3`, `:6`, `:20` show artifact timestamps later than the dispatch and commit times. A time-zone mix-up is excluded because the local offset is -0400 and would produce a four-hour difference. The plan defined `<ts>` as the artifact creation time, so the values were not pre-assigned. The skill defines only the format. The most likely cause, inferred and not verified, is that the writing agent composed a plausible value. No validator can check a timestamp against wall-clock creation time without git metadata. The only change is the documentation sentence in R5.1.

## Deferred to other items

These steps remain reproducible on current `main`. They are not dropped; each is recommended as its own follow-up item.

- Step 2 (promotion receipts demanded for issue-intake items; `completion_gate_residuals` not understood by any validator): `config/orchestration-routing.json:26-32`, `:53-59`, `:93-98` list `new_potential_entry` and `potential_to_issue` in `required_mcp_tools`; `validate_routing_contract` (`scripts/dev_tools/_orchestrator_state_routing.py:530-595`) and its ports (`extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts:443`, `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1:415`) require a successful receipt for each. No exemption exists, and a search outside `docs/` for `completion_gate_residuals`, `issue_intake`, `intake_mode`, `pre_existing_issue`, and `preexisting` found no validator match. Reason for deferral: the fix (research approach B, a key-gated intake declaration) edits the same `required_mcp_tools` resolution function in all three validators that open issue #405 edits. Implementing it here would create a blast-radius conflict with #405 and a large cross-runtime parity surface. Recommended as a follow-up item sequenced with or after #405.
- Step 4 (`run_poshqc_test` uses the installed extension's settings, #707 CR-3): the MCP schema (`extensions/drm-copilot/src/mcp-repo-automation-tool-definitions-poshqc.ts:60-80`) and argument builder (`extensions/drm-copilot/src/repo-automation-args.ts:20-55`) pass no settings path, and the module default (`extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1:3`, `PoshQC.Testing.psm1:156`, `:296-304`) resolves settings from the installed copy. Reason for deferral: the change shares the PoshQC module and settings files with #527, which is prepared separately in this run, and the settings source is a plausible cause of #527's denominator variance. Recommended to be folded into or sequenced after #527. No fix is specified in this spec.

## Risks & Mitigations

- Risk: editing the parallel-orchestrate surfaces breaks pinned fragment, heading, or digest tests. Mitigation: R2.8 constraints and AC-8; run `test_parallel_orchestrator_surface_contracts.py` after each surface edit.
- Risk: the Python change alters rendered PR rows for active features that duplicate a required key. Mitigation: the change converges on the documented TypeScript behaviour; single-occurrence artifacts are unchanged (AC-13).
- Risk: mirror drift between source and bundled copies. Mitigation: AC-16 byte-identity test.
- Risk: the S9 re-run after a check-off push adds a CI cycle. Mitigation: it applies only to items with CI-dependent AC and reuses the existing remediation loop and cap.

## Rollout & Follow-up

- Release: single PR against `main` from `bug/orchestration-completion-gate-and-tooling-friction-744`.
- Follow-up items: step 2 (with or after #405); step 4 (with or after #527).
- The orchestrator decides the lifecycle disposition of `docs/features/potential/2026-08-20-pr-context-duplicate-required-key-precedence-divergence.md`, which this item satisfies.
- The fixes are observable through the MCP tools only after an extension rebuild and reinstall; repository tests are the verification mechanism for this item.
- Links: issue #744; related #405, #527, #622, #709, #710, #714, #708, #706, #712, #769, #773.
