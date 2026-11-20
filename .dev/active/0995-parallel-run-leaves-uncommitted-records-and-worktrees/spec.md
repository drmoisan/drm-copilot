# parallel-run-leaves-uncommitted-records-and-worktrees (Spec)

- **Issue:** #995
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-29T10-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (acceptance criteria live in this file only; no `user-story.md` applies)
- **Research:** `research/research.2026-10-29T10-07.md`

## Context
A completed parallel run does not finish its own housekeeping. It leaves the run's planning records uncommitted and unmerged, and it leaves its item worktrees and the planner's scratch worktrees in place. A human must commit, merge and remove them by hand.

Environment:
- OS/version: Windows 11
- Python version: not applicable
- Command/flags used: `/parallel-plan` then `/parallel-run pr-author-and-file-size`
- Data source or fixture: run `pr-author-and-file-size`, items #989 (PR #991) and #990 (PR #993)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Every parallel run needs manual cleanup, and stale worktrees accumulate.

## Repro & Evidence
Steps to Reproduce:
1. Run `/parallel-plan` for two items that conflict, so they run in two cohorts.
2. Run `/parallel-run` to completion. Both item PRs merge.
3. Inspect the planning session's worktree and `git worktree list`.

Expected:
When the run completes, it commits and merges the records it generated (`parallel-status.md`, the run manifest and kickoff, any promoted records) and removes the item worktrees and the planner's scratch worktrees. No manual step remains.

Actual:
- `parallel-status.md` and the promoted potential records stayed untracked in the planning worktree. The manifest and kickoff were committed on a branch that was never merged.
- Both item worktrees stayed in place; one registration carried a harness lock.
- The removal hook returned `EPIC_WORKTREE_REMOVAL_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE`. The checkpoint records `worktree_path` as a relative path (`.claude/worktrees/agent-...`) while the hook compares against the absolute path in the command, so an item whose `merge_status` is `merged` is not recognised.
- The planner's scratch worktrees (`wt989`, `wt990`, `wtplan`) were left behind because `git worktree remove` is hook-blocked.
- The pre-implementation gate blocks `git add` and `git commit` commands that fall outside its documented docs-only exemption.

Logs / Screenshots:
- Snippet: `EPIC_WORKTREE_REMOVAL_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE: no live worktree's run checkpoint records worktree_path '<absolute path>'`

## Scope & Non-Goals
- In scope:
  - (a) A shared pure matcher so a relative recorded `worktree_path` matches the absolute removal target at every site that compares a recorded `worktree_path` to a removal target (the matcher family listed under Technical specifications).
  - (b) A `Run Closing` section in `parallel-orchestrate/SKILL.md` and in the `parallel-orchestrator` agent.
  - (c) Byte-identical bundle mirrors and `core.json` pack-manifest entries for every changed or added Claude file.
- Non-goals (out of scope):
  - **D8: the standalone merge-on-green hook change is OUT of scope.** Allowing a standalone orchestration to merge its own pull request once CI is green (a new green-CI branch in `enforce-epic-merge-gate.ps1` and the related skill, rule, and test edits) is tracked in a separate issue, to be filed after this one. This issue does not modify the merge-gate hooks, the #670 authorization branch, or the `epic_mode` merge prose.
  - No change to the `merge_status` predicate (`merged` or `worktree_removed`) or to the fail-closed ordering of either removal gate.
  - No new hook allow rule for planner scratch worktrees (no path-class or "detached" allow).
  - No change to the pre-implementation gate, the pr-author gate, or the merge gate exemptions.
  - No Codex hook change (D7: the Codex twin is deferred; the Codex removal gate is epic-only and already resolves relative paths against the payload `cwd`).
  - No change to the planner's scratch worktree creation behavior unless the planner source is found to create them without need (see D5).
- Explicitly excluded systems, integrations, or datasets: `.agents`, `.github`, `.codex`, and the Codex customization bundle.

## Root Cause Analysis
Two causes, both confirmed by reading source (research sections 1 and 2):
1. Path-form mismatch. The run checkpoint records `items[].worktree_path` relative to the main checkout. Each matcher compares that string to the absolute path in the command after only separator and trailing-slash normalisation, so the two are never equal, resolution returns no target, and the gate denies. Each of the matcher sites carries its own copy of the comparison, so fixing one leaves the denial in place.
2. Missing closing step. `parallel-orchestrate` has no step that unlocks and removes merged item worktrees, regenerates final status, lands the run's records, or reports deferrals. `parallel-orchestrator` also lacks the `Agent(pr-author)` tool needed to open the records pull request.

The harness lock on an item worktree is held by the agent process that ran the item. Whether removal succeeds after unlock is a live-verification item (see Live-Verification Items).

## Proposed Fix

### Design summary (what changes where):
1. A new pure module holds the path comparison and the relative-path matcher. All matcher sites call it.
2. The `Run Closing` section defines a repeatable, deferral-tolerant closing step.
3. Mirrors and pack-manifest entries keep the bundle in parity.

### Boundaries and invariants to preserve:
- The `merge_status` predicate and the fail-closed ordering are unchanged. A relative record with `pr_open`, `worktree_created`, or no `merge_status` still denies.
- Stale checkpoint copies in two live roots still resolve as ambiguous and deny.
- The closing step never uses a force flag, `git add -A`, or `git add .`.
- No production file exceeds 500 lines. `WorktreeRunResolution.psm1` is near the limit, so the matcher goes in a new module and `Test-WorktreeRunPathEqual` moves into it.
- Hook dependency imports use the guarded `try { Import-Module ... } catch { Add-HookDependencyFailure ... }` form.

### Dependencies or blocked work:
- None blocking. The standalone merge-on-green change (D8) is a separate, later issue that will overlap in `parallel-orchestrate/SKILL.md`; it is sequenced after this one.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- New: `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1`.
- Edit: `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`.
- Edit: `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`.
- Edit: `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/agents/parallel-orchestrator.md`.
- Edit if matcher contract wording changes: `.claude/rules/parallel-orchestration.md`.
- Update or remove as stale: `.claude/agent-memory/parallel-orchestrator/worktree-removal-gate-path-mismatch.md`.
- Mirrors: byte-identical copies under `extensions/drm-copilot/resources/claude-customizations/.claude/` of every file above that has a bundle copy; new module entry in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.

#### Functions/classes/CLI commands impacted:
Matcher family (every site that compares a recorded `worktree_path` to a removal target):
- Run resolution: `Test-WorktreeRunCheckpointRecord` and `Resolve-WorktreeRunTargetByRecord` (with `Test-WorktreeRunPathEqual` relocated).
- Parallel gate: `Find-ParallelWorktreeItemRecord`.
- Epic gate: `Find-EpicWorktreeFeatureRecord` and `Test-ParallelCheckpointAllowsWorktreeRemoval`.
- Diagnostics helper: `Find-EpicWorktreeGateParallelItemRecord`.
- Manifest coverage test: `Test-CleanupManifestCheckpointCoversPath`.

The family is stated by name; this spec asserts no count. Any later count must be re-derived with two independent strategies per the research record.

New functions in `WorktreeRunRecordPath.psm1`:
- `Test-WorktreeRunPathEqual` (moved unchanged).
- `Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath -TargetPath -BaseRoot <string[]>`.
- `Get-WorktreeRunMainCheckoutRoot -SessionRoot` (the only function with a filesystem seam).

#### Data flow and validation changes:
- A rooted recorded path compares as today.
- A relative recorded path is joined to each base root and compared. Base roots are the main checkout root and the checkpoint's own root (D1).
- A relative record is rejected (matches nothing) when it is blank, is `.`, is `..`, has a `.` or `..` segment, or contains `:`.
- The matcher applies to epic `features[]` as well as parallel `items[]` (D2).
- The manifest coverage test uses the same matcher, so a manifest entry cannot authorize removal of a target that a checkpoint records relatively with an unsafe status.

#### Error handling and logging updates:
- Deny reason text and prefixes are unchanged.
- A refused item removal in the closing step is recorded as a `completed_steps` entry naming the path and refusal reason, and does not fail completion.

#### Rollback/feature-flag considerations (if applicable):
- None. Revert by reverting the change set. The matcher change only widens recognition of records whose status already permits removal.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `Test-WorktreeRunRecordedPathMatchesTarget` returns a boolean. Inputs are strings; no filesystem access.
- `Run Closing` substeps, in order, run once after every non-withdrawn item is `merged` or `worktree_removed` and before completion is reported:
  1. Item worktrees: take the absolute path from `git worktree list --porcelain`, never the relative `items[].worktree_path`. Unlock only when the item is `merged`, the lock reason names the item's own agent, and no force flag is used (D3). Run `git worktree remove <path>` without a force flag. On success record `merge_status: worktree_removed` and `worktree_removed_at`. On refusal leave `merged`, record the deferral, and continue.
  2. Final status: regenerate `docs/features/parallel/<slug>/parallel-status.md`.
  3. Records: stage the run folder and the promoted records created for the run by literal path, in commands whose every path is under `docs/features/` or `artifacts/orchestration/`, relying on the existing docs-only exemptions (D4). Never stage `docs/features/active/<item>/` folders. Require that the branch diff against `origin/main` lists only `docs/` paths; otherwise stop and report, never force or split the branch (D6). Push, delegate the pull request to `Agent(pr-author)` with the `branch:` label, merge with `gh pr merge <PR> --merge` naming the pull request number, and confirm the merge with the existing merge-on-green confirmation procedure.
  4. Scratch worktrees: add no hook allow. Run `cleanup-merged-worktrees` after the records merge is confirmed, and report any scratch worktree that is not delete-eligible as a deferral (D5).
  5. Report: list every deferral.
- `parallel-orchestrator` `tools:` gains `Agent(pr-author)`.

#### Required configuration keys and defaults:
- New `core.json` entry for `WorktreeRunRecordPath.psm1`. No other configuration keys.

#### Backward-compatibility expectations:
- Existing absolute-path records match exactly as before, including the separator, trailing-slash, and case rules.
- Existing and in-flight checkpoints with relative records start working without being rewritten.

#### Performance constraints (latency/throughput/memory):
- The matcher adds string comparisons only. The main-root seam is evaluated once per resolution, not per record.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): the recorded relative `worktree_path` is relative to the main checkout, supported by the admin directory layout of the item worktrees (research section 1).
- Constraints (budget, performance, compatibility): PowerShell Pester only, no temporary files in tests, no file over 500 lines, line coverage at least 85% per changed file (PowerShell branch coverage is not measured). The change touches more than three production PowerShell files, so it belongs on the large orchestration route.
- External dependencies (services, libraries, releases): none new.

## Data / API / Config Impact
- User-facing or API changes: none to command syntax. New exported functions in a new module.
- Data or migration considerations: none; existing checkpoints are read as written.
- Logging/telemetry updates (if any): none beyond the `completed_steps` deferral entries.
- Compatibility notes (CLI flags, config schemas, versioning): `core.json` gains one module entry. The execution-environment brief copies are re-checked with `test_execution_environment_brief_contracts.py` and changed only if that test requires it.

## Test Strategy
- Regression tests to add or update:
  - New `tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1`: relative join to each base root, rooted pass-through, rejection of `.`, `..`, segment `..`, `:`, and blank records, and the separator and case rules moved with `Test-WorktreeRunPathEqual` (POSIX and drive-letter style, one case-rule test each).
  - Extend `WorktreeRunResolution.Record.Tests.ps1` and `WorktreeRunResolution.Tests.ps1` with relative-record cases.
  - One end-to-end allow case per gate (parallel gate, epic gate parallel-item branch, epic gate feature branch): checkpoint in a different live root, relative `worktree_path`, `merge_status` `merged`, absolute command target under a mocked main root.
  - Negative cases per gate: `pr_open`, `worktree_created`, no `merge_status`, a different agent name, a `..` record, a blank record, and a stale checkpoint copy in two live roots (ambiguous deny).
  - A `CleanupWorktreeManifestGateMatrix.Tests.ps1` case: a manifest entry for a target recorded relatively with an unsafe status stays denied.
  - A diagnostics-helper case confirming the deny text path uses the shared matcher.
  - Content checks that the `Run Closing` section and `Agent(pr-author)` tool exist in the skill, agent, and mirrors.
- Unit tests (Pester) for the fixed behavior and boundaries: as above; use existing read seams and `Set-RecordTopology`-style mocks; never mock `git`; mock `Get-WorktreeResolutionGitEntryKind` or `Get-WorktreeItemLiveRoot` for the main-root function.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): blank, `.`, `..`, embedded `:`, trailing separators, mixed separators, case differences, absent `merge_status`.
- Error handling and logging verification: deny reason prefixes and text are unchanged for denied cases.
- Coverage impact and targets for changed lines/modules: at least 85% line coverage per changed or added PowerShell file, read from `artifacts/pester/powershell-coverage.xml`.
- Toolchain commands to run (format, lint, type-check, test): PowerShell formatting and PSScriptAnalyzer, then the Pester suites named above, plus the push-down contract, pack-manifest completeness, dependency-closure, and execution-environment brief tests, the Codex generator `--check`, `claude-architecture-doc.Tests.ps1`, and `hook-dependency-guard-completeness.Tests.ps1`.
- Manual validation steps (if required): see Live-Verification Items.

## Live-Verification Items
These cannot be established by unit tests or by source reading. They are not acceptance facts. Each is verified on a live run after merge, with command output recorded under `evidence/regression-testing/`, and each has a defined deferral behavior.
- LV1: `git worktree remove` succeeds after `git worktree unlock` while the harness process for the item is alive (Windows file handles may refuse). Deferral: record the refusal, leave `merged`, report.
- LV2: the merge queue admits the docs-only records pull request without delay, and `origin/main` is present locally when the merge hook evaluates it. Deferral: report the pull request as open.
- LV3: `Agent(pr-author)` invoked from the forked `parallel-orchestrator` with a `branch:` label and no issue number passes the model-routing receipt check. Deferral: report that the records pull request needs manual authoring.
- LV4: a fresh two-cohort run ends with records merged and no item worktree left, other than reported deferrals. The original repro can only be rerun after merge.

## Implementation Deviations
Recorded at execution of `plan.2026-10-29T05-58.md`:
- New test files carry the relative-record cases instead of extending `WorktreeRunResolution.Record.Tests.ps1` and `WorktreeRunResolution.Tests.ps1`: `WorktreeRunRecordPath.Tests.ps1`, `WorktreeRunResolution.RelativeRecord.Tests.ps1`, and one `.RelativeRecord.Tests.ps1` suite per removal gate. `WorktreeRunResolution.Record.Tests.ps1` was already above 450 lines; it received helper-only edits.
- `Run Closing` is a `### Run Closing` subsection (at the end of `## Worktree Cleanup` in the skill and of `## Completion Requirements` in the agent), because contract tests pin the skill's sixteen and the agent's nine `##` headings.
- `parallel-orchestrator` `tools:` also gains `Bash(bash .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh*)`, the grant the Run Closing scratch-worktree substep needs.
- Plan Design Decision 7: the closing step runs the `cleanup-merged-worktrees` report first and runs `--apply` only when every delete-eligible row is a worktree the run created; otherwise it applies nothing and reports each scratch worktree as a deferral.
- `test_agent_tools_allowlist_excludes_pr_author_channel` was replaced by `test_agent_tools_allowlist_grants_only_the_records_pr_author_channel`, because D4 reverses the behavior the old test asserted.
- `Get-EpicWorktreeGateDenyDiagnostics` gained an optional `-MainRoot` parameter so the gate passes the main checkout root it already derived, keeping the main-root seam to one call per gate decision.
- Three repository guard suites outside the plan's file list required additive updates when the new files landed: `WorktreeResolution.Manifest.Tests.ps1` (the new module joins its expected-path lists), and the two new gate `.RelativeRecord.Tests.ps1` suites gained the baseline null mocks and interception-probe row that `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` requires; two new matrix rows were named to satisfy `test-name-uniqueness.Tests.ps1`.
- `.claude/agent-memory/` is ignored by `.gitignore`, so the updated `worktree-removal-gate-path-mismatch.md` note and its `MEMORY.md` index line exist in the executing checkout only and are not part of the branch diff.

## Acceptance Criteria
- [x] `WorktreeRunRecordPath.psm1` exists under `.claude/lib/worktree-resolution/` and exports `Test-WorktreeRunPathEqual`, `Test-WorktreeRunRecordedPathMatchesTarget`, and `Get-WorktreeRunMainCheckoutRoot`; `Test-WorktreeRunPathEqual` is no longer defined in `WorktreeRunResolution.psm1`.
- [x] Pester cases in `WorktreeRunRecordPath.Tests.ps1` show that a relative recorded path such as `.claude/worktrees/agent-x` matches the absolute target formed by joining it to the main checkout root, and that a rooted recorded path matches exactly as before.
- [x] Pester cases show that blank, `.`, `..`, paths containing a `.` or `..` segment, and paths containing `:` never match any target, including the main checkout root.
- [x] Every site in the matcher family (run resolution, parallel gate, epic gate features and parallel-item sites, diagnostics helper, manifest coverage test) calls the shared matcher; a search of `.claude/**/*.ps1` and `*.psm1` finds no inline `worktree_path` normalise-and-compare outside `WorktreeRunRecordPath.psm1`.
- [x] Pester cases show that both `enforce-parallel-worktree-removal-gate.ps1` and `enforce-epic-worktree-removal-gate.ps1` allow removal of an absolute target whose checkpoint record is a relative `worktree_path` with `merge_status` `merged` (and with `worktree_removed`).
- [x] Pester cases show that both gates still deny a relative record whose `merge_status` is `pr_open`, `worktree_created`, or absent, a record for a different agent, and a target recorded in checkpoint copies in two live roots (ambiguous).
- [x] A Pester case in `CleanupWorktreeManifestGateMatrix.Tests.ps1` shows that a manifest entry for a target recorded relatively with an unsafe status stays denied.
- [x] The `merge_status` predicate and the fail-closed ordering in both gates and in run resolution are unchanged, evidenced by the pre-existing suites listed under Test Strategy passing without edits to their existing assertions.
- [x] `parallel-orchestrate/SKILL.md` contains a `Run Closing` section that specifies the item worktree step (absolute path from `git worktree list --porcelain`, unlock only for a merged item whose lock reason names its own agent, removal without a force flag, deferral on refusal), final status regeneration, records landing by literal path with no `git add -A` or `git add .`, the docs-only branch-diff precondition with stop-and-report, the `Agent(pr-author)` pull request with a `branch:` label, merge by explicit pull request number, the scratch worktree step, and deferral reporting; its Completion Requirements reference the section.
- [x] `.claude/agents/parallel-orchestrator.md` contains the same closing procedure, lists `Agent(pr-author)` in `tools:`, and its completion conditions reference the closing step.
- [x] A content test or documented search shows every command example in the `Run Closing` section that stages or commits uses only literal paths under `docs/features/` or `artifacts/orchestration/`.
- [x] Every changed Claude file has a byte-identical bundle copy, `core.json` lists `WorktreeRunRecordPath.psm1`, and the push-down contract, pack-manifest completeness, and dependency-closure tests pass.
- [x] No production or test file added or changed by this issue exceeds 500 lines, evidenced by recorded physical line counts.
- [x] The merge-gate hooks, the #670 authorization branch, and the Codex hooks are unchanged by this issue's diff.
- [x] The Non-goals section records the standalone merge-on-green change as out of scope (D8), tracked in a separate issue.
- [x] The Live-Verification Items are each labelled as live verification with a stated deferral behavior, and no acceptance criterion asserts their outcome.
- [x] Line coverage is at least 85% for each changed or added PowerShell file, read from `artifacts/pester/powershell-coverage.xml`.
- [x] The local toolchain passes in a single pass (format, lint, Pester suites named in Test Strategy, including three seeded shuffled runs and one single-process full run recorded under `evidence/regression-testing/`).
- [x] Docs and config references (`parallel-orchestration.md` line describing the parallel allow branch, the stale agent-memory note) match the new behavior.
- [x] (CI verified on head f99f0bca0568674cd66e4a80fd4e5c86ea301be4, PR #998) The Pester suites named in Test Strategy pass in CI on the pull request head, with `ci_gate.conclusion` `success` and `ci_gate.head_sha` equal to the final PR head. This criterion is verified and checked off by the item's own orchestrator run at S9, not before CI has run.

### Acceptance Criteria Evidence
Criteria are numbered AC-1 through AC-20 in list order. Paths are relative to this feature folder.
- AC-1: `evidence/other/matcher-family-search.2026-10-29T10-58.md` (strategy 2b), `evidence/qa-gates/pester-coverage.2026-10-29T11-40.md` (WorktreeRunRecordPath.Tests.ps1 X1 export row).
- AC-2: `evidence/qa-gates/pester-coverage.2026-10-29T11-40.md` (WorktreeRunRecordPath.Tests.ps1, 31 tests, 0 failures; rows M1, M2, M4).
- AC-3: same artifact (rows M7, M8, M10).
- AC-4: `evidence/other/matcher-family-search.2026-10-29T10-58.md`.
- AC-5: `evidence/regression-testing/expect-fail.2026-10-29T10-48.md` (fail before) and `evidence/qa-gates/pester-coverage.2026-10-29T11-40.md` (RP1, RE1 pass).
- AC-6: `evidence/regression-testing/gate-suites.2026-10-29T10-57.md` and `evidence/qa-gates/pester-coverage.2026-10-29T11-40.md` (RP2, RP3, RE2, RE3).
- AC-7: `evidence/regression-testing/expect-fail.2026-10-29T10-48.md` and `evidence/qa-gates/pester-coverage.2026-10-29T11-40.md` (matrix rows "denies the relative-record case when ...").
- AC-8: `evidence/qa-gates/assertion-preservation.2026-10-29T11-42.md` and `evidence/regression-testing/gate-suites.2026-10-29T10-57.md`.
- AC-9: `evidence/qa-gates/pester-coverage.2026-10-29T11-40.md` (parallel-orchestrate-run-closing.Tests.ps1 RC rows, 56 tests, 0 failures).
- AC-10: same artifact (RA rows) and `evidence/qa-gates/python-contracts.2026-10-29T11-41.md` (test_agent_tools_allowlist_grants_only_the_records_pr_author_channel).
- AC-11: same Pester artifact (RC4 staging check for both skill copies).
- AC-12: `evidence/qa-gates/mirror-parity.2026-10-29T11-41.md`.
- AC-13: `evidence/qa-gates/line-counts.2026-10-29T11-43.md`.
- AC-14: `evidence/qa-gates/scope-check.2026-10-29T11-42.md`.
- AC-15: `evidence/other/spec-doc-criteria.2026-10-29T11-45.md`.
- AC-16: same artifact.
- AC-17: `evidence/qa-gates/coverage-comparison.2026-10-29T11-41.md`.
- AC-18: `evidence/qa-gates/poshqc-format.2026-10-29T11-21.md`, `evidence/qa-gates/pssa.2026-10-29T11-21.md`, `evidence/qa-gates/pester-coverage.2026-10-29T11-40.md` (fresh single-process full run), `evidence/regression-testing/isolation.2026-10-29T11-44.md` (three seeded shuffled runs).
- AC-19: `.claude/rules/parallel-orchestration.md` `## Enforcement` bullet names `Test-WorktreeRunRecordedPathMatchesTarget` (`evidence/qa-gates/python-contracts.2026-10-29T11-41.md`, test_claude_rules_frontmatter.py); the agent-memory note was updated in the executing checkout only, because `.claude/agent-memory/` is ignored by git (see `## Implementation Deviations`).
- AC-20: CI on PR #998 passed every check on head f99f0bca0568674cd66e4a80fd4e5c86ea301be4 (`gh pr checks 998` reported no failing or pending check); checked off by the item's own orchestrator run at S9.

## Risks & Mitigations
- Technical or operational risks:
  - A matcher site is missed and still compares raw strings (most likely the diagnostics helper or the manifest coverage test).
  - A relative record such as `.` or `..` authorizes the main checkout.
  - Bundle parity or `core.json` drift fails push-down tests.
  - Adding code inline breaks the 500-line limit.
  - Test isolation: shared `$script:` state across suites that dot-source the same hooks.
  - Linux CI uses a case-sensitive file system and forward-slash paths, unlike the Windows host.
  - `git add` of the records sweeps in item folders under `docs/features/active/`.
- Mitigations and rollbacks:
  - The matcher family is listed by name, with one task per site and a search-based acceptance criterion.
  - Negative tests for `.`, `..`, `:`, and blank records.
  - A task per file pair for mirrors, then the push-down, completeness, and closure tests.
  - New module for the matcher; physical line counts recorded before and after.
  - No temporary files, mocks scoped to `BeforeEach`, seeded shuffled runs.
  - POSIX-root fixtures and no drive letters in Linux-run suites; no test reads gitignored `artifacts/` state.
  - The closing step stages by literal path only.
  - Rollback: revert the change set.

## Rollout & Follow-up
- Release/rollout steps: deliver on the large orchestration route; merge by the normal pull request flow; rebuild and reinstall the extension payload before relying on push-down of the changed resources.
- Post-fix monitoring or clean-up tasks:
  - File the separate issue for D8 (standalone merge-on-green hook change) after this one; sequence it after this issue because both edit `parallel-orchestrate/SKILL.md`, `.claude/rules/orchestrator-state.md`, and `.claude/rules/parallel-orchestration.md`.
  - Run the live-verification items on the next two-cohort run.
  - Resolve D5 by checking whether the planner creates its scratch worktrees without need.
- Decisions applied (research defaults): D1 main checkout root plus the checkpoint's own root; D2 apply to `features[]` and `items[]`; D3 unlock only for a merged item whose lock names its own agent, no force; D4 docs-only pull request through existing exemptions with `Agent(pr-author)` added; D5 no hook allow, cleanup tool after records merge; D6 stop and report on non-docs commits; D7 Codex twin deferred; D8 out of scope, separate issue.
- Links: issue #995 (https://github.com/drmoisan/drm-copilot/issues/995), research `research/research.2026-10-29T10-07.md`, related items #989 (PR #991) and #990 (PR #993).
