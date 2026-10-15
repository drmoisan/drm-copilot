# PowerShell Format Baseline (P0-T27)

Timestamp: 2026-10-13T10-43
Command: git status --porcelain; mcp__drm-copilot__run_poshqc_format workspace_root=<worktree> scan_folders=[".claude/hooks", ".codex/hooks", ".claude/lib/blast-radius", "tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-lib", "tests/scripts/claude-runtime", "tests/scripts/workflows"]; git status --porcelain
EXIT_CODE: 0
BASE: 320cb5ddf

EXIT_CODE is the MCP call disposition only (`"ok":true`). No formatter count or finding is asserted from it.

MCP result (verbatim, worktree path redacted):
```
{"ok":true,"tool":"run_poshqc_format","workspace_root":"<worktree>","summary":"Ran bundled PoshQC format against '<worktree>' with 8 selected scan folder(s)."}
```

Porcelain before format:
```
 M docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/plan.2026-10-11T10-39.md
?? docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/evidence/baseline/ts-jest-coverage.2026-10-13T10-42.md
```

Porcelain after format:
```
 M docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/plan.2026-10-11T10-39.md
?? docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/evidence/baseline/ts-jest-coverage.2026-10-13T10-42.md
```

Restore: none required (no file outside `<FEATURE>/` changed).

Output Summary: Call disposition ok:true. The second porcelain output is identical to the first and lists only paths under `<FEATURE>/` (Phase 0 plan check-off and P0-T26 artifact). The formatter changed no tracked file in the eight scan folders; no pre-existing format drift observed.
