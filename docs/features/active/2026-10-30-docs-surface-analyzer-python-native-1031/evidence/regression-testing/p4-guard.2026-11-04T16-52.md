# [P4-T7] Guard detection class 5 and the D3 allowlist entry

Timestamp: 2026-11-04T16-52
Command: sh SCRATCH/issue-1031-gate.sh issue-1031-p4t7.out tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1,tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 -NoCoverage (branch-current Invoke-PoshQCTest, both suites in one process)
EXIT_CODE: 0
Output Summary: artifacts/pester/pester-junit.xml tests=89 failures=0 errors=0 (enforcement-hooks-no-python-invocation.Tests.ps1 35, enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 54, unchanged). Passing cases include:
- repository scan.reports no Python invocation beyond the allowlist across the guarded tree
- repository scan.carries no stale allowlist entry (the D3 entry is matched by the three class-5 findings below)
- allowlist policy.ships exactly the D3 allowlist entry (formerly 'ships an empty allowlist')
- detection class 5 - interpreter target handed to a scriptblock seam.reports a seam call whose target is a constant interpreter name
- detection class 5 - interpreter target handed to a scriptblock seam.reports no finding for a seam call whose target is another constant or a variable
The cases 'reports no finding for a scriptblock-parameter seam invocation' and 'reports no finding when a seam variable differs from its parameter by letter case' pass unchanged.

Command: sh SCRATCH/issue-1031-run.sh issue-1031-libfind.ps1 issue-1031-libfind.out (Get-PythonInvocationFinding over every .ps1 and .psm1 file of .claude/lib/docs)
EXIT_CODE: 0
Output Summary: finding list for LIB (three findings, all in the allowlisted function):
- .claude/lib/docs/DocsAnalyzerPythonNative.psm1:78 [SeamInterpreterTarget] in Invoke-DocsPythonNativeInterpreter: python3
- .claude/lib/docs/DocsAnalyzerPythonNative.psm1:79 [SeamInterpreterTarget] in Invoke-DocsPythonNativeInterpreter: python
- .claude/lib/docs/DocsAnalyzerPythonNative.psm1:80 [SeamInterpreterTarget] in Invoke-DocsPythonNativeInterpreter: py
No other LIB file yields a finding.

Command: git diff --numstat MERGE_BASE -- tests/scripts/claude-runtime tests/scripts/codex-hooks
EXIT_CODE: 0
Output Summary: EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1 14/8; EnforcementHooksNoPythonInvocation.Helpers.ps1 15/2; enforcement-hooks-no-python-invocation.Tests.ps1 44/6; tests/scripts/codex-hooks unchanged.
