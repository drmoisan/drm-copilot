# Task Check P1-T4 ([expect-fail])

Timestamp: 2026-11-14T19-29
Changed files: tests/scripts/claude-hooks/enforce-owner-directive-pass-down.NonAscii.Tests.ps1 (new, 196 lines)
Selection rule: the new test file itself (a test-only change; its own rows are the selection).

Command: sh SCRATCH/issue-1187-st.sh tests/scripts/claude-hooks/enforce-owner-directive-pass-down.NonAscii.Tests.ps1 (check-only Invoke-Formatter, Invoke-ScriptAnalyzer with the repo settings, count of lines holding a character above U+007F)
EXIT_CODE: 0
Output Summary: formatter-unchanged=True, pssa-findings=0, non-ASCII lines=0.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/enforce-owner-directive-pass-down.NonAscii.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 19 passed, 1 failed, 0 skipped (shard JUnit of this run).
- Passing (AC-6): allows a verbatim relay of text containing <Name> x3; denies a relay whose <Name> is replaced by <Substitute> x3 (OWNER_DIRECTIVE_RELAY_REQUIRED); records a text_sha256 equal to the digest the hook validates for <Name> x3.
- Passing (AC-7): allows a main-session append of a <Name> entry to a ledger holding non-ASCII lines x3; denies an edit of an existing non-ASCII ledger line; denies an appended non-ASCII line whose digest covers altered text x3 (OWNER_DIRECTIVE_LEDGER_WRITE_DENIED).
- Passing (AC-8): accepts a decision-file write whose reason contains <Name> x3.
- Failing (expected, AC-12): denies the Latin1 decode and allows the UTF-8 reader decode of the same relay bytes: CommandNotFoundException for Read-PreToolUseDispatchStandardInput (reader absent in the unchanged dispatcher).
