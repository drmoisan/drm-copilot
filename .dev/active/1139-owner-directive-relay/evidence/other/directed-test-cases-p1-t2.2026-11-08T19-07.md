# Coordinator-Directed Test Cases ([P1-T2])

Timestamp: 2026-11-08T19-07
Command: git show HEAD:tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1 (read of the committed test file; no test run is recorded here)
EXIT_CODE: 0
Output Summary: The confirming preflight record evidence/other/preflight-fixes.2026-11-08T18-35.md listed missing cases that the coordinator directed into [P1-T2]. Each is present in tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1 as listed below. Pass proof is the [P4-T3] Pester gate; the focused debug run used while authoring is not evidence.

## Directed cases and the tests that carry them

| Directed case | Test (It name, data row) | Asserted value |
|---|---|---|
| B1: `owner_directives` as `{}` | `B1 rejects an owner_directives value that is <Shape>`, row `Shape = 'an object'` (`Json = '{}'`) | exactly one error, the B1 string |
| B1: `owner_directives` as `[1]` | same It, row `Shape = 'a list holding a number'` (`Json = '[1]'`) | exactly one error, the B1 string |
| B8: missing `scope.issue` (entry #1, others valid) | `B8 rejects entry #1 when <Case>`, row `scope.issue is removed` | exactly one error, the B8 string |
| B8: missing `scope` (entry #1, others valid) | same It, row `scope is removed` | exactly one error, the B8 string |
| B3: `OD-1x` | `B3 rejects the id <Id>`, row `Id = 'OD-1x'` | exactly one error, the B3 string (anchored match) |
| B6: class `Scheduling` | `B6 rejects the class <Class>`, row `Class = 'Scheduling'` | exactly one error, the B6 string (ordinal comparison) |

The B8 and B3/B6 rows run on the fixture text with `owner_directive_records` removed, so no record rule contributes an error and the single-error assertion holds.
