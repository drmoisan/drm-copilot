# epic-child-pr-merges-without-ci (Spec)

- **Issue:** #1130
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T08-08
- **Status:** Draft
- **Version:** 0.2

## Context
In a destination repository whose CI runs automatically only on pull requests to `main`, child PRs into an epic integration branch get no CI, and the merge gate lets them merge anyway. Several iar-migration E1 child PRs, for example #161, merged into the integration branch with no CI run. One agent worked around it by dispatching the workflow manually on the PR head.

Environment:
- OS/version: Windows 11 Pro, Claude Code
- Python version: n/a
- Command/flags used: `gh pr merge` on a child PR whose base is `epic/<slug>-integration`
- Data source or fixture: iar-migration E1, 2026-11-07/08; this repository's own `ci.yml` already includes `epic/**` in its pull_request trigger

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. In a repository whose CI `pull_request` trigger lists only `main`, open a child PR into `epic/<slug>-integration`.
2. Observe that no CI runs.
3. Merge it through `epic-orchestrator`; observe that the merge gate allows it.

Expected:
`epic-orchestrator` and the merge gate require a green CI result on the child PR head SHA before merging into the integration branch, from either a `pull_request` run or a recorded `workflow_dispatch` run on the same SHA. Repository bootstrap and push-down add the integration-branch pattern (`epic/**`) to the CI `pull_request` trigger.

Actual:
Child PRs merge into the integration branch with no CI result at all.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: iar-migration PR #161 merged into the E1 integration branch with zero checks.
- Research record: `research/research.2026-11-08T13-40.md` (section `## Root cause (confirmed)`).


## Scope & Non-Goals
- In scope:
  - Both epic merge gates (`.claude/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`) and a new shared helper `enforce-epic-merge-gate-child-ci.ps1` in each hooks directory.
  - Skill text for the S9 dispatch-and-record rule (`orchestrate`, `epic-orchestrate`, `epic-run`) and their `.agents/skills` and bundle mirrors.
  - `.claude/rules/orchestrator-state.md`, `.claude/rules/ci-workflows.md`, `.agents/skills/ci-workflows/SKILL.md`, the six execution-environment brief copies, both `core.json` pack manifests, and bundle copies of the new helper.
  - Pester suites for the new behavior and updates to existing suites whose branch-1 allow now requires CI.
- Out of scope / non-goals:
  - Making the required workflow name configurable; `CI` is a stated assumption.
  - Accepting `push`-event runs as CI evidence.
  - Changes to `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` or its tests.
  - Changes to `enforce-epic-merge-gate-review.ps1` (#1097) or `enforce-epic-merge-gate-green-ci.ps1`.
  - Changes to `.claude/agents/epic-orchestrator.md`, `.codex/agents/epic-orchestrator.toml`, or `.github` Copilot surfaces.
- Explicitly excluded systems, integrations, or datasets: destination repository workflow files. No file in this repository writes a destination's CI workflow trigger (verified by search of `extensions/drm-copilot/src`, `resources`, `scripts`, `packages`, `.claude/lib`, `.claude/skills`); destinations are reached only through push-down of rule and skill text.

## Root Cause Analysis
The branch-1 child path of `Invoke-EpicMergeGateDecision` in `.claude/hooks/enforce-epic-merge-gate.ps1` returns allow when `Test-ChildCheckpointAllowsEpicMerge` (JSON `epic_mode` true, `step9_status` `passed`) and `Test-ChildCheckpointPrGateBinding` (`.claude/hooks/enforce-epic-merge-gate-resolution.ps1`) hold. The binding returns true for a bare command. In `.codex/hooks/enforce-epic-merge-gate.ps1`, `Invoke-CodexEpicMergeDecision` allows when `Test-CodexChildMergeReady` holds and has no PR binding. Neither path reads a CI result tied to the live PR head SHA; an epic child merges on checkpoint state alone. Because the child `orchestrator` merges its own PR at `.claude/skills/orchestrate/SKILL.md` S9 step 6, and the S9 text assumes CI runs on the child PR, a destination whose `CI` workflow does not trigger on `epic/**` produces a child that reaches `step9_status` `passed` with no run.

## Proposed Fix

### Design summary (what changes where):
- A new helper `enforce-epic-merge-gate-child-ci.ps1`, byte-identical in `.claude/hooks/` and `.codex/hooks/`, verifies a green `CI` run on the live head SHA of the child PR.
- Both gates dot-source the helper (guarded like the existing helpers). The child branch allows only when the existing checks hold AND `Get-EpicMergeGateChildCiDecision` returns `Verified`; otherwise it denies immediately with `EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: <detail>` and does not fall through to later allow branches.
- The S9 epic-child rule dispatches `CI` once when no `CI` check exists on the child head and records `ci_gate.dispatch_run_id`.
- Pushed-down CI-authoring guidance requires `epic/**` in the `pull_request` branches of the `CI` workflow for repositories that use epic integration branches.

### Boundaries and invariants to preserve:
- The gate is not weakened: every stage failure denies; there is no fall-through for an epic child.
- The review guard (`enforce-epic-merge-gate-review.ps1`, #1097) still runs first and is untouched; compatibility with #1097 stage C (review guard) and stage J (`review/verdict` commit status) is preserved.
- The existing generic final deny text is unchanged (it is pinned verbatim in several suites).
- Hooks do not invoke Python.
- The helper dot-sources nothing and uses only `Invoke-DocsOnlyGhExe`, already loaded by both gates through `hook-docs-only-diff.ps1`.
- Branch 1 continues to call `Get-EpicMergeGateLivePrHeadSha` zero times (asserted in `enforce-epic-merge-gate.GreenCiRegression.Tests.ps1` and `enforce-epic-merge-gate.EpicModeStrict.Tests.ps1`), and the helper does not call `Get-EpicMergeGateReviewLiveHeadSha`.
- `Invoke-CiGateParser.ps1` output contract is unchanged.

### Dependencies or blocked work:
- Builds on #1097 (review guard) and #997 (green-CI gate). No blocking dependency.
- GitHub CLI 2.103.3 provides `gh run list --commit` with the fields `databaseId,event,status,conclusion,headSha,workflowName,createdAt` (verified).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- New: `.claude/hooks/enforce-epic-merge-gate-child-ci.ps1`, `.codex/hooks/enforce-epic-merge-gate-child-ci.ps1`, and bundle copies under `extensions/drm-copilot/resources/claude-customizations/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/`.
- Gates: `.claude/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1` (dot-source line and child-branch call only), plus bundle copies.
- Manifests: both `pack-manifests/core.json` files gain the new helper.
- Skills: `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/skills/epic-run/SKILL.md`; mirrors `.agents/skills/orchestrate`, `.agents/skills/epic-orchestrate`, `.agents/skills/epic-run`; bundle copies.
- Rules: `.claude/rules/orchestrator-state.md`, `.claude/rules/ci-workflows.md`; `.agents/skills/ci-workflows/SKILL.md`; bundle copies.
- Execution-environment brief: all six byte-identical copies (`## Hook Execution Context`, `## CI Shape and Required Checks`).
- Test pins: `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` refreshed for the epic-orchestrate skill with a `RE-BASELINED by issue #1130` comment.

#### Functions/classes/CLI commands impacted:
- New: `Get-EpicMergeGateChildCiDecision` (entry), seams `Get-EpicMergeGateChildCiLiveHeadSha` and `Get-EpicMergeGateChildCiRunList`, pure helpers for object-id validation, PR-number resolution, and run selection.
- Changed: `Invoke-EpicMergeGateDecision` (Claude branch 1), `Invoke-CodexEpicMergeDecision` (Codex `Test-CodexChildMergeReady` branch).
- Unchanged: `Test-ChildCheckpointAllowsEpicMerge`, `Test-ChildCheckpointPrGateBinding`, `Test-CodexChildMergeReady`.

#### Data flow and validation changes:
Verification runs only after the existing child predicates hold, cheapest first; the first failure denies:
1. PR number: the command's explicit number, else JSON-integer `pr_gate.pr_number`; when both are present they must match; when neither is present, deny.
2. `ci_gate.conclusion` equals `success` and `ci_gate.head_sha` is a lowercase 40- or 64-character object id.
3. One bounded `gh pr view <PR> --json headRefOid`; the live head must equal `ci_gate.head_sha`.
4. One bounded `gh run list --commit <head> --limit 100 --json databaseId,event,status,conclusion,headSha,workflowName,createdAt`; filter to `workflowName == 'CI'` and `headSha == head`; select the newest by `createdAt`. No match denies.
5. The selected run's `event` is `pull_request` or `workflow_dispatch`, `status` is `completed`, and `conclusion` is `success`.
6. For `workflow_dispatch`, `databaseId` equals `ci_gate.dispatch_run_id`.

Claude passes the session root as `-GhRoot`; Codex passes `-RepositoryRoot`.

#### Error handling and logging updates:
- Every failure returns `Verified = $false` with a stage-specific `Reason`, emitted as `EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: <detail>`.
- A failed, timed-out, or unparseable `gh` call denies (fail closed). The helper never throws.
- A failed dot-source of the helper registers through `Add-HookDependencyFailure`, the pattern checked by `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`.

#### Rollback/feature-flag considerations (if applicable):
No feature flag. Rollback is a revert of the gate wiring lines; the helper and text changes are inert without them.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `Get-EpicMergeGateChildCiDecision -Checkpoint <parsed object> -CommandPrNumber <int or null> -GhRoot <string>` returns `[ordered]@{ Verified = <bool>; Reason = <string> }`.
- `Get-EpicMergeGateChildCiLiveHeadSha -PrNumber -WorktreeRoot` and `Get-EpicMergeGateChildCiRunList -HeadSha -WorktreeRoot` each make exactly one `Invoke-DocsOnlyGhExe` call.
- Checkpoint field `ci_gate.dispatch_run_id` (positive JSON integer), added by the orchestrator to the parser's object; tolerated by `_validate_completion_ci_gate` in `scripts/dev_tools/validate_orchestrator_state.py`, which checks required keys only.

#### Required configuration keys and defaults:
- Required workflow name: `CI` (consistent with the S9 `-RequireWorkflow CI` contract). A destination whose CI workflow has a different name is denied; this is documented in `.claude/rules/ci-workflows.md` and the skill text.
- Hook registration in `.claude/settings.json` and `.codex/config.toml` is unchanged.

#### Backward-compatibility expectations:
- Epic children that previously merged on checkpoint state alone now require a verified run. This is the intended behavior change.
- A destination `ci.yml` without `epic/**` remains protected by the gate plus the S9 dispatch fallback; destinations need a push-down refresh to receive the updated guidance.

#### Performance constraints (latency/throughput/memory):
Two additional calls bounded at the `Invoke-DocsOnlyGhExe` default (7000 ms each). With the review guard active, the Codex worst case stays within its registered 30 s timeout. The run list is one call.

## Assumptions, Constraints, Dependencies
- Assumptions: the destination CI workflow is named `CI`; `gh pr checks` lists check runs of a `workflow_dispatch` run on the PR head (S9 step 2 depends on it; to be confirmed during execution).
- Constraints: Claude gate file stays below the 800-line hard limit (all new logic lives in the helper); Linux hook-suite fixtures use forward-slash synthetic roots and `Join-Path`; Pester runs use the parallel gate only.
- External dependencies: GitHub CLI 2.103.3.

## Data / API / Config Impact
- User-facing or API changes: new deny reason `EPIC_CHILD_CI_NOT_VERIFIED`; S9 epic-child dispatch rule.
- Data or migration considerations: new optional checkpoint field `ci_gate.dispatch_run_id`.
- Logging/telemetry updates (if any): deny reasons only.
- Compatibility notes (CLI flags, config schemas, versioning): `.claude/rules/orchestrator-state.md` documents the field and verification; no schema version change.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: merge gate denies an epic-child merge with no CI record; allows one with a green `pull_request` run on the head SHA; allows one with a recorded green `workflow_dispatch` run on the same SHA; denies a run on a different SHA.
- [ ] Integration scenario to retest: `epic-orchestrator` dispatches CI when no run exists and records it before merging.
- [ ] Manual verification notes: update `epic-orchestrate` and `epic-run` text and mirrors, the bootstrap or push-down that writes the CI trigger, and state that destination repositories need a push-down refresh.

- Regression tests to add or update: new suites `tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCi.Tests.ps1` and `tests/scripts/codex-hooks/enforce-epic-merge-gate-child-ci.Tests.ps1`. A regression test proving the defect is written first and fails before the fix.
- Unit tests (Pester) for the fixed behavior and boundaries: deny with no `ci_gate`; deny when `ci_gate.head_sha` differs from the live head; allow with a green `pull_request` `CI` run on the head; allow with a green `workflow_dispatch` run whose id equals `ci_gate.dispatch_run_id`; deny a dispatch run whose id is not recorded; deny a failed or in-progress newest run; deny a run on a different SHA; deny when `gh` fails; byte identity of the two helper copies.
- Existing suites updated by mocking the new seams by name, each with its stated reason (research `## Q3`): Claude `enforce-epic-merge-gate.Tests.ps1`, `.EpicModeStrict`, `.GreenCiRegression`, `.WorktreeResolution`, `.ReviewGuard`, `.ReviewPaths` (and the shared `EpicMergeGateReview.Cases.Helpers.ps1` fixture); Codex `epic-execution-gates.Tests.ps1`, `enforce-epic-merge-gate-authorization.Tests.ps1`, `enforce-epic-merge-gate-review.Tests.ps1`. `Invoke-DocsOnlyGhExe` call counts asserted by review suites stay unchanged.
- Edge cases and negative scenarios: PR number mismatch between command and `pr_gate.pr_number`; bare command with no `pr_gate`; non-integer `pr_gate.pr_number`; uppercase or short `head_sha`; non-array run-list output; runs from a workflow not named `CI`; `push`-event run on the head.
- Error handling and logging verification: each stage asserts its `EPIC_CHILD_CI_NOT_VERIFIED` detail and that no later allow branch is reached.
- Coverage impact and targets: line coverage >= 85% for the new helper file; no regression on changed lines.
- Toolchain commands: Invoke-Formatter, PSScriptAnalyzer, Pester (parallel gate only); pytest `-n auto` for the pin, manifest, bundle-parity, and contract tests (`test_ci_gate_epic_child_contracts.py` fragments kept intact).
- Baselines: Phase 0 baselines captured before any change (pytest `-n auto`: 16537 passed, 6 skipped, 0 failed, scripts coverage 94%; Pester parallel baseline captured by the orchestrator) under `evidence/baselines/`.
- Manual validation steps: none beyond the toolchain.


## Acceptance Criteria
- [ ] A regression test in `tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCi.Tests.ps1` shows an epic-child merge with `epic_mode` true, `step9_status` passed, and no `ci_gate` is allowed before the fix and denied after it.
- [ ] `.claude/hooks/enforce-epic-merge-gate-child-ci.ps1` and `.codex/hooks/enforce-epic-merge-gate-child-ci.ps1` exist, are byte-identical (asserted by a test), dot-source nothing, call `gh` only through `Invoke-DocsOnlyGhExe` inside `Get-EpicMergeGateChildCiLiveHeadSha` and `Get-EpicMergeGateChildCiRunList`, and expose `Get-EpicMergeGateChildCiDecision` returning `Verified` and `Reason`.
- [ ] Both gates dot-source the helper with the guarded pattern, and their epic-child branch allows only when the existing checks hold and the helper returns `Verified`; any failure denies with `EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: <detail>` without falling through.
- [ ] The helper enforces the verification stages in order (PR number, `ci_gate` fields, live head, `CI` run list on the head, run event/status/conclusion, dispatch run id), and each stage has a deny test in both the Claude and Codex suites.
- [ ] Both suites allow a green `pull_request` `CI` run on the live head and a green `workflow_dispatch` run whose `databaseId` equals `ci_gate.dispatch_run_id`, and deny an unrecorded dispatch run, a failed or in-progress newest run, a run on a different SHA, and a `gh` failure.
- [ ] Existing suites whose branch-1 allow rows lacked CI are updated by mocking the new seams by name with a stated reason per suite; the generic final deny text, the review guard ordering, and the zero-call assertion on `Get-EpicMergeGateLivePrHeadSha` are unchanged.
- [ ] `enforce-epic-merge-gate-review.ps1` is unchanged, and the #1097 review-guard (stage C) and `review/verdict` (stage J) suites pass.
- [ ] No hook file added or changed by this item invokes Python.
- [x] `.claude/skills/orchestrate/SKILL.md` S9 epic-child rule dispatches `gh workflow run CI --ref <child branch>` once when no `CI` check exists on the child head and records `ci_gate.dispatch_run_id`; `.claude/skills/epic-orchestrate/SKILL.md` (`## Merge-on-Green Kickoff Parameter` and fan-in text) states the requirement, the epic-orchestrator dispatch fallback, and that a child merge is never accepted without it; `.claude/skills/epic-run/SKILL.md` points to the requirement.
- [x] The `.agents/skills` mirrors of `orchestrate`, `epic-orchestrate`, and `epic-run`, and all bundle copies under `extensions/drm-copilot/resources/`, match their sources; `.claude/agents/epic-orchestrator.md` is unchanged.
- [ ] `PINNED_FROZEN_SURFACE_HASHES` is refreshed for the epic-orchestrate skill with a `RE-BASELINED by issue #1130` comment, and `test_ci_gate_epic_child_contracts.py` passes unchanged.
- [x] `.claude/rules/orchestrator-state.md` has an epic-child CI verification section and an updated `## Enforcement` bullet; every copy of the execution-environment brief updates `## Hook Execution Context` and `## CI Shape and Required Checks` and remain byte-identical.
- [x] `.claude/rules/ci-workflows.md`, `.agents/skills/ci-workflows/SKILL.md`, and their bundle copies require `epic/**` in the `pull_request` branches of the `CI` workflow for repositories using epic integration branches, state that a differently named workflow is denied, and state that destinations need a push-down refresh.
- [ ] Both `core.json` pack manifests list the new helper, and the push-down manifest-completeness, dependency-closure, and bundle-parity tests pass.
- [ ] Line coverage for the new helper file is >= 85%, and the full toolchain (format, lint, Pester parallel gate, pytest `-n auto`) passes with no regression against the Phase 0 baselines.

## Risks & Mitigations
- Technical or operational risks:
  - Existing allow rows across many suites break when branch 1 requires CI.
  - Destinations with a differently named workflow, or with only `push` CI, are blocked.
  - A push after the live-head lookup changes the head (same residual as #997).
  - Mirror drift across helper twins, skill mirrors, bundles, manifests, and brief copies.
- Mitigations and rollbacks:
  - Seam mocks by name keep `Invoke-DocsOnlyGhExe` counts stable; each updated suite records its reason.
  - Fail-closed behavior is documented, and the S9 dispatch fallback gives a legitimate path.
  - Byte-identity and bundle-parity tests; the residual race is disclosed in `.claude/rules/orchestrator-state.md`.
  - Rollback by reverting the two gate wiring changes.

## Rollout & Follow-up
- Release/rollout steps: merge to `main`; ship in the next extension release; destination repositories run a push-down refresh.
- Post-fix monitoring or clean-up tasks: confirm on the first epic run after release that a child with no `pull_request` CI is dispatched and verified.
- Links: issue #1130; promoted record `docs/features/potential/promoted/2026-11-08-epic-child-pr-merges-without-ci.md`; research `research/research.2026-11-08T13-40.md`; related #1097, #997.
