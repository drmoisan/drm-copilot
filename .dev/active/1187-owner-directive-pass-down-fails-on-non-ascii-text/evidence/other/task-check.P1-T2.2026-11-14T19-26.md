# Task Check P1-T2 ([expect-fail])

Timestamp: 2026-11-14T19-24
Changed files: tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1
Selection rule: the changed test file itself (a test-only change; its own rows are the selection).

Command: sh SCRATCH/issue-1187-st.sh tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1 (check-only Invoke-Formatter, Invoke-ScriptAnalyzer with the repo settings, count of lines holding a character above U+007F)
EXIT_CODE: 0
Output Summary: formatter-unchanged=True, pssa-findings=0, non-ASCII lines=0.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 12 passed, 12 failed, 0 skipped (shard JUnit of this run). Every failure is an expected-fail row of P1-T2 against the unchanged Codex dispatcher:
- script tail row (updated): CommandNotFoundException, because Mock Read-CodexPreToolUseDispatchStandardInput names a function the unchanged dispatcher does not define.
- the five reader rows of P1-T1 and the default-seam row: CommandNotFoundException (reader absent).
- emits the decision / writes the trace line / emits the dependency-failure deny of the script tail with every character below U+0080: raw non-ASCII emitted (Expected $false ... but got $true).
- defaults ReadPayload to the Codex UTF-8 reader: default text differs.
Every other row of the file passes.

Deviation (micro-action, same reason as P1-T1): the row 'opens the process standard input through the default stream seam without reading it' is added so that the default OpenStream line of the Codex dispatcher is covered and its 100% Phase 0 line coverage does not drop.
