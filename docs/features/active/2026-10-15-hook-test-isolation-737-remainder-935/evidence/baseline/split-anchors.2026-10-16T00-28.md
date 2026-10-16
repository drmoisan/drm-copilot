# I-3 Split Anchors (P0-T4)

Timestamp: 2026-10-16T00-28
Command: sh SCRATCH/935/issue-935/p0t4-anchors.sh (runs `grep -n -F`, `grep -c -E "^\s*It '"` and `sed -n` line reads on the four I-3 files; the guard refused the inline form, so the same commands were run from a scratch script)
EXIT_CODE: 0

Output Summary: every anchor matches the plan. PASS.

`tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`
- line 428: `}` (first Describe closes)
- line 430: `# Sanctioned-removal manifest branch (issue #635). A separate Describe so the` (comment block start)
- line 434: `Describe 'enforce-epic-worktree-removal-gate.ps1 manifest branch' {`
- line 442: `    }` (BeforeAll closing brace)
- It count: 51

`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`
- line 154: `Context 'cross-file mock resolution smoke'`
- line 166: `Context 'call-target resolution seam'`
- line 236: `Context 'target resolution matrix'`
- It count: 21

`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
- line 32: `        function ConvertTo-CodexExemptionToolInput {`; line 69: `        }` (helper functions occupy 32-69); line 70 closes BeforeAll; line 71 is the probe row
- line 309: `Context 'issue #671 worktree selector allow cases'`
- line 445: `Context 'issue #663 quote-aware angle brackets'`
- line 500: `}`
- It count: 23

`tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1`
- line 14: `ALLOWLIST POLICY - THE TABLE IS EMPTY AND MUST REMAIN EMPTY.`
- line 65: `$script:PythonInvocationAllowlist = @()`
- line 69: `function Get-PythonInvocationAllowlist {`
- line 426: `function Test-PythonInvocationAllowlistMatch {`
- line 446: `function Select-UnallowedPythonInvocationFinding {`
- line 473: `function Get-UnusedPythonInvocationAllowlistEntry {`
