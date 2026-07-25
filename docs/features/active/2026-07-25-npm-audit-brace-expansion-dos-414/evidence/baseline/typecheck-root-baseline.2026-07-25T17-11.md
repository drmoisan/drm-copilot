# Baseline Gate — `npm run typecheck`, Repository Root (#414, [P0-T16])

Timestamp: 2026-07-25T17-11

Command: `npm run typecheck` (working directory: repository root, BEFORE any manifest edit)
EXIT_CODE: 0

The script guards on the presence of TypeScript sources under `src/` or `tests/` and then runs `tsc -p ./ --noEmit` with `stdio: inherit`.

```text
> drm-copilot@1.0.0 typecheck
> node -e "... resolveTool('typescript/bin/tsc') ... spawnSync(process.execPath,[tsc,'-p','./','--noEmit'], ...)"

(no diagnostics emitted)
```

## Diagnostic Count

| Category | Count |
|---|---|
| TypeScript errors | 0 |

`tsc --noEmit` emitted no diagnostics and returned status 0, which the wrapper propagated as the script exit code.

Output Summary: PASS at baseline. `npm run typecheck` exits 0 in the repository root before any #414 edit, with 0 TypeScript diagnostics. This establishes the green pre-edit state of the gate for comparison against [P4-T4].
