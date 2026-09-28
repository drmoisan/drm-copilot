# P0-T5 — npm audit Baseline (Repo Root)

- Timestamp: 2026-09-03T08-34
- Command: `npm audit --audit-level=moderate` (run in `.`, repo root)
- EXIT_CODE: 1
- Output Summary: 4 vulnerabilities found (2 moderate, 2 high):
  - `@humanfs/node` <0.16.8 — moderate — GHSA-p498-v437-472g
  - `browserslist` <=4.28.6 — high — GHSA-c83g-rgw3-j3cx, GHSA-73wf-gq98-2v4g
  - `fast-uri` 3.0.0 - 3.1.5 — high — GHSA-5jgf-p345-68v8, GHSA-f65p-4m7j-42xc, GHSA-fph4-wmhf-6fwf, GHSA-jqff-g426-hqxp
  - `qs` 2.2.5 - 6.15.3 — moderate — GHSA-x5fp-wj9c-mxmx, GHSA-4mjr-xmp4-gh2g
  All four report "fix available via `npm audit fix`". This matches the vulnerability count/severity distribution described in `issue.md`'s Actual Behavior section for the root workspace.
