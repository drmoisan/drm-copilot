# Diff Additive-Only — Command-Exemption Suites (issue #671)

Timestamp: 2026-09-17T08-19
Task: [P5-T5]
Command: git -C <worktree root> status --porcelain ; git -C <worktree root> diff --merge-base main -- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 ; cross-check: git -C <worktree root> diff --merge-base main --numstat -- <same two paths>
EXIT_CODE: 0

Output Summary:
- Removed content lines: 0. The diff contains no line beginning with a single `-` other than the two `---` file headers.
- Claude suite: one hunk `@@ -293,4 +293,58 @@`, 54 added lines, 0 removed.
- Codex suite: one hunk `@@ -299,4 +299,59 @@`, 55 added lines, 0 removed.
- The numstat cross-check agrees: `54 0` (Claude) and `55 0` (Codex).
- Porcelain capture: identical to the [P5-T1] capture (both suites listed as ` M`).
- Both hunks append the two new `issue #671` Contexts after the existing D3/D8 Context. No existing `It` node or `-ForEach` row is touched.
- Route note: the full-diff capture was first issued with a stray trailing `--stat` token, which git read as a pathspec after `--` that matches no file, so the output equals that of the command recorded above. The numstat cross-check was then issued in the exact recorded form.

## Numstat capture

```
54	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
55	0	tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
```

## Hunk headers from the full diff

```
--- a/tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
+++ b/tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
@@ -293,4 +293,58 @@ NOTE
--- a/tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
+++ b/tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
@@ -299,4 +299,59 @@ NOTE
```

Count of removed content lines: 0
