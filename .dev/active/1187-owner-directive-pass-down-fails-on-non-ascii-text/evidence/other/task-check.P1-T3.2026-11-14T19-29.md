# Task Check P1-T3 ([expect-fail])

Timestamp: 2026-11-14T19-26
Changed files: tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1
Selection rule: the changed test file itself (a test-only change; its own rows are the selection).

Command: sh SCRATCH/issue-1187-st.sh tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1 (check-only Invoke-Formatter, Invoke-ScriptAnalyzer with the repo settings, count of lines holding a character above U+007F)
EXIT_CODE: 0
Output Summary: formatter-unchanged=True, pssa-findings=0, non-ASCII lines=0.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 85 passed, 1 failed, 6 skipped (shard JUnit of this run; the 6 skips are the existing 'has parity envelopes for <leaf>' rows with recorded reasons). The one failure is the expected-fail row 'defines the Claude and Codex stdin readers with equal bodies apart from the name': the Claude dispatcher does not define Read-PreToolUseDispatchStandardInput (Expected a value). The row parses only the two dispatcher files.
