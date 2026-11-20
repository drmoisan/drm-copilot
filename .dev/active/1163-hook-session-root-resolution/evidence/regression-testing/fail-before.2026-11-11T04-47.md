# Fail-Before Evidence (issue #1163, P2-T1)

Timestamp: 2026-11-11T04-47
Command: sh SCRATCH/issue-1163-pester.sh failbefore (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <item worktree>; exit with the returned ExitCode); results read from artifacts/pester/parallel/shard-*/pester-junit.xml with SCRATCH/issue-1163-junit.sh
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: One Invoke-PoshQCParallelTest run (8 workers, wall clock 1909.1 s) against unmodified production code with the P1-T1 to P1-T6 suites in place; this is regression evidence, not a test gate. Per-shard JUnit: 21410 test cases, 21346 passed, 54 failed, 0 errors, 10 skipped; no merged artifact was written (failed run). Every failure is one of the issue #1163 rows marked fails before (50 rows, each failing on its decision or asserted outcome; none fails on parameter binding or mock registration) or one of the 4 direct Get-DocsCompleteGateReceiptRoot rows of P1-T4 (CommandNotFoundException, function created in P5-T5). Every unchanged-decision row passes. No other test failed.

## Fails-before rows (observed failure)

The FailIfCalled rows report the probe seam's own exception ("... probe must not be called for an unresolved identity"), which is the observed decision of the unmodified hook: it probes the session root for an unresolved present identity.

| Suite | Row | Observed result on unmodified code |
|---|---|---|
| `enforce-completion-consistency-target-worktree.Tests.ps1` | allows a completion-asserting Write to an item-worktree checkpoint whose feature folder exists only beneath the item root | Expected strings to be the same, but they were different. |
| `enforce-completion-consistency.TargetWorktree.Tests.ps1` | allows a completion-asserting Write to an item-worktree checkpoint whose feature folder exists only beneath the item root | Expected strings to be the same, but they were different. |
| `enforce-docs-complete-gate.Tests.ps1` | decision: allows when the head branch is checked out in one item worktree that holds the receipt | Expected strings to be the same, but they were different. |
| `enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1` | RE11 applies the default resolver to a host-moved epic record | Expected strings to be the same, but they were different. |
| `enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1` | RE11 applies the default resolver to a host-moved parallel record | Expected strings to be the same, but they were different. |
| `enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1` | RE6 allows removal of a host-moved epic record through its branch_name | Expected strings to be the same, but they were different. |
| `enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1` | RE6 allows removal of a host-moved parallel record through its branch_name | Expected strings to be the same, but they were different. |
| `enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1` | RE7 names the host-moved pr_open epic record in the deny diagnostics | Expected regular expression 'epic run OtherWorktree .*merge_status 'pr_open'' to match 'EPIC_WORKTREE_REMOVAL_... |
| `enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1` | RE7 names the host-moved pr_open parallel record in the deny diagnostics | Expected regular expression 'parallel run OtherWorktree .*merge_status 'pr_open'' to match 'EPIC_WORKTREE_REMO... |
| `enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1` | RE8 names the host-moved pr_open parallel record in the deny diagnostics | Expected regular expression 'parallel run OtherWorktree .*merge_status 'pr_open'' to match 'Diagnostics: epic ... |
| `enforce-file-size-limit-target-worktree.Tests.ps1` | denies an 801-line Write to a sibling worktree outside the repository root | Expected a value, but got $null or empty. |
| `enforce-file-size-limit-target-worktree.Tests.ps1` | denies an 801-line Write to an agent worktree beneath .claude/worktrees/ | Expected a value, but got $null or empty. |
| `enforce-file-size-limit-target-worktree.Tests.ps1` | forwards the worktree-list seam from the entry point to the decision | Expected like wildcard '*"permissionDecision":"deny"*' to match <empty>, but it did not match. |
| `enforce-file-size-limit.TargetWorktree.Tests.ps1` | denies an 801-line Write to a sibling worktree outside the repository root | Expected strings to be the same, but they were different. |
| `enforce-file-size-limit.TargetWorktree.Tests.ps1` | denies an 801-line Write to an agent worktree beneath .claude/worktrees/ | Expected strings to be the same, but they were different. |
| `enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1` | RP11 applies the default resolver to a host-moved epic record | Expected strings to be the same, but they were different. |
| `enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1` | RP11 applies the default resolver to a host-moved parallel record | Expected strings to be the same, but they were different. |
| `enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1` | RP7 allows removal of a host-moved epic record through its branch_name | Expected strings to be the same, but they were different. |
| `enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1` | RP7 allows removal of a host-moved parallel record through its branch_name | Expected strings to be the same, but they were different. |
| `enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1` | RP8 finds a host-moved epic features[] record through Find-ParallelWorktreeItemRecord | Expected a value, but got $null or empty. |
| `subagentstop-target-worktree.Tests.ps1` | carries the target detail naming the stale root and git worktree repair into the rejection detail | Expected like wildcard '*TARGET_WORKTREE_NOT_DERIVABLE*' to match $null, but it did not match. |
| `subagentstop-target-worktree.Tests.ps1` | rejects without a probe path when the target carries TARGET_WORKTREE_AMBIGUOUS | Expected $true, but got $false. |
| `subagentstop-target-worktree.Tests.ps1` | rejects without a probe path when the target carries TARGET_WORKTREE_NOT_DERIVABLE | Expected $true, but got $false. |
| `subagentstop-target-worktree.Tests.ps1` | resolves the item root from the envelope cwd when the prompt carries no identity | Expected strings to be the same, but they were different. |
| `subagentstop-target-worktree.Tests.ps1` | resolves the live root for a prompt branch registered once as prunable and once live | Expected $null or empty, but got 'TARGET_WORKTREE_AMBIGUOUS'. |
| `validate-docs-role-output.TargetWorktree.Tests.ps1` | blocks without a probe when the prompt branch resolves to TARGET_WORKTREE_AMBIGUOUS | RuntimeException: the docs-role probe must not be called for an unresolved identity |
| `validate-docs-role-output.TargetWorktree.Tests.ps1` | blocks without a probe when the prompt branch resolves to TARGET_WORKTREE_NOT_DERIVABLE | RuntimeException: the docs-role probe must not be called for an unresolved identity |
| `validate-docs-role-output.TargetWorktree.Tests.ps1` | probes the docs-architect output paths beneath the item worktree named by the prompt branch | Expected $true, because DOCS_ROLE_OUTPUT_BLOCKED: docs-architect output check failed; report each token on its... |
| `validate-docs-role-output.TargetWorktree.Tests.ps1` | probes the docs-author output paths beneath the item worktree named by the prompt branch | Expected $true, because DOCS_ROLE_OUTPUT_BLOCKED: docs-author output check failed; report each token on its ow... |
| `validate-executor-output.TargetWorktree.Tests.ps1` | blocks without a probe naming TARGET_WORKTREE_AMBIGUOUS in the plan block message when the prompt names two issue numbers | RuntimeException: the plan probe must not be called for an unresolved identity |
| `validate-executor-output.TargetWorktree.Tests.ps1` | blocks without a probe naming TARGET_WORKTREE_NOT_DERIVABLE in the plan block message when the prompt branch names no worktree | RuntimeException: the plan probe must not be called for an unresolved identity |
| `validate-executor-output.TargetWorktree.Tests.ps1` | blocks without probing the fix record or the plan and names TARGET_WORKTREE_AMBIGUOUS when the prompt names two issue numbers | RuntimeException: the plan probe must not be called for an unresolved identity |
| `validate-executor-output.TargetWorktree.Tests.ps1` | blocks without probing the fix record or the plan and names TARGET_WORKTREE_NOT_DERIVABLE when the branch names no worktree | RuntimeException: the plan probe must not be called for an unresolved identity |
| `validate-human-exception-runbook-output.TargetWorktree.Tests.ps1` | blocks without a probe naming TARGET_WORKTREE_AMBIGUOUS when the prompt names two issue numbers | RuntimeException: the runbook probe must not be called for an unresolved identity |
| `validate-human-exception-runbook-output.TargetWorktree.Tests.ps1` | blocks without a probe naming TARGET_WORKTREE_NOT_DERIVABLE when the prompt branch names no worktree | RuntimeException: the runbook probe must not be called for an unresolved identity |
| `validate-human-exception-runbook-output.TargetWorktree.Tests.ps1` | lists no root and reads no file when the prompt branch names no worktree | Expected like wildcard '*nuitka*' to not match 'HUMAN_EXCEPTION_RUNBOOK_OUTPUT_MISSING: runbook 'docs/features... |
| `validate-planner-output.TargetWorktree.Tests.ps1` | blocks without a probe naming TARGET_WORKTREE_AMBIGUOUS when the prompt names two issue numbers | RuntimeException: the plan probe must not be called for an unresolved identity |
| `validate-planner-output.TargetWorktree.Tests.ps1` | blocks without a probe naming TARGET_WORKTREE_NOT_DERIVABLE when the prompt branch names no worktree | RuntimeException: the plan probe must not be called for an unresolved identity |
| `validate-prd-feature-output.TargetWorktree.Tests.ps1` | blocks without a probe naming TARGET_WORKTREE_AMBIGUOUS when the prompt names two issue numbers | RuntimeException: the spec probe must not be called for an unresolved identity |
| `validate-prd-feature-output.TargetWorktree.Tests.ps1` | blocks without a probe naming TARGET_WORKTREE_NOT_DERIVABLE when the prompt branch names no worktree | RuntimeException: the spec probe must not be called for an unresolved identity |
| `validate-required-artifact-output.TargetWorktree.Tests.ps1` | blocks without a probe naming TARGET_WORKTREE_AMBIGUOUS when the prompt names two issue numbers | RuntimeException: the spec probe must not be called for an unresolved identity |
| `validate-required-artifact-output.TargetWorktree.Tests.ps1` | blocks without a probe naming TARGET_WORKTREE_NOT_DERIVABLE when the prompt branch names no worktree | RuntimeException: the spec probe must not be called for an unresolved identity |
| `validate-task-researcher-output.TargetWorktree.Tests.ps1` | blocks without a probe naming TARGET_WORKTREE_AMBIGUOUS when the prompt names two issue numbers | RuntimeException: the research probe must not be called for an unresolved identity |
| `validate-task-researcher-output.TargetWorktree.Tests.ps1` | blocks without a probe naming TARGET_WORKTREE_NOT_DERIVABLE when the prompt branch names no worktree | RuntimeException: the research probe must not be called for an unresolved identity |
| `WorktreeRunRecordPath.Tests.ps1` | M12 matches a rooted record that names no live root through a branch that resolves to the target | Expected $true, but got $false. |
| `WorktreeRunResolution.Record.Tests.ps1` | B15 resolves the live worktree whose epic checkpoint records a stale absolute worktree_path through its branch_name | Expected strings to be the same, but they were different. |
| `WorktreeRunResolution.Record.Tests.ps1` | B15 resolves the live worktree whose parallel checkpoint records a stale absolute worktree_path through its branch_name | Expected strings to be the same, but they were different. |
| `WorktreeRunResolution.RelativeRecord.Tests.ps1` | RR10 calls Resolve-AgentTargetWorktree with the record branch, FailClosedOnIdentity, and the call SessionRoot when no resolver is supplied for epic | Expected strings to be the same, but they were different. |
| `WorktreeRunResolution.RelativeRecord.Tests.ps1` | RR10 calls Resolve-AgentTargetWorktree with the record branch, FailClosedOnIdentity, and the call SessionRoot when no resolver is supplied for parallel | Expected strings to be the same, but they were different. |
| `WorktreeRunResolution.RelativeRecord.Tests.ps1` | RR9 carries the enumerated live roots in LiveRoot for a worktree_path lookup | Expected 'LiveRoot' to be found in collection @('Status', 'WorktreeRoot', 'SessionRoot', 'Signal', 'SignalValu... |

D9 cross-check against the plan's list: M12; B15 (epic, parallel); RR9; RR10 (epic, parallel); RE6 (parallel, epic); RE7 (parallel, epic); RE8; RE11 (parallel, epic); RP7 (parallel, epic); RP8; RP11 (parallel, epic) are all present above.

## Direct rows for a function created later (outside both lists)

| Suite | Row | Observed result on unmodified code |
|---|---|---|
| `enforce-docs-complete-gate.Tests.ps1` | Get-DocsCompleteGateReceiptRoot returns /repo when no registration has the branch checked out | CommandNotFoundException: The term 'Get-DocsCompleteGateReceiptRoot' is not recognized as a name of a cmdlet, ... |
| `enforce-docs-complete-gate.Tests.ps1` | Get-DocsCompleteGateReceiptRoot returns /repo when only a prunable registration has the branch checked out | CommandNotFoundException: The term 'Get-DocsCompleteGateReceiptRoot' is not recognized as a name of a cmdlet, ... |
| `enforce-docs-complete-gate.Tests.ps1` | Get-DocsCompleteGateReceiptRoot returns /repo when two registrations have the branch checked out | CommandNotFoundException: The term 'Get-DocsCompleteGateReceiptRoot' is not recognized as a name of a cmdlet, ... |
| `enforce-docs-complete-gate.Tests.ps1` | Get-DocsCompleteGateReceiptRoot returns /repo/.claude/worktrees/item when one live registration has the branch checked out | CommandNotFoundException: The term 'Get-DocsCompleteGateReceiptRoot' is not recognized as a name of a cmdlet, ... |

## Unchanged-decision rows (observed PASS)

| Suite | Rows |
|---|---|
| `WorktreeRunRecordPath.Tests.ps1` | M13 (TARGET_WORKTREE_NOT_DERIVABLE, TARGET_WORKTREE_AMBIGUOUS), M14, M15, M16 |
| `WorktreeRunResolution.Record.Tests.ps1` | B16 (epic and parallel, each code), U2, U3 |
| `WorktreeRunResolution.RelativeRecord.Tests.ps1` | RR8 (epic, parallel) |
| `enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1` | RE9 (four kind and code pairs), RE10 (parallel, epic) |
| `enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1` | RP9 (four kind and code pairs), RP10 (parallel, epic) |

All pre-existing rows of the edited suites (RE1 to RE5, RP1 to RP6, M1 to M11, B1 to B14, RR1 to RR7, and the issue #1105 rows not converted in P1-T3) passed.
