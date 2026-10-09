# Fail-before run over the section-5.5 and section-5.6 files (issue #738)

Timestamp: 2026-10-09T04-01
Task: [P3-T6]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/scoped-task.sh (R-SCOPED over 4 files)
EXIT_CODE: 1
ExpectedExitCode: 1

## Output

```text
FILES: 4
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
PassedCount: 79
FailedCount: 20
FailedBlocksCount: 0
FailedContainersCount: 0
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a second segment that targets a different not-ready worktree
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a relative -C selector in epic scope
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies an unresolvable -C selector in epic scope
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a directory-changing segment in epic scope
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a wrapper-led git segment in epic scope
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write into a not-ready epic worktree
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a target outside the epic scope of the session root
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).evaluates every value of a repeated -C selector
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies an ambiguous epic target
FAILED: Codex preimplementation gate epic-scope targets (issue #738).denies a second segment that targets a different not-ready worktree
FAILED: Codex preimplementation gate epic-scope targets (issue #738).denies a relative -C selector in epic scope
FAILED: Codex preimplementation gate epic-scope targets (issue #738).denies an unresolvable -C selector in epic scope
FAILED: Codex preimplementation gate epic-scope targets (issue #738).denies a directory-changing segment in epic scope
FAILED: Codex preimplementation gate epic-scope targets (issue #738).denies a wrapper-led git segment in epic scope
FAILED: Codex preimplementation gate epic-scope targets (issue #738).denies a target outside the epic scope of the session root
FAILED: Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch absolute file marker into a not-ready epic worktree
FAILED: Codex preimplementation gate epic-scope targets (issue #738).evaluates every value of a repeated -C selector
FAILED: Codex preimplementation gate epic-scope targets (issue #738).denies an ambiguous epic target
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies a -C selector worktree outside the session-root epic scope as target-mixed (issue #738)
FAILED: Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.a -C selector command whose selector HEAD differs is denied as target-mixed when the session-root HEAD matches (issue #738)
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).allows when every target is epic scope and ready
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).keeps the single-feature decision for a relative -C selector outside epic scope
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).keeps the single-feature decision for a directory change outside epic scope
PASSED: Codex preimplementation gate epic-scope targets (issue #738).allows when every target is epic scope and ready
PASSED: Codex preimplementation gate epic-scope targets (issue #738).keeps the single-feature decision for a relative -C selector outside epic scope
PASSED: Codex preimplementation gate epic-scope targets (issue #738).keeps the single-feature decision for a directory change outside epic scope
PASSED: Codex preimplementation gate epic-scope targets (issue #738).resolves a segment without -C to the session root
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
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #663 the relocated epic read seam returns an empty string when the epic checkpoint file is absent
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #663 the relocated epic read seam returns the raw epic checkpoint text when the file exists
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #663 the relocated parallel read seam returns an empty string when the parallel checkpoint file is absent
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #663 the relocated parallel read seam returns the raw parallel checkpoint text when the file exists
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #690 the relocated per-feature read seam returns an empty string when the checkpoint file is absent
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #690 the relocated per-feature read seam returns the raw checkpoint text when the file exists
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #663 the epic-scope decision returns null without resolving when the call carries neither a command nor a path
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
```

Output Summary: PassedCount 79, FailedCount 20, FailedBlocksCount 0, FailedContainersCount 0; 20 FAILED: lines listed above.

