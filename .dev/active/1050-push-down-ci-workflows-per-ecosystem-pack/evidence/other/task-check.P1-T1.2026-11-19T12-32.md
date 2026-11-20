# Task Check P1-T1 (advisory-fix plan: ruleset list pagination)

Timestamp: 2026-11-19T12-32
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1
EXIT_CODE: 0
Output Summary: 27 passed, 0 failed (after change). Fail-before run against the unchanged script: 25 passed, 2 failed (the two new tests), launcher exit 1.

Changed files:
- scripts/ci/Set-CiRequiredChecks.ps1 (list call passes `--paginate --slurp`; pages flattened before the same-name filter)
- extensions/drm-copilot/resources/ci-workflows/Set-CiRequiredChecks.ps1 (byte copy)
- tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1

Selection rule: mirrored test file of the changed production file (`tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1`); the Jest bundle-parity test `CI bundle is complete and copies match` is covered at the phase gate.

Steps:
1. Fail-before: launcher `pester -TestPath tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1` before the script edit — attempts 1-4 exit 75 (queue timeout, lock held by another worktree's pester suite), attempt 5 exit 1. Failures: `lists the rulesets with --paginate and --slurp` (Invoke-GhExe called 0 times with the expected arguments) and `finds a same-name ruleset on the second page and issues no write` (output did not match `already exists in owner/repo (id 9)`; a POST was planned).
2. Format check (Invoke-Formatter with pssa.settings.psd1, no write) over the two script copies and the suite: exit 0, 0 findings.
3. PSScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the same three files: exit 0, 0 findings.
4. `git hash-object` of both script copies: 2ee9e8f446fb2816bc7e3c9c5e20f905d8a94fdf for both.
5. After-change Pester selection: attempt 1 exit 0; 27 passed, 0 failed.

Existing-test dispositions applied: `BeforeEach` default list fixture changed to `[[]]`; `reports an existing ruleset of the same name and issues no write` and `issues no PUT, PATCH or DELETE in any case` changed to the paged fixture form. Decision recorded: the list arguments are ordered `api repos/<repo>/rulesets --paginate --slurp` so the argument text that P1-T2 asserts (`api repos/owner/repo/rulesets`) is a contiguous substring.
