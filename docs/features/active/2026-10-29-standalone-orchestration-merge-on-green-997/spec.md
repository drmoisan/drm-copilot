# standalone-orchestration-merge-on-green (Spec)

- **Issue:** #997
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-29T11-46
- **Status:** Draft
- **Version:** 0.2

## Context
A standalone orchestration (neither an epic child nor a parallel item) cannot merge its own pull request after CI is green. The merge gate allows a standalone merge only through a hand-written, session-bound `standalone_merge_authorizations` record (#670). The orchestration therefore stops at a green PR and a person must merge it or write the record.

This item reverses that policy for the green-CI case, at the user's direction on 2026-10-29. Design source: `research/research.2026-10-29T11-46.md` in this feature folder (section 2 for the design, section 7 for decisions D1 to D11).

Environment:
- OS/version: Windows 11
- Python version: not applicable
- Command/flags used: `gh pr merge --merge <PR>` under `.claude/hooks/enforce-epic-merge-gate.ps1`
- Data source or fixture: standalone `/orchestrate` runs

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Run `/orchestrate` for a single item to a green PR (`step9_status` passed, `ci_gate.conclusion` success).
2. Attempt `gh pr merge --merge <PR>`.

Expected:
When the checkpoint records `step9_status` passed, `ci_gate.conclusion` success, a `ci_gate.head_sha` equal to the live PR head, and a binding to the explicit PR number, the orchestration merges its own PR and confirms the merge.

Actual:
The gate returns `EPIC_MERGE_GATE_BLOCKED`. Branch 1 requires `epic_mode` to be true, and a standalone run satisfies none of branches 1 to 3.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: `EPIC_MERGE_GATE_BLOCKED` from `enforce-epic-merge-gate.ps1`


## Scope & Non-Goals
- In scope:
  - A fail-closed green-CI merge branch in `.claude/hooks/enforce-epic-merge-gate.ps1`, inserted after the parallel allow-branch and before the existing Branch 4 comment (decision D1).
  - A new sibling hook file `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` holding all new logic, including a mockable live-head seam.
  - Layered, best-effort parallel-exclusion discriminators (decision D2).
  - Updated final deny text with the three pinned Pester suites (Authorization, MergeQueue, DocsOnly) changed in the same commit (decision D3).
  - Prose updates: `orchestrate` skill S9 step 6 and PR Creation Gate condition 7; `parallel-orchestrate` skill; `.claude/rules/orchestrator-state.md`; `.claude/rules/parallel-orchestration.md`.
  - A new top-level `pr_merge` checkpoint record, unvalidated like `epic_merge` (decision D4).
  - Bundle mirrors and the `core.json` pack-manifest entry for the new hook.
- Out of scope / non-goals:
  - The Codex twin (deferred, decision D7).
  - `.claude/skills/epic-orchestrate/SKILL.md` (frozen hash, decision D6).
  - Any validator change for `pr_merge`.
  - Requiring base branch `main` in the hook (decision D5; required in skill prose only).
  - Requiring `--match-head-commit` in the command (decision D8; the skill prose instructs passing it).
  - Retiring or changing the #670 authorization branch (decision D9).
- Explicitly excluded systems, integrations, or datasets: Codex hooks and Codex skills; `enforce-epic-merge-gate-authorization.ps1`; `hook-docs-only-diff.ps1`; `.claude/settings.json`.

## Root Cause Analysis
By design: a standalone run never merges itself. The gate header states that a standalone run never satisfies conditions 1 to 3, and branch 4 admits only a session-bound `standalone_merge_authorizations` record. No branch consults the recorded S9 CI result, so a green standalone run has no automated route.

## Proposed Fix

### Design summary (what changes where):
- `enforce-epic-merge-gate.ps1` gains one guarded dot-source line for the new sibling, one call to `Get-EpicMergeGateGreenCiDecision`, one early allow-return, and a suffix append on the final deny reason. The call sits after the parallel allow-branch, because the epic and parallel run targets are resolved only there.
- The new sibling holds: `Test-ChildCheckpointGreenCiRecorded` (pure), `Get-EpicMergeGateLivePrHeadSha` (the mockable live-head seam, wrapping `Invoke-DocsOnlyGhExe`), `Test-EpicMergeGateGreenCiHeadAgreement` (pure), a thin seam over `Resolve-WorktreeRunTargetByRecord` for the parallel worktree check, and `Get-EpicMergeGateGreenCiDecision` (stage orchestrator).
- Stage order, cheapest first: A pure checkpoint check; B parallel and epic exclusion; C command shape via `Get-DocsOnlyMergeShapeViolation`; D live head lookup; E head and `--match-head-commit` agreement.
- Parallel exclusion is layered and best-effort: layer 1a run target by PR number, layer 1b run target by worktree path, layer 2 child-recorded `parallel_mode` and `parallel_slug`, layer 3 prose. The `Parallel mode: true` marker lives in the Agent delegation prompt and is not present in a Bash `PreToolUse` payload, so no Bash-time mechanism can close the window in which the parent has recorded neither the PR number nor a `worktree_path` and the child omits layer 2. This residual window is stated in the hook header and the rules text. The exclusion is not claimed to be mechanically closed.
- A route that requires S9 may self-merge; the `preparation` route (`requires_ci_gate: false`) never merges (decision D11).

### Boundaries and invariants to preserve:
- Branches 1 to 3 keep their order and behavior; the green branch is evaluated only when they decline.
- `Test-ChildCheckpointAllowsEpicMerge` is not edited and keeps returning `$false` when `epic_mode` is false.
- The #670 authorization branch is unchanged and still governs merges with no green S9.
- A decline by the green branch is silent for non-green cases, so every existing deny string other than the updated final text is unchanged.
- No existing file crosses 500 physical lines; all new logic is in the new sibling.
- The `epic-orchestrate` skill and its pinned hash are untouched.
- `hook-docs-only-diff.ps1` is reused, not edited.

### Dependencies or blocked work:
- Rebase on `main` before editing: #995 (merged) also edited `parallel-orchestrate/SKILL.md`, `orchestrator-state.md`, and `parallel-orchestration.md`.
- Reuses `Invoke-DocsOnlyGhExe`, `Get-DocsOnlyMergeShapeViolation`, `Test-CommandLineFlag`, `Get-CommandLineFlagValue`, and `Resolve-WorktreeRunTargetByRecord`.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- Hook: `.claude/hooks/enforce-epic-merge-gate.ps1` (edited); `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` (new).
- Tests: three existing deny-text pins (`enforce-epic-merge-gate.Authorization.Tests.ps1`, `enforce-epic-merge-gate.MergeQueue.Tests.ps1`, `enforce-epic-merge-gate.DocsOnly.Tests.ps1` under `tests/scripts/claude-hooks/`); two new suites `enforce-epic-merge-gate.GreenCi.Tests.ps1` and `enforce-epic-merge-gate.GreenCiDecision.Tests.ps1` in the same directory.
- Prose: `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/rules/orchestrator-state.md`, `.claude/rules/parallel-orchestration.md`.
- Mirrors under `extensions/drm-copilot/resources/claude-customizations/`: byte-identical copies of the five edited Claude files, a copy of the new hook, and a `pack-manifests/core.json` entry beside the existing merge-gate entries.

#### Functions/classes/CLI commands impacted:
- `Invoke-EpicMergeGateDecision` (one call and one early return after the parallel allow-branch; suffix appended to the final deny reason).
- New functions listed in the design summary.
- `gh pr view <PR> --json headRefOid` (read only, through `Invoke-DocsOnlyGhExe`, 7 second bound).

#### Data flow and validation changes:
- Green decision inputs: command text, explicit command PR number, per-feature child checkpoint, item, epic, and parallel run targets, session root, optional `--match-head-commit` value, and the live PR head.
- Allow requires all of: explicit PR number greater than zero; `epic_mode` absent, null, or JSON `false`; no `parallel_mode` true and no non-blank `parallel_slug`; `step9_status` exactly `passed`; `ci_gate.conclusion` exactly `success`; `pr_gate.pr_number` an integer equal to the command number (no fallback to an authorization record); `ci_gate.head_sha` lowercase hex of 40 or 64 characters; `pr_gate.head_sha`, when present and non-null, equal to `ci_gate.head_sha`; epic and parallel targets both `NoTarget`; child worktree not recorded as a parallel item; command a single structural `gh pr merge`; live head equal to `ci_gate.head_sha`; `--match-head-commit`, when present, equal to the live head.
- The orchestrator S9 prose merges with `gh pr merge --merge <PR> --match-head-commit <ci_gate.head_sha>`, then confirms through the existing merge-confirmation procedure and records `pr_merge: { merge_commit_sha, target_branch, merged_at }`.

#### Error handling and logging updates:
- Fail closed on every uncertainty. Suffix codes are appended to the final deny reason only after the live-head stage has run: `GREEN_CI_LIVE_HEAD_UNRESOLVED`, `GREEN_CI_HEAD_STALE`, `GREEN_CI_MATCH_HEAD_MISMATCH`.
- A failure to dot-source the sibling produces the existing `Add-HookDependencyFailure` fail-closed deny.
- The final deny text is updated to name the green-CI route in addition to the existing routes.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. Rollback is reverting the change; the #670 record route remains available throughout.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `Get-EpicMergeGateGreenCiDecision` returns `[ordered]@{ Allowed; Suffix }`.
- `Get-EpicMergeGateLivePrHeadSha` returns a head string, or `$null` on every failure path (non-zero exit, exit 124 timeout, exit -1 missing root, unparseable JSON, malformed oid).
- `pr_merge` is a new top-level checkpoint object with `merge_commit_sha`, `target_branch`, and `merged_at`; no validator reads it.

#### Required configuration keys and defaults:
- No new configuration keys. `.claude/settings.json` is unchanged because the gate is already registered and the sibling is not a registered hook.
- Optional checkpoint keys `parallel_mode` (boolean) and `parallel_slug` (string) are tolerated and unvalidated.

#### Backward-compatibility expectations:
- Existing deny strings for non-green cases are unchanged except the final deny text (D3).
- Existing suites that mock `Invoke-DocsOnlyGhExe` to a failing exit continue to fail closed through the live-head seam.

#### Performance constraints (latency/throughput/memory):
- Stages A to C make no external call, so a non-green merge attempt adds no `gh` call. Stage D adds at most one `gh pr view` call bounded at 7 seconds.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): the per-feature checkpoint is readable from the session root or the item worktree; `gh` is authenticated when the live-head lookup runs.
- Constraints (budget, performance, compatibility): no production, test, or reusable script file exceeds 500 physical lines; Markdown is exempt; PowerShell 7 advanced functions with `Invoke-<Tool>Exe`-style seams; Pester 5 with no temporary files, no clock or real `gh` dependence; fixtures use `/synthetic-worktrees/<name>` roots and `Join-Path`.
- External dependencies (services, libraries, releases): GitHub CLI and the GitHub API at run time only; none in unit tests.
- Residual limits (disclosed): a push after the live-head lookup changes the head unless `--match-head-commit` is passed (the hook does not require it); the parallel exclusion is best-effort as described above.

## Data / API / Config Impact
- User-facing or API changes: a standalone orchestration with a green S9 gate merges its own PR; the final deny text names the new route; new optional checkpoint keys `pr_merge`, `parallel_mode`, `parallel_slug`.
- Data or migration considerations: none; existing checkpoints remain valid.
- Logging/telemetry updates (if any): deny suffix codes listed above.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag or schema change; no validator change; Codex hooks and Codex pack are unchanged.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: a new pure green-CI check, with fail-closed cases for stale head, pending or failed CI, `step9_status` not passed, unbound or different PR number, missing checkpoint, bare command, `gh` failure or timeout, and a differing `--match-head-commit`.
- [ ] Integration scenario to retest: a standalone orchestration merges its own green PR; a parallel child still does not. This is a post-merge live-verification item with a stated deferral (see AC-32); it cannot be run from an isolated subagent because hooks run `main`'s copies.
- [ ] Manual verification notes: keep the #670 authorization branch for non-green cases; update the orchestrate skill S9 step 6 and the PR Creation Gate; mirror changes.

- Regression tests to add or update: new suites `enforce-epic-merge-gate.GreenCi.Tests.ps1` (pure function matrix, one `It` per fail-closed row) and `enforce-epic-merge-gate.GreenCiDecision.Tests.ps1` (decision through `Invoke-EpicMergeGateDecision`, allow case, paired parallel-child declines); update the Authorization, MergeQueue, and DocsOnly deny-text pins together.
- Unit tests (Pester 5) for the fixed behavior and boundaries: every fail-closed row in the acceptance criteria, the wrapper body through a mocked `Invoke-DocsOnlyGhExe` (exit 0, exit 1, exit 124, exit -1, unparseable JSON, malformed oid), and the stage ordering.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): `epic_mode` as a string; case variants of `passed` and `success`; uppercase or short `head_sha`; null `pr_gate.head_sha`; `gh api` mutation and `--auto` commands; ambiguous run targets.
- Error handling and logging verification: each suffix code asserted; silent decline asserted byte-identical to the prior deny text.
- Coverage impact and targets for changed lines/modules: line coverage at least 85 percent for the new sibling and the edited gate, read from `artifacts/pester/powershell-coverage.xml`; no PowerShell branch gate.
- Toolchain commands to run (format, lint, type-check, test): `Invoke-Formatter`, PSScriptAnalyzer, then Pester through `Invoke-PoshQCTest` launched by a `sh`-started PowerShell 7 process; counts read from `artifacts/pester/pester-junit.xml`. Python documentation and push-down contract tests listed in AC-19.
- Manual validation steps (if required): post-merge live check from a non-isolated run.

Fixture rule: every suite registers the baseline mock family (`Register-EpicStateBaselineMock`, `Invoke-EpicStateInterceptionProbe`) so no suite reads a live checkpoint, and mocks the live-head seam by name; `gh` itself is never mocked or started.

## Acceptance Criteria

Hook behavior, allow case:
- [x] AC-01: With a standalone checkpoint recording `epic_mode` absent or false, `step9_status` `passed`, `ci_gate.conclusion` `success`, `ci_gate.head_sha` and `pr_gate.pr_number` set, no parallel marker, epic and parallel targets `NoTarget`, a single structural `gh pr merge --merge <PR>` naming that PR, and a mocked live head equal to `ci_gate.head_sha`, `Invoke-EpicMergeGateDecision` returns allow. Test: `enforce-epic-merge-gate.GreenCiDecision.Tests.ps1`, allow case.
- [x] AC-02: The allow case in AC-01 also returns allow when `--match-head-commit` is present and equal to the live head, and when `pr_gate.head_sha` is present and equal to `ci_gate.head_sha`.

Hook behavior, fail-closed declines (one test each; a decline falls through to the epic, parallel, #670, and docs-only logic unchanged):
- [x] AC-03: Stale head: a live head that differs from `ci_gate.head_sha` declines with the `GREEN_CI_HEAD_STALE` suffix.
- [x] AC-04: `ci_gate.conclusion` of `pending`, `failure`, absent, or a case variant of `success` declines; `ci_gate` absent or not an object declines.
- [x] AC-05: `step9_status` absent, `pending`, `failed_remediation_required`, `blocked_ci_loop_limit`, or a case variant of `passed` declines.
- [x] AC-06: `pr_gate.pr_number` absent, null, non-integer, or different from the command PR number declines. A matching `standalone_merge_authorizations` entry does not satisfy this binding.
- [x] AC-07: A missing or unreadable per-feature checkpoint, or an ambiguous item target, declines.
- [x] AC-08: A bare `gh pr merge` command with no PR number declines and yields the final deny text.
- [x] AC-09: When `Get-EpicMergeGateLivePrHeadSha` returns `$null`, the decision declines with `GREEN_CI_LIVE_HEAD_UNRESOLVED`. The wrapper returns `$null` for each of: `gh` exit 1, timeout exit 124, missing-root exit -1, unparseable JSON, and a malformed `headRefOid`.
- [x] AC-10: `--match-head-commit` present and different from the live head declines with `GREEN_CI_MATCH_HEAD_MISMATCH`.
- [x] AC-11: `epic_mode` true declines in the green branch (branch 1 owns it); `epic_mode` present but not a JSON boolean (for example the string `"false"`) declines.
- [x] AC-12: `ci_gate.head_sha` absent, blank, uppercase, or not 40 or 64 lowercase hex declines; a present `pr_gate.head_sha` that differs from `ci_gate.head_sha` declines.
- [x] AC-13: Parallel child declines on each independent discriminator: (a) `Resolve-EpicMergeGateRunTarget` returning a resolved or ambiguous epic or parallel target for the PR number (layer 1a); (b) the child worktree recorded as a parallel item through the mockable worktree seam (layer 1b); (c) the checkpoint carrying `parallel_mode` true or a non-blank `parallel_slug` (layer 2). Each is a separate `It`, paired with a `NoTarget` allow case.
- [x] AC-14: A command that is not a single structural `gh pr merge` declines: chain, wrapper, `-R`, `--repo`, `/pull/` URL selector, inline environment prefix, `--auto`, `--admin`, and a `gh api` merge or enqueue command; `--merge`, `--squash`, and `--rebase` keep the behavior stated elsewhere in this spec.
- [x] AC-15: Failure to dot-source `enforce-epic-merge-gate-green-ci.ps1` yields the existing `Add-HookDependencyFailure` fail-closed deny, following the pattern in `hook-dependency-failure.SpecialCases.Tests.ps1`.
- [x] AC-16: Stages A to C make no live-head call: a test asserts `Get-EpicMergeGateLivePrHeadSha` is not invoked when the checkpoint, parallel exclusion, or command shape declines.

Regression and scope:
- [x] AC-17: Regression: for a command that the green branch declines, every existing branch behaves as before. The branch 1 case (`epic_mode` true, S9 passed), the parallel allow-branch, the #670 authorization record cases, the docs-only branch, and the merge-queue cases in every existing `enforce-epic-merge-gate*.Tests.ps1` suite pass without expectation changes other than the final deny text pin. `Test-ChildCheckpointAllowsEpicMerge` is unedited and still returns false for `epic_mode` false.
- [x] AC-18: The final deny text is updated to describe the green-CI route, and the Authorization (`$script:Line433Text`), MergeQueue (`$script:DenyText`), and DocsOnly (`$script:BareDeny`) suites assert the new text in the same commit. A search for the prior text over `tests/scripts/claude-hooks` returns no match.
- [x] AC-19: Python documentation and push-down contract tests pass: `parallel_orchestrator_surface_expectations.py` (including `MERGE_ON_GREEN_FRAGMENTS`), `merge_queue_documentation_expectations.py`, `test_ci_gate_all_checks_contracts.py`, `test_ci_gate_epic_child_contracts.py`, `test_completion_gate_documentation_contracts.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, and `test_push_down_pack_manifest_dependency_closure.py`.

Prose, mirrors, and manifests:
- [x] AC-20: `orchestrate/SKILL.md` S9 states the standalone merge as an addition that leaves the existing epic step 6 sentences and pinned fragments verbatim: it applies when `epic_mode` is absent or false, no `Parallel mode: true` marker was supplied, the route requires S9, and the PR base is `main`; it issues `gh pr merge --merge <PR> --match-head-commit <ci_gate.head_sha>`, confirms with the existing merge-confirmation procedure, records `pr_merge: { merge_commit_sha, target_branch, merged_at }`, states that the `preparation` route never merges, and states that a parallel item never merges itself. The Checkpoint Schema lists `pr_merge` beside `epic_merge`.
- [x] AC-21: PR Creation Gate condition 7 keeps the pinned `epic_merge.merge_commit_sha` sentence verbatim and adds the standalone alternative (DONE requires `pr_merge.merge_commit_sha` once the merge is confirmed, for routes with S9 required only). Condition 2 is not edited.
- [x] AC-22: `parallel-orchestrate/SKILL.md` keeps the sentence "`.claude/skills/orchestrate/SKILL.md` is **not modified by this feature**" verbatim, adds a following sentence recording the #997 amendment for standalone runs only, states that a parallel child never merges its own PR, adds the `parallel_mode: true` and `parallel_slug` recording instruction to the child kickoff, and updates the merge-gate paragraph so the green-CI condition is evaluated after the parallel condition and before the #670 record, and the #670 record is described as the route for a merge with no green S9. `orchestrator-state.md` gains a "Green-CI standalone merge (issue #997)" subsection stating the conditions, that `parallel_mode`, `parallel_slug`, and `pr_merge` are unvalidated, and the residual-window disclosure, and its Enforcement bullet names the new sibling. `parallel-orchestration.md` extends the merge-gate Enforcement bullet. None of these prose files states that the parallel exclusion is mechanically closed.
- [x] AC-23: The hook header of `enforce-epic-merge-gate.ps1` lists the new branch, rewrites the standalone sentence, and states the residual parallel-exclusion window. The sibling's header states the same.
- [x] AC-24: Mirrors and manifest: byte-identical bundle copies exist for every edited Claude file (the gate hook, the orchestrate and parallel-orchestrate skills, `orchestrator-state.md`, and `parallel-orchestration.md`) and for the new hook, and `pack-manifests/core.json` lists the new hook beside the existing merge-gate entries. Not edited: `epic-orchestrate/SKILL.md`, `.claude/settings.json`, the execution-environment brief, the Codex bundle, `enforce-epic-merge-gate-authorization.ps1`, `hook-docs-only-diff.ps1`.

File size (physical line counts; Markdown exempt):
- [x] AC-25: `.claude/hooks/enforce-epic-merge-gate.ps1` (460 physical lines at baseline) is at most 500 physical lines after the change.
- [x] AC-26: `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` and each new Pester suite are at most 500 physical lines.
- [x] AC-27: `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` (443 physical lines at baseline) has no diff and remains 443 physical lines. `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` receives no added tests, and `session-root-reads-850.Constraints.Tests.ps1` still passes.

Toolchain and CI:
- [x] AC-28: The PowerShell toolchain loop (format, lint, architecture-boundary tests, unit tests, contract checks) passes in a single pass, with pass and fail counts taken from `artifacts/pester/pester-junit.xml` and not from the PoshQC MCP result. Evidence is stored under `<FEATURE>/evidence/`.
- [x] AC-29: Line coverage is at least 85 percent for the new sibling and for the edited gate, read per file from `artifacts/pester/powershell-coverage.xml`.
- [x] AC-30: Seeded shuffled Pester runs show no order dependence, and no new test creates temporary files or starts `gh`.
- [ ] AC-31 (pending-CI): CI on the PR head is green, including the Linux hook-suite job over `tests/scripts/claude-hooks` and the Python documentation and push-down contract jobs, with `ci_gate.head_sha` equal to the final PR head. Owner: this item's own orchestrator run at S9, after `ci_gate.conclusion` is `success` and before DONE.
- [ ] AC-32 (pending live verification, deferred): After merge, a non-isolated run from the merged tree shows a standalone orchestration merging its own green PR and a parallel child not doing so. This item is not an acceptance fact before merge and is recorded as a deferred verification, not claimed as passed.

## Risks & Mitigations
- Technical or operational risks:
  - The green branch fires for a parallel child because the delegation marker is invisible to the hook. Residual window disclosed; layers 1a, 1b, 2, and 3 reduce it.
  - `epic_mode` handling accepts a truthy string.
  - A deny-text pin is left stale.
  - A push after the live-head lookup changes the head when `--match-head-commit` is not passed.
  - Sibling coverage falls below 85 percent because the wrapper is I/O-thin.
  - Mirror parity or manifest closure fails.
  - The gate or a suite crosses the 500-line cap.
  - Leaked mocks change shuffled-order results; Linux CI is case-sensitive.
- Mitigations and rollbacks:
  - One test per fail-closed row, including `epic_mode` as a string and exact-case rows; paired parallel-decline rows.
  - A search task confirms the three pinned strings changed together.
  - The skill prose instructs passing `--match-head-commit`.
  - The wrapper body is exercised through a mocked `Invoke-DocsOnlyGhExe` with six outcomes.
  - One mirror task per file pair and a final run of the three push-down contract tests.
  - All new logic lives in the sibling; line counts are recorded before and after.
  - New suites register the baseline mock family; fixtures use synthetic roots and exact-case names.
  - Rollback: revert the change; the #670 record route stays in place.

## Rollout & Follow-up
- Release/rollout steps: merge to `main`; push-down serves the installed extension payload, so a repository-side resources edit reaches consuming repositories only after rebuild and reinstall.
- Post-fix monitoring or clean-up tasks: perform the deferred live verification (AC-32); file a separate issue for the Codex twin if wanted; file a separate issue for a `pr_merge` validator or a hook `baseRefName` check if wanted.
- Links: issue #997 (`issue.md`), `research/research.2026-10-29T11-46.md`, `plan.2026-10-29T11-46.md`, related #670 and #995.
