# Final QA Gate — Extension Package Dependency Install ([P10-T5])

Timestamp: 2026-08-08T14-53

Command: `npm --prefix extensions/drm-copilot ci`

EXIT_CODE: 0

Output Summary: `added 457 packages, and audited 458 packages in 7s`; `found 0 vulnerabilities`.
One deprecation warning was emitted for the transitive dependency `glob@10.5.0`; it is a
pre-existing property of the committed `extensions/drm-copilot/package-lock.json` and is out of
scope for this plan.

## Rationale for this task

`extensions/drm-copilot/node_modules` is absent in a fresh worktree, and `@eslint/js` — a
devDependency of that package imported by `extensions/drm-copilot/eslint.config.mjs` — resolves
from no ancestor `node_modules`. Without this install, [P10-T7] could not load its flat config.
`ci` was used rather than `install` so the committed lockfile
(`extensions/drm-copilot/package-lock.json`, lockfileVersion 3) is honoured exactly.

## Post-install verification

Command: `ls extensions/drm-copilot/node_modules/.bin/ | grep -i "^eslint"`

EXIT_CODE: 0

Output Summary:

```
eslint*
eslint.cmd
eslint.ps1*
```

`extensions/drm-copilot/node_modules/.bin/eslint` exists, satisfying this task's acceptance
criterion.

## Working-tree effect

`npm ci` writes only into the gitignored `extensions/drm-copilot/node_modules` directory. No
tracked file was created or modified, so this task triggers no loop restart and no bundled
`.claude` mirror re-sync.
