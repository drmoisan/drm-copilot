# Research: cleanup-merged-worktrees workflow blocked by checkpoint gates (Issue #1026)

- Issue: #1026
- Branch: `bug/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026`
- Inputs: `docs/features/potential/promoted/2026-10-30-cleanup-worktrees-workflow-blocked-by-checkpoint-gates.md`, `evidence/regression-testing/reproduction.2026-11-03T11-56.md` (this feature folder)
- Method: static reading of the hooks, libraries, skills, tests, pack manifests, and settings in this worktree. No command was executed. Line counts are physical line counts measured with a ripgrep `^` count, which equals `@(Get-Content -LiteralPath <path>).Count` for a file that ends with a line terminator; the executor re-measures before editing.

## Summary of Findings

1. The five blockers in the reproduction are confirmed by code reading at the functions the reproduction names.
2. Two further blockers exist on the PR leg and were not part of the reproduction. Both are inferred from code and need a reproduction run (see Open Questions):
   - `Agent(pr-author)` delegation is denied by `.claude/hooks/enforce-model-routing-receipt.ps1` (`Invoke-ModelRoutingReceiptDecision`): `pr-author` is in `Get-ModelRoutingGatedAgent`, the `branch: documentationandmemories` label resolves to the consolidation worktree, `Get-ModelRoutingCheckpoint` returns `$null` there, and `Test-ModelRoutingReceiptPresent` returns `$false` for a `$null` checkpoint, so the final `MODEL_ROUTING_RECEIPT_BLOCKED` deny applies.
   - The pr-author agent's Write of `<consolidation worktree>/artifacts/pr_body_<N>.receipt.json` is classified as implementation by `Test-ImplementationPath` (the `.json` extension leg; `artifacts/` is not exempt), and `Read-OrchestrationGateCheckpoint` reads the absent checkpoint beneath the consolidation worktree, so the Write is denied with `PREIMPLEMENTATION_GATE_BLOCKED`. The body file (`.md`) is not affected.
3. Codex has twins only for the preimplementation gate and its shared siblings. Codex has no PR-author gate, no checkpoint-backed model-routing receipt gate, no parallel worktree-removal gate, no manifest branch in its epic worktree-removal gate, and no `cleanup-merged-worktrees` skill.
4. Several files are at or near pinned 500-line caps enforced by tests (not only by the file-size policy). The design must place new logic in new sibling files.

## Q1. Codex Parity Map

| Claude function or file | Codex twin | Difference |
|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`: `Test-ImplementationPath`, `Test-ImplementationCommand`, `Invoke-OrchestrationPreimplementationGateDecision` | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, same function names | Codex `Test-ImplementationCommand` adds two `apply_patch` marker legs (`*** Add/Update/Delete File:`, `*** Move to:`) that call `Test-ImplementationPath` before the staging loop. Codex `Invoke-OrchestrationPreimplementationGateDecision` parses JSON directly (no `Resolve-ClaudeHookToolInput`), allows an empty payload, and has no entry-point seam. The Codex entry tail sends `Bash` and `apply_patch` raw `tool_input` to the decision, and maps `Edit`/`Write` through `ConvertTo-CodexFileEditInput` (`.codex/hooks/codex-pretooluse-file-mapping.ps1`) into `@{ file_path = ... }` only, so the Write `content` field is dropped before the decision. |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`: `Test-ExemptOrchestrationStagingCommand` and its parser | `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | Byte-identical across four copies, pinned by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`. |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`: `Get-OrchestrationCommandTarget`, `Get-OrchestrationPatchMarkerPath` | `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | Byte-identical across four copies, pinned by `enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1`. |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`: `Get-OrchestrationGateWorktreeList`, `Invoke-OrchestrationGateWorktreeList`, `Get-OrchestrationGateCommandOperandPath`, `Resolve-OrchestrationGateTarget`, `Read-OrchestrationGateCheckpoint` | `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | Not byte-identical. The listing seam and operand parser have identical text; Codex `Resolve-OrchestrationGateTarget` has no `-Mode`/`-Prompt`, resolves `apply_patch` marker paths as `-FilePath`, restates the two reason-code literals, and composes the checkpoint path by string concatenation. |
| `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` | `.codex/hooks/hook-target-worktree.ps1` | Function text byte-identical (module header states this); Codex dot-sources it, guarded. |
| `.claude/hooks/enforce-pr-author-skill.ps1`, `-helpers.ps1` (`Get-PrAuthorBypassReason`, `Test-PrAuthorReceiptVerification`), `.docs-only.ps1` (`Get-PrAuthorDocsOnlyExemption`) | none | `.codex/config.toml` registers no PR-author hook. |
| `.claude/hooks/hook-docs-only-diff.ps1` (`Get-DocsOnlyDiffTextViolation`, `Get-DocsOnlyPathViolation`, `Invoke-DocsOnlyGitExe`) | `.codex/hooks/hook-docs-only-diff.ps1` | Byte-identical at four locations; also consumed by both `enforce-epic-merge-gate.ps1` copies, so widening `Get-DocsOnlyPathViolation` would widen the merge gate on both runtimes. |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | none | `.codex/hooks/enforce-codex-model-routing.ps1` checks model/profile routing, not checkpoint receipts. |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` only | The Codex gate reads only `artifacts/orchestration/epic-orchestrator-state.json` beneath the repository root that holds the script, has no parallel branch and no manifest branch, and cannot import `.claude/lib`. |

Codex registration (`.codex/config.toml`): the preimplementation gate is registered under the `^Bash$` matcher group and under the `^(apply_patch|Edit|Write)$` matcher group. No cleanup skill exists under `.agents/skills/` or `.github/skills/` (search for `cleanup-merged-worktrees` and `documentationandmemories` under `.agents`, `.codex`, `.github` returned no file).

## Q2. Consolidation-Worktree Identification

Existing helpers:

- `ConvertFrom-HookTargetWorktreePorcelain` (HookTargetWorktree) returns one record per non-bare stanza with `Root` (normalized), `Branch` (short name, `$null` when detached), and `Prunable`. This is the only helper that exposes the branch of each registered worktree without reading files.
- `Get-HookTargetWorktreeEnclosingRoot` returns the longest registered root enclosing a path; `Get-HookTargetWorktreeRelativePath` returns the remainder under a root.
- `Resolve-HookTargetWorktree` returns `WorktreeRoot`, `Source`, `Ambiguous`, `ReasonCode`, `Detail`, `Candidates`, but not the branch. A path outside every registered worktree returns the session root with `Source = 'SessionRoot'`.
- `Get-OrchestrationGateWorktreeList` (both epic-scope siblings) is the single listing seam; existing suites mock it.
- `Get-OrchestrationCommandTarget` (targets file) resolves every command segment to an absolute target and fails closed with a rule token for: unbalanced segment, a directory-change word (`cd`, `pushd`, `Set-Location`, and others), a wrapper or live substitution carrying `git add`/`git commit`, a relocation name (`GIT_DIR`, `GIT_WORK_TREE`, `GIT_COMMON_DIR`, `GIT_INDEX_FILE`), `--git-dir`/`--work-tree`/`-c core.worktree`, an unmodeled git global option, a `-C` with no value, and a `-C` value that contains a backslash, is not absolute, or carries a dot segment. A segment with no `-C` resolves to the session root.
- The epic-scope leg uses `Resolve-EpicScopeCheckpoint -MatchWorktreeHead`, which reads the HEAD file through `Get-EpicScopeWorktreeHeadBranch` (EpicScopeResolution.psm1). It is Claude-only module code; Codex has its own resolution sibling. The porcelain `Branch` field is therefore the portable source for both runtimes.

Fail-closed cases the new leg must respect:

- Listing failure or empty listing: deny (as `Invoke-OrchestrationGateWorktreeList` already records).
- Ambiguous resolution: `Read-OrchestrationGateCheckpoint` already denies before any later leg.
- Any `Get-OrchestrationCommandTarget` unresolved result.
- `Test-OrchestrationCommandTextUnresolvable` true (backslash anywhere, typographic quote, `$` or backtick outside single quotes, `< > # { } , ( ) @` outside quotes). Paths in commands must therefore use forward slashes.
- Chained text: every segment must independently be a recognized cleanup staging invocation (the issue #539 all-segments rule); any other segment, including another implementation pattern such as `pytest`, withholds the leg.
- A segment without `-C`: target is the session root, which qualifies only if the session root itself is the consolidation worktree.
- A matching record that is `Prunable`, detached, or is the first stanza (the main worktree): no match.

Branch constant: `CLEANUP_WT_CONSOLIDATION_BRANCH="documentationandmemories"` in `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_actions_lib.sh` (plain, non-overridable assignment). The consolidation worktree path is `<main worktree>-wt/documentationandmemories` unless `CLEANUP_WT_CONSOLIDATION_PATH` overrides it (`consolidation_worktree_path`). No PowerShell equivalent exists: a search for `documentationandmemories` under `.claude/hooks`, `.claude/lib`, `.codex`, and `tests/scripts` returned no file. The gate must therefore match by branch, not by path, because the path is overridable.

## Q3. Manifest Content Validation and Location

- `CleanupWorktreeManifest.psm1` cannot validate supplied text today. `Test-CleanupWorktreeManifestAuthorizesRemoval` takes only `-WorktreePath` and reads through `Get-CleanupWorktreeManifestContent`; its conditions 1 (parse) and 2 (tool, schema version) are inline. `Find-CleanupWorktreeManifestRemovalRecord` accepts `-Raw` but only locates a removal record. The constants `$script:ExpectedManifestTool`, `$script:ExpectedManifestSchemaVersion`, and `$script:ManifestFreshnessBound` are module-private.
- Codex hooks cannot import `.claude/lib` (stated in the Codex epic-scope header), so a text validator usable by both preimplementation gates must live in a hook-level file, with its literals pinned equal to the module constants by a test (precedent: the reason-code literals in HookTargetWorktree.psm1 and the Codex epic-scope sibling).
- Payload availability: the Claude Write `tool_input` carries `content`; an Edit carries only `old_string`/`new_string`. The Codex entry tail currently drops `content` (Q1).
- Edit treatment: an Edit of the manifest cannot be validated without reading the file and applying the edit. Recommendation: Edit (and Codex `apply_patch` Update, Delete, or Move) of the manifest stays implementation and stays denied without a checkpoint. The manifest is written whole with Write.
- Location: `Get-CleanupWorktreeManifestContent` reads the relative literal `artifacts/orchestration/cleanup-worktrees-manifest.json` against the hook process location, which is the session root for both removal gates; `--preserve` reads the same relative path against the script's working directory unless `CLEANUP_WT_MANIFEST_PATH` is set (`cleanup_worktrees_preserve_lib.sh`). The manifest must therefore be at the session root (the main checkout where the skill runs). A manifest written in another worktree is never read by either gate; the Write leg should admit only the session-root spelling.
- Checkpoint dependency of the removal gates: none. In `Get-ParallelWorktreeRemovalTargetDenial` and `Get-EpicWorktreeRemovalTargetDenial`, an absent checkpoint yields a `NoTarget` read with `Checkpoint = $null`; only `Ambiguous` denies early; `Test-CleanupManifestCheckpointCoversPath` returns `$false` for a `$null` checkpoint; the manifest branch is then evaluated. A manifest-authorized `SAFE_TO_DELETE` removal (branch state `NOT_MERGED` or `HAS_UNIQUE_RESIDUALS`, verdict in the three authorized members) is reachable with no `orchestrator-state.json` once the manifest exists. Existing coverage: `CleanupWorktreeManifestGateMatrix.Tests.ps1` (allow and deny matrices for both gates) and `enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1`. Both gates are registered on the Bash matcher and both must allow; both have the branch.

## Q4. Scratch Writes Outside Every Registered Worktree

Current behavior: `Test-ImplementationPath` classifies by extension (`py ps1 psm1 ts tsx js jsx cs json yml yaml`) regardless of location. `Read-OrchestrationGateCheckpoint` then calls `Resolve-OrchestrationGateTarget`, whose `Resolve-HookTargetWorktree` call falls back to the session root for an absolute path in no registered worktree (`Source = 'SessionRoot'`). The session root's checkpoint is read; absent, the call is denied.

Batch-budget behavior for comparison (`.claude/hooks/enforce-powershell-batch-budget.ps1`, `Invoke-PowerShellBatchBudgetHook` and `Test-PowerShellBatchBudgetPathInRoot`): the same resolver falls back to the session root, and the containment test discards the absolute path because it is not under that root, so the write is allowed with no slot consumed. Codex has no containment filter, so a Codex scratch write counts against the session root (execution-environment brief, Batch Budget).

Narrowest safe rule (allow-side only, evaluated only where today's code would deny):

1. The call is a Write or Edit path leg (not a command), with an absolute, local path: no match for `$script:OrchestrationTargetNonLocalPattern` (UNC, device, URI, drive-relative, `~`, surrounding whitespace) and no `.` or `..` segment.
2. The worktree listing succeeded with at least one record, and `Get-HookTargetWorktreeEnclosingRoot` returns `$null` for the path over all records, including prunable ones.
3. The path is not under the session root.
4. The path is under the operating-system temporary root, read through an injectable seam (proposed `Get-OrchestrationGateTemporaryRoot`, default `[System.IO.Path]::GetTempPath()`), compared after normalization with OrdinalIgnoreCase.

Rationale for condition 4: HookTargetWorktree documents that an 8.3 short-name spelling of a worktree path matches no registered worktree. Without condition 4, a worktree file spelled in short-name form would be exempt. The session scratchpad is under the temporary root, and registered worktrees are not. This rule applies to every session, not only cleanup runs, because no signal identifies a cleanup session; it does not relax any path inside the repository or any worktree. The spelling agreement between `GetTempPath()` and the scratchpad path needs a live check (Open Questions).

## Q5. PR-Author Consolidation Readiness

Head branch: `Resolve-PrAuthorWorktreeTarget` reads `--head`, `--branch`, or a `branch:` label through `Find-WorktreeResolutionBranchSignal`; with no canonical issue line it calls `Resolve-HookTargetWorktree -CommandBranch`, which selects the registered worktree whose porcelain branch equals the value (OrdinalIgnoreCase) and maps it through `ConvertFrom-PrAuthorHookTargetResult`. The current-branch fallback (`Resolve-PrAuthorCurrentBranchTarget`) runs only when the command carries no signal. Recommendation: the cleanup exemption requires an explicit `--head` whose value is ordinal-equal to `documentationandmemories`, and does not use the current-branch fallback. With `--head`, the resolved root is the consolidation worktree (`OtherWorktree` from a main-checkout session), so `RelativeBodyAllowed` is false and the body path must be absolute, as `.claude/skills/pr-author/SKILL.md` (Coordinator-Session Topology) already instructs.

Manifest location for the PR leg: the hook process location (session root), read through `Get-CleanupWorktreeManifestContent`. An isolated pr-author agent would not see it and would be denied (fail closed); the pr-author skill already requires a non-isolated delegation in this topology.

run_id: nothing on the PR side carries a `run_id`. The command carries `--head`, `--base`, `--body-file`; the receipt schema (`skill`, `pr_body_path`, `number`, `sha256`, `context_summary_path`, `created_at`) has no run identifier; `<N>` is an arbitrary run-scoped number for a cleanup run (skill step 4). Minimal alternative: do not match `run_id`; require a fresh, valid manifest (tool, schema version, `generated_at` parseable, not in the future, within 24 hours, `run_id` a non-empty string) plus the branch and diff conditions. The diff allowlist, not the run identifier, is the control that bounds what the PR can carry. An optional binding (a `Cleanup-Run-Id: <run_id>` line in the hash-verified body) is listed in Open Questions as an owner decision.

Receipt verifier dependency: `Test-PrAuthorReceiptVerification` takes a mandatory `-CheckpointPath` string, but `Get-PrAuthorTargetCheckpointResolution` composes it for any resolved root whether or not the file exists, and check 6 (`Test-EpicBaseBranchOverride`) returns `$null` when `Get-PrAuthorCheckpointContent` returns `$null`. Checks 1 to 5 read only the body, receipt, and summary beneath the artifact root. The verifier therefore does not require a checkpoint; it already runs without one for the issue #901 docs-only path. `PR_CONTEXT_MISSING` still requires `artifacts/pr_context.summary.txt` beneath the consolidation worktree (Open Questions).

Placement constraint: `.claude/hooks/enforce-pr-author-skill-helpers.ps1` has 499 lines and is listed in `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` (`keeps every changed file within the line cap`, at most 500). The edit there must be line-neutral: replace the `Get-PrAuthorDocsOnlyExemption` call in `Get-PrAuthorBypassReason` with a wrapper of the same signature, defined in a new sibling dot-sourced from `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` (224 lines). The wrapper evaluates the docs-only exemption first, unchanged, then the cleanup exemption, and returns a combined reason on failure.

Proposed cleanup exemption conditions, first failure returns its sub-code, all appended to `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`:

- K1 structural `gh pr create` (an edit is not exempt, matching E1).
- K2 no checkpoint at the resolved path (`Test-PrAuthorDocsOnlyCheckpointPresence`).
- K3 explicit `--head` ordinal-equal to `documentationandmemories`.
- K4 exactly one explicit `--base`, equal to `main`, with no base or repository override (`Get-PrAuthorDocsOnlyBaseName`).
- K5 fresh, valid manifest at the session root (Q3 header plus freshness).
- K6 `refs/remotes/origin/main` resolves, `git diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <commit>...HEAD` in the resolved root exits 0, ends with NUL, lists at least one path, and every path is on the allowlist (Q6). Git runs only through `Invoke-PrAuthorDocsOnlyGitExe`; names are split with `ConvertFrom-DocsOnlyNameList`.

The model-routing gate needs a matching allow for `subagent_type = pr-author` only: checkpoint `$null` at the resolved worktree, prompt `branch:` label ordinal-equal to the constant, and K5. `enforce-model-routing-receipt.ps1` has 352 lines.

## Q6. Allowlist Definition

Recommendation: exactly two repository-relative prefixes, ordinal and case-sensitive, applied to every staged, committed, or diffed path and to the Write/Edit leg inside the consolidation worktree: `docs/` and `.claude/agent-memory/`. Do not admit `**/*.md` elsewhere. Operands must match the plain allowlist `A-Z a-z 0-9 . _ / -`, be relative, and carry no `..` segment (the `Test-ExemptOrchestrationOperand` rule).

Rationale:

- `**/*.md` would admit `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/*.md`, `.claude/rules/*.md`, `.claude/skills/**/SKILL.md`, and `.claude/agents/*.md`. `CLAUDE.md` names the `.github` instruction files as canonical policy that is not to be modified, and the `.claude` customization files are mirrored into the bundle and pinned by `test_push_down_claude_resource_contracts.py`, so a consolidation PR editing them without the mirror would fail CI, and would bypass the orchestrator-state preflight for a policy change.
- `.claude/agent-memory/**` is exempt from the bundle mirror assertion (docstring of `test_push_down_claude_resource_contracts.py`), so it carries no mirror obligation.
- `.claude/agent-memory` is listed in this repository's `.gitignore`. `git add -- <ignored path>` fails without `-f`, and both the preserve library (`cleanup_worktrees_preserve_lib.sh` states it never passes `-f`) and the proposed gate leg (no `-f`) keep it that way. In this repository the agent-memory prefix therefore admits only already-tracked files; it is kept for consumer repositories that receive these hooks through push-down. Whether any agent-memory file is tracked here needs `git ls-files` (Open Questions).
- In the Write/Edit leg only, additionally admit `artifacts/pr_body_<digits>.receipt.json` beneath the consolidation worktree, so the pr-author receipt write (Summary item 2) is reachable. `artifacts/` is gitignored and never enters the staging allowlist.

## Q7. Tests, Mirrors, Manifests, Contract Tests, and Line Counts

Production files (current physical lines; tier flag):

| File | Lines | Tier | Pinned cap test |
|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 471 | under 500 | none found |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 491 | under 500, 9 lines headroom | `legacy-codex-hook-contracts.Tests.ps1` (at most 500, repo and bundle) |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (and Codex twin) | 470 | under 500 | helpers Parity suite (at most 500, four copies); recommended unchanged |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (and Codex twin) | 433 | under 500 | targets Parity suite; recommended unchanged |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 387 | under 500 | recommended unchanged |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 447 | under 500 | Codex epic-scope suite (at most 500); recommended unchanged |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 499 | at 500 guidance | `session-root-reads-850.Constraints.Tests.ps1` (at most 500); edit must be line-neutral |
| `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | 224 | under 500 | none |
| `.claude/hooks/enforce-pr-author-skill.ps1` | 359 | under 500 | session-root list; recommended unchanged |
| `.claude/hooks/hook-docs-only-diff.ps1` (and Codex twin) | 497 | at 500 guidance | recommended unchanged |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 352 | under 500 | none found |
| `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | 442 | under 500 | recommended unchanged |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 467 | under 500 | session-root list; unchanged |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 469 | under 500 | session-root list; unchanged |
| `.codex/hooks/codex-pretooluse-file-mapping.ps1` | 474 | under 500 | legacy-codex-hook-contracts; recommended unchanged |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | 583 | Markdown, exempt | none |
| `.claude/skills/execution-environment/SKILL.md` | 150 | Markdown, exempt | byte-identity across six copies |

Existing Pester suites (physical lines; flag at or above 500):

- Claude preimplementation gate: `enforce-orchestration-preimplementation-gate.Tests.ps1` (473), `.TargetWorktree.Tests.ps1` (423), `.CommandExemption.Tests.ps1` (498, do not extend), `.TriggerScoping.Tests.ps1` (344), `.WorktreeResolution.Tests.ps1` (286), `.OperandResolution.Tests.ps1` (255), `.Parity.Tests.ps1` (206) with `.Parity.Cases.ps1` (183), `-absolute-paths.Tests.ps1` (235), `-classifier.Tests.ps1` (166), `-helpers.Parity.Tests.ps1` (55), `-targets.Parity.Tests.ps1` (65), `-mode-resolution.Tests.ps1` (497, do not extend).
- Codex preimplementation gate: `enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1` (461), `-trigger-scoping.Tests.ps1` (357), `-command-exemption.Tests.ps1` (271), `codex-preimplementation-gate-absolute-paths.Tests.ps1` (249), `-epic-scope.Tests.ps1` (493, do not extend), `legacy-codex-hook-contracts.Tests.ps1` (506, above 500 guidance; extend only the `SharedModuleNames` list).
- PR-author gate: `enforce-pr-author-skill.Tests.ps1` (469), `.DocsOnly.Tests.ps1` (243), `.DocsOnly.Decision.Tests.ps1` (163), `.DocsOnly.Exemption.Tests.ps1` (261), `.OrchestratorStatePreflight.Tests.ps1` (137), `.TargetResolution.Tests.ps1` (304), `.WorktreeResolution.Tests.ps1` (431), `.ItemArtifactRoot.Tests.ps1` (353), `.CurrentBranch.Tests.ps1` (253), `session-root-reads-850.Constraints.Tests.ps1` (118).
- Model-routing gate: `enforce-model-routing-receipt.Tests.ps1` (161), `.WorktreeResolution.Tests.ps1` (406), `.AuthorAsserted.Tests.ps1` (291), `.EpicScope.Tests.ps1` (162).
- Manifest and removal: `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1` (209), `CleanupWorktreeManifestGateMatrix.Tests.ps1` (391), `enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1` (95), `enforce-parallel-worktree-removal-gate.Tests.ps1` (491).
- Resolver and docs-only (unchanged; regression only): `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1` (232), `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1` (158), `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` (328), `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` (244).

Bundled mirror paths:

- Claude: `extensions/drm-copilot/resources/claude-customizations/<same .claude path>` for every changed or new `.claude/hooks/*`, `.claude/lib/*`, and `.claude/skills/cleanup-merged-worktrees/SKILL.md`.
- Codex: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/<file>`.
- Execution-environment brief, six copies: `.claude/skills/`, `.agents/skills/`, `.github/skills/` (`execution-environment/SKILL.md`), and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/...`, `.../codex-and-agents-customizations/.agents/skills/...`, `.../customizations/.github/skills/...`.

Pack manifests: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists the preimplementation-gate family, the PR-author family, `hook-docs-only-diff.ps1`, `CleanupWorktreeManifest.psm1`, `HookTargetWorktree.psm1`, and the cleanup skill files; each new `.claude` file is added there. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` lists the Codex gate family; the brief states it is generated by `scripts/dev_tools/generate_codex_agent_variants.py` (module form, `--check`), so new Codex files enter it through the generator.

Contract tests to keep green (execution-environment brief, `## Contract Tests That Pin Mirrored Files`): `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` (every `$PSScriptRoot` dot-source of a manifested file must be manifested), the Codex generator `--check`, `test_push_down_issue_824_follow_ups.py` (pushed skills name no consuming product), `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` (guarded dot-source pattern in hooks), and `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`. Additionally: the helpers and targets Parity suites, `legacy-codex-hook-contracts.Tests.ps1`, and `session-root-reads-850.Constraints.Tests.ps1`.

## Q8. End-to-End Test Feasibility

The full workflow cannot run in a unit test: it needs real worktrees, git, gh, and the MCP tool, and temporary files are prohibited. The hook decisions, which are the subject of this issue, can be composed in one Pester suite over one in-memory scenario:

- Scenario data defined once at file scope: a porcelain listing text (main worktree on `main`, consolidation worktree on `documentationandmemories`, one `SAFE_TO_DELETE` worktree), a manifest text, a staged-path list, a branch diff list, and body and receipt bytes.
- One `Context` per workflow step, each loading only the hook under test in its own `BeforeAll` (Pester 5 scopes dot-sourced functions to the block, which avoids name collisions such as the shared `$script:CleanupWorktreeManifestPath`), each with `-CheckpointRaw` absent and every checkpoint seam returning nothing:
  1. report, preserve, and apply: the command texts `bash .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`, `... --preserve`, `... --apply` are allowed by the preimplementation gate (no implementation classification) and by both removal gates (no `git worktree remove` invocation);
  2. manifest Write: allowed; wrong `tool` and wrong `schema_version` denied; Edit denied;
  3. scratch `.ps1` Write under the injected temporary root: allowed; the same file name inside a registered worktree: denied;
  4. `git -C <consolidation root> add -- docs/...` and `... -- .claude/agent-memory/...`: allowed; a `scripts/...` operand, `-A`, or a missing `-C`: denied;
  5. `git -C <consolidation root> commit -F <file>`: allowed when the mocked staged list is all allowlisted; denied when it holds one non-allowlisted path;
  6. `git push -u origin documentationandmemories`: allowed;
  7. `Agent(pr-author)` with `branch: documentationandmemories`: allowed by the model-routing gate with the manifest present; denied with the manifest absent;
  8. pr-author receipt Write beneath the consolidation worktree: allowed;
  9. `gh pr create --head documentationandmemories --base main --body-file <abs>`: allowed with receipt seams satisfied; denied for a non-consolidation `--head` with no checkpoint (preflight still mandatory);
  10. `git worktree remove <SAFE_TO_DELETE path>`: allowed by both removal gates through the mocked `Get-CleanupWorktreeManifestContent` and `Get-CleanupWorktreeManifestUtcNow`.
- Seams to mock: `Get-OrchestrationGateWorktreeList`, `Get-CheckpointContent`, the proposed temporary-root and staged-index seams, `Get-CleanupWorktreeManifestContent` and `Get-CleanupWorktreeManifestUtcNow` (`-ModuleName CleanupWorktreeManifest`), `Resolve-PrAuthorWorktreeTarget`, `Get-PrContextArtifactExistence`, `Invoke-OrchestratorStatePreflight`, `Invoke-PrAuthorDocsOnlyGitExe`, `Get-PrBodyFileBytes`, `Get-PrAuthorReceiptContent`, `Get-PrContextSummaryLastWriteUtc`, `Get-PrAuthorCheckpointContent`, `Resolve-ModelRoutingWorktreeTarget`, `Get-ModelRoutingCheckpoint`, and the removal gates' run-target and checkpoint seams. Register the baseline through `Register-EpicStateBaselineMock` (`EpicStateIsolation.Baseline.Helpers.ps1`) as the existing gate suites do.
- Bats: suites exist for the script (`tests/shell/test_cleanup_worktrees_*.bats`, including `_preserve.bats`, `_consolidation.bats`, `_deletion.bats`), driven through the `CLEANUP_WT_GIT_BIN` stub. The recommended design does not change the bash scripts, so no bats suite needs extending; those suites remain the coverage for the script-internal steps.
- A live run is still needed after merge, because isolated subagents execute `main`'s hook copies (brief, Hook Execution Context). It is a manual validation step, not CI.

## Candidate Approaches

- A. Recommended: allow-side cleanup legs placed at the existing final deny points, backed by one pure, byte-identical shared file (`hook-cleanup-context.ps1`, four copies) plus a preimplementation-gate sibling and a PR-author sibling; no change to the helpers, targets, epic-scope, resolver, docs-only diff, manifest module, or bash scripts. Advantages: fail-closed defaults unchanged; every new decision is reachable only where today's code denies; fits the pinned line caps; Codex parity is mechanical for the preimplementation gate. Limitation: the branch constant and manifest literals are restated in PowerShell and pinned by tests.
- B. Rejected: widen existing predicates (add trees to `$script:OrchestrationBookkeepingTrees`, widen `Get-DocsOnlyPathViolation`). This widens unrelated behavior (the epic merge gate's docs-only merge exemption on both runtimes, and the issue #539 exemption for every session) and breaks the "helpers byte-untouched" contract the gate file header records.
- C. Rejected: have the cleanup skill write a synthetic `orchestrator-state.json`. The skill's Prohibited Shortcuts forbid writing a checkpoint to satisfy a gate, and it would mark a non-feature run as a feature run.
- D. Rejected: a separate PowerShell CLI for the skill's step 4 readiness check. It adds a launcher that the worktree isolation guard refuses (`pwsh` text) and duplicates the hook; the hook already enforces the check at `gh pr create`.

## Behavior Semantics

- Ordering: each new leg runs only after the existing logic would deny. Preimplementation gate: after `Test-OrchestrationReady` fails, immediately before the final `PREIMPLEMENTATION_GATE_BLOCKED` return; the epic-scope decision, the delegation-mode branch, and the unresolved-target deny of `Read-OrchestrationGateCheckpoint` all precede it unchanged. PR-author gate: after `Invoke-OrchestratorStatePreflight` errors and after the docs-only exemption fails. Model-routing gate: immediately before its final deny.
- Pure prefilters before any process: the manifest leg compares the path literal and validates content with no listing; the consolidation Write leg first requires a `/docs/`, `/.claude/agent-memory/`, or `/artifacts/pr_body_<digits>.receipt.json` tail; the command leg first requires every segment to be `git` `add` or `commit` with a `-C` value. Only then is the listing seam called, and the staged-index git seam only after the branch matches.
- Commit option model for the cleanup leg: accept `-m`, `--message`, `-F`, `--file`, `--trailer` (with values); deny every other option, including `-a`, `--all`, `--amend`, `--pathspec-from-file`, `-C`, `-c`; require zero pathspec operands, so the staged index is the single source of what is committed.
- Add option model: no option other than `--`; at least one operand; every operand allowlisted (Q6).
- Staged index read: `git -C <root> diff --cached --name-only -z --no-renames --no-color --no-ext-diff --no-relative` through `Invoke-DocsOnlyGitExe` (bounded, never throws), split by `ConvertFrom-DocsOnlyNameList`; empty, non-NUL-terminated, failed, or any non-allowlisted path denies. This is required because `--preserve` stages files through script-internal git calls that no hook sees.
- Deny wording: unchanged `PREIMPLEMENTATION_GATE_BLOCKED` text when the cleanup leg does not apply; a cleanup-specific sub-code may be appended only when the target is the consolidation worktree, so existing reason-matching tests keep their expected strings.

## Pre-Mortem

- Review checklists: a reviewer can find a leg that allows outside the cleanup context (for example a commit in a feature worktree with no checkpoint). Mitigation: each leg's tests include the same command or path against a non-consolidation worktree, against the session root, and with a ready checkpoint absent, and assert the unchanged deny text; the plan maps each issue acceptance item to a named test.
- Coverage: new PowerShell production files must reach 85% line coverage in `artifacts/pester/powershell-coverage.xml`, and the coverage population comes from `config/poshqc-coverage.json` through `Invoke-PoshQCTest`. Mitigation: confirm the new files fall under a configured coverage root (add them if not), test every fail-closed branch of the pure functions directly, and read per-file figures from the XML rather than from PoshQC MCP results, which carry no output.
- Mirror parity: every changed or new `.claude` and `.codex` file has a bundle copy; four copies of `hook-cleanup-context.ps1` and two of each gate sibling must be byte-identical; the execution-environment brief changes in six copies; new files enter the Claude `core.json` by hand and the Codex `core.json` through the generator. Mitigation: a dedicated parity task, the push-down contract tests, the dependency-closure test, the generator `--check`, a new parity suite for `hook-cleanup-context.ps1`, and a test pinning its literals equal to the `CleanupWorktreeManifest.psm1` constants and to `CLEANUP_WT_CONSOLIDATION_BRANCH`.
- File size: `enforce-pr-author-skill-helpers.ps1` (499) is capped at 500 by `session-root-reads-850.Constraints.Tests.ps1`, the Codex gate (491) by `legacy-codex-hook-contracts.Tests.ps1`, and `.CommandExemption.Tests.ps1` (498), `-mode-resolution.Tests.ps1` (497), and the Codex `-epic-scope.Tests.ps1` (493) are near 500. Mitigation: line-neutral helpers edit, at most a guarded dot-source and a short call in each gate file, all new logic and tests in new files, and a physical line count with `@(Get-Content).Count` before and after each edit.
- Test isolation: the new legs call the listing seam and possibly a staged-index seam from paths that existing suites exercise with an injected `-CheckpointRaw`, where the listing is not called today; an unmocked call starts a real `git` process and depends on the machine's worktrees. Mitigation: pure prefilters before any process, mock `Get-OrchestrationGateWorktreeList` and the new seams in every new suite and add them to the shared baseline helper, run the existing preimplementation suites unchanged to show they do not reach a process, and run the seeded shuffled, single-process, and concurrent-shard Pester checks from the brief.
- CI-only behavior: the Linux hook-suite job runs `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` on a case-sensitive file system; a fixture with a drive letter or backslash, or a temporary-root fixture that assumes a Windows spelling, can fail only there. Mitigation: forward-slash, POSIX-rooted fixtures, the temporary root supplied through its seam in every test, no dependency on gitignored `artifacts/` state, and no `origin/main` reference in tests.
- Evidence: the acceptance item "end-to-end with no shell-escape steps" can be read as requiring a live run that CI cannot provide, and the two unreproduced blockers could be missed. Mitigation: record the composed Pester run as the regression evidence, extend the reproduction script to the model-routing and receipt-write cases before implementation (fail-before) and after (pass-after) under `evidence/regression-testing/`, and record the post-merge live run as a separate manual validation artifact.

## Numeric Derivation Evidence

No numeric count, enumeration, or population is proposed for a `spec.md` acceptance criterion in this research. Line counts above are measurements for planning, not acceptance assertions.

## Recommended Design

1. New shared pure file `hook-cleanup-context.ps1` at `.claude/hooks/` and `.codex/hooks/` (plus both bundles, byte-identical): the branch constant `documentationandmemories`; the manifest relative path; `Test-CleanupManifestText -Raw [-UtcNow]` (JSON object, `tool` ordinal-equal to `cleanup-merged-worktrees`, integer `schema_version` 1, and, when `-UtcNow` is supplied, `generated_at` parseable, not future, within 24 hours, and `run_id` non-empty); `Test-CleanupConsolidationRelativePath` (the Q6 allowlist); `Find-CleanupConsolidationRecord` (porcelain records plus a root, returning the non-main, non-prunable record whose `Branch` is ordinal-equal to the constant); `Test-CleanupScratchPath` (the Q4 rule, taking roots, session root, and temporary root as inputs). Functions only, no I/O.
2. New sibling `enforce-orchestration-preimplementation-gate-cleanup.ps1` (Claude and Codex, byte-identical, plus bundles): `Test-OrchestrationCleanupContextAllowed -FilePath -Content -Command`, composing the four legs (manifest Write, scratch Write, consolidation Write/Edit including the receipt literal, consolidation `git add`/`git commit`) over `Get-OrchestrationGateWorktreeList`, `Get-OrchestrationCommandTarget`, the helpers parser, a temporary-root seam, and a staged-index seam built on `Invoke-DocsOnlyGitExe`. For Codex `apply_patch`, accept only a patch whose single marker is `*** Add File:` naming the manifest, with content taken from its `+` lines. Each gate file gains one guarded dot-source and one call before its final deny; the Codex entry tail forwards `content` for Write records.
3. New sibling `.claude/hooks/enforce-pr-author-skill.cleanup.ps1`, dot-sourced from the docs-only sibling: the wrapper (docs-only, then K1 to K6) used by a line-neutral edit of `Get-PrAuthorBypassReason`. Receipt checks are unchanged and still run after the exemption.
4. `enforce-model-routing-receipt.ps1`: one cleanup allow for `pr-author` before the final deny, using the manifest seam of `CleanupWorktreeManifest.psm1` and `hook-cleanup-context.ps1`.
5. No change to `CleanupWorktreeManifest.psm1`, either removal gate, the resolver, the helpers or targets files, `hook-docs-only-diff.ps1`, or the bash scripts; the removal step already works once the manifest can be written.
6. Skill text (`.claude/skills/cleanup-merged-worktrees/SKILL.md` and bundle): steps 3 and 4 name the cleanup context (manifest at the session root, `git -C <consolidation root>` staging of allowlisted paths with `git commit -F`, explicit `--head documentationandmemories --base main`, absolute body path, non-isolated pr-author delegation carrying `branch: documentationandmemories`), remove the `--require-pr-creation-ready` requirement for consolidation PRs, and state that the hooks perform the cleanup readiness check; the Sanctioned Removal Manifest section states the session-root location and that Edit of the manifest is not supported without a checkpoint.
7. Execution-environment brief, six copies: one bullet under Hook Execution Context describing the cleanup legs of the preimplementation, PR-authoring, and model-routing gates, and one under Batch Budget or Hook Execution Context stating the scratch rule.
8. Codex scope: the preimplementation-gate legs are in parity. The PR-author, model-routing, and manifest-removal changes have no Codex twin, because Codex has no such gates and no cleanup skill; this is recorded as a non-goal in the spec rather than as a parity gap.

## Open Questions

1. Confirm by reproduction (orchestrator, extending `SCRATCH/issue-1026-repro.sh`) that `Agent(pr-author)` with `branch: documentationandmemories` is denied by `enforce-model-routing-receipt.ps1`, and that a Write of `<consolidation worktree>/artifacts/pr_body_<N>.receipt.json` is denied by the preimplementation gate, with no checkpoint. Both are inferred from code only.
2. Where `mcp__drm-copilot__collect_pr_context` writes `artifacts/pr_context.summary.txt` when the session root is the main checkout and the PR head is the consolidation worktree. `PR_CONTEXT_MISSING` requires the summary beneath the consolidation worktree; the tool's target-directory behavior was not found in the tree searched.
3. Whether `[System.IO.Path]::GetTempPath()` on the host returns the same spelling (short-name or long-name) as the session scratchpad prefix. A live `pwsh` check by the orchestrator decides whether condition 4 of Q4 needs a second accepted spelling.
4. Owner decision on `run_id` binding: default recommended here is no `run_id` match (no PR-side carrier exists); the alternative is a required `Cleanup-Run-Id: <run_id>` line in the hash-verified PR body, which also changes the pr-author skill and agent text.
5. Whether any file under `.claude/agent-memory/` is tracked on `main` (`git ls-files .claude/agent-memory`). The directory is gitignored, so in this repository the agent-memory allowlist prefix is effective only for tracked files.
6. Whether `--preserve` runs on the operator host: it reads the manifest through `jq` (`CLEANUP_WT_JQ_BIN`), and `jq` availability on the Windows host was not verified. This is outside the hook scope but affects the end-to-end acceptance item.
7. Owner confirmation that the Codex non-goals in Recommended Design item 8 are acceptable under the parity constraint.
