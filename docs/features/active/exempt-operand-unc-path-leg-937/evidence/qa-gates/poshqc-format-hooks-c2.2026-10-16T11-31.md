# PoshQC Format of the Hook Folders, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T11-31
Task: P3-T6 (remediation-plan.2026-10-16T08-40.md)
Command: mcp__drm-copilot__run_poshqc_format with workspace_root WORKTREE and scan_folders [".claude/hooks", ".codex/hooks", "extensions/drm-copilot/resources/claude-customizations/.claude/hooks", "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks"]; before and after: git hash-object <four targets copies>, git status --porcelain (via sh SCRATCH/c2_hashes_status.sh, which also hashes the four test files)
EXIT_CODE: 0
Output Summary: ok=true. Summary (verbatim, worktree root replaced by WORKTREE): "Ran bundled PoshQC format against 'WORKTREE' with 4 selected scan folder(s)." The four targets-copy hashes (f8e8e9a1a3ea4ff63d9535238fbb5c7595d76c38) and the porcelain output are identical before and after, so the formatter rewrote no file.

## Hashes before and after (identical)

```text
f8e8e9a1a3ea4ff63d9535238fbb5c7595d76c38  .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
f8e8e9a1a3ea4ff63d9535238fbb5c7595d76c38  .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
f8e8e9a1a3ea4ff63d9535238fbb5c7595d76c38  extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
f8e8e9a1a3ea4ff63d9535238fbb5c7595d76c38  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
c5781a22aacad3bf540fb9647429c1f8a2438496  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
38f83bf5b8895bc8513a7693a04682b67ccbc729  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1
1923e63e04e5c5f620bf385f5c7ba4674b992b9f  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
82274f04ea7af375368d35a7d6225e4aedc6b1a0  tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
```

## git status --porcelain before and after (identical)

```text
 M .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
 M .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
 M docs/features/active/exempt-operand-unc-path-leg-937/remediation-plan.2026-10-16T08-40.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-diff-shape-c2.2026-10-16T11-30.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-mirror-identity-c2.2026-10-16T11-30.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-size-check-c2.2026-10-16T11-30.md
```

## Acceptance

- Before and after hashes identical: met.
- Porcelain lists no path beyond the four copies and `FEATURE` paths: met.
