# Gate Rows - Issue 1034 Remediation Cycle 3 (P3-T2)

Timestamp: 2026-11-07T04-58
Command: sh SCRATCH/issue-1034-c3-suite.sh p3t2 over COMPOUND_SUITE, HELPER_SUITE, HOOK_SUITE, tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1, tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 and tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
EXIT_CODE: 0
Output Summary: PASS. 1460 tests, 1460 passed, 0 failed, 0 errored, 0 failed blocks, 0 failed containers. Every row of Groups F4, W, F5, D, C, R and H passes, including the 52 rows of the fail-before artifact.

| Suite | Passed | Failed |
|---|---|---|
| `COMPOUND_SUITE` | 209 | 0 |
| `HELPER_SUITE` | 138 | 0 |
| `HOOK_SUITE` | 149 | 0 |
| `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` | 195 | 0 |
| `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1` | 86 | 0 |
| `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` | 683 | 0 |

## F4 Action 3 Controls

Row 'keeps the selector of <Case>' in Context `Get-DocsCompleteGateMergeTarget` of `HELPER_SUITE`, selector `12` and no reason, all pass:

- `gh pr merge 12 # note; echo done`
- `gh pr merge 12 #99`
- `gh pr merge \<NL>12`
- `gh pr \<NL>merge 12`

## F5 Action 2 Controls

Row 'allows the quoted mention <Command> with no gh call when the gate is <State>' in Context `merge mentions` of `COMPOUND_SUITE`, in the enabled and disabled states, all pass:

- `git commit -m 'gh pr merge 12'`
- `echo "gh pr merge 12"`
- `git log --grep='gh pr merge'`
