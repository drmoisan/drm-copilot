# Task Check P1-T3

Timestamp: 2026-11-19T09-15
Command: sh SCRATCH/issue-1050-p1t3.sh (cp into place; cmp of the bundle copy); sh SCRATCH/issue-1050-static.sh pwsh scripts/ci extensions/drm-copilot/resources/ci-workflows tests/scripts/ci (Invoke-PoshQCFormat non-writing seam; Invoke-ScriptAnalyzer per file with the repository settings); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1
EXIT_CODE: 0
Output Summary: Bundle copy byte-identical to the source. Format drift 0 and analyzer findings 0 over 24 files. Launcher pester selection exit 0: 22 tests passed, 0 failed (artifacts/pester/pester-junit.xml). Selection-run line coverage of `scripts/ci/Set-CiRequiredChecks.ps1` 88.46% (46/52), informational only; this run is not a gate.

Changed files:
- `scripts/ci/Set-CiRequiredChecks.ps1` (new)
- `extensions/drm-copilot/resources/ci-workflows/Set-CiRequiredChecks.ps1` (new, byte copy)
- `tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1` (new)

Selection rule: the mirrored test file of the changed production file (`tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1`); no other test names or dot-sources the new script.

Iterations within this task (each fixed before the result above):
1. Analyzer findings on the first draft: `PSUseShouldProcessForStateChangingFunctions` (`New-CiRequiredChecksRulesetBody`) and `PSUseSingularNouns` (`Invoke-SetCiRequiredChecks`). Both names are fixed by the plan; resolved with localized `SuppressMessageAttribute` entries carrying a justification, following the existing pattern in `scripts/ci/CiChangeScope.psm1` and `scripts/ci/NpmAuditGate.psm1`.
2. Analyzer findings `PSReviewUnusedParameter` on three mock parameter blocks in the test; resolved by referencing the parameters (`$null = $Path`, `$null = $InputText`), keeping the production parameter names on the mocks.
3. Queue timeouts: three launcher runs exited 75 (`TEST_EXECUTION_QUEUE_TIMEOUT:`, lock held by another worktree's pester suite); each was re-run after the holder finished.
4. Deviation from the plan's loading wording: the first passing run (22 passed) loaded the functions through their AST into a new script block, and its coverage report showed 0/51 lines for the script, because functions rebuilt from AST text are not attributed to the file by Pester code coverage; S14's 85% line threshold would then be unreachable. The script body is now one `if ($MyInvocation.InvocationName -ne '.')` statement around the single `Invoke-SetCiRequiredChecks` call (the dot-source guard used by `scripts/ci/Invoke-CiRequiredGate.ps1`, `Invoke-CiChangeScope.ps1`, and `Invoke-NpmAuditGate.ps1`), and the test dot-sources the file; the test still inspects the script's AST to assert one guarded statement outside functions. Decision recorded under autonomous mode: recommended option chosen because it preserves the plan's intent (functions tested in isolation, body never runs in tests) and makes the coverage requirement measurable.

Behaviors covered: default run prints the body and issues no gh call; `-WhatIf` issues no POST; `-Apply` issues exactly one POST (`api --method POST repos/owner/repo/rulesets --input -`) whose body targets `~DEFAULT_BRANCH` and requires `CI Required Gate` read from the data text; repository resolution through `gh repo view`; an existing same-name ruleset is reported with no write; no PUT, PATCH, or DELETE across four runs; malformed data text throws (seven variants) before any gh call; list, view, and POST failures throw; a missing data file throws.
