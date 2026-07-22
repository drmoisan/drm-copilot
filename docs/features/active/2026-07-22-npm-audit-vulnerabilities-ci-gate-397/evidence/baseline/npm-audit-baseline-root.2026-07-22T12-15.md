# [P0-T4] [expect-fail] npm audit baseline — root (`.`)

- **Timestamp:** 2026-07-22T12-15
- **Command:** `npm ci && npm audit --audit-level=moderate` (run in `.`, repo root)
- **EXIT_CODE:** 1 (non-zero, as expected for this `[expect-fail]` baseline task)

## Output Summary

- `npm ci`: exit 0, installed 531 packages, audited 532 packages.
- `npm audit --audit-level=moderate`: exit 1 — **7 vulnerabilities (1 low, 3 moderate, 3 high)**.
- Advisories observed:
  - `body-parser` — denial of service when invalid limit value silently disables size enforcement (GHSA-v422-hmwv-36x6).
  - `brace-expansion` 2.0.0-2.1.1 || 3.0.0-5.0.6 — high — DoS via exponential-time expansion (GHSA-3jxr-9vmj-r5cp), via `node_modules/brace-expansion` and `node_modules/minimatch/node_modules/brace-expansion`.
  - `fast-uri` 3.0.0-3.1.3 — high — host confusion via failed IDN canonicalization / literal backslash authority delimiter (GHSA-4c8g-83qw-93j6, GHSA-v2hh-gcrm-f6hx).
  - `hono` 4.0.0-4.12.26 — moderate — API Gateway v1 adapter header de-dup drop, JSX context isolation, XSS via JSX escaping bypass (GHSA-xgm2-5f3f-mvvc, GHSA-hvrm-45r6-mjfj, GHSA-w62v-xxxg-mg59).
  - `js-yaml` 4.0.0-4.2.0 — high — YAML merge-key chains quadratic CPU consumption (GHSA-52cp-r559-cp3m).
  - (root cause of the `@hono/node-server`/`hono` chain, per spec.md Root Cause Analysis: `@modelcontextprotocol/sdk@1.29.0` declares `@hono/node-server@^1.19.9`, resolved to a vulnerable version — GHSA-frvp-7c67-39w9.)
- Confirms the `[expect-fail]` outcome for this baseline task: the audit fails before the Phase 1 override fix is applied.
