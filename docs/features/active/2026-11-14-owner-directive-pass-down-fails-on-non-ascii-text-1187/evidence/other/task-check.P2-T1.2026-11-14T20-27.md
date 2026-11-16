# Task Check P2-T1

Timestamp: 2026-11-14T20-22
Changed files: .claude/hooks/invoke-pretooluse-dispatch.ps1 (Read-PreToolUseDispatchStandardInput added; ReadPayload default set to `{ Read-ClaudeHookRawPayload -ReadStandardInput { Read-PreToolUseDispatchStandardInput } }`; -EscapeHandling EscapeNonAscii on the trace write, the decision write, and the script-tail dependency emit; .DESCRIPTION and ReadPayload help updated), tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1 (test-defect fix, below).
Selection rule: the mirrored dispatcher suite plus every test file that names the changed dispatcher (search of tests/ for invoke-pretooluse-dispatch, Read-PreToolUseDispatchStandardInput, and Invoke-PreToolUseDispatchEntryPoint), restricted to the Claude surface: invoke-pretooluse-dispatch.Tests.ps1, PreToolUsePayload.Contract.Tests.ps1, tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1, hook-dependency-failure.Claude.Tests.ps1, enforce-owner-directive-pass-down.NonAscii.Tests.ps1, PreToolUseDispatch.Parity.Tests.ps1, test-execution-policy.Registration.Tests.ps1, tests/scripts/claude-lib/discovery-validation/DiscoveryCapability.Tests.ps1, tests/scripts/claude-runtime/claude-settings.Tests.ps1, tests/scripts/dev-tools/HookProcessCost.Tests.ps1. The Codex-surface files that name the Codex dispatcher run in the P2-T2 task check; test_codex_core_manifest_closure.py runs in the P2-T3 and gate pytest runs.

Command: sh SCRATCH/issue-1187-st.sh .claude/hooks/invoke-pretooluse-dispatch.ps1 (check-only Invoke-Formatter, Invoke-ScriptAnalyzer with the repo settings, count of lines holding a character above U+007F)
EXIT_CODE: 0
Output Summary: formatter-unchanged=True, pssa-findings=0, non-ASCII lines=0.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <the ten files above>
EXIT_CODE: 1
Output Summary: workers=8, wall-clock=201.18s; 1390 passed, 2 failed, 8 skipped.
- Expected failure until P2-T2: PreToolUse dispatcher stdin reader parity (issue #1187) / defines the Claude and Codex stdin readers with equal bodies apart from the name (the Codex reader does not exist yet).
- Test defect found: Invoke-PreToolUseDispatchEntryPoint non-ASCII output (issue #1187) / emits the dependency-failure deny of the script tail with every character below U+0080 asserted against $script:TailReason, which an earlier P1-T1 edit had removed from BeforeAll; before the fix the row failed at its ASCII assertion first, so this assertion was not reached. Fix: the row builds its expected reason in a local $expected, as the Codex row does. No assertion was weakened.
- Every P1-T1 row and the P1-T4 contrast row pass; PreToolUsePayload.Contract, hook-dependency-guard-completeness, hook-dependency-failure.Claude, and the other selected suites pass.

Command: sh SCRATCH/issue-1187-st.sh tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1 (after the test-defect fix)
EXIT_CODE: 0
Output Summary: static clean (formatter-unchanged=True, pssa-findings=0, non-ASCII lines=0); 25 passed, 0 failed.

.claude/lib/hook-payload/HookPayload.psm1 is unchanged (git status shows no change under .claude/lib/).
