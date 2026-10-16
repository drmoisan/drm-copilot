# Targets Production Diff Shape, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T11-30
Task: P3-T5 (remediation-plan.2026-10-16T08-40.md)
Command: git diff --numstat HEAD -- <four copies>; git diff -U0 HEAD -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1; git merge-base origin/main HEAD; git diff --numstat <merge-base-sha> -- <four copies> (run via sh SCRATCH/c2_p3t3_5.sh from WORKTREE; HEAD = bdd9d30524faf15f0759146312f4ae44704d96ce)
EXIT_CODE: 0
Output Summary: HEAD numstat is 2 added / 2 deleted for each copy. The canonical HEAD -U0 diff has exactly two hunks, @@ -40 +40 @@ (comment line) and @@ -42 +42 @@ (pattern continuation). Merge base c415af626c292f38b910e3a27e70ab3e1903b31a; merge-base numstat is 9 added / 0 deleted for each copy.

## git diff --numstat HEAD (EXIT_CODE: 0)

```text
2	2	.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
2	2	.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
2	2	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
2	2	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
```

## git diff -U0 HEAD -- canonical copy (EXIT_CODE: 0)

```text
diff --git a/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 b/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
index e92597ce1..f8e8e9a1a 100644
--- a/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
+++ b/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
@@ -40 +40 @@ $script:OrchestrationTargetAbsolutePattern = '^([A-Za-z]:/|/(?!/))'
-# current-drive-rooted single backslash, a file: URI, a ~-prefixed home path, or surrounding whitespace.
+# current-drive-rooted single backslash, a URI scheme, a ~-prefixed home path, or surrounding whitespace.
@@ -42 +42 @@ $script:OrchestrationTargetNonLocalPattern = '^(?:\s|[\\/]{2}|[\\/]\?\?[\\/]|\\(
-'|file:|~)|\s$'
+'|[A-Za-z][A-Za-z0-9+.-]+:|~)|\s$'
```

## git merge-base origin/main HEAD

```text
c415af626c292f38b910e3a27e70ab3e1903b31a
```

## git diff --numstat c415af626c292f38b910e3a27e70ab3e1903b31a (EXIT_CODE: 0)

```text
9	0	.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
9	0	.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
9	0	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
9	0	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
```

## Acceptance

- HEAD numstat 2 added / 2 deleted for each copy: met.
- Exactly two hunks with headers beginning `@@ -40 +40 @@` and `@@ -42 +42 @@`: met. Line 41 (statement start), line 36 (`OrchestrationTargetAbsolutePattern`), `ConvertTo-OrchestrationTargetPath`, R0, the R1 guard (lines 230 and 231), and the R6 `-C` leg are unchanged.
- Merge-base numstat 9 added / 0 deleted for each copy (AC-10, AC-18): met.
