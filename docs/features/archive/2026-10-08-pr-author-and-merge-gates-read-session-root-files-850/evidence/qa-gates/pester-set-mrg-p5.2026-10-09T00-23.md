# P5-T14 SET-MRG after Phase 5 (includes T-MRG-IR), run 1

Timestamp: 2026-10-09T00-23
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=160
  PassedCount=160
  FailedCount=0

## Full output

```text
Pester v5.6.1

Starting discovery in 7 files.
Discovery found 160 tests in 383ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.Tests.ps1'
Describing enforce-epic-merge-gate.ps1
 Context commands outside scope
 107ms (80ms|27ms)
 80ms (80ms|1ms)
 72ms (72ms|0ms)
 9ms (8ms|0ms)
 Context allow via child-feature checkpoint (epic_mode + step9_status passed)
 78ms (77ms|1ms)
 27ms (27ms|0ms)
 Context allow via epic-integration checkpoint (ci_gate success + matching PR number)
 61ms (60ms|1ms)
 22ms (22ms|0ms)
 Context deny on non-matching PR number
 48ms (47ms|1ms)
 Context deny on non-success ci_gate.conclusion
 33ms (32ms|1ms)
 Context deny on missing/unreadable checkpoints (fail closed)
 35ms (34ms|1ms)
 32ms (32ms|0ms)
 Context allow via parallel-orchestrator checkpoint (route_id parallel + ci_green + matching PR)
 41ms (40ms|1ms)
 Context deny via parallel-orchestrator checkpoint (fail closed)
 30ms (29ms|1ms)
 31ms (31ms|0ms)
 30ms (30ms|0ms)
 38ms (37ms|0ms)
 31ms (30ms|0ms)
 48ms (48ms|1ms)
 Context Get-EpicMergeGateCommandPrNumber extractor (flag-order forms)
 13ms (11ms|2ms)
 13ms (12ms|1ms)
 24ms (23ms|1ms)
 Context real Test-Path read seam for the parallel checkpoint
 92ms (90ms|2ms)
 57ms (56ms|1ms)
 Context Test-ParallelCheckpointAllowsMerge helper (direct branch coverage)
 10ms (8ms|2ms)
 5ms (4ms|1ms)
 4ms (3ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 7ms (6ms|1ms)
 Context real Test-Path read seams
 19ms (18ms|2ms)
 42ms (33ms|9ms)
 20ms (19ms|1ms)
 31ms (31ms|1ms)
 Context Test-ChildCheckpointAllowsEpicMerge helper (direct branch coverage)
 15ms (13ms|2ms)
 12ms (10ms|2ms)
 6ms (4ms|1ms)
 5ms (4ms|1ms)
 Context Test-EpicCheckpointAllowsMerge helper (direct branch coverage)
 6ms (4ms|2ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 5ms (4ms|1ms)
 Context Invoke-EpicMergeGateDecision - command field absent
 7ms (5ms|2ms)
 Context entry-point exit code and emitted decision (AC-4, no child process)
 46ms (44ms|2ms)
 24ms (23ms|1ms)
 23ms (22ms|1ms)
 24ms (23ms|1ms)
 23ms (22ms|1ms)
 29ms (28ms|1ms)
 59ms (59ms|1ms)
 38ms (38ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.Authorization.Tests.ps1'
Describing enforce-epic-merge-gate.ps1 standalone authorization (issue #670)
 Context decision matrix
 98ms (95ms|4ms)
 41ms (40ms|1ms)
 40ms (39ms|1ms)
 36ms (35ms|1ms)
 45ms (44ms|1ms)
 36ms (35ms|1ms)
 40ms (39ms|1ms)
 40ms (39ms|1ms)
 43ms (43ms|1ms)
 43ms (42ms|1ms)
 14ms (13ms|1ms)
 Context reason text and branch order
 49ms (48ms|1ms)
 44ms (43ms|1ms)
 74ms (74ms|1ms)
 Context the pr_number matcher is unchanged
 51ms (50ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.AuthorizationFields.Tests.ps1'
Describing enforce-epic-merge-gate-authorization.ps1 predicates (issue #670)
 Context blocks that are not PR specific
 8ms (6ms|2ms)
 2ms (2ms|1ms)
 5ms (4ms|1ms)
 4ms (3ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 Context field shape failures on the matched record
 10ms (9ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 10ms (9ms|1ms)
 4ms (3ms|1ms)
 8ms (7ms|1ms)
 4ms (4ms|1ms)
 6ms (5ms|1ms)
 Context valid records and session binding
 5ms (4ms|1ms)
 6ms (5ms|1ms)
 5ms (4ms|1ms)
 6ms (5ms|1ms)
 8ms (8ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 6ms (6ms|1ms)
 Context checkpoint-level verdicts
 13ms (11ms|3ms)
 5ms (4ms|1ms)
 12ms (11ms|1ms)
 4ms (4ms|1ms)
 4ms (3ms|1ms)
 6ms (5ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.TriggerScoping.Tests.ps1'
Describing enforce-epic-merge-gate.ps1 trigger scoping (issue #545)
 Context PR-number extraction comes from the matched segment only
 16ms (15ms|2ms)
 14ms (13ms|1ms)
 6ms (6ms|1ms)
 6ms (6ms|1ms)
 Context scope filter separates a mention from an invocation
 22ms (21ms|1ms)
 40ms (40ms|0ms)
 Context the false-allow direction of the whole-line PR-number defect
 10ms (9ms|1ms)
 52ms (52ms|1ms)
 57ms (56ms|1ms)
 Context R-2.a wrapper-led segments stay in scope
 63ms (61ms|2ms)
 24ms (23ms|1ms)
 45ms (44ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.WorktreeResolution.Tests.ps1'
Describing epic merge gate run-target resolution
 119ms (117ms|1ms)
 67ms (66ms|1ms)
 53ms (53ms|1ms)
 40ms (40ms|1ms)
 102ms (101ms|1ms)
 75ms (74ms|1ms)
 74ms (73ms|1ms)
 72ms (71ms|1ms)
 83ms (82ms|1ms)
 13ms (12ms|1ms)

Running tests from 'tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1'
Describing hook-command-parser acceptance cases (issue #545)
 Context AT-1 - the mandatory latent-bypass case
 105ms (103ms|2ms)
 Context AT-2 - the issue #591 operand mis-parse
 17ms (15ms|3ms)
 Context AT-3 - the promotion-hook over-match on receipt values
 48ms (47ms|2ms)
 Context AT-4 - the merge-gate over-match on quoted prose
 28ms (26ms|1ms)
 Context AT-5 - the promotion-hook gh relocation bypass
 13ms (11ms|1ms)
 Context AT-6 - the wrapper deny pin
 124ms (122ms|2ms)
 Context AT-7 - the cross-runtime operand divergence
 10ms (8ms|1ms)
 Context paired negatives that must hold alongside the acceptance cases
 10ms (9ms|1ms)
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 13ms (12ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1'
Describing epic merge gate item-worktree resolution
 58ms (57ms|1ms)
 53ms (53ms|1ms)
 35ms (34ms|1ms)
 29ms (28ms|1ms)
 35ms (34ms|1ms)
 43ms (43ms|1ms)
 39ms (38ms|1ms)
 36ms (35ms|1ms)
 33ms (33ms|1ms)
 4ms (3ms|1ms)
 Context child checkpoint pull request binding
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 6ms (5ms|2ms)
 2ms (1ms|1ms)
 4ms (4ms|0ms)
 4ms (3ms|1ms)
 2ms (1ms|1ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
Tests completed in 7.18s
Tests Passed: 160, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=160
PassedCount=160
FailedCount=0
```
