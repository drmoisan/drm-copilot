# Fail-Before Proof (P1-T7, AC-12)

Timestamp: 2026-11-14T19-37
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1 tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1 tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1 tests/scripts/claude-hooks/enforce-owner-directive-pass-down.NonAscii.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Production state: unchanged. `git diff --stat HEAD -- .claude .codex` printed nothing before the run; both dispatchers are the pre-fix versions.
- Invoke-PoshQCParallelTest: workers=4, wall-clock=162.3s, exit code=1; shards 1-4 exited non-zero; no merged artifact (per-shard JUnit under artifacts/pester/parallel/shard-<i>/ read instead).
- Counts across the four shard JUnit files: 129 passed, 26 failed, 6 skipped (the 6 skips are the existing parity-envelope rows with recorded reasons).
- Every failing row is a row that P1-T1 to P1-T4 name as expected-fail; no other row failed.

Failing rows and failure messages:
- tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1 (12, P1-T1):
  - invoke-pretooluse-dispatch.ps1 script tail / denies a payload without a tool name through the registry beside the script when run in process: Expected Read-ClaudeHookRawPayload to be called 1 time exactly (with a ReadStandardInput naming Read-PreToolUseDispatchStandardInput), but was called 0 times.
  - Read-PreToolUseDispatchStandardInput (issue #1187) / decodes an em dash, decodes curly quotes, decodes a non-BMP character from UTF-8 bytes exactly; strips a leading UTF-8 byte order mark; maps an invalid byte to U+FFFD without throwing; disposes the stream it reads; opens the process standard input through the default stream seam without reading it (7): CommandNotFoundException, Read-PreToolUseDispatchStandardInput is not recognized.
  - Invoke-PreToolUseDispatchEntryPoint non-ASCII output (issue #1187) / emits the decision with every character below U+0080 and restores the reason; writes the trace line with every character below U+0080 and restores the reason; emits the dependency-failure deny of the script tail with every character below U+0080 (3): Expected $false (no character above U+007F) but got $true.
  - Invoke-PreToolUseDispatchEntryPoint non-ASCII output (issue #1187) / defaults ReadPayload to Read-ClaudeHookRawPayload with the UTF-8 reader: Expected strings to be the same, but they were different.
- tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1 (12, P1-T2):
  - Codex invoke-pretooluse-dispatch.ps1 script tail / denies a payload without a tool name through the registry beside the script when run in process: CommandNotFoundException, Could not find Command Read-CodexPreToolUseDispatchStandardInput (Mock target absent).
  - Read-CodexPreToolUseDispatchStandardInput (issue #1187) / the same seven reader rows: CommandNotFoundException, Read-CodexPreToolUseDispatchStandardInput is not recognized.
  - Invoke-CodexPreToolUseDispatchEntryPoint non-ASCII output (issue #1187) / the three output rows: Expected $false but got $true; defaults ReadPayload to the Codex UTF-8 reader: Expected strings to be the same.
- tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1 (1, P1-T3):
  - PreToolUse dispatcher stdin reader parity (issue #1187) / defines the Claude and Codex stdin readers with equal bodies apart from the name: Expected a value (the Claude dispatcher defines no Read-PreToolUseDispatchStandardInput).
- tests/scripts/claude-hooks/enforce-owner-directive-pass-down.NonAscii.Tests.ps1 (1, P1-T4):
  - stdin decode contrast (issue #1187 AC-12) / denies the Latin1 decode and allows the UTF-8 reader decode of the same relay bytes: CommandNotFoundException, Read-PreToolUseDispatchStandardInput is not recognized.

The AC-1, AC-3, and AC-5 rows therefore fail against the unchanged dispatchers, the run is not a discovery failure, and no fail-before exception dossier is needed.
