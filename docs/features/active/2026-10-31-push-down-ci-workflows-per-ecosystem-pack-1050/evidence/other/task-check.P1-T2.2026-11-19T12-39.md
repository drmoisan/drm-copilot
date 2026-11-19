# Task Check P1-T2 (advisory-fix plan: gh standard-error separation)

Timestamp: 2026-11-19T12-39
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1
EXIT_CODE: 0
Output Summary: 30 passed, 0 failed (final run of this task). Format and PSScriptAnalyzer 0 findings; both script copies hash acac0fbb754381c219d0c70a12d4c578cce21fa9.

Changed files:
- scripts/ci/Set-CiRequiredChecks.ps1 (`Invoke-GhExe` returns `Output` from non-error records and `ErrorOutput` from error records; the three failure throws keep their prefixes and add the gh argument text and `ErrorOutput`; a non-JSON list output throws `The output of gh <args> is not JSON`)
- extensions/drm-copilot/resources/ci-workflows/Set-CiRequiredChecks.ps1 (byte copy)
- tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1

Selection rule: mirrored test file of the changed production file.

Steps:
1. Format check and PSScriptAnalyzer (pssa.settings.psd1) over the two script copies and the suite: exit 0, 0 findings each.
2. `git hash-object` of both script copies: acac0fbb754381c219d0c70a12d4c578cce21fa9 for both.
3. Pester selection, run 1: exit 1; 29 passed, 1 failed — `returns standard output only when the command writes a warning to standard error`: the PoshQC shard runs with a Stop error preference, so the double's `Write-Error` terminated (WriteErrorException). Fix: the double writes the record with `-ErrorAction Continue`, matching native standard error, which never terminates. No production change.
4. Format check and PSScriptAnalyzer re-run: exit 0, 0 findings.
5. Pester selection, run 2: exit 0; 30 passed, 0 failed.

New tests: `returns standard output only when the command writes a warning to standard error`, `names the gh call and its error output when listing fails`, `names the gh call when the ruleset list is not JSON`. Existing-test dispositions applied: the `Invoke-SetCiRequiredChecks` `BeforeEach` mock returns `ErrorOutput` on every result; the five named unchanged cases pass unchanged.
