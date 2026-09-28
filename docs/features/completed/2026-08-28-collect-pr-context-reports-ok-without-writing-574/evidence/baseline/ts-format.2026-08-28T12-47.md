# Phase 0 — TypeScript Formatter Baseline

Timestamp: 2026-08-28T12-47

Task: [P0-T4]

Command: `git status --porcelain`, then `npm run format` (working directory
`extensions/drm-copilot`), then `git status --porcelain` again.

EXIT_CODE: 0

The recorded exit code is the exit code of `npm run format` itself, captured directly from the
command and not from a pipeline tail.

## Environment micro-action taken before the recorded run

`node_modules` was absent from both the repository root and `extensions/drm-copilot` in this
worktree, so a first invocation resolved a globally installed Prettier rather than the
repository-pinned one. `npm ci` was run in `extensions/drm-copilot` (exit code 0, 457 packages)
and at the repository root (exit code 0, 525 packages) before the run recorded here. Both write
only into `node_modules`, which `.gitignore` excludes, and the porcelain listing was unchanged by
either install. The run recorded below is against the repository-pinned Prettier.

## Output Summary

### Porcelain listing before the run, verbatim

```
 M docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/plan.2026-08-28T09-31.md
?? docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/
```

### Porcelain listing after the run, verbatim

```
 M docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/plan.2026-08-28T09-31.md
?? docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/
```

### Tracked files the run rewrote

None. The list is empty.

### Statement

The two porcelain listings are identical, so **the run left every matched file unchanged**. No
tracked file was rewritten, so no revert was necessary and no pre-existing formatting drift was
repaired by this baseline capture.

This is corroborated independently by the formatter's own per-file output beyond the exit code.
`npm run format` resolves to `prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` for
`drm-copilot@1.1.5`. The run printed 408 lines carrying the `(unchanged)` marker and printed no
matched-file line without it; the only two non-marker lines in the output are the two npm banner
lines quoted above. A file Prettier had rewritten would have printed without the `(unchanged)`
marker, so the marker count together with the empty complement is the success-case observation
that distinguishes a clean run from a repairing one.
