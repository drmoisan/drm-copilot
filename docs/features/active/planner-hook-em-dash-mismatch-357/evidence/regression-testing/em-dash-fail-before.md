# Em-Dash Regression Test — Fail Before Fix (Issue #357) [expect-fail]

Timestamp: 2026-07-17T10:31 (local, America/New_York; workstation clock)

Command: `Invoke-Pester` (ad hoc `PesterConfiguration`, no repo files modified) with `Run.Path = 'tests/scripts/claude-hooks/validate-planner-output.Tests.ps1'` and `Filter.FullName = '*allows termination when phase headings use the canonical em dash*'`, scoping execution to only the single new `It` case added in P1-T1, against the current unmodified `.claude/hooks/validate-planner-output.ps1` `$phasePattern` regex (ASCII hyphen).

EXIT_CODE: 1

Output Summary: The new em-dash regression test failed as expected (1 discovered/selected, 0 passed, 1 failed). Assertion failure: `Expected $true, but got $false` at `validate-planner-output.Tests.ps1:126` (`$result.Ok | Should -BeTrue`). Root cause confirmed: `Get-PlanStructureValidationReport`'s `$phasePattern` (`^### Phase (?<Phase>\d+)\s+-\s+(?<Title>.+)$`, ASCII hyphen literal) does not match the em-dash (`—`) fixture headings, so each em-dash phase heading is rejected with "phase heading must match `### Phase N - <Title>`", causing `Invoke-PlannerOutputValidation` to return `Ok = $false`. This is the expected pre-fix failure for this `[expect-fail]` task; the remaining 6 pre-existing tests were not run in this scoped invocation (NotRun), consistent with scoping to only the new em-dash case.
