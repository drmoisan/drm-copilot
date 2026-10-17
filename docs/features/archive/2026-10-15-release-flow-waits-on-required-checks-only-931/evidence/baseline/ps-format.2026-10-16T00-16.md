# PowerShell Format Baseline (Issue #931)

Timestamp: 2026-10-16T00-16
Command: mcp__drm-copilot__run_poshqc_format (workspace_root = <worktree>)
EXIT_CODE: 0
Output Summary: Call returned "ok":true. Porcelain before and after are identical; the formatter changed no tracked file. No pre-existing formatter drift.

Call result: `"ok":true`
Summary (verbatim, host path replaced with `<worktree>`): `Ran bundled PoshQC format against '<worktree>'.`

## git status --porcelain (before)

```
 M docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/plan.2026-10-15T15-45.md
?? docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/evidence/
```

## git status --porcelain (after)

```
 M docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/plan.2026-10-15T15-45.md
?? docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/evidence/
```

Pre-existing formatter drift: none. No restore was required, so no third porcelain run was needed. The last recorded porcelain output lists no path outside the feature folder.
