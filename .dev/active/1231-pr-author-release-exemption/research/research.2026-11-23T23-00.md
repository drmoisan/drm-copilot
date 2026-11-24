# Research: Checkpoint-Free Release Pull Request (Issue #1231)

- Issue: #1231
- Branch: feature/pr-author-release-exemption-1231
- Feature folder: .dev/active/1231-pr-author-release-exemption/
- Sources read: `issue.md`, `spec.md` (Draft 0.1), the hooks and tests cited below, `config/harness-parity-matrix.json`, `.claude/hooks/pretooluse-dispatch.json`, `.codex/hooks/pretooluse-dispatch.json`, `.claude/rules/orchestrator-state.md`, and the `execution-environment` brief.
- Tool limits: this researcher has no Bash, so no `git`, `gh`, or Pester run was made. Line counts are read from the Read tool numbering; the plan must re-measure them with `@(Get-Content -LiteralPath <path>).Count` before relying on them.

## 1. Current State: Gates on the Checkpoint-Free Release PR Path

The end-to-end sequence an agent runs after the #1201 commit is: `mcp__drm-copilot__collect_pr_context`, `git push`, `Agent(pr-author)`, then inside pr-author a Write of `artifacts/pr_body_<N>.md`, `sha256sum`, `date -u`, a Write of `artifacts/pr_body_<N>.receipt.json`, `gh pr create --head <b> --base <base> --body-file ...`, and `gh pr view <N> --json closingIssuesReferences,body`.

| Step | Gate(s) evaluated | Denies without a checkpoint? | Existing checkpoint-free legs |
|---|---|---|---|
| `collect_pr_context` (MCP) | `enforce-discovery-artifact-gate.ps1` (`mcp__.*` group) and `enforce-owner-directive-pass-down.ps1` (`mcp__.*` group) | No. The discovery gate allows every call of a non-discovery agent and every non-discovery root call (header of `.claude/hooks/enforce-discovery-artifact-gate.ps1`). The pass-down hook emits nothing with no ledger and no `owner_directives`. `extensions/drm-copilot/src/lib/pr-context/` reads no checkpoint (grep for `checkpoint`/`orchestrator-state` returns no file). | Not needed. |
| `git push` | Bash group: `validate-bash.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-epic-merge-gate.ps1`, `enforce-docs-complete-gate.ps1`, removal gates, `enforce-test-execution-policy.ps1` | No. `Test-ImplementationCommand` (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`) classifies only `git add`/`git commit`, the Python runners, the npm/npx toolchain words, and Pester; `validate-bash.ps1` denies only forced pushes. | Not needed. |
| `Agent(pr-author)` | Agent group: `enforce-prd-feature-before-planner.ps1` (acts only on `atomic-planner`), `enforce-discovery-planning-gate.ps1` (planner/orchestrator launches only), `enforce-orchestration-preimplementation-gate.ps1` (`Test-ImplementationDelegation`: pr-author is not in `$script:OrchestrationImplementationAgentAllowList` of `enforce-orchestration-preimplementation-gate-modes.ps1`, so it is not classified), `enforce-epic-wave-barrier.ps1` and `enforce-parallel-cohort-barrier.ps1` (orchestrator only), `enforce-epic-invocation-origin.ps1` (epic/parallel planners and orchestrators only), `enforce-parallel-drift-gate.ps1` (parallel-mode marker only), `enforce-model-routing-receipt.ps1`, and `enforce-owner-directive-pass-down.ps1` | **Yes: `enforce-model-routing-receipt.ps1`.** `Invoke-ModelRoutingReceiptDecision` resolves the item by the prompt `branch:` label (`Resolve-WorktreeItemTargetByBranch` in `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` resolves a branch-only prompt to the live worktree that has it checked out), reads `$checkpoint = $null`, and denies with `MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry ...` + `$parallelSuffix` + `$docsSuffix`. | Cleanup (#1026) `Test-ModelRoutingCleanupDelegation`; parallel records (#1182) `Get-ModelRoutingParallelRecordsDecision` (`enforce-model-routing-receipt-parallel.ps1`); docs-estate (#1169) `Get-ModelRoutingDocsEstateDecision` (`enforce-model-routing-receipt-docs.ps1`). All dispatched inside `Invoke-ModelRoutingReceiptDecision` after the receipt check fails, only for `pr-author` with a null checkpoint. |
| Write `artifacts/pr_body_<N>.md` | Write group, including the preimplementation gate | No. `Test-ImplementationPath` matches only `\.(py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml)$`; `.md` is not classified. | Not needed. |
| Write `artifacts/pr_body_<N>.receipt.json` | Write group: preimplementation gate, batch budgets (ignore root `artifacts/`), evidence locations (path is not a forbidden `artifacts/` sub-path), file-size, feature-folder order, checkpoint monotonic, completion consistency, mermaid, docs-role write scope (docs roles only) | **Yes: `enforce-orchestration-preimplementation-gate.ps1`.** `.json` is classified; with no ready checkpoint the final deny `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require ...` is returned. `Get-OrchestrationReleaseAllowanceResult` (#1201) declines a Write (blank `$Command`, step 1) with an empty suffix. | Cleanup (#1026) `Get-OrchestrationCleanupContextResult`; docs-estate (#1169) `Get-OrchestrationDocsEstateContextResult` (receipt Write needs D1+D2 only); parallel records (#1182) `Get-OrchestrationParallelRecordsResult`. Dispatched on lines 437-441 of the gate in that order, suffixes concatenated on line 442. |
| `sha256sum`, `date -u`, `gh pr view` | pr-author frontmatter `enforce-pr-author-command-allowlist.ps1`; Bash group | No. The allowlist admits these exact forms and reads no checkpoint. | Not needed. |
| `gh pr create --body-file` | `enforce-pr-author-skill.ps1` (Bash group) and `enforce-pr-author-command-allowlist.ps1` (agent frontmatter) | **Yes: `enforce-pr-author-skill.ps1`.** `Get-PrAuthorBypassReason` (`enforce-pr-author-skill-helpers.ps1`) runs `Invoke-OrchestratorStatePreflight` in the non-epic branch; on errors it calls `Get-PrAuthorPreflightExemption` and denies `ORCHESTRATOR_STATE_PREFLIGHT_FAILED: <summary> (docs-only exemption not applied: <reason>)`. The command allowlist admits `gh pr create` without a checkpoint. | Docs-only (#901) `Get-PrAuthorDocsOnlyExemption` (`enforce-pr-author-skill.docs-only.ps1`, E1-E7); cleanup (#1026) inside `Get-PrAuthorPreflightExemption` (`enforce-pr-author-skill.cleanup.ps1`, K1-K6), which appends `; cleanup exemption not applied: <code>` inside the parentheses. No docs-estate or parallel leg exists in this gate. |
| SubagentStop of pr-author | `validate-pr-author-output.ps1` | No. It reads no checkpoint (grep for `checkpoint` returns nothing); it requires a PR URL or number in the final output. | Not needed. |

Conclusion: exactly three gates deny a checkpoint-free release PR: the pr-author skill gate (`gh pr create`), the Claude model-routing gate (`Agent(pr-author)`), and the Claude preimplementation gate (receipt Write). See `## Numeric Derivation Evidence`.

Out-of-scope finding: merging the release PR is still gated. `Invoke-EpicMergeGateDecision` in `.claude/hooks/enforce-epic-merge-gate.ps1` allows a checkpoint-free merge only through the docs-only branch (`Get-DocsOnlyMergeExemption`, M1-M9, every path under `docs/`), so a release diff stays denied with `EPIC_MERGE_GATE_BLOCKED`. Issue #1231 covers opening the PR only; this is recorded under Risks.

### Key abstractions and constraints verified

- `ConvertFrom-ReleaseAllowanceConfig` and `Test-ReleaseAllowanceBranchMatch` (`hook-release-allowance-context.ps1`) call only same-file helpers, `ConvertFrom-Json`, and `WildcardPattern`; they have no call-time dependency on the preimplementation-gate helpers. The other functions of that file (`Test-ReleaseAllowanceCommandRelevant`, `Get-ReleaseAllowanceCommandDecision`, `Get-ReleaseAllowanceGlobalOptionFailure`) depend on `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `ConvertTo-OrchestrationCleanupComparablePath`, and `Test-CommandLineTokenLiteral`, which are not loaded in the pr-author or model-routing hooks; the new legs must not call them.
- `enforce-orchestration-preimplementation-gate-release.ps1` holds the two I/O seams `Get-OrchestrationGateReleaseAllowanceConfigText` (returns `$null` when absent, throws when not a file or unreadable) and `Test-OrchestrationGateReleaseAllowancePathIsContainer`, plus `$script:ReleaseAllowanceFileRelativePath = '.claude/release-commit-allowance.json'`. Its top level only dot-sources the context file (guarded) and assigns that variable. Its `$BranchReader`/`$StagedIndexReader` defaults reference preimplementation functions only when invoked.
- `hook-release-allowance-context.ps1` is about 495 lines and the parity test `hook-release-allowance-context.Parity.Tests.ps1` (AC-22 row) requires each of the four copies to stay below 500 lines. No predicate can be added to it.
- PreToolUse dispatcher: `isolation: in-process` runs each hook script in its own script scope in one process (`HookDispatchRunner.psm1` header); imported modules are process-wide, dot-sourced functions and `$script:` variables are per hook. A new file's script-scope names still need a unique prefix (the #1201 parity test enforces `ReleaseAllowance` for its two files).
- AC-21 row of `hook-release-allowance-context.Parity.Tests.ps1`: in each gate copy, exactly one occurrence of `Get-OrchestrationReleaseAllowanceResult`, called after the `LastLeg` (`Get-OrchestrationParallelRecordsResult` on Claude), and the final deny line must end with `+ $release.DenySuffix)`.
- `Invoke-PrAuthorDocsOnlyGitExe` (pr-author seam, unbounded `git @args`) and `Invoke-DocsOnlyGitExe` (`hook-docs-only-diff.ps1`, bounded 3000 ms) never throw. `Get-ModelRoutingDocsEstateCommit` resolves a ref through the bounded seam.
- `Get-DocsEstateDelegationLabel` (`hook-docs-estate-context.ps1`) returns `Branch` and `Base` only when the prompt has exactly one `branch:` and one `base:` label (counted case-insensitively at a word boundary) with conservative spellings.
- `Get-PrAuthorDocsOnlyBaseName` returns the single `--base` only when no `-B`/`-R`-bearing short cluster, `--repo`, `--repo=`, or `GH_REPO=` token exists; `Get-PrAuthorCleanupSegmentToken` returns the matched segment tokens; the cleanup K3 test for `--head` (exactly one `--head`, no `--head=`, no single-dash token containing `H`) is reusable in shape.

## 2. Candidate Approaches

**A. Separate Claude-only legs, one per denying gate, sharing a new pure predicate file (recommended).** New files:
1. `.claude/hooks/hook-release-pull-request-context.ps1`: pure, no dot-source, no I/O; script-scope prefix `ReleasePullRequest`. Functions: `Get-ReleasePullRequestConfigState -WorktreeRoot -ConfigReader -ContainerProbe` (calls the injected seams, then `ConvertFrom-ReleaseAllowanceConfig`, then the container probe per `allowed_paths` entry exactly as #1201 steps 4-5; returns `State` `Absent|Invalid|Valid`, `Allowances`, `Detail`) and `Get-ReleasePullRequestPathDecision -Allowances -Branch -Path` (candidates by `Test-ReleaseAllowanceBranchMatch` in file order; empty path list, branch not matched, and the first candidate's first unlisted path as failures; the first candidate that lists every path wins; ordinal case-sensitive `-ccontains`). Call-time dependencies: `ConvertFrom-ReleaseAllowanceConfig`, `Test-ReleaseAllowanceBranchMatch`.
2. `.claude/hooks/enforce-pr-author-skill.release.ps1`: the gh pr create leg; dot-sources (guarded) `enforce-orchestration-preimplementation-gate-release.ps1` (parser plus the two seams) and `hook-release-pull-request-context.ps1`.
3. `.claude/hooks/enforce-model-routing-receipt-release.ps1`: the delegation leg; same two guarded dot-sources.
4. `.claude/hooks/enforce-orchestration-preimplementation-gate-release-receipt.ps1`: the receipt Write leg; dot-sources only the pure file (the gate already loads the #1201 release sibling).

Advantages: no edit to any of the four-copy byte-identical #1201 files and no Codex edit; the #1201 AC-21 contract (single release call, release suffix last) stays true; each gate keeps its own sub-code family like cleanup, docs-estate, and parallel records; parser and seams are reused, not reimplemented. Limitations: four new production files plus wiring edits (about 14 production files with bundle copies), which is the orchestrated large route under the batch budget.

**Rejected alternatives.**
- B. Extend `Get-OrchestrationReleaseAllowanceResult` with `-FilePath` and add the PR predicates to the #1201 files: edits four byte-identical copies on both surfaces, widens a Bash-only leg that `.claude/rules/orchestrator-state.md` documents as never applying to Write, Edit, or delegation calls, and the context file has no line headroom under the AC-22 500-line bound.
- C. Generalize the cleanup composite (`Get-PrAuthorPreflightExemption`) into a table of exemptions: larger refactor of #901/#1026 code paths with no requirement driving it.

## 3. Behavior Semantics and Design per Gate

General rule for every leg: the allowance file beneath the resolved root R is read first through `Get-OrchestrationGateReleaseAllowanceConfigText`; an absent file declines with an empty suffix and no git or further I/O, so every deny text without the file is byte-identical. A read throw or parse/container failure yields `*_CONFIG_INVALID`. Each leg is wrapped in `try/catch` and answers declined with an empty suffix on an unexpected error, with a `Write-Debug` record, following `Get-OrchestrationReleaseAllowanceResult`.

### 3.1 `enforce-pr-author-skill.ps1` leg (`Get-PrAuthorReleaseExemption`)

Inputs: `CommandText`, `WorktreeRoot` (= `$artifact.ArtifactRoot`), `CheckpointPath`. Returns `Exempt` and `Reason` (`$null` when the allowance file is absent).

Order (first failure wins; codes use the cleanup naming family):
1. R blank or file absent: `Exempt $false`, `Reason $null`.
2. `RELEASE_EXEMPTION_CONFIG_INVALID` - read throw, `ConvertFrom-ReleaseAllowanceConfig` invalid (its `Detail`), or an `allowed_paths` entry is a directory.
3. `RELEASE_EXEMPTION_NOT_CREATE` - not a structural `gh pr create` (covers `gh pr edit`).
4. `RELEASE_EXEMPTION_CHECKPOINT_PRESENT` - `Test-PrAuthorDocsOnlyCheckpointPresence` is true.
5. `RELEASE_EXEMPTION_HEAD_UNRESOLVED` - not exactly one `--head` token, a `--head=` token, a single-dash token containing `H`, a missing value, or a value outside `^[A-Za-z0-9][A-Za-z0-9._/-]*$` or holding `..` (rejects `owner:branch`, which a `*` pattern would otherwise match).
6. `RELEASE_EXEMPTION_BASE_UNRESOLVED` - `Get-PrAuthorDocsOnlyBaseName` returns `$null` (also rejects `-R`, `--repo`, `GH_REPO=`).
7. `RELEASE_EXEMPTION_BRANCH_NOT_MATCHED` - the `--head` value matches no `branch_patterns` entry.
8. `RELEASE_EXEMPTION_REMOTE_HEAD_MISMATCH` - new seam `Get-PrAuthorReleasePublishedHead -WorktreeRoot -Branch` (the `Get-PrAuthorCleanupPublishedHead` shape with the branch as a parameter) shows `refs/remotes/origin/<head>` unresolved, or different from `HEAD`.
9. `RELEASE_EXEMPTION_DIFF_FAILED` - `refs/remotes/origin/<base>^{commit}` does not resolve, or `git diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <commit>...HEAD` fails or returns non-empty output not ending in NUL (the cleanup leg's exact argument list).
10. `RELEASE_EXEMPTION_EMPTY_DIFF` - no path.
11. `RELEASE_EXEMPTION_PATH_NOT_ALLOWED` - no single allowance whose pattern matches the head lists every diff path (`Get-ReleasePullRequestPathDecision`).

Wiring: `Get-PrAuthorPreflightExemption` in `enforce-pr-author-skill.cleanup.ps1` keeps its docs-only and cleanup result; when that result is not exempt it calls `Get-PrAuthorReleaseExemption`; exempt returns `[ordered]@{ Exempt = $true; Reason = $null }`; a non-null release reason appends `; release exemption not applied: <CODE>: <detail>` to the existing reason, so it lands after the docs-only and (when present) cleanup reasons inside the parentheses of `ORCHESTRATOR_STATE_PREFLIGHT_FAILED: ... (docs-only exemption not applied: ...)`. `enforce-pr-author-skill.cleanup.ps1` dot-sources the release sibling with the guarded single-statement form. `enforce-pr-author-skill-helpers.ps1` (at its 500-line guidance tier) is not edited; only header/doc text of `enforce-pr-author-skill.ps1` changes. The receipt checks 1-6 of `Test-PrAuthorReceiptVerification` run unchanged after an exemption. The leg is reachable only in the non-epic branch of `Get-PrAuthorBypassReason`, so epic scope is unaffected.

### 3.2 Model-routing leg (`Get-ModelRoutingReleaseDecision`)

Called in `Invoke-ModelRoutingReceiptDecision` inside the existing `if ($subagent -eq 'pr-author' -and $null -eq $checkpoint)` block after the docs-estate leg; its `DenySuffix` is appended after `$docsSuffix`. Prefix ` Release delegation leg not applied: `. Order: R blank or file absent (empty suffix); `RELEASE_DELEGATION_CONFIG_INVALID`; `RELEASE_DELEGATION_LABEL_INVALID` (`Get-DocsEstateDelegationLabel` returns `$null`); `RELEASE_DELEGATION_BRANCH_NOT_MATCHED` (label branch); `RELEASE_DELEGATION_DIFF_UNREADABLE` (`Get-ModelRoutingDocsEstateCommit` for `refs/remotes/origin/<base>` or `HEAD`, or the bounded diff fails); `RELEASE_DELEGATION_DIFF_EMPTY`; `RELEASE_DELEGATION_PATH_NOT_ALLOWED`. R is `$resolution.WorktreeRoot`, the worktree that has the label branch checked out, so the label branch is R's branch. The remote-head comparison is not repeated at delegation (the docs-estate and cleanup delegation legs do not check it either); the gh pr create leg enforces it. The author-asserted autoclose rule applies only when a checkpoint with `issue-num` exists, so it does not apply here.

### 3.3 Preimplementation receipt Write leg (`Get-OrchestrationReleaseReceiptResult`)

Called on a new line between the parallel-records call and the #1201 release call; its suffix is inserted before `$release.DenySuffix`, so the #1201 suffix remains the last term (AC-21 holds). Prefix ` Release receipt leg not applied: `. Order: `FilePath` blank or not matching `(^|/)artifacts/pr_body_[0-9]+\.receipt\.json$` (decline, empty); R from `Get-OrchestrationGateBookkeepingWorktreeRoot -CheckpointPath $checkpointPath -CheckpointSuffix $script:CheckpointPaths[0]` (null declines); an absolute path whose remainder beneath R (`Get-HookTargetWorktreeRelativePath`) is not exactly `artifacts/pr_body_<digits>.receipt.json` declines; file absent declines; `RELEASE_RECEIPT_CONFIG_INVALID`; `RELEASE_RECEIPT_CHECKPOINT_PRESENT` (`Test-OrchestrationDocsEstateCheckpointPresent`, all seven checkpoint names); `RELEASE_RECEIPT_BRANCH_NOT_MATCHED` (`Get-EpicScopeWorktreeHeadBranch` of R is detached, unreadable, or matches no pattern). No diff check, matching the docs-estate receipt rule (D1+D2 only); the diff is enforced at delegation and at gh pr create. The gate's epic-scope decision still runs first. The Codex gate is not changed, because the Codex pr-author (`.codex/agents/pr-author.toml`) writes no receipt and runs no `gh pr create`.

### 3.4 Success and failure conditions

- Success: a structural `gh pr create --head <b> --base <base> --body-file artifacts/pr_body_<N>.md` (or the absolute coordinator form) with no checkpoint beneath R, a valid allowance file, `<b>` matching one allowance, `origin/<b>` equal to HEAD, and a non-empty `origin/<base>...HEAD` diff entirely in that allowance's `allowed_paths`, followed by passing receipt checks.
- Ordering: absent file before any git call; config validity before command shape; the cleanup composite result before the release leg.
- Edge cases: renames list both paths (`--no-renames`); deletions are listed and must be allowed; a stale local `origin/<base>` widens the three-dot diff and denies (fail closed); `--head owner:branch` denies at step 5.

## 4. Requirements Mapping and File Changes

| Draft AC | Design element |
|---|---|
| Release create passes preflight, receipt checks still run | 3.1 steps 1-11, wiring after docs-only/cleanup |
| Distinct sub-codes for each failure, appended after existing reasons | 3.1 codes; suffix `; release exemption not applied:` |
| Byte-identical text without allowance file | Absent-file decline with `$null` reason in all three legs |
| Every other gate admits the same case | 3.2 and 3.3 |
| Parser reused | `ConvertFrom-ReleaseAllowanceConfig`, `Test-ReleaseAllowanceBranchMatch`, and the two #1201 seams reused via guarded dot-source |
| Mirrors, manifests, brief, rule | Section 5 |
| Pester coverage, no Python | Section 6 |

Production files (Claude source plus `extensions/drm-copilot/resources/claude-customizations/` copy each):

| File | Change | Current size (Read numbering) |
|---|---|---|
| `.claude/hooks/hook-release-pull-request-context.ps1` | new | - |
| `.claude/hooks/enforce-pr-author-skill.release.ps1` | new | - |
| `.claude/hooks/enforce-model-routing-receipt-release.ps1` | new | - |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-release-receipt.ps1` | new | - |
| `.claude/hooks/enforce-pr-author-skill.cleanup.ps1` | guarded dot-source, composite wiring, header | 246 |
| `.claude/hooks/enforce-pr-author-skill.ps1` | header text only | 359 |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | guarded dot-source, call, suffix, header | 425 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | guarded dot-source, one call line, deny-line suffix | 499 (reaches about 501; guidance tier only; no test pins this file below 500, verified by grep of the parity suites) |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | list the four new hook paths | - |

Not touched: `hook-release-allowance-context.ps1` (about 495), `enforce-orchestration-preimplementation-gate-release.ps1` (166), `enforce-pr-author-skill-helpers.ps1` (499), `enforce-pr-author-skill.docs-only.ps1` (225), `enforce-model-routing-receipt-docs.ps1` (238), all `.codex/` files.

## 5. Codex Surface, Mirrors, and Documentation

- Codex: `.codex/hooks/pretooluse-dispatch.json` has no pr-author skill gate and no receipt model-routing gate; `enforce-codex-model-routing.ps1` attests profiles, not checkpoint receipts. `config/harness-parity-matrix.json` records `claude:hook-registration:PreToolUse/Bash/enforce-pr-author-skill` as `native` with `GAP:DEFER` ("Codex PR authoring uses its own receipts") and `claude:hook-registration:PreToolUse/Agent/enforce-model-routing-receipt` as `native` (`hook:model-routing`). No Codex twin is required and the matrix needs no new row for hook scripts (it records registrations, which do not change). The #1201 parity test requires the Codex gate copies to remain byte-identical to their sources and the release call to follow `Get-OrchestrationDocsEstateContextResult`; leaving Codex unchanged satisfies it.
- Mirror and manifest contracts to run: `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` (every `$PSScriptRoot` dependency of a manifested file must be in core), `hook-dependency-guard-completeness.Tests.ps1` (guarded dot-source form), `enforcement-hooks-no-python-invocation.Tests.ps1`, and `hook-release-allowance-context.Parity.Tests.ps1` (AC-21, AC-24: the allowance file stays absent from repository, bundles, and manifests).
- Generated files (edit the source and run `scripts/harness-generation/Invoke-HarnessGeneration.ps1`; `HarnessGeneration.RepoGate.Tests.ps1` reports a hand edit as drift):
  - `.claude/rules/orchestrator-state.md` from `scripts/harness-generation/sources/rules/orchestrator-state.md` (matrix entry `claude:path-scoped-rule:orchestrator-state`). Add a paragraph to `## Release-Commit Allowance Scope` naming the three #1231 legs and their codes; keep the existing token `destination-owned` and the sentence that the #1201 command leg never applies to Write, Edit, or delegation calls (still true for that function).
  - `.claude/skills/execution-environment/SKILL.md` from `.agents/skills/execution-environment/SKILL.md`; add a `Release pull-request legs (#1231)` bullet to `## Hook Execution Context` and the new contract test names to `## Contract Tests That Pin Mirrored Files`, in all four byte-identical copies (`test_execution_environment_brief_contracts.py::test_brief_copies_are_byte_identical`).
  - `.claude/skills/pr-author/SKILL.md` from `.agents/skills/pr-author/SKILL.md`; add `## Checkpoint-Free Release Delegation (issue #1231)` parallel to the #1169 section (prompt lines `branch:` and `base:` once each; command form `gh pr create --head <branch> --base <base>`; preconditions). `pr-author-docs-estate-delegation-contract.Tests.ps1` pins the #1169 section in the four copies; the new section must not alter it.
  - `.claude/agents/pr-author.md` from `scripts/harness-generation/sources/agents/pr-author.json`; its Precondition paragraph states the hook "blocks ... when the checkpoint is missing", which is already inexact for #901/#1026; one sentence naming the checkpoint-free exemptions is recommended.
- Push-down never publishes the allowance file (`EXCLUDED_RELATIVE_PATHS` of both publishers, pinned by AC-25 and `claude-customizations-release-allowance.test.ts`); no change.

## 6. Testing Implications

Patterns to follow (no temporary files; synthetic roots; mocked seams):
- `tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1`: dot-sources the hook, registers `Register-EpicStateBaselineMock` from `EpicStateIsolation.Baseline.Helpers.ps1`, mocks `Resolve-PrAuthorWorktreeTarget`, `Invoke-OrchestratorStatePreflight`, `Invoke-PrAuthorDocsOnlyGitExe` (by `$GitArgs[0]`), the receipt seams, and the published-head seam, and asserts through `Invoke-PrAuthorSkillDecision`.
- `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` / `.Decision.Tests.ps1` for unit versus decision-level rows.
- `enforce-model-routing-receipt.DocsEstate.Tests.ps1` and `.ParallelRecords.Tests.ps1` for the delegation leg.
- `enforce-orchestration-preimplementation-gate-release.Tests.ps1` for seam rows (mocked `Test-Path`/`Get-Content` at `/synthetic-worktrees/release`) and injected scriptblock readers.
- `hook-release-allowance-context.Tests.ps1` for pure predicate rows.

Proposed new suites (mirroring `.claude/hooks` under `tests/scripts/claude-hooks/`): `hook-release-pull-request-context.Tests.ps1`, `enforce-pr-author-skill.Release.Tests.ps1` (one allow row with receipt checks exercised, one row per code, one byte-identical-text row per gate with the file absent, a `gh pr edit` row, a cleanup-context row showing both suffixes in order), `enforce-model-routing-receipt.Release.Tests.ps1`, `enforce-orchestration-preimplementation-gate-release-receipt.Tests.ps1`, and `release-pull-request.Parity.Tests.ps1` (bundle byte identity, core.json listing, `ReleasePullRequest` prefix, no Python, brief/rule/skill tokens, and the AC-21 property that `$release.DenySuffix` stays last). Each leg file stays below 500 lines and gets at least 85% line coverage in the Pester gate.

Existing suites to re-check because they mock `Test-Path` or count git calls: `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`, `.EpicFanIn.Tests.ps1`, `-bookkeeping.Tests.ps1`, `-release.Tests.ps1`, and any pr-author suite asserting `Should -Invoke Invoke-PrAuthorDocsOnlyGitExe -Times`. The absent-file decline performs no git call, so git counts are unchanged; a suite that mocks `Test-Path { $true }` globally and reaches a receipt Write could reach the config read. Preflight must search these suites and name each disposition.

## 7. Risks

- Remote head race: the leg compares the local `refs/remotes/origin/<head>` with `HEAD`; it never fetches. A push from another clone after the local push leaves the tracking ref stale, and `gh pr create` opens the PR at the true remote head, which may contain unchecked paths. Same residual as the cleanup K6 check and the #997 green-CI branch. Mitigation: document as a policy-level control; recommend `git push` immediately before `gh pr create`.
- Release branch with non-allowed files: denied with `RELEASE_EXEMPTION_PATH_NOT_ALLOWED` (and `RELEASE_DELEGATION_PATH_NOT_ALLOWED`). A branch that merged a newer `main` while the local `origin/<base>` is stale lists main's paths and denies; remedy `git fetch origin <base>`.
- `gh pr edit`: never exempt (`RELEASE_EXEMPTION_NOT_CREATE`), so editing a release PR body later needs a checkpoint, as for #901 and #1026.
- Epic scope: the pr-author leg runs only in the non-epic branch; the preimplementation and model-routing gates run their epic-scope decisions first, so a release branch equal to an epic `integration_branch` is governed by the epic checkpoint.
- Docs-only E-code interaction: E1 (`DOCS_ONLY_EXEMPTION_NOT_CREATE`) and E2 run before the release leg; the release reason is appended after the docs-only reason (and after `; cleanup exemption not applied:` when the head names the consolidation branch). No E-code text changes. A diff that is docs-only is exempted by #901 first and never reaches the release leg.
- Deny-text growth: with an allowance file committed, every failed preflight of that destination gains a release suffix (the draft AC requires codes for branch-not-matched and checkpoint-present). This is informational only.
- Merge of the release PR remains denied without a checkpoint (Section 1). Recorded for the owner; not in #1231 scope.
- Isolated subagents run `main`'s hook copies, so behavior is proven by Pester only.

## 8. Automation Feasibility

No human step is required to implement or verify the change: every leg is pure PowerShell with injectable seams, verified by Pester suites, the harness generator check, and the push-down contract tests, all runnable by the executor through the test-execution launcher and the `sh` route. The batch budget requires the orchestrated large route (about 14 production files including bundle copies). A live end-to-end release in a destination repository (commit an allowance file, push, open the PR) is optional confirmation and is not required by any draft AC. Merging a checkpoint-free release PR still requires an owner action or a checkpoint path; that is outside this issue.

## Numeric Derivation Evidence

Claim: three gates deny a checkpoint-free release pull request on the creation path (used in Section 1 and in the design scope; not yet an approved `spec.md` AC).

- Complete Family: every PreToolUse hook registered in `.claude/hooks/pretooluse-dispatch.json` whose group matcher admits `Bash`, `Write`, `Agent`, or `mcp__drm-copilot__collect_pr_context`, plus the hooks in the frontmatter of `.claude/agents/pr-author.md` and the SubagentStop hook for pr-author.
- Exhaustive Search Scope: all seven groups of `.claude/hooks/pretooluse-dispatch.json`; `.claude/agents/pr-author.md` frontmatter; `.claude/settings.json` SubagentStop entry for `validate-pr-author-output.ps1`.
- Inclusion Rules: a hook is counted when, for one step of the sequence in Section 1, it returns deny when no orchestration checkpoint exists beneath the resolved root and no existing leg applies.
- Exclusion Rules: hooks that act only on other subagent types or only on merges, removals, test runners, or discovery agents; hooks that emit nothing without owner-directive sources.
- Primary Search Strategy or Query Expression: walk the registry groups in order and read each hook's decision entry point for the release step it sees.
- Primary Member Set: `enforce-pr-author-skill.ps1` (gh pr create), `enforce-model-routing-receipt.ps1` (Agent pr-author), `enforce-orchestration-preimplementation-gate.ps1` (receipt `.json` Write).
- Primary Count: 3.
- Cross-check Search Strategy or Query Expression: Grep `pr-author` over `.claude/hooks` (23 files), keep only files registered as a hook entry point (exclude dot-sourced siblings, shared context files, and the registry JSON), then keep those that read an orchestration checkpoint and deny on a creation-path step.
- Cross-check Member Set: registered entry points found: `enforce-pr-author-skill.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-model-routing-receipt.ps1`, `enforce-epic-merge-gate.ps1` (merge only, excluded), `enforce-pr-author-command-allowlist.ps1` (no checkpoint read, excluded), `validate-pr-author-output.ps1` (no checkpoint read, excluded). Remaining: `enforce-pr-author-skill.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-model-routing-receipt.ps1`.
- Cross-check Count: 3.
- Member-set Comparison: the normalized primary set {enforce-model-routing-receipt.ps1, enforce-orchestration-preimplementation-gate.ps1, enforce-pr-author-skill.ps1} equals the normalized cross-check set. Agreement.

## Pre-Mortem

- Review checklists: a reviewer could flag an edit of a generated rule, skill, or agent file by hand, or a deny text change without an allowance file. Mitigation: the plan edits only the sources (`scripts/harness-generation/sources/rules/orchestrator-state.md`, `.agents/skills/pr-author/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `scripts/harness-generation/sources/agents/pr-author.json`) and runs the generator; byte-identical-text rows exist for each of the three gates.
- Coverage: the four new PowerShell files must each reach 85% line coverage in the single Pester gate run; catch paths and seam-throw paths need explicit rows. Mitigation: one row per code and per seam failure, read from `artifacts/pester/powershell-coverage.xml`.
- Mirror parity: every new and changed hook file must be copied byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` and listed in that bundle's `pack-manifests/core.json`; the brief changes in four copies; the #1201 AC-21 property (single release call, release suffix last) must hold in both Claude gate copies. Mitigation: a brief-update task and a parity suite are part of the plan, and the plan's Mirror parity bullet names them.
- File size: `enforce-orchestration-preimplementation-gate.ps1` moves from about 499 to about 501 lines (guidance tier; no gate fails below 801); each new file stays below 500. Mitigation: measure with `@(Get-Content -LiteralPath <path>).Count` before and after; do not add logic to `enforce-pr-author-skill-helpers.ps1` or `hook-release-allowance-context.ps1`.
- Test isolation: suites must use synthetic roots and mocked seams, no temporary files, and register the epic-state baseline mocks; `Invoke-PoshQCLeakScan` fails on unpaired global state. Mitigation: follow `enforce-pr-author-skill.Cleanup.Tests.ps1` and run the leak scan through the launcher.
- CI-only behavior: the Linux hook-suite job runs `tests/scripts/claude-hooks` on a case-sensitive file system with no drive letters; a fixture path such as `C:/...` or a backslash literal fails there. Mitigation: use `/synthetic-worktrees/...` roots and forward slashes, and no test reads `origin/main` or gitignored `artifacts/` state.
- Evidence: gate results must be written under `.dev/active/1231-pr-author-release-exemption/evidence/<kind>/` with UTC write-time stamps, append-only; PoshQC MCP results carry no counts, so counts come from `artifacts/pester/pester-junit.xml` and the coverage XML of a launcher run. Mitigation: the plan names the launcher commands and evidence file shapes.
