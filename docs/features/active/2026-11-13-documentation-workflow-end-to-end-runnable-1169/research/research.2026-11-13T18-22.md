# Research: documentation-workflow end-to-end runnable, Part A (Issue #1169)

- Issue: #1169
- Scope: Part A items A1 to A5 of `issue.md` in this feature folder. Part B (B1 to B13) is tracked in #1173 and is out of scope; it is named below only where it touches a Part A file.
- Environment facts: `.claude/skills/execution-environment/SKILL.md` (referenced, not restated).
- Timestamp source: the task-researcher agent has no shell, so the filename stamp was read from a network UTC clock (`timeapi.io`, current UTC zone) immediately before the write, not composed.
- Method: every finding below was verified by reading the named file in the item worktree with Read or Grep. Nothing was executed. Facts that need `git show`, `git log`, or `gh` are listed under `## Facts for the Orchestrator to Confirm`.

## Summary of Findings

1. A1 is confirmed. A checkpoint-free `git add` or `git commit` reaches the final deny of `Invoke-OrchestrationPreimplementationGateDecision`; the only allow legs on that path are the issue #539 bookkeeping exemption and the issue #1026 cleanup legs. A second gap the issue does not name: the pr-author receipt `artifacts/pr_body_<N>.receipt.json` ends in `.json`, so `Test-ImplementationPath` classifies its Write as implementation, and outside the cleanup consolidation worktree no leg admits it. A checkpoint-free docs PR therefore also fails at the receipt Write, inside the pr-author agent.
2. A2 is confirmed. The model-routing gate admits a checkpoint-free `Agent(pr-author)` only through `Test-ModelRoutingCleanupDelegation`. `AUTHOR_ASSERTED_AUTOCLOSE_MISSING` cannot fire on a checkpoint-free path, because `Get-ModelRoutingAuthorAssertedReason` runs only after a receipt was found in a non-null checkpoint. PR creation itself already has a checkpoint-free route (the E1 to E7 docs-only exemption) and needs no new leg. It fails today only because of A3.
3. A3 is confirmed. `Get-DocsOnlyPathViolation` in `.claude/hooks/hook-docs-only-diff.ps1` is the single classifier behind both E7 and M9, and it admits only `docs/` paths. `Get-DocsInitTemplate` in `.claude/lib/docs/DocsProfileCommands.psm1` writes five configuration files and one workflow outside `docs/`. No code in `.claude/lib/docs/` or in `_docs-quality.yml` reads the Vale or markdownlint files. They are optional data for external linters (`docs/engineering/documentation-estate/consumer-onboarding.md`, `## Linting`), so the "`--config` paths in `_docs-quality.yml`" part of the preferred option has no step to attach to.
4. A4 is confirmed, with one refinement. `Invoke-DocsValidation` requires the validated `-Revision` to equal the snapshot `revision` (`DOCS_REVISION_MISMATCH`), the receipt records that revision, and `Test-DocsCompleteGateReceipt` requires the receipt revision to equal the pull request `headRefOid`. For a committed snapshot the gate is unsatisfiable: the commit that holds the snapshot cannot be the revision the snapshot names. Because the gate reads the receipt from the working tree of the head-branch worktree, it can be satisfied by one route only: regenerate the snapshot at the head, leave it uncommitted, and validate there (what the consumer CI template does). The gate applies only to an `epic/*-integration` head merging into `main` (`Test-DocsCompleteGateIntegrationTarget`), so a standalone docs PR is never gated by it.
5. A5 is confirmed. `.claude/skills/documentation-workflow/SKILL.md` ends at `## Rules` after the seven-step `## Dispatch Order` and has no commit, receipt, push, or PR stage.

## Current State Analysis

### A1: preimplementation gate (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`)

- Detection: `Test-ImplementationCommand` holds the five-entry `$implementationCommandPatterns` array. Index 0 is `git (add|commit)`. `$isStaging` is the structural test `Test-CommandLineInvocation -CommandWord 'git' -SubcommandPath add|commit`. In the loop, index 0 matches when the scan-text regex or `$isStaging` holds. Only index 0 may be cleared, by `Test-ExemptOrchestrationStagingCommand` (issue #539, helpers file); clearing it continues the loop, so a chained `pytest`, `ruff`, `black`, `pyright`, `npm`, `npx`, or `pwsh … Invoke-Pester` segment still returns implementation. A docs leg must keep that property: it is evaluated after classification, on a command the loop already classified as implementation, so a chained non-git segment has to be rejected again by the leg's own segment-shape check, as the cleanup leg does through `Test-OrchestrationCleanupSegmentShape`.
- Write path: `Test-ImplementationPath` exempts `docs/features/active/` and the seven checkpoint literals, and otherwise treats `.py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml` as implementation. Pages (`.md`) are not gated. `docs/documentation-estate/*.json` and `.github/workflows/_docs-quality.yml` are written by the docs library through `pwsh` (Bash or MCP), not by the Write tool, so they are not Write-gated. The pr-author receipt `.json` is Write-gated (finding 1).
- Order in `Invoke-OrchestrationPreimplementationGateDecision`: classification, the declared-checkpoint cross-check, `Get-OrchestrationEpicScopeDecision` (command and path legs), the epic and parallel delegation branch, `Read-OrchestrationGateCheckpoint` (denies on `NoTarget` or `Ambiguous`; an absent checkpoint returns `Resolved` with empty `Raw`), `Test-OrchestrationReady`, then the one-line cleanup call `Get-OrchestrationCleanupContextResult` and the final deny, which appends `$cleanup.DenySuffix`.
- Cleanup leg (`enforce-orchestration-preimplementation-gate-cleanup.ps1`, byte-identical at `.claude/hooks`, `.codex/hooks`, and both bundles): dot-sources `hook-cleanup-context.ps1` and `hook-docs-only-diff.ps1`. It owns the seams `Get-OrchestrationGateTemporaryRoot` and `Get-OrchestrationGateStagedIndex` (staged index through `Invoke-DocsOnlyGitExe`, NUL-terminated, `--no-renames --no-relative`). It has four legs (manifest Write, scratch Write/Edit, consolidation Write, consolidation git). The command leg requires every segment to be `git -C <absolute> add|commit`, `add` with `--` and allowlisted operands only, and `commit` with `-m`, `--message`, `-F`, `--file`, `--trailer` and no pathspec. Every target must be the consolidation root, and on commit the staged index must be non-empty and fully allowlisted. `DenySuffix` is `' Cleanup leg not applied: <SUB_CODE>: <detail>'`. It is set only after the leg has identified its target, and every prefilter rejection leaves it empty. `Get-OrchestrationCleanupContextResult` never throws.
- `hook-cleanup-context.ps1` holds pure predicates and restated literals, no I/O and no dot-source, byte-identical in four places. Its literals are pinned against `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` by `tests/scripts/claude-hooks/hook-cleanup-context.Parity.Tests.ps1`, because Codex hooks cannot import `.claude/lib`.
- Codex twin: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (493 lines). It has the same final two statements, with `-AllowPatchManifest` and `Get-StringProperty` for content. It dot-sources the same cleanup sibling, and it maps Codex Write and Edit through `ConvertTo-CodexFileEditInput`.
- Minimal insertion point (issue #1160 is concurrently editing the Claude main gate): one guarded dot-source line after the cleanup dot-source, and a change to the one-line cleanup call and final deny so that a docs leg is evaluated only when the cleanup leg did not allow. Its suffix is appended after the cleanup suffix. The same two edits apply to the Codex twin. All logic lives in the new sibling `enforce-orchestration-preimplementation-gate-docs.ps1`.
- Existing suites: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1`, `…gate.Tests.ps1`, `…gate.CommandExemption.Tests.ps1`, `…gate.Parity.Tests.ps1` with `…Parity.Cases.ps1`, `…gate.TriggerScoping.Tests.ps1`, and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1`.

### A2: model-routing gate and PR-create gate

- `.claude/hooks/enforce-model-routing-receipt.ps1`, `Invoke-ModelRoutingReceiptDecision`: the scope filter keeps the six gated agents, then epic scope, then `Get-ModelRoutingTargetCheckpointResolution` (denies on `NoTarget` or `Ambiguous`), then `Get-ModelRoutingCheckpoint` and the receipt check (which runs `Get-ModelRoutingAuthorAssertedReason` for pr-author only), then the cleanup exemption `if ($subagent -eq 'pr-author' -and $null -eq $checkpoint -and (Test-ModelRoutingCleanupDelegation …))`, then the final deny. The docs leg belongs beside the cleanup exemption with the same `$null -eq $checkpoint` conjunct.
- Branch parsing: `Resolve-WorktreeItemTarget` (`.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`) reads `Find-WorktreeResolutionBranchSignal` and the `Canonical issue number for this feature is` line. A prompt with only `branch: <name>` resolves through `Resolve-WorktreeItemTargetByBranch` to the one live worktree that has the branch checked out (`SessionRoot` when that is the session root). Zero or several checkouts deny before the docs leg runs. `Test-CleanupConsolidationBranchLabel` (`hook-cleanup-context.ps1`) is the label-shape precedent: exactly one case-insensitive `branch:` occurrence, a line-anchored lowercase label, and no `--head` or `--branch` token.
- Diff computation, fail-closed and with no Python: reuse `Invoke-DocsOnlyGitExe` from `hook-docs-only-diff.ps1` (bounded 3000 ms per git call through `Invoke-DocsOnlyBoundedNative`; never throws; exit 124 on timeout). The sequence is `rev-parse --verify --quiet refs/remotes/origin/<base>^{commit}`, then `rev-parse --verify --quiet HEAD^{commit}` in the resolved worktree, then `diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <base>...<head>`, followed by the same NUL check as `Get-DocsOnlyDiffTextViolation`. With the A4 rule it adds `merge-base --is-ancestor <receipt-rev> <head>` and `diff --name-only -z --no-renames <receipt-rev> <head>`: five bounded git calls, at most about 20 s with output waits. No timeout is set on the Agent hooks in `.claude/settings.json`, so the Claude Code default applies (orchestrator to confirm the default).
- `AUTHOR_ASSERTED_AUTOCLOSE_MISSING`: not reachable on a checkpoint-free delegation (finding 2). The docs leg needs no change there. The skill text should still tell the docs run to add the line when an issue exists, so the PR body emits `- Closes #N` from the delegation-prompt source of the pr-author skill.
- PR-create gate: `Get-PrAuthorBypassReason` (`enforce-pr-author-skill-helpers.ps1`, 499 lines) runs `Resolve-PrAuthorArtifactRoot`, `PR_CONTEXT_MISSING`, `Invoke-OrchestratorStatePreflight`, then on preflight errors `Get-PrAuthorPreflightExemption` (`enforce-pr-author-skill.cleanup.ps1`). That calls `Get-PrAuthorDocsOnlyExemption` (`enforce-pr-author-skill.docs-only.ps1`, E1 to E7) and then receipt checks 1 to 6. A docs run with no checkpoint satisfies E1 and E2. E3 needs exactly one explicit `--base`. E4 to E6 need `origin/<base>` and a non-empty diff. E7 fails only on the non-`docs/` init outputs. **Conclusion: A2 needs no change to the PR-create gate; A3 makes E7 pass.** The pr-author skill's required `--head <branch>` resolves the artifact root through `Resolve-HookTargetWorktree`.

### A3: docs-init outputs and the E7/M9 classifiers

- `Get-DocsInitTemplate` (`DocsProfileCommands.psm1`, 239 lines) returns six rows: `.markdownlint.json`, `.vale.ini`, `.vale/styles/DocsBase/HeadingPunctuation.yml`, `.vale/styles/DocsBase/Placeholders.yml`, `.vale/styles/config/vocabularies/Project/accept.txt`, and `.github/workflows/_docs-quality.yml`. Their sources are under `.claude/lib/docs/templates/`. `Invoke-DocsInitCommand` prepends the profile (`Get-DocsDefaultProfilePath` = `docs/documentation-estate/docs-profile.json`).
- `_docs-quality.yml` runs `inventory`, `check`, `validate -WriteReceipt`, and an optional `surface-delta`, all through `Invoke-DocsCommand.ps1`. It invokes no Vale or markdownlint.
- Vale configuration discovery was verified against the Vale documentation (`docs.vale.sh/topics/.vale.ini`). `StylesPath` resolves relative to the file that sets it. Discovery order is `--config`, then `VALE_CONFIG_PATH`, then an upward search from the working directory. A `.vale.ini` moved to `docs/documentation-estate/` keeps `StylesPath = .vale/styles` valid only when the styles move with it, and a consumer must pass `--config` or set `VALE_CONFIG_PATH`. The markdownlint per-directory discovery behavior was not verified in this research.
- E7: `Get-PrAuthorDocsOnlyExemption` calls `Get-DocsOnlyDiffTextViolation`, which calls `Get-DocsOnlyPathViolation`. M9: `Get-DocsOnlyMergeExemption` (same file) calls the same function, and both the Claude and the Codex `enforce-epic-merge-gate.ps1` call it. One edit to `Get-DocsOnlyPathViolation` therefore covers E7 and M9 on both runtimes. `hook-docs-only-diff.ps1` is byte-identical at `.claude/hooks`, `.codex/hooks`, and both bundles, and it states "imports nothing, dot-sources nothing".
- Tests that pin the current init output paths or the init table text:
  - `tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1`: the five source-to-destination pairs, `StylesPath = .vale/styles`, the planned-writes and `-Write` destinations, and the empty `accept.txt` destination.
  - `tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1`: the exact text of the table row after the `1034` anchor, the workflow destination, and the workflow step count.
  - `tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1`: the write count `1 + DefaultTemplateFiles.Count`, and the anchor-comment format.
  - `tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1`: indirectly, through the skill command references.
  - Contract tests over the bundle: `test_push_down_claude_resource_contracts.py` and `test_push_down_claude_pack_manifest_completeness.py`. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists the five template sources.
  - Documentation: `docs/engineering/documentation-estate/consumer-onboarding.md` (`## Linting`) and `command-reference.md` name the root paths. These are not tests.

### A4: receipt revision rule

- `Test-DocsCompleteGateReceipt` (`.claude/lib/docs/DocsCompleteGate.psm1`, 191 lines, pure) applies the order `RECEIPT_ABSENT`, `RECEIPT_UNREADABLE`, `RECEIPT_MODE`, `RECEIPT_FAILING`, then `RECEIPT_REVISION_MISMATCH`, where receipt `revision` is compared ordinally with `-HeadRevision`. The hook passes the PR `headRefOid` from `Get-DocsCompleteGatePullRequest`, and it reads the receipt beneath `Get-DocsCompleteGateReceiptRoot` (the worktree that has the head branch, else the repository root) from the working tree, not from git.
- `Invoke-DocsValidateCommand` (`DocsLedgerCommands.psm1`, **785 lines**) requires `-Revision` (`Test-DocsValidateArgument`) and passes it to `Invoke-DocsValidation` (`DocsValidation.psm1`, 367 lines). There a non-null snapshot `revision` other than `-Revision` adds the `DOCS_REVISION_MISMATCH` error, and in docs-complete mode a null snapshot revision gives `DOCS_SNAPSHOT_UNPINNED`. `New-DocsValidationReceipt` (`DocsReceipt.psm1`) records `revision = -Revision`. A pass receipt therefore always names the snapshot revision S.
- Gate versus validate: the gate requires S equal to the PR head H, and a committed snapshot cannot name its own commit. The gate cannot be satisfied in the documented commit-the-estate workflow (verified by reading; not executed).
- A second, unused copy of the revision comparison exists: `Get-DocsReceiptGateDecision` (`DocsReceipt.psm1`). Production code does not call it; it is used only by `DocsReceipt.Tests.ps1`, `DocsReceipt.Properties.Tests.ps1`, and `DocsCompleteIntegration.Tests.ps1`.
- MCP: `validate_docs_artifacts` (`extensions/drm-copilot/src/mcp-docs-tool-definitions.ts`) "never persists a receipt", so a `-Revision` default limited to `-WriteReceipt` does not change the MCP surface.

### A5: skill texts and mirrors

- `documentation-workflow/SKILL.md` has six copies: `.claude/skills/`, `.agents/skills/`, `.github/skills/`, and the three bundles under `extensions/drm-copilot/resources/` (`claude-customizations/.claude/…`, `codex-and-agents-customizations/.agents/…`, `customizations/.github/…`). `docs-authoring-roles.Skills.Tests.ps1` pins the following:
  - the seven dispatch links in order (Claude copy);
  - every `-Command <name> -<Option>` reference must be a dispatch-table row and option of `Invoke-DocsCommand.ps1`, with the global options `Json`, `Help`, and `RepositoryRoot`;
  - every docs MCP tool name must be one of the six docs tools;
  - the non-Claude copies must contain no `.claude/` text, and their `## Prerequisites` must match `docs helper library`, `push-down`, and `PowerShell 7\.4`.
- `pr-author/SKILL.md` has four copies: `.claude/skills/`, `.agents/skills/`, and the two bundles. There is no `.github/skills/pr-author`; the Copilot surface is `.github/agents/pr-author.agent.md` and `.github/prompts/generate-pr.prompt.md`, which these Claude hooks do not gate. Contract tests that name it: `tests/scripts/claude-runtime/pr-author-issue-link-contract.Tests.ps1`, `pr-author-coordinator-topology-contract.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1`, and `tests/scripts/dev_tools/test_parallel_issue_combination_contracts.py`. The new text goes in a new section after `## Coordinator-Session Topology (issue #1011)`.
- The pr-author agent (`.claude/agents/pr-author.md`) writes the body and receipt with `Write(/artifacts/**)`. Its own hooks (`enforce-pr-author-command-allowlist.ps1`, `validate-pr-author-output.ps1`) do not read a checkpoint.

### Execution-environment brief

- `## Hook Execution Context`, bullet `Cleanup legs (#1026)`: a docs-estate counterpart bullet is required (the three new legs, their predicates, and the receipt Write). `## Contract Tests That Pin Mirrored Files` gains the new suites. The brief is byte-identical in six copies (`test_execution_environment_brief_contracts.py`, `test_brief_copies_are_byte_identical`). `test_brief_has_no_consuming_names` and `test_brief_has_no_g11_or_g12_findings` also apply. `cleanup-merged-worktrees.SkillText.Tests.ps1` reads `## Hook Execution Context` and asserts three cleanup literals, which must survive the edit.

## Candidate Approaches

### A1 placement

- Selected: a new sibling `enforce-orchestration-preimplementation-gate-docs.ps1`, byte-identical at `.claude/hooks`, `.codex/hooks`, and both bundles. It exposes `Get-OrchestrationDocsEstateContextResult` (same shape as the cleanup result: `Allowed`, `DenySuffix`; never throws). Each main gate calls it once, only when the cleanup leg did not allow. This matches the spec ("beside the cleanup leg"), keeps the cleanup sibling and its contract text untouched, and limits the edit to the issue #1160 file to three lines.
- Rejected: chaining the docs leg from inside `Get-OrchestrationCleanupContextResult`. It needs zero main-gate edits, but it changes the cleanup sibling's documented "Four legs" contract and mixes two readiness models in one result.

### A3 option

- Selected (preferred option of the issue): move the five linter files under `docs/documentation-estate/` (for example `docs/documentation-estate/.markdownlint.json`, `docs/documentation-estate/.vale.ini`, `docs/documentation-estate/.vale/styles/...`) and keep `.github/workflows/_docs-quality.yml` as the single admitted non-`docs/` path. Add no `--config` step to `_docs-quality.yml`, because the workflow runs no linter. State instead in `consumer-onboarding.md` and in `docs-init/SKILL.md` that a consumer passes `--config` (Vale) or a config option (markdownlint) when running the linters. The exemption widening is one exact path, ordinal, not a glob.
- Rejected: the alternative of admitting all six init outputs in E7/M9. It widens the docs-only exemption, which is global and not docs-estate-scoped, by six root paths including `.vale/**` files, and every consumer branch would carry them.

### Shared constant location

- Selected: a script-scope literal `$script:DocsOnlyInitWorkflowPath = '.github/workflows/_docs-quality.yml'` in `hook-docs-only-diff.ps1`, read by `Get-DocsOnlyPathViolation` (one ordinal equality, inside the existing loop). Every E7 and M9 consumer already dot-sources that file, so no consumer gains a dependency. The docs library cannot import a hook file, and the Codex hooks cannot import `.claude/lib`. A Pester parity test therefore pins the hook literal equal to the workflow destination row of `Get-DocsInitTemplate`, following the precedent of `hook-cleanup-context.Parity.Tests.ps1`. The A1 sibling and the A2 leg read the same literal.
- Rejected: a new `hook-docs-estate-paths.ps1` dot-sourced from `hook-docs-only-diff.ps1`. That breaks the file's "dot-sources nothing" contract, and a consumer that missed the dot-source would deny every docs-only PR. Also rejected: a lib-to-hook dot-source (layer inversion; dependency-closure scanner behavior unverified).
- Cost: `hook-docs-only-diff.ps1` grows from 497 to about 505 lines. That crosses the 500-line guidance tier only (no gate).

### A4 shared rule location

- Selected: a new pure module `.claude/lib/docs/DocsReceiptRevision.psm1`. It imports only `DocsSurface.psm1`, so the import closure stays free of runtime imports for the hook dependency guard. It exports `Get-DocsReceiptRevisionDecision -ReceiptRevision -SnapshotRevision -HeadRevision -IsAncestor <bool|null> -ChangedPath <string[]|null> -SourceRoot <string[]>`, which returns `@{ Allow; Reason; Message }`. The git I/O stays in each caller:
  - The gate hook uses `Invoke-DocsOnlyGitExe`, which it already dot-sources.
  - The model-routing docs leg uses the same seam.
  - `validate` uses two new members of the command context in `Invoke-DocsCommand.ps1` (552 lines), next to `ResolveRevision`, with the same 30-second bounded `InvokeProcess`.
  - `Test-DocsCompleteGateReceipt` delegates its revision step to the new function.
- Rejected: placing the rule in `DocsCompleteGate.psm1`. It has room, but `validate` would then import a gate module, and the gate module's header scopes it to the merge hook.

## Behavior Semantics (proposed design)

### A1 docs-estate leg (`Get-OrchestrationDocsEstateContextResult`)

The leg is evaluated only where the gate would otherwise deny, after the cleanup leg declines.

- Prefilters, pure and run before any I/O:
  - Command: every segment of `Split-OrchestrationCommandLine` is `git add -- <operand…>` or `git commit` with only `-m`, `--message`, `-F`, `--file`, `--trailer` and no pathspec, optionally `git -C <absolute root>`.
  - Write: the path is `artifacts/pr_body_<digits>.receipt.json`, relative or absolute.
  - Anything else returns `Allowed $false` with an empty suffix, so a chained `pytest` or `ruff` segment still denies with the unchanged text.
- D1, target: `Get-OrchestrationCommandTarget` resolves exactly one worktree root R. The checkpoint at R is absent; the docs leg must not admit a call that a present but unready checkpoint governs.
- D2, profile: `docs/documentation-estate/docs-profile.json` beneath R is read and validated structurally by a pure function in a new byte-identical hook file `hook-docs-estate-context.ps1`. The JSON object must have `artifact_kind` `docs-profile`, a non-empty `documentation_roots[]` of plain relative paths, and string `artifact_paths` values. Full schema validation (`ConvertFrom-DocsProfileText`) is not available to the Codex twin, which cannot import `.claude/lib`.
- D3, path set: a path qualifies when either of the following holds.
  - It lies under the directory of an `artifact_paths` value.
  - It equals `$script:DocsOnlyInitWorkflowPath`.
  - It lies under a `documentation_roots[].path`. When that root is not under `docs/`, the path must also end in `.md`.
  - Every path is checked against the character class and `..` rules of `Test-CleanupConsolidationRelativePath`.
- D4, add: every operand is in the path set.
- D5, commit: the staged index read through `Get-OrchestrationGateStagedIndex` beneath R is readable, NUL-terminated, non-empty, and entirely in the path set.
- Receipt Write: R holds a valid profile (D2) and no checkpoint.
- Deny suffix: `' Docs-estate leg not applied: <SUB_CODE>: <detail>'`. It is set only after the leg identified R and found a profile (the precedent of the cleanup leg). Sub-codes: `DOCS_LEG_PROFILE_INVALID`, `DOCS_LEG_PATH_NOT_ALLOWED`, `DOCS_LEG_STAGED_INDEX_UNREADABLE`, `DOCS_LEG_STAGED_INDEX_EMPTY`, `DOCS_LEG_STAGED_PATH_NOT_ALLOWED`. A missing profile leaves the suffix empty, so non-docs repositories see unchanged deny text.

### A2 docs-estate delegation leg

- Placement: in `Invoke-ModelRoutingReceiptDecision`, after the cleanup exemption and under the same `$subagent -eq 'pr-author' -and $null -eq $checkpoint` conjunct.
- Conditions, evaluated in order (first failure denies, with the existing final reason plus a docs suffix):
  1. Exactly one `branch:` line (`Test-CleanupConsolidationBranchLabel` shape, with any conservative branch value) and exactly one `base: <branch>` line with a conservative spelling and no `..`.
  2. The profile beneath the resolved root passes D2.
  3. The `<base>...HEAD` diff in that root is non-empty, NUL-terminated, and fully in the D3 path set.
  4. The receipt at `artifact_paths.validation_receipt` beneath the root has `artifact_kind` `docs-validation-receipt`, `mode` `docs-complete`, and `validation_result` `pass`, and it passes `Get-DocsReceiptRevisionDecision` against the worktree `HEAD`.
- Open choice for the planner: whether `base:` is required or the base is fixed to `main`, as the cleanup exemption K4 does. The recommendation is to require `base:`, because a docs PR may target an epic integration branch.

### A4 one revision rule (`Get-DocsReceiptRevisionDecision`)

- Allow when all of the following hold:
  - The receipt revision equals the snapshot revision.
  - The receipt revision is an ancestor of the head (`git merge-base --is-ancestor`, exit 0).
  - `git diff --name-only -z --no-renames <receipt-rev> <head>` lists no path under any `surface_selection.source_roots` entry (ordinal, segment-anchored prefix).
- Deny reasons:
  - `RECEIPT_REVISION_NOT_ANCESTOR`, which covers a rebased branch whose snapshot revision left history.
  - `RECEIPT_SOURCE_DRIFT`, which names up to a fixed number of drifted paths.
  - `RECEIPT_REVISION_UNRESOLVED`, for a git failure, a timeout, or a head not present locally, with a fetch remediation as in M5.
  - Each message names the refresh procedure of A5.
- Head equal to the receipt revision allows with no git call. This keeps the CI template's inventory-at-head flow passing.
- `validate`: with `-WriteReceipt` and no `-Revision`, the revision defaults to the snapshot `revision`. The usage error remains when the snapshot revision is null or absent; it then names `inventory -Revision`. `-Help` and `docs/engineering/documentation-estate/command-reference.md` state the default. In docs-complete mode, validate also applies the rule against the repository `HEAD` (new context members) and reports an error finding, so a drifted estate cannot be written as a pass receipt. The MCP `validate_docs_artifacts` path still passes `-Revision` and is unaffected.

### A5 skill stage

- A new final root stage, `## Commit, Receipt and Pull Request`, comes after `## Dispatch Order` and is not a numbered dispatch row, so the seven-link order test is unchanged. It has four steps:
  1. Commit after docs-init and after docs-complete, with `git add -- <paths>` and `git commit -F <file>`.
  2. Write the receipt with `validate -Mode docs-complete -WriteReceipt` (default revision).
  3. Push.
  4. Delegate `Agent(pr-author)` with the prompt contract: `branch:`, `base:`, the canonical issue line and `Author-asserted autoclose issues: #<N>` when an issue exists, and `gh pr create --head <branch> --base <base>`.
- Add a `## Refresh After Rebase or Source Change` procedure with the seven steps of the issue.
- Non-Claude copies keep no `.claude/` text and use only dispatch-table options.

## Requirements Mapping and File Inventory

The table uses logical line counts (from Grep line counts) for existing files. No file named below is listed in `config/file-size-baseline.json`.

| File | Change | Lines now | Tier note |
|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 3-line insertion (#1160 overlap) | 473 | under 500 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | same 3 lines | 493 | crosses 500 (guidance only) |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1` (+ `.codex/hooks/`, both bundles) | new, A1 | 0 | keep under 500 |
| `.claude/hooks/hook-docs-estate-context.ps1` (+ `.codex/hooks/`, both bundles) | new, pure profile and path predicates | 0 | |
| `.claude/hooks/hook-docs-only-diff.ps1` (+ `.codex/hooks/`, both bundles) | constant and one admit condition, A3 | 497 | crosses 500 (guidance only) |
| `.claude/hooks/enforce-model-routing-receipt.ps1` (+ Claude bundle) | A2 leg (or new sibling `enforce-model-routing-receipt.docs.ps1` to keep the file small) | 393 | |
| `.claude/hooks/enforce-docs-complete-gate.ps1` (+ Claude bundle) | git seam calls for the A4 rule | 396 | |
| `.claude/lib/docs/DocsCompleteGate.psm1` (+ bundle) | delegate revision step | 191 | |
| `.claude/lib/docs/DocsReceiptRevision.psm1` (+ bundle) | new, A4 | 0 | |
| `.claude/lib/docs/DocsLedgerCommands.psm1` (+ bundle) | **785 lines; 15 lines from the hard block.** Move `Test-DocsValidateArgument` and `Invoke-DocsValidateCommand` to a new `DocsValidateCommands.psm1` before changing them, and update the `validate` dispatch row | 785 | 700 advisory now |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` (+ bundle) | two context members, help text, dispatch row module | 552 | crosses no new tier |
| `.claude/lib/docs/DocsProfileCommands.psm1` (+ bundle) | five destination changes | 239 | |
| `.claude/lib/docs/DocsReceipt.psm1` | optional: align or leave `Get-DocsReceiptGateDecision` | 299 | |
| `.claude/lib/docs/templates/_docs-quality.yml` | comment only, if any | 65 | |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | add the new Claude hook and lib files | n/a | |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | generated by `scripts/dev_tools/generate_codex_agent_variants.py` (`--check`) | n/a | |
| `.claude/skills/documentation-workflow/SKILL.md` (6 copies) | A5 | 39 | Markdown exempt |
| `.claude/skills/pr-author/SKILL.md` (4 copies) | A2 prompt contract | 142 | Markdown exempt |
| `.claude/skills/docs-init/SKILL.md` (copies) | new init paths. Touches B13 (#1173); coordinate | n/a | |
| `.claude/skills/execution-environment/SKILL.md` (6 copies) | docs-estate legs bullet, contract-test list | n/a | |
| `docs/engineering/documentation-estate/consumer-onboarding.md`, `command-reference.md`, `workflow.md` | paths, `-Revision` default, commit stage | n/a | |

Part B overlap: B13 edits `docs-init/SKILL.md` and the init output lines. B6 and B7 edit `New-DocsStarterProfile` (`DocsProfile.psm1`), whose `documentation_roots` default of `docs` the D3 path set relies on. Part A should not edit `DocsProfile.psm1`.

## Testing Implications

All new tests are Pester 6 under `tests/scripts/claude-hooks/`, `tests/scripts/codex-hooks/`, and `tests/scripts/claude-lib/docs/`. They use injected seams only (`Get-OrchestrationGateStagedIndex`, `Get-OrchestrationGateWorktreeList`, `-GitInvoker`, and the profile and receipt read seams), with no temporary files.

- New suites:
  - `enforce-orchestration-preimplementation-gate.DocsEstate.Tests.ps1` (Claude) and `enforce-orchestration-preimplementation-gate-docs.Tests.ps1` (Codex). Cases: allow add and commit; deny for each of D1 to D5; deny for a chained `pytest`; deny with a checkpoint present; unchanged text without a profile; receipt Write allow and deny.
  - `hook-docs-estate-context.Tests.ps1`.
  - A byte-identity and literal parity suite: the hook literal equals the `Get-DocsInitTemplate` workflow destination.
  - `enforce-model-routing-receipt.DocsEstate.Tests.ps1`: each condition, plus a regression for the cleanup leg.
  - `DocsReceiptRevision.Tests.ps1`, with a property test over ancestor, drift, and equality.
  - A documentation-workflow skill contract test for the new stage in six copies.
- Updated suites:
  - `hook-docs-only-diff.Tests.ps1` (Claude and Codex): docs paths plus the workflow path allow; one extra non-docs path denies.
  - `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` and `enforce-epic-merge-gate.DocsOnly.Tests.ps1`.
  - `DocsCompleteGate.Tests.ps1` and `enforce-docs-complete-gate.Tests.ps1`: the current `RECEIPT_REVISION_MISMATCH` cases change meaning.
  - `DocsLedgerCommands.Tests.ps1`: `It 'rejects WriteReceipt outside docs-complete'` asserts `-Revision` required for `ledger` mode; that stays.
  - `DocsLedgerCommands.Properties.Tests.ps1`: the property over modes, revisions, and WriteReceipt treats an empty revision as invalid for every mode, so the docs-complete plus WriteReceipt row needs a deliberate disposition.
  - `DocsLedgerCommands.Validate.Tests.ps1`, `DocsCompleteIntegration.Tests.ps1`, `EndToEndDocumentationEstate.Tests.ps1`, `DocsPageTemplates.Tests.ps1`, `DocsInitTemplate.DocsWorkflow.Tests.ps1`, and `DocsProfileCommands.Tests.ps1`.
- Contract tests: the push-down resource and pack-manifest tests (Claude and Codex), `test_push_down_pack_manifest_dependency_closure.py`, the Codex generator `--check`, `hook-dependency-guard-completeness.Tests.ps1` (guarded dot-source pattern in the new hooks), `test_execution_environment_brief_contracts.py`, `cleanup-merged-worktrees.SkillText.Tests.ps1`, `docs-authoring-roles.Skills.Tests.ps1`, the pr-author contract suites, and `enforcement-hooks-no-python-invocation.Tests.ps1`.
- Live verification: hook behavior on the branch is proven by Pester. An isolated subagent runs `main`'s hooks (execution-environment brief, `## Hook Execution Context`). The end-to-end condition of the early-draft acceptance list cannot be met by an isolated subagent run on this branch.

## Numeric Derivation Evidence

`spec.md` is Draft and states no numeric acceptance criterion. This research proposes no numeric count, enumeration, or population for an approved acceptance criterion. Counts stated above (six init rows, six skill copies, four pr-author copies) are descriptive facts read from the named files. They are not proposed assertions, so no derivation record is required. A planner that turns any of them into an acceptance assertion must first add the full derivation record.

## Automation Feasibility

Fully automatable. Every change is PowerShell, Markdown, or JSON, and every behavior is exercised through existing seams with in-memory inputs. No step needs a human decision, external credentials, or a live GitHub call: `gh` and `git` sit behind the bounded seams that tests replace. Two inputs need an owner decision before planning closes: `base:` required versus fixed `main` in A2, and the D3 rule for documentation roots outside `docs/`. Neither blocks automation.

## Pre-Mortem

- **Review checklists:** The new allow legs widen three enforcement gates, and a reviewer will check fail-closed ordering, ordinal comparisons, prefilter-before-I/O, and unchanged deny text for non-docs repositories. Mitigation: the plan lists every sub-code with a deny test, and it asserts byte-identical existing deny text when no profile exists, as the cleanup-leg suites do.
- **Coverage:** New PowerShell files need 85% line coverage from the single `Invoke-PoshQCParallelTest` run. A Codex-only branch that only the Codex suite exercises can fall short. Mitigation: dedicated Claude and Codex suites, and coverage read from `artifacts/pester/powershell-coverage.xml`, not from MCP output.
- **Mirror parity:** The changes reach 4-copy hook files, a 6-copy brief, a 6-copy workflow skill, 4-copy pr-author copies, lib bundle copies, the Claude `core.json`, and the generated Codex `core.json`. Missing one fails the push-down contract tests. Mitigation: one task per mirror family, the Codex generator `--check`, and a brief-update task named in this bullet (execution-environment brief `## Preflight Defect Classes the Validator Cannot See`, the last item).
- **File size:** `DocsLedgerCommands.psm1` is at 785 lines, so any in-place edit risks the 801-line hard block. `hook-docs-only-diff.ps1` (497 lines) and the Codex main gate (493 lines) cross the 500-line guidance tier. Mitigation: extract the validate command to a new module before changing it, and keep new logic in new files.
- **Test isolation:** New suites dot-source hook files that define `$script:` literals and global-scope functions, and Pester shards share a process. Mitigation: remove functions in `AfterAll` as `docs-authoring-roles.Skills.Tests.ps1` does, set no environment variables, and pass `Invoke-PoshQCLeakScan` with no new allowlist entry.
- **CI-only behavior:** The Linux hook-suite job is case-sensitive and has no gitignored `artifacts/`. Fixtures that use drive-letter roots or backslashes fail there. Mitigation: forward-slash relative paths and `/`-rooted synthetic roots, with no reliance on `origin/main` in `_shell-coverage.yml`.
- **Evidence:** The end-to-end acceptance item (a first-time run through PR creation with no denial) cannot be proven on the branch, because isolated subagents run `main`'s hooks. Mitigation: prove each leg with Pester, and record the live end-to-end check as a post-merge verification, or run it through a non-isolated delegation from the item worktree, with append-only evidence under `evidence/regression-testing/`.

## Open Risks

1. Docs-only exemption breadth: admitting `.github/workflows/_docs-quality.yml` in E7/M9 applies to every repository and every PR, not only to docs-estate runs. A PR that edits only that workflow passes the checkpoint preflight and the merge-side checkpoint gate. CI still runs in full (the path is outside `config/ci-docs-only-paths.json`), and the ruleset still requires `CI Required Gate`. State this as a policy-level control.
2. Author-controlled profile: `documentation_roots` comes from a repository file, so a profile could name a code directory. D3 limits roots outside `docs/` to `.md` files.
3. Pull-request number `<N>` for `artifacts/pr_body_<N>.md`: a docs run without a tracking issue has no number before the PR exists. The skill contract must require an issue, or state which number the run uses.
4. A session root holding another item's checkpoint makes every docs leg decline, because each requires an absent checkpoint, and it makes E2 fail. This is acceptable fail-closed behavior; the skill states it.
5. A2 bounded git calls on Windows add latency to every checkpoint-free pr-author delegation, up to about 20 s.
6. Issue #1160 edits the same Claude main gate file. The three-line insertion may conflict textually, and the conflict is cheap to resolve.

## Facts for the Orchestrator to Confirm

- The diff of the concurrent issue #1160 branch against `enforce-orchestration-preimplementation-gate.ps1` (Claude and Codex), to place the three-line insertion: `git diff` against that branch.
- The Claude Code default PreToolUse hook timeout for hooks registered without `timeout` in `.claude/settings.json`.
- That #1173 (Part B) does not plan edits to `DocsProfileCommands.psm1` or `docs-init/SKILL.md` that conflict with the A3 path move: `gh issue view 1173`.
- Whether `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` is regenerated, not hand-edited, for new `.codex/hooks/` files (`generate_codex_agent_variants.py --check`).
- That no production caller of `Get-DocsReceiptGateDecision` exists outside the files Grep found (the grep covered the item worktree only).

## Rejected Alternatives (brief)

- Chain the docs leg inside the cleanup sibling: this would change the cleanup sibling's documented contract.
- Admit all six init outputs in E7/M9: this would widen a global exemption by six root paths.
- A new dot-sourced paths file for E7/M9: this would break the "dot-sources nothing" contract of `hook-docs-only-diff.ps1`.
- The shared revision rule in `DocsCompleteGate.psm1`: `validate` would depend on a gate module.
- Full profile schema validation in the hooks: this is not available to Codex, which cannot import `.claude/lib`.
