# P0-T18 Pester baseline SET-MRG

Timestamp: 2026-10-08T23-40
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=141
  PassedCount=141
  FailedCount=0
  BASE_MRG: 141
  A18 (copied verbatim from evidence/baseline/pester-set-pra.2026-10-08T23-39.md; not re-run):
  DECISION=deny
  REASON=EPIC_BASE_BRANCH_MISMATCH: `gh pr create` must pass `--base epic/enforcement-hook-precision-integration` (`epic_context.integration_branch`) under `epic_mode`; the command does not carry a matching `--base` argument.
  DECISION-WITHOUT-CHECKPOINT=allow
  Rule EE: applied; SET-MRG contains no EE-ROWS suite, so nothing is exempt (no ENV-EPIC-FAILED line).
  Baseline failure set: empty
  Baseline container set: empty
  BASELINE-RED-IN-EDITED-SUITE: not triggered

## Full output

```text
Pester v5.6.1

Starting discovery in 6 files.
Discovery found 141 tests in 407ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.Tests.ps1'
Describing enforce-epic-merge-gate.ps1
 Context commands outside scope
 93ms (71ms|23ms)
 70ms (70ms|1ms)
 25ms (24ms|1ms)
 10ms (10ms|1ms)
 Context allow via child-feature checkpoint (epic_mode + step9_status passed)
 93ms (78ms|15ms)
 39ms (39ms|1ms)
 Context allow via epic-integration checkpoint (ci_gate success + matching PR number)
 35ms (34ms|1ms)
 39ms (38ms|0ms)
 Context deny on non-matching PR number
 39ms (38ms|1ms)
 Context deny on non-success ci_gate.conclusion
 34ms (33ms|1ms)
 Context deny on missing/unreadable checkpoints (fail closed)
 30ms (29ms|1ms)
 35ms (35ms|0ms)
 Context allow via parallel-orchestrator checkpoint (route_id parallel + ci_green + matching PR)
 39ms (37ms|1ms)
 Context deny via parallel-orchestrator checkpoint (fail closed)
 31ms (30ms|1ms)
 30ms (29ms|1ms)
 35ms (34ms|1ms)
 33ms (32ms|1ms)
 31ms (31ms|1ms)
 26ms (26ms|1ms)
 Context Get-EpicMergeGateCommandPrNumber extractor (flag-order forms)
 9ms (8ms|1ms)
 7ms (6ms|0ms)
 12ms (11ms|0ms)
 Context real Test-Path read seam for the parallel checkpoint
 46ms (45ms|1ms)
 22ms (22ms|0ms)
 Context Test-ParallelCheckpointAllowsMerge helper (direct branch coverage)
 5ms (4ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 11ms (2ms|9ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 Context real Test-Path read seams
 10ms (9ms|1ms)
 20ms (19ms|1ms)
 13ms (13ms|1ms)
 26ms (25ms|1ms)
 Context Test-ChildCheckpointAllowsEpicMerge helper (direct branch coverage)
 4ms (3ms|2ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 4ms (3ms|1ms)
 Context Test-EpicCheckpointAllowsMerge helper (direct branch coverage)
 4ms (2ms|2ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)
 4ms (3ms|1ms)
 Context Invoke-EpicMergeGateDecision - command field absent
 6ms (4ms|1ms)
 Context entry-point exit code and emitted decision (AC-4, no child process)
 36ms (35ms|1ms)
 30ms (29ms|1ms)
 16ms (15ms|1ms)
 14ms (13ms|1ms)
 12ms (12ms|1ms)
 14ms (13ms|1ms)
 43ms (42ms|1ms)
 35ms (34ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.Authorization.Tests.ps1'
Describing enforce-epic-merge-gate.ps1 standalone authorization (issue #670)
 Context decision matrix
 54ms (51ms|3ms)
 32ms (31ms|1ms)
 32ms (31ms|1ms)
 22ms (22ms|1ms)
 22ms (21ms|1ms)
 18ms (18ms|0ms)
 37ms (36ms|1ms)
 41ms (40ms|1ms)
 46ms (45ms|1ms)
 49ms (48ms|1ms)
 23ms (22ms|1ms)
 Context reason text and branch order
 45ms (43ms|1ms)
 63ms (63ms|1ms)
 77ms (76ms|1ms)
 Context the pr_number matcher is unchanged
 55ms (54ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.AuthorizationFields.Tests.ps1'
Describing enforce-epic-merge-gate-authorization.ps1 predicates (issue #670)
 Context blocks that are not PR specific
 7ms (5ms|2ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (1ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (1ms|1ms)
 Context field shape failures on the matched record
 10ms (8ms|1ms)
 7ms (3ms|4ms)
 3ms (2ms|1ms)
 4ms (3ms|1ms)
 8ms (7ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 5ms (4ms|1ms)
 6ms (5ms|1ms)
 Context valid records and session binding
 4ms (3ms|1ms)
 6ms (6ms|0ms)
 5ms (4ms|1ms)
 6ms (6ms|1ms)
 8ms (7ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 3ms (2ms|1ms)
 10ms (9ms|1ms)
 Context checkpoint-level verdicts
 11ms (9ms|2ms)
 4ms (4ms|1ms)
 3ms (2ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 5ms (5ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.TriggerScoping.Tests.ps1'
Describing enforce-epic-merge-gate.ps1 trigger scoping (issue #545)
 Context PR-number extraction comes from the matched segment only
 13ms (12ms|2ms)
 7ms (7ms|1ms)
 6ms (5ms|0ms)
 9ms (8ms|1ms)
 Context scope filter separates a mention from an invocation
 23ms (22ms|1ms)
 46ms (45ms|1ms)
 Context the false-allow direction of the whole-line PR-number defect
 12ms (11ms|1ms)
 40ms (40ms|1ms)
 48ms (48ms|1ms)
 Context R-2.a wrapper-led segments stay in scope
 52ms (51ms|1ms)
 19ms (18ms|1ms)
 48ms (47ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.WorktreeResolution.Tests.ps1'
Describing epic merge gate run-target resolution
 106ms (105ms|1ms)
 52ms (51ms|1ms)
 46ms (45ms|1ms)
 35ms (34ms|1ms)
 28ms (27ms|1ms)
 59ms (59ms|0ms)
 47ms (46ms|1ms)
 43ms (42ms|1ms)
 32ms (31ms|1ms)
 8ms (7ms|1ms)

Running tests from 'tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1'
Describing hook-command-parser acceptance cases (issue #545)
 Context AT-1 - the mandatory latent-bypass case
 54ms (53ms|1ms)
 Context AT-2 - the issue #591 operand mis-parse
 14ms (13ms|1ms)
 Context AT-3 - the promotion-hook over-match on receipt values
 49ms (48ms|1ms)
 Context AT-4 - the merge-gate over-match on quoted prose
 16ms (15ms|1ms)
 Context AT-5 - the promotion-hook gh relocation bypass
 11ms (10ms|1ms)
 Context AT-6 - the wrapper deny pin
 61ms (60ms|1ms)
 Context AT-7 - the cross-runtime operand divergence
 22ms (21ms|1ms)
 Context paired negatives that must hold alongside the acceptance cases
 8ms (7ms|1ms)
 6ms (5ms|1ms)
 5ms (5ms|1ms)
 10ms (10ms|1ms)
Tests completed in 5.24s
Tests Passed: 141, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=141
PassedCount=141
FailedCount=0
```
