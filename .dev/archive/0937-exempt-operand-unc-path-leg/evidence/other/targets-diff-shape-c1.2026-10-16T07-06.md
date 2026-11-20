# Targets production diff shape, remediation cycle 1 (P2-T5)

Timestamp: 2026-10-16T07-06
Command: git diff --numstat HEAD -- <the four targets copies>
EXIT_CODE: 0
Output Summary: HEAD numstat is `4 2` for each of the four copies. The HEAD `-U0` diff of the canonical copy has exactly one hunk, header `@@ -39,2 +39,4 @@`, replacing only the pattern comment line and the `OrchestrationTargetNonLocalPattern` assignment. Merge base with origin/main is ba53ff5694a42e975d5d1db99b2b6ef505143e66; merge-base numstat is `9 0` for each copy (additions only).

## HEAD numstat (verbatim)

```
4	2	.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
4	2	.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
4	2	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
4	2	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
```

## HEAD -U0 diff of the canonical copy (verbatim)

Command: git diff -U0 HEAD -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
EXIT_CODE: 0

```
diff --git a/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 b/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
index ef89c7f2e..e92597ce1 100644
--- a/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
+++ b/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
@@ -39,2 +39,4 @@ $script:OrchestrationTargetAbsolutePattern = '^([A-Za-z]:/|/(?!/))'
-# device, or NT-object prefixes in either separator style, or a drive-relative drive letter.
-$script:OrchestrationTargetNonLocalPattern = '^(?:[\\/]{2}|[\\/]\?\?[\\/]|[A-Za-z]:(?![\\/]))'
+# device, or NT-object prefixes in either separator style, a drive-relative drive letter, a
+# current-drive-rooted single backslash, a file: URI, a ~-prefixed home path, or surrounding whitespace.
+$script:OrchestrationTargetNonLocalPattern = '^(?:\s|[\\/]{2}|[\\/]\?\?[\\/]|\\(?![\\/])|[A-Za-z]:(?![\\/])' +
+'|file:|~)|\s$'
```

## Merge base

Command: git merge-base origin/main HEAD
EXIT_CODE: 0

```
ba53ff5694a42e975d5d1db99b2b6ef505143e66
```

## Merge-base numstat (verbatim)

Command: git diff --numstat ba53ff5694a42e975d5d1db99b2b6ef505143e66 -- <the four targets copies>
EXIT_CODE: 0

```
9	0	.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
9	0	.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
9	0	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
9	0	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
```

## Acceptance check

- HEAD numstat `4` added and `2` deleted for each copy: met.
- HEAD `-U0` diff contains exactly one hunk with header beginning `@@ -39,2 +39,4 @@`: met. `OrchestrationTargetAbsolutePattern` (line 36), `ConvertTo-OrchestrationTargetPath`, R0, the R1 guard statement, and the R6 `-C` leg are outside the hunk and unchanged.
- Merge-base numstat `9` added and `0` deleted for each copy (AC-18, AC-10): met.
