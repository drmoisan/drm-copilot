# Baseline Gate — `npm run compile`, `extensions/drm-copilot` (#414, [P0-T20])

Timestamp: 2026-07-25T17-15

Command: `npm run compile` (working directory: `extensions/drm-copilot`, BEFORE any manifest edit)
EXIT_CODE: 0

```text
> drm-copilot@1.0.19 compile
> tsc -p ./ --noEmit && npm run bundle:extension && npm run bundle:mcp-server


> drm-copilot@1.0.19 bundle:extension
> node esbuild-extension.cjs


> drm-copilot@1.0.19 bundle:mcp-server
> node esbuild-mcp-server.cjs

(no errors emitted)
```

All three stages of the compound script completed: `tsc -p ./ --noEmit`, the esbuild extension bundle, and the esbuild mcp-server bundle.

The build emits bundle output into the extension's ignored build directory only; no tracked file was modified by this baseline run:

Command: `git status --porcelain` (repository root, after the compile)
EXIT_CODE: 0

```text
 M docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/plan.2026-07-25T15-42.md
?? docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/
```

Only this feature's own plan checklist and evidence directory are reported, both under the excluded `docs/features/` prefix.

Output Summary: PASS at baseline. `npm run compile` exits 0 in `extensions/drm-copilot` before any #414 edit; type-check, extension bundling, and mcp-server bundling all succeed against the pre-edit dependency tree. No tracked source or dependency file was modified by the run. This establishes the green pre-edit state of the gate for comparison against [P5-T4].
