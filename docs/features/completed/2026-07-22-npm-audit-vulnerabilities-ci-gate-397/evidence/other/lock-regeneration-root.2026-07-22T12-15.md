# [P4-T1/P4-T2] Lock File Regeneration — root (`.`)

## npm install

- **Timestamp:** 2026-07-22T12-15
- **Command:** `npm install` (run in `.`, repo root)
- **EXIT_CODE:** 0

### Output Summary

- `changed 4 packages, and audited 532 packages in 3s`.
- Post-install audit surfaced `3 vulnerabilities (1 low, 2 high)` remaining (down from 7 pre-fix — the `@hono/node-server`, `fast-uri`, and `hono` overrides resolved immediately via `npm install`).
- `git diff --stat -- package-lock.json`: `package-lock.json | 26 +++++++++++++-------------` (1 file changed, 13 insertions, 13 deletions) — confirms the lock file changed.

## npm audit fix (no --force)

- **Timestamp:** 2026-07-22T12-15
- **Command:** `npm audit fix` (run in `.`, repo root; no `--force` flag)
- **EXIT_CODE:** 0

### Output Summary

- `added 2 packages, changed 4 packages, and audited 534 packages in 1s`.
- `found 0 vulnerabilities`.
- No `isSemVerMajor` warning was reported for `@modelcontextprotocol/sdk` (it was not touched by this step).
- Confirmed post-fix: `package.json` `dependencies["@modelcontextprotocol/sdk"]` is still `^1.29.0`; `package-lock.json` resolves `@modelcontextprotocol/sdk` at `1.29.0`.
