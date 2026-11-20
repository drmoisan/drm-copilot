# P0-T6 — npm audit Baseline (extensions/drm-copilot)

- Timestamp: 2026-09-03T08-35
- Command: `npm audit --audit-level=moderate` (run in `extensions/drm-copilot/`)
- EXIT_CODE: 1
- Output Summary: 3 vulnerabilities found (1 moderate, 2 high):
  - `browserslist` <=4.28.6 — high — GHSA-c83g-rgw3-j3cx, GHSA-73wf-gq98-2v4g
  - `fast-uri` 3.0.0 - 3.1.5 — high — GHSA-5jgf-p345-68v8, GHSA-f65p-4m7j-42xc, GHSA-fph4-wmhf-6fwf, GHSA-jqff-g426-hqxp
  - `qs` 2.2.5 - 6.15.3 — moderate — GHSA-x5fp-wj9c-mxmx, GHSA-4mjr-xmp4-gh2g
  All three report "fix available via `npm audit fix`". This matches the vulnerability count/severity distribution described in `issue.md`'s Actual Behavior section for `extensions/drm-copilot`. `@humanfs/node` does not appear (consistent with the plan's observation note that this workspace's resolved `@humanfs/node` version, 0.16.8, is not currently flagged).
