# PoshQC Format of the Edited Tests, Remediation Cycle 2 (issue #937 RI-7)

Timestamp: 2026-10-16T10-50
Task: P2-T10 (remediation-plan.2026-10-16T08-40.md)
Command: git hash-object <three edited test files>; mcp__drm-copilot__run_poshqc_format (workspace_root = WORKTREE, scan_folders = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]); git hash-object <three edited test files>; git status --porcelain
EXIT_CODE: 0
Output Summary: MCP ok = true. All three hashes are identical before and after the formatter run, so the formatter rewrote none of the edited files. The porcelain output lists only the three test files and FEATURE paths. Single loop pass; P2-T8 did not need a rerun.

MCP summary (verbatim, worktree root replaced by WORKTREE): "Ran bundled PoshQC format against 'WORKTREE' with 2 selected scan folder(s)."

## git hash-object

| File | Before | After |
|---|---|---|
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1 | 38f83bf5b8895bc8513a7693a04682b67ccbc729 | 38f83bf5b8895bc8513a7693a04682b67ccbc729 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 | 1923e63e04e5c5f620bf385f5c7ba4674b992b9f | 1923e63e04e5c5f620bf385f5c7ba4674b992b9f |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | 82274f04ea7af375368d35a7d6225e4aedc6b1a0 | 82274f04ea7af375368d35a7d6225e4aedc6b1a0 |

## git status --porcelain (after)

```text
 M docs/features/active/exempt-operand-unc-path-leg-937/remediation-plan.2026-10-16T08-40.md
 M docs/features/active/exempt-operand-unc-path-leg-937/spec.md
 M tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1
 M tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
 M tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/pathleg-rows-after-edit-c2.2026-10-16T10-49.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/test-edit-shape-c2.2026-10-16T10-49.md
```

## Acceptance

- Before and after hashes identical: met.
- Porcelain lists no path other than the three test files and FEATURE paths: met.
