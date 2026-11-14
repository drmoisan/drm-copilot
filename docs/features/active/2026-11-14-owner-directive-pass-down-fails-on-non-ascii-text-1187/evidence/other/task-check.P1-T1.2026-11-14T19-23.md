# Task Check P1-T1 ([expect-fail])

Timestamp: 2026-11-14T19-22
Changed files: tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1
Selection rule: the changed test file itself (a test-only change; its own rows are the selection).

Command: sh SCRATCH/issue-1187-st.sh tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1 (check-only Invoke-Formatter, Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1, count of lines holding a character above U+007F)
EXIT_CODE: 0
Output Summary: formatter-unchanged=True, pssa-findings=0, non-ASCII lines=0.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 13 passed, 12 failed, 0 skipped (shard JUnit of this run). Every failure is an expected-fail row of P1-T1 against the unchanged dispatcher:
- script tail row (updated): Read-ClaudeHookRawPayload called 0 times with a ReadStandardInput naming Read-PreToolUseDispatchStandardInput.
- decodes an em dash / curly quotes / a non-BMP character from UTF-8 bytes exactly; strips a leading UTF-8 byte order mark; maps an invalid byte to U+FFFD without throwing; disposes the stream it reads; opens the process standard input through the default stream seam without reading it: CommandNotFoundException (reader absent).
- emits the decision / writes the trace line with every character below U+0080 and restores the reason: raw non-ASCII emitted.
- emits the dependency-failure deny of the script tail with every character below U+0080: raw non-ASCII emitted.
- defaults ReadPayload to Read-ClaudeHookRawPayload with the UTF-8 reader: default text differs.
Every other row of the file passes.

Deviation (micro-action, recorded for review): the row 'opens the process standard input through the default stream seam without reading it' is added beyond the rows the plan names. The Phase 0 baseline shows both dispatchers at 100% line coverage and shows parameter-default lines are instrumented, so the plan's expected uncovered default OpenStream line would break the P3-T2 no-drop condition. The row runs only the default seam script block taken from the function's syntax tree (same source file, so coverage applies), checks that it returns a stream, and disposes it without reading.
