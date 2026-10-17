# PoshQC Format of the Test Folders After the Move, Remediation Cycle 2 (issue #937 RI-8)

Timestamp: 2026-10-16T10-36
Task: P1-T6 (remediation-plan.2026-10-16T08-40.md)
Command: git hash-object <source suite> <new suite>; mcp__drm-copilot__run_poshqc_format (workspace_root = WORKTREE, scan_folders = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]); git hash-object <source suite> <new suite>; git status --porcelain
EXIT_CODE: 0
Output Summary: MCP ok = true. Both hashes are identical before and after the formatter run, so the formatter rewrote neither suite. The porcelain output lists only the two suites and FEATURE paths.

MCP summary (verbatim, worktree root replaced by WORKTREE): "Ran bundled PoshQC format against 'WORKTREE' with 2 selected scan folder(s)."

Source suite: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1`
New suite: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1`

## git hash-object

| File | Before | After |
|---|---|---|
| Source suite | c5781a22aacad3bf540fb9647429c1f8a2438496 | c5781a22aacad3bf540fb9647429c1f8a2438496 |
| New suite | 61ad1c96a225b527f87427b8f01062b96083cf64 | 61ad1c96a225b527f87427b8f01062b96083cf64 |

## git status --porcelain (after)

```text
 M docs/features/active/exempt-operand-unc-path-leg-937/remediation-plan.2026-10-16T08-40.md
 M tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/pathleg-rows-after-move-c2.2026-10-16T10-36.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/test-move-shape-c2.2026-10-16T10-35.md
?? tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1
```

## Acceptance

- Before and after hashes identical: met.
- Porcelain lists no path other than the two suites and FEATURE paths: met.
