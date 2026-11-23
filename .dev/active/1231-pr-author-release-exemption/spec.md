# 2026-11-23-pr-author-release-exemption — Spec

- **Issue:** #1231
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-23T23-30
- **Status:** Draft
- **Version:** 0.2
- **Research:** `.dev/active/1231-pr-author-release-exemption/research/research.2026-11-23T23-00.md`

## Overview

Issue #1201 added the release-commit allowance: a destination repository that commits `.claude/release-commit-allowance.json` lets an agent stage and commit a release version bump on a matching branch without an orchestration checkpoint. Opening the release pull request remains blocked. `.claude/hooks/enforce-pr-author-skill.ps1` requires an orchestrator-state checkpoint that passes `--require-pr-creation-ready` for every `gh pr create --body-file`, and its only checkpoint-free exemptions are the docs-only exemption (#901, every path under `docs/`) and the cleanup consolidation exemption (#1026, branch `documentationandmemories`). A release diff changes package manifests, lockfiles, and configuration files, so neither exemption applies.

Today a release pull request is opened only because `scripts/dev-tools/Invoke-FullRelease.ps1` calls `gh pr create` inside a PowerShell process the hook cannot read. That is an inspection gap, not a designed path, and destination repositories have no equivalent script. An agent-driven release therefore needs a full orchestration checkpoint for a version-bump diff of a few files.

The research walked the creation sequence (`collect_pr_context`, `git push`, `Agent(pr-author)`, body Write, receipt Write, `sha256sum`, `date -u`, `gh pr create`, `gh pr view`, SubagentStop) against the registered hooks and identified these gates as denying the checkpoint-free release case:

- `enforce-pr-author-skill.ps1` on `gh pr create` (`ORCHESTRATOR_STATE_PREFLIGHT_FAILED`).
- `enforce-model-routing-receipt.ps1` on `Agent(pr-author)` (`MODEL_ROUTING_RECEIPT_BLOCKED`).
- `enforce-orchestration-preimplementation-gate.ps1` on the Write of `artifacts/pr_body_<N>.receipt.json` (`PREIMPLEMENTATION_GATE_BLOCKED`).

This feature adds one Claude-only allow-side leg to each of those gates.

## Behavior

Each leg is keyed on the existing destination-owned `.claude/release-commit-allowance.json` (schema version 1, unchanged) beneath the resolved worktree root R, parsed by the #1201 parser.

Rules common to every leg:

- The allowance file is read first, through `Get-OrchestrationGateReleaseAllowanceConfigText`. When R is blank or the file is absent, the leg declines with no reason and no suffix, performs no git call and no further I/O, and the gate's deny text is byte-identical to the text produced before this feature.
- A read throw, a `ConvertFrom-ReleaseAllowanceConfig` failure, or an `allowed_paths` entry that `Test-OrchestrationGateReleaseAllowancePathIsContainer` reports as a directory yields the leg's `*_CONFIG_INVALID` code.
- An unexpected error inside a leg is caught; the leg declines with an empty suffix and writes a `Write-Debug` record, following `Get-OrchestrationReleaseAllowanceResult`. The gate's deny therefore stands (fail closed).
- Path matching is ordinal and case-sensitive. Allowance candidates are the allowances whose `branch_patterns` match the branch (`Test-ReleaseAllowanceBranchMatch`), in file order; the first candidate that lists every diff path wins. The leg never combines paths from two allowances.

### Leg 1: `gh pr create` in `enforce-pr-author-skill.ps1` (`Get-PrAuthorReleaseExemption`)

Inputs: `CommandText`, `WorktreeRoot` (the artifact root), `CheckpointPath`. Returns `Exempt` and `Reason` (`$null` when the allowance file is absent). Evaluation order, first failure wins:

1. R blank or allowance file absent: `Exempt = $false`, `Reason = $null`.
2. `RELEASE_EXEMPTION_CONFIG_INVALID`: read throw, invalid parse (with the parser `Detail`), or a directory `allowed_paths` entry.
3. `RELEASE_EXEMPTION_NOT_CREATE`: the command is not a structural `gh pr create` (includes `gh pr edit`).
4. `RELEASE_EXEMPTION_CHECKPOINT_PRESENT`: `Test-PrAuthorDocsOnlyCheckpointPresence` is true.
5. `RELEASE_EXEMPTION_HEAD_UNRESOLVED`: not exactly one `--head` token; a `--head=` token; a single-dash token containing `H`; a missing value; or a value outside `^[A-Za-z0-9][A-Za-z0-9._/-]*$` or containing `..` (rejects `owner:branch`).
6. `RELEASE_EXEMPTION_BASE_UNRESOLVED`: `Get-PrAuthorDocsOnlyBaseName` returns `$null` (also rejects `-R`, `--repo`, `--repo=`, and `GH_REPO=`).
7. `RELEASE_EXEMPTION_BRANCH_NOT_MATCHED`: the `--head` value matches no `branch_patterns` entry.
8. `RELEASE_EXEMPTION_REMOTE_HEAD_MISMATCH`: the new seam `Get-PrAuthorReleasePublishedHead -WorktreeRoot -Branch` (the `Get-PrAuthorCleanupPublishedHead` shape with the branch as a parameter) cannot resolve `refs/remotes/origin/<head>`, or it differs from `HEAD`.
9. `RELEASE_EXEMPTION_DIFF_FAILED`: `refs/remotes/origin/<base>^{commit}` does not resolve, or `git diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <commit>...HEAD` fails or returns non-empty output not ending in NUL.
10. `RELEASE_EXEMPTION_EMPTY_DIFF`: the diff lists no path.
11. `RELEASE_EXEMPTION_PATH_NOT_ALLOWED`: no single matching allowance lists every diff path.

Wiring: `Get-PrAuthorPreflightExemption` in `enforce-pr-author-skill.cleanup.ps1` keeps its docs-only and cleanup result. When that result is not exempt, it calls `Get-PrAuthorReleaseExemption`. An exempt result returns `[ordered]@{ Exempt = $true; Reason = $null }`. A non-null release reason is appended to the existing reason as `; release exemption not applied: <CODE>: <detail>`, so it appears after the docs-only reason and, when present, after `; cleanup exemption not applied: <code>`, inside the parentheses of `ORCHESTRATOR_STATE_PREFLIGHT_FAILED: <summary> (docs-only exemption not applied: ...)`. The receipt checks of `Test-PrAuthorReceiptVerification` run unchanged after an exemption. The leg is reachable only in the non-epic branch of `Get-PrAuthorBypassReason`.

### Leg 2: `Agent(pr-author)` in `enforce-model-routing-receipt.ps1` (`Get-ModelRoutingReleaseDecision`)

Called in `Invoke-ModelRoutingReceiptDecision` inside the existing `pr-author` with null checkpoint block, after the docs-estate leg. Its `DenySuffix` is appended after `$docsSuffix`, with the prefix ` Release delegation leg not applied: `. R is `$resolution.WorktreeRoot`. Evaluation order:

1. R blank or allowance file absent: allow not granted, empty suffix.
2. `RELEASE_DELEGATION_CONFIG_INVALID`.
3. `RELEASE_DELEGATION_LABEL_INVALID`: `Get-DocsEstateDelegationLabel` returns `$null` (the prompt lacks exactly one `branch:` and one `base:` label).
4. `RELEASE_DELEGATION_BRANCH_NOT_MATCHED`: the label branch matches no `branch_patterns` entry.
5. `RELEASE_DELEGATION_DIFF_UNREADABLE`: `Get-ModelRoutingDocsEstateCommit` cannot resolve `refs/remotes/origin/<base>` or `HEAD`, or the bounded diff fails.
6. `RELEASE_DELEGATION_DIFF_EMPTY`.
7. `RELEASE_DELEGATION_PATH_NOT_ALLOWED`.

The remote-head comparison is not repeated at delegation, consistent with the docs-estate and cleanup delegation legs; Leg 1 enforces it.

### Leg 3: receipt Write in `enforce-orchestration-preimplementation-gate.ps1` (`Get-OrchestrationReleaseReceiptResult`)

Called on a new line after `Get-OrchestrationParallelRecordsResult` and before the #1201 `Get-OrchestrationReleaseAllowanceResult` call. Its suffix, with the prefix ` Release receipt leg not applied: `, is inserted in the final deny expression immediately before `$release.DenySuffix`, so the #1201 suffix remains the last term. Evaluation order:

1. `FilePath` blank or not matching `(^|/)artifacts/pr_body_[0-9]+\.receipt\.json$`: decline, empty suffix.
2. R from `Get-OrchestrationGateBookkeepingWorktreeRoot`; a null R declines.
3. An absolute path whose remainder beneath R is not exactly `artifacts/pr_body_<digits>.receipt.json` declines.
4. Allowance file absent: decline, empty suffix.
5. `RELEASE_RECEIPT_CONFIG_INVALID`.
6. `RELEASE_RECEIPT_CHECKPOINT_PRESENT`: `Test-OrchestrationDocsEstateCheckpointPresent` is true.
7. `RELEASE_RECEIPT_BRANCH_NOT_MATCHED`: `Get-EpicScopeWorktreeHeadBranch` of R is detached, unreadable, or matches no pattern.

No diff check runs at this leg, matching the docs-estate receipt rule; the diff is enforced by Legs 1 and 2. The gate's epic-scope decision still runs first.

### Sub-code families and suffix placement

The sub-code families and suffix placement follow the research recommendation (Section 3) without deviation:

| Leg | Family | Suffix form | Placement |
|---|---|---|---|
| 1 | `RELEASE_EXEMPTION_*` | `; release exemption not applied: <CODE>: <detail>` | after the docs-only reason and the cleanup reason, inside the parentheses |
| 2 | `RELEASE_DELEGATION_*` | ` Release delegation leg not applied: <CODE>...` | after `$docsSuffix` |
| 3 | `RELEASE_RECEIPT_*` | ` Release receipt leg not applied: <CODE>...` | after `$parallel.DenySuffix`, before `$release.DenySuffix` |

## Inputs / Outputs

- Inputs: `.claude/release-commit-allowance.json` beneath R (schema version 1, unchanged); the tool payload (`CommandText`, delegation prompt, or `FilePath`); local git refs `HEAD`, `refs/remotes/origin/<head>`, `refs/remotes/origin/<base>`.
- Outputs: PreToolUse allow or deny decisions; deny reasons extended with the release suffixes above when an allowance file is present; `Write-Debug` records on caught errors.
- Config keys: none added. The allowance schema, its keys (`branch_patterns`, `allowed_paths`), and its location are unchanged.
- Backward compatibility: without an allowance file, every gate decision and deny text is unchanged.

## API / CLI Surface

- Allowed command form: `gh pr create --head <branch> --base <base> --body-file artifacts/pr_body_<N>.md` (or the absolute coordinator form).
- Allowed delegation form: `Agent(pr-author)` with a prompt containing exactly one `branch:` line and one `base:` line.
- Allowed Write: `artifacts/pr_body_<N>.receipt.json` beneath R.
- Not exempt: `gh pr edit`, `--head=<b>`, `--head owner:branch`, `-R`/`--repo`/`GH_REPO=`, repeated or missing `--head`/`--base`.

## Data & State

- No persisted state is added. Each leg reads the allowance file and git refs at decision time and never fetches.
- Invariant: the leg exempts only when every path of the `origin/<base>...HEAD` diff (renames listed as both paths; deletions listed) equals an `allowed_paths` entry of one allowance whose pattern matches the branch.
- No migration.

## Constraints & Risks

- **Policy-level control disclosure.** This exemption is a policy-level control, not a security control. Whoever can commit `.claude/release-commit-allowance.json` decides which paths may reach a pull request without an orchestration checkpoint. The legs compare local tracking refs and never fetch: a push from another clone after the local push can leave `refs/remotes/origin/<head>` stale, and `gh pr create` then opens the pull request at the true remote head. This is the same residual as the cleanup K6 check. The documented mitigation is to run `git push` immediately before `gh pr create`.
- The allowance file is destination-owned and never pushed down; this repository commits none.
- A stale local `origin/<base>` widens the three-dot diff and denies with `*_PATH_NOT_ALLOWED` (fail closed); the remedy is `git fetch origin <base>`.
- With an allowance file committed, every failed preflight in that destination gains a release suffix. This is informational.
- PowerShell only; enforcement hooks invoke no Python.
- Hooks run with the default branch's copy in isolated subagents, so behavior is proven by Pester.
- `enforce-orchestration-preimplementation-gate.ps1` moves from about 499 to about 501 lines (500-line guidance tier; no gate fails below 801).

## Non-Goals

- **Merging the release pull request (scope decision D1, binding).** A checkpoint-free merge leg in `.claude/hooks/enforce-epic-merge-gate.ps1` is out of scope. Merging a release pull request without a checkpoint remains denied with `EPIC_MERGE_GATE_BLOCKED`; this feature covers pull-request creation only.
- Editing a release pull request (`gh pr edit`) without a checkpoint.
- Any Codex surface change (`.codex/` hooks, Codex pr-author). The Codex pr-author writes no receipt and runs no `gh pr create`.
- Any change to the allowance schema, to `hook-release-allowance-context.ps1`, or to `enforce-orchestration-preimplementation-gate-release.ps1`.
- Changing `scripts/dev-tools/Invoke-FullRelease.ps1`.
- Fetching remote refs inside a hook.

## Implementation Strategy

- New Claude hook files, each with a bundle copy under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`:
  - `hook-release-pull-request-context.ps1`: pure, no dot-source, no I/O; script-scope prefix `ReleasePullRequest`; `Get-ReleasePullRequestConfigState` (calls the injected config reader and container probe, then `ConvertFrom-ReleaseAllowanceConfig`; returns `State` `Absent|Invalid|Valid`, `Allowances`, `Detail`) and `Get-ReleasePullRequestPathDecision`.
  - `enforce-pr-author-skill.release.ps1`: Leg 1; guarded dot-sources of `enforce-orchestration-preimplementation-gate-release.ps1` and the pure file.
  - `enforce-model-routing-receipt-release.ps1`: Leg 2; same guarded dot-sources.
  - `enforce-orchestration-preimplementation-gate-release-receipt.ps1`: Leg 3; guarded dot-source of the pure file only.
- Edited Claude hook files (with bundle copies): `enforce-pr-author-skill.cleanup.ps1` (dot-source, composite wiring, header), `enforce-pr-author-skill.ps1` (header text only), `enforce-model-routing-receipt.ps1` (dot-source, call, suffix, header), `enforce-orchestration-preimplementation-gate.ps1` (dot-source, call line, deny-line suffix).
- Manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists the new hook files.
- Documentation sources, regenerated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1`:
  - `scripts/harness-generation/sources/rules/orchestrator-state.md` (`## Release-Commit Allowance Scope`).
  - `.agents/skills/execution-environment/SKILL.md` (`## Hook Execution Context`, `## Contract Tests That Pin Mirrored Files`), in every byte-identical copy.
  - `.agents/skills/pr-author/SKILL.md` (new `## Checkpoint-Free Release Delegation (issue #1231)` section).
  - `scripts/harness-generation/sources/agents/pr-author.json` (Precondition sentence naming the checkpoint-free exemptions).
- Not edited: `hook-release-allowance-context.ps1`, `enforce-orchestration-preimplementation-gate-release.ps1`, `enforce-pr-author-skill-helpers.ps1`, `enforce-pr-author-skill.docs-only.ps1`, `enforce-model-routing-receipt-docs.ps1`, all `.codex/` files.
- Dependencies: none added.
- Rollout: active in a destination only when it commits an allowance file; no flag.

## Acceptance Criteria

### Leg 1: `gh pr create` (`enforce-pr-author-skill.ps1`)

- [ ] AC-01: A checkpoint-free structural `gh pr create --head <b> --base <base> --body-file artifacts/pr_body_<N>.md`, with a valid allowance file, `<b>` matching one allowance, `refs/remotes/origin/<b>` equal to `HEAD`, and a non-empty `origin/<base>...HEAD` diff whose every path is listed in that allowance's `allowed_paths`, passes the checkpoint preflight of `enforce-pr-author-skill.ps1`; a Pester row proves the receipt checks of `Test-PrAuthorReceiptVerification` still run and still deny a missing or mismatched receipt.
- [ ] AC-02: Each `RELEASE_EXEMPTION_*` code in the Leg 1 evaluation order (`CONFIG_INVALID`, `NOT_CREATE`, `CHECKPOINT_PRESENT`, `HEAD_UNRESOLVED`, `BASE_UNRESOLVED`, `BRANCH_NOT_MATCHED`, `REMOTE_HEAD_MISMATCH`, `DIFF_FAILED`, `EMPTY_DIFF`, `PATH_NOT_ALLOWED`) keeps the deny and appears in the deny reason; a Pester row exists for each code, including `gh pr edit`, a repeated `--head`, a missing `--base`, `--head=<b>`, `--head owner:branch`, and `--repo`.
- [ ] AC-03: The Leg 1 reason is appended as `; release exemption not applied: <CODE>: <detail>` after the docs-only reason and, when the cleanup reason is present, after `; cleanup exemption not applied: <code>`, inside the parentheses of `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`; a Pester row asserts the order with both preceding reasons present.
- [ ] AC-04: The Leg 1 evaluation runs only in the non-epic branch of `Get-PrAuthorBypassReason`, and a docs-only diff is still exempted by #901 before Leg 1 is evaluated; Pester rows prove both.

### Leg 2: `Agent(pr-author)` (`enforce-model-routing-receipt.ps1`)

- [ ] AC-05: A checkpoint-free `Agent(pr-author)` delegation whose prompt has exactly one `branch:` and one `base:` label, with a valid allowance file, the label branch matching one allowance, and a non-empty `origin/<base>...HEAD` diff entirely in that allowance's `allowed_paths`, is allowed by `enforce-model-routing-receipt.ps1`.
- [ ] AC-06: Each `RELEASE_DELEGATION_*` code (`CONFIG_INVALID`, `LABEL_INVALID`, `BRANCH_NOT_MATCHED`, `DIFF_UNREADABLE`, `DIFF_EMPTY`, `PATH_NOT_ALLOWED`) keeps the `MODEL_ROUTING_RECEIPT_BLOCKED` deny, and the suffix ` Release delegation leg not applied: <CODE>` is appended after `$docsSuffix`; a Pester row exists for each code and one asserts the suffix order.

### Leg 3: receipt Write (`enforce-orchestration-preimplementation-gate.ps1`)

- [ ] AC-07: A checkpoint-free Write of `artifacts/pr_body_<N>.receipt.json` beneath R, with a valid allowance file and the head branch of R matching one allowance, is allowed by `enforce-orchestration-preimplementation-gate.ps1`.
- [ ] AC-08: Each `RELEASE_RECEIPT_*` code (`CONFIG_INVALID`, `CHECKPOINT_PRESENT`, `BRANCH_NOT_MATCHED`) keeps the `PREIMPLEMENTATION_GATE_BLOCKED` deny with the suffix ` Release receipt leg not applied: <CODE>`; a Write to any other path (including a non-numeric `<N>` and a path outside `artifacts/` beneath R) declines with an empty suffix; a Pester row exists for each case.
- [ ] AC-09: In each Claude copy of `enforce-orchestration-preimplementation-gate.ps1`, `Get-OrchestrationReleaseAllowanceResult` occurs once, after `Get-OrchestrationParallelRecordsResult`, and the final deny line ends with `+ $release.DenySuffix)`; the Leg 3 suffix term immediately precedes it; the existing `hook-release-allowance-context.Parity.Tests.ps1` passes unchanged.

### Shared behavior

- [ ] AC-10: Without `.claude/release-commit-allowance.json`, the deny text of each of `enforce-pr-author-skill.ps1`, `enforce-model-routing-receipt.ps1`, and `enforce-orchestration-preimplementation-gate.ps1` is byte-identical to its text before this feature, and the leg performs no git call; a Pester row per gate asserts the exact string and zero git-seam invocations.
- [ ] AC-11: An unexpected error inside any leg is caught, the leg declines with an empty suffix, the gate's deny stands, and a `Write-Debug` record is written; a Pester row per leg proves it.
- [ ] AC-12: Every leg parses the allowance through `ConvertFrom-ReleaseAllowanceConfig`, matches branches through `Test-ReleaseAllowanceBranchMatch`, and reads the file through `Get-OrchestrationGateReleaseAllowanceConfigText` and `Test-OrchestrationGateReleaseAllowancePathIsContainer`; no new file defines a JSON parser, schema check, or wildcard branch matcher for the allowance; `hook-release-allowance-context.ps1` and `enforce-orchestration-preimplementation-gate-release.ps1` are unchanged in every copy; the allowance schema is unchanged.
- [ ] AC-13: No new or changed hook file invokes Python; `enforcement-hooks-no-python-invocation.Tests.ps1` passes.
- [ ] AC-14: No `.codex/` file and no Codex bundle copy is changed.

### Mirrors, manifests, and documentation

- [ ] AC-15: Every new and changed `.claude/hooks/` file is byte-identical to its copy under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`; `pack-manifests/core.json` lists each new hook file; `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, and `hook-dependency-guard-completeness.Tests.ps1` pass.
- [ ] AC-16: No `.claude/release-commit-allowance.json` exists in the repository, the bundles, or any pack manifest.
- [ ] AC-17: `.claude/rules/orchestrator-state.md`, `.claude/skills/execution-environment/SKILL.md`, `.claude/skills/pr-author/SKILL.md`, and `.claude/agents/pr-author.md` describe the release pull-request legs and their sub-code families, and each change is made in its source (`scripts/harness-generation/sources/rules/orchestrator-state.md`, `.agents/skills/execution-environment/SKILL.md`, `.agents/skills/pr-author/SKILL.md`, `scripts/harness-generation/sources/agents/pr-author.json`) and produced by `scripts/harness-generation/Invoke-HarnessGeneration.ps1`; `Invoke-HarnessGeneration.ps1 -Check` reports no drift, `HarnessGeneration.RepoGate.Tests.ps1` passes, every execution-environment brief copy stays byte-identical (`test_brief_copies_are_byte_identical`), and `pr-author-docs-estate-delegation-contract.Tests.ps1` passes unchanged.
- [ ] AC-18: The orchestrator-state rule retains the token `destination-owned` and the statement that the #1201 command leg never applies to Write, Edit, or delegation calls, and adds the policy-level-control disclosure of this spec.

### Size, tests, and toolchain

- [ ] AC-19: Each new hook file is below 500 logical lines; no changed file exceeds 800 logical lines; `enforce-pr-author-skill-helpers.ps1` and `hook-release-allowance-context.ps1` are not edited; sizes are measured with `@(Get-Content -LiteralPath <path>).Count` before and after and recorded as evidence.
- [ ] AC-20: New Pester suites under `tests/scripts/claude-hooks/` (`hook-release-pull-request-context.Tests.ps1`, `enforce-pr-author-skill.Release.Tests.ps1`, `enforce-model-routing-receipt.Release.Tests.ps1`, `enforce-orchestration-preimplementation-gate-release-receipt.Tests.ps1`, `release-pull-request.Parity.Tests.ps1`) cover every allow row and code row above, use synthetic `/synthetic-worktrees/...` roots and mocked seams, create no temporary files, and pass the PoshQC leak scan.
- [ ] AC-21: Each new hook file reaches at least 85% line coverage in the Pester coverage run, read from `artifacts/pester/powershell-coverage.xml`.
- [ ] AC-22: Existing suites that mock `Test-Path` or count git-seam calls on these gates (including `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`, `.EpicFanIn.Tests.ps1`, `-bookkeeping.Tests.ps1`, `-release.Tests.ps1`, and the pr-author suites asserting `Invoke-PrAuthorDocsOnlyGitExe` counts) pass, and each one's disposition is recorded in the plan.
- [ ] AC-23: The PowerShell toolchain loop (format, lint, tests, contract checks) completes in one clean pass, with evidence written under `.dev/active/1231-pr-author-release-exemption/evidence/<kind>/`.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests
- [ ] Behavior matches acceptance criteria
- [ ] Tests added (unit and decision-level Pester rows)
- [ ] Edge cases and error handling covered by tests
- [ ] Generated docs updated through their sources and the generator
- [ ] `Write-Debug` records on caught errors
- [ ] Toolchain pass completed (format, lint, test, contract checks)

## Seeded Test Conditions (from potential)

- [ ] Unit coverage of the release exemption predicate with injected git and file seams
- [ ] Integration through `Get-PrAuthorBypassReason` with a stubbed checkpoint preflight
- [ ] Byte-identity of mirrors and pack-manifest listing

## Numeric Assertion Note

The research reports that three gates deny the checkpoint-free release case. That count is not stated as an acceptance criterion: the cross-check derivation narrowed its search to hook files containing `pr-author`, which does not cover the complete family of registered Bash, Write, and Agent hooks, so the derivation does not meet the exhaustive-scope requirement. The acceptance criteria instead name each gate this feature changes, without asserting that no other gate applies.
