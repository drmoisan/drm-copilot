# Post-Change Regression-Guard Audit — `packages/mcp-server` (#414, [P3-T4])

Timestamp: 2026-07-25T21-54

Command: `npm audit --audit-level=moderate` (working directory: `packages/mcp-server`, AFTER the root and extension manifest edits and lockfile regenerations)
EXIT_CODE: 0

## Verbatim Output

```text
found 0 vulnerabilities
```

## Regression-Guard Comparison

| Run | Artifact | EXIT_CODE | Findings |
|---|---|---|---|
| Pre-change baseline ([P0-T9]) | `evidence/baseline/npm-audit-baseline-mcp-server.2026-07-25T17-02.md` | 0 | `found 0 vulnerabilities` |
| Post-change ([P3-T4]) | this artifact | 0 | `found 0 vulnerabilities` |

The result is unchanged, as expected: `packages/mcp-server` is an independent npm project whose manifest and lockfile were not touched by this change, and its tree contains no `brace-expansion`, `minimatch`, or `glob` node.

## Untouched-Root Confirmation

Command: `git status --porcelain packages/mcp-server` (working directory: repository root)
EXIT_CODE: 0

```text
(no output — zero modified or untracked paths under packages/mcp-server)
```

Output Summary: `npm audit --audit-level=moderate` in `packages/mcp-server` exits 0 with `found 0 vulnerabilities`, identical to its pre-change baseline, so the one previously-passing root continues to pass. `git status --porcelain packages/mcp-server` returns no output, confirming no file under that root was modified. This satisfies the `spec.md` acceptance criterion "`npm audit --audit-level=moderate` exits 0 in `packages/mcp-server` (regression guard)".
