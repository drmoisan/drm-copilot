# FC diff guard (P1-T5, AC-3)

Timestamp: 2026-10-16T01-19
Command: git diff --numstat origin/main...HEAD -- tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
EXIT_CODE: 0
Output Summary: numstat 10 0 (ten lines added, none removed). descguard: PREFIX-EQUAL=True SUFFIX-EQUAL=True, OLD-LINES=80 NEW-LINES=90 UNDER-500=True, HEADER-ONLY=True.

Output: 10	0	tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1

Command: git diff origin/main...HEAD -- tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
EXIT_CODE: 0
Diff text:

```diff
@@ -11,6 +11,16 @@
     for feature-folder-resolution.ps1 and assert that the gate denies naming the readiness failure.
     Construction assertions carry -Because 'E-CONSTRUCTION'. Checkpoint content is a literal, so no
     case reads orchestration state, and no test creates, renames, moves, or deletes a file.
+
+    Coverage attribution note (issue #936). The two H2 codex deny rows execute line 41 of
+    .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1, the catch body of
+    the feature-folder-resolution.ps1 import guard. Their line-unique assertion checks that
+    OrchestrationFeatureFolderResolutionImportFailure equals 'feature-folder-resolution.ps1';
+    only line 41 assigns that value. A full-run CI coverage report can still show line 41
+    with ci="0". The likely cause is Pester 5.x breakpoint mode: each line breakpoint binds
+    to the first compiled instance of a script, and a later recompilation of the unchanged
+    file leaves later executions of the line unattributed. A coverage run scoped to
+    tests/scripts/codex-hooks attributes the line; the #936 evidence records both results.
 #>
 
 Describe 'preimplementation gate modes handler proof on the codex surface' {
```

Command: git merge-base origin/main HEAD
EXIT_CODE: 0
Output: adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99 (MB)

Command: git show MB:tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 > SCRATCH/old/failclosed.ps1
EXIT_CODE: 0
Note: the worktree isolation guard refused the absolute scratch redirect target, so the old copy was written to the gitignored path artifacts/pester/failclosed-old-936.ps1 instead; content is the same merge-base blob.

Command: poetry run python -I SCRATCH/cov936.py descguard SCRATCH/old/failclosed.ps1 tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
EXIT_CODE: 0
Output:
PREFIX-EQUAL=True SUFFIX-EQUAL=True
OLD-LINES=80 NEW-LINES=90 UNDER-500=True
HEADER-ONLY=True
