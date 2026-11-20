# Baseline — extension dependency install and TypeScript formatting (Prettier, non-mutating check form)

Timestamp: 2026-08-20T09-53

Task: [P0-T11]

Command: (from `extensions/drm-copilot`) npm ci
Command: (from `extensions/drm-copilot`) node -e "console.log(require.resolve('eslint'))"
Command: (from `extensions/drm-copilot`) npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"
EXIT_CODE: 0

## SC10 remediation — dependencies installed into THIS worktree

`npm ci` from `extensions/drm-copilot` reported:

```
added 457 packages, and audited 458 packages in 6s
found 0 vulnerabilities
```

`extensions/drm-copilot/node_modules` now exists inside this worktree. Tool resolution was then
confirmed to bind to this worktree and not to any sibling checkout:

- resolved `eslint` path:
  `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad8da196d6247bdf4\extensions\drm-copilot\node_modules\eslint\lib\api.js`
- resolved `jest/bin/jest` path (recorded as a second confirmation):
  `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad8da196d6247bdf4\extensions\drm-copilot\node_modules\jest\bin\jest.js`

Both paths contain the worktree segment `agent-ad8da196d6247bdf4`, so the SC10 hazard (resolution
walking up to `C:\Users\DanMoisan\repos\drm-copilot\node_modules`, an incomplete ancestor tree that
made `npm run lint` fail with `Cannot find package '@eslint/js'`) is remediated. The plan is not
halted.

`extensions/drm-copilot/node_modules` is gitignored (`.gitignore:3`), so the install does not affect
any diff-based gate. A working-tree status check after the install showed only the plan file
(checkbox updates) and the new untracked feature `evidence/` directory as changed — no tracked
source file.

## Prettier check result

```
Checking formatting...
All matched files use Prettier code style!
```

- Prettier reported `All matched files use Prettier code style!`: yes
- Files Prettier would rewrite: none (empty list)
- Tracked files modified by this task: 0

The `--check` form is load-bearing for the same reason as [P0-T7]: a baseline must not write files
that the later diff-based gates measure. The mutating `npm run format` is used only in the Phase 8
final QC loop, and the glob set checked here (`src/**/*.ts`, `test/**/*.ts`, `*.json`, `*.cjs`) is
the same set the `format` script writes over.

Output Summary: `npm ci` installed 457 packages into this worktree's
`extensions/drm-copilot/node_modules` with 0 vulnerabilities; `eslint` resolves to
`...agent-ad8da196d6247bdf4\extensions\drm-copilot\node_modules\eslint\lib\api.js`, inside this
worktree. Prettier `--check` over `src/**/*.ts`, `test/**/*.ts`, `*.json`, `*.cjs` reports
`All matched files use Prettier code style!` with exit code 0 and an empty rewrite list. No tracked
file was modified.
