# [P4-T3/P4-T4] Lock File Regeneration — `extensions/drm-copilot/`

## npm install

- **Timestamp:** 2026-07-22T12-15
- **Command:** `npm install` (run in `extensions/drm-copilot/`)
- **EXIT_CODE:** 0

### Output Summary

- `changed 3 packages, and audited 461 packages in 2s`.
- Post-install audit surfaced `2 high severity vulnerabilities` remaining (down from 6 pre-fix).
- `git diff --stat -- extensions/drm-copilot/package-lock.json`: `extensions/drm-copilot/package-lock.json | 20 ++++++++++----------` (1 file changed, 10 insertions, 10 deletions) — confirms the lock file changed.

## npm audit fix (no --force)

- **Timestamp:** 2026-07-22T12-15
- **Command:** `npm audit fix` (run in `extensions/drm-copilot/`; no `--force` flag)
- **EXIT_CODE:** 0

### Output Summary

- `changed 3 packages, and audited 461 packages in 1s`.
- `found 0 vulnerabilities`.
- No `isSemVerMajor` warning was reported for `@modelcontextprotocol/sdk`.
- Confirmed post-fix: `extensions/drm-copilot/package.json` `dependencies["@modelcontextprotocol/sdk"]` is still `^1.29.0`; `extensions/drm-copilot/package-lock.json` resolves `@modelcontextprotocol/sdk` at `1.29.0`.
