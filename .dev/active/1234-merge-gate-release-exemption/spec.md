# 2026-11-23-merge-gate-release-exemption — Spec

- **Issue:** #1234
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-24
- **Status:** Draft
- **Version:** 0.2
- **Research:** `.dev/active/1234-merge-gate-release-exemption/research/research.2026-11-24T04-03.md`

## Overview

Issue #1201 lets an agent commit a release version bump without an orchestration checkpoint on a branch matching the destination-owned `.claude/release-commit-allowance.json`, and issue #1231 (PR #1232) lets the same agent open the release pull request without a checkpoint. Merging that pull request is still blocked. `.claude/hooks/enforce-epic-merge-gate.ps1` admits a `gh pr merge` only through the epic-child, epic, parallel, green-CI, `standalone_merge_authorizations`, or docs-only branch, and each of the first five reads an orchestrator checkpoint while the docs-only branch admits only paths under `docs/`. A checkpoint-free release pull request therefore reaches `EPIC_MERGE_GATE_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE: ...; STANDALONE_MERGE_AUTHORIZATION_ABSENT: ... (docs-only exemption not applied: DOCS_ONLY_EXEMPTION_NON_DOCS_PATH ...)`, and the release flow stops one step before completion. #1231 recorded the merge as out of scope.

The research found that `.codex/hooks/enforce-epic-merge-gate.ps1` denies the same case with `STANDALONE_MERGE_AUTHORIZATION_ABSENT` and the docs-only suffix. Per the issue's instruction, the same leg is added to the Codex gate.

## Decisions

- **D1 (adopted): Approach A of the research.** One byte-identical sibling file `enforce-epic-merge-gate-release.ps1` in `.claude/hooks/` and `.codex/hooks/`, reading the pull request's changed files from one bounded `gh pr view` call. The rejected alternatives are a local `git diff` leg (Approach B) and a Claude-only leg (Approach C); the reasons are recorded in research Section 3.
- **D2 (adopted): Codex parity.** The Codex gate blocks the same case (research Section 1.2), so the leg is wired into both gates. Codex receives a byte-identical copy of `.claude/hooks/hook-release-pull-request-context.ps1`.
- **D3 (adopted): Placement.** The leg runs inside the explicit-number block of each gate, after the docs-only branch declines and before the final deny, so every earlier branch keeps its order and outcome.

## Behavior

### Entry point

`Get-EpicMergeGateReleaseDecision -CommandText <string> -PrNumber <int?> -WorktreeRoot <string> -NoRecordingTarget <bool> [-ConfigReader <scriptblock>] [-ContainerProbe <scriptblock>]` returns `[ordered]@{ Allowed; Suffix }`. The default `ConfigReader` and `ContainerProbe` call `Get-OrchestrationGateReleaseAllowanceConfigText` and `Test-OrchestrationGateReleaseAllowancePathIsContainer`, as in `Get-OrchestrationReleaseAllowanceResult`.

Callers:

- Claude: `-WorktreeRoot $sessionRoot` and `-NoRecordingTarget (Test-EpicMergeGateNoRecordingTarget -ItemTarget $itemTarget -EpicTarget $epicTarget -ParallelTarget $parallelTarget)`.
- Codex: `-WorktreeRoot $RepositoryRoot` and `-NoRecordingTarget ([string]::IsNullOrWhiteSpace($ChildCheckpointRaw) -and [string]::IsNullOrWhiteSpace($EpicCheckpointRaw))`, the rule its docs-only branch already applies.

### Evaluation order

The first failing step decides. A failure at steps 2-16 returns `Allowed = $false` and the suffix ` (release merge not applied: <CODE>: <detail>)`.

1. `PrNumber` is null or not positive, or `WorktreeRoot` is blank: decline with an empty suffix and no I/O.
2. `Get-ReleasePullRequestConfigState` with the injected seams. `Absent`: decline with an empty suffix and no `gh` call. `Invalid` (read throw, parse failure, or an `allowed_paths` entry that is a directory): `RELEASE_MERGE_CONFIG_INVALID` with the parser `Detail`.
3. `NoRecordingTarget` is false: `RELEASE_MERGE_CHECKPOINT_PRESENT`.
4. `Get-DocsOnlyMergeShapeViolation` returns non-null (chain, wrapper, `VAR=` prefix, `-R`/`--repo`, URL selector, `--auto`, or a non-structural `gh pr merge`), or `--admin` is present: `RELEASE_MERGE_COMMAND_NOT_MODELLED`. The detail is the shape text with its `DOCS_ONLY_EXEMPTION_PR_UNRESOLVED: ` prefix removed, or `--admin is not eligible`.
5. `--match-head-commit` is absent, or its value is not a lowercase 40- or 64-character hexadecimal object id: `RELEASE_MERGE_MATCH_HEAD_MISSING`.
6. One bounded call through the new seam `Get-EpicMergeGateReleasePullRequest -PrNumber -WorktreeRoot`, which runs `Invoke-DocsOnlyGhExe -GhArgs @('pr','view',<N>,'--json','headRefName,baseRefName,headRefOid,state,isCrossRepository,changedFiles,files')`. A non-zero exit, unparseable output, a non-object, a `headRefOid` that is not a full lowercase object id, a `headRefName` or `baseRefName` outside `^[A-Za-z0-9][A-Za-z0-9._/-]*$` or containing `..`, a non-boolean `isCrossRepository`, a non-integer `changedFiles`, or a non-array `files`: `RELEASE_MERGE_PR_UNRESOLVED`.
7. `state` is not exactly `OPEN`: `RELEASE_MERGE_PR_NOT_OPEN`.
8. `isCrossRepository` is true: `RELEASE_MERGE_CROSS_REPOSITORY`.
9. `headRefOid` is not ordinally equal to the `--match-head-commit` value: `RELEASE_MERGE_HEAD_MISMATCH`.
10. `changedFiles` is greater than 100, or the `files` count differs from `changedFiles`: `RELEASE_MERGE_FILES_TRUNCATED`.
11. A `files[].changeType` outside `ADDED`, `MODIFIED`, `CHANGED`, `DELETED` (including `RENAMED` and `COPIED`), or a blank `path`: `RELEASE_MERGE_CHANGE_NOT_MODELLED`.
12. `Get-ReleasePullRequestPathDecision -Allowances -Branch <headRefName> -Path <paths>`: `BranchNotMatched` maps to `RELEASE_MERGE_BRANCH_NOT_MATCHED`, `EmptyPath` to `RELEASE_MERGE_EMPTY_DIFF`, and `PathNotAllowed` to `RELEASE_MERGE_PATH_NOT_ALLOWED`.
13. `Get-EpicMergeGateChildCiRunList -HeadSha <headRefOid>` returns `$null`: `RELEASE_MERGE_CI_UNREADABLE`.
14. `Select-EpicMergeGateChildCiRun` returns `$null`: `RELEASE_MERGE_CI_MISSING`.
15. The selected run (the newest `CI` workflow run for the head commit) has an `event` other than exactly `pull_request`: `RELEASE_MERGE_CI_EVENT_NOT_ALLOWED`.
16. The selected run's `status` is not `completed` or its `conclusion` is not `success`: `RELEASE_MERGE_CI_NOT_GREEN`.
17. Otherwise: `Allowed = $true`, empty suffix.

The whole body is inside `try/catch`. An unexpected error returns `Allowed = $false`, `Suffix = ''`, and writes a `Write-Debug` record `EPIC_MERGE_GATE_RELEASE_LEG_ERROR`; the gate's deny stands.

### Gate wiring

- Claude, after the docs-only block: one line `$release = Get-EpicMergeGateReleaseDecision ...; if ($release.Allowed) { return Get-EpicMergeGateAllowDecision }`. The final explicit-number deny ends `... + $docsOnlySuffix + $greenCi.Suffix + $release.Suffix)`.
- Codex, after the docs-only block: the same one-line call returning the Codex allow decision. The final explicit-number deny ends `... + $docsOnlySuffix + $release.Suffix`.
- The bare-command deny (no explicit number) is unchanged in both gates.

### Review guard

The review guard (`Get-EpicMergeGateReviewShapeDecision`, `Get-EpicMergeGateReviewDecision`, `Get-EpicMergeGateRegenerationDecision`) is not changed. For a checkpoint-free merge the command is bound to one number and the checkpoint is `$null`, so the guard passes without a process call (research Section 1.3).

## Inputs / Outputs

- Inputs: the PreToolUse payload command text; `.claude/release-commit-allowance.json` beneath the session root (Claude) or repository root (Codex), schema version 1, unchanged; `gh pr view <N> --json headRefName,baseRefName,headRefOid,state,isCrossRepository,changedFiles,files`; `gh run list --commit <head> --limit 100 --json databaseId,event,status,conclusion,headSha,workflowName,createdAt`.
- Outputs: a PreToolUse allow decision for the admitted case; otherwise the existing deny with the release suffix appended as the last term when an allowance file is present; a `Write-Debug` record on a caught error.
- Config keys: none added.
- Backward compatibility: without an allowance file, every decision and deny text of both gates is unchanged, and no additional `gh` or `git` process is started.

## API / CLI Surface

- Admitted command form: `gh pr merge <N> --merge --match-head-commit <sha>`; `--squash` and `--rebase` are also accepted, matching the docs-only and green-CI branches.
- Not admitted: a command without an explicit number, a URL or branch selector, `-R`/`--repo`, a `VAR=` prefix, a chain or wrapper, `--auto`, `--admin`, or a missing or malformed `--match-head-commit`.
- Deny suffix form: ` (release merge not applied: <CODE>: <detail>)`.

## Data & State

- No persisted state is added. The leg reads the allowance file, one `gh pr view` result, and one `gh run list` result at decision time.
- Invariant: the leg admits only when every changed path of the pull request equals an `allowed_paths` entry of one allowance whose `branch_patterns` match the head branch, the live head equals `--match-head-commit`, and the newest `CI` run on that head is a completed, successful `pull_request` run.
- Process calls: none when the file is absent or for a failure at steps 1-5; one `gh pr view` for steps 6-12; one `gh run list` for steps 13-17.
- No migration.

## Constraints & Risks

- **Policy-level control disclosure.** The leg is a policy-level control, not a security control. Whoever can commit `.claude/release-commit-allowance.json` decides which paths may be merged without an orchestration checkpoint. A successful CI run on the exact head is the remaining safeguard.
- A push after the lookup can change the head; the required `--match-head-commit` makes `gh` reject the merge in that case.
- Renamed and copied entries deny because the GraphQL changed-file node lists no source path.
- A pull request with more than 100 changed files denies with `RELEASE_MERGE_FILES_TRUNCATED`.
- The workflow name `CI` is an assumption shared with #1130; a destination with a different name denies with `RELEASE_MERGE_CI_MISSING`.
- On Codex, any checkpoint at the repository root yields `RELEASE_MERGE_CHECKPOINT_PRESENT`, the same rule as the Codex docs-only branch.
- A destination that commits the allowance file gains a release suffix on every explicit-number merge deny; this is informational.
- The allowance file is destination-owned and never pushed down; this repository commits none.
- PowerShell only; enforcement hooks invoke no Python.
- `.claude/hooks/enforce-epic-merge-gate.ps1` is at 498 lines and capped at 500 by `session-root-reads-850.Constraints.Tests.ps1`; the leg goes in the sibling file and the gate grows by at most two physical lines.
- Isolated subagents run the default branch's hook copies, so branch behavior is proven by Pester.
- An admitted merge runs three bounded `gh` calls (the docs-only branch makes its own `gh pr view` first) plus the docs-only `git` calls.

## Non-Goals

- Any change to the allowance schema, its keys (`branch_patterns`, `allowed_paths`), or its location.
- Any change to the order or outcome of the existing allow branches: epic child, epic, parallel, green-CI, `standalone_merge_authorizations`, and docs-only.
- Any change to the review guard (`Get-EpicMergeGateReviewShapeDecision`, `Get-EpicMergeGateReviewDecision`, `Get-EpicMergeGateRegenerationDecision`).
- Any change to `hook-release-allowance-context.ps1`, `enforce-orchestration-preimplementation-gate-release.ps1`, `enforce-epic-merge-gate-child-ci.ps1`, `hook-docs-only-diff.ps1`, or `hook-command-invocation-operands.ps1`, and any change to the function set of `hook-release-pull-request-context.ps1`.
- Restricting the merge method, validating the base branch beyond spelling, or a configurable CI workflow name.
- Admitting a bare `gh pr merge` without an explicit number.
- Fetching remote refs or running a local diff inside the leg.
- A new hook registration, and therefore any change to `config/harness-parity-matrix.json`.
- Changing `scripts/dev-tools/Invoke-FullRelease.ps1`.

## Implementation Strategy

- New hook files:
  - `.claude/hooks/enforce-epic-merge-gate-release.ps1`: the leg; guarded dot-sources (`Add-HookDependencyFailure` form, as in `enforce-model-routing-receipt-release.ps1`) of `enforce-orchestration-preimplementation-gate-release.ps1` and `hook-release-pull-request-context.ps1`; defines `Get-EpicMergeGateReleasePullRequest` (the `gh` seam), pure helpers, and `Get-EpicMergeGateReleaseDecision`.
  - `.codex/hooks/enforce-epic-merge-gate-release.ps1`: byte-identical copy.
  - `.codex/hooks/hook-release-pull-request-context.ps1`: byte-identical copy of the Claude file.
- Edited hook files:
  - `.claude/hooks/hook-release-pull-request-context.ps1`: `.NOTES` header only, naming both trees and the merge leg as a consumer.
  - `.claude/hooks/enforce-epic-merge-gate.ps1`: one guarded dot-source, one call line, the suffix term, and a reworded header phrase with no net header growth.
  - `.codex/hooks/enforce-epic-merge-gate.ps1`: one guarded dot-source, one call line, the suffix term, and a header paragraph.
- Bundle copies of every new and edited hook file under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`.
- Pack manifests: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` adds `.claude/hooks/enforce-epic-merge-gate-release.ps1`; `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` adds `.codex/hooks/enforce-epic-merge-gate-release.ps1` and `.codex/hooks/hook-release-pull-request-context.ps1` by hand (the generator appends agent paths only).
- Documentation sources, regenerated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1`:
  - `scripts/harness-generation/sources/rules/orchestrator-state.md`, `## Release-Commit Allowance Scope`: replace "Merging the release pull request is not covered and stays with the merge gate." with a release merge paragraph.
  - `.agents/skills/execution-environment/SKILL.md`: update the `Release pull-request legs (#1231)` bullet, add a `Release merge leg (#1234)` bullet to `## Hook Execution Context`, and add the new parity suite to `## Contract Tests That Pin Mirrored Files`.
  - `.agents/skills/pr-author/SKILL.md`: replace "Merging the release pull request is not covered by these legs." with a pointer to the merge leg.
- Test-list extensions: `tests/scripts/codex-hooks/cross-tree-helper-identity.Tests.ps1` (`$script:IdenticalHelpers`); optionally `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`.
- Dependencies: none added.
- Rollout: active in a destination only when it commits an allowance file; no flag.

## Acceptance Criteria

### Admitted case

- [ ] AC-01: In `.claude/hooks/enforce-epic-merge-gate.ps1`, a checkpoint-free `gh pr merge <N> --merge --match-head-commit <sha>` is allowed when a valid allowance file exists beneath the session root, no item, epic, or parallel target resolves, the live pull request is `OPEN` and not cross-repository, its head branch matches one allowance, every changed path is listed in that allowance's `allowed_paths`, the live head equals `<sha>`, and the newest `CI` run on that head is a `pull_request` run that is `completed` with conclusion `success`; a decision-level Pester row through `Invoke-EpicMergeGateDecision` proves it.
- [ ] AC-02: In `.codex/hooks/enforce-epic-merge-gate.ps1`, the same command under the same conditions, with blank child and epic checkpoint texts, is allowed; a decision-level Pester row through `Invoke-CodexEpicMergeDecision` proves it.

### Evaluation order and sub-codes

- [ ] AC-03: Step 1: a null or non-positive `PrNumber`, or a blank `WorktreeRoot`, declines with an empty suffix and invokes neither the config reader nor `Invoke-DocsOnlyGhExe`; a Pester row exists for each input.
- [ ] AC-04: Step 2: an absent allowance file declines with an empty suffix and zero `Invoke-DocsOnlyGhExe` calls; a read throw, a `ConvertFrom-ReleaseAllowanceConfig` failure, and an `allowed_paths` entry reported as a directory each yield `RELEASE_MERGE_CONFIG_INVALID` with the parser detail; a Pester row exists for each case.
- [ ] AC-05: Step 3: `RELEASE_MERGE_CHECKPOINT_PRESENT` is returned when `NoRecordingTarget` is false; a Claude decision-level row with a resolved item target and a Codex decision-level row with a non-blank checkpoint text each prove it.
- [ ] AC-06: Step 4: `RELEASE_MERGE_COMMAND_NOT_MODELLED` is returned for a chained command, a `VAR=` prefix, `-R`, `--repo`, a URL selector, `--auto`, and `--admin`, each with the detail defined in the Behavior section; a Pester row exists for each form.
- [ ] AC-07: Step 5: `RELEASE_MERGE_MATCH_HEAD_MISSING` is returned for a missing `--match-head-commit`, a missing value, an uppercase value, and a value that is neither 40 nor 64 hexadecimal characters; a Pester row exists for each case.
- [ ] AC-08: Step 6: `RELEASE_MERGE_PR_UNRESOLVED` is returned for a non-zero `gh pr view` exit, unparseable output, a non-object, an invalid `headRefOid`, an invalid `headRefName` or `baseRefName` (including one containing `..`), a non-boolean `isCrossRepository`, a non-integer `changedFiles`, and a non-array `files`; the `gh pr view` call carries exactly the arguments `pr view <N> --json headRefName,baseRefName,headRefOid,state,isCrossRepository,changedFiles,files`; a Pester row exists for each case.
- [ ] AC-09: Step 7: a `state` other than exactly `OPEN` (including `MERGED`, `CLOSED`, and `open`) yields `RELEASE_MERGE_PR_NOT_OPEN`; Pester rows prove it.
- [ ] AC-10: Step 8: `isCrossRepository` true yields `RELEASE_MERGE_CROSS_REPOSITORY`, including when the head branch name matches an allowance; a Pester row proves it.
- [ ] AC-11: Step 9: a `headRefOid` that differs ordinally from the `--match-head-commit` value yields `RELEASE_MERGE_HEAD_MISMATCH`; a Pester row proves it.
- [ ] AC-12: Step 10: `changedFiles` of 101 and a `files` count that differs from `changedFiles` each yield `RELEASE_MERGE_FILES_TRUNCATED`; a Pester row exists for each case.
- [ ] AC-13: Step 11: a `RENAMED` entry, a `COPIED` entry, and a blank `path` each yield `RELEASE_MERGE_CHANGE_NOT_MODELLED`; entries of type `ADDED`, `MODIFIED`, `CHANGED`, and `DELETED` pass this step; Pester rows prove both.
- [ ] AC-14: Step 12: a head branch matching no `branch_patterns` entry yields `RELEASE_MERGE_BRANCH_NOT_MATCHED`, an empty `files` array with `changedFiles` 0 yields `RELEASE_MERGE_EMPTY_DIFF`, and a changed path missing from the matching allowance yields `RELEASE_MERGE_PATH_NOT_ALLOWED`; a row also proves that paths from two different allowances are not combined; a Pester row exists for each case.
- [ ] AC-15: Steps 13-14: a `$null` result of `Get-EpicMergeGateChildCiRunList` yields `RELEASE_MERGE_CI_UNREADABLE`, and a run list with no `CI` run on the head yields `RELEASE_MERGE_CI_MISSING`; the run list is read with `-HeadSha` equal to the live `headRefOid`; a Pester row exists for each case.
- [ ] AC-16: Step 15: a selected newest `CI` run whose `event` is `push` or `workflow_dispatch` yields `RELEASE_MERGE_CI_EVENT_NOT_ALLOWED`, including when an older successful `pull_request` run exists on the same head; Pester rows prove it.
- [ ] AC-17: Step 16: a selected run that is not `completed` (pending) and a completed run whose conclusion is not `success` (failed) each yield `RELEASE_MERGE_CI_NOT_GREEN`; a Pester row exists for each case.
- [ ] AC-18: Every failure at steps 2-16 returns `Allowed = $false` and the single suffix ` (release merge not applied: <CODE>: <detail>)` for the first failing step only; a Pester row with two simultaneous failures proves that only the earlier code is reported.
- [ ] AC-19: The leg makes no process call for a failure at steps 1-5, exactly one `gh pr view` call for a failure at steps 6-12, and exactly one `gh pr view` and one `gh run list` call for steps 13-17; `Should -Invoke ... -Exactly` rows prove each band.
- [ ] AC-20: An unexpected error inside the leg is caught, returns `Allowed = $false` with an empty suffix, writes a `Write-Debug` record containing `EPIC_MERGE_GATE_RELEASE_LEG_ERROR`, and leaves the gate's deny in place; a Pester row proves it.

### Gate integration and unchanged behavior

- [ ] AC-21: Without `.claude/release-commit-allowance.json`, every deny text of `.claude/hooks/enforce-epic-merge-gate.ps1` is byte-identical to its text before this feature, and the gate starts no `gh` or `git` process beyond those it started before; a decision-level row asserts the exact checkpoint-free release-shaped deny string and the exact `Invoke-DocsOnlyGhExe` and `Invoke-DocsOnlyGitExe` counts, and the existing merge-gate suites pass with their call-count assertions unchanged.
- [ ] AC-22: Without `.claude/release-commit-allowance.json`, every deny text of `.codex/hooks/enforce-epic-merge-gate.ps1` is byte-identical to its text before this feature, and the gate starts no `gh` or `git` process beyond those it started before; a Codex decision-level row asserts the exact deny string and call counts, and the existing Codex merge-gate suites pass unchanged.
- [ ] AC-23: With an allowance file present and the leg declining, the release suffix is the last term of the explicit-number deny: after `$docsOnlySuffix` and `$greenCi.Suffix` in the Claude gate, and after `$docsOnlySuffix` in the Codex gate; a decision-level row per gate asserts the order with the preceding suffixes present.
- [ ] AC-24: The leg is evaluated only after the docs-only branch declines in the explicit-number block of each gate; a merge admitted or denied by the epic-child, epic, parallel, green-CI, standalone, or docs-only branch keeps its decision and text with an allowance file present; the bare-command deny is unchanged; decision-level rows prove that the docs-only branch still admits a docs-only diff before the leg runs and that an epic-child decision does not reach the leg.
- [ ] AC-25: The review guard functions are unchanged in every copy, and for a checkpoint-free `gh pr merge <N> --merge --match-head-commit <sha>` the guard passes without starting a process in both gates; a decision-level row per gate proves it.

### Reuse without reimplementation

- [ ] AC-26: The leg parses and classifies the allowance only through `Get-ReleasePullRequestConfigState` (which calls `ConvertFrom-ReleaseAllowanceConfig`), reads the file only through `Get-OrchestrationGateReleaseAllowanceConfigText` and `Test-OrchestrationGateReleaseAllowancePathIsContainer`, and matches branch and paths only through `Get-ReleasePullRequestPathDecision` (which calls `Test-ReleaseAllowanceBranchMatch`); `enforce-epic-merge-gate-release.ps1` defines no JSON parser or schema check for the allowance and no wildcard branch matcher.
- [ ] AC-27: The leg checks the command shape only through `Get-DocsOnlyMergeShapeViolation`, reads flags only through `Test-CommandLineFlag` and `Get-CommandLineFlagValue`, runs `gh` only through `Invoke-DocsOnlyGhExe`, and reads and selects CI runs only through `Get-EpicMergeGateChildCiRunList`, `Select-EpicMergeGateChildCiRun`, and `Test-EpicMergeGateChildCiObjectId`; `enforce-epic-merge-gate-release.ps1` defines no process invoker, command tokenizer, or run selector of its own.
- [ ] AC-28: `hook-release-allowance-context.ps1`, `enforce-orchestration-preimplementation-gate-release.ps1`, `enforce-epic-merge-gate-child-ci.ps1`, `hook-docs-only-diff.ps1`, and `hook-command-invocation-operands.ps1` are unchanged in every copy; `.claude/hooks/hook-release-pull-request-context.ps1` changes only in its `.NOTES` header and keeps its function set; `release-pull-request.Parity.Tests.ps1` and `hook-release-allowance-context.Parity.Tests.ps1` pass unchanged.

### Codex copies, bundle mirrors, and manifests

- [ ] AC-29: `.codex/hooks/enforce-epic-merge-gate-release.ps1` is byte-identical to `.claude/hooks/enforce-epic-merge-gate-release.ps1`, and `.codex/hooks/hook-release-pull-request-context.ps1` is byte-identical to `.claude/hooks/hook-release-pull-request-context.ps1`; `tests/scripts/codex-hooks/cross-tree-helper-identity.Tests.ps1` lists both files in `$script:IdenticalHelpers` and passes.
- [ ] AC-30: Each new and changed file under `.claude/hooks/` is byte-identical to its copy under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and each new and changed file under `.codex/hooks/` is byte-identical to its copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`.
- [ ] AC-31: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists `.claude/hooks/enforce-epic-merge-gate-release.ps1`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` lists `.codex/hooks/enforce-epic-merge-gate-release.ps1` and `.codex/hooks/hook-release-pull-request-context.ps1`; `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both pack-manifest completeness suites, `test_push_down_pack_manifest_dependency_closure.py`, and `hook-dependency-guard-completeness.Tests.ps1` pass.
- [ ] AC-32: No hook registration is added, `config/harness-parity-matrix.json` is unchanged, and the harness parity check passes.
- [ ] AC-33: No `.claude/release-commit-allowance.json` exists in the repository, the bundles, or any pack manifest.

### Generated documentation

- [ ] AC-34: `.claude/rules/orchestrator-state.md`, every copy of the execution-environment brief, and `.claude/skills/pr-author/SKILL.md` describe the release merge leg (`Get-EpicMergeGateReleaseDecision`, both gates, the `RELEASE_MERGE_*` family, the `--match-head-commit` requirement, and the CI rule), and each change is made only in `scripts/harness-generation/sources/rules/orchestrator-state.md`, `.agents/skills/execution-environment/SKILL.md`, or `.agents/skills/pr-author/SKILL.md` and produced by `scripts/harness-generation/Invoke-HarnessGeneration.ps1`; `Invoke-HarnessGeneration.ps1 -Check` reports no drift, `HarnessGeneration.RepoGate.Tests.ps1` passes, and every execution-environment brief copy stays byte-identical.
- [ ] AC-35: The orchestrator-state rule states that the merge leg is a policy-level control, not a security control, and retains the tokens `RELEASE_EXEMPTION_`, `RELEASE_DELEGATION_`, `RELEASE_RECEIPT_`, `policy-level control`, and `destination-owned`; the `## Checkpoint-Free Release Delegation (issue #1231)` heading of the pr-author skill is retained.

### Size, tests, and toolchain

- [ ] AC-36: `.claude/hooks/enforce-epic-merge-gate.ps1` stays at or below 500 lines and `session-root-reads-850.Constraints.Tests.ps1` passes; `enforce-epic-merge-gate-release.ps1` is below 500 logical lines; no changed file exceeds 800 logical lines; sizes are measured with `@(Get-Content -LiteralPath <path>).Count` before and after and recorded as evidence.
- [ ] AC-37: Pester suites `tests/scripts/claude-hooks/enforce-epic-merge-gate-release.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Release.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-release.Tests.ps1`, and `tests/scripts/claude-hooks/release-merge.Parity.Tests.ps1` cover every allow row and code row above with injected `ConfigReader` and `ContainerProbe` scriptblocks and mocked `Invoke-DocsOnlyGhExe` and run-list seams, use synthetic forward-slash roots, create no temporary files, and pass the PoshQC leak scan.
- [ ] AC-38: `enforce-epic-merge-gate-release.ps1` reaches at least 85% line coverage in the Pester coverage run, read from `artifacts/pester/powershell-coverage.xml`.
- [ ] AC-39: No new or changed hook file invokes or names Python or Poetry; `enforcement-hooks-no-python-invocation.Tests.ps1` passes, and `release-merge.Parity.Tests.ps1` asserts the absence of `python` and `poetry` text in each copy of the leg.
- [ ] AC-40: The PowerShell toolchain loop (format, lint, tests, contract checks) completes in one clean pass; evidence is written append-only under `.dev/active/1234-merge-gate-release-exemption/evidence/<kind>/`; the full suite runs only at the baseline and final QA gates.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests
- [ ] Behavior matches acceptance criteria on both the Claude and Codex gates
- [ ] Tests added (unit and decision-level Pester rows)
- [ ] Edge cases and error handling covered by tests
- [ ] Generated docs updated through their sources and the generator
- [ ] `Write-Debug` record on caught errors
- [ ] Toolchain pass completed (format, lint, test, contract checks)

## Seeded Test Conditions (from potential)

- [ ] Unit coverage of the release merge predicate with injected `gh` and file seams
- [ ] Integration through the merge gate's decision order with existing branches declining
- [ ] Byte-identity of mirrors and pack-manifest listing

## Numeric Assertion Note

The research reports two merge-gate entry points (research `## Numeric Derivation Evidence`). That count is not stated as an acceptance criterion. Both derivations select candidates by the file name `enforce-epic-merge-gate` (a name glob and a parity-matrix grep on the same name), so they are not independently constructed against the inclusion rule "a registered PreToolUse entry point that evaluates `gh pr merge`", and the primary strategy reads the Codex gate by name rather than searching `.codex/hooks/` exhaustively. The acceptance criteria instead name each gate this feature changes, without asserting that no other gate evaluates `gh pr merge`.
