# [P0-T6] [expect-fail] npm audit baseline — `packages/mcp-server/`

- **Timestamp:** 2026-07-22T12-15
- **Command:** `npm ci && npm audit --audit-level=moderate` (run in `packages/mcp-server/`)
- **EXIT_CODE:** 1 (non-zero, as expected for this `[expect-fail]` baseline task)

## Output Summary

- `npm ci`: exit 0.
- `npm audit --audit-level=moderate`: exit 1 — **4 vulnerabilities (3 moderate, 1 high)**.
- Advisories observed:
  - `@hono/node-server` `<2.0.5` — moderate — path traversal in `serve-static` on Windows via encoded backslash (GHSA-frvp-7c67-39w9), via `@modelcontextprotocol/sdk >=1.25.0`. npm again reports that `npm audit fix --force` would downgrade `@modelcontextprotocol/sdk` to `1.24.3` (breaking change) — confirms `--force` must not be used.
  - `fast-uri` 3.0.0-3.1.3 — high — host confusion advisories (GHSA-4c8g-83qw-93j6, GHSA-v2hh-gcrm-f6hx).
  - `hono` 4.0.0-4.12.26 — moderate — header de-dup drop, JSX context isolation, XSS via JSX escaping bypass (GHSA-xgm2-5f3f-mvvc, GHSA-hvrm-45r6-mjfj, GHSA-w62v-xxxg-mg59).
- No `brace-expansion`/`js-yaml` advisories in this manifest (consistent with the plan's note that `packages/mcp-server/package.json` has no `c8`-scoped `brace-expansion` override to raise).
- Confirms the `[expect-fail]` outcome for this baseline task.
