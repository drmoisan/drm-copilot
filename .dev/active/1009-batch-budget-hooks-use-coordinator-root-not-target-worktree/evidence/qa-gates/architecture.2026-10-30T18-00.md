# Architecture-Boundary Suites, Final Pass (issue #1009)

Timestamp: 2026-10-30T18-00
Command: sh SCRATCH/issue-1009-pester.sh issue-1009-arch.txt (Invoke-PoshQCTest over tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 and tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1; counts from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: JUnit total=704 passed=704 failed=0 skipped=0.
- hook-dependency-guard-completeness.Tests.ps1: 671/671 (S1 to S6 rows for all four canonical batch-budget hooks and their mirrors pass with the new guarded import and dot-source).
- enforcement-hooks-no-python-invocation.Tests.ps1: 33/33.

Loop history: the first run of this gate failed one row of enforcement-hooks-no-python-invocation.Tests.ps1 (`reports no Python invocation beyond the allowlist across the guarded tree`): the scanner reports every `& $variable` call whose variable is not a `[scriptblock]` parameter as a fail-closed DynamicInvocation finding, and the first resolver design invoked local scriptblocks. `Resolve-HookTargetWorktree` was restructured so the only ampersand invocations are of its `[scriptblock]` parameters (`WorktreeListInvoker`, `CheckpointIssueReader`) and its helpers are nested functions called by constant name; the twin was regenerated, bundles re-copied, and the loop restarted at the format gate. The resolver behavior rows (83 per suite) pass unchanged.
