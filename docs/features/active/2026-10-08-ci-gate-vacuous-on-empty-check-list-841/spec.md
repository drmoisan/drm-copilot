# 2026-10-08-ci-gate-vacuous-on-empty-check-list (Spec)

- **Issue:** #841 (also closes #795)
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** full-bug (acceptance criteria source: this file only)
- **Design basis:** `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/research/research.2026-10-09T02-25.md`

## Context

The S9 CI gate can conclude `success` on an empty check list. `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` maps an empty or null check set to `success` (`Get-CiGateConclusion`, lines 130-134), so the epic-child rule added by #658 (PR #837, merge `6dac65b0`), which requires at least one `CI` check, is enforced only by skill prose at `.claude/skills/orchestrate/SKILL.md:291`. The same #658 review recorded two rule-text gaps:

- CR-4: S9 step 3 (`orchestrate/SKILL.md:293`) and the `ci_gate.head_sha` schema bullet (`:307`) still describe the conclusion in terms of "required checks", although the epic-child query runs without `--required`. The treatment of non-`CI` checks on an epic child is unstated.
- PA-N9: the `modified-workflow-needs-green-run` rule (`.claude/skills/feature-review-workflow/SKILL.md:73`) requires a green run whose head SHA equals the current branch head. An in-repo evidence artifact cannot name the SHA of the commit that contains it, so committed evidence fails the rule as soon as it is committed.

Issue #795 is delivered in the same item: `.agents/skills/ci-workflows/SKILL.md:40` and `.agents/skills/benchmark-baselines/SKILL.md:39` (and their Codex bundle mirrors) cite `modified-workflow-needs-green-run` and point at `.agents/skills/feature-review-workflow/SKILL.md`, which does not define the rule. A Codex session that loads only `.agents` content cannot resolve the citation.

Environment:
- OS/version: Windows 11 Pro; any host that runs the S9 gate
- Command/flags used: `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson '[]' -HeadSha <sha>`; `gh pr checks --json bucket,name,state,link,workflow`
- Data source: #658 review artifacts `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/code-review.2026-10-08T03-15.md` (CR-1, CR-4) and `policy-audit.2026-10-08T03-15.md` (PA-N9, ruling at `:372-382`)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

An orchestrator that runs S9 mechanically on an epic child with zero checks records `ci_gate.conclusion: success`, which is the vacuous-green defect class #658 targeted. PA-N9 makes the review rule depend on a per-run orchestrator ruling each time a workflow-modifying branch commits its evidence.

## Repro & Evidence

Steps to Reproduce:
1. CR-1: run `Invoke-CiGateParser.ps1` with `-ChecksJson '[]'`. Observe `conclusion: success`. The test `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1:91` ("returns success for an empty required-check array (vacuous satisfaction)") pins this behavior. No parameter exists to require a check from a named workflow.
2. CR-4: read `.claude/skills/orchestrate/SKILL.md:289-307`. Step 2's epic-child paragraph (`:291`) drops `--required`; step 3 (`:293`) and the schema bullet (`:307`) still say "required checks".
3. PA-N9: read `.claude/skills/feature-review-workflow/SKILL.md:73`. Commit an evidence file that records a green run, then re-run the policy audit on the new head; the rule cannot be met.
4. #795: grep `.agents/skills/feature-review-workflow/SKILL.md` for `### modified-workflow-needs-green-run`; there is no match.

Expected:
- CR-1: with an opt-in parameter passed by S9 when `epic_mode` is true, the parser never returns `success` unless at least one check whose `workflow` is `CI` is observed passing, and no observed check failed or is pending.
- CR-4: step 3 describes the conclusion over the checks actually queried, and the rule states that non-`CI` checks on an epic child are evaluated like any other check.
- PA-N9: the rule defines a satisfiable condition for committed evidence.
- #795: the `.agents` feature-review-workflow skill defines the rule its citers reference.

## Scope & Non-Goals

- In scope:
  - CR-1: opt-in `-RequireWorkflow <name>` parameter on `Invoke-CiGateParser.ps1`; default behavior unchanged.
  - CR-4: S9 wording in `.claude/skills/orchestrate/SKILL.md` and its Claude bundle mirror.
  - PA-N9: satisfiable qualifying-run definition in `.claude/skills/feature-review-workflow/SKILL.md` and its Claude bundle mirror.
  - #795: the rule (with PA-N9 text) in `.agents/skills/feature-review-workflow/SKILL.md` and its Codex bundle mirror, plus a narrow citation-resolution regression test.
- Out of scope / non-goals:
  - Changing the default (no-parameter) empty-set mapping. It remains `success` for `--required` queries on protected branches and for consumer repositories without branch protection.
  - A general "every cited rule name resolves" scanner (deferred; see Rollout & Follow-up).
  - Codex parity for CR-1 in `.agents/skills/orchestrate/SKILL.md` (its CI Green Gate does not reference the parser; follow-up candidate).
  - Wording alignment in `.claude/agents/orchestrator.md:133`, `.claude/rules/**`, `.github/workflows/**` comments, and the optional `orchestrate/SKILL.md:342` "failed required check" phrase.
- Explicitly excluded files (must not be written): `.claude/skills/epic-orchestrate/SKILL.md` (and its mirror; SHA-256 pinned by `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, and its final PR targets `main` with `--required`, so the default path applies), `.agents/skills/orchestrate/SKILL.md` (and its mirror), `.github/workflows/**`, `.claude/rules/**`, `.github/instructions/**`, `.claude/agents/orchestrator.md`, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (the parser path is already listed), and the Copilot `.github/skills/feature-review-workflow/SKILL.md` copies.

## Root Cause Analysis

- #658 declared parser changes out of scope, so the epic-child rule was added as prose only; `Get-CiGateConclusion` never reads the `workflow` property.
- The empty-set-is-success mapping is a deliberate design for `--required` queries (help text `:22-23`, `:107-114`). It is correct for that case, so the fix is an opt-in guard rather than a change of default.
- The S9 step 3 text predates the epic-child query variant and was not updated when #658 added it.
- The PA-N9 definition is SHA-exact; the #658 review cleared its Blocker only by a per-run orchestrator ruling (`policy-audit.2026-10-08T03-15.md:374`) that was never codified.
- The `.agents` feature-review-workflow skill is a hand-maintained Codex variant (not current converter output) that never received the `## Policy Rules` section, while its citers were written against the `.claude` copy's content.

## Proposed Fix

### Design summary (what changes where):

1. Parser (CR-1): add `[string]$RequireWorkflow = ''` to the script parameters, to `Invoke-CiGateParser`, and to `Get-CiGateConclusion`, and forward it at each call. With the parameter empty, behavior is byte-for-byte the current derivation. With it set, the derivation is:
   1. Validate every element as today (missing `bucket` throws; unknown bucket throws).
   2. Any `fail` or `cancel` on any observed check: `failure`.
   3. Else any `pending` on any observed check: `pending`.
   4. Else, if no observed check has a `workflow` property equal (case-sensitive, `-ceq`) to `RequireWorkflow` with bucket `pass`: `pending`.
   5. Else: `success`.
2. Orchestrate skill (CR-1 wiring, CR-4), `.claude/skills/orchestrate/SKILL.md` and Claude bundle mirror:
   - Step 2 epic-child paragraph (`:291`): state that step 3 passes `-RequireWorkflow CI`; that every check returned by the unfiltered query counts (a failing or cancelled non-`CI` check fails the gate, a pending one keeps it pending); that at least one passing `CI` check is required; and that a `gh pr checks` "no checks reported" error on an epic child is handed to the parser as `-ChecksJson '[]'` and is never treated as green (the parser returns `pending`).
   - Step 3 (`:293`): describe the conclusion over "the queried checks" (the required checks on a non-epic PR; all observed checks on an epic child); keep the command on one line beginning `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1` so `extract_script_references` (`scripts/dev_tools/skill_bundle_contract.py:54`) still resolves the path; state the `-RequireWorkflow CI` variant used when `epic_mode` is true.
   - Schema bullet (`:307`): "the PR head SHA that the queried checks were observed against".
   - Do not edit `:298` or the PR Creation Gate text (pinned by `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py:207-238`).
3. Feature-review-workflow (PA-N9), `.claude` copy and Claude bundle mirror: replace the `:73` bullet with the definition below. Keep `:72`, `:74` (`workflow_dispatch` qualifies), and `:75` (`awaiting_ci` routing) unchanged.

   > "Green workflow run against the branch head" means a run of the affected workflow whose conclusion is success and which satisfies either (a) its head SHA equals the current branch head, or (b) all three predecessor-head conditions: (1) the run's head SHA is an ancestor of, or equal to, the current branch head and contains the latest commit that changes any path outside the active feature folder (`git merge-base --is-ancestor <commit> <run-sha>`); (2) every commit after the run's head SHA changes only paths inside the active feature folder (`git log <run-sha>..HEAD -- . ":!<feature-folder>"` returns no commits); (3) the policy audit states that the orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE. Condition (b) exists because an in-repo evidence artifact cannot name the SHA of the commit that contains it.

   The exact sentence structure may vary; the fragments pinned by AC-14 must be present verbatim.
4. Feature-review-workflow (#795), `.agents` copy and Codex bundle mirror: insert `## Policy Rules` with `### modified-workflow-needs-green-run` between `### Work-mode acceptance-criteria contract` (ends `:64`) and `## Ordered Procedure` (`:66`), carrying the trigger paths, the second-line-of-defense bullet, the PA-N9 definition, the `workflow_dispatch` bullet, and the `awaiting_ci` bullet. Refer to the gate as "the orchestrator CI Green Gate (S9)" to match `.agents/skills/orchestrate/SKILL.md:453-460`.
5. Tests: extend `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`; add `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` (text contracts for items 2-4 and the #795 citation-resolution check).

### Boundaries and invariants to preserve:

- Default parser path (no `-RequireWorkflow`): every existing Pester expectation, including empty array and null set returning `success`, is unchanged.
- Output object shape (`head_sha`, `pr_pipeline_run_id`, `pr_pipeline_run_url`, `conclusion`, `verified_at`) is unchanged; no checkpoint schema, `CI_GATE_KEYS` validator, or hook change.
- The parser contains no epic or branch-pattern concept; it checks a workflow name only.
- Failure outranks pending outranks the presence condition.
- Every bundled mirror equals its source byte-for-byte.
- Pinned fragments in `.claude/skills/feature-review-workflow/SKILL.md` remain: `root \`CLAUDE.md\``, `record tier classification as not applicable`, `tier-classification check` (`test_push_down_tier_rule_adoption_gate.py:369-382`) and the MCP contract-lag wording (`test_orchestrator_state_remediation_docs.py:296-305`).

### Dependencies or blocked work:

- None blocking. Concurrency overlap with #798 and #824 is recorded under Risks.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

See `## Files In Scope`.

#### Functions/classes/CLI commands impacted:

- `Invoke-CiGateParser.ps1` script parameters and `process` block forwarding.
- `Invoke-CiGateParser` (adds and forwards `RequireWorkflow`).
- `Get-CiGateConclusion` (adds `RequireWorkflow` and rule 4).
- Help text: `.SYNOPSIS`/`.DESCRIPTION` (`:7-26`), example (`:59-61`, add an epic-child example), `Get-CiGateConclusion` help (`:107-114`), new `.PARAMETER RequireWorkflow`.

#### Data flow and validation changes:

- `-RequireWorkflow` validation: `''` (default) disables the guard. A non-empty value consisting only of whitespace throws a fail-fast error naming the parameter (deviation from research 3.1, which proposed treating whitespace as off; rationale in Assumptions A-4).
- Workflow match: read `workflow` only when `$check.PSObject.Properties.Name -contains 'workflow'` (safe under `Set-StrictMode`); an element without the property, or with an empty or `$null` value, is non-matching and does not throw.
- `skipping` on a `CI` check does not satisfy the presence condition.

#### Error handling and logging updates:

- New fail-fast error for whitespace-only `-RequireWorkflow`. Existing errors unchanged. No logging changes.

#### Rollback/feature-flag considerations (if applicable):

- The parameter is opt-in; reverting the S9 text to omit `-RequireWorkflow CI` restores prior behavior without a parser revert.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- New input: `-RequireWorkflow <string>` (optional, default `''`). Output unchanged: `conclusion` in {`success`, `failure`, `pending`}.

Behavior matrix with `-RequireWorkflow 'CI'`:

| Observed checks | Conclusion |
|---|---|
| `[]` or `$null` | `pending` |
| only non-`CI`, all `pass` | `pending` |
| `CI` `pass` (with or without non-`CI` `pass`) | `success` |
| `CI` `fail` or `cancel` | `failure` |
| `CI` `pass` + non-`CI` `fail` | `failure` |
| `CI` `pending`, or `CI` `pass` + non-`CI` `pending` | `pending` |
| `CI` `pending` + any `fail` | `failure` |
| `CI` only `skipping` | `pending` |
| `workflow = 'ci'` `pass` only | `pending` |
| element without `workflow` property, `pass`, plus `CI` `pass` | `success` (no throw) |

#### Required configuration keys and defaults:

- None.

#### Backward-compatibility expectations:

- All existing callers (non-epic S9, epic final PR in `epic-orchestrate`) omit the parameter and keep current behavior.

#### Performance constraints (latency/throughput/memory):

- One additional linear pass or flag over the check set; no measurable change.

## Assumptions

The operator is not available for questions; the following assumptions were made and are recorded for review.

- A-1: The research record `research/research.2026-10-09T02-25.md` is the design basis. Its file and line references were spot-checked against this worktree on 2026-10-08 (parser `:130-134`, orchestrate `:289-307`, feature-review-workflow `:66-75`, `.agents` feature-review-workflow `:51-66`, and the four `.agents`-side citers) and matched.
- A-2: `pending` (not `failure`) is the correct conclusion when the required workflow is absent, because checks may not be registered immediately after PR creation; `pending` keeps S9 in its bounded poll, and a poll timeout routes to `awaiting_ci` rather than a vacuous success or a synthetic remediation finding without a failing check.
- A-3: On an epic child, non-`CI` checks must pass (fail-closed reading). This needs no filtering in the parser.
- A-4: A whitespace-only `-RequireWorkflow` value throws rather than silently disabling the guard. This deviates from the research suggestion (treat as off) because the repository fail-fast policy prohibits silently ignoring an invalid input that would otherwise restore vacuous success.
- A-5: The "no checks reported" handling applies to the epic-child query only. For a non-epic `--required` query, the existing behavior (empty set is vacuously satisfied) is unchanged and out of scope.
- A-6: `gh pr checks` returns an error, not `[]`, for zero checks (research 1.3, verified against cli/cli source, not against the locally installed `gh` version). The S9 text covers both forms.
- A-7: The `.agents` feature-review-workflow skill is a hand-maintained Codex variant; adding the section by hand is correct and the Codex converter is not re-run.
- A-8: Markdown documentation files are exempt from the 500-line limit; the limit is enforced for the parser, the Pester file, and the new pytest file.
- A-9: Evidence for this item is written under `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/<kind>/` (`baseline/`, `regression-testing/`, `qa-gates/`).
- A-10: Pester runs directly through `Invoke-Pester` (PowerShell tool) for evidence, because the PoshQC MCP test tool returns summaries without output.

## Assumptions, Constraints, Dependencies

- Assumptions: see `## Assumptions`.
- Constraints: no edits to excluded files listed in Scope; byte-identical mirrors; 500-line limit for code and test files; no temporary files in tests.
- External dependencies: none new. `gh` behavior is documented, not invoked, by tests.

## Data / API / Config Impact

- User-facing or API changes: new optional parser parameter; revised S9 and rule text.
- Data or migration considerations: none; checkpoint `ci_gate` object unchanged.
- Logging/telemetry updates: none.
- Compatibility notes: consumer repositories receiving the push-down get the new parameter; their default behavior is unchanged.

## Files In Scope

- `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1`
- `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`
- `.claude/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
- `.claude/skills/feature-review-workflow/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`
- `.agents/skills/feature-review-workflow/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`
- `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` (new)
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/` (timestamped evidence files under `baseline/`, `regression-testing/`, `qa-gates/`)

## Test Strategy

- Regression tests (Pester, `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`):
  - Rename the `:91` test to state "without -RequireWorkflow" and keep its expectation (`success`); keep `:201` ("returns success for a null check set").
  - Add `Context "-RequireWorkflow (epic-child guard)"` with one `It` per row of the behavior matrix, the whitespace-only rejection, and a script-level forwarding case: `& $script:scriptPath -ChecksJson '[]' -HeadSha x -RequireWorkflow CI -NowProvider $fixedClock` returns `pending` (no temp files, no `gh`).
  - The new cases fail before the fix (parameter does not exist) and are recorded under `evidence/regression-testing/`.
- Text-contract tests (pytest, `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`), file reads only, whitespace-normalized:
  - orchestrate copies (`.claude` + Claude bundle): CR-4 fragments present, superseded fragments absent.
  - feature-review-workflow copies (`.claude`, Claude bundle, `.agents`, Codex bundle): PA-N9 fragments present; SHA-exact sole definition absent.
  - #795: for each `.agents`-side citing copy, the cited path's file contains `### modified-workflow-needs-green-run`; one synthetic negative case (in-memory text, no temp files) proves the resolver reports a missing heading.
- Existing suites to re-run: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`, `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`, `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`, `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py`, the `tests/scripts/dev_tools/test_parallel_*` surface-pin tests, and `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1`.
- Coverage: Pester line coverage on `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` >= 85%, with a pre-change baseline under `evidence/baseline/` and the post-change result and comparison under `evidence/qa-gates/`. PowerShell has no branch threshold. The new pytest file is test code and is excluded from coverage measurement.
- Toolchain order: format, lint, type-check, architecture, unit, contract, integration; restart on any failure or auto-fix.

## Acceptance Criteria

- [x] AC-1: `Invoke-CiGateParser.ps1` exposes an optional `-RequireWorkflow` string parameter (default `''`) at script level, on `Invoke-CiGateParser`, and on `Get-CiGateConclusion`, with `.PARAMETER RequireWorkflow` help text; verified by a Pester test in `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` that asserts the parameter on all three and its default.
- [x] AC-2: With `-RequireWorkflow 'CI'`, an empty check array (`-ChecksJson '[]'`) and a `$null` set (`Get-CiGateConclusion -Checks $null -RequireWorkflow 'CI'`) each return `pending`; verified by named Pester tests in the `-RequireWorkflow (epic-child guard)` context.
- [x] AC-3: With `-RequireWorkflow 'CI'`, a set containing only non-`CI` checks, all `pass`, returns `pending`; verified by a named Pester test.
- [x] AC-4: With `-RequireWorkflow 'CI'`, a set with a `CI` `pass` check (alone, and together with a non-`CI` `pass` check) returns `success`; verified by named Pester tests.
- [x] AC-5: With `-RequireWorkflow 'CI'`, a `CI` check with bucket `fail` returns `failure` and a `CI` check with bucket `cancel` returns `failure`; verified by named Pester tests.
- [x] AC-6: With `-RequireWorkflow 'CI'`, a `CI` `pass` check plus a non-`CI` `fail` check returns `failure`; verified by a named Pester test.
- [x] AC-7: With `-RequireWorkflow 'CI'`, a `CI` `pending` check returns `pending`, a `CI` `pass` check plus a non-`CI` `pending` check returns `pending`, and a `CI` `pending` check plus any `fail` check returns `failure`; verified by named Pester tests.
- [x] AC-8: With `-RequireWorkflow 'CI'`, a set whose only `CI` checks are `skipping` returns `pending`; a `pass` check with `workflow = 'ci'` does not satisfy `CI` (returns `pending`); an element lacking a `workflow` property is non-matching and does not throw; and a whitespace-only `-RequireWorkflow` value throws an error naming the parameter; verified by named Pester tests.
- [x] AC-9: Invoking the script file as `& $script:scriptPath -ChecksJson '[]' -HeadSha x -RequireWorkflow CI -NowProvider $fixedClock` returns an object whose `conclusion` is `pending`; verified by a named Pester test (covers `process`-block forwarding).
- [x] AC-10: Without `-RequireWorkflow`, behavior is unchanged: every pre-existing `It` block in `Invoke-CiGateParser.Tests.ps1` is retained with its original expectation, the empty-array test (renamed to include "without -RequireWorkflow") returns `success`, and the null-set test returns `success`; verified by the Pester run.
- [x] AC-11: `.claude/skills/orchestrate/SKILL.md` S9 states that step 3 passes `-RequireWorkflow CI` when `epic_mode` is true; that every observed check counts on an epic child (a failing non-`CI` check fails the gate); that at least one passing `CI` check is required; that a `gh pr checks` "no checks reported" error is handed to the parser as `'[]'` and is never treated as green; step 3 describes the conclusion over the queried checks and the `head_sha` bullet reads "the queried checks were observed against"; the phrases "derives `ci_gate.conclusion` as `success` when all required checks pass" and "that the required checks were observed against" are absent; verified by `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` for the source and the Claude bundle mirror.
- [x] AC-12: The S9 step 3 command remains on one line beginning `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1`, and `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` passes.
- [ ] AC-13: `.claude/skills/epic-orchestrate/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, `.claude/rules/**`, `.github/instructions/**`, and `.github/workflows/**` are unchanged; verified by `git diff --name-only origin/main...HEAD` listing none of those paths and the `tests/scripts/dev_tools/test_parallel_*` surface-pin tests passing.
- [x] AC-14: `.claude/skills/feature-review-workflow/SKILL.md` and its Claude bundle mirror define the qualifying run with alternative (a) head SHA equals the current branch head, or (b) the three predecessor-head conditions, containing the fragments `git merge-base --is-ancestor`, `":!<feature-folder>"`, `ci_gate.head_sha`, and "cannot name the SHA of the commit that contains it", and no longer contain "a workflow run whose head SHA matches the current branch head and whose conclusion is success" as the definition; verified by `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`.
- [ ] AC-15: `.agents/skills/feature-review-workflow/SKILL.md` and its Codex bundle mirror contain `## Policy Rules` and `### modified-workflow-needs-green-run` between the work-mode contract and `## Ordered Procedure`, carrying the trigger paths, the AC-14 fragments, the `workflow_dispatch` bullet, the `awaiting_ci` bullet, and the phrase "CI Green Gate (S9)"; verified by `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`.
- [ ] AC-16: A citation-resolution test in `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` asserts, for each of the four `.agents`-side citing copies (`.agents/skills/ci-workflows/SKILL.md`, `.agents/skills/benchmark-baselines/SKILL.md`, and their two Codex bundle mirrors), that the cited `.agents/skills/feature-review-workflow/SKILL.md` contains the heading `### modified-workflow-needs-green-run`, and includes a synthetic negative case that fails when the heading is absent; verified by pytest.
- [ ] AC-17: Mirror parity is preserved: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, and `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1` pass.
- [ ] AC-18: Pinned-fragment suites pass unchanged: `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`, `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`, and `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py`.
- [ ] AC-19: PoshQC formatting (`Invoke-Formatter`) produces no changes and PSScriptAnalyzer reports zero findings for `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` and `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`; results recorded under `evidence/qa-gates/`.
- [ ] AC-20: `Invoke-Pester` on `tests/scripts/claude-lib/ci-gate/` passes with zero failures and line coverage on `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` >= 85% and not below the pre-change baseline; baseline under `evidence/baseline/` and post-change result under `evidence/qa-gates/`.
- [ ] AC-21: `black --check`, `ruff check`, `pyright`, and `pytest` pass for `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`; results recorded under `evidence/qa-gates/`.
- [ ] AC-22: No production or test file written by this item exceeds 500 lines (`.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, its bundle mirror, `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`, `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`); verified by a line count recorded under `evidence/qa-gates/`.

## Risks & Mitigations

- Concurrency overlap (risk only): #798 edits `.claude/skills/orchestrate/SKILL.md` and its Claude bundle mirror; this item edits S9 lines `:291`, `:293`, `:307`. #824 edits `.claude/skills/feature-review-workflow/SKILL.md` and its mirror; this item edits `:73` there. Neither feature folder is present on this branch, so exact line ranges were not verified. Mitigation: if a textual conflict occurs after either lands, resolve in the source and re-copy the source to its mirror byte-for-byte, then re-run AC-17 and AC-18.
- Enforcement still depends on S9 passing `-RequireWorkflow CI`. Mitigation: AC-11 pins the token in both orchestrate copies.
- A check-less epic child now polls to timeout instead of passing. Mitigation: the timeout routes to `awaiting_ci` per existing S9 step 4; this is the intended outcome.
- Codex S9 (`.agents/skills/orchestrate/SKILL.md`) still lacks the epic-child guard. Mitigation: recorded as a follow-up candidate.

## Rollout & Follow-up

- Release/rollout: ships through the normal extension push-down; no migration.
- Follow-up candidates (not filed by this item):
  - General cited-rule scanner. Deferred because rule citations are free-form prose (backticked kebab-case names followed by `(see <path>)`); a general check needs a citation grammar and an exception list, which exceeds the scope of the Low item #795. The narrow AC-16 test covers the defect reported.
  - Codex CI Green Gate parity for CR-1 in `.agents/skills/orchestrate/SKILL.md`.
  - Optional wording alignment: `orchestrate/SKILL.md:342`, `.claude/agents/orchestrator.md:133`.
- Links: issue #841, issue #795, #658 (PR #837), research `research/research.2026-10-09T02-25.md`.
