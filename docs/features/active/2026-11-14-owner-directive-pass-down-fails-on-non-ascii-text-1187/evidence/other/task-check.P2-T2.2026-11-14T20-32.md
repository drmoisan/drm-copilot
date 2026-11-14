# Task Check P2-T2

Timestamp: 2026-11-14T20-28
Changed files: .codex/hooks/invoke-pretooluse-dispatch.ps1 (Read-CodexPreToolUseDispatchStandardInput added with a body equal to the Claude reader; ReadPayload default set to `{ Read-CodexPreToolUseDispatchStandardInput }` with no probe or fallback; -EscapeHandling EscapeNonAscii on the trace write, the decision write, and the script-tail dependency emit; .DESCRIPTION and ReadPayload help updated).
Selection rule: the mirrored Codex dispatcher suite plus every test file that names the Codex dispatcher, and the parity suite that parses it: tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1, tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1, tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1, tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1. tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 is excluded locally (see below).

Command: sh SCRATCH/issue-1187-st.sh .codex/hooks/invoke-pretooluse-dispatch.ps1
EXIT_CODE: 0
Output Summary: formatter-unchanged=True, pssa-findings=0, non-ASCII lines=0.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1 tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1 tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
EXIT_CODE: 2
Output Summary: refused before any test ran: TEST_EXECUTION_POLICY_BLOCKED: local integration lane is CI-only evidence (test-execution policy). codex-pretooluse-integration.Tests.ps1 matches the integration lane suffix of config/test-execution-policy.json.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1 tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1 tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
EXIT_CODE: 0
Output Summary: workers=4, wall-clock=174.1s; 231 passed, 0 failed, 6 skipped (the existing parity-envelope skips). Every P1-T2 row passes, including the updated Codex script-tail row and the default-seam row, and the P1-T3 row 'defines the Claude and Codex stdin readers with equal bodies apart from the name' passes.

Deviation: codex-pretooluse-integration.Tests.ps1 is named by the P2-T2 acceptance but is an integration-lane suite, which runs in CI only; see evidence/other/deviation-integration-lane.2026-11-14T20-32.md.
