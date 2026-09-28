# P0-T7 — npm audit Baseline (packages/mcp-server)

- Timestamp: 2026-09-03T08-36
- Command: `npm audit --audit-level=moderate` (run in `packages/mcp-server/`)
- EXIT_CODE: 1
- Output Summary: 2 vulnerabilities found (1 moderate, 1 high):
  - `fast-uri` 3.0.0 - 3.1.5 — high — GHSA-5jgf-p345-68v8, GHSA-f65p-4m7j-42xc, GHSA-fph4-wmhf-6fwf, GHSA-jqff-g426-hqxp
  - `qs` 2.2.5 - 6.15.3 — moderate — GHSA-x5fp-wj9c-mxmx, GHSA-4mjr-xmp4-gh2g
  Both report "fix available via `npm audit fix`". This matches the vulnerability count/severity distribution described in `issue.md`'s Actual Behavior section for `packages/mcp-server`. `browserslist` and `@humanfs/node` do not appear (consistent with the plan's observation note that this workspace has no `browserslist` dependency and `@humanfs/node` is genuinely absent from this lockfile).
