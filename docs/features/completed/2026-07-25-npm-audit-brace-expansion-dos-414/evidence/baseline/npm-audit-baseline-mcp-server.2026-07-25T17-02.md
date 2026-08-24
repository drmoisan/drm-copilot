# Fail-Before-Window Baseline — `npm audit`, `packages/mcp-server` (#414, [P0-T9], passing control)

Timestamp: 2026-07-25T17-02

Command: `npm audit --audit-level=moderate` (working directory: `packages/mcp-server`, BEFORE any manifest edit)
EXIT_CODE: 0

```text
found 0 vulnerabilities
```

Output Summary: PASS. `packages/mcp-server` reports `found 0 vulnerabilities` and exits 0 at `--audit-level=moderate` in the same advisory-database window in which the repository root ([P0-T7], exit 1, 22 high) and `extensions/drm-copilot` ([P0-T8], exit 1, 20 high) fail. This establishes the one-passing-root control: the two failures are specific to trees containing the `brace-expansion`/`minimatch`/`glob` package family, not a global property of the advisory database or the audit invocation. This root is not modified by #414; [P3-T4] re-runs the same command post-change as the regression guard.
