# Limited Diff (issue #928, P6-T12, loop pass 1)

Timestamp: 2026-10-16T03-17
Command: git diff -U0 MERGE_BASE -- .claude/hooks/subagentstop-envelope.ps1 .claude/hooks/enforce-epic-wave-barrier.ps1 .claude/agents
EXIT_CODE: 0

MERGE_BASE: adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99

Output Summary: subagentstop-envelope.ps1 shows only `@@ -12 +12 @@`; enforce-epic-wave-barrier.ps1 shows only `@@ -34,2 +34,2 @@`; the only `.claude/agents` file listed is `epic-orchestrator.md`, with the single hunk `@@ -133,3 +133,3 @@` (below the frontmatter).

```text
diff --git a/.claude/agents/epic-orchestrator.md b/.claude/agents/epic-orchestrator.md
index 1bda9c9ee..b91cf900c 100644
--- a/.claude/agents/epic-orchestrator.md
+++ b/.claude/agents/epic-orchestrator.md
@@ -133,3 +133,3 @@ the `mcp__drm-copilot__validate_orchestration_artifacts` call. If the check repo
-report it to the operator and halt. Its runtime effect is likely to depend on the `SubagentStop`
-transport and exit-code defect recorded in
-`docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md`.
+report it to the operator and halt. The `SubagentStop` transport and exit-code defect this check
+previously depended on was resolved by epic #904 and issue #928: a violation blocks the stop with
+exit 2 and a stderr reason.
diff --git a/.claude/hooks/enforce-epic-wave-barrier.ps1 b/.claude/hooks/enforce-epic-wave-barrier.ps1
index 2dae0884a..3638b309b 100644
--- a/.claude/hooks/enforce-epic-wave-barrier.ps1
+++ b/.claude/hooks/enforce-epic-wave-barrier.ps1
@@ -34,2 +34,2 @@
-    That hook's runtime effect is likely to depend on the SubagentStop transport defect recorded in
-    docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md.
+    The SubagentStop transport and exit-code defect that hook depended on was resolved by epic #904
+    and issue #928: a violation blocks the stop with exit 2 and a stderr reason.
diff --git a/.claude/hooks/subagentstop-envelope.ps1 b/.claude/hooks/subagentstop-envelope.ps1
index 2cc85967e..e9db6991e 100644
--- a/.claude/hooks/subagentstop-envelope.ps1
+++ b/.claude/hooks/subagentstop-envelope.ps1
@@ -12 +12 @@
-    docs/features/active/subagentstop-envelope-core-897/spec.md (issue #897). Where this file and any
+    docs/features/archive/subagentstop-envelope-core-897/spec.md (issue #897; at docs/features/active/subagentstop-envelope-core-897/ until the archive move). Where this file and any
```
