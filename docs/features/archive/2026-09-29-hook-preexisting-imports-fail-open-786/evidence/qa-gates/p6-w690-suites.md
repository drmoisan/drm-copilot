# W-690 Suites ([P6-T6])

Timestamp: 2026-10-09T23-57
Command: R-SCOPED over the 8 W-690-TESTS files and every tests/scripts/claude-hooks/*.Tests.ps1 whose name begins with enforce-parallel-worktree-removal-gate, enforce-epic-wave-barrier, enforce-parallel-drift-gate, enforce-parallel-cohort-barrier, enforce-epic-merge-gate, enforce-epic-worktree-removal-gate, or enforce-orchestration-preimplementation-gate (47 files; the W-690-TESTS files are all in this set). No section 2.6.6 assertion-map file of a W-CONVERT handler (H7, H8) matches these prefixes, so none is excluded. The support file enforce-orchestration-preimplementation-gate.Parity.Cases.ps1 is not a test file and is loaded by its Parity suite.
EXIT_CODE: 0
Output Summary: PassedCount 1401, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0; one CONTAINER: line per listed file (47).

The file list and the full R-SCOPED output follow.

```text
FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
FILE-COUNT: 47

Starting discovery in 47 files.
Discovery found 1401 tests in 1.23s.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Authorization.Tests.ps1 1.45s (1.02s|314ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 307ms (180ms|80ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1 596ms (520ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Tests.ps1 996ms (832ms|125ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.TriggerScoping.Tests.ps1 622ms (534ms|69ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 550ms (489ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.FolderResolution.Tests.ps1 399ms (316ms|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.Tests.ps1 366ms (255ms|84ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 327ms (259ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 367ms (311ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 960ms (858ms|74ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1 1.08s (907ms|134ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 237ms (174ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 294ms (247ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 524ms (431ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 423ms (332ms|74ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 308ms (158ms|108ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 378ms (207ms|152ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 85ms (38ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 568ms (450ms|92ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 565ms (386ms|140ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 52ms (15ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Tests.ps1 540ms (415ms|100ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 1.4s (1.24s|116ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 150ms (96ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 2.07s (1.88s|151ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 634ms (558ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 551ms (492ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 224ms (186ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 2.96s (2.9s|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 996ms (886ms|71ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Tests.ps1 431ms (351ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 485ms (417ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 320ms (261ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 240ms (178ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Payload.Tests.ps1 151ms (110ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Tests.ps1 408ms (292ms|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 231ms (169ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate-helpers.Tests.ps1 280ms (184ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.FolderResolution.Tests.ps1 217ms (154ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.Tests.ps1 432ms (336ms|65ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 183ms (143ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 270ms (228ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 599ms (527ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1 722ms (602ms|80ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 171ms (125ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 228ms (190ms|26ms)
Tests completed in 26.41s
Tests Passed: 1401, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 1401
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | result=Passed | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 | result=Passed | passed=37 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | result=Passed | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | result=Passed | passed=57 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | result=Passed | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | result=Passed | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | result=Passed | passed=31 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | result=Passed | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | result=Passed | passed=9 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | result=Passed | passed=41 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | result=Passed | passed=51 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | result=Passed | passed=6 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | result=Passed | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | result=Passed | passed=34 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 | result=Passed | passed=38 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 | result=Passed | passed=76 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 | result=Passed | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | result=Passed | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | result=Passed | passed=88 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 | result=Passed | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 | result=Passed | passed=84 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | result=Passed | passed=86 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 | result=Passed | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | result=Passed | passed=120 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | result=Passed | passed=22 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 | result=Passed | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 | result=Passed | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | result=Passed | passed=85 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | result=Passed | passed=36 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | result=Passed | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 | result=Passed | passed=16 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | result=Passed | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | result=Passed | passed=53 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | result=Passed | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 | result=Passed | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | result=Passed | passed=49 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | result=Passed | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | result=Passed | passed=12 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | result=Passed | passed=41 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | result=Passed | passed=50 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | result=Passed | passed=4 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | result=Passed | passed=8 | failed=0
PASSED: baseline mock interception probe
PASSED: decides allow for a valid 691 record in the per-feature checkpoint
PASSED: decides allow for a valid 691 record in the epic checkpoint
PASSED: decides allow for a valid 691 record in the parallel checkpoint
PASSED: decides deny for a record naming 777 only
PASSED: decides deny for no authorization key on any checkpoint
PASSED: decides deny for a blanket true flag
PASSED: decides deny for a session_id that differs from the envelope
PASSED: decides deny for an envelope carrying no session_id
PASSED: decides deny for the discriminator merging unauthorized 777 after a cd into 501
PASSED: decides allow for the paired positive merging authorized 501 after a cd into 501
PASSED: decides allow for a squash merge of 691 with a valid 691 record
PASSED: denies an explicit PR with no record using both the gate token and the absent code
PASSED: keeps the existing fall-through text for a bare merge even with a valid record present
PASSED: allows parallel item 501 through branch 3 before the standalone branch is consulted
PASSED: extracts the same numbers for the six existing spellings
PASSED: rejects block value true as not PR specific
PASSED: rejects block value a string as not PR specific
PASSED: rejects block value an object as not PR specific
PASSED: rejects empty array as not PR specific
PASSED: rejects entry not an object as not PR specific
PASSED: rejects pr_number absent as not PR specific
PASSED: rejects pr_number null as not PR specific
PASSED: rejects pr_number zero as not PR specific
PASSED: rejects pr_number negative as not PR specific
PASSED: rejects pr_number a non-integer number as not PR specific
PASSED: rejects pr_number a digit-spelling string as not PR specific
PASSED: rejects pr_number the wildcard string as not PR specific
PASSED: rejects pr_number an array as not PR specific
PASSED: names pr_url when pr_url ends with a different pull number
PASSED: names issue_num when issue_num is a string
PASSED: names branch_name when branch_name is whitespace
PASSED: names authorized_by when authorized_by is empty
PASSED: names authorized_at when authorized_at is unparseable
PASSED: names basis when basis is empty
PASSED: names basis when basis is shorter than twenty characters
PASSED: names run_slug when run_slug is present but empty
PASSED: names pr_url first when both pr_url and basis fail
PASSED: accepts a well-formed record whose session matches
PASSED: accepts a well-formed record that omits the optional run_slug
PASSED: accepts an authorized_at value that is not an ISO date-time but still parses
PASSED: rejects a non-string authorized_at value
PASSED: names session_id when the envelope session differs
PASSED: names session_id when the envelope carries no session
PASSED: names session_id when the record session is blank
PASSED: names session_id when the sessions differ only by case
PASSED: selects the entry for the requested PR and returns nothing for another PR
PASSED: reports STANDALONE_MERGE_AUTHORIZATION_ABSENT for three absent checkpoints
PASSED: reports STANDALONE_MERGE_AUTHORIZATION_ABSENT for a checkpoint without the key
PASSED: reports STANDALONE_MERGE_AUTHORIZATION_PR_MISMATCH for a record for another pull request
PASSED: reports STANDALONE_MERGE_AUTHORIZATION_NOT_PR_SPECIFIC for a blanket flag beside a valid record
PASSED: reports STANDALONE_MERGE_AUTHORIZATION_MALFORMED for a matched record with a bad field
PASSED: allows a valid record held in any checkpoint slot
PASSED: baseline mock interception probe
PASSED: authorizes a standalone merge from the item worktree checkpoint
PASSED: does not authorize from a session-root copy of another worktree's checkpoint
PASSED: denies an unresolvable item target with the no-target code
PASSED: denies an ambiguous item target with the ambiguity code
PASSED: observes module-scoped WorktreeItemResolution mocks
PASSED: does not resolve an item target for a bare merge command
PASSED: denies a merge when no checkpoint records the pull request number
PASSED: denies a merge whose pull request number differs from pr_gate
PASSED: re-checks the binding on the checkpoint the gate reads
PASSED: denies naming WorktreeItemResolution.psm1 when its import failed
PASSED: returns true for a bare command
PASSED: returns false for a null checkpoint
PASSED: returns the pr_gate equality result
PASSED: returns the pr_gate equality result
PASSED: returns true for a matching positive-integer standalone entry
PASSED: returns false for a standalone pr_number that is string
PASSED: returns false for a standalone pr_number that is zero
PASSED: returns false for a standalone pr_number that is fractional
PASSED: returns false when neither field records the number
PASSED: baseline mock interception probe
PASSED: denies an empty payload as an envelope anomaly (fail closed)
PASSED: allows a non gh-pr-merge Bash command
PASSED: allows gh pr merge without --merge (e.g., --squash)
PASSED: denies unparseable JSON instead of throwing (exit 1 is non-blocking)
PASSED: allows gh pr merge --merge when the child checkpoint is epic_mode true and step9_status passed
PASSED: denies when the child checkpoint has epic_mode true but step9_status is not passed
PASSED: allows gh pr merge validate-task-researcher-output.Tests.ps1 --merge when epic_merge_pr.ci_gate.conclusion is success and PR number matches
PASSED: allows a bare gh pr merge --merge (no PR number) when ci_gate.conclusion is success
PASSED: denies gh pr merge validate-task-researcher-output.Tests.ps1 --merge when N does not match epic_merge_pr.pr_number
PASSED: denies when epic_merge_pr.ci_gate.conclusion is pending
PASSED: denies EPIC_MERGE_GATE_BLOCKED when both checkpoints are absent
PASSED: denies when both checkpoints are unreadable (malformed JSON)
PASSED: allows gh pr merge --merge validate-task-researcher-output.Tests.ps1 when route_id is parallel and the matched item is ci_green
PASSED: denies when the matched item merge_status is not ci_green (e.g. pr_open)
PASSED: denies when the command PR number matches no item
PASSED: denies when route_id is not parallel
PASSED: denies when the parallel checkpoint is absent and child and epic are also absent
PASSED: denies when the parallel checkpoint is malformed JSON
PASSED: denies a bare gh pr merge --merge (no PR number) even when a parallel checkpoint is present
PASSED: returns 410 for the number-before-flag form gh pr merge 410 --merge
PASSED: returns 410 for the flag-before-number form gh pr merge --merge 410
PASSED: returns $null for a bare gh pr merge --merge with no PR number
PASSED: Get-ParallelOrchestratorCheckpointContent returns $null when the checkpoint file does not exist
PASSED: Get-ParallelOrchestratorCheckpointContent reads real content when the file exists
PASSED: returns $false when Checkpoint is $null
PASSED: returns $false when route_id is not parallel
PASSED: returns $false when CommandPrNumber is $null
PASSED: returns $false when items is absent
PASSED: returns $false when no item matches the command PR number
PASSED: returns $false when the matched item pr_number is non-numeric
PASSED: returns $false when the matched item has no merge_status
PASSED: returns $false when the matched item merge_status is not ci_green
PASSED: returns $true when the matched item merge_status is ci_green
PASSED: Get-ChildOrchestratorCheckpointContent returns $null when the checkpoint file does not exist
PASSED: Get-ChildOrchestratorCheckpointContent reads real content when the file exists
PASSED: Get-EpicOrchestratorCheckpointContent returns $null when the checkpoint file does not exist
PASSED: Get-EpicOrchestratorCheckpointContent reads real content when the file exists
PASSED: returns $false when Checkpoint is $null
PASSED: returns $false when epic_mode is explicitly false
PASSED: returns $false when epic_mode is true but step9_status is absent
PASSED: returns $true when epic_mode is true and step9_status is passed
PASSED: returns $false when Checkpoint is $null
PASSED: returns $false when epic_merge_pr is absent
PASSED: returns $false when epic_merge_pr.ci_gate is absent
PASSED: returns $false when epic_merge_pr.pr_number is absent but a command PR number is supplied
PASSED: returns $false when epic_merge_pr.pr_number is non-numeric
PASSED: returns $true when no command PR number is supplied and ci_gate is success
PASSED: allows when the JSON payload has no command field
PASSED: returns exit code 0 and emits a deny when every transport is empty
PASSED: returns exit code 0 and emits a deny for unparseable JSON
PASSED: returns exit code 0 and emits a deny for JSON with no tool_input key
PASSED: returns exit code 0 and emits a deny for the legacy flat root shape
PASSED: returns exit code 0 and emits a deny for a null tool_input
PASSED: returns exit code 0 and emits a deny for a non-object tool_input
PASSED: denies the nested envelope end-to-end when no checkpoint satisfies the gate
PASSED: allows the nested envelope when the child checkpoint authorizes the merge
PASSED: baseline mock interception probe
PASSED: returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag
PASSED: returns null for a bare gh pr merge --merge that names no PR number
PASSED: returns 410 for the positional spelling gh pr merge 410 --merge
PASSED: returns 410 for the equals-joined spelling gh pr merge --merge=410
PASSED: allows a printf whose double-quoted text mentions the gated merge phrase
PASSED: keeps gh --repo drmoisan/drm-copilot pr merge --merge 688 in scope
PASSED: takes the PR number from the merge operand 777, not from the authorized item number 501 in the cd path
PASSED: denies merging unauthorized PR 777 even though authorized item 501 appears earlier on the line
PASSED: still allows merging the authorized PR 501 when 501 is the merge operand
PASSED: R2a-C1 denies a gh pr merge --merge carried inside a bash -c argument
PASSED: R2a-N1 still allows a commit message quoting the merge phrase and the merge flag
PASSED: R2a-N2 keeps a gh pr merge --merge relocated through xargs in scope
PASSED: baseline mock interception probe
PASSED: M1 allows an epic integration merge whose ready checkpoint is only in another worktree
PASSED: M2 allows a parallel item merge whose ci_green checkpoint is only in another worktree
PASSED: M3 denies a child merge whose pr_gate.pr_number differs from the command PR number
PASSED: M4 allows a child merge whose pr_gate.pr_number equals the command PR number
PASSED: M5 denies a child merge whose checkpoint records neither pr_gate nor a standalone record for the number
PASSED: M6 reads every checkpoint beneath the session worktree for a bare command without resolving
PASSED: M7 denies with TARGET_WORKTREE_NOT_DERIVABLE when neither run branch resolves and no record authorizes
PASSED: M8 denies with TARGET_WORKTREE_AMBIGUOUS when the epic branch is ambiguous
PASSED: M9 allows a standalone-authorized merge when neither run branch resolves
PASSED: M10 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0
PASSED: baseline mock interception probe
PASSED: W1: allows the target folder cited alone when its dependencies are merged
PASSED: W2a: allows the target folder cited together with a research artifact
PASSED: W2b: allows the target folder cited together with an evidence artifact
PASSED: W3a: allows a research artifact cited alone
PASSED: W3b: allows an evidence artifact cited alone
PASSED: W4a: prunes the cited upstream dependency and allows when it is merged
PASSED: W4b: evaluates the target, not the upstream, and denies when the dependency is pr_open
PASSED: W5a: denies as ambiguous and names both candidates
PASSED: W5b: denies as ambiguous for the reversed order with the longer slug first
PASSED: W6a: denies a bare docs/features/active/ token as naming no folder
PASSED: W6b: denies a docs/features/active/. token as naming no folder
PASSED: W7a: evaluates feature 621 and allows while 507 and 508 are merged
PASSED: W7b: evaluates feature 621 and denies when 508 is pr_open
PASSED: W8a: matches a minimal integer depends_on edge and allows when the dependency is merged
PASSED: W8b: matches a minimal integer depends_on edge and denies when the dependency is pr_open
PASSED: W9: denies naming feature-folder-resolution.ps1 and guards the dot-source
PASSED: W10: matches records recorded with active/ and docs/features/active/ prefixes
PASSED: baseline mock interception probe
PASSED: denies an empty payload as an envelope anomaly (fail closed)
PASSED: allows a non-orchestrator subagent delegation
PASSED: allows an orchestrator delegation whose prompt has no epic-mode marker
PASSED: denies unparseable JSON instead of throwing (exit 1 is non-blocking)
PASSED: denies the legacy flat root shape as a missing-tool_input anomaly
PASSED: allows when every depends_on entry has merge_status merged
PASSED: allows when a dependency has merge_status worktree_removed
PASSED: allows a wave-0 feature with an empty depends_on list
PASSED: denies when a depends_on entry has merge_status pr_open
PASSED: denies when a depends_on entry has no matching features[] record
PASSED: denies when the prompt cannot be resolved to a feature folder
PASSED: denies when the epic checkpoint file is absent
PASSED: denies when the epic checkpoint content is malformed JSON
PASSED: returns $null for an empty prompt
PASSED: resolves a .md-suffixed match to its parent directory basename
PASSED: returns $null when no path token is present
PASSED: returns $null when Checkpoint is $null
PASSED: returns $null when features key is absent
PASSED: returns $false when Checkpoint is $null
PASSED: returns $true when depends_on key is absent from the feature record
PASSED: returns $false when a dependency record has no merge_status key
PASSED: Get-EpicWaveBarrierCheckpointContent returns $null when the checkpoint file does not exist
PASSED: Get-EpicWaveBarrierCheckpointContent reads real content when the file exists
PASSED: returns exit code 0 and emits a deny when every transport is empty
PASSED: returns exit code 0 and emits a deny for unparseable JSON
PASSED: returns exit code 0 and emits a deny for JSON with no tool_input key
PASSED: returns exit code 0 and emits a deny for a null tool_input
PASSED: returns exit code 0 and emits a deny for a non-object tool_input
PASSED: denies the nested envelope when an epic-mode delegation names no feature folder
PASSED: allows a nested delegation whose prompt lacks the epic-mode marker
PASSED: baseline mock interception probe
PASSED: W1 admits the reproduction at the barrier by reading the epic checkpoint under the other worktree
PASSED: W2 denies the reproduction with TARGET_WORKTREE_NOT_DERIVABLE when no worktree holds the epic checkpoint
PASSED: W3 denies an ambiguous target with TARGET_WORKTREE_AMBIGUOUS
PASSED: W4 keeps the dependency deny text for a resolved target whose dependency is not merged
PASSED: W5 decides a session-root checkpoint exactly as before the change
PASSED: W6 reads the worktree that has the integration branch checked out over a stale session-root copy
PASSED: W7 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0
PASSED: W8 allows a non-orchestrator delegation without resolving
PASSED: W9 allows an orchestrator delegation without the epic marker without resolving
PASSED: baseline mock interception probe
PASSED: emits a single leading token when both run kinds are unresolved
PASSED: names each run kind's status and checkpoint path
PASSED: names the matched record merge_status
PASSED: states that no record matched
PASSED: states that the checkpoint was absent or unparseable
PASSED: returns the checkpoint path it read on the read result
PASSED: returns a null path when the target is unresolved
PASSED: builds the clause without reading any file
PASSED: baseline mock interception probe
PASSED: EW-01 allows R-824-ADD1
PASSED: EW-02 allows R-742-1
PASSED: EW-37 allows the fixture AC-19 list command
PASSED: EW-38 denies the fixture AC-19 wrapped removal
PASSED: EW-39 denies the EW-01 command when substring presence is reinstated
PASSED: EW-40 allows an in-scope command when the target resolver reports NoMatch
PASSED: EW-03 denies F1 for P
PASSED: EW-04 denies F2 for P
PASSED: EW-05 denies F3 for P
PASSED: EW-06 denies F4 for P
PASSED: EW-07 denies F5 for P
PASSED: EW-13 denies Q then P naming P
PASSED: EW-18 denies W5 naming P
PASSED: EW-19 denies W6 naming P
PASSED: EW-14 denies W1 as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-15 denies W2 as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-16 denies W3 as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-17 denies W4 as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-08 allows F1
PASSED: EW-09 allows F2
PASSED: EW-10 allows F3
PASSED: EW-11 allows F4
PASSED: EW-12 allows F5
PASSED: EW-21 denies the unbalanced quote spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-22 denies the PowerShell parse error spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-23 denies the decode failure spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-24 denies the depth limit spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-25 denies the dynamic position spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-26 denies the not proven inert spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-27 denies the no operand spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-28 denies the two operands spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-29 denies the X1 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-30 denies the X2 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-31 denies the X3 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-32 denies the X4 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-33 denies the X7 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-34 denies the X8 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-35 denies the X10 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-36 denies the B5 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: EW-20 allows the removal of Q and P
PASSED: baseline mock interception probe
PASSED: denies an empty payload as an envelope anomaly (fail closed)
PASSED: allows when the JSON payload has no command field
PASSED: allows a non git-worktree-remove Bash command
PASSED: denies unparseable JSON instead of throwing (exit 1 is non-blocking)
PASSED: allows git worktree remove when the matching record has merge_status merged
PASSED: allows git worktree remove when the matching record has merge_status worktree_removed
PASSED: denies EPIC_WORKTREE_REMOVAL_BLOCKED when the checkpoint file is absent
PASSED: denies EPIC_WORKTREE_REMOVAL_BLOCKED when the checkpoint content is malformed JSON
PASSED: denies when no features[] record has a matching worktree_path
PASSED: denies when the matching record has merge_status pr_open
PASSED: matches worktree_path across backslash/forward-slash separator differences
PASSED: extracts the target path from the command text
PASSED: reports NoMatch when the command does not invoke git worktree remove
PASSED: returns $null when Checkpoint is $null
PASSED: returns $null when features key is absent
PASSED: skips feature records with no worktree_path key
PASSED: returns $false when FeatureRecord is $null
PASSED: returns $false when merge_status key is absent
PASSED: Get-EpicWorktreeGateCheckpointContent returns $null when the checkpoint file does not exist
PASSED: Get-EpicWorktreeGateCheckpointContent reads real content when the file exists
PASSED: returns exit code 0 and emits a deny when every transport is empty
PASSED: returns exit code 0 and emits a deny for unparseable JSON
PASSED: returns exit code 0 and emits a deny for JSON with no tool_input key
PASSED: returns exit code 0 and emits a deny for a null tool_input
PASSED: returns exit code 0 and emits a deny for a non-object tool_input
PASSED: denies the nested envelope end-to-end when no checkpoint record authorizes removal
PASSED: allows the nested envelope when the checkpoint records the worktree as merged
PASSED: allows when the matching parallel items[] record has merge_status merged
PASSED: allows when the matching parallel items[] record has merge_status worktree_removed
PASSED: matches a parallel worktree_path across backslash/forward-slash separator differences
PASSED: denies when both checkpoint seams return $null
PASSED: denies when the parallel checkpoint body is malformed JSON
PASSED: denies when route_id is absent even though a merged matching item is present
PASSED: denies when route_id is present but is not parallel even though a merged matching item is present
PASSED: denies when route_id is parallel but no items key exists
PASSED: denies when no items[] entry matches the target worktree path
PASSED: denies when the matched parallel item has merge_status pr_open
PASSED: denies when the matched parallel item carries no merge_status key
PASSED: allows when the epic checkpoint authorizes while the parallel checkpoint does not (branches are ORed)
PASSED: emits the envelope-anomaly deny before reading either checkpoint
PASSED: returns $false when Checkpoint is $null
PASSED: returns $false when the route_id key is absent
PASSED: returns $false when the items key is absent
PASSED: skips an items[] entry that carries no worktree_path key
PASSED: Get-EpicWorktreeGateParallelCheckpointContent returns $null when the checkpoint file does not exist
PASSED: Get-EpicWorktreeGateParallelCheckpointContent reads real content when the file exists
PASSED: allows removal when a fresh manifest record authorizes the target
PASSED: denies a manifest-covered removal whose target an epic checkpoint records
PASSED: emits the unchanged epic block reason
PASSED: keeps the merge_status allow-set unchanged
PASSED: baseline mock interception probe
PASSED: denies git -C /repo/main worktree remove against a checkpoint with no authorizing record
PASSED: resolves the operand when --force precedes the path
PASSED: resolves the same operand when --force follows the path
PASSED: allows a command whose quoted text merely mentions the removal phrase
PASSED: keeps git worktree list out of scope
PASSED: baseline mock interception probe
PASSED: V1 allows a removal authorized by an epic record held only in another worktree
PASSED: V2 allows a removal authorized by a parallel record held only in another worktree
PASSED: V3 denies with TARGET_WORKTREE_NOT_DERIVABLE when neither kind resolves and the manifest declines
PASSED: V4 denies an ambiguous epic target before consulting the manifest
PASSED: V5 allows a manifest-authorized removal when neither kind resolves
PASSED: V6 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0
PASSED: baseline mock interception probe
PASSED: allows the repo-relative spelling of artifacts/orchestration/orchestrator-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/orchestrator-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/orchestrator-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/parallel-planner-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/parallel-planner-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/parallel-planner-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/parallel-orchestrator-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/parallel-orchestrator-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/parallel-orchestrator-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/epic-planner-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/epic-planner-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/epic-planner-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/epic-orchestrator-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/epic-orchestrator-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/epic-orchestrator-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/powershell-orchestrator-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/powershell-orchestrator-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/powershell-orchestrator-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/csharp-orchestrator-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/csharp-orchestrator-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/csharp-orchestrator-state.json
PASSED: admits the POSIX-shaped absolute spelling of artifacts/orchestration/orchestrator-state.json
PASSED: admits the leading dot-slash relative spelling of artifacts/orchestration/orchestrator-state.json
PASSED: allows the repo-relative spelling of a feature-folder .json artifact
PASSED: allows the forward-slash absolute spelling of a feature-folder .json artifact
PASSED: allows the backslash absolute spelling of a feature-folder .json artifact
PASSED: allows an absolute checkpoint path whose literal differs only in letter case
PASSED: denies an absolute path whose documentation prefix differs only in letter case
PASSED: denies a synthetic absolute path ending in a production .ps1 file
PASSED: denies a synthetic absolute path ending in a production .py file
PASSED: denies a synthetic absolute path ending in a orchestration JSON whose name is not one of the seven literals
PASSED: denies a synthetic absolute path ending in a checkpoint-named JSON with no preceding artifacts/orchestration segment
PASSED: denies a synthetic absolute path ending in a checkpoint name reached only through a parent-directory hop
PASSED: baseline mock interception probe
PASSED: returns false for a null tool input
PASSED: returns false for a non-orchestrator subagent type carrying both preparation markers
PASSED: returns false for an orchestrator carrying only one preparation marker
PASSED: returns true for an orchestrator carrying both preparation markers
PASSED: pins the preparation marker set equal to the preparation row of the mode table
PASSED: does not classify a non-orchestrator agent as an implementation delegation
PASSED: allows a non-orchestrator delegation against an unready single-feature checkpoint
PASSED: treats a mid-line escaped semicolon as literal
PASSED: treats an escaped ampersand as literal
PASSED: treats an escaped pipe as literal
PASSED: treats backslash-newline as a line continuation
PASSED: still splits on unescaped ;
PASSED: still splits on unescaped &&
PASSED: still splits on unescaped ||
PASSED: still splits on unescaped |
PASSED: still splits on unescaped &
PASSED: still splits after an escaped backslash
PASSED: does not split after an odd run of backslashes
PASSED: splits on the unescaped ampersand after an escaped one
PASSED: keeps backslash literal inside single quotes
PASSED: consumes an escaped double quote inside double quotes
PASSED: does not open a quote on an unquoted escaped double quote
PASSED: treats a trailing lone backslash as balanced
PASSED: returns no segments for an empty command
PASSED: does not exempt a commit whose message contains an escaped semicolon (issue #732 D2a)
PASSED: does not exempt a chained command after an escaped backslash
PASSED: treats a mid-line escaped semicolon as literal
PASSED: treats an escaped ampersand as literal
PASSED: treats an escaped pipe as literal
PASSED: treats backslash-newline as a line continuation
PASSED: still splits on unescaped ;
PASSED: still splits on unescaped &&
PASSED: still splits on unescaped ||
PASSED: still splits on unescaped |
PASSED: still splits on unescaped &
PASSED: still splits after an escaped backslash
PASSED: does not split after an odd run of backslashes
PASSED: splits on the unescaped ampersand after an escaped one
PASSED: keeps backslash literal inside single quotes
PASSED: consumes an escaped double quote inside double quotes
PASSED: does not open a quote on an unquoted escaped double quote
PASSED: treats a trailing lone backslash as balanced
PASSED: returns no segments for an empty command
PASSED: does not exempt a commit whose message contains an escaped semicolon (issue #732 D2a)
PASSED: does not exempt a chained command after an escaped backslash
PASSED: denies the issue 732 brace-expansion shape
PASSED: denies the issue 732 escaped dot-segment shape
PASSED: denies an escaped semicolon in a message
PASSED: denies an escaped ampersand in a message
PASSED: denies an escaped pipe in a message
PASSED: denies a mixed dot-backslash segment in an operand
PASSED: denies a backslash-spelled operand
PASSED: denies a comma brace in an operand
PASSED: denies a range brace in an operand
PASSED: denies a brace in an unquoted message
PASSED: denies an unquoted comma in a message
PASSED: denies an unquoted at-sign name in a message
PASSED: denies an unquoted opening parenthesis in a message
PASSED: denies an unquoted closing parenthesis in a message
PASSED: denies a star glob under an exempt tree
PASSED: denies a question-mark glob under an exempt tree
PASSED: denies a bracket glob under an exempt tree
PASSED: denies a leading slash
PASSED: denies a leading double slash
PASSED: denies a parent-directory segment
PASSED: denies a drive-letter operand
PASSED: denies a tilde in an operand
PASSED: denies a percent sign in an operand
PASSED: denies a caret in an operand
PASSED: denies an exclamation mark in an operand
PASSED: denies an equals sign in an operand
PASSED: denies a plus sign in an operand
PASSED: denies a non-ASCII division-slash look-alike in an operand
PASSED: admits an ordinary operand under the epics tree
PASSED: admits an ordinary operand under the parallel tree
PASSED: admits an ordinary operand under the active tree
PASSED: admits an ordinary operand under the potential tree
PASSED: admits an ordinary operand under the orchestration artifacts tree
PASSED: admits an operand with a dot segment inside an exempt tree
PASSED: admits a single-quoted message containing an opening brace
PASSED: admits a single-quoted message containing a comma
PASSED: admits a single-quoted message containing an opening parenthesis
PASSED: admits a single-quoted message containing an at sign
PASSED: denies the issue 732 brace-expansion shape
PASSED: denies the issue 732 escaped dot-segment shape
PASSED: denies an escaped semicolon in a message
PASSED: denies an escaped ampersand in a message
PASSED: denies an escaped pipe in a message
PASSED: denies a mixed dot-backslash segment in an operand
PASSED: denies a backslash-spelled operand
PASSED: denies a comma brace in an operand
PASSED: denies a range brace in an operand
PASSED: denies a brace in an unquoted message
PASSED: denies an unquoted comma in a message
PASSED: denies an unquoted at-sign name in a message
PASSED: denies an unquoted opening parenthesis in a message
PASSED: denies an unquoted closing parenthesis in a message
PASSED: denies a star glob under an exempt tree
PASSED: denies a question-mark glob under an exempt tree
PASSED: denies a bracket glob under an exempt tree
PASSED: denies a leading slash
PASSED: denies a leading double slash
PASSED: denies a parent-directory segment
PASSED: denies a drive-letter operand
PASSED: denies a tilde in an operand
PASSED: denies a percent sign in an operand
PASSED: denies a caret in an operand
PASSED: denies an exclamation mark in an operand
PASSED: denies an equals sign in an operand
PASSED: denies a plus sign in an operand
PASSED: denies a non-ASCII division-slash look-alike in an operand
PASSED: admits an ordinary operand under the epics tree
PASSED: admits an ordinary operand under the parallel tree
PASSED: admits an ordinary operand under the active tree
PASSED: admits an ordinary operand under the potential tree
PASSED: admits an ordinary operand under the orchestration artifacts tree
PASSED: admits an operand with a dot segment inside an exempt tree
PASSED: admits a single-quoted message containing an opening brace
PASSED: admits a single-quoted message containing a comma
PASSED: admits a single-quoted message containing an opening parenthesis
PASSED: admits a single-quoted message containing an at sign
PASSED: keeps all four surface copies of the helpers module byte-identical by SHA256 hash
PASSED: keeps every surface copy of the helpers module under the 500-line cap
PASSED: baseline mock interception probe
PASSED: M1: allows the target folder cited alone at decision level
PASSED: M2a: allows the target folder cited together with a research artifact
PASSED: M2b: allows the target folder cited together with an evidence artifact
PASSED: M3a: allows a research artifact cited alone
PASSED: M3b: allows an evidence artifact cited alone
PASSED: M4e: prunes a cited epic dependency and reports no readiness failure
PASSED: M4p: reports target-ambiguous for a parallel target cited with another item and no issue number
PASSED: M4q: resolves a parallel target cited with another item through the declared issue number
PASSED: M5: denies with target-ambiguous naming both candidates
PASSED: M5r: denies with target-ambiguous for the reversed order with the longer slug first
PASSED: M6a: falls back to the keyed issue number when the bare token yields no candidate
PASSED: M6b: reports target-record when the token yields no candidate and no issue number is cited
PASSED: M7: resolves feature 621 and does not fail the merge_status predicate
PASSED: M7d: allows the 621 launch at decision level
PASSED: M8: resolves the record by the keyed issue number when the folder record was renamed
PASSED: M9: returns no target folder and a feature-folder-resolution-import readiness failure
PASSED: M10p: denies a parallel delegation as target-ambiguous when only a bare #302 sibling reference is cited
PASSED: M10e: denies an epic delegation as target-ambiguous when only a bare #302 sibling reference is cited
PASSED: M11p: selects the terminal parallel target through the keyed issue number despite a bare #302 sibling reference
PASSED: M11e: selects the terminal epic target through the keyed issue number despite a bare #302 sibling reference
PASSED: M12a: returns no keyed issue number when only a bare hash form is present
PASSED: M12b: returns the keyed issue number and ignores a bare hash form
PASSED: M12c: keeps the bare hash form as the default issue-number source
PASSED: M8h: allows a zero-candidate delegation through the bare hash D3 fallback
PASSED: M8m: denies a zero-candidate delegation with no issue number as target-record
PASSED: baseline mock interception probe
PASSED: denies an orchestrator delegation phrased with "atomic execution" and no mode markers against an unready single-feature checkpoint
PASSED: resolves the preparation mode for its marker prompt
PASSED: resolves the epic mode for its marker prompt
PASSED: resolves the parallel mode for its marker prompt
PASSED: resolves the single-feature mode for its marker prompt
PASSED: evaluates preparation first when an execution marker is also present
PASSED: requires both preparation markers, so a single marker falls through to the default mode
PASSED: resolves the default mode for an empty prompt
PASSED: resolves the default mode for an null prompt
PASSED: maps the preparation mode to its canonical checkpoint path
PASSED: maps the epic mode to its canonical checkpoint path
PASSED: maps the parallel mode to its canonical checkpoint path
PASSED: maps the single-feature mode to its canonical checkpoint path
PASSED: returns an empty checkpoint path for a mode name that is not in the table
PASSED: accepts an absent declared epic checkpoint path
PASSED: accepts an matching declared epic checkpoint path
PASSED: rejects a declared epic checkpoint path that differs from the canonical value
PASSED: rejects a declared parallel checkpoint path that differs from the canonical value
PASSED: accepts a matching declared parallel checkpoint path
PASSED: has nothing to cross-check for a mode carrying no declared-path key
PASSED: returns nothing for a prompt carrying no feature-folder token
PASSED: returns the parent basename for a token ending in a Markdown file
PASSED: returns the basename for a bare directory token
PASSED: returns nothing for a prompt carrying no issue number
PASSED: returns the numeric string for a prompt carrying an keyed issue number
PASSED: returns the numeric string for a prompt carrying an Issue number wording issue number
PASSED: returns the numeric string for a prompt carrying an mixed-prose hash-form issue number
PASSED: selects the later exact folder record in epic readiness
PASSED: selects the later exact folder record in parallel readiness
PASSED: retains first matching issue fallback when no folder matches
PASSED: names route_id as the failed conjunct
PASSED: names epic_feature_folder as the failed conjunct
PASSED: names epic_manifest_path as the failed conjunct
PASSED: names epic_manifest_path as the failed conjunct
PASSED: names integration_branch as the failed conjunct
PASSED: names features as the failed conjunct
PASSED: names target-record as the failed conjunct
PASSED: names merge_status as the failed conjunct
PASSED: returns a non-empty failure name for a null checkpoint
PASSED: reports no failure for a fully ready epic checkpoint
PASSED: treats an absent merge_status as not_started and does not fail the last conjunct
PASSED: denies the terminal-merged merge status merged (decision D8)
PASSED: denies the terminal-merged merge status worktree_removed (decision D8)
PASSED: allows the failure merge status merge_conflict, which is legitimate remediation (decision D8)
PASSED: allows the failure merge status blocked_conflict_loop_limit, which is legitimate remediation (decision D8)
PASSED: resolves the target by issue_num when no feature-folder basename matches
PASSED: returns false from the wrapper for a null checkpoint
PASSED: names route_id as the failed conjunct
PASSED: names parallel_slug as the failed conjunct
PASSED: names parallel_manifest_path as the failed conjunct
PASSED: names items as the failed conjunct
PASSED: names target-record as the failed conjunct
PASSED: names merge_status as the failed conjunct
PASSED: returns a non-empty failure name for a null checkpoint
PASSED: reports no failure for a fully ready parallel checkpoint
PASSED: denies the terminal-merged merge status merged (decision D8)
PASSED: denies the terminal-merged merge status worktree_removed (decision D8)
PASSED: allows the blocked merge status blocked_drift, adding no member to the parallel enum
PASSED: allows the blocked merge status blocked_ci_loop_limit, adding no member to the parallel enum
PASSED: returns false from the wrapper for a null checkpoint
PASSED: classifies the allow-listed agent python-typed-engineer as an implementation agent
PASSED: classifies the allow-listed agent powershell-typed-engineer as an implementation agent
PASSED: classifies the allow-listed agent typescript-engineer as an implementation agent
PASSED: classifies the allow-listed agent csharp-typed-engineer as an implementation agent
PASSED: classifies the allow-listed agent atomic-executor as an implementation agent
PASSED: holds exactly five members
PASSED: does not classify orchestrator as an implementation agent
PASSED: does not classify task-researcher as an implementation agent
PASSED: does not classify  as an implementation agent
PASSED: matrix case 1: a ready epic checkpoint allows
PASSED: matrix case 2: empty injected epic content denies, naming the epic checkpoint
PASSED: matrix case 3: a features array lacking the target record denies, naming the failed predicate
PASSED: matrix case 4: a non-canonical declared epic_checkpoint_path denies
PASSED: epic target unresolvable: a prompt with no resolvable target token and no issue number denies
PASSED: decision D8: a target record in a terminal-merged state denies
PASSED: decision D8: a target record in a failure state allows, as legitimate remediation
PASSED: matrix case 5: an epic marker in a non-prompt field resolves to the default single-feature mode
PASSED: matrix case 6a: an allow-listed implementation agent denies against an unready checkpoint whatever its prompt says
PASSED: matrix case 7: both preparation markers exempt the delegation
PASSED: matrix case 8: a standalone orchestrator allows against a ready single-feature checkpoint
PASSED: matrix case 8: a standalone orchestrator denies against an unready single-feature checkpoint
PASSED: a ready parallel checkpoint allows
PASSED: an items array lacking the target record denies, naming the parallel checkpoint
PASSED: a non-canonical declared parallel_checkpoint_path denies
PASSED: denies an unparseable payload
PASSED: denies a payload carrying no tool_input key
PASSED: denies an epic-mode delegation whose injected epic content is empty, with no filesystem read
PASSED: keeps all four surface copies of the targets module byte-identical by SHA256 hash
PASSED: keeps every surface copy of the targets module under the 500-line cap
PASSED: U01 resolves an absolute path-leg input to itself
PASSED: U02 resolves a relative path-leg input to the session root
PASSED: U03 denies an absolute path-leg input with a dot segment
PASSED: U04 normalizes a backslash path-leg input
PASSED: U05 resolves two patch-marker paths in order
PASSED: U06 denies an unbalanced segment
PASSED: U07 gives directory-change for cd
PASSED: U07 gives directory-change for pushd
PASSED: U07 gives directory-change for popd
PASSED: U07 gives directory-change for chdir
PASSED: U07 gives directory-change for Set-Location
PASSED: U07 gives directory-change for sl
PASSED: U07 gives directory-change for Push-Location
PASSED: U07 gives directory-change for Pop-Location
PASSED: U08 denies a wrapper-led git segment without reading its -C value
PASSED: U09 denies a substitution-bearing git segment
PASSED: U10 resolves a wrapper-led non-git segment to the session root
PASSED: U11 gives git-relocation for GIT_DIR=/x git add a.ps1
PASSED: U11 gives git-relocation for GIT_WORK_TREE=/x git add a.ps1
PASSED: U11 gives git-relocation for GIT_COMMON_DIR=/x git add a.ps1
PASSED: U11 gives git-relocation for GIT_INDEX_FILE=/x git add a.ps1
PASSED: U11 gives git-relocation for export GIT_DIR=/x && git add a.ps1
PASSED: U12 gives git-relocation for git --git-dir=/x add a.ps1
PASSED: U12 gives git-relocation for git --git-dir /x add a.ps1
PASSED: U12 gives git-relocation for git --work-tree /x add a.ps1
PASSED: U12 gives git-relocation for git -c core.worktree=/x add a.ps1
PASSED: U13 collects every value of a repeated -C selector
PASSED: U14 gives selector-not-absolute for a relative and a UNC selector
PASSED: U15 gives selector-dot-segment for a dot and a dot-dot selector
PASSED: U16 gives selector-backslash for a backslash selector
PASSED: U17 gives selector-missing-value for a trailing -C
PASSED: U18 gives git-option-unmodeled for an unknown global option
PASSED: U19 resolves a chained command to the session root and the selector
PASSED: U20 rejects a relative session root and normalizes a backslash session root
PASSED: U21 returns the four patch-marker paths and nothing for a plain command
PASSED: U22 gives none for no epic scope
PASSED: U22 gives deny for an unresolved target result
PASSED: U22 gives deny for an ambiguous target
PASSED: U22 gives deny for an unresolved selector target
PASSED: U22 gives deny for a non-epic target
PASSED: U22 gives evaluate for all-epic targets
PASSED: U23 resolves a target equal to the session root once
PASSED: U01 resolves an absolute path-leg input to itself
PASSED: U02 resolves a relative path-leg input to the session root
PASSED: U03 denies an absolute path-leg input with a dot segment
PASSED: U04 normalizes a backslash path-leg input
PASSED: U05 resolves two patch-marker paths in order
PASSED: U06 denies an unbalanced segment
PASSED: U07 gives directory-change for cd
PASSED: U07 gives directory-change for pushd
PASSED: U07 gives directory-change for popd
PASSED: U07 gives directory-change for chdir
PASSED: U07 gives directory-change for Set-Location
PASSED: U07 gives directory-change for sl
PASSED: U07 gives directory-change for Push-Location
PASSED: U07 gives directory-change for Pop-Location
PASSED: U08 denies a wrapper-led git segment without reading its -C value
PASSED: U09 denies a substitution-bearing git segment
PASSED: U10 resolves a wrapper-led non-git segment to the session root
PASSED: U11 gives git-relocation for GIT_DIR=/x git add a.ps1
PASSED: U11 gives git-relocation for GIT_WORK_TREE=/x git add a.ps1
PASSED: U11 gives git-relocation for GIT_COMMON_DIR=/x git add a.ps1
PASSED: U11 gives git-relocation for GIT_INDEX_FILE=/x git add a.ps1
PASSED: U11 gives git-relocation for export GIT_DIR=/x && git add a.ps1
PASSED: U12 gives git-relocation for git --git-dir=/x add a.ps1
PASSED: U12 gives git-relocation for git --git-dir /x add a.ps1
PASSED: U12 gives git-relocation for git --work-tree /x add a.ps1
PASSED: U12 gives git-relocation for git -c core.worktree=/x add a.ps1
PASSED: U13 collects every value of a repeated -C selector
PASSED: U14 gives selector-not-absolute for a relative and a UNC selector
PASSED: U15 gives selector-dot-segment for a dot and a dot-dot selector
PASSED: U16 gives selector-backslash for a backslash selector
PASSED: U17 gives selector-missing-value for a trailing -C
PASSED: U18 gives git-option-unmodeled for an unknown global option
PASSED: U19 resolves a chained command to the session root and the selector
PASSED: U20 rejects a relative session root and normalizes a backslash session root
PASSED: U21 returns the four patch-marker paths and nothing for a plain command
PASSED: U22 gives none for no epic scope
PASSED: U22 gives deny for an unresolved target result
PASSED: U22 gives deny for an ambiguous target
PASSED: U22 gives deny for an unresolved selector target
PASSED: U22 gives deny for a non-epic target
PASSED: U22 gives evaluate for all-epic targets
PASSED: U23 resolves a target equal to the session root once
PASSED: baseline mock interception probe
PASSED: admits a separate-value trailer option
PASSED: admits an equals-form trailer option
PASSED: admits two trailer options
PASSED: admits a multi-message form with both trailers in one single-quoted paragraph
PASSED: admits a single-quoted subject containing a backtick
PASSED: admits a single-quoted subject containing a dollar sign and a command substitution
PASSED: admits a chained add and trailer-bearing commit
PASSED: admits a POSIX-rooted selector with a trailer option
PASSED: admits a hash inside a single-quoted message
PASSED: admits a hash inside a double-quoted message
PASSED: admits an inline angle-bracket attribution in a double-quoted subject
PASSED: admits an empty single-quoted trailer value
PASSED: admits a trailer option taking the double-dash separator as its value (CR-4)
PASSED: denies an unquoted redirection after a single-quoted dollar message
PASSED: denies a command substitution in an operand
PASSED: denies a variable expansion in an operand
PASSED: denies a dollar sign inside double quotes
PASSED: denies a command substitution inside double quotes
PASSED: denies a backtick inside double quotes
PASSED: denies the heredoc command-substitution commit recipe
PASSED: denies ANSI-C dollar-single-quote quoting
PASSED: denies an and-chain to a non-exempt add
PASSED: denies a semicolon chain to a non-git command
PASSED: denies a non-exempt pathspec with a trailer option
PASSED: denies a pathless commit carrying a message and a trailer
PASSED: denies a trailer option on the add subcommand
PASSED: denies a dangling trailer option with no value
PASSED: denies a message-file option
PASSED: denies an equals-form file option
PASSED: denies a stdin message file fed by a heredoc
PASSED: denies the hash-quote comment desynchronization line
PASSED: denies an unquoted trailing comment
PASSED: denies a mid-word hash in an exempt operand
PASSED: denies an unbalanced single quote around a dollar sign
PASSED: denies an escaped single quote near a dollar sign
PASSED: denies a typographic single-quoted command substitution
PASSED: denies a typographic double-quoted command substitution
PASSED: denies a typographic single quote around a non-exempt pathspec
PASSED: denies a trailer option taking the double-dash separator before a non-exempt operand (CR-4)
PASSED: denies a single low-9 quotation mark (U+201A)
PASSED: denies a single high-reversed-9 quotation mark (U+201B)
PASSED: denies a double low-9 quotation mark (U+201E)
PASSED: baseline mock interception probe
PASSED: admits a separate-value trailer option
PASSED: admits an equals-form trailer option
PASSED: admits two trailer options
PASSED: admits a multi-message form with both trailers in one single-quoted paragraph
PASSED: admits a single-quoted subject containing a backtick
PASSED: admits a single-quoted subject containing a dollar sign and a command substitution
PASSED: admits a chained add and trailer-bearing commit
PASSED: admits a POSIX-rooted selector with a trailer option
PASSED: admits a hash inside a single-quoted message
PASSED: admits a hash inside a double-quoted message
PASSED: admits an inline angle-bracket attribution in a double-quoted subject
PASSED: admits an empty single-quoted trailer value
PASSED: admits a trailer option taking the double-dash separator as its value (CR-4)
PASSED: denies an unquoted redirection after a single-quoted dollar message
PASSED: denies a command substitution in an operand
PASSED: denies a variable expansion in an operand
PASSED: denies a dollar sign inside double quotes
PASSED: denies a command substitution inside double quotes
PASSED: denies a backtick inside double quotes
PASSED: denies the heredoc command-substitution commit recipe
PASSED: denies ANSI-C dollar-single-quote quoting
PASSED: denies an and-chain to a non-exempt add
PASSED: denies a semicolon chain to a non-git command
PASSED: denies a non-exempt pathspec with a trailer option
PASSED: denies a pathless commit carrying a message and a trailer
PASSED: denies a trailer option on the add subcommand
PASSED: denies a dangling trailer option with no value
PASSED: denies a message-file option
PASSED: denies an equals-form file option
PASSED: denies a stdin message file fed by a heredoc
PASSED: denies the hash-quote comment desynchronization line
PASSED: denies an unquoted trailing comment
PASSED: denies a mid-word hash in an exempt operand
PASSED: denies an unbalanced single quote around a dollar sign
PASSED: denies an escaped single quote near a dollar sign
PASSED: denies a typographic single-quoted command substitution
PASSED: denies a typographic double-quoted command substitution
PASSED: denies a typographic single quote around a non-exempt pathspec
PASSED: denies a trailer option taking the double-dash separator before a non-exempt operand (CR-4)
PASSED: denies a single low-9 quotation mark (U+201A)
PASSED: denies a single high-reversed-9 quotation mark (U+201B)
PASSED: denies a double low-9 quotation mark (U+201E)
PASSED: removes one trailing slash from a rooted path
PASSED: removes one trailing slash from a backslash-spelled drive path
PASSED: keeps the bare POSIX root unchanged
PASSED: keeps a bare drive root unchanged
PASSED: resolves a segment without -C to a session root given with a trailing slash
PASSED: removes one trailing slash from a rooted path
PASSED: removes one trailing slash from a backslash-spelled drive path
PASSED: keeps the bare POSIX root unchanged
PASSED: keeps a bare drive root unchanged
PASSED: resolves a segment without -C to a session root given with a trailing slash
PASSED: baseline mock interception probe
PASSED: allows staging an epic document under the epics tree
PASSED: allows staging a parallel manifest and its kickoff in one two-operand invocation
PASSED: allows a quoted operand under the active feature tree
PASSED: denies a backslash-spelled operand (D4 row 18 reversed by issues #732 and #735)
PASSED: allows staging a kickoff markdown file under the orchestration artifacts tree
PASSED: allows the pathspec-bearing integration form with a message option and a double-dash separator
PASSED: allows a chained two-segment line whose every segment is independently exempt
PASSED: allows staging a lifecycle record under the potential feature tree
PASSED: denies an exempt operand paired with a .ps1 production operand
PASSED: denies an exempt operand paired with a .py production operand
PASSED: denies an exempt operand paired with a .ts production operand
PASSED: denies an exempt operand paired with a .cs production operand
PASSED: denies D4 row 1 - bare staging with zero operands
PASSED: denies D4 row 2a - the tree-wide short all flag
PASSED: denies D4 row 2b - the tree-wide long all flag
PASSED: denies D4 row 2c - the update short flag with an exempt operand
PASSED: denies D4 row 2d - the update long flag
PASSED: denies D4 row 2e - the no-all flag with an exempt operand
PASSED: denies D4 row 3a - the dot whole-tree operand
PASSED: denies D4 row 3b - the colon-slash whole-tree operand
PASSED: denies D4 row 4 - a pathless message-only integration invocation
PASSED: denies D4 row 5a - the content-widening short all option
PASSED: denies D4 row 5b - the content-widening long all option
PASSED: denies D4 row 5c - the include short option
PASSED: denies D4 row 5d - the include long option
PASSED: denies D4 row 5e - the interactive long option
PASSED: denies D4 row 5f - the patch short option
PASSED: denies D4 row 5g - the history-rewriting amend option
PASSED: denies D4 row 6a - pathspecs supplied from a file
PASSED: denies D4 row 6b - the nul-delimited pathspec file option
PASSED: denies D4 row 7 - a double-dash separator with nothing after it
PASSED: denies D4 row 8 - an unmodeled dash-leading option before the separator
PASSED: denies D4 row 9a - the exclude pathspec magic operand
PASSED: denies D4 row 9b - the bang shorthand exclude operand
PASSED: denies D4 row 9c - the top pathspec magic operand
PASSED: denies D4 row 9d - the glob pathspec magic operand
PASSED: denies D4 row 9e - the icase pathspec magic operand
PASSED: denies D4 row 10 - a leading-dash operand with no preceding separator
PASSED: denies D4 row 11 - an unbalanced quote around an exempt operand
PASSED: denies D4 row 12a - a dollar-sign interpolation inside an operand
PASSED: denies D4 row 12b - a backtick substitution inside an operand
PASSED: denies D4 row 12c - an output redirection in the segment
PASSED: denies D4 row 12d - an input redirection in the segment
PASSED: denies D4 row 13a - a chained line whose second segment is not exempt
PASSED: denies D4 row 13b - unsplittable text whose quote spans the chain operator
PASSED: denies D4 row 14a - an environment-style prefix relocating the pathspec base
PASSED: denies D4 row 14b - a directory-relocating option before the subcommand
PASSED: denies D4 row 14c - a git-dir option before the subcommand
PASSED: denies D4 row 14d - a work-tree option before the subcommand
PASSED: denies D4 row 15a - a glob whose literal prefix stops above the exempt trees
PASSED: denies D4 row 15b - a glob whose wildcard occupies an ancestor segment
PASSED: denies D4 row 15c - a glob carrying a parent-directory segment
PASSED: denies D4 row 16a - an absolute operand in the leading-slash spelling
PASSED: denies D4 row 16b - an absolute operand in the drive-letter spelling
PASSED: denies D4 row 16c - an absolute operand in the UNC spelling
PASSED: denies D4 row 17 - a parent-directory segment inside an otherwise exempt operand
PASSED: denies D4 row 19 - a mixed operand set of one exempt and one production path
PASSED: denies a message-body payload that merely contains the staging literal
PASSED: denies the same heredoc body when it feeds a shell wrapper instead of a file
PASSED: allows issue #671 LACS allow 1 - drive-letter absolute selector on the add subcommand
PASSED: allows issue #671 LACS allow 2 - POSIX-rooted absolute selector on the add subcommand
PASSED: allows issue #671 LACS allow 4 - absolute selector on the message-bearing commit form
PASSED: allows issue #671 LACS allow 5 - chained add and commit segments each carrying the same absolute selector
PASSED: allows issue #671 LACS allow 6 - absolute selector naming a sibling item worktree root
PASSED: allows issue #671 LACS allow 7 - absolute selector naming a directory outside every worktree
PASSED: denies issue #671 LACS L1a - attached selector spelling
PASSED: denies issue #671 LACS L1b - config-injection selector
PASSED: denies issue #671 LACS L2 - repeated selector
PASSED: denies issue #671 LACS L3a - selector with no subcommand after the value
PASSED: denies issue #671 LACS L3b - subcommand not immediately after the selector value
PASSED: denies issue #671 LACS L4a - bare relative selector
PASSED: denies issue #671 LACS L4b - UNC selector
PASSED: denies issue #671 LACS L5a - parent-directory segment in the selector
PASSED: denies issue #671 LACS L5b - current-directory segment in the selector
PASSED: denies issue #671 LACS L6 - wildcard in the selector
PASSED: denies issue #671 LACS L7 - stray colon in the selector
PASSED: denies issue #732 LACS allow 3 reversed - backslash-spelled absolute selector
PASSED: denies issue #671 LACS L8 - empty selector value
PASSED: denies issue #671 selector followed by an unmodelled subcommand
PASSED: denies issue #671 selector with a non-exempt pathspec operand
PASSED: denies issue #671 selector with the tree-wide all flag
PASSED: denies issue #671 selector with an absolute pathspec operand
PASSED: denies issue #671 selector with an output redirection
PASSED: denies issue #671 cd chain into the target worktree
PASSED: allows issue #671 empty commit message beside an exempt operand
PASSED: denies issue #671 empty token beside a non-exempt operand
PASSED: denies issue #671 empty token after the separator beside a non-exempt operand
PASSED: denies issue #671 trailing empty token after a non-exempt operand
PASSED: denies issue #671 empty commit message beside a non-exempt operand
PASSED: accepts issue #671 predicate accept 1 - drive-letter selector followed by add
PASSED: accepts issue #671 predicate accept 2 - rooted selector followed by commit
PASSED: accepts issue #671 predicate accept 3 - non-option token after the value is left to the caller
PASSED: rejects issue #671 predicate L1a - single token segment
PASSED: rejects issue #671 predicate L1b - option other than the selector at index 1
PASSED: rejects issue #671 predicate L2 - repeated selector
PASSED: rejects issue #671 predicate L3a - no token after the selector value
PASSED: rejects issue #671 predicate L3b - option token after the selector value
PASSED: rejects issue #671 predicate L4a - relative selector
PASSED: rejects issue #671 predicate L4b - UNC selector
PASSED: rejects issue #671 predicate L5a - parent-directory segment
PASSED: rejects issue #671 predicate L5b - current-directory segment
PASSED: rejects issue #671 predicate L6 - wildcard
PASSED: rejects issue #671 predicate L7 - stray colon
PASSED: rejects issue #671 predicate L8 - empty selector value
PASSED: returns false when segment classification raises an error
PASSED: issue #663 exempts a double-quoted message carrying a Co-Authored-By trailer and an apostrophe
PASSED: issue #663 exempts a single-quoted message carrying angle brackets
PASSED: issue #663 denies the single-quoted apostrophe idiom
PASSED: issue #663 denies a command substitution inside a double-quoted message
PASSED: issue #663 denies a variable expansion inside a double-quoted message
PASSED: issue #663 denies a backtick substitution inside a double-quoted message
PASSED: issue #663 denies a pathless commit whose message carries angle brackets
PASSED: issue #663 denies an unquoted output redirection after a quoted message carrying angle brackets
PASSED: issue #663 remediation denies an escaped double quote hiding an output redirection (CR-1)
PASSED: issue #663 remediation denies an escaped double quote hiding an output redirection after a semicolon (CR-1)
PASSED: issue #663 remediation denies an escaped double quote hiding chain operators (CR-3)
PASSED: issue #663 remediation denies an unquoted escaped double quote opening a scan-only span
PASSED: issue #663 remediation denies an unquoted escaped single quote opening a scan-only span
PASSED: issue #663 remediation denies a backslash inside a double-quoted message
PASSED: baseline mock interception probe
PASSED: epic scope allows git add of a production path while a merge is in progress
PASSED: epic scope denies git add of a production path when no merge is in progress and names the epic checkpoint
PASSED: epic scope denies git add of a production path when epic_feature_folder is missing and names it
PASSED: epic scope denies git add of a production path when epic_manifest_path is missing and names it
PASSED: epic scope denies git add of a production path when features is missing and names it
PASSED: a checkpoint missing route_id is not epic scope and the command leg denies through the single-feature path
PASSED: a checkpoint missing integration_branch is not epic scope and the command leg denies through the single-feature path
PASSED: epic scope resolves the -C selector worktree for the command leg
PASSED: epic scope allows an Edit of a production path while a merge is in progress
PASSED: epic scope denies a Write of a production path when no merge is in progress
PASSED: without an epic checkpoint the command leg returns the unchanged single-feature decision and reason
PASSED: without an epic checkpoint the path leg returns the unchanged single-feature decision and reason
PASSED: an epic checkpoint whose integration_branch differs from HEAD leaves the command leg on the single-feature path
PASSED: epic scope denies a -C selector worktree outside the session-root epic scope as target-mixed (issue #738)
PASSED: issue #663 the relocated epic read seam returns an empty string when the epic checkpoint file is absent
PASSED: issue #663 the relocated epic read seam returns the raw epic checkpoint text when the file exists
PASSED: issue #663 the relocated parallel read seam returns an empty string when the parallel checkpoint file is absent
PASSED: issue #663 the relocated parallel read seam returns the raw parallel checkpoint text when the file exists
PASSED: issue #690 the relocated per-feature read seam returns an empty string when the checkpoint file is absent
PASSED: issue #690 the relocated per-feature read seam returns the raw checkpoint text when the file exists
PASSED: issue #663 the epic-scope decision returns null without resolving when the call carries neither a command nor a path
PASSED: baseline mock interception probe
PASSED: denies a second segment that targets a different not-ready worktree
PASSED: denies a relative -C selector in epic scope
PASSED: denies an unresolvable -C selector in epic scope
PASSED: denies a directory-changing segment in epic scope
PASSED: denies a wrapper-led git segment in epic scope
PASSED: denies a Write into a not-ready epic worktree
PASSED: denies a target outside the epic scope of the session root
PASSED: evaluates every value of a repeated -C selector
PASSED: allows when every target is epic scope and ready
PASSED: keeps the single-feature decision for a relative -C selector outside epic scope
PASSED: keeps the single-feature decision for a directory change outside epic scope
PASSED: denies an ambiguous epic target
PASSED: baseline mock interception probe
PASSED: denies the issue 732 brace-expansion shape without an authorizing checkpoint
PASSED: denies the issue 732 escaped dot-segment shape without an authorizing checkpoint
PASSED: baseline mock interception probe
PASSED: O1 admits a Write inside another worktree whose checkpoint is ready, reading that checkpoint
PASSED: O2 denies a Write inside another worktree whose checkpoint is not ready
PASSED: O3 denies a Write inside another worktree whose checkpoint is absent
PASSED: O6 decides a Write inside the session worktree exactly as the injected checkpoint
PASSED: O9 denies a Write whose target is ambiguous, naming the reason code and the detail
PASSED: O4 reads the checkpoint of the worktree a git -C selector names
PASSED: O5 reads the session worktree checkpoint for a command with no selector
PASSED: O7 denies naming WorktreeRunResolution.psm1 when that import failed, and the entry point exits 0
PASSED: O8 denies naming WorktreeItemResolution.psm1 when that import failed
PASSED: O10 passes no relative checkpoint literal to Test-Path or Get-Content, and every read seam takes a mandatory Path
PASSED: baseline mock interception probe
PASSED: AC-17 path classification a repository-relative implementation path claude
PASSED: AC-17 path classification an absolute implementation path claude
PASSED: AC-17 path classification a case-variant implementation path claude
PASSED: AC-17 path classification a case-variant feature documentation path with a json extension claude
PASSED: AC-17 path classification a checkpoint file name claude
PASSED: AC-17 path classification an absolute checkpoint file name claude
PASSED: AC-17 path classification a feature documentation path claude
PASSED: AC-17 path classification an evidence path with a json extension claude
PASSED: AC-17 path classification a non-implementation extension claude
PASSED: AC-17 path classification an empty string claude
PASSED: AC-17 command classification a write redirect claude
PASSED: AC-17 command classification a git add of an implementation path claude
PASSED: AC-17 command classification a read-only git log claude
PASSED: AC-17 command classification git status claude
PASSED: AC-17 command classification a formatter invocation through poetry claude
PASSED: AC-17 command classification a formatter invocation through npx claude
PASSED: AC-17 command classification a documentation-only git commit claude
PASSED: AC-17 command classification a read-only file listing claude
PASSED: AC-17 command classification an empty string claude
PASSED: AC-17 delegation classification a delegation to an implementation agent claude
PASSED: AC-17 delegation classification a delegation to a preparation orchestrator claude
PASSED: AC-17 delegation classification a delegation to an orchestrator that is not in preparation mode claude
PASSED: AC-17 delegation classification a delegation to a non-implementation agent claude
PASSED: AC-17 delegation classification a non-delegation tool input claude
PASSED: AC-17 delegation classification an empty input claude
PASSED: AC-17 delegation classification an orchestrator subagent type padded with whitespace claude
PASSED: AC-17 readiness a ready checkpoint claude
PASSED: AC-17 readiness a ready checkpoint that names its route as path_selected claude
PASSED: AC-17 readiness a not-ready checkpoint claude
PASSED: AC-17 readiness an empty checkpoint object claude
PASSED: AC-17 readiness an empty checkpoint text claude
PASSED: AC-17 readiness a checkpoint whose feature folder is outside the active tree claude
PASSED: AC-17 readiness an unparseable checkpoint claude
PASSED: AC-17 decision allow for a documentation path claude
PASSED: AC-17 decision block for an implementation path with a not-ready checkpoint claude
PASSED: AC-17 decision allow for an implementation path with a ready checkpoint claude
PASSED: AC-17 decision allow for an empty input claude
PASSED: AC-17 decision allow for a preparation orchestrator delegation claude
PASSED: AC-17 decision block for an implementation agent delegation with a not-ready checkpoint claude
PASSED: baseline mock interception probe
PASSED: AC-17 path classification a repository-relative implementation path codex
PASSED: AC-17 path classification an absolute implementation path codex
PASSED: AC-17 path classification a case-variant implementation path codex
PASSED: AC-17 path classification a case-variant feature documentation path with a json extension codex
PASSED: AC-17 path classification a checkpoint file name codex
PASSED: AC-17 path classification an absolute checkpoint file name codex
PASSED: AC-17 path classification a feature documentation path codex
PASSED: AC-17 path classification an evidence path with a json extension codex
PASSED: AC-17 path classification a non-implementation extension codex
PASSED: AC-17 path classification an empty string codex
PASSED: AC-17 command classification a write redirect codex
PASSED: AC-17 command classification a git add of an implementation path codex
PASSED: AC-17 command classification a read-only git log codex
PASSED: AC-17 command classification git status codex
PASSED: AC-17 command classification a formatter invocation through poetry codex
PASSED: AC-17 command classification a formatter invocation through npx codex
PASSED: AC-17 command classification a documentation-only git commit codex
PASSED: AC-17 command classification a read-only file listing codex
PASSED: AC-17 command classification an empty string codex
PASSED: AC-17 delegation classification a delegation to an implementation agent codex
PASSED: AC-17 delegation classification a delegation to a preparation orchestrator codex
PASSED: AC-17 delegation classification a delegation to an orchestrator that is not in preparation mode codex
PASSED: AC-17 delegation classification a delegation to a non-implementation agent codex
PASSED: AC-17 delegation classification a non-delegation tool input codex
PASSED: AC-17 delegation classification an empty input codex
PASSED: AC-17 delegation classification an orchestrator subagent type padded with whitespace codex
PASSED: AC-17 readiness a ready checkpoint codex
PASSED: AC-17 readiness a ready checkpoint that names its route as path_selected codex
PASSED: AC-17 readiness a not-ready checkpoint codex
PASSED: AC-17 readiness an empty checkpoint object codex
PASSED: AC-17 readiness an empty checkpoint text codex
PASSED: AC-17 readiness a checkpoint whose feature folder is outside the active tree codex
PASSED: AC-17 readiness an unparseable checkpoint codex
PASSED: AC-17 decision allow for a documentation path codex
PASSED: AC-17 decision block for an implementation path with a not-ready checkpoint codex
PASSED: AC-17 decision allow for an implementation path with a ready checkpoint codex
PASSED: AC-17 decision allow for an empty input codex
PASSED: AC-17 decision allow for a preparation orchestrator delegation codex
PASSED: AC-17 decision block for an implementation agent delegation with a not-ready checkpoint codex
PASSED: AC-17 the set of rows with differing per-surface expectations equals the declared set
PASSED: AC-17 an undeclared divergence fails
PASSED: AC-18 each gate's function names equal the shared set plus its declared per-surface set
PASSED: AC-18 an undeclared added function fails
PASSED: AC-18 the parity test reads only the two canonical gate files
PASSED: baseline mock interception probe
PASSED: blocks implementation writes when route metadata and lifecycle readiness are absent (generalized message)
PASSED: emits the PreToolUse deny schema (hookEventName + permissionDecision=deny) after serialize-then-parse
PASSED: allows feature documentation writes
PASSED: allows evidence writes
PASSED: allows implementation writes when checkpoint readiness is present, regardless of issue number
PASSED: blocks implementation command payloads before readiness (generalized message)
PASSED: blocks staging and commit command payloads before readiness
PASSED: blocks formatter and test command payloads before readiness
PASSED: blocks implementation delegation payloads before readiness (generalized message)
PASSED: allows implementation operations for any ready workflow state regardless of issue number
PASSED: denies an empty payload as an envelope anomaly (fail closed)
PASSED: denies unparseable top-level JSON instead of throwing (exit 1 is non-blocking)
PASSED: denies the legacy flat root shape as a missing-tool_input anomaly
PASSED: allows a well-formed nested Bash envelope whose tool_input carries no file_path (AC-6)
PASSED: allows a non-implementation file write (documentation path) without a checkpoint
PASSED: blocks an implementation write when the resolved checkpoint is malformed JSON
PASSED: allows an implementation write when readiness is supplied via path_selected fallback
PASSED: blocks an implementation write when the checkpoint omits the feature folder
PASSED: Test-OrchestrationReady returns false for a null payload
PASSED: Test-ImplementationDelegation returns false for a null tool input
PASSED: allows a Write to every exempt checkpoint literal with no ready checkpoint
PASSED: allows the backslash spelling of every exempt checkpoint literal
PASSED: denies a non-checkpoint .json under artifacts/orchestration/ (literal set, not directory prefix)
PASSED: denies a checkpoint-named file outside artifacts/orchestration/ (full-path equality)
PASSED: allows the verbatim parallel-plan preparation kickoff delegation with no ready checkpoint
PASSED: allows the verbatim epic-plan preparation kickoff delegation with no ready checkpoint
PASSED: denies both markers when subagent_type is not orchestrator
PASSED: denies an orchestrator delegation whose prompt matches the implementation regex without the markers
PASSED: denies an orchestrator delegation carrying only one preparation marker
PASSED: denies an orchestrator delegation whose first marker is missing its trailing period
PASSED: denies markers placed in a non-prompt field while prompt matches the implementation regex
PASSED: returns exit code 0 and emits a deny when every transport is empty
PASSED: returns exit code 0 and emits an allow decision JSON for a documentation write
PASSED: returns exit code 0 and never 1 for unparseable JSON
PASSED: registers the preimplementation gate in active and tracked Claude settings
PASSED: baseline mock interception probe
PASSED: allows a quoted mention of the staging invocation inside an echo argument
PASSED: allows a heredoc body that quotes the staging invocation in prose
PASSED: allows a heredoc whose JSON body names a governed tool as a receipt value
PASSED: allows prose containing the English word black
PASSED: allows a cross-segment line whose npm segment and lint mention are in different segments
PASSED: denies a relocating git add carrying a directory global option
PASSED: denies a relocating git commit carrying a git-dir global option
PASSED: denies a relocating git add carrying a work-tree global option
PASSED: denies an unmodeled dash-leading token between git and its subcommand
PASSED: denies the subshell spelling of a staging command
PASSED: denies the command-substitution spelling of a staging command
PASSED: does not classify git log --grep add as a staging command
PASSED: wrapper deny pin 1: denies a staging command relocated through xargs
PASSED: wrapper deny pin 2: denies a staging command nested inside a bash -c argument
PASSED: wrapper deny pin 3: denies a staging command nested inside an sh -c argument
PASSED: wrapper deny pin 4: denies a staging command behind the env transparent wrapper
PASSED: wrapper deny pin 5: denies a test invocation behind the pwsh -Command wrapper
PASSED: wrapper deny pin 6: denies a heredoc body piped into bash
PASSED: wrapper deny pin 7: denies a live substitution inside a double-quoted span
PASSED: baseline mock interception probe
PASSED: R1 admits the reproduction by reading the epic checkpoint under the other worktree
PASSED: R2 denies the reproduction with TARGET_WORKTREE_NOT_DERIVABLE when no worktree holds the epic checkpoint
PASSED: R3 denies an ambiguous epic target with TARGET_WORKTREE_AMBIGUOUS
PASSED: R11 decides an epic checkpoint at the session root exactly as the injected checkpoint
PASSED: R12 reads the worktree that has the integration branch checked out over a stale session-root copy
PASSED: R4 reads the parallel checkpoint beneath another worktree and admits a ready run
PASSED: R5 denies a parallel kickoff without parallel_slug with TARGET_WORKTREE_NOT_DERIVABLE
PASSED: R6 denies an ambiguous parallel target
PASSED: R7 reads an implementation agent's checkpoint beneath its own worktree
PASSED: R8 denies an implementation agent delegation that carries neither identity line without enumerating worktrees
PASSED: R9 denies an ambiguous implementation agent target
PASSED: R10 denies a non-mode orchestrator delegation without identity lines
PASSED: R13 bypasses resolution for a bound non-empty CheckpointRaw
PASSED: R14 bypasses resolution for a bound empty EpicCheckpointRaw
PASSED: R15 bypasses resolution for a bound ParallelCheckpointRaw
PASSED: baseline mock interception probe
PASSED: C1: allows the target folder cited alone
PASSED: C2a: allows the target folder cited together with a research artifact
PASSED: C2b: allows the target folder cited together with an evidence artifact
PASSED: C3a: allows a research artifact cited alone
PASSED: C3b: allows an evidence artifact cited alone
PASSED: C4a: denies as ambiguous and names both folders when no canonical issue-number line is present
PASSED: C4b: allows when the canonical issue-number line selects the target
PASSED: C5a: denies as ambiguous and names both candidates
PASSED: C5b: denies as ambiguous for the reversed order with the longer slug first
PASSED: C6a: denies a bare docs/features/active/ token as naming no folder
PASSED: C6b: denies a docs/features/active/. token as naming no folder
PASSED: C7: denies naming feature-folder-resolution.ps1 and guards the dot-source
PASSED: C8: matches records recorded with active/ and docs/features/active/ prefixes
PASSED: baseline mock interception probe
PASSED: returns exit code 0 and emits a deny when every transport is empty
PASSED: returns exit code 0 and emits a deny for unparseable JSON
PASSED: returns exit code 0 and emits a deny for the legacy flat root shape
PASSED: returns exit code 0 and emits a deny for a null tool_input
PASSED: denies the nested envelope end-to-end when no checkpoint resolves the target (AC-7)
PASSED: allows a nested delegation whose prompt lacks the parallel-mode marker
PASSED: allows a well-formed tool_input carrying no subagent_type (scope filter)
PASSED: baseline mock interception probe
PASSED: allows a non-orchestrator subagent delegation
PASSED: allows an orchestrator delegation whose prompt lacks the Parallel mode: true marker
PASSED: allows an orchestrator delegation with an empty prompt
PASSED: allows when the conflicting prior-cohort neighbor has merge_status merged
PASSED: allows when the conflicting prior-cohort neighbor has merge_status worktree_removed
PASSED: allows a cohort-0 target whose only conflicting neighbor sits in a later cohort
PASSED: allows a target that has no conflict edges at all
PASSED: allows when a same-cohort conflicting neighbor is not terminal (not a Layer 1 concern)
PASSED: ignores a superseded-generation cohort row when projecting the current coloring
PASSED: denies when the conflicting prior-cohort neighbor has merge_status pr_open
PASSED: denies when the conflicting prior-cohort neighbor has merge_status ci_green
PASSED: denies when the conflicting prior-cohort neighbor has merge_status not_started
PASSED: denies when the conflicting prior-cohort neighbor has merge_status blocked_drift
PASSED: denies when the conflicting prior-cohort neighbor record has no merge_status key
PASSED: denies when the conflicting prior-cohort neighbor has no items[] record
PASSED: denies when the conflict edge names the target as endpoint a
PASSED: denies when the parallel checkpoint file is absent
PASSED: denies when the parallel checkpoint content is malformed JSON
PASSED: denies when the prompt carries no feature-folder token
PASSED: denies when no items[] record matches the resolved feature folder
PASSED: denies when the target has no current-generation cohort assignment
PASSED: denies when the target items[] record carries no issue_num
PASSED: calls the read seam exactly once and allows when the seam reports a merged neighbor
PASSED: calls the read seam exactly once and denies for the identical payload when the seam reports ci_green
PASSED: does not call the read seam when the call is out of scope
PASSED: returns $null for an empty value
PASSED: reduces a full docs path to its basename
PASSED: resolves a .md-suffixed value to its parent directory basename
PASSED: returns $null for an empty prompt
PASSED: resolves a bare docs/features/active token to its basename
PASSED: returns $null when no path token is present
PASSED: returns $null when Checkpoint is $null
PASSED: returns $null when the items key is absent
PASSED: skips item records that carry no feature_folder
PASSED: matches a checkpoint that records a bare basename feature_folder
PASSED: returns $null when Checkpoint is $null
PASSED: returns $null when the items key is absent
PASSED: skips item records that carry no issue_num
PASSED: returns $null when Checkpoint is $null
PASSED: returns $null when recolor_generation is absent
PASSED: skips cohort rows that are missing a required key
PASSED: skips cohort rows whose index is not an integer
PASSED: returns cohort index 0 for a current-generation match
PASSED: returns an empty list when Checkpoint is $null
PASSED: returns an empty list when conflict_edges is absent
PASSED: skips edges that are missing an endpoint
PASSED: returns the opposite endpoint regardless of which side matches
PASSED: returns $false when Checkpoint is $null
PASSED: returns $false when ItemRecord is $null
PASSED: returns $false when the item record carries no issue_num
PASSED: Get-ParallelCohortBarrierCheckpointContent returns $null when the checkpoint file does not exist
PASSED: Get-ParallelCohortBarrierCheckpointContent reads real content when the file exists
PASSED: baseline mock interception probe
PASSED: C1 admits a clear barrier by reading the parallel checkpoint under the other worktree
PASSED: C2 denies a kickoff without parallel_slug with TARGET_WORKTREE_NOT_DERIVABLE
PASSED: C3 denies two matching parallel checkpoints with TARGET_WORKTREE_AMBIGUOUS
PASSED: C4 decides a session-root checkpoint exactly as before the change
PASSED: C5 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0
PASSED: C6 allows a non-orchestrator delegation without resolving
PASSED: C7 allows an orchestrator delegation without the parallel marker without resolving
PASSED: binds the PowerShell unresolved-drift decision to the Python unresolved_drift_item_keys derivation
PASSED: reports unresolved on every non-conforming-timestamp row of the shared table
PASSED: records the narrowing as strictly conservative on the widened-radius row
PASSED: Test-ParallelDriftGateItemKey rejects a boolean
PASSED: Test-ParallelDriftGateItemKey rejects a string
PASSED: Test-ParallelDriftGateItemKey rejects zero
PASSED: Test-ParallelDriftGateItemKey rejects a negative integer
PASSED: Test-ParallelDriftGateItemKey rejects null
PASSED: Test-ParallelDriftGateItemKey accepts a positive integer
PASSED: Test-ParallelDriftGateText rejects null
PASSED: Test-ParallelDriftGateText rejects an empty string
PASSED: Test-ParallelDriftGateText rejects whitespace
PASSED: Test-ParallelDriftGateText rejects an integer
PASSED: Test-ParallelDriftGateText accepts a non-blank string
PASSED: Test-ParallelDriftGateEventRecord rejects a $null record
PASSED: Test-ParallelDriftGateEventRecord rejects an escaped_paths entry that is blank
PASSED: Test-ParallelDriftGateEventRecord accepts a well-formed record
PASSED: Get-ParallelDriftGateLatestEventMap reports malformed for a $null checkpoint
PASSED: Get-ParallelDriftGateLatestEventMap reports malformed for a non-list drift_events
PASSED: Get-ParallelDriftGateItemRadiusMap returns an empty index for a $null checkpoint
PASSED: Get-ParallelDriftGateItemRadiusMap skips a null item, a bad key, and a non-object radius
PASSED: Test-ParallelDriftGateEventResolved rejects a source that differs only in case
PASSED: Test-ParallelDriftGateEventResolved rejects a $null radius
PASSED: Test-ParallelDriftGateEventResolved rejects a computed_at equal to the event at
PASSED: Get-ParallelDriftGateUnresolvedState surfaces LatestAt for the latest event of each item
PASSED: Get-ParallelDriftGateUnresolvedState returns an empty LatestAt when the log is malformed
PASSED: baseline mock interception probe
PASSED: D1: allows the target folder cited alone when it has no drift event
PASSED: D2a: allows the target folder cited together with a research artifact
PASSED: D2b: allows the target folder cited together with an evidence artifact
PASSED: D3a: allows a research artifact cited alone
PASSED: D3b: allows an evidence artifact cited alone
PASSED: D4a: denies as ambiguous and names both folders when no canonical issue-number line is present
PASSED: D4b: allows when the canonical issue-number line selects the target
PASSED: D5a: denies as ambiguous and names both candidates
PASSED: D5b: denies as ambiguous for the reversed order with the longer slug first
PASSED: D6a: denies a bare docs/features/active/ token as naming no folder
PASSED: D6b: denies a docs/features/active/. token as naming no folder
PASSED: D7: denies naming feature-folder-resolution.ps1 and guards the dot-source
PASSED: D8: probes the target folder, not the nested evidence kind, for an unresolved drift event
PASSED: baseline mock interception probe
PASSED: denies an empty payload as an envelope anomaly (fail closed)
PASSED: denies the legacy flat root shape as a missing-tool_input anomaly
PASSED: allows a non-feature-review subagent_type even under the marker
PASSED: allows a feature-review delegation whose prompt lacks the parallel-mode marker
PASSED: allows a feature-review delegation whose prompt is absent
PASSED: denies unparseable JSON instead of throwing (exit 1 is non-blocking)
PASSED: allows when the item has no drift event at all
PASSED: allows when the latest drift event is resolved by a later observed radius
PASSED: allows an unresolved item once its synthetic finding file is recorded as written
PASSED: denies when the latest drift event is unresolved and no finding has been written
PASSED: denies (fail closed) when the checkpoint is missing
PASSED: denies (fail closed) when the checkpoint content is malformed JSON
PASSED: denies (fail closed) when the prompt names no feature folder
PASSED: denies (fail closed) when no items[] record resolves to the prompt folder
PASSED: denies (fail closed) when the resolved item has an unreadable issue_num
PASSED: denies (fail closed) when the drift event log is malformed and no finding exists
PASSED: denies when the only finding file predates the latest drift event
PASSED: allows when the finding file timestamp equals the latest drift event at
PASSED: allows when the finding file timestamp follows the latest drift event at
PASSED: denies when the finding file name carries a non-conforming embedded substring
PASSED: names the current-event requirement in the deny reason for a stale finding file
PASSED: asserts the hook marker constant is a substring of the marker line in SKILL.md
PASSED: asserts the registered hook path resolves to an existing file
PASSED: returns $null for an empty prompt
PASSED: returns $null when no path token is present
PASSED: resolves a .md-suffixed match to its parent directory basename
PASSED: accepts a backslash-separated token and reports two distinct folders as Ambiguous
PASSED: Find-ParallelDriftGateItemRecord returns $null for a $null checkpoint
PASSED: Find-ParallelDriftGateItemRecord returns $null for a blank target folder
PASSED: Find-ParallelDriftGateItemRecord returns $null for an absent items key
PASSED: Find-ParallelDriftGateItemRecord returns $null for a null item and a non-string feature_folder
PASSED: Find-ParallelDriftGateItemRecord returns $null for a case-mismatched basename
PASSED: Find-ParallelDriftGateItemRecord matches a feature_folder recorded as a full path
PASSED: Get-ParallelDriftGateCheckpointContent returns $null when the checkpoint file is absent
PASSED: Get-ParallelDriftGateCheckpointContent reads content when the checkpoint file exists
PASSED: Test-ParallelDriftFindingPresent reports absence for a null worktree path
PASSED: Test-ParallelDriftFindingPresent reports absence for a blank feature folder
PASSED: Test-ParallelDriftFindingPresent reports absence when the feature folder does not exist
PASSED: Test-ParallelDriftFindingPresent reports absence when no remediation-inputs file is present
PASSED: Test-ParallelDriftFindingPresent reports presence for a remediation-inputs markdown file
PASSED: Test-ParallelDriftFindingPresent reports absence for a non-canonical EventAt
PASSED: returns exit code 0 and emits a deny when every transport is empty
PASSED: returns exit code 0 and emits a deny for unparseable JSON
PASSED: returns exit code 0 and emits a deny for JSON with no tool_input key
PASSED: returns exit code 0 and emits a deny for a null tool_input
PASSED: returns exit code 0 and emits a deny for a non-object tool_input
PASSED: denies the nested envelope when the parallel checkpoint is unreadable (AC-7)
PASSED: allows a nested delegation whose subagent_type is out of scope
PASSED: baseline mock interception probe
PASSED: D1 allows an undrifted item by reading the parallel checkpoint under the other worktree
PASSED: D2 denies a review delegation without parallel_slug with TARGET_WORKTREE_NOT_DERIVABLE
PASSED: D3 denies an ambiguous target
PASSED: D4 allows a non-feature-review delegation without resolving
PASSED: D5 allows a feature-review delegation without the parallel marker without resolving
PASSED: D6 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0
PASSED: baseline mock interception probe
PASSED: allows when an epic features[] record matches and merge_status is merged
PASSED: allows when the epic record merge_status is worktree_removed
PASSED: allows when a parallel checkpoint exists but does not cover the target
PASSED: normalizes backslash paths in an epic features[] record
PASSED: denies when the epic record merge_status is not terminal
PASSED: denies when the epic record has no merge_status field
PASSED: denies when the epic checkpoint covers a different worktree
PASSED: denies fail-closed when the epic checkpoint is unparseable
PASSED: denies fail-closed when the epic checkpoint is absent
PASSED: denies when the epic checkpoint has no features array
PASSED: still denies an unmerged parallel item even when an epic record exists for another path
PASSED: baseline mock interception probe
PASSED: PW-01 allows R-824-ADD1
PASSED: PW-02 allows R-742-1
PASSED: PW-37 allows the fixture AC-19 list command
PASSED: PW-38 denies the fixture AC-19 wrapped removal
PASSED: PW-39 denies the PW-01 command when substring presence is reinstated
PASSED: PW-40 allows an in-scope command when the target resolver reports NoMatch
PASSED: PW-03 denies F1 for P
PASSED: PW-04 denies F2 for P
PASSED: PW-05 denies F3 for P
PASSED: PW-06 denies F4 for P
PASSED: PW-07 denies F5 for P
PASSED: PW-13 denies Q then P naming P
PASSED: PW-18 denies W5 naming P
PASSED: PW-19 denies W6 naming P
PASSED: PW-14 denies W1 as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-15 denies W2 as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-16 denies W3 as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-17 denies W4 as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-08 allows F1
PASSED: PW-09 allows F2
PASSED: PW-10 allows F3
PASSED: PW-11 allows F4
PASSED: PW-12 allows F5
PASSED: PW-21 denies the unbalanced quote spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-22 denies the PowerShell parse error spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-23 denies the decode failure spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-24 denies the depth limit spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-25 denies the dynamic position spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-26 denies the not proven inert spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-27 denies the no operand spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-28 denies the two operands spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-29 denies the X1 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-30 denies the X2 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-31 denies the X3 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-32 denies the X4 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-33 denies the X7 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-34 denies the X8 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-35 denies the X10 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-36 denies the B5 spelling as TARGET_WORKTREE_NOT_DERIVABLE
PASSED: PW-20 allows the removal of Q and P
PASSED: baseline mock interception probe
PASSED: denies an empty payload as an envelope anomaly (fail closed)
PASSED: allows when the JSON payload has no command field
PASSED: allows git worktree list
PASSED: allows git worktree add
PASSED: allows an unrelated Bash command
PASSED: denies unparseable JSON instead of throwing (exit 1 is non-blocking)
PASSED: allows git worktree remove when the matching record has merge_status merged
PASSED: allows git worktree remove when the matching record has merge_status worktree_removed
PASSED: allows git worktree remove --force when the matching record has merge_status merged
PASSED: denies when the matching record has merge_status not_started
PASSED: denies when the matching record has merge_status worktree_created
PASSED: denies when the matching record has merge_status pr_open
PASSED: denies when the matching record has merge_status ci_green
PASSED: denies when the matching record has merge_status blocked_drift
PASSED: denies when the matching record has merge_status blocked_ci_loop_limit
PASSED: denies when the matching record carries no merge_status key
PASSED: denies when the parallel checkpoint file is absent
PASSED: denies when the parallel checkpoint content is malformed JSON
PASSED: denies when no items[] record has a matching worktree_path
PASSED: denies when the checkpoint carries no items key
PASSED: calls the read seam exactly once and allows when the seam reports merged
PASSED: calls the read seam exactly once and denies for the identical command when the seam reports ci_green
PASSED: does not call the read seam for a command that is not git worktree remove
PASSED: matches worktree_path across backslash/forward-slash separator differences
PASSED: matches worktree_path when the recorded value carries a trailing slash
PASSED: matches worktree_path when the command quotes the target path
PASSED: extracts the target path from the command text
PASSED: reports NoMatch when the command does not invoke git worktree remove
PASSED: returns $null when Checkpoint is $null
PASSED: returns $null when the items key is absent
PASSED: returns $null when WorktreePath is empty
PASSED: skips item records with no worktree_path key
PASSED: returns the matching item record
PASSED: returns $false when ItemRecord is $null
PASSED: returns $false when the merge_status key is absent
PASSED: returns $true for merge_status merged
PASSED: Get-ParallelWorktreeRemovalGateCheckpointContent returns $null when the checkpoint file does not exist
PASSED: Get-ParallelWorktreeRemovalGateCheckpointContent reads real content when the file exists
PASSED: returns exit code 0 and emits a deny when every transport is empty
PASSED: returns exit code 0 and emits a deny for unparseable JSON
PASSED: returns exit code 0 and emits a deny for JSON with no tool_input key
PASSED: returns exit code 0 and emits a deny for a null tool_input
PASSED: returns exit code 0 and emits a deny for a non-object tool_input
PASSED: denies the nested envelope end-to-end when no checkpoint record authorizes removal
PASSED: allows the nested envelope when the checkpoint records the item as merged
PASSED: allows removal when a fresh manifest record authorizes the target
PASSED: denies a manifest-covered removal whose target a parallel checkpoint records
PASSED: emits the unchanged parallel block reason
PASSED: keeps the merge_status allow-set unchanged
PASSED: baseline mock interception probe
PASSED: resolves the operand when --force precedes the path
PASSED: brings git -C /repo/main worktree remove into scope
PASSED: takes a quoted mention of the removal phrase out of scope
PASSED: baseline mock interception probe
PASSED: Y1 allows a removal authorized by a parallel record held only in another worktree
PASSED: Y2 allows a removal authorized by an epic record held only in another worktree
PASSED: Y3 denies with TARGET_WORKTREE_NOT_DERIVABLE when neither kind resolves and the manifest declines
PASSED: Y4 denies an ambiguous parallel target before consulting the manifest
PASSED: Y5 allows a manifest-authorized removal when neither kind resolves
PASSED: Y6 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0
PASSED: Y7 emits a single leading token when both run kinds are unresolved
```
