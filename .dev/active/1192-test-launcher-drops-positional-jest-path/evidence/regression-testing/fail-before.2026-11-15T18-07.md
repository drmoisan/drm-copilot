# Fail-before proof (P1-T4)

Timestamp: 2026-11-15T18-07
Command: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/test-execution-policy.Tests.ps1 tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1`, run through `sh SCRATCH/issue-1192-run.sh` from the worktree root, before any edit to `.claude/hooks/test-execution-policy.ps1` (debugging evidence, not a gate).
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Two shards: shard 1 (hook test file) Passed 204, Failed 8; shard 2 (launcher test file) Passed 38, Failed 1. Total 9 failed test cases, which are 5 distinct test names; the hook-test names each fail once per hook copy (`.claude/hooks` and `.codex/hooks`).
- Failing tests, by name:
  1. `suite command builder.builds the jest suite with one --testPathIgnorePatterns word per pattern and keeps a positional extra` (updated case; `.claude/hooks` and `.codex/hooks`)
  2. `suite command builder.places a single jest positional before the first --testPathIgnorePatterns word` (both copies)
  3. `suite command builder.places a jest positional and a flag extra before every --testPathIgnorePatterns word` (both copies)
  4. `suite command builder.places a pester -TestPath extra before -ExcludeTag and keeps both exclusion groups intact` (both copies; fails on the word-order assertion)
  5. `Invoke-TestSuiteLauncher argument and field reach (issue #1158, D26, D27).places a jest-extension positional before the first --testPathIgnorePatterns word in ArgumentList`
- No other test failed: the new no-extras cases, the pytest, dotnet-test, and bats ordering cases, and `refuses a jest-extension integration operand with exit 2 and starts nothing, beside a valid positional run` pass against the unmodified builder.
- Queue note: earlier launcher attempts that exited 75 were queue timeouts and are not counted.
