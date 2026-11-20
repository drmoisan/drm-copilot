# Coordinator-Directed Test Cases ([P1-T3])

Timestamp: 2026-11-08T19-08
Command: git show HEAD:tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Records.Tests.ps1 (read of the committed test file; no test run is recorded here)
EXIT_CODE: 0
Output Summary: The confirming preflight record evidence/other/preflight-fixes.2026-11-08T18-35.md listed missing cases that the coordinator directed into [P1-T3]. Each is present in tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Records.Tests.ps1 as listed below. Pass proof is the [P4-T3] Pester gate; the focused debug run used while authoring is not evidence.

## Directed cases and the tests that carry them

| Directed case | Test (It name, data row) | Asserted value |
|---|---|---|
| R1: records as `{}` | `R1 rejects an owner_directive_records value that is <Shape>`, row `Shape = 'an object'` (`Json = '{}'`) | exactly one error, the R1 string |
| R1: records as `[1]` | same It, row `Shape = 'a list holding a number'` (`Json = '[1]'`) | exactly one error, the R1 string |
| R5: outcome `Honored` rejected | `R5 rejects the outcome <Outcome>`, row `Outcome = 'Honored'` | exactly one error, the R5 string (ordinal comparison; no R6, R7, or R10 error) |
| R8: 19 non-space characters padded with spaces to raw length >= 20 | `R8 rejects the reason <Case>`, row `of 19 non-space characters padded to a raw length of 25` (three spaces, 19 characters, three spaces) | exactly one error, the R8 string |

The R1 rows replace the fixture's `owner_directive_records` value while its valid `owner_directives` block stays in place, so the single-error assertion holds.
