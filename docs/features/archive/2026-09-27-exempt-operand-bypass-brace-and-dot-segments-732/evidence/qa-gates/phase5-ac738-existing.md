# Phase 5 AC738-EXISTING regression run (issue #738)

Timestamp: 2026-10-09T04-12
Task: [P5-T5]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/scoped-task.sh (R-SCOPED over 15 files)
EXIT_CODE: 0

## Output

```text
FILES: 15
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
PassedCount: 401
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
```

Output Summary: PassedCount 401, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0; 0 FAILED: lines listed above.

