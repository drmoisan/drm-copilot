# MCP PoshQC Format Route Observation ([P0-T14])

Timestamp: 2026-10-09T22-09
Command: mcp__drm-copilot__run_poshqc_format with workspace_root `<WORKSPACE_ROOT>` and scan_folders [".claude/hooks", ".claude/lib", ".codex/hooks", ".codex/scripts", "tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime", "tests/scripts/claude-lib", "tests/scripts/codex-scripts"]
EXIT_CODE: 0
Output Summary: the tool call returned a result with ok true; the porcelain output after the call equals the output before it, so the tool rewrote no file.

MCP_OK: true
MCP_FORMAT_REWROTE: none

Porcelain before the call:

```text
 M docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/plan.2026-10-08T13-54.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-enumeration-mirror.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-enumeration-repo.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-reconciliation.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-rows.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-guard-worklist.md
```

Porcelain after the call:

```text
 M docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/plan.2026-10-08T13-54.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-enumeration-mirror.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-enumeration-repo.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-reconciliation.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-rows.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-guard-worklist.md
```

Final porcelain output (no restore was required): identical to the output after the call.
