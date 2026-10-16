# DEC diff guard (P1-T6, AC-3)

Timestamp: 2026-10-16T01-19
Command: git diff --numstat origin/main...HEAD -- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1
EXIT_CODE: 0
Output Summary: numstat 11 0 (eleven lines added, none removed). descguard: PREFIX-EQUAL=True SUFFIX-EQUAL=True, OLD-LINES=97 NEW-LINES=108 UNDER-500=True, HEADER-ONLY=True.

Output: 11	0	tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1

Command: git diff origin/main...HEAD -- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1
EXIT_CODE: 0
Diff text:

```diff
@@ -13,6 +13,17 @@
     constructors Get-OrchestrationPreimplementationGateBlockDecision and
     Get-OrchestrationPreimplementationGateAllowDecision. Each row uses a relative path leg, so
     the only target is the session root. No row creates a file or starts a process.
+
+    Coverage attribution note (issue #936). ES-D1 executes lines 206 and 207 of
+    .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1, and ES-D2
+    executes lines 206 and 209. ES-D1 makes the exact-reason assertion: its deny decision is
+    built only by the stand-in block constructor, which only line 207 calls. A full-run CI
+    coverage report can still show lines 183, 190, 191, 206, 207, and 209 of that function
+    with ci="0"; other Codex suites reach lines 183, 190, and 191. The likely cause is
+    Pester 5.x breakpoint mode: each line breakpoint binds to the first compiled instance of
+    a script, and a later recompilation of the unchanged file leaves later executions of
+    those lines unattributed. A coverage run scoped to tests/scripts/codex-hooks attributes
+    lines 206 and 207; the #936 evidence records both results.
 #>
 
 Describe 'Codex epic-scope decision tail (issue #903)' {
```

Command: git merge-base origin/main HEAD
EXIT_CODE: 0
Output: adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99 (MB)

Command: git show MB:tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 > SCRATCH/old/decision.ps1
EXIT_CODE: 0
Note: the worktree isolation guard refused the absolute scratch redirect target, so the old copy was written to the gitignored path artifacts/pester/decision-old-936.ps1 instead; content is the same merge-base blob.

Command: poetry run python -I SCRATCH/cov936.py descguard SCRATCH/old/decision.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1
EXIT_CODE: 0
Output:
PREFIX-EQUAL=True SUFFIX-EQUAL=True
OLD-LINES=97 NEW-LINES=108 UNDER-500=True
HEADER-ONLY=True
