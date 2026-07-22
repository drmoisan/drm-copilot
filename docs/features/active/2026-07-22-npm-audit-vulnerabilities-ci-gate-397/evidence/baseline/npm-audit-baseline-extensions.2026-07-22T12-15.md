# [P0-T5] [expect-fail] npm audit baseline — `extensions/drm-copilot/`

- **Timestamp:** 2026-07-22T12-15
- **Command:** `npm ci && npm audit --audit-level=moderate` (run in `extensions/drm-copilot/`)
- **EXIT_CODE:** 1 (non-zero, as expected for this `[expect-fail]` baseline task)

## Output Summary

- `npm ci`: exit 0.
- `npm audit --audit-level=moderate`: exit 1 — **6 vulnerabilities (3 moderate, 3 high)**.
- Advisories observed:
  - `@hono/node-server` `<2.0.5` — moderate — path traversal in `serve-static` on Windows via encoded backslash (GHSA-frvp-7c67-39w9), pulled in transitively via `@modelcontextprotocol/sdk >=1.25.0`. npm reports the naive `npm audit fix --force` remediation would downgrade `@modelcontextprotocol/sdk` to `1.24.3` (a breaking change) — confirms the plan's decision to use an `overrides` pin instead of `--force`.
  - `brace-expansion` 2.0.0-2.1.1 || 3.0.0-5.0.6 — high — DoS via exponential-time expansion (GHSA-3jxr-9vmj-r5cp), via `node_modules/brace-expansion` and `node_modules/glob/node_modules/brace-expansion`.
  - `fast-uri` 3.0.0-3.1.3 — high — host confusion advisories (GHSA-4c8g-83qw-93j6, GHSA-v2hh-gcrm-f6hx).
  - `hono` 4.0.0-4.12.26 — moderate — header de-dup drop, JSX context isolation, XSS via JSX escaping bypass (GHSA-xgm2-5f3f-mvvc, GHSA-hvrm-45r6-mjfj, GHSA-w62v-xxxg-mg59).
  - `js-yaml` 4.0.0-4.2.0 — high — quadratic CPU consumption via YAML merge-key chains (GHSA-52cp-r559-cp3m).
- Confirms the `[expect-fail]` outcome for this baseline task, and directly confirms the spec's root-cause claim that `npm audit fix --force` would force an unwanted SDK downgrade.
