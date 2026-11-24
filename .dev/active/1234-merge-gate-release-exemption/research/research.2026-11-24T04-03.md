# Research: Checkpoint-Free Release Pull Request Merge (Issue #1234)

- Issue: #1234
- Branch: feature/merge-gate-release-exemption-1234
- Feature folder: .dev/active/1234-merge-gate-release-exemption/
- Sources read: `issue.md`, `spec.md` (Draft 0.1), `.dev/active/1231-pr-author-release-exemption/research/research.2026-11-23T23-00.md`, the hooks and tests cited below, `scripts/harness-generation/sources/rules/orchestrator-state.md`, `scripts/dev_tools/generate_codex_agent_variants.py`, `.codex/config.toml`, `config/harness-parity-matrix.json`, and the GitHub CLI query builder (`https://raw.githubusercontent.com/cli/cli/trunk/api/query_builder.go`, fetched for the `files` fragment).
- Tool limits: this researcher has no Bash, `git`, or `gh`, so no command, Pester run, or line measurement was made. Line counts come from Read tool numbering; the plan re-measures them with `@(Get-Content -LiteralPath <path>).Count`. The filename stamp of this file was not read from a clock (no clock tool is available to this agent); the orchestrator should confirm or rename it.

## 1. Current State: Decision Order of the Merge Gates

### 1.1 Claude gate `.claude/hooks/enforce-epic-merge-gate.ps1` (498 lines)

Dot-sourced siblings (all guarded with `Add-HookDependencyFailure`): `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `enforce-epic-merge-gate-authorization.ps1`, `enforce-epic-merge-gate-resolution.ps1`, `enforce-epic-merge-gate-command.ps1`, `hook-docs-only-diff.ps1`, `enforce-epic-merge-gate-green-ci.ps1`, `enforce-epic-merge-gate-review.ps1`, `DevelopmentDocsRoot.psm1`, `enforce-epic-merge-gate-child-ci.ps1`, `enforce-epic-merge-gate-regeneration.ps1`.

`Invoke-EpicMergeGateDecision` order:

1. Dependency failure decision (deny `EPIC_MERGE_GATE_BLOCKED:`).
2. Envelope anomaly (deny).
3. No `command` (allow).
4. Scope (`Test-EpicMergeGateCommandInScope`, `-command.ps1`); out-of-scope text goes through the review shape check only, then allows.
5. `$commandPrNumber` (`Get-EpicMergeGateSelectorPrNumber`), `$sessionRoot` (`Get-EpicMergeGateSessionWorktreeRoot`).
6. Item target (`Resolve-EpicMergeGateItemTarget`) and per-feature checkpoint read; `NoTarget` reads no checkpoint (`$childCheckpoint = $null`).
7. Review guard: `Get-EpicMergeGateReviewShapeDecision`, `Get-EpicMergeGateReviewDecision`, `Get-EpicMergeGateRegenerationDecision`; any denial returns.
8. Branch 1, epic child: `Test-ChildCheckpointAllowsEpicMerge` + `Test-ChildCheckpointPrGateBinding`, then `Get-EpicMergeGateChildCiDecision`; allow or deny with no fall-through.
9. Epic and parallel run targets (`Resolve-EpicMergeGateRunTarget`) and branch 2 (`Test-EpicCheckpointAllowsMerge`), branch 3 (`Test-ParallelCheckpointAllowsMerge`).
10. Branch 3b green-CI (`Get-EpicMergeGateGreenCiDecision`); stages A-C decline silently, D-E return a `GREEN_CI_*` suffix.
11. Explicit PR number only: branch 4 (`Test-StandaloneCheckpointAllowsMerge`); on decline, the docs-only branch (`Get-DocsOnlyMergeExemption`) runs only when `Test-EpicMergeGateNoRecordingTarget` (item, epic, parallel all `NoTarget`); then the deny at line 444:
    `'EPIC_MERGE_GATE_BLOCKED: ' + $prefix + $standalone.ReasonCode + ': ' + $standalone.Message + $docsOnlySuffix + $greenCi.Suffix`
    where `$prefix` is `Get-EpicMergeGateUnresolvedReason` + `'; '` (for example `TARGET_WORKTREE_NOT_DERIVABLE: ...; `) and `$docsOnlySuffix` is `' (docs-only exemption not applied: <Reason>)'`.
12. Bare command: the fixed long deny at line 447.

A checkpoint-free release merge therefore reaches step 11 with the item, epic, and parallel targets `NoTarget` and denies with `TARGET_WORKTREE_NOT_DERIVABLE ... STANDALONE_MERGE_AUTHORIZATION_ABSENT ... (docs-only exemption not applied: DOCS_ONLY_EXEMPTION_NON_DOCS_PATH ...)` (the shape pinned in `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1`).

Placement of the release leg: inside the step 11 block, after the docs-only branch declines and before the deny, so every earlier branch (epic child, epic, parallel, green-CI, standalone, docs-only) keeps its order and outcome. Its suffix is appended as the last term of the line 444 deny. Step 12 (bare command) is unchanged because the leg needs an explicit number.

### 1.2 Codex gate `.codex/hooks/enforce-epic-merge-gate.ps1` (446 lines)

`Invoke-CodexEpicMergeDecision(PayloadRaw, ChildCheckpointRaw, EpicCheckpointRaw, RepositoryRoot)`: scope, review guard (no reader), epic child with child-CI, epic integration, then for an explicit number the standalone authorization; on decline, the docs-only branch only when both checkpoint texts at the repository root are blank (OD-1); deny at line 242 `'EPIC_MERGE_GATE_BLOCKED: ' + $verdict.ReasonCode + ': ' + $verdict.Message + $docsOnlySuffix`. Codex has no green-CI and no parallel branch. `RepositoryRoot` is derived from `$PSScriptRoot`; gh and git run there.

Finding: the Codex gate blocks the same checkpoint-free release merge (`STANDALONE_MERGE_AUTHORIZATION_ABSENT` plus the docs-only suffix). The #1201 commit leg exists on Codex (`enforce-orchestration-preimplementation-gate-release.ps1` is in both trees), and Codex has no pr-author skill gate (#1231 research Section 5), so on Codex the release flow is currently commit allowed, PR creation ungated, merge denied.

### 1.3 Review guard interaction (question 6)

- `Get-EpicMergeGateReviewShapeDecision` returns pass with no checkpoint read when `Get-EpicMergeGateReviewBoundPrNumber` binds the command to one number; `gh pr merge <N> --merge --match-head-commit <sha>` is bound.
- `Get-EpicMergeGateReviewDecision` returns pass immediately when `Test-EpicMergeGateReviewModeConcurrent -Checkpoint $null` is false (`$childCheckpoint` is `$null` for an item `NoTarget`); it starts no process.
- `Get-EpicMergeGateRegenerationDecision` passes for `$null` (no `remediation_loop.review_outcomes`).
- Codex passes no reader and uses `$child` parsed from a blank text (`$null`), so the same result holds.
Conclusion: for a checkpoint-free merge the guard sees no `review_mode` key and does not deny; no change to the guard is needed.

## 2. Reusable Parts

| Need | Reuse | Location |
|---|---|---|
| Allowance file read (absent returns `$null`, throws on non-file) | `Get-OrchestrationGateReleaseAllowanceConfigText`, `Test-OrchestrationGateReleaseAllowancePathIsContainer` | `enforce-orchestration-preimplementation-gate-release.ps1` (both trees, byte-identical; it dot-sources `hook-release-allowance-context.ps1`) |
| Parse, container probe, state | `Get-ReleasePullRequestConfigState` (calls `ConvertFrom-ReleaseAllowanceConfig`) | `hook-release-pull-request-context.ps1` (Claude only today) |
| Branch and path decision | `Get-ReleasePullRequestPathDecision` (calls `Test-ReleaseAllowanceBranchMatch`; first matching allowance listing every path wins; ordinal case-sensitive; failures `BranchNotMatched`, `EmptyPath`, `PathNotAllowed`) | same |
| Command shape (one segment, structural `gh pr merge`, no `VAR=`, no `-R`/`--repo`, no `/pull/`, no `--auto`) | `Get-DocsOnlyMergeShapeViolation` | `hook-docs-only-diff.ps1` (both trees) |
| `--admin` and `--match-head-commit` reads | `Test-CommandLineFlag`, `Get-CommandLineFlagValue` (as in `Get-EpicMergeGateGreenCiDecision`) | `hook-command-invocation-operands.ps1` (both trees) |
| Bounded gh (7000 ms, never throws, `-GhInvoker` seam) | `Invoke-DocsOnlyGhExe` | `hook-docs-only-diff.ps1` |
| Run list and newest `CI` run | `Get-EpicMergeGateChildCiRunList` (`gh run list --commit <head> --limit 100 --json databaseId,event,status,conclusion,headSha,workflowName,createdAt`), `Select-EpicMergeGateChildCiRun` (workflowName `CI`, headSha equal, newest by createdAt then databaseId) | `enforce-epic-merge-gate-child-ci.ps1` (both trees, byte-identical, loaded by both gates) |
| Object-id test | `Test-EpicMergeGateChildCiObjectId` | same |
| No-recording predicate (Claude) | `Test-EpicMergeGateNoRecordingTarget` | `enforce-epic-merge-gate-resolution.ps1` |

Constraints verified on the #1231 files:
- `release-pull-request.Parity.Tests.ps1` requires `hook-release-pull-request-context.ps1` to define exactly two functions with the `ReleasePullRequest` prefix and to contain no `ConvertFrom-Json`, `WildcardPattern`, `python`, or `poetry`. No predicate may be added to it; the merge leg must live in its own file, which needs `ConvertFrom-Json` for gh output (that token rule covers only the four #1231 leaves).
- `hook-release-allowance-context.ps1` is about 495 lines and pinned below 500 by its parity suite; not edited.
- The #1231 legs load their dependencies with the same two guarded dot-sources (`enforce-model-routing-receipt-release.ps1` lines 38-39); the merge leg follows that form.

GitHub CLI facts (fetched from `api/query_builder.go`): `--json files` expands to `files(first: 100) {nodes {additions,deletions,path,changeType}}`, and `changedFiles` is a plain field. The GraphQL changed-file node has no previous-path field, so a `RENAMED` entry lists only the new path.

## 3. Candidate Approaches

**A. One byte-identical sibling `enforce-epic-merge-gate-release.ps1` in `.claude/hooks/` and `.codex/hooks/`, with gh-sourced changed files (recommended).** The file dot-sources (guarded) `enforce-orchestration-preimplementation-gate-release.ps1` and `hook-release-pull-request-context.ps1`, defines one gh seam and pure helpers, and exposes `Get-EpicMergeGateReleaseDecision`. Each gate adds one guarded dot-source, one call line, and the suffix term. Codex receives a byte-identical copy of `hook-release-pull-request-context.ps1`. Advantages: one implementation for both runtimes (the child-CI precedent), reuse of the #1201/#1231 parser, matcher, and seams, changed files read from the server-side pull-request diff that the merge applies, no local fetch or head-commit presence needed. Limitations: the 100-file cap and rename visibility require explicit fail-closed checks; one extra Codex file plus mirrors.

**Rejected alternatives.**
- B. Local `git diff origin/<base>...<head>` as in `Get-DocsOnlyMergeExemption` M4-M7: needs the head commit locally and a current `origin/<base>`, adds three git calls, and diverges from the issue's single `gh pr view` design; its only advantage (both rename paths) is covered in A by denying renames.
- C. Claude-only leg with the Codex decision recorded: leaves the Codex release flow blocked although the Codex gate denies the same case, which the issue directs to fix.

## 4. Behavior Semantics (Approach A)

Signature (byte-identical in both trees):
`Get-EpicMergeGateReleaseDecision -CommandText <string> -PrNumber <int?> -WorktreeRoot <string> -NoRecordingTarget <bool> [-ConfigReader <scriptblock>] [-ContainerProbe <scriptblock>]`, returning `[ordered]@{ Allowed; Suffix }`. Defaults of the two scriptblocks call the #1201 seams, as in `Get-OrchestrationReleaseAllowanceResult`. The whole body sits in `try/catch`; an unexpected error returns `Allowed $false`, `Suffix ''`, and a `Write-Debug` record `EPIC_MERGE_GATE_RELEASE_LEG_ERROR`.

Callers:
- Claude: `-WorktreeRoot $sessionRoot` (where gh already runs), `-NoRecordingTarget (Test-EpicMergeGateNoRecordingTarget -ItemTarget $itemTarget -EpicTarget $epicTarget -ParallelTarget $parallelTarget)`.
- Codex: `-WorktreeRoot $RepositoryRoot`, `-NoRecordingTarget ([string]::IsNullOrWhiteSpace($ChildCheckpointRaw) -and [string]::IsNullOrWhiteSpace($EpicCheckpointRaw))` (the OD-1 rule of its docs-only branch).

Evaluation order (first failure decides; suffix ` (release merge not applied: <CODE>: <detail>)`):

1. `PrNumber` null or not positive, or `WorktreeRoot` blank: decline, empty suffix, no I/O.
2. `Get-ReleasePullRequestConfigState` with the injected seams. `Absent`: decline, empty suffix, no gh call. `Invalid`: `RELEASE_MERGE_CONFIG_INVALID` with its `Detail`.
3. `NoRecordingTarget` false: `RELEASE_MERGE_CHECKPOINT_PRESENT` (a checkpoint records the PR or the target is ambiguous; on Codex a checkpoint exists at the repository root).
4. `Get-DocsOnlyMergeShapeViolation` non-null, or `--admin` present: `RELEASE_MERGE_COMMAND_NOT_MODELLED` (detail is the shape text with its `DOCS_ONLY_EXEMPTION_PR_UNRESOLVED: ` prefix removed, or `--admin is not eligible`).
5. `--match-head-commit` absent, or its value not a lowercase 40/64-hex id: `RELEASE_MERGE_MATCH_HEAD_MISSING`.
6. One bounded call through the new seam `Get-EpicMergeGateReleasePullRequest -PrNumber -WorktreeRoot`: `Invoke-DocsOnlyGhExe -GhArgs @('pr','view',<N>,'--json','headRefName,baseRefName,headRefOid,state,isCrossRepository,changedFiles,files')`; non-zero exit, unparseable output, a non-object, a `headRefOid` that is not a full lowercase id, a `headRefName` or `baseRefName` outside `^[A-Za-z0-9][A-Za-z0-9._/-]*$` or holding `..`, a non-boolean `isCrossRepository`, a non-integer `changedFiles`, or a non-array `files`: `RELEASE_MERGE_PR_UNRESOLVED`.
7. `state` not exactly `OPEN`: `RELEASE_MERGE_PR_NOT_OPEN`.
8. `isCrossRepository` true: `RELEASE_MERGE_CROSS_REPOSITORY` (a fork head named like a release branch must not match).
9. `headRefOid` not ordinally equal to the `--match-head-commit` value: `RELEASE_MERGE_HEAD_MISMATCH`.
10. `changedFiles` greater than 100, or the `files` count not equal to `changedFiles`: `RELEASE_MERGE_FILES_TRUNCATED`.
11. Any `files[].changeType` outside `ADDED`, `MODIFIED`, `CHANGED`, `DELETED` (in particular `RENAMED` and `COPIED`, whose source path is not listed) or a blank `path`: `RELEASE_MERGE_CHANGE_NOT_MODELLED`.
12. `Get-ReleasePullRequestPathDecision -Allowances -Branch headRefName -Path <paths>`: `BranchNotMatched` maps to `RELEASE_MERGE_BRANCH_NOT_MATCHED`, `EmptyPath` to `RELEASE_MERGE_EMPTY_DIFF`, `PathNotAllowed` to `RELEASE_MERGE_PATH_NOT_ALLOWED`.
13. `Get-EpicMergeGateChildCiRunList -HeadSha headRefOid` returns `$null`: `RELEASE_MERGE_CI_UNREADABLE`.
14. `Select-EpicMergeGateChildCiRun` returns `$null`: `RELEASE_MERGE_CI_MISSING`.
15. The selected (newest `CI`) run's `event` is not exactly `pull_request` (a newer `push` or `workflow_dispatch` run denies; there is no recorded dispatch id without a checkpoint): `RELEASE_MERGE_CI_EVENT_NOT_ALLOWED`.
16. `status` not `completed` or `conclusion` not `success`: `RELEASE_MERGE_CI_NOT_GREEN` (covers pending and failed).
17. Otherwise `Allowed $true`.

Process calls: zero when the file is absent or for any failure at steps 1-5; one `gh pr view` for steps 6-12; one `gh run list` for steps 13-17. The docs-only branch still makes its own `gh pr view` first, so an admitted release merge costs three gh calls and the docs-only git calls.

Gate wiring:
- Claude, after the docs-only block: `$release = Get-EpicMergeGateReleaseDecision ...; if ($release.Allowed) { return Get-EpicMergeGateAllowDecision }` on one line, and line 444 ends `... + $docsOnlySuffix + $greenCi.Suffix + $release.Suffix)`.
- Codex, after the docs-only block, the same one-line call, and line 242 ends `... + $docsOnlySuffix + $release.Suffix`.

Byte identity without the file: step 2 returns an empty suffix before any gh call, so every deny text and every `Should -Invoke Invoke-DocsOnlyGhExe -Times <n> -Exactly` count in the existing suites is unchanged. The repository commits no allowance file (pinned by `hook-release-allowance-context.Parity.Tests.ps1`), and existing merge-gate suites set the session root to `$PSScriptRoot` or the repository root and do not mock `Test-Path` or `Get-Content` (Grep over the merge-gate, epic-execution, session-root, consumer, parity-corpus, and end-to-end suites returned no such mock).

Edge cases: a destination that commits the file gains a release suffix on every explicit-number merge deny (informational, as in #1231); `--squash` and `--rebase` are not restricted, matching the docs-only and green-CI branches; the base branch is validated for spelling only (the allowance schema has no base field); the PR's server-side file list is the diff between the merge base and the head, which is what the merge applies.

## 5. Requirements Mapping

| Draft AC | Design element |
|---|---|
| Admit the checkpoint-free merge with matching branch, allowed paths, head, green CI | Steps 1-17, allow at 17 |
| Distinct sub-code per failure (path, branch, invalid file, missing pin, head mismatch, CI missing/pending/failed/push, checkpoint present, disallowed shape) | Steps 2-16 codes |
| Byte-identical text and no extra gh call without the file | Step 2 absent decline before I/O |
| Reuse parser, matcher, and #1231 predicate file | `Get-ReleasePullRequestConfigState`, `Get-ReleasePullRequestPathDecision`, #1201 seams via guarded dot-source |
| Mirrors, manifests, rule and brief through sources | Section 6 |
| Pester with injected gh seams, no Python | Section 7 |

## 6. Files That Must Change

Production (each with its bundle copy, which counts against the batch budget; the orchestrated large route applies):

| File | Change | Size (Read numbering) |
|---|---|---|
| `.claude/hooks/enforce-epic-merge-gate-release.ps1` | new, the leg | target under 400 |
| `.codex/hooks/enforce-epic-merge-gate-release.ps1` | new, byte-identical | same |
| `.codex/hooks/hook-release-pull-request-context.ps1` | new, byte-identical copy of the Claude file | 116 |
| `.claude/hooks/hook-release-pull-request-context.ps1` | header `.NOTES` only: name both trees and the merge leg as a consumer (no function change; two functions stay) | 116 |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | one guarded dot-source, one call line, suffix term, header phrase | 498; must stay at or below 500 (see Pre-Mortem) |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | one guarded dot-source, one call line, suffix term, header paragraph | 446 |
| Bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` (release leg, pure file, gate) and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` (release leg, pure file, gate) | byte-identical | - |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | add `.claude/hooks/enforce-epic-merge-gate-release.ps1` | - |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | add `.codex/hooks/enforce-epic-merge-gate-release.ps1` and `.codex/hooks/hook-release-pull-request-context.ps1` (hook paths in this manifest are hand-maintained; `render_manifest` in `generate_codex_agent_variants.py` only appends agent paths) | - |

Generated documentation (edit the source, run `scripts/harness-generation/Invoke-HarnessGeneration.ps1`; `HarnessGeneration.RepoGate.Tests.ps1` reports hand edits):
- `scripts/harness-generation/sources/rules/orchestrator-state.md` (renders `.claude/rules/orchestrator-state.md` and its bundle copy): in `## Release-Commit Allowance Scope`, replace "Merging the release pull request is not covered and stays with the merge gate." with a release merge paragraph naming `Get-EpicMergeGateReleaseDecision`, both gates, the `RELEASE_MERGE_*` codes, the `--match-head-commit` requirement, the CI rule, and the honest-disclosure sentence; keep the tokens pinned by `release-pull-request.Parity.Tests.ps1` (`RELEASE_EXEMPTION_`, `RELEASE_DELEGATION_`, `RELEASE_RECEIPT_`, `policy-level control`, `destination-owned`) and by `hook-release-allowance-context.Parity.Tests.ps1`.
- `.agents/skills/execution-environment/SKILL.md` (renders the other three copies): replace "Merging the release pull request is not covered." in the `Release pull-request legs (#1231)` bullet, add a `Release merge leg (#1234)` bullet to `## Hook Execution Context`, and add the new parity suite to `## Contract Tests That Pin Mirrored Files`.
- `.agents/skills/pr-author/SKILL.md` (renders `.claude/skills/pr-author/SKILL.md` and bundles): replace "Merging the release pull request is not covered by these legs." with a pointer to the merge leg; the `## Checkpoint-Free Release Delegation (issue #1231)` heading and tokens stay.
- `config/harness-parity-matrix.json`: no change; it lists hook registrations (lines 809 and 6634 for the two merge gates), not dot-sourced helpers (Grep for `child-ci` and `hook-release` returns nothing).

Tests that list helper files and must be extended:
- `tests/scripts/codex-hooks/cross-tree-helper-identity.Tests.ps1`: add `enforce-epic-merge-gate-release.ps1` and `hook-release-pull-request-context.ps1` to `$script:IdenticalHelpers`.
- `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`: optionally add the new Codex runtime path to its root/bundle identity and manifest lists.

## 7. Testing Implications

Existing seams and patterns:
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1`: dot-sources the gate, registers `EpicStateIsolation.Baseline.Helpers.ps1`, mocks the three checkpoint content seams, `Get-WorktreeItemCheckpointText`/`Get-WorktreeItemLiveRoot`/`Get-WorktreeRunCheckpointText` by module, `Get-EpicMergeGateSessionWorktreeRoot`, `Resolve-EpicMergeGateItemTarget`, `Resolve-EpicMergeGateRunTarget`, `Invoke-DocsOnlyGhExe`, and `Invoke-DocsOnlyGitExe`, and asserts call counts with `Should -Invoke ... -ParameterFilter { ($GhArgs -join ' ') -ceq '...' }`.
- `enforce-epic-merge-gate.ChildCi.Tests.ps1` and `tests/scripts/codex-hooks/enforce-epic-merge-gate-child-ci.Tests.ps1`: run-list fixtures and both-tree execution.
- `enforce-orchestration-preimplementation-gate-release.Tests.ps1` and the #1231 suites: injected `ConfigReader`/`ContainerProbe` scriptblocks with synthetic `/synthetic-worktrees/...` roots.

Proposed suites:
- `tests/scripts/claude-hooks/enforce-epic-merge-gate-release.Tests.ps1`: unit rows for `Get-EpicMergeGateReleaseDecision` with injected config scriptblocks and mocked `Invoke-DocsOnlyGhExe` keyed on `$GhArgs[0..1]`: one allow row, one row per code, absent-file row asserting zero gh calls, unexpected-error row, renamed-file row, truncation rows (`changedFiles` 101; count mismatch), newest-run-is-push row.
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Release.Tests.ps1`: decision-level rows through `Invoke-EpicMergeGateDecision` (allow; deny suffix last after the docs-only and green-CI suffixes; byte-identical deny text with the file absent; `CHECKPOINT_PRESENT` when an item target resolves; review guard inert).
- `tests/scripts/codex-hooks/enforce-epic-merge-gate-release.Tests.ps1`: the same allow and suffix rows through `Invoke-CodexEpicMergeDecision`.
- `tests/scripts/claude-hooks/release-merge.Parity.Tests.ps1`: byte identity across the four copies of the leg and the pure file, both `core.json` listings, the suffix as the last deny term in both gate copies and their bundles, no `python`/`poetry` text, and the brief/rule/skill tokens.
- Optional: a `hook-dependency-failure.SpecialCases.Tests.ps1` row for a failed load of the new file.

All rows use synthetic roots and forward slashes, no temporary files, and the launcher (`sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <paths>`) for task checks. Shards pick up new files automatically.

## 8. Risks

- Head race: `--match-head-commit` is required and gh rejects a merge whose head moved after the lookup.
- Rename and copy entries are denied because the source path is not visible; a release bump does not rename files.
- More than 100 changed files denies (`RELEASE_MERGE_FILES_TRUNCATED`); release diffs are small.
- Allowance file location: read beneath the session root (Claude) or repository root (Codex), the root gh runs in; a locally edited, uncommitted allowance file widens the leg. Policy-level control, as in #1201 and #1231. A PR that edits the allowance file itself is admitted only when the file is listed in `allowed_paths`.
- Codex OD-1: any checkpoint at the repository root (also an unrelated item's) yields `RELEASE_MERGE_CHECKPOINT_PRESENT`; same rule as the Codex docs-only branch.
- Workflow name `CI` is an assumption shared with #1130; a destination with a different workflow name denies with `RELEASE_MERGE_CI_MISSING`.
- Time: an admitted merge runs three bounded gh calls (7 s each) plus the docs-only git calls (3 s each), worst case about 30 s; the Codex dispatcher registration timeout is 720 s (`.codex/config.toml`), and the Claude registration in `.claude/settings.json` sets no timeout (the runtime default is not verified here).
- Isolated subagents run `main`'s hook copies, so behavior on the branch is proven by Pester only.

## 9. Automation Feasibility

No human interaction is required. Every leg stage is pure PowerShell behind injectable seams (`ConfigReader`, `ContainerProbe`, `Invoke-DocsOnlyGhExe` via its `-GhInvoker` or a mock, `Get-EpicMergeGateChildCiRunList`), verified by Pester suites, the harness generator check, the push-down contract tests, and the cross-tree identity suite, all runnable by the executor through the test-execution launcher and the `sh` route. The batch budget needs the orchestrated large route (about ten production files including bundle copies). A live end-to-end release merge in a destination repository is optional confirmation and no draft AC requires it. Owner standing constraints: decide with the recommended option (Approach A, Codex parity included) and do not run the full test suite outside the baseline and final QA gates.

## Numeric Derivation Evidence

Claim: two merge-gate entry points must be wired (used in Section 6; not yet an approved `spec.md` AC).

- Complete Family: every PreToolUse merge-gate entry point in this repository's runtime surfaces (`.claude/hooks/`, `.codex/hooks/`); bundle copies are mirrors of these and excluded.
- Exhaustive Search Scope: `.claude/hooks/` and `.codex/hooks/` file names, and the hook-registration rows of `config/harness-parity-matrix.json`.
- Inclusion Rules: a file that is a registered PreToolUse entry point and evaluates `gh pr merge`.
- Exclusion Rules: dot-sourced siblings (`-authorization`, `-resolution`, `-command`, `-green-ci`, `-review`, `-child-ci`, `-regeneration`), bundle mirrors, and tests.
- Primary Search Strategy or Query Expression: Glob `.claude/hooks/enforce-epic-merge-gate*.ps1` and read the Codex gate; keep files that define a decision entry point (`Invoke-EpicMergeGateDecision`, `Invoke-CodexEpicMergeDecision`).
- Primary Member Set: `.claude/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`.
- Primary Count: 2.
- Cross-check Search Strategy or Query Expression: Grep `enforce-epic-merge-gate` in `config/harness-parity-matrix.json` and keep `hook-registration` rows.
- Cross-check Member Set: `claude:hook-registration:PreToolUse/Bash/enforce-epic-merge-gate` (Claude gate), `codex:hook-registration:PreToolUse/%5EBash%24/enforce-epic-merge-gate` (Codex gate).
- Cross-check Count: 2.
- Member-set Comparison: the normalized primary set {claude gate, codex gate} equals the normalized cross-check set. Agreement.

## Pre-Mortem

- Review checklists: a reviewer could flag a hand edit of a generated rule, brief, or skill copy, or a changed deny text without an allowance file. Mitigation: edit only `scripts/harness-generation/sources/rules/orchestrator-state.md`, `.agents/skills/execution-environment/SKILL.md`, and `.agents/skills/pr-author/SKILL.md`, run the generator, and carry byte-identical-deny rows with the file absent for both gates.
- Coverage: the new leg file must reach 85% line coverage in the single Pester gate run in both trees' measurement; catch paths, every code, and seam failures need rows. Mitigation: one row per code plus error and absent rows, read from `artifacts/pester/powershell-coverage.xml`.
- Mirror parity: the leg and the pure file must be byte-identical in four copies, both gates in their bundles, both `core.json` files list the new paths, `cross-tree-helper-identity.Tests.ps1` lists the two shared helpers, and the brief changes in four copies through its source. Mitigation: a brief-update task, the new `release-merge.Parity.Tests.ps1`, and the contract suites `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both pack-manifest completeness suites, and `test_push_down_pack_manifest_dependency_closure.py`.
- File size: `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` caps `.claude/hooks/enforce-epic-merge-gate.ps1` at 500 lines, and it is at 498. Mitigation: add at most two physical lines (one dot-source, one call line) and keep header growth at zero by rewording existing lines; put the leg description in the new file's header; measure before and after with `@(Get-Content -LiteralPath <path>).Count`. The new file stays under 500.
- Test isolation: suites must use synthetic roots, mocked seams, and no temporary files, register the epic-state baseline mocks, and remove helper functions they define; `Invoke-PoshQCLeakScan` fails on unpaired global state. Mitigation: follow `enforce-epic-merge-gate.DocsOnly.Tests.ps1` and run the leak scan through the launcher.
- CI-only behavior: `poshqc / PowerShell hook suites (Linux)` runs `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` on a case-sensitive file system. Mitigation: forward-slash relative paths, exact file-name case, no drive letters, and no read of `origin/main` or gitignored `artifacts/` state.
- Evidence: gate results go under `.dev/active/1234-merge-gate-release-exemption/evidence/<kind>/` with UTC write-time stamps and are append-only; PoshQC MCP results carry no counts. Mitigation: counts from `artifacts/pester/pester-junit.xml` and the coverage XML of launcher runs; full suites only at the Phase 0 baseline and final QA.
