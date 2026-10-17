# Phase 5 ALL-SCOPED run (issue #732)

Timestamp: 2026-10-09T04-15
Task: [P5-T6]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/scoped-task.sh (R-SCOPED over 46 files)
EXIT_CODE: 0

## Output

```text
FILES: 46
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
RUN_FILE: tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1
RUN_FILE: tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1
RUN_FILE: tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1
RUN_FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1
RUN_FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1
RUN_FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1
RUN_FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1
RUN_FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1
RUN_FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1
RUN_FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1
PassedCount: 1594
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope allows git add of a production path while a merge is in progress
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies git add of a production path when no merge is in progress and names the epic checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies git add of a production path when epic_feature_folder is missing and names it
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies git add of a production path when epic_manifest_path is missing and names it
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies git add of a production path when features is missing and names it
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).a checkpoint missing route_id is not epic scope and the command leg denies through the single-feature path
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).a checkpoint missing integration_branch is not epic scope and the command leg denies through the single-feature path
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope resolves the -C selector worktree for the command leg
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope allows an Edit of a production path while a merge is in progress
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies a Write of a production path when no merge is in progress
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).without an epic checkpoint the command leg returns the unchanged single-feature decision and reason
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).without an epic checkpoint the path leg returns the unchanged single-feature decision and reason
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).an epic checkpoint whose integration_branch differs from HEAD leaves the command leg on the single-feature path
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies a -C selector worktree outside the session-root epic scope as target-mixed (issue #738)
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #663 the relocated epic read seam returns an empty string when the epic checkpoint file is absent
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #663 the relocated epic read seam returns the raw epic checkpoint text when the file exists
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #663 the relocated parallel read seam returns an empty string when the parallel checkpoint file is absent
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #663 the relocated parallel read seam returns the raw parallel checkpoint text when the file exists
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #690 the relocated per-feature read seam returns an empty string when the checkpoint file is absent
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #690 the relocated per-feature read seam returns the raw checkpoint text when the file exists
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #663 the epic-scope decision returns null without resolving when the call carries neither a command nor a path
PASSED: preimplementation gate path leg.O1 admits a Write inside another worktree whose checkpoint is ready, reading that checkpoint
PASSED: preimplementation gate path leg.O2 denies a Write inside another worktree whose checkpoint is not ready
PASSED: preimplementation gate path leg.O3 denies a Write inside another worktree whose checkpoint is absent
PASSED: preimplementation gate path leg.O6 decides a Write inside the session worktree exactly as the injected checkpoint
PASSED: preimplementation gate path leg.O9 denies a Write whose target is ambiguous, naming the reason code and the detail
PASSED: preimplementation gate command leg.O4 reads the checkpoint of the worktree a git -C selector names
PASSED: preimplementation gate command leg.O5 reads the session worktree checkpoint for a command with no selector
PASSED: preimplementation gate import failure.O7 denies naming WorktreeRunResolution.psm1 when that import failed, and the entry point exits 0
PASSED: preimplementation gate import failure.O8 denies naming WorktreeItemResolution.psm1 when that import failed
PASSED: preimplementation gate read literals (parse-tree scan).O10 passes no relative checkpoint literal to Test-Path or Get-Content, and every read seam takes a mandatory Path
PASSED: preimplementation gate epic-mode resolution.R1 admits the reproduction by reading the epic checkpoint under the other worktree
PASSED: preimplementation gate epic-mode resolution.R2 denies the reproduction with TARGET_WORKTREE_NOT_DERIVABLE when no worktree holds the epic checkpoint
PASSED: preimplementation gate epic-mode resolution.R3 denies an ambiguous epic target with TARGET_WORKTREE_AMBIGUOUS
PASSED: preimplementation gate epic-mode resolution.R11 decides an epic checkpoint at the session root exactly as the injected checkpoint
PASSED: preimplementation gate epic-mode resolution.R12 reads the worktree that has the integration branch checked out over a stale session-root copy
PASSED: preimplementation gate parallel-mode resolution.R4 reads the parallel checkpoint beneath another worktree and admits a ready run
PASSED: preimplementation gate parallel-mode resolution.R5 denies a parallel kickoff without parallel_slug with TARGET_WORKTREE_NOT_DERIVABLE
PASSED: preimplementation gate parallel-mode resolution.R6 denies an ambiguous parallel target
PASSED: preimplementation gate single-feature delegation resolution.R7 reads an implementation agent's checkpoint beneath its own worktree
PASSED: preimplementation gate single-feature delegation resolution.R8 denies an implementation agent delegation that carries neither identity line without enumerating worktrees
PASSED: preimplementation gate single-feature delegation resolution.R9 denies an ambiguous implementation agent target
PASSED: preimplementation gate single-feature delegation resolution.R10 denies a non-mode orchestrator delegation without identity lines
PASSED: preimplementation gate injection precedence.R13 bypasses resolution for a bound non-empty CheckpointRaw
PASSED: preimplementation gate injection precedence.R14 bypasses resolution for a bound empty EpicCheckpointRaw
PASSED: preimplementation gate injection precedence.R15 bypasses resolution for a bound ParallelCheckpointRaw
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope allows the command leg of a production path while a merge is in progress
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope allows the apply_patch leg of a production path while a merge is in progress
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope allows the path leg of a production path while a merge is in progress
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the command leg of a production path when no merge is in progress and names the epic checkpoint
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the apply_patch leg of a production path when no merge is in progress and names the epic checkpoint
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the path leg of a production path when no merge is in progress and names the epic checkpoint
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the command leg when epic_feature_folder is missing and names it and the epic checkpoint
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the command leg when epic_manifest_path is missing and names it and the epic checkpoint
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the command leg when features is missing and names it and the epic checkpoint
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.the epic-scope decision names route_id and the epic checkpoint when the resolved scope carries an invalid route_id
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.the epic-scope decision names epic_feature_folder and the epic checkpoint when the resolved scope carries an invalid epic_feature_folder
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.the epic-scope decision names epic_manifest_path and the epic checkpoint when the resolved scope carries an invalid epic_manifest_path
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.the epic-scope decision names integration_branch and the epic checkpoint when the resolved scope carries an invalid integration_branch
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.the epic-scope decision names features and the epic checkpoint when the resolved scope carries an invalid features
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope decides a -C selector command by the selector worktree HEAD and allows it
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.a -C selector command whose selector HEAD differs is denied as target-mixed when the session-root HEAD matches (issue #738)
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with no epic checkpoint the command leg returns the unchanged single-feature decision and reason
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with no epic checkpoint the apply_patch leg returns the unchanged single-feature decision and reason
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with no epic checkpoint the path leg returns the unchanged single-feature decision and reason
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with an integration_branch that differs from HEAD the command leg returns the unchanged single-feature decision and reason
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with an integration_branch that differs from HEAD the apply_patch leg returns the unchanged single-feature decision and reason
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with an integration_branch that differs from HEAD the path leg returns the unchanged single-feature decision and reason
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with a missing route_id the command leg returns the unchanged single-feature decision and reason
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with a missing route_id the apply_patch leg returns the unchanged single-feature decision and reason
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with a missing route_id the path leg returns the unchanged single-feature decision and reason
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with an empty integration_branch the command leg returns the unchanged single-feature decision and reason
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with an empty integration_branch the apply_patch leg returns the unchanged single-feature decision and reason
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with an empty integration_branch the path leg returns the unchanged single-feature decision and reason
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.without an epic checkpoint the command leg is allowed by a ready single-feature checkpoint
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.without an epic checkpoint the apply_patch leg is allowed by a ready single-feature checkpoint
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.without an epic checkpoint the path leg is allowed by a ready single-feature checkpoint
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.a bookkeeping path operand stays exempt without reading the epic checkpoint
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.a bookkeeping command operand stays exempt without reading the epic checkpoint
PASSED: Codex preimplementation gate epic scope (issue #707).relocated read seams and the no-leg guard.the relocated epic read seam returns an empty string when the epic checkpoint file is absent
PASSED: Codex preimplementation gate epic scope (issue #707).relocated read seams and the no-leg guard.the relocated epic read seam returns the raw epic checkpoint text when the file exists
PASSED: Codex preimplementation gate epic scope (issue #707).relocated read seams and the no-leg guard.the relocated parallel read seam returns an empty string when the parallel checkpoint file is absent
PASSED: Codex preimplementation gate epic scope (issue #707).relocated read seams and the no-leg guard.the relocated parallel read seam returns the raw parallel checkpoint text when the file exists
PASSED: Codex preimplementation gate epic scope (issue #707).relocated read seams and the no-leg guard.the epic-scope decision returns null without resolving when the call carries neither a command nor a path
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope selector.the epic-scope selector returns the selector path for a leading git -C selector
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope selector.the epic-scope selector returns no selector for a command without a selector
PASSED: Codex preimplementation gate epic scope (issue #707).epic-scope selector.the epic-scope selector returns no selector for an unbalanced command line
PASSED: Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.resolves every Codex epic-scope seam name as a function after dot-sourcing the gate
PASSED: Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.keeps enforce-orchestration-preimplementation-gate.ps1 at or under 500 lines in the repository and the bundle
PASSED: Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.keeps enforce-orchestration-preimplementation-gate-epic-scope.ps1 at or under 500 lines in the repository and the bundle
PASSED: Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.keeps enforce-orchestration-preimplementation-gate-epic-resolution.ps1 at or under 500 lines in the repository and the bundle
PASSED: Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.keeps enforce-orchestration-preimplementation-gate.ps1 byte-identical to its bundle copy
PASSED: Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.keeps enforce-orchestration-preimplementation-gate-epic-scope.ps1 byte-identical to its bundle copy
PASSED: Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.keeps enforce-orchestration-preimplementation-gate-epic-resolution.ps1 byte-identical to its bundle copy
PASSED: Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.reports no interpreter invocation in enforce-orchestration-preimplementation-gate.ps1 or its bundle copy
PASSED: Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.reports no interpreter invocation in enforce-orchestration-preimplementation-gate-epic-scope.ps1 or its bundle copy
PASSED: Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.reports no interpreter invocation in enforce-orchestration-preimplementation-gate-epic-resolution.ps1 or its bundle copy
PASSED: Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.keeps enforce-orchestration-preimplementation-gate-epic-scope.ps1 free of interpreter-name tokens and declares the predicate PowerShell-authoritative
PASSED: Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.keeps enforce-orchestration-preimplementation-gate-epic-resolution.ps1 free of interpreter-name tokens and declares the predicate PowerShell-authoritative
PASSED: Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason epic-scope for the session-root HEAD matching integration_branch
PASSED: Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason epic-scope for a -C selector worktree whose HEAD matches integration_branch
PASSED: Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason session-root-unresolved for a session root outside any worktree
PASSED: Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason epic-checkpoint-absent-or-unparseable for an absent epic checkpoint
PASSED: Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason epic-checkpoint-absent-or-unparseable for an unparseable epic checkpoint
PASSED: Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason epic-checkpoint-absent-or-unparseable for an array-shaped epic checkpoint
PASSED: Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason route_id for a route_id other than epic
PASSED: Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason integration_branch for an empty integration_branch
PASSED: Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason selector-unresolved for a -C selector outside any worktree
PASSED: Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason branch-mismatch for an effective HEAD that differs from integration_branch
PASSED: Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason branch-mismatch for a detached HEAD
PASSED: Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.reports MergeInProgress True when the MERGE_HEAD probe returns True
PASSED: Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.reports MergeInProgress False when the MERGE_HEAD probe returns False
PASSED: Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.composes an absolute checkpoint path from the resolved session root
PASSED: Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.consults the -C selector worktree HEAD and not the session-root HEAD when a selector is supplied
PASSED: Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.declares the fixed head-match signature without Text or MatchWorktreeHead parameters
PASSED: Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.returns null checkpoint text when the checkpoint file is absent
PASSED: Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.returns the checkpoint text when the checkpoint file exists
PASSED: Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.reads the HEAD branch of a linked worktree through its gitdir file
PASSED: Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.reads the HEAD branch of a main checkout through its git directory
PASSED: Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.resolves a relative gitdir target against the worktree root
PASSED: Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.returns no HEAD branch for a detached HEAD
PASSED: Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.returns no git directory for a missing git entry
PASSED: Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.returns no git directory for a gitdir file without a gitdir line
PASSED: Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.returns no git directory for a relative worktree root
PASSED: Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.probes MERGE_HEAD in the worktree git directory and reports True
PASSED: Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.probes MERGE_HEAD in the worktree git directory and reports False
PASSED: Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.reports no merge in progress when the worktree has no git directory
PASSED: Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.finds the worktree root by ascending to the first level that carries a git directory
PASSED: Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.finds a linked worktree root whose git entry is a gitdir file
PASSED: Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.returns no worktree root for a relative start path
PASSED: Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.returns no worktree root for an ascent that reaches the filesystem root without a git entry
PASSED: Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.normalises backslashes, repeated separators, a leading dot segment, and a trailing slash
PASSED: Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.returns a null normalised path for blank input
PASSED: Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.rejects a relative worktree root when composing a path
PASSED: Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.returns null from the checkpoint parser for null text
PASSED: Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.returns null from the checkpoint parser for whitespace text
PASSED: Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.returns null from the checkpoint parser for a JSON scalar
PASSED: Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness passes for a ready epic checkpoint while a merge is in progress
PASSED: Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness names checkpoint-absent for a null checkpoint
PASSED: Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness names route_id for a route_id other than epic
PASSED: Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness names epic_feature_folder for a missing epic_feature_folder
PASSED: Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness names epic_manifest_path for an epic_manifest_path outside docs/features/epics/
PASSED: Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness names integration_branch for a missing integration_branch
PASSED: Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness names features for an empty features array
PASSED: Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness names merge-in-progress for no merge in progress
PASSED: Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness reports the earliest failed conjunct when several fail
PASSED: Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness accepts a backslash-separated epic_manifest_path under the epics tree
PASSED: Get-EpicPrCreationReadinessFailure.PR-creation readiness passes when every feature is merged or worktree_removed
PASSED: Get-EpicPrCreationReadinessFailure.PR-creation readiness names checkpoint-absent for a null checkpoint
PASSED: Get-EpicPrCreationReadinessFailure.PR-creation readiness names route_id for a route_id other than epic
PASSED: Get-EpicPrCreationReadinessFailure.PR-creation readiness names integration_branch for a --head branch that differs from integration_branch
PASSED: Get-EpicPrCreationReadinessFailure.PR-creation readiness names features for an empty features array
PASSED: Get-EpicPrCreationReadinessFailure.PR-creation readiness names merge_status for a feature whose merge_status is pr_open
PASSED: Get-EpicCommandLegReadinessFailure.command-leg readiness passes for a ready epic checkpoint while a merge is in progress
PASSED: Get-EpicCommandLegReadinessFailure.command-leg readiness names checkpoint-absent for a null checkpoint
PASSED: Get-EpicCommandLegReadinessFailure.command-leg readiness names route_id for a route_id other than epic
PASSED: Get-EpicCommandLegReadinessFailure.command-leg readiness names epic_feature_folder for a missing epic_feature_folder
PASSED: Get-EpicCommandLegReadinessFailure.command-leg readiness names epic_manifest_path for an epic_manifest_path outside docs/features/epics/
PASSED: Get-EpicCommandLegReadinessFailure.command-leg readiness names integration_branch for a missing integration_branch
PASSED: Get-EpicCommandLegReadinessFailure.command-leg readiness names features for an empty features array
PASSED: Get-EpicCommandLegReadinessFailure.command-leg readiness names merge-in-progress for no merge in progress
PASSED: Resolve-EpicScopeCheckpoint run-target location.N1 resolves a head-matched command leg to the epic checkpoint held only in another worktree
PASSED: Resolve-EpicScopeCheckpoint run-target location.N2 is not epic scope when no worktree records the branch
PASSED: Resolve-EpicScopeCheckpoint run-target location.N3 is not epic scope with target-worktree-ambiguous when two unresolvable worktrees record the branch
PASSED: Resolve-EpicScopeCheckpoint run-target location.N4 reads Get-EpicScopeCheckpointText exactly once with the resolved path
PASSED: Resolve-EpicScopeCheckpoint epic-scope matches.resolves epic scope when the --head branch equals integration_branch
PASSED: Resolve-EpicScopeCheckpoint epic-scope matches.resolves epic scope when a branch: label equals integration_branch
PASSED: Resolve-EpicScopeCheckpoint epic-scope matches.resolves epic scope for a command leg whose -C selector worktree HEAD equals integration_branch
PASSED: Resolve-EpicScopeCheckpoint epic-scope matches.resolves epic scope for a command leg without a selector when the session-root HEAD equals integration_branch
PASSED: Resolve-EpicScopeCheckpoint epic-scope matches.reports a merge in progress for a head-matched command leg when MERGE_HEAD exists
PASSED: Resolve-EpicScopeCheckpoint fail-closed non-matches.is not epic scope when the epic checkpoint is absent
PASSED: Resolve-EpicScopeCheckpoint fail-closed non-matches.is not epic scope when the epic checkpoint is unparseable
PASSED: Resolve-EpicScopeCheckpoint fail-closed non-matches.is not epic scope when route_id is not epic
PASSED: Resolve-EpicScopeCheckpoint fail-closed non-matches.is not epic scope when integration_branch is empty
PASSED: Resolve-EpicScopeCheckpoint fail-closed non-matches.is not epic scope when the branch signal does not equal integration_branch
PASSED: Resolve-EpicScopeCheckpoint fail-closed non-matches.is not epic scope when the worktree HEAD does not equal integration_branch
PASSED: Resolve-EpicScopeCheckpoint fail-closed non-matches.is not epic scope and locates no checkpoint when a head-matched leg has a detached HEAD (issue #690)
PASSED: Resolve-EpicScopeCheckpoint fail-closed non-matches.is not epic scope and reads no checkpoint when there is no branch signal and head matching is off
PASSED: Resolve-EpicScopeCheckpoint fail-closed non-matches.is not epic scope when the session root is not inside a worktree
PASSED: Resolve-EpicScopeCheckpoint checkpoint path composition.returns an absolute checkpoint path composed from the session worktree root
PASSED: Resolve-EpicScopeCheckpoint checkpoint path composition.never takes the checkpoint path from text that names another epic checkpoint
PASSED: Resolve-EpicScopeCheckpoint checkpoint path composition.reads the epic checkpoint through the seam exactly once per resolution
PASSED: EpicScopeResolution read seams.returns null checkpoint text when the checkpoint file is absent
PASSED: EpicScopeResolution read seams.reads the HEAD branch of a linked worktree through its gitdir file
PASSED: EpicScopeResolution read seams.reads the HEAD branch of a main checkout through its git directory
PASSED: EpicScopeResolution read seams.returns no HEAD branch for a detached HEAD
PASSED: EpicScopeResolution read seams.probes MERGE_HEAD in the worktree git directory
PASSED: Resolve-EpicScopeCheckpoint head matching ignores a text branch signal (issue #663 remediation CR-2).a head-matched command leg is not epic scope when the text names integration_branch but the selector HEAD differs
PASSED: Resolve-EpicScopeCheckpoint head matching ignores a text branch signal (issue #663 remediation CR-2).a head-matched command leg probes MERGE_HEAD in the selector worktree when the text names another branch
PASSED: WorktreeItemResolution checkpoint path.returns the repository-relative orchestrator checkpoint path
PASSED: WorktreeItemResolution checkpoint path.matches the default checkpoint path of Invoke-OrchestratorStatePreflight
PASSED: WorktreeItemResolution checkpoint path.composes the absolute checkpoint path under a worktree root
PASSED: WorktreeItemResolution issue signals.reads every distinct issue number from canonical issue lines
PASSED: WorktreeItemResolution issue signals.returns no issue number for text without a canonical issue line
PASSED: WorktreeItemResolution issue signals.normalises string and integer issue-num values
PASSED: WorktreeItemResolution issue signals.rejects zero, none, empty, and non-numeric issue-num values
PASSED: WorktreeItemResolution checkpoint reader.reads the issue number from a worktree checkpoint through the checkpoint text seam
PASSED: WorktreeItemResolution checkpoint reader.returns no issue number for an absent, empty, or unparseable checkpoint
PASSED: WorktreeItemResolution liveness seam.keeps only registered worktrees that still carry a root marker
PASSED: WorktreeItemResolution liveness seam.returns no live worktree when the session path is inside no repository
PASSED: WorktreeItemResolution target resolution.resolves NoTarget without enumerating worktrees when the text carries no identity
PASSED: WorktreeItemResolution target resolution.resolves the single live worktree whose checkpoint records the issue
PASSED: WorktreeItemResolution target resolution.resolves NoTarget when no live worktree records the issue
PASSED: WorktreeItemResolution target resolution.resolves Ambiguous when two live worktrees record the issue
PASSED: WorktreeItemResolution target resolution.breaks a stale-attempt tie with the branch signal
PASSED: WorktreeItemResolution target resolution.resolves Ambiguous when the branch worktree records a different issue
PASSED: WorktreeItemResolution target resolution.resolves Ambiguous when the branch and the issue name different worktrees
PASSED: WorktreeItemResolution target resolution.resolves the branch worktree when its checkpoint records no issue and no other worktree records it
PASSED: WorktreeItemResolution target resolution.resolves Ambiguous when the text names two different issue numbers
PASSED: WorktreeItemResolution target resolution.resolves the branch worktree when only a branch signal is present
PASSED: WorktreeItemResolution target resolution.resolves NoTarget when the branch is checked out in no live worktree
PASSED: WorktreeItemResolution target resolution.ignores a feature-folder path and resolves NoTarget when it is the only signal
PASSED: WorktreeItemResolution target resolution.resolves by branch when a relative feature folder and a unique branch are both present
PASSED: WorktreeItemResolution target resolution.labels the result SessionRoot when the resolved worktree is the session root
PASSED: WorktreeItemResolution target resolution.carries the no-target and ambiguity codes supplied by the worktree-resolution accessors
PASSED: WorktreeItemResolution target resolution.names no absolute path in the Detail of any result
PASSED: WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/WorktreeResolution.psm1 in core.json paths
PASSED: WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 in core.json paths
PASSED: WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 in core.json paths
PASSED: WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/EpicScopeResolution.psm1 in core.json paths
PASSED: WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 in core.json paths
PASSED: WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 in core.json paths
PASSED: WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/WorktreeResolution.psm1 exactly once
PASSED: WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 exactly once
PASSED: WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 exactly once
PASSED: WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/EpicScopeResolution.psm1 exactly once
PASSED: WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 exactly once
PASSED: WorktreeResolution core.json manifest membership.lists .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 exactly once
PASSED: WorktreeResolution core.json manifest membership.registers every on-disk worktree-resolution module so none is unregistered
PASSED: WorktreeResolution bundle mirror byte identity.mirrors .claude/lib/worktree-resolution/WorktreeResolution.psm1 byte-identically into the bundle
PASSED: WorktreeResolution bundle mirror byte identity.mirrors .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 byte-identically into the bundle
PASSED: WorktreeResolution bundle mirror byte identity.mirrors .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 byte-identically into the bundle
PASSED: WorktreeResolution bundle mirror byte identity.mirrors .claude/lib/worktree-resolution/EpicScopeResolution.psm1 byte-identically into the bundle
PASSED: WorktreeResolution bundle mirror byte identity.mirrors .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 byte-identically into the bundle
PASSED: WorktreeResolution bundle mirror byte identity.mirrors .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 byte-identically into the bundle
PASSED: WorktreeResolution seam default bodies.classifies an existing directory, an existing file, and an absent path
PASSED: WorktreeResolution seam default bodies.reads the raw text of a tracked file and returns null for an absent file
PASSED: WorktreeResolution seam default bodies.lists child directory names as an array, empty for an absent directory
PASSED: WorktreeResolution.path normalisation.normalises a backslash path to C:/repo/docs/features
PASSED: WorktreeResolution.path normalisation.normalises a forward-slash path to C:/repo/docs/features
PASSED: WorktreeResolution.path normalisation.normalises mixed and repeated separators to C:/repo/docs/features
PASSED: WorktreeResolution.path normalisation.normalises a trailing slash to C:/repo/docs
PASSED: WorktreeResolution.path normalisation.normalises a leading ./ segment to docs/features
PASSED: WorktreeResolution.path normalisation.normalises the filesystem root to /
PASSED: WorktreeResolution.path normalisation.normalises a UNC share to //server/share/repo
PASSED: WorktreeResolution.path normalisation.returns null for a null input
PASSED: WorktreeResolution.path normalisation.returns null for an empty input
PASSED: WorktreeResolution.path normalisation.returns null for a whitespace input
PASSED: WorktreeResolution.path normalisation.returns null for a bare ./ input
PASSED: WorktreeResolution.root marker.treats a .git directory as a root marker
PASSED: WorktreeResolution.root marker.treats a .git file with a well-formed gitdir line as a root marker
PASSED: WorktreeResolution.root marker.rejects a .git file whose text is malformed
PASSED: WorktreeResolution.root marker.rejects a .git file whose text is empty
PASSED: WorktreeResolution.root marker.rejects a .git file whose text is unreadable
PASSED: WorktreeResolution.root marker.rejects a level with no .git entry and an empty level
PASSED: WorktreeResolution.upward ascent.returns the input itself when it is a root (depth 0)
PASSED: WorktreeResolution.upward ascent.ascends several levels to the nearest root (depth greater than 0)
PASSED: WorktreeResolution.upward ascent.returns null after probing the drive root when no marker exists
PASSED: WorktreeResolution.upward ascent.returns null after probing the filesystem root for a slash-rooted path
PASSED: WorktreeResolution.upward ascent.stops at the MaximumDepth guard before reaching a distant root
PASSED: WorktreeResolution.upward ascent.refuses a relative input without probing the filesystem
PASSED: WorktreeResolution.worktree enumeration.enumerates the main checkout and its linked worktrees from the main checkout
PASSED: WorktreeResolution.worktree enumeration.includes the main checkout when the session root is a linked worktree
PASSED: WorktreeResolution.worktree enumeration.resolves a linked worktree that is a sibling of the main checkout without a prefix comparison
PASSED: WorktreeResolution.worktree enumeration.returns a single-element array when the admin directory holds no linked worktree
PASSED: WorktreeResolution.worktree enumeration.returns an empty array for a session root with no .git entry
PASSED: WorktreeResolution.worktree enumeration.returns an empty array for an empty session root
PASSED: WorktreeResolution.worktree enumeration.returns an empty array for a linked worktree whose admin directory has no commondir
PASSED: WorktreeResolution.worktree enumeration.returns an empty array for a .git file with no gitdir line
PASSED: WorktreeResolution.worktree enumeration.follows relative pointers, skips admin entries without a gitdir file, and deduplicates roots
PASSED: WorktreeResolution.worktree enumeration.omits the main checkout when the common directory is not a .git directory
PASSED: WorktreeResolution.worktree enumeration.filters candidates by branch feature/item-700
PASSED: WorktreeResolution.worktree enumeration.filters candidates by branch main
PASSED: WorktreeResolution.worktree enumeration.filters candidates by branch feature/absent
PASSED: WorktreeResolution.worktree enumeration.filters candidates to those containing a repo-relative path
PASSED: WorktreeResolution.repo-relative normalisation.keeps a remainder deeper than four segments intact and recovers the absolute prefix
PASSED: WorktreeResolution.repo-relative normalisation.normalises a relative path against an explicit worktree root (Ruling A complement)
PASSED: WorktreeResolution.repo-relative normalisation.refuses a relative path with no worktree root and does not echo the input (Ruling A)
PASSED: WorktreeResolution.repo-relative normalisation.marks an absolute path with no .git entry on the ascent as not normalised with the ambiguity reason code
PASSED: WorktreeResolution.repo-relative normalisation.marks an empty path as not normalised with the ambiguity reason code
PASSED: WorktreeResolution.repo-relative normalisation.returns an empty remainder for the worktree root itself
PASSED: WorktreeResolution.reason code.returns the exact ambiguity literal from the accessor
PASSED: WorktreeResolution.reason code.declares the literal once as a script-scope constant
PASSED: Resolve-WorktreeRunTargetByRecord.B1 resolves an epic run by epic_merge_pr.pr_number
PASSED: Resolve-WorktreeRunTargetByRecord.B2 resolves an epic run by features[].pr_number
PASSED: Resolve-WorktreeRunTargetByRecord.B3 resolves an epic run by features[].worktree_path across separator style and trailing slash
PASSED: Resolve-WorktreeRunTargetByRecord.B4 resolves a parallel run by items[].pr_number
PASSED: Resolve-WorktreeRunTargetByRecord.B5 resolves a parallel run by items[].worktree_path
PASSED: Resolve-WorktreeRunTargetByRecord.B6 resolves NoTarget when no live root records the value
PASSED: Resolve-WorktreeRunTargetByRecord.B7 resolves Ambiguous when two live roots record the value
PASSED: Resolve-WorktreeRunTargetByRecord.B8 resolves NoTarget for a blank value without enumerating live roots
PASSED: Resolve-WorktreeRunTargetByRecord.B9 resolves NoTarget for a non-numeric pull request value without enumerating live roots
PASSED: Resolve-WorktreeRunTargetByRecord.B10 does not match an epic lookup against a checkpoint whose route_id is parallel
PASSED: Resolve-WorktreeRunTargetByRecord.B11 compares drive-letter paths case-insensitively
PASSED: Resolve-WorktreeRunTargetByRecord.B12 compares slash-rooted paths case-sensitively
PASSED: Resolve-WorktreeRunTargetByRecord.B13 resolves NoTarget for a pull request value too large for a 64-bit integer without enumerating live roots
PASSED: Resolve-WorktreeOperandTarget.Q1 places an absolute operand inside another worktree in that worktree
PASSED: Resolve-WorktreeOperandTarget.Q2 places an operand inside the session worktree at the session root
PASSED: Resolve-WorktreeOperandTarget.Q3 evaluates an operand in no worktree against the session worktree
PASSED: Resolve-WorktreeOperandTarget.Q4 evaluates a blank operand against the session worktree
PASSED: Resolve-WorktreeOperandTarget.Q5 joins a relative operand to the session root before placing it
PASSED: Run resolver result contract.C1 returns the full result shape and accessor reason code for an epic NoTarget
PASSED: Run resolver result contract.C1 returns the full result shape and accessor reason code for a parallel Ambiguous
PASSED: Run resolver result contract.C1 returns the full result shape and accessor reason code for a record OtherWorktree
PASSED: Run resolver result contract.C1 returns the full result shape and accessor reason code for an operand SessionRoot
PASSED: Run resolver result contract.C2 delegates SessionRoot and OtherWorktree labelling to ConvertTo-WorktreeItemResolvedResult
PASSED: Run resolver purity (parse-tree scan).U1 confines every filesystem read to Get-WorktreeRunCheckpointText
PASSED: Run resolver purity (parse-tree scan).U2 invokes only allow-listed commands and never a string as a command
PASSED: Run resolver purity (parse-tree scan).U3 reads no environment variable, clock, location, or network type
PASSED: Resolver module exports.X1 exports exactly the seven run-resolver functions
PASSED: Resolver module exports.X2 exports ConvertTo-WorktreeItemResolvedResult from the item resolver
PASSED: Find-WorktreeRunIdentitySignal.S1 reads the integration branch from the epic kickoff sentence without its full stop
PASSED: Find-WorktreeRunIdentitySignal.S2 reads the epic slug from epic_feature_folder
PASSED: Find-WorktreeRunIdentitySignal.S3 reads the parallel slug from parallel_slug
PASSED: Find-WorktreeRunIdentitySignal.S4 keeps the full token when the value is followed by a space
PASSED: Find-WorktreeRunIdentitySignal.S5 matches the literal case-sensitively
PASSED: Find-WorktreeRunIdentitySignal.S6 returns three null fields when no literal is present
PASSED: Find-WorktreeRunIdentitySignal.S7 does not read the literal as the tail of a longer word
PASSED: Find-WorktreeRunIdentitySignal.S8 returns null when two different integration branches are named
PASSED: Find-WorktreeRunIdentitySignal.S9 returns three null fields for null and for empty text
PASSED: Get-WorktreeRunCheckpointText.T1 returns null for a blank path
PASSED: Get-WorktreeRunCheckpointText.T2 returns null for a path that does not exist
PASSED: Get-WorktreeRunCheckpointText.T3 returns the text of an existing committed file
PASSED: Get-WorktreeRunCheckpointText.T4 returns null and writes a diagnostic to stderr when the file cannot be read
PASSED: Get-WorktreeRunCheckpointPath.P1 composes the epic checkpoint path beneath a root
PASSED: Get-WorktreeRunCheckpointPath.P2 composes the parallel checkpoint path beneath a root
PASSED: Get-WorktreeRunCheckpointPath.P3 composes the item checkpoint path beneath a root
PASSED: Get-WorktreeRunCheckpointPath.P4 throws for a relative root
PASSED: Resolve-WorktreeEpicTarget.E1 resolves NoTarget for a blank branch without enumerating live roots
PASSED: Resolve-WorktreeEpicTarget.E2 resolves NoTarget when no live root records the branch
PASSED: Resolve-WorktreeEpicTarget.E3 resolves OtherWorktree for one match in another worktree
PASSED: Resolve-WorktreeEpicTarget.E4 resolves SessionRoot for one match at the session root
PASSED: Resolve-WorktreeEpicTarget.E5 resolves Ambiguous when the slug disagrees with the match
PASSED: Resolve-WorktreeEpicTarget.E6 resolves when the slug agrees with the match
PASSED: Resolve-WorktreeEpicTarget.E7 breaks the observed tie in favour of the worktree that has the branch checked out
PASSED: Resolve-WorktreeEpicTarget.E8 resolves Ambiguous with the handoff remedy when no match has the branch checked out
PASSED: Resolve-WorktreeEpicTarget.E9 resolves Ambiguous with the handoff remedy when both matches have the branch checked out
PASSED: Resolve-WorktreeEpicTarget.E10-E15 never counts a live root whose epic checkpoint is absent
PASSED: Resolve-WorktreeEpicTarget.E10-E15 never counts a live root whose epic checkpoint is empty
PASSED: Resolve-WorktreeEpicTarget.E10-E15 never counts a live root whose epic checkpoint is unparseable
PASSED: Resolve-WorktreeEpicTarget.E10-E15 never counts a live root whose epic checkpoint is a JSON array
PASSED: Resolve-WorktreeEpicTarget.E10-E15 never counts a live root whose epic checkpoint is a parallel route
PASSED: Resolve-WorktreeEpicTarget.E10-E15 never counts a live root whose epic checkpoint is another integration branch
PASSED: Resolve-WorktreeParallelTarget.R1 resolves NoTarget for a blank slug without enumerating live roots
PASSED: Resolve-WorktreeParallelTarget.R2 resolves one matching live root
PASSED: Resolve-WorktreeParallelTarget.R3 resolves Ambiguous for two matching live roots
PASSED: Resolve-WorktreeParallelTarget.R4-R7 never counts a live root whose parallel checkpoint is unparseable
PASSED: Resolve-WorktreeParallelTarget.R4-R7 never counts a live root whose parallel checkpoint is a JSON array
PASSED: Resolve-WorktreeParallelTarget.R4-R7 never counts a live root whose parallel checkpoint is an epic route
PASSED: Resolve-WorktreeParallelTarget.R4-R7 never counts a live root whose parallel checkpoint is another slug
PASSED: WorktreeTargetResolution.result factory and field invariants.enforces the field invariants for Status SessionRoot
PASSED: WorktreeTargetResolution.result factory and field invariants.enforces the field invariants for Status OtherWorktree
PASSED: WorktreeTargetResolution.result factory and field invariants.enforces the field invariants for Status NoTarget
PASSED: WorktreeTargetResolution.result factory and field invariants.enforces the field invariants for Status Ambiguous
PASSED: WorktreeTargetResolution.result factory and field invariants.refuses a resolved Status without a WorktreeRoot
PASSED: WorktreeTargetResolution.result factory and field invariants.refuses an empty Detail or SessionRoot and an unknown Status
PASSED: WorktreeTargetResolution.result factory and field invariants.returns an object carrying exactly the eight contract fields from Resolve-WorktreeCallTarget
PASSED: WorktreeTargetResolution.result factory and field invariants.defaults SessionRoot to the worktree containing the current location
PASSED: WorktreeTargetResolution.result factory and field invariants.falls back to the normalised current location when no worktree contains it
PASSED: WorktreeTargetResolution.signal extraction.preserves the absolute prefix of a Windows-style feature-folder path
PASSED: WorktreeTargetResolution.signal extraction.returns the bare token for a repo-relative path
PASSED: WorktreeTargetResolution.signal extraction.returns the bare token for a quoted path ending a sentence
PASSED: WorktreeTargetResolution.signal extraction.reads a branch from a --head option
PASSED: WorktreeTargetResolution.signal extraction.reads a branch from a --branch= option
PASSED: WorktreeTargetResolution.signal extraction.reads a branch from a branch: label
PASSED: WorktreeTargetResolution.signal extraction.reads an absolute file path from a drive-rooted path
PASSED: WorktreeTargetResolution.signal extraction.reads an absolute file path from a slash-rooted path
PASSED: WorktreeTargetResolution.signal extraction.returns null from Find-WorktreeResolutionFeatureFolderSignal for an embedded non-token
PASSED: WorktreeTargetResolution.signal extraction.returns null from Find-WorktreeResolutionBranchSignal for prose naming no branch
PASSED: WorktreeTargetResolution.signal extraction.returns null from Find-WorktreeResolutionFilePathSignal for relative paths and a URL
PASSED: WorktreeTargetResolution.signal extraction.returns null from Find-WorktreeResolutionFeatureFolderSignal for a null payload
PASSED: WorktreeTargetResolution.required matrix.required matrix row: cwd session, relative path, own target resolves to SessionRoot
PASSED: WorktreeTargetResolution.required matrix.required matrix row: cwd session, absolute path, own target resolves to SessionRoot
PASSED: WorktreeTargetResolution.required matrix.required matrix row: cwd session, relative path, sibling target resolves to OtherWorktree
PASSED: WorktreeTargetResolution.required matrix.required matrix row: cwd session, absolute path, sibling target resolves to OtherWorktree
PASSED: WorktreeTargetResolution.required matrix.required matrix row: cwd session, relative path, absent target resolves to Ambiguous
PASSED: WorktreeTargetResolution.required matrix.required matrix row: cwd session, absolute path, absent target resolves to Ambiguous
PASSED: WorktreeTargetResolution.required matrix.required matrix row: cwd item, relative path, own target resolves to SessionRoot
PASSED: WorktreeTargetResolution.required matrix.required matrix row: cwd item, absolute path, own target resolves to SessionRoot
PASSED: WorktreeTargetResolution.required matrix.required matrix row: cwd item, relative path, sibling target resolves to OtherWorktree
PASSED: WorktreeTargetResolution.required matrix.required matrix row: cwd item, absolute path, sibling target resolves to OtherWorktree
PASSED: WorktreeTargetResolution.required matrix.required matrix row: cwd item, relative path, absent target resolves to Ambiguous
PASSED: WorktreeTargetResolution.required matrix.required matrix row: cwd item, absolute path, absent target resolves to Ambiguous
PASSED: WorktreeTargetResolution.ambiguity, no target, and Ruling B.ambiguous sub-case: a relative feature-folder token present in two worktrees
PASSED: WorktreeTargetResolution.ambiguity, no target, and Ruling B.ambiguous sub-case: a relative feature-folder token present in no worktree
PASSED: WorktreeTargetResolution.ambiguity, no target, and Ruling B.ambiguous sub-case: an absolute path whose upward walk finds no .git entry
PASSED: WorktreeTargetResolution.ambiguity, no target, and Ruling B.ambiguous sub-case: a branch matching no worktree
PASSED: WorktreeTargetResolution.ambiguity, no target, and Ruling B.ambiguous sub-case: a branch matching more than one worktree
PASSED: WorktreeTargetResolution.ambiguity, no target, and Ruling B.ambiguous sub-case: two signals resolving to different worktree roots
PASSED: WorktreeTargetResolution.ambiguity, no target, and Ruling B.returns NoTarget with empty signal fields for a payload naming nothing, without reading the filesystem
PASSED: WorktreeTargetResolution.ambiguity, no target, and Ruling B.distinguishes NoTarget from Ambiguous by Status and ReasonCode alone
PASSED: WorktreeTargetResolution.ambiguity, no target, and Ruling B.deduplicates two agreeing signals and reports the higher-precedence kind FeatureFolderPath
PASSED: WorktreeTargetResolution.ambiguity, no target, and Ruling B.deduplicates two agreeing signals and reports the higher-precedence kind FilePath
PASSED: WorktreeTargetResolution.ambiguity, no target, and Ruling B.never lets precedence suppress a disagreement between a relative file path and a branch
PASSED: WorktreeTargetResolution.ambiguity, no target, and Ruling B.concatenates into a gate deny reason carrying both tokens
PASSED: WorktreeTargetResolution.ambiguity, no target, and Ruling B.produces each of the four Status values from a documented input
PASSED: WorktreeTargetResolution.path composition.join composes an absolute path from a backslash-separated root
PASSED: WorktreeTargetResolution.path composition.join composes an absolute path from a root with a trailing slash
PASSED: WorktreeTargetResolution.path composition.join composes an absolute path from a remainder deeper than four segments
PASSED: WorktreeTargetResolution.path composition.join composes an absolute path from a blank remainder
PASSED: WorktreeTargetResolution.path composition.refuses a relative worktree root
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging an epic document under the epics tree
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging a parallel manifest and its kickoff in one two-operand invocation
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows a quoted operand under the active feature tree
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.denies a backslash-spelled operand (D4 row 18 reversed by issues #732 and #735)
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging a kickoff markdown file under the orchestration artifacts tree
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows the pathspec-bearing integration form with a message option and a double-dash separator
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows a chained two-segment line whose every segment is independently exempt
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging a lifecycle record under the potential feature tree
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 mixed pathspec deny cases.denies an exempt operand paired with a .ps1 production operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 mixed pathspec deny cases.denies an exempt operand paired with a .py production operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 mixed pathspec deny cases.denies an exempt operand paired with a .ts production operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 mixed pathspec deny cases.denies an exempt operand paired with a .cs production operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 1 - bare staging with zero operands
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2a - the tree-wide short all flag
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2b - the tree-wide long all flag
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2c - the update short flag with an exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2d - the update long flag
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2e - the no-all flag with an exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 3a - the dot whole-tree operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 3b - the colon-slash whole-tree operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 4 - a pathless message-only integration invocation
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5a - the content-widening short all option
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5b - the content-widening long all option
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5c - the include short option
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5d - the include long option
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5e - the interactive long option
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5f - the patch short option
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5g - the history-rewriting amend option
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 6a - pathspecs supplied from a file
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 6b - the nul-delimited pathspec file option
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 7 - a double-dash separator with nothing after it
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 8 - an unmodeled dash-leading option before the separator
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9a - the exclude pathspec magic operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9b - the bang shorthand exclude operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9c - the top pathspec magic operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9d - the glob pathspec magic operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9e - the icase pathspec magic operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 10 - a leading-dash operand with no preceding separator
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 11 - an unbalanced quote around an exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 12a - a dollar-sign interpolation inside an operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 12b - a backtick substitution inside an operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 12c - an output redirection in the segment
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 12d - an input redirection in the segment
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 13a - a chained line whose second segment is not exempt
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 13b - unsplittable text whose quote spans the chain operator
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 14a - an environment-style prefix relocating the pathspec base
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 14b - a directory-relocating option before the subcommand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 14c - a git-dir option before the subcommand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 14d - a work-tree option before the subcommand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 15a - a glob whose literal prefix stops above the exempt trees
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 15b - a glob whose wildcard occupies an ancestor segment
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 15c - a glob carrying a parent-directory segment
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 16a - an absolute operand in the leading-slash spelling
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 16b - an absolute operand in the drive-letter spelling
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 16c - an absolute operand in the UNC spelling
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 17 - a parent-directory segment inside an otherwise exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 19 - a mixed operand set of one exempt and one production path
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 residual whole-command-text behaviour (D3 and D8).denies a message-body payload that merely contains the staging literal
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 residual whole-command-text behaviour (D3 and D8).denies the same heredoc body when it feeds a shell wrapper instead of a file
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 1 - drive-letter absolute selector on the add subcommand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 2 - POSIX-rooted absolute selector on the add subcommand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 4 - absolute selector on the message-bearing commit form
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 5 - chained add and commit segments each carrying the same absolute selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 6 - absolute selector naming a sibling item worktree root
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 7 - absolute selector naming a directory outside every worktree
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L1a - attached selector spelling
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L1b - config-injection selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L2 - repeated selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L3a - selector with no subcommand after the value
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L3b - subcommand not immediately after the selector value
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L4a - bare relative selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L4b - UNC selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L5a - parent-directory segment in the selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L5b - current-directory segment in the selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L6 - wildcard in the selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L7 - stray colon in the selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #732 LACS allow 3 reversed - backslash-spelled absolute selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L8 - empty selector value
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector followed by an unmodelled subcommand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector with a non-exempt pathspec operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector with the tree-wide all flag
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector with an absolute pathspec operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector with an output redirection
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 cd chain into the target worktree
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 empty-token fail-closed cases.allows issue #671 empty commit message beside an exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 empty-token fail-closed cases.denies issue #671 empty token beside a non-exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 empty-token fail-closed cases.denies issue #671 empty token after the separator beside a non-exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 empty-token fail-closed cases.denies issue #671 trailing empty token after a non-exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 empty-token fail-closed cases.denies issue #671 empty commit message beside a non-exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.accepts issue #671 predicate accept 1 - drive-letter selector followed by add
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.accepts issue #671 predicate accept 2 - rooted selector followed by commit
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.accepts issue #671 predicate accept 3 - non-option token after the value is left to the caller
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L1a - single token segment
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L1b - option other than the selector at index 1
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L2 - repeated selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L3a - no token after the selector value
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L3b - option token after the selector value
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L4a - relative selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L4b - UNC selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L5a - parent-directory segment
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L5b - current-directory segment
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L6 - wildcard
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L7 - stray colon
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L8 - empty selector value
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.returns false when segment classification raises an error
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 exempts a double-quoted message carrying a Co-Authored-By trailer and an apostrophe
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 exempts a single-quoted message carrying angle brackets
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies the single-quoted apostrophe idiom
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies a command substitution inside a double-quoted message
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies a variable expansion inside a double-quoted message
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies a backtick substitution inside a double-quoted message
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies a pathless commit whose message carries angle brackets
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies an unquoted output redirection after a quoted message carrying angle brackets
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding an output redirection (CR-1)
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding an output redirection after a semicolon (CR-1)
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding chain operators (CR-3)
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an unquoted escaped double quote opening a scan-only span
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an unquoted escaped single quote opening a scan-only span
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies a backslash inside a double-quoted message
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging an epic document under the epics tree
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging a parallel manifest and its kickoff in one two-operand invocation
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows a quoted operand under the active feature tree
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.denies a backslash-spelled operand (D4 row 18 reversed by issues #732 and #735)
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging a kickoff markdown file under the orchestration artifacts tree
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows the pathspec-bearing integration form with a message option and a double-dash separator
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows a chained two-segment line whose every segment is independently exempt
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging a lifecycle record under the potential feature tree
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 mixed pathspec deny cases.denies an exempt operand paired with a .ps1 production operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 mixed pathspec deny cases.denies an exempt operand paired with a .py production operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 mixed pathspec deny cases.denies an exempt operand paired with a .ts production operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 mixed pathspec deny cases.denies an exempt operand paired with a .cs production operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 1 - bare staging with zero operands
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2a - the tree-wide short all flag
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2b - the tree-wide long all flag
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2c - the update short flag with an exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2d - the update long flag
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2e - the no-all flag with an exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 3a - the dot whole-tree operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 3b - the colon-slash whole-tree operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 4 - a pathless message-only integration invocation
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5a - the content-widening short all option
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5b - the content-widening long all option
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5c - the include short option
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5d - the include long option
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5e - the interactive long option
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5f - the patch short option
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5g - the history-rewriting amend option
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 6a - pathspecs supplied from a file
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 6b - the nul-delimited pathspec file option
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 7 - a double-dash separator with nothing after it
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 8 - an unmodeled dash-leading option before the separator
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9a - the exclude pathspec magic operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9b - the bang shorthand exclude operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9c - the top pathspec magic operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9d - the glob pathspec magic operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9e - the icase pathspec magic operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 10 - a leading-dash operand with no preceding separator
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 11 - an unbalanced quote around an exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 12a - a dollar-sign interpolation inside an operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 12b - a backtick substitution inside an operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 12c - an output redirection in the segment
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 12d - an input redirection in the segment
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 13a - a chained line whose second segment is not exempt
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 13b - unsplittable text whose quote spans the chain operator
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 14a - an environment-style prefix relocating the pathspec base
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 14b - a directory-relocating option before the subcommand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 14c - a git-dir option before the subcommand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 14d - a work-tree option before the subcommand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 15a - a glob whose literal prefix stops above the exempt trees
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 15b - a glob whose wildcard occupies an ancestor segment
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 15c - a glob carrying a parent-directory segment
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 16a - an absolute operand in the leading-slash spelling
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 16b - an absolute operand in the drive-letter spelling
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 16c - an absolute operand in the UNC spelling
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 17 - a parent-directory segment inside an otherwise exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 19 - a mixed operand set of one exempt and one production path
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 residual whole-command-text behaviour (D3 and D8).denies a message-body payload that merely contains the staging literal
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 residual whole-command-text behaviour (D3 and D8).denies the same heredoc body when it feeds a shell wrapper instead of a file
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 1 - drive-letter absolute selector on the add subcommand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 2 - POSIX-rooted absolute selector on the add subcommand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 4 - absolute selector on the message-bearing commit form
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 5 - chained add and commit segments each carrying the same absolute selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 6 - absolute selector naming a sibling item worktree root
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 7 - absolute selector naming a directory outside every worktree
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L1a - attached selector spelling
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L1b - config-injection selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L2 - repeated selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L3a - selector with no subcommand after the value
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L3b - subcommand not immediately after the selector value
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L4a - bare relative selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L4b - UNC selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L5a - parent-directory segment in the selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L5b - current-directory segment in the selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L6 - wildcard in the selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L7 - stray colon in the selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #732 LACS allow 3 reversed - backslash-spelled absolute selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L8 - empty selector value
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector followed by an unmodelled subcommand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector with a non-exempt pathspec operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector with the tree-wide all flag
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector with an absolute pathspec operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector with an output redirection
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 cd chain into the target worktree
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 empty-token fail-closed cases.allows issue #671 empty commit message beside an exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 empty-token fail-closed cases.denies issue #671 empty token beside a non-exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 empty-token fail-closed cases.denies issue #671 empty token after the separator beside a non-exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 empty-token fail-closed cases.denies issue #671 trailing empty token after a non-exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 empty-token fail-closed cases.denies issue #671 empty commit message beside a non-exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.accepts issue #671 predicate accept 1 - drive-letter selector followed by add
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.accepts issue #671 predicate accept 2 - rooted selector followed by commit
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.accepts issue #671 predicate accept 3 - non-option token after the value is left to the caller
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L1a - single token segment
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L1b - option other than the selector at index 1
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L2 - repeated selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L3a - no token after the selector value
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L3b - option token after the selector value
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L4a - relative selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L4b - UNC selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L5a - parent-directory segment
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L5b - current-directory segment
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L6 - wildcard
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L7 - stray colon
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L8 - empty selector value
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.returns false when segment classification raises an error
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 exempts a double-quoted message carrying a Co-Authored-By trailer and an apostrophe
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 exempts a single-quoted message carrying angle brackets
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies the single-quoted apostrophe idiom
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies a command substitution inside a double-quoted message
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies a variable expansion inside a double-quoted message
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies a backtick substitution inside a double-quoted message
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies a pathless commit whose message carries angle brackets
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies an unquoted output redirection after a quoted message carrying angle brackets
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding an output redirection (CR-1)
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding an output redirection after a semicolon (CR-1)
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding chain operators (CR-3)
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an unquoted escaped double quote opening a scan-only span
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an unquoted escaped single quote opening a scan-only span
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies a backslash inside a double-quoted message
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).treats a mid-line escaped semicolon as literal
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).treats an escaped ampersand as literal
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).treats an escaped pipe as literal
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).treats backslash-newline as a line continuation
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped ;
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped &&
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped ||
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped |
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped &
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits after an escaped backslash
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).does not split after an odd run of backslashes
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).splits on the unescaped ampersand after an escaped one
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).keeps backslash literal inside single quotes
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).consumes an escaped double quote inside double quotes
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).does not open a quote on an unquoted escaped double quote
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).treats a trailing lone backslash as balanced
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).returns no segments for an empty command
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).does not exempt a commit whose message contains an escaped semicolon (issue #732 D2a)
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).does not exempt a chained command after an escaped backslash
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).treats a mid-line escaped semicolon as literal
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).treats an escaped ampersand as literal
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).treats an escaped pipe as literal
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).treats backslash-newline as a line continuation
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped ;
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped &&
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped ||
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped |
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped &
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits after an escaped backslash
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).does not split after an odd run of backslashes
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).splits on the unescaped ampersand after an escaped one
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).keeps backslash literal inside single quotes
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).consumes an escaped double quote inside double quotes
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).does not open a quote on an unquoted escaped double quote
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).treats a trailing lone backslash as balanced
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).returns no segments for an empty command
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).does not exempt a commit whose message contains an escaped semicolon (issue #732 D2a)
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).does not exempt a chained command after an escaped backslash
PASSED: preimplementation gate attribution trailers (claude).admits a separate-value trailer option
PASSED: preimplementation gate attribution trailers (claude).admits an equals-form trailer option
PASSED: preimplementation gate attribution trailers (claude).admits two trailer options
PASSED: preimplementation gate attribution trailers (claude).admits a multi-message form with both trailers in one single-quoted paragraph
PASSED: preimplementation gate attribution trailers (claude).admits a single-quoted subject containing a backtick
PASSED: preimplementation gate attribution trailers (claude).admits a single-quoted subject containing a dollar sign and a command substitution
PASSED: preimplementation gate attribution trailers (claude).admits a chained add and trailer-bearing commit
PASSED: preimplementation gate attribution trailers (claude).admits a POSIX-rooted selector with a trailer option
PASSED: preimplementation gate attribution trailers (claude).admits a hash inside a single-quoted message
PASSED: preimplementation gate attribution trailers (claude).admits a hash inside a double-quoted message
PASSED: preimplementation gate attribution trailers (claude).admits an inline angle-bracket attribution in a double-quoted subject
PASSED: preimplementation gate attribution trailers (claude).admits an empty single-quoted trailer value
PASSED: preimplementation gate attribution trailers (claude).admits a trailer option taking the double-dash separator as its value (CR-4)
PASSED: preimplementation gate attribution trailers (claude).denies an unquoted redirection after a single-quoted dollar message
PASSED: preimplementation gate attribution trailers (claude).denies a command substitution in an operand
PASSED: preimplementation gate attribution trailers (claude).denies a variable expansion in an operand
PASSED: preimplementation gate attribution trailers (claude).denies a dollar sign inside double quotes
PASSED: preimplementation gate attribution trailers (claude).denies a command substitution inside double quotes
PASSED: preimplementation gate attribution trailers (claude).denies a backtick inside double quotes
PASSED: preimplementation gate attribution trailers (claude).denies the heredoc command-substitution commit recipe
PASSED: preimplementation gate attribution trailers (claude).denies ANSI-C dollar-single-quote quoting
PASSED: preimplementation gate attribution trailers (claude).denies an and-chain to a non-exempt add
PASSED: preimplementation gate attribution trailers (claude).denies a semicolon chain to a non-git command
PASSED: preimplementation gate attribution trailers (claude).denies a non-exempt pathspec with a trailer option
PASSED: preimplementation gate attribution trailers (claude).denies a pathless commit carrying a message and a trailer
PASSED: preimplementation gate attribution trailers (claude).denies a trailer option on the add subcommand
PASSED: preimplementation gate attribution trailers (claude).denies a dangling trailer option with no value
PASSED: preimplementation gate attribution trailers (claude).denies a message-file option
PASSED: preimplementation gate attribution trailers (claude).denies an equals-form file option
PASSED: preimplementation gate attribution trailers (claude).denies a stdin message file fed by a heredoc
PASSED: preimplementation gate attribution trailers (claude).denies the hash-quote comment desynchronization line
PASSED: preimplementation gate attribution trailers (claude).denies an unquoted trailing comment
PASSED: preimplementation gate attribution trailers (claude).denies a mid-word hash in an exempt operand
PASSED: preimplementation gate attribution trailers (claude).denies an unbalanced single quote around a dollar sign
PASSED: preimplementation gate attribution trailers (claude).denies an escaped single quote near a dollar sign
PASSED: preimplementation gate attribution trailers (claude).denies a typographic single-quoted command substitution
PASSED: preimplementation gate attribution trailers (claude).denies a typographic double-quoted command substitution
PASSED: preimplementation gate attribution trailers (claude).denies a typographic single quote around a non-exempt pathspec
PASSED: preimplementation gate attribution trailers (claude).denies a trailer option taking the double-dash separator before a non-exempt operand (CR-4)
PASSED: preimplementation gate attribution trailers (claude).denies a single low-9 quotation mark (U+201A)
PASSED: preimplementation gate attribution trailers (claude).denies a single high-reversed-9 quotation mark (U+201B)
PASSED: preimplementation gate attribution trailers (claude).denies a double low-9 quotation mark (U+201E)
PASSED: preimplementation gate attribution trailers (codex).admits a separate-value trailer option
PASSED: preimplementation gate attribution trailers (codex).admits an equals-form trailer option
PASSED: preimplementation gate attribution trailers (codex).admits two trailer options
PASSED: preimplementation gate attribution trailers (codex).admits a multi-message form with both trailers in one single-quoted paragraph
PASSED: preimplementation gate attribution trailers (codex).admits a single-quoted subject containing a backtick
PASSED: preimplementation gate attribution trailers (codex).admits a single-quoted subject containing a dollar sign and a command substitution
PASSED: preimplementation gate attribution trailers (codex).admits a chained add and trailer-bearing commit
PASSED: preimplementation gate attribution trailers (codex).admits a POSIX-rooted selector with a trailer option
PASSED: preimplementation gate attribution trailers (codex).admits a hash inside a single-quoted message
PASSED: preimplementation gate attribution trailers (codex).admits a hash inside a double-quoted message
PASSED: preimplementation gate attribution trailers (codex).admits an inline angle-bracket attribution in a double-quoted subject
PASSED: preimplementation gate attribution trailers (codex).admits an empty single-quoted trailer value
PASSED: preimplementation gate attribution trailers (codex).admits a trailer option taking the double-dash separator as its value (CR-4)
PASSED: preimplementation gate attribution trailers (codex).denies an unquoted redirection after a single-quoted dollar message
PASSED: preimplementation gate attribution trailers (codex).denies a command substitution in an operand
PASSED: preimplementation gate attribution trailers (codex).denies a variable expansion in an operand
PASSED: preimplementation gate attribution trailers (codex).denies a dollar sign inside double quotes
PASSED: preimplementation gate attribution trailers (codex).denies a command substitution inside double quotes
PASSED: preimplementation gate attribution trailers (codex).denies a backtick inside double quotes
PASSED: preimplementation gate attribution trailers (codex).denies the heredoc command-substitution commit recipe
PASSED: preimplementation gate attribution trailers (codex).denies ANSI-C dollar-single-quote quoting
PASSED: preimplementation gate attribution trailers (codex).denies an and-chain to a non-exempt add
PASSED: preimplementation gate attribution trailers (codex).denies a semicolon chain to a non-git command
PASSED: preimplementation gate attribution trailers (codex).denies a non-exempt pathspec with a trailer option
PASSED: preimplementation gate attribution trailers (codex).denies a pathless commit carrying a message and a trailer
PASSED: preimplementation gate attribution trailers (codex).denies a trailer option on the add subcommand
PASSED: preimplementation gate attribution trailers (codex).denies a dangling trailer option with no value
PASSED: preimplementation gate attribution trailers (codex).denies a message-file option
PASSED: preimplementation gate attribution trailers (codex).denies an equals-form file option
PASSED: preimplementation gate attribution trailers (codex).denies a stdin message file fed by a heredoc
PASSED: preimplementation gate attribution trailers (codex).denies the hash-quote comment desynchronization line
PASSED: preimplementation gate attribution trailers (codex).denies an unquoted trailing comment
PASSED: preimplementation gate attribution trailers (codex).denies a mid-word hash in an exempt operand
PASSED: preimplementation gate attribution trailers (codex).denies an unbalanced single quote around a dollar sign
PASSED: preimplementation gate attribution trailers (codex).denies an escaped single quote near a dollar sign
PASSED: preimplementation gate attribution trailers (codex).denies a typographic single-quoted command substitution
PASSED: preimplementation gate attribution trailers (codex).denies a typographic double-quoted command substitution
PASSED: preimplementation gate attribution trailers (codex).denies a typographic single quote around a non-exempt pathspec
PASSED: preimplementation gate attribution trailers (codex).denies a trailer option taking the double-dash separator before a non-exempt operand (CR-4)
PASSED: preimplementation gate attribution trailers (codex).denies a single low-9 quotation mark (U+201A)
PASSED: preimplementation gate attribution trailers (codex).denies a single high-reversed-9 quotation mark (U+201B)
PASSED: preimplementation gate attribution trailers (codex).denies a double low-9 quotation mark (U+201E)
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.blocks implementation writes when route metadata and lifecycle readiness are absent (generalized message)
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.emits the PreToolUse deny schema (hookEventName + permissionDecision=deny) after serialize-then-parse
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.allows feature documentation writes
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.allows evidence writes
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.allows implementation writes when checkpoint readiness is present, regardless of issue number
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.blocks implementation command payloads before readiness (generalized message)
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.blocks staging and commit command payloads before readiness
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.blocks formatter and test command payloads before readiness
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.blocks implementation delegation payloads before readiness (generalized message)
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.allows implementation operations for any ready workflow state regardless of issue number
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.denies an empty payload as an envelope anomaly (fail closed)
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.denies unparseable top-level JSON instead of throwing (exit 1 is non-blocking)
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.denies the legacy flat root shape as a missing-tool_input anomaly
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.allows a well-formed nested Bash envelope whose tool_input carries no file_path (AC-6)
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.allows a non-implementation file write (documentation path) without a checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.blocks an implementation write when the resolved checkpoint is malformed JSON
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.allows an implementation write when readiness is supplied via path_selected fallback
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.blocks an implementation write when the checkpoint omits the feature folder
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.Test-OrchestrationReady returns false for a null payload
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.Test-ImplementationDelegation returns false for a null tool input
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 checkpoint write exemptions.allows a Write to every exempt checkpoint literal with no ready checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 checkpoint write exemptions.allows the backslash spelling of every exempt checkpoint literal
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 checkpoint write exemptions.denies a non-checkpoint .json under artifacts/orchestration/ (literal set, not directory prefix)
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 checkpoint write exemptions.denies a checkpoint-named file outside artifacts/orchestration/ (full-path equality)
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 preparation-mode delegation exemption.allows the verbatim parallel-plan preparation kickoff delegation with no ready checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 preparation-mode delegation exemption.allows the verbatim epic-plan preparation kickoff delegation with no ready checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 preparation-mode delegation exemption.denies both markers when subagent_type is not orchestrator
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 preparation-mode delegation exemption.denies an orchestrator delegation whose prompt matches the implementation regex without the markers
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 preparation-mode delegation exemption.denies an orchestrator delegation carrying only one preparation marker
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 preparation-mode delegation exemption.denies an orchestrator delegation whose first marker is missing its trailing period
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 preparation-mode delegation exemption.denies markers placed in a non-prompt field while prompt matches the implementation regex
PASSED: enforce-orchestration-preimplementation-gate.ps1.Entrypoint (exit code seam, no child process).returns exit code 0 and emits a deny when every transport is empty
PASSED: enforce-orchestration-preimplementation-gate.ps1.Entrypoint (exit code seam, no child process).returns exit code 0 and emits an allow decision JSON for a documentation write
PASSED: enforce-orchestration-preimplementation-gate.ps1.Entrypoint (exit code seam, no child process).returns exit code 0 and never 1 for unparseable JSON
PASSED: enforce-orchestration-preimplementation-gate.ps1.Claude runtime registration.registers the preimplementation gate in active and tracked Claude settings
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a quoted mention of the staging invocation inside an echo argument
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a heredoc body that quotes the staging invocation in prose
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a heredoc whose JSON body names a governed tool as a receipt value
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows prose containing the English word black
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a cross-segment line whose npm segment and lint mention are in different segments
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).under-match deny cases - the latent bypass.denies a relocating git add carrying a directory global option
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).under-match deny cases - the latent bypass.denies a relocating git commit carrying a git-dir global option
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).under-match deny cases - the latent bypass.denies a relocating git add carrying a work-tree global option
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).under-match deny cases - the latent bypass.denies an unmodeled dash-leading token between git and its subcommand
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).under-match deny cases - the latent bypass.denies the subshell spelling of a staging command
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).under-match deny cases - the latent bypass.denies the command-substitution spelling of a staging command
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).the non-classifying stop case.does not classify git log --grep add as a staging command
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 1: denies a staging command relocated through xargs
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 2: denies a staging command nested inside a bash -c argument
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 3: denies a staging command nested inside an sh -c argument
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 4: denies a staging command behind the env transparent wrapper
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 5: denies a test invocation behind the pwsh -Command wrapper
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 6: denies a heredoc body piped into bash
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 7: denies a live substitution inside a double-quoted span
PASSED: enforce-orchestration-preimplementation-gate.ps1 classifier (issue #554).the preparation-mode delegation predicate.returns false for a null tool input
PASSED: enforce-orchestration-preimplementation-gate.ps1 classifier (issue #554).the preparation-mode delegation predicate.returns false for a non-orchestrator subagent type carrying both preparation markers
PASSED: enforce-orchestration-preimplementation-gate.ps1 classifier (issue #554).the preparation-mode delegation predicate.returns false for an orchestrator carrying only one preparation marker
PASSED: enforce-orchestration-preimplementation-gate.ps1 classifier (issue #554).the preparation-mode delegation predicate.returns true for an orchestrator carrying both preparation markers
PASSED: enforce-orchestration-preimplementation-gate.ps1 classifier (issue #554).the duplicated preparation-marker rule.pins the preparation marker set equal to the preparation row of the mode table
PASSED: enforce-orchestration-preimplementation-gate.ps1 classifier (issue #554).the classifier allow branch for a non-orchestrator agent.does not classify a non-orchestrator agent as an implementation delegation
PASSED: enforce-orchestration-preimplementation-gate.ps1 classifier (issue #554).the classifier allow branch for a non-orchestrator agent.allows a non-orchestrator delegation against an unready single-feature checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.Fault-1 wording independence, direction (b): the new allow-to-deny change.denies an orchestrator delegation phrased with "atomic execution" and no mode markers against an unready single-feature checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.mode resolution from the fixed table.resolves the preparation mode for its marker prompt
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.mode resolution from the fixed table.resolves the epic mode for its marker prompt
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.mode resolution from the fixed table.resolves the parallel mode for its marker prompt
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.mode resolution from the fixed table.resolves the single-feature mode for its marker prompt
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.mode resolution from the fixed table.evaluates preparation first when an execution marker is also present
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.mode resolution from the fixed table.requires both preparation markers, so a single marker falls through to the default mode
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.mode resolution from the fixed table.resolves the default mode for an empty prompt
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.mode resolution from the fixed table.resolves the default mode for an null prompt
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.mode resolution from the fixed table.maps the preparation mode to its canonical checkpoint path
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.mode resolution from the fixed table.maps the epic mode to its canonical checkpoint path
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.mode resolution from the fixed table.maps the parallel mode to its canonical checkpoint path
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.mode resolution from the fixed table.maps the single-feature mode to its canonical checkpoint path
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.mode resolution from the fixed table.returns an empty checkpoint path for a mode name that is not in the table
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the prompt-declared checkpoint-path cross-check.accepts an absent declared epic checkpoint path
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the prompt-declared checkpoint-path cross-check.accepts an matching declared epic checkpoint path
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the prompt-declared checkpoint-path cross-check.rejects a declared epic checkpoint path that differs from the canonical value
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the prompt-declared checkpoint-path cross-check.rejects a declared parallel checkpoint path that differs from the canonical value
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the prompt-declared checkpoint-path cross-check.accepts a matching declared parallel checkpoint path
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the prompt-declared checkpoint-path cross-check.has nothing to cross-check for a mode carrying no declared-path key
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.target resolution out of the prompt.returns nothing for a prompt carrying no feature-folder token
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.target resolution out of the prompt.returns the parent basename for a token ending in a Markdown file
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.target resolution out of the prompt.returns the basename for a bare directory token
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.target resolution out of the prompt.returns nothing for a prompt carrying no issue number
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.target resolution out of the prompt.returns the numeric string for a prompt carrying an keyed issue number
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.target resolution out of the prompt.returns the numeric string for a prompt carrying an Issue number wording issue number
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.target resolution out of the prompt.returns the numeric string for a prompt carrying an mixed-prose hash-form issue number
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.ordered mode record resolution.selects the later exact folder record in epic readiness
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.ordered mode record resolution.selects the later exact folder record in parallel readiness
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.ordered mode record resolution.retains first matching issue fallback when no folder matches
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.names route_id as the failed conjunct
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.names epic_feature_folder as the failed conjunct
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.names epic_manifest_path as the failed conjunct
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.names epic_manifest_path as the failed conjunct
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.names integration_branch as the failed conjunct
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.names features as the failed conjunct
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.names target-record as the failed conjunct
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.names merge_status as the failed conjunct
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.returns a non-empty failure name for a null checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.reports no failure for a fully ready epic checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.treats an absent merge_status as not_started and does not fail the last conjunct
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.denies the terminal-merged merge status merged (decision D8)
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.denies the terminal-merged merge status worktree_removed (decision D8)
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.allows the failure merge status merge_conflict, which is legitimate remediation (decision D8)
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.allows the failure merge status blocked_conflict_loop_limit, which is legitimate remediation (decision D8)
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.resolves the target by issue_num when no feature-folder basename matches
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the epic readiness predicate.returns false from the wrapper for a null checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the parallel readiness predicate.names route_id as the failed conjunct
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the parallel readiness predicate.names parallel_slug as the failed conjunct
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the parallel readiness predicate.names parallel_manifest_path as the failed conjunct
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the parallel readiness predicate.names items as the failed conjunct
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the parallel readiness predicate.names target-record as the failed conjunct
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the parallel readiness predicate.names merge_status as the failed conjunct
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the parallel readiness predicate.returns a non-empty failure name for a null checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the parallel readiness predicate.reports no failure for a fully ready parallel checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the parallel readiness predicate.denies the terminal-merged merge status merged (decision D8)
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the parallel readiness predicate.denies the terminal-merged merge status worktree_removed (decision D8)
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the parallel readiness predicate.allows the blocked merge status blocked_drift, adding no member to the parallel enum
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the parallel readiness predicate.allows the blocked merge status blocked_ci_loop_limit, adding no member to the parallel enum
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the parallel readiness predicate.returns false from the wrapper for a null checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the implementation-agent allow-list.classifies the allow-listed agent python-typed-engineer as an implementation agent
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the implementation-agent allow-list.classifies the allow-listed agent powershell-typed-engineer as an implementation agent
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the implementation-agent allow-list.classifies the allow-listed agent typescript-engineer as an implementation agent
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the implementation-agent allow-list.classifies the allow-listed agent csharp-typed-engineer as an implementation agent
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the implementation-agent allow-list.classifies the allow-listed agent atomic-executor as an implementation agent
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the implementation-agent allow-list.holds exactly five members
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the implementation-agent allow-list.does not classify orchestrator as an implementation agent
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the implementation-agent allow-list.does not classify task-researcher as an implementation agent
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the implementation-agent allow-list.does not classify  as an implementation agent
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the decision-level epic matrix.matrix case 1: a ready epic checkpoint allows
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the decision-level epic matrix.matrix case 2: empty injected epic content denies, naming the epic checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the decision-level epic matrix.matrix case 3: a features array lacking the target record denies, naming the failed predicate
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the decision-level epic matrix.matrix case 4: a non-canonical declared epic_checkpoint_path denies
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the decision-level epic matrix.epic target unresolvable: a prompt with no resolvable target token and no issue number denies
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the decision-level epic matrix.decision D8: a target record in a terminal-merged state denies
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the decision-level epic matrix.decision D8: a target record in a failure state allows, as legitimate remediation
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the decision-level epic matrix.matrix case 5: an epic marker in a non-prompt field resolves to the default single-feature mode
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the decision-level single-feature matrix.matrix case 6a: an allow-listed implementation agent denies against an unready checkpoint whatever its prompt says
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the decision-level single-feature matrix.matrix case 7: both preparation markers exempt the delegation
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the decision-level single-feature matrix.matrix case 8: a standalone orchestrator allows against a ready single-feature checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the decision-level single-feature matrix.matrix case 8: a standalone orchestrator denies against an unready single-feature checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the decision-level parallel matrix.a ready parallel checkpoint allows
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the decision-level parallel matrix.an items array lacking the target record denies, naming the parallel checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.the decision-level parallel matrix.a non-canonical declared parallel_checkpoint_path denies
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.deny-by-default is preserved, with no new permissive path.denies an unparseable payload
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.deny-by-default is preserved, with no new permissive path.denies a payload carrying no tool_input key
PASSED: enforce-orchestration-preimplementation-gate.ps1 mode resolution.deny-by-default is preserved, with no new permissive path.denies an epic-mode delegation whose injected epic content is empty, with no filesystem read
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the repo-relative spelling of artifacts/orchestration/orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the forward-slash absolute spelling of artifacts/orchestration/orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the backslash absolute spelling of artifacts/orchestration/orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the repo-relative spelling of artifacts/orchestration/parallel-planner-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the forward-slash absolute spelling of artifacts/orchestration/parallel-planner-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the backslash absolute spelling of artifacts/orchestration/parallel-planner-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the repo-relative spelling of artifacts/orchestration/parallel-orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the forward-slash absolute spelling of artifacts/orchestration/parallel-orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the backslash absolute spelling of artifacts/orchestration/parallel-orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the repo-relative spelling of artifacts/orchestration/epic-planner-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the forward-slash absolute spelling of artifacts/orchestration/epic-planner-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the backslash absolute spelling of artifacts/orchestration/epic-planner-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the repo-relative spelling of artifacts/orchestration/epic-orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the forward-slash absolute spelling of artifacts/orchestration/epic-orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the backslash absolute spelling of artifacts/orchestration/epic-orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the repo-relative spelling of artifacts/orchestration/powershell-orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the forward-slash absolute spelling of artifacts/orchestration/powershell-orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the backslash absolute spelling of artifacts/orchestration/powershell-orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the repo-relative spelling of artifacts/orchestration/csharp-orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the forward-slash absolute spelling of artifacts/orchestration/csharp-orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the backslash absolute spelling of artifacts/orchestration/csharp-orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.admits the POSIX-shaped absolute spelling of artifacts/orchestration/orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.admits the leading dot-slash relative spelling of artifacts/orchestration/orchestrator-state.json
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.documentation exemption holds in every spelling.allows the repo-relative spelling of a feature-folder .json artifact
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.documentation exemption holds in every spelling.allows the forward-slash absolute spelling of a feature-folder .json artifact
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.documentation exemption holds in every spelling.allows the backslash absolute spelling of a feature-folder .json artifact
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.case handling is zero-delta against the previous operators.allows an absolute checkpoint path whose literal differs only in letter case
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.case handling is zero-delta against the previous operators.denies an absolute path whose documentation prefix differs only in letter case
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.negative half stays denied.denies a synthetic absolute path ending in a production .ps1 file
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.negative half stays denied.denies a synthetic absolute path ending in a production .py file
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.negative half stays denied.denies a synthetic absolute path ending in a orchestration JSON whose name is not one of the seven literals
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.negative half stays denied.denies a synthetic absolute path ending in a checkpoint-named JSON with no preceding artifacts/orchestration segment
PASSED: enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.negative half stays denied.denies a synthetic absolute path ending in a checkpoint name reached only through a parent-directory hop
PASSED: enforce-orchestration-preimplementation-gate-helpers.ps1 surface parity (issue #671).keeps all four surface copies of the helpers module byte-identical by SHA256 hash
PASSED: enforce-orchestration-preimplementation-gate-helpers.ps1 surface parity (issue #671).keeps every surface copy of the helpers module under the 500-line cap
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).structural git classification.classifies a relocating git add carrying a directory global option
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).structural git classification.classifies a relocating git commit carrying a git-dir global option
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).structural git classification.classifies a relocating git add carrying a work-tree global option
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).structural git classification.classifies an unmodeled dash-leading token between git and its subcommand
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).structural git classification.does not classify git log --grep add, because a non-dash non-target token stops the scan
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).structural git classification.classifies the plain adjacent spelling
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).structural git classification.skips VAR=value prefixes and transparent wrappers before the command word
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).structural gh classification.classifies gh pr create carrying a repo global option in the equals form
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).structural gh classification.classifies gh issue create carrying a short repo global option
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).structural gh classification.does not classify gh issue list as gh issue create
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).operand retrieval.returns the worktree path for the flag-before-path spelling
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).operand retrieval.returns the worktree path for the flag-after-path spelling
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).operand retrieval.takes operands from the matched segment only, so a chained cd contributes nothing
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).operand retrieval.consumes a modeled option-with-argument pair rather than returning its value
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).operand retrieval.treats a token after a bare double-dash separator as an operand
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).operand retrieval.returns an empty array when no segment matched
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).operand retrieval.returns the pull-request number for the anchored gh pr merge spelling
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).Get-CommandLineFlagValue.recognises the separated form
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).Get-CommandLineFlagValue.recognises the equals form
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).Get-CommandLineFlagValue.resolves the number across a chained cd, which is the issue #591 fix
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).Get-CommandLineFlagValue.returns null for an absent flag
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).Get-CommandLineFlagValue.returns null for a present flag with no following value
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).Get-CommandLineFlagValue.returns null when the following token is itself dash-leading
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).Test-CommandLineFlag.distinguishes an absent flag from a valueless present flag
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).Test-CommandLineFlag.distinguishes --body from --body-file
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).Test-CommandLineFlag.reports a flag present in the equals form
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).Test-CommandLineMention.returns true only when the invocation predicate returns false
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).Test-CommandLineMention.returns false for a genuine invocation
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).Test-CommandLineMention.returns false when the text does not contain the words at all
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).fail-closed rules.classifies a wrapper-led segment whose payload invokes the command
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).fail-closed rules.classifies a live-substitution segment by the same wrapper rule
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).fail-closed rules.classifies an unbalanced segment, because its structure could not be resolved
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).fail-closed rules.classifies the subshell and command-substitution spellings
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).fail-closed rules.does not classify a quoted mention in a non-wrapper segment
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).constant tables.exposes exactly the five transparent wrappers of D2 Piece 3 step 2
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).constant tables.exposes exactly the modeled git global options
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).constant tables.exposes exactly the modeled gh global options
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).constant tables.exposes exactly the modeled npx global options
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).constant tables.returns two empty lists for an unmodeled command word, which is fail-closed
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).D12 public parser contract.pins the Test-CommandLineInvocation parameter list and OutputType
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).D12 public parser contract.pins the Get-CommandLineOperand parameter list and OutputType
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).D12 public parser contract.pins the Get-CommandLineFlagValue parameter list and OutputType
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).D12 public parser contract.pins the Test-CommandLineFlag parameter list and OutputType
PASSED: hook-command-invocation (issue #545 D2 Piece 3 and D12).D12 public parser contract.pins the Test-CommandLineMention parameter list and OutputType
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).empty input.returns an empty array for null input
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).empty input.returns an empty array for empty input
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).empty input.returns an empty array for whitespace-only input
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).segment delimiters.splits on a semicolon
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).segment delimiters.splits on an ampersand
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).segment delimiters.splits on a pipe
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).segment delimiters.splits on a newline
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).segment delimiters.treats the subshell opener and closer as delimiters
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).segment delimiters.treats the group opener and closer as delimiters
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).segment delimiters.treats the substitution opener as a delimiter
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).segment delimiters.treats the backtick as a delimiter
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).quoted-span masking.masks a single-quoted span
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).quoted-span masking.masks a double-quoted span
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).quoted-span masking.preserves nothing of the masked content, so mask length equals span length
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).tokenizer.yields one token per double-quoted span with the delimiting quotes removed
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).tokenizer.produces no adjacent token pair equal to the recursive-remove literal
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).tokenizer.keeps a quoted span attached to the token it sits in
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).tokenizer.emits an empty token for an empty quoted string
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).tokenizer.collapses runs of whitespace between tokens
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).heredoc rules.masks the body of a plain heredoc
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).heredoc rules.masks the body of a tab-stripping heredoc whose terminator is tab-indented
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).heredoc rules.masks the body of a heredoc whose delimiter is quoted
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).heredoc rules.consumes multiple pending heredocs on one physical line in order
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).heredoc rules.masks an unterminated heredoc body to end of text and reports it unbalanced
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).heredoc rules.does not treat a three-angle here-string as a heredoc
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).heredoc rules.forces a raw scan when the heredoc delimiter is produced by expansion
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).CommandWord determination.returns the first token when there is no env-assignment prefix
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).CommandWord determination.skips VAR=value env-assignment prefixes
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).CommandWord determination.returns the empty string when the segment carries only assignments
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).segment flags.sets IsWrapperLed for a wrapper-led segment
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).segment flags.clears IsWrapperLed for a non-wrapper segment
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).segment flags.sets HasLiveSubstitution for a dollar-paren inside a double-quoted span
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).segment flags.sets HasLiveSubstitution for a backtick inside a double-quoted span
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).segment flags.clears HasLiveSubstitution for an inert double-quoted span
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).segment flags.sets Unbalanced for an unterminated quote span
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).segment flags.clears Unbalanced for a balanced segment
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).ScanText clause order.clause 1 selects RawText for an unbalanced or live-substitution segment
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).ScanText clause order.clause 1 outranks clause 3, so a masked-eligible segment still scans raw
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).ScanText clause order.clause 2 selects RawText for a wrapper-led segment
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).ScanText clause order.clause 3 selects MaskedText for every other segment
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).wrapper carve-out set.exposes exactly the fourteen members named by D2 Piece 2
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).R-2 raw-scan predicate.R2-P1 reports true for a wrapper-led segment
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).R-2 raw-scan predicate.R2-P2 reports true for a segment carrying a live substitution
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).R-2 raw-scan predicate.R2-P3 reports true for an unbalanced segment
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).R-2 raw-scan predicate.R2-P4 reports false for a masked quoted mention in a non-wrapper segment
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).R-2 raw-scan predicate.R2-P5 reports false for a null segment
PASSED: hook-command-scanner (issue #545 D2 Piece 1 and Piece 2).D12 public parser contract.pins the Read-CommandLineSegment parameter list and OutputType
PASSED: hook-command-parser acceptance cases (issue #545).AT-1 - the mandatory latent-bypass case.AT-1 denies a relocating git worktree remove against an epic checkpoint with no authorizing record
PASSED: hook-command-parser acceptance cases (issue #545).AT-2 - the issue #591 operand mis-parse.AT-2 returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag
PASSED: hook-command-parser acceptance cases (issue #545).AT-3 - the promotion-hook over-match on receipt values.AT-3 allows a heredoc whose JSON body names promotion tools as receipt values
PASSED: hook-command-parser acceptance cases (issue #545).AT-4 - the merge-gate over-match on quoted prose.AT-4 allows a printf whose double-quoted text mentions the gated merge phrase
PASSED: hook-command-parser acceptance cases (issue #545).AT-5 - the promotion-hook gh relocation bypass.AT-5 blocks a relocating gh issue create spelling that carries a repo global option
PASSED: hook-command-parser acceptance cases (issue #545).AT-6 - the wrapper deny pin.AT-6 still classifies a pwsh -Command wrapper carrying a test invocation
PASSED: hook-command-parser acceptance cases (issue #545).AT-7 - the cross-runtime operand divergence.AT-7 resolves the worktree path when the force flag precedes it, in both removal gates
PASSED: hook-command-parser acceptance cases (issue #545).paired negatives that must hold alongside the acceptance cases.paired negative for AT-2: a bare gh pr merge --merge with no number still returns $null
PASSED: hook-command-parser acceptance cases (issue #545).paired negatives that must hold alongside the acceptance cases.paired negative for AT-2: the number-before-flag form gh pr merge 410 --merge still returns 410
PASSED: hook-command-parser acceptance cases (issue #545).paired negatives that must hold alongside the acceptance cases.paired negative for AT-3: a genuine promotion-script invocation still returns its blocked reason
PASSED: hook-command-parser acceptance cases (issue #545).paired negatives that must hold alongside the acceptance cases.paired negative for AT-5: a relocating gh issue list spelling still returns $null
PASSED: PreToolUse deny-schema contract (all 15 hooks).validate-bash.ps1 emits a PreToolUse deny shape
PASSED: PreToolUse deny-schema contract (all 15 hooks).enforce-promotion-mcp-only.ps1 emits a PreToolUse deny shape
PASSED: PreToolUse deny-schema contract (all 15 hooks).enforce-pr-author-skill.ps1 emits a PreToolUse deny shape
PASSED: PreToolUse deny-schema contract (all 15 hooks).enforce-orchestration-preimplementation-gate.ps1 emits a PreToolUse deny shape
PASSED: PreToolUse deny-schema contract (all 15 hooks).check-python-test-purity.ps1 emits a PreToolUse deny shape
PASSED: PreToolUse deny-schema contract (all 15 hooks).enforce-python-batch-budget.ps1 emits a PreToolUse deny shape
PASSED: PreToolUse deny-schema contract (all 15 hooks).check-powershell-test-purity.ps1 emits a PreToolUse deny shape
PASSED: PreToolUse deny-schema contract (all 15 hooks).enforce-powershell-batch-budget.ps1 emits a PreToolUse deny shape
PASSED: PreToolUse deny-schema contract (all 15 hooks).enforce-evidence-locations.ps1 emits a PreToolUse deny shape
PASSED: PreToolUse deny-schema contract (all 15 hooks).enforce-feature-folder-order.ps1 emits a PreToolUse deny shape
PASSED: PreToolUse deny-schema contract (all 15 hooks).enforce-checkpoint-monotonic.ps1 emits a PreToolUse deny shape
PASSED: PreToolUse deny-schema contract (all 15 hooks).enforce-completion-consistency.ps1 emits a PreToolUse deny shape
PASSED: PreToolUse deny-schema contract (all 15 hooks).enforce-prd-feature-before-planner.ps1 emits a PreToolUse deny shape
PASSED: PreToolUse deny-schema contract (all 15 hooks).enforce-epic-invocation-origin.ps1 emits a PreToolUse deny shape
PASSED: PreToolUse deny-schema contract (all 15 hooks).enforce-mermaid-validation.ps1 emits a PreToolUse deny shape
PASSED: gate suites isolate the epic checkpoint read (structural guard).tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 isolates the epic checkpoint read in its outermost BeforeAll
PASSED: gate suites isolate the epic checkpoint read (structural guard).tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 isolates the epic checkpoint read in its outermost BeforeAll
PASSED: gate suites isolate the epic checkpoint read (structural guard).tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 isolates the epic checkpoint read in its outermost BeforeAll
PASSED: gate suites isolate the epic checkpoint read (structural guard).tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 isolates the epic checkpoint read in its outermost BeforeAll
PASSED: gate suites isolate the epic checkpoint read (structural guard).tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 isolates the epic checkpoint read in its outermost BeforeAll
PASSED: gate suites isolate the epic checkpoint read (structural guard).tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 isolates the epic checkpoint read in its outermost BeforeAll
PASSED: gate suites isolate the epic checkpoint read (structural guard).tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 isolates the epic checkpoint read in its outermost BeforeAll
PASSED: gate suites isolate the epic checkpoint read (structural guard).tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 isolates the epic checkpoint read in its outermost BeforeAll
PASSED: gate suites isolate the epic checkpoint read (structural guard).guard predicate discrimination.accepts the compliant positional form with zero findings
PASSED: gate suites isolate the epic checkpoint read (structural guard).guard predicate discrimination.accepts the compliant -CommandName and -MockWith form with zero findings
PASSED: gate suites isolate the epic checkpoint read (structural guard).guard predicate discrimination.rejects a Mock that targets another command with a finding containing "missing from outermost BeforeAll"
PASSED: gate suites isolate the epic checkpoint read (structural guard).guard predicate discrimination.rejects a Mock without -ModuleName with a finding containing "lacks -ModuleName"
PASSED: gate suites isolate the epic checkpoint read (structural guard).guard predicate discrimination.rejects a Mock body other than $null with a finding containing "not exactly"
PASSED: gate suites isolate the epic checkpoint read (structural guard).guard predicate discrimination.rejects a Mock declared only in a nested Context BeforeAll with a finding containing "missing from outermost BeforeAll"
PASSED: gate suites isolate the epic checkpoint read (structural guard).guard predicate discrimination.rejects an Import-Module with -Force with a finding containing "uses -Force"
PASSED: gate suites isolate the epic checkpoint read (structural guard).guard predicate discrimination.rejects an import and Mock placed before the hook dot-source with a finding containing "order violated"
PASSED: gate suites isolate the epic checkpoint read (structural guard).guard predicate discrimination.rejects a missing Get-WorktreeRunCheckpointText Mock with a finding containing "Mock of Get-WorktreeRunCheckpointText missing from outermost BeforeAll"
PASSED: gate suites isolate the epic checkpoint read (structural guard).guard predicate discrimination.rejects a Get-WorktreeRunCheckpointText Mock without -ModuleName with a finding containing "Mock lacks -ModuleName WorktreeRunResolution"
PASSED: gate suites isolate the epic checkpoint read (structural guard).guard predicate discrimination.rejects a missing WorktreeRunResolution import with a finding containing "Import-Module of WorktreeRunResolution.psm1 missing from outermost BeforeAll"
PASSED: gate suites isolate the epic checkpoint read (structural guard).guard predicate discrimination.rejects a WorktreeRunResolution import with -Force with a finding containing "Import-Module of WorktreeRunResolution.psm1 uses -Force"
PASSED: gate suites isolate the epic checkpoint read (structural guard).guard predicate discrimination.reports a listed suite path that does not exist and names the path
PASSED: the run-checkpoint mocks block the epic-state read (seam sufficiency).gate 1 control: the hostile payload is epic scope without the mocks
PASSED: the run-checkpoint mocks block the epic-state read (seam sufficiency).gate 3 control: the hostile payload is epic scope without the mocks
PASSED: the run-checkpoint mocks block the epic-state read (seam sufficiency).gate 4 control: the hostile payload is epic scope without the mocks
PASSED: the run-checkpoint mocks block the epic-state read (seam sufficiency).gate 4 selector control: the hostile payload is epic scope without the mocks
PASSED: the run-checkpoint mocks block the epic-state read (seam sufficiency).gate 1 treatment A: both $null mocks block the target lookup and the epic-state read
PASSED: the run-checkpoint mocks block the epic-state read (seam sufficiency).gate 3 treatment A: both $null mocks block the target lookup and the epic-state read
PASSED: the run-checkpoint mocks block the epic-state read (seam sufficiency).gate 4 treatment A: both $null mocks block the target lookup and the epic-state read
PASSED: the run-checkpoint mocks block the epic-state read (seam sufficiency).gate 4 selector treatment A: both $null mocks block the target lookup and the epic-state read
PASSED: the run-checkpoint mocks block the epic-state read (seam sufficiency).gate 1 treatment B: the Get-EpicScopeCheckpointText mock alone blocks the epic-state read
PASSED: the run-checkpoint mocks block the epic-state read (seam sufficiency).gate 3 treatment B: the Get-EpicScopeCheckpointText mock alone blocks the epic-state read
PASSED: the run-checkpoint mocks block the epic-state read (seam sufficiency).gate 4 treatment B: the Get-EpicScopeCheckpointText mock alone blocks the epic-state read
PASSED: the run-checkpoint mocks block the epic-state read (seam sufficiency).gate 4 selector treatment B: the Get-EpicScopeCheckpointText mock alone blocks the epic-state read
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.resolves the preparation mode for its marker prompt
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.resolves the epic mode for its marker prompt
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.resolves the parallel mode for its marker prompt
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.resolves the single-feature mode for its marker prompt
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.resolves the preparation mode for its marker prompt
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.resolves the single-feature mode for its marker prompt
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.resolves the single-feature mode for its marker prompt
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.maps the preparation mode to its canonical checkpoint path
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.maps the epic mode to its canonical checkpoint path
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.maps the parallel mode to its canonical checkpoint path
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.maps the single-feature mode to its canonical checkpoint path
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.returns an empty checkpoint path for a mode name that is not in the table
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.accepts the declared checkpoint path for epic mode
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.accepts the declared checkpoint path for epic mode
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.rejects the declared checkpoint path for epic mode
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.accepts the declared checkpoint path for parallel mode
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.rejects the declared checkpoint path for parallel mode
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).target folder resolution parity.returns nothing for a prompt carrying no feature-folder token
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).target folder resolution parity.returns the parent basename for a token ending in a Markdown file
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).target folder resolution parity.returns the basename for a bare directory token
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).target folder resolution parity.returns the basename for a token followed by sentence punctuation
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).target folder resolution parity.returns nothing for a prompt carrying no issue number
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).target folder resolution parity.returns the numeric string for a keyed issue number
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).target folder resolution parity.returns the numeric string for a bare-hash issue number
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).the mode deny-reason builder.builds an epic deny reason naming the epic checkpoint and the failed predicate
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).the mode deny-reason builder.builds a parallel deny reason naming the parallel checkpoint and the failed predicate
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.names route_id as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.names epic_feature_folder as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.names epic_manifest_path as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.names integration_branch as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.names features as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.names target-record as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.names merge_status as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.reports ready for the epic readiness wrapper
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.denies the terminal-merged worktree_removed status for the epic readiness wrapper
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.allows the failure status blocked_conflict_loop_limit for the epic readiness wrapper
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.returns false from the wrapper for a null checkpoint
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.names route_id as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.names parallel_slug as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.names parallel_manifest_path as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.names items as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.names target-record as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.names merge_status as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.reports ready for the parallel readiness wrapper
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.denies the terminal-merged worktree_removed status for the parallel readiness wrapper
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.allows the blocked status blocked_drift, adding no enum member for the parallel readiness wrapper
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.returns false from the wrapper for a null checkpoint
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).classifier parity through the mapped flat tool_input the Codex seam consumes.classifies atomic-executor as implementation: True
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).classifier parity through the mapped flat tool_input the Codex seam consumes.classifies powershell-typed-engineer as implementation: True
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).classifier parity through the mapped flat tool_input the Codex seam consumes.classifies task-researcher as implementation: False
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).classifier parity through the mapped flat tool_input the Codex seam consumes.classifies orchestrator as implementation: False
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).classifier parity through the mapped flat tool_input the Codex seam consumes.classifies orchestrator as implementation: True
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).the preparation-mode delegation predicate on the Codex surface.returns false for a non-orchestrator subagent type carrying both preparation markers on the Codex surface
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).the preparation-mode delegation predicate on the Codex surface.returns true for an orchestrator carrying both preparation markers on the Codex surface
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).the recorded Agent-transport gap (decision D5, deliverable ii).registers no PreToolUse matcher admitting an Agent or Task tool name
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the epic leg of the decision router.allows an epic-mode delegation against an injected ready epic checkpoint
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the epic leg of the decision router.denies an epic-mode delegation and names integration_branch as the failed predicate
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the epic leg of the decision router.denies an epic-mode delegation whose injected checkpoint text is malformed JSON
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the epic leg of the decision router.denies an epic-mode delegation whose injected checkpoint text is empty
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the epic leg of the decision router.denies an epic-mode delegation that declares a non-canonical checkpoint path
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the parallel leg of the decision router.allows a parallel-mode delegation against an injected ready parallel checkpoint
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the parallel leg of the decision router.denies a parallel-mode delegation and names parallel_slug as the failed predicate
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the parallel leg of the decision router.denies a parallel-mode delegation whose injected checkpoint declares the epic route
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the per-mode read seams supply the checkpoint when no text is injected.denies an epic-mode delegation against the canonical epic checkpoint read seam
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the per-mode read seams supply the checkpoint when no text is injected.denies a parallel-mode delegation against the canonical parallel checkpoint read seam
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the mode legs do not capture a non-implementation delegation.allows a research delegation that carries the epic marker
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a quoted mention of the staging invocation inside an echo argument
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a heredoc body that quotes the staging invocation in prose
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a heredoc whose JSON body names a governed tool as a receipt value
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows prose containing the English word black
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a cross-segment line whose npm segment and lint mention are in different segments
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).under-match deny cases - the latent bypass.denies a relocating git add carrying a directory global option
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).under-match deny cases - the latent bypass.denies a relocating git commit carrying a git-dir global option
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).under-match deny cases - the latent bypass.denies a relocating git add carrying a work-tree global option
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).under-match deny cases - the latent bypass.denies an unmodeled dash-leading token between git and its subcommand
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).under-match deny cases - the latent bypass.denies the subshell spelling of a staging command
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).under-match deny cases - the latent bypass.denies the command-substitution spelling of a staging command
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).the non-classifying stop case.does not classify git log --grep add as a staging command
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 1: denies a staging command relocated through xargs
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 2: denies a staging command nested inside a bash -c argument
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 3: denies a staging command nested inside an sh -c argument
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 4: denies a staging command behind the env transparent wrapper
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 5: denies a test invocation behind the pwsh -Command wrapper
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 6: denies a heredoc body piped into bash
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 7: denies a live substitution inside a double-quoted span
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).apply_patch marker legs are unaffected (Codex-only).still classifies an apply_patch add of a production script
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).apply_patch marker legs are unaffected (Codex-only).still declines to classify an apply_patch add of feature documentation
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).apply_patch marker legs are unaffected (Codex-only).still classifies an apply_patch rename onto a production script
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).apply_patch marker legs are unaffected (Codex-only).still declines to classify an apply_patch update of feature documentation
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the repo-relative spelling of artifacts/orchestration/orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the forward-slash absolute spelling of artifacts/orchestration/orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the backslash absolute spelling of artifacts/orchestration/orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the repo-relative spelling of artifacts/orchestration/parallel-planner-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the forward-slash absolute spelling of artifacts/orchestration/parallel-planner-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the backslash absolute spelling of artifacts/orchestration/parallel-planner-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the repo-relative spelling of artifacts/orchestration/parallel-orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the forward-slash absolute spelling of artifacts/orchestration/parallel-orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the backslash absolute spelling of artifacts/orchestration/parallel-orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the repo-relative spelling of artifacts/orchestration/epic-planner-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the forward-slash absolute spelling of artifacts/orchestration/epic-planner-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the backslash absolute spelling of artifacts/orchestration/epic-planner-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the repo-relative spelling of artifacts/orchestration/epic-orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the forward-slash absolute spelling of artifacts/orchestration/epic-orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the backslash absolute spelling of artifacts/orchestration/epic-orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the repo-relative spelling of artifacts/orchestration/powershell-orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the forward-slash absolute spelling of artifacts/orchestration/powershell-orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the backslash absolute spelling of artifacts/orchestration/powershell-orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the repo-relative spelling of artifacts/orchestration/csharp-orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the forward-slash absolute spelling of artifacts/orchestration/csharp-orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.allows the backslash absolute spelling of artifacts/orchestration/csharp-orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.admits the POSIX-shaped absolute spelling of artifacts/orchestration/orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.checkpoint exemption holds in every spelling.admits the leading dot-slash relative spelling of artifacts/orchestration/orchestrator-state.json
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.documentation exemption holds in every spelling.allows the repo-relative spelling of a feature-folder .json artifact
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.documentation exemption holds in every spelling.allows the forward-slash absolute spelling of a feature-folder .json artifact
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.documentation exemption holds in every spelling.allows the backslash absolute spelling of a feature-folder .json artifact
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.case handling is zero-delta against the previous operators.allows an absolute checkpoint path whose literal differs only in letter case
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.case handling is zero-delta against the previous operators.denies an absolute path whose documentation prefix differs only in letter case
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.negative half stays denied.denies a synthetic absolute path ending in a production .ps1 file
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.negative half stays denied.denies a synthetic absolute path ending in a production .py file
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.negative half stays denied.denies a synthetic absolute path ending in a orchestration JSON whose name is not one of the seven literals
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.negative half stays denied.denies a synthetic absolute path ending in a checkpoint-named JSON with no preceding artifacts/orchestration segment
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.negative half stays denied.denies a synthetic absolute path ending in a checkpoint name reached only through a parent-directory hop
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.apply_patch file markers classify exactly as before.denies a repo-relative file-marker path for a production .ps1 file
PASSED: codex enforce-orchestration-preimplementation-gate.ps1 absolute-path classification.apply_patch file markers classify exactly as before.allows a repo-relative file-marker path for a checkpoint literal
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.allows a safe Edit payload on every group handler
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.allows a safe Write payload on every group handler
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.allows a safe apply_patch payload on every group handler
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.allows a well-formed apply_patch payload whose tool_input maps to no file edit (command:'')
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.allows a well-formed apply_patch payload whose tool_input maps to no file edit (command:'noop')
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.fails closed with exit 2 when a batch-budget payload omits session_id
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.allows an apply_patch update that touches only ungoverned files with a missing source
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for check-python-test-purity.ps1 on a forbidden Edit payload
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for check-python-test-purity.ps1 on a forbidden Write payload
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for check-python-test-purity.ps1 on a forbidden apply_patch payload
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for check-powershell-test-purity.ps1 on a forbidden Edit payload
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for check-powershell-test-purity.ps1 on a forbidden Write payload
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for check-powershell-test-purity.ps1 on a forbidden apply_patch payload
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for enforce-evidence-locations.ps1 on a forbidden Edit payload
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for enforce-evidence-locations.ps1 on a forbidden Write payload
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for enforce-evidence-locations.ps1 on a forbidden apply_patch payload
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for enforce-checkpoint-monotonic.ps1 on a forbidden Write payload
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for enforce-checkpoint-monotonic.ps1 on a forbidden apply_patch payload
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for enforce-checkpoint-monotonic.ps1 on a forbidden Edit payload
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for enforce-completion-consistency.ps1 on a forbidden Write payload
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for enforce-completion-consistency.ps1 on a forbidden apply_patch payload
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.emits only the native deny envelope for enforce-completion-consistency.ps1 on a forbidden Edit payload
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.denies a preimplementation-gate implementation path mapped from Edit
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.denies a preimplementation-gate implementation path mapped from Write
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.denies a preimplementation-gate implementation path mapped from apply_patch
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.fails closed with exit 2 for a missing tool_input on every group handler
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.fails closed with exit 2 for a null tool_input on every group handler
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).returns null checkpoint content when the path is not a file
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).returns the file text when the checkpoint path resolves to a file
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).returns an empty string for a null checkpoint payload property lookup
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).returns an empty string when the checkpoint property value is null
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).treats a null payload as asserting no completion
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).detects completion asserted by next_step
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).detects completion asserted by completed_steps
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).detects completion asserted by step8_status
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).detects completion asserted by step9_status
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).detects completion asserted by step10_status
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).detects no completion assertion for an in-progress next_step
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).detects no completion assertion for completed_steps without the terminal step
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).detects no completion assertion for an empty completed_steps list
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).detects no completion assertion for an in-progress step8_status
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows when no mapped tool_input is supplied
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).throws a hook-named error for malformed mapped tool_input JSON
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows mapped tool_input that carries no file_path
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows a file path that is not the governed checkpoint
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).denies a checkpoint edit whose patch cannot be resolved
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows a checkpoint write that does not assert completion
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).denies a completion-asserting checkpoint write through its own entrypoint
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).allows an unrelated mapped write through its own entrypoint
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).fails closed with exit 2 when its entrypoint receives empty stdin
PASSED: Codex PreToolUse hooks honour the native stdin transport contract.enforce-completion-consistency in-process behaviour (issue #415 R1).reads issue-num and feature-folder from variables and reports ci_gate gaps
PASSED: Codex completion-consistency gate epic checkpoint (issue #707).epic checkpoint writes are not intercepted.does not intercept a completion-asserting Write to the epic checkpoint
PASSED: Codex completion-consistency gate epic checkpoint (issue #707).epic checkpoint writes are not intercepted.does not intercept a completion-asserting Edit to the epic checkpoint
PASSED: Codex completion-consistency gate epic checkpoint (issue #707).epic checkpoint writes are not intercepted.does not intercept an apply_patch Add of the epic checkpoint
PASSED: Codex completion-consistency gate epic checkpoint (issue #707).epic checkpoint writes are not intercepted.emits no mapped record for an apply_patch Update of the epic checkpoint
PASSED: Codex completion-consistency gate epic checkpoint (issue #707).per-feature checkpoint writes are still intercepted.still denies a completion-asserting per-feature checkpoint whose feature-folder is under docs/features/epics/
PASSED: Codex completion-consistency gate epic checkpoint (issue #707).per-feature checkpoint writes are still intercepted.still denies a completion-asserting per-feature checkpoint that lacks ci_gate
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).structural git classification.classifies a relocating git add carrying a directory global option
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).structural git classification.classifies a relocating git commit carrying a git-dir global option
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).structural git classification.classifies a relocating git add carrying a work-tree global option
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).structural git classification.classifies an unmodeled dash-leading token between git and its subcommand
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).structural git classification.does not classify git log --grep add, because a non-dash non-target token stops the scan
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).structural git classification.classifies the plain adjacent spelling
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).structural git classification.skips VAR=value prefixes and transparent wrappers before the command word
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).structural gh classification.classifies gh pr create carrying a repo global option in the equals form
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).structural gh classification.classifies gh issue create carrying a short repo global option
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).structural gh classification.does not classify gh issue list as gh issue create
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).operand retrieval.returns the worktree path for the flag-before-path spelling
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).operand retrieval.returns the worktree path for the flag-after-path spelling
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).operand retrieval.takes operands from the matched segment only, so a chained cd contributes nothing
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).operand retrieval.consumes a modeled option-with-argument pair rather than returning its value
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).operand retrieval.treats a token after a bare double-dash separator as an operand
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).operand retrieval.returns an empty array when no segment matched
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).operand retrieval.returns the pull-request number for the anchored gh pr merge spelling
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).Get-CommandLineFlagValue.recognises the separated form
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).Get-CommandLineFlagValue.recognises the equals form
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).Get-CommandLineFlagValue.resolves the number across a chained cd, which is the issue #591 fix
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).Get-CommandLineFlagValue.returns null for an absent flag
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).Get-CommandLineFlagValue.returns null for a present flag with no following value
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).Get-CommandLineFlagValue.returns null when the following token is itself dash-leading
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).Test-CommandLineFlag.distinguishes an absent flag from a valueless present flag
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).Test-CommandLineFlag.distinguishes --body from --body-file
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).Test-CommandLineFlag.reports a flag present in the equals form
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).Test-CommandLineMention.returns true only when the invocation predicate returns false
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).Test-CommandLineMention.returns false for a genuine invocation
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).Test-CommandLineMention.returns false when the text does not contain the words at all
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).fail-closed rules.classifies a wrapper-led segment whose payload invokes the command
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).fail-closed rules.classifies a live-substitution segment by the same wrapper rule
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).fail-closed rules.classifies an unbalanced segment, because its structure could not be resolved
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).fail-closed rules.classifies the subshell and command-substitution spellings
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).fail-closed rules.does not classify a quoted mention in a non-wrapper segment
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).constant tables.exposes exactly the five transparent wrappers of D2 Piece 3 step 2
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).constant tables.exposes exactly the modeled git global options
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).constant tables.exposes exactly the modeled gh global options
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).constant tables.exposes exactly the modeled npx global options
PASSED: hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12).constant tables.returns two empty lists for an unmodeled command word, which is fail-closed
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).empty input.returns an empty array for null input
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).empty input.returns an empty array for empty input
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).empty input.returns an empty array for whitespace-only input
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).segment delimiters.splits on a semicolon
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).segment delimiters.splits on an ampersand
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).segment delimiters.splits on a pipe
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).segment delimiters.splits on a newline
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).segment delimiters.treats the subshell opener and closer as delimiters
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).segment delimiters.treats the group opener and closer as delimiters
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).segment delimiters.treats the substitution opener as a delimiter
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).segment delimiters.treats the backtick as a delimiter
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).quoted-span masking.masks a single-quoted span
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).quoted-span masking.masks a double-quoted span
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).quoted-span masking.preserves nothing of the masked content, so mask length equals span length
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).tokenizer.yields one token per double-quoted span with the delimiting quotes removed
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).tokenizer.produces no adjacent token pair equal to the recursive-remove literal
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).tokenizer.keeps a quoted span attached to the token it sits in
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).tokenizer.emits an empty token for an empty quoted string
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).tokenizer.collapses runs of whitespace between tokens
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).heredoc rules.masks the body of a plain heredoc
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).heredoc rules.masks the body of a tab-stripping heredoc whose terminator is tab-indented
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).heredoc rules.masks the body of a heredoc whose delimiter is quoted
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).heredoc rules.consumes multiple pending heredocs on one physical line in order
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).heredoc rules.masks an unterminated heredoc body to end of text and reports it unbalanced
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).heredoc rules.does not treat a three-angle here-string as a heredoc
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).heredoc rules.forces a raw scan when the heredoc delimiter is produced by expansion
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).CommandWord determination.returns the first token when there is no env-assignment prefix
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).CommandWord determination.skips VAR=value env-assignment prefixes
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).CommandWord determination.returns the empty string when the segment carries only assignments
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).segment flags.sets IsWrapperLed for a wrapper-led segment
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).segment flags.clears IsWrapperLed for a non-wrapper segment
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).segment flags.sets HasLiveSubstitution for a dollar-paren inside a double-quoted span
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).segment flags.sets HasLiveSubstitution for a backtick inside a double-quoted span
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).segment flags.clears HasLiveSubstitution for an inert double-quoted span
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).segment flags.sets Unbalanced for an unterminated quote span
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).segment flags.clears Unbalanced for a balanced segment
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).ScanText clause order.clause 1 selects RawText for an unbalanced or live-substitution segment
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).ScanText clause order.clause 1 outranks clause 3, so a masked-eligible segment still scans raw
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).ScanText clause order.clause 2 selects RawText for a wrapper-led segment
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).ScanText clause order.clause 3 selects MaskedText for every other segment
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).wrapper carve-out set.exposes exactly the fourteen members named by D2 Piece 2
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).R-2 raw-scan predicate.R2-P1 reports true for a wrapper-led segment
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).R-2 raw-scan predicate.R2-P2 reports true for a segment carrying a live substitution
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).R-2 raw-scan predicate.R2-P3 reports true for an unbalanced segment
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).R-2 raw-scan predicate.R2-P4 reports false for a masked quoted mention in a non-wrapper segment
PASSED: hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2).R-2 raw-scan predicate.R2-P5 reports false for a null segment
PASSED: Legacy Codex hooks use native lifecycle contracts.parse-checks each root and bundled hook and keeps every file within 500 lines
PASSED: Legacy Codex hooks use native lifecycle contracts.keeps the canonical hooks byte-identical to their bundled copies
PASSED: Legacy Codex hooks use native lifecycle contracts.reads stdin in every hook entrypoint
PASSED: Legacy Codex hooks use native lifecycle contracts.contains no legacy Claude environment-variable dependency in hooks or shared modules
PASSED: Legacy Codex hooks use native lifecycle contracts.lists every shared hook module in the core pack manifest
PASSED: Legacy Codex hooks use native lifecycle contracts.ignores poisoned Claude variables when safe Codex stdin payloads are supplied
PASSED: Legacy Codex hooks use native lifecycle contracts.fails closed with exit 2 and stderr for malformed stdin on every hook
PASSED: Legacy Codex hooks use native lifecycle contracts.emits the current PreToolUse deny envelope for shell and patch violations
PASSED: Legacy Codex hooks use native lifecycle contracts.fails closed when the canonical checkpoint is deleted or becomes invalid JSON
PASSED: Legacy Codex hooks use native lifecycle contracts.denies preimplementation and batch-budget violations through their pure decisions
PASSED: Legacy Codex hooks use native lifecycle contracts.allows exempt checkpoint writes and preparation-mode delegations (issue #535)
PASSED: Legacy Codex hooks use native lifecycle contracts.reconstructs update patches in memory and includes move destinations
PASSED: Legacy Codex hooks use native lifecycle contracts.uses one SubagentStop continuation and stops repeated continuation loops
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies a feature documentation path as implementation path False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies the orchestrator checkpoint as implementation path False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies a production script as implementation path True
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies a plain text file as implementation path False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies an empty command as implementation command False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies an apply_patch add of a script as implementation command True
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies an apply_patch add of documentation as implementation command False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies an apply_patch rename onto a script as implementation command True
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies a git commit as implementation command True
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies a pytest run as implementation command True
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies an unrelated command as implementation command False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a null tool_input as no implementation delegation
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).detects an implementation delegation inside a serialized tool_input
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats an unrelated serialized tool_input as no delegation
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a null checkpoint payload as not ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a checkpoint missing lifecycle readiness as not ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a complete checkpoint as ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).returns empty checkpoint content when the checkpoint file is absent
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).returns the checkpoint file content when the checkpoint file is present
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows when no mapped tool_input is supplied
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).throws a hook-named error for malformed mapped tool_input JSON
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows a documentation file path without consulting the checkpoint
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an implementation command when the checkpoint is not ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an implementation delegation when the checkpoint is not ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows an implementation path when the checkpoint is ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).reads the checkpoint from disk when no checkpoint text is supplied
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an apply_patch implementation through its own entrypoint
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies a mapped Edit implementation through its own entrypoint
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows a mapped Write of feature documentation through its own entrypoint
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).fails closed with exit 2 when its entrypoint receives empty stdin
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies the issue 732 brace-expansion shape
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies the issue 732 escaped dot-segment shape
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies an escaped semicolon in a message
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies an escaped ampersand in a message
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies an escaped pipe in a message
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a mixed dot-backslash segment in an operand
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a backslash-spelled operand
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a comma brace in an operand
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a range brace in an operand
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a brace in an unquoted message
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies an unquoted comma in a message
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies an unquoted at-sign name in a message
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies an unquoted opening parenthesis in a message
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies an unquoted closing parenthesis in a message
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a star glob under an exempt tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a question-mark glob under an exempt tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a bracket glob under an exempt tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a leading slash
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a leading double slash
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a parent-directory segment
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a drive-letter operand
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a tilde in an operand
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a percent sign in an operand
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a caret in an operand
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies an exclamation mark in an operand
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies an equals sign in an operand
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a plus sign in an operand
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a non-ASCII division-slash look-alike in an operand
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an ordinary operand under the epics tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an ordinary operand under the parallel tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an ordinary operand under the active tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an ordinary operand under the potential tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an ordinary operand under the orchestration artifacts tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an operand with a dot segment inside an exempt tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits a single-quoted message containing an opening brace
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits a single-quoted message containing a comma
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits a single-quoted message containing an opening parenthesis
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits a single-quoted message containing an at sign
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies the issue 732 brace-expansion shape
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies the issue 732 escaped dot-segment shape
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies an escaped semicolon in a message
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies an escaped ampersand in a message
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies an escaped pipe in a message
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a mixed dot-backslash segment in an operand
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a backslash-spelled operand
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a comma brace in an operand
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a range brace in an operand
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a brace in an unquoted message
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies an unquoted comma in a message
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies an unquoted at-sign name in a message
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies an unquoted opening parenthesis in a message
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies an unquoted closing parenthesis in a message
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a star glob under an exempt tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a question-mark glob under an exempt tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a bracket glob under an exempt tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a leading slash
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a leading double slash
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a parent-directory segment
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a drive-letter operand
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a tilde in an operand
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a percent sign in an operand
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a caret in an operand
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies an exclamation mark in an operand
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies an equals sign in an operand
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a plus sign in an operand
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a non-ASCII division-slash look-alike in an operand
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an ordinary operand under the epics tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an ordinary operand under the parallel tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an ordinary operand under the active tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an ordinary operand under the potential tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an ordinary operand under the orchestration artifacts tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an operand with a dot segment inside an exempt tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits a single-quoted message containing an opening brace
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits a single-quoted message containing a comma
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits a single-quoted message containing an opening parenthesis
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits a single-quoted message containing an at sign
PASSED: enforce-orchestration-preimplementation-gate.ps1 exempt-operand bypass (issue #732).denies the issue 732 brace-expansion shape without an authorizing checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1 exempt-operand bypass (issue #732).denies the issue 732 escaped dot-segment shape without an authorizing checkpoint
PASSED: Codex preimplementation gate exempt-operand bypass (issue #732).denies the issue 732 brace-expansion shape without an authorizing checkpoint
PASSED: Codex preimplementation gate exempt-operand bypass (issue #732).denies the issue 732 escaped dot-segment shape without an authorizing checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a second segment that targets a different not-ready worktree
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a relative -C selector in epic scope
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies an unresolvable -C selector in epic scope
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a directory-changing segment in epic scope
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a wrapper-led git segment in epic scope
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write into a not-ready epic worktree
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a target outside the epic scope of the session root
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).evaluates every value of a repeated -C selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).allows when every target is epic scope and ready
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).keeps the single-feature decision for a relative -C selector outside epic scope
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).keeps the single-feature decision for a directory change outside epic scope
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies an ambiguous epic target
PASSED: Codex preimplementation gate epic-scope targets (issue #738).denies a second segment that targets a different not-ready worktree
PASSED: Codex preimplementation gate epic-scope targets (issue #738).denies a relative -C selector in epic scope
PASSED: Codex preimplementation gate epic-scope targets (issue #738).denies an unresolvable -C selector in epic scope
PASSED: Codex preimplementation gate epic-scope targets (issue #738).denies a directory-changing segment in epic scope
PASSED: Codex preimplementation gate epic-scope targets (issue #738).denies a wrapper-led git segment in epic scope
PASSED: Codex preimplementation gate epic-scope targets (issue #738).denies a target outside the epic scope of the session root
PASSED: Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch absolute file marker into a not-ready epic worktree
PASSED: Codex preimplementation gate epic-scope targets (issue #738).evaluates every value of a repeated -C selector
PASSED: Codex preimplementation gate epic-scope targets (issue #738).allows when every target is epic scope and ready
PASSED: Codex preimplementation gate epic-scope targets (issue #738).keeps the single-feature decision for a relative -C selector outside epic scope
PASSED: Codex preimplementation gate epic-scope targets (issue #738).keeps the single-feature decision for a directory change outside epic scope
PASSED: Codex preimplementation gate epic-scope targets (issue #738).resolves a segment without -C to the session root
PASSED: Codex preimplementation gate epic-scope targets (issue #738).denies an ambiguous epic target
PASSED: preimplementation gate targets (.claude/hooks).U01 resolves an absolute path-leg input to itself
PASSED: preimplementation gate targets (.claude/hooks).U02 resolves a relative path-leg input to the session root
PASSED: preimplementation gate targets (.claude/hooks).U03 denies an absolute path-leg input with a dot segment
PASSED: preimplementation gate targets (.claude/hooks).U04 normalizes a backslash path-leg input
PASSED: preimplementation gate targets (.claude/hooks).U05 resolves two patch-marker paths in order
PASSED: preimplementation gate targets (.claude/hooks).U06 denies an unbalanced segment
PASSED: preimplementation gate targets (.claude/hooks).U07 gives directory-change for cd
PASSED: preimplementation gate targets (.claude/hooks).U07 gives directory-change for pushd
PASSED: preimplementation gate targets (.claude/hooks).U07 gives directory-change for popd
PASSED: preimplementation gate targets (.claude/hooks).U07 gives directory-change for chdir
PASSED: preimplementation gate targets (.claude/hooks).U07 gives directory-change for Set-Location
PASSED: preimplementation gate targets (.claude/hooks).U07 gives directory-change for sl
PASSED: preimplementation gate targets (.claude/hooks).U07 gives directory-change for Push-Location
PASSED: preimplementation gate targets (.claude/hooks).U07 gives directory-change for Pop-Location
PASSED: preimplementation gate targets (.claude/hooks).U08 denies a wrapper-led git segment without reading its -C value
PASSED: preimplementation gate targets (.claude/hooks).U09 denies a substitution-bearing git segment
PASSED: preimplementation gate targets (.claude/hooks).U10 resolves a wrapper-led non-git segment to the session root
PASSED: preimplementation gate targets (.claude/hooks).U11 gives git-relocation for GIT_DIR=/x git add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U11 gives git-relocation for GIT_WORK_TREE=/x git add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U11 gives git-relocation for GIT_COMMON_DIR=/x git add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U11 gives git-relocation for GIT_INDEX_FILE=/x git add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U11 gives git-relocation for export GIT_DIR=/x && git add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U12 gives git-relocation for git --git-dir=/x add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U12 gives git-relocation for git --git-dir /x add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U12 gives git-relocation for git --work-tree /x add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U12 gives git-relocation for git -c core.worktree=/x add a.ps1
PASSED: preimplementation gate targets (.claude/hooks).U13 collects every value of a repeated -C selector
PASSED: preimplementation gate targets (.claude/hooks).U14 gives selector-not-absolute for a relative and a UNC selector
PASSED: preimplementation gate targets (.claude/hooks).U15 gives selector-dot-segment for a dot and a dot-dot selector
PASSED: preimplementation gate targets (.claude/hooks).U16 gives selector-backslash for a backslash selector
PASSED: preimplementation gate targets (.claude/hooks).U17 gives selector-missing-value for a trailing -C
PASSED: preimplementation gate targets (.claude/hooks).U18 gives git-option-unmodeled for an unknown global option
PASSED: preimplementation gate targets (.claude/hooks).U19 resolves a chained command to the session root and the selector
PASSED: preimplementation gate targets (.claude/hooks).U20 rejects a relative session root and normalizes a backslash session root
PASSED: preimplementation gate targets (.claude/hooks).U21 returns the four patch-marker paths and nothing for a plain command
PASSED: preimplementation gate targets (.claude/hooks).U22 gives none for no epic scope
PASSED: preimplementation gate targets (.claude/hooks).U22 gives deny for an unresolved target result
PASSED: preimplementation gate targets (.claude/hooks).U22 gives deny for an ambiguous target
PASSED: preimplementation gate targets (.claude/hooks).U22 gives deny for an unresolved selector target
PASSED: preimplementation gate targets (.claude/hooks).U22 gives deny for a non-epic target
PASSED: preimplementation gate targets (.claude/hooks).U22 gives evaluate for all-epic targets
PASSED: preimplementation gate targets (.claude/hooks).U23 resolves a target equal to the session root once
PASSED: preimplementation gate targets (.codex/hooks).U01 resolves an absolute path-leg input to itself
PASSED: preimplementation gate targets (.codex/hooks).U02 resolves a relative path-leg input to the session root
PASSED: preimplementation gate targets (.codex/hooks).U03 denies an absolute path-leg input with a dot segment
PASSED: preimplementation gate targets (.codex/hooks).U04 normalizes a backslash path-leg input
PASSED: preimplementation gate targets (.codex/hooks).U05 resolves two patch-marker paths in order
PASSED: preimplementation gate targets (.codex/hooks).U06 denies an unbalanced segment
PASSED: preimplementation gate targets (.codex/hooks).U07 gives directory-change for cd
PASSED: preimplementation gate targets (.codex/hooks).U07 gives directory-change for pushd
PASSED: preimplementation gate targets (.codex/hooks).U07 gives directory-change for popd
PASSED: preimplementation gate targets (.codex/hooks).U07 gives directory-change for chdir
PASSED: preimplementation gate targets (.codex/hooks).U07 gives directory-change for Set-Location
PASSED: preimplementation gate targets (.codex/hooks).U07 gives directory-change for sl
PASSED: preimplementation gate targets (.codex/hooks).U07 gives directory-change for Push-Location
PASSED: preimplementation gate targets (.codex/hooks).U07 gives directory-change for Pop-Location
PASSED: preimplementation gate targets (.codex/hooks).U08 denies a wrapper-led git segment without reading its -C value
PASSED: preimplementation gate targets (.codex/hooks).U09 denies a substitution-bearing git segment
PASSED: preimplementation gate targets (.codex/hooks).U10 resolves a wrapper-led non-git segment to the session root
PASSED: preimplementation gate targets (.codex/hooks).U11 gives git-relocation for GIT_DIR=/x git add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U11 gives git-relocation for GIT_WORK_TREE=/x git add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U11 gives git-relocation for GIT_COMMON_DIR=/x git add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U11 gives git-relocation for GIT_INDEX_FILE=/x git add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U11 gives git-relocation for export GIT_DIR=/x && git add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U12 gives git-relocation for git --git-dir=/x add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U12 gives git-relocation for git --git-dir /x add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U12 gives git-relocation for git --work-tree /x add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U12 gives git-relocation for git -c core.worktree=/x add a.ps1
PASSED: preimplementation gate targets (.codex/hooks).U13 collects every value of a repeated -C selector
PASSED: preimplementation gate targets (.codex/hooks).U14 gives selector-not-absolute for a relative and a UNC selector
PASSED: preimplementation gate targets (.codex/hooks).U15 gives selector-dot-segment for a dot and a dot-dot selector
PASSED: preimplementation gate targets (.codex/hooks).U16 gives selector-backslash for a backslash selector
PASSED: preimplementation gate targets (.codex/hooks).U17 gives selector-missing-value for a trailing -C
PASSED: preimplementation gate targets (.codex/hooks).U18 gives git-option-unmodeled for an unknown global option
PASSED: preimplementation gate targets (.codex/hooks).U19 resolves a chained command to the session root and the selector
PASSED: preimplementation gate targets (.codex/hooks).U20 rejects a relative session root and normalizes a backslash session root
PASSED: preimplementation gate targets (.codex/hooks).U21 returns the four patch-marker paths and nothing for a plain command
PASSED: preimplementation gate targets (.codex/hooks).U22 gives none for no epic scope
PASSED: preimplementation gate targets (.codex/hooks).U22 gives deny for an unresolved target result
PASSED: preimplementation gate targets (.codex/hooks).U22 gives deny for an ambiguous target
PASSED: preimplementation gate targets (.codex/hooks).U22 gives deny for an unresolved selector target
PASSED: preimplementation gate targets (.codex/hooks).U22 gives deny for a non-epic target
PASSED: preimplementation gate targets (.codex/hooks).U22 gives evaluate for all-epic targets
PASSED: preimplementation gate targets (.codex/hooks).U23 resolves a target equal to the session root once
PASSED: enforce-orchestration-preimplementation-gate-targets.ps1 surface parity (issue #738).keeps all four surface copies of the targets module byte-identical by SHA256 hash
PASSED: enforce-orchestration-preimplementation-gate-targets.ps1 surface parity (issue #738).keeps every surface copy of the targets module under the 500-line cap
```

Output Summary: PassedCount 1594, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0; 0 FAILED: lines listed above.

Run history: run 1 (preserved as phase5-all-scoped.run1-failed.md) failed 10 D2A rows (the issue #671 LACS L8 and empty-token rows on both surfaces) with "Cannot bind argument to parameter Token because it is an empty string" at Get-OrchestrationCommandTarget, because Get-OrchestrationGitSelectorTarget declared a mandatory string[] Token parameter without AllowEmptyString. Fix: added [AllowEmptyString()] to that parameter in .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 and re-ran R-MIRROR to the three byte copies (mirror log, task [P5-T6 fix]). This run (run 2) is the result of record: FAILED set empty, a subset of B_SCOPED; no protected-suite test fails.
