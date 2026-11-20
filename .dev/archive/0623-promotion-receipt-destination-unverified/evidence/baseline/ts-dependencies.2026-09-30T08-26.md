# TypeScript Locked Dependency Install (#623)

Timestamp: 2026-09-30T08-26
Command: npm --prefix extensions/drm-copilot ci; npm --prefix extensions/drm-copilot ls @eslint/js; git diff --quiet 6e6ccd62792e0838bee7459a2b468de83ad5d408 -- extensions/drm-copilot/package.json extensions/drm-copilot/package-lock.json; git status --porcelain --untracked-files=all
EXIT_CODE: 0
Output Summary: npm ci exit 0 ("added 452 packages, and audited 453 packages in 13s"; npm audit reported 2 vulnerabilities, informational only). npm ls exit 0 and printed "@eslint/js@10.0.1". git diff --quiet exit 0 (package.json and package-lock.json unchanged). git status after install lists only FEATURE paths (plan file and two baseline artifacts); with FEATURE lines excluded, the output is empty, identical to P0-T6.

## Per-command results

- npm ci: EXIT_CODE 0
- npm ls @eslint/js: EXIT_CODE 0; line `└── @eslint/js@10.0.1`
- git diff --quiet BASE_SHA -- package.json package-lock.json: EXIT_CODE 0
- git status --porcelain --untracked-files=all (verbatim):

```
 M docs/features/active/promotion-receipt-destination-unverified-623/plan.2026-09-29T19-06.md
?? docs/features/active/promotion-receipt-destination-unverified-623/evidence/baseline/branch-state.2026-09-30T08-26.md
?? docs/features/active/promotion-receipt-destination-unverified-623/evidence/baseline/phase0-instructions-read.2026-09-30T08-26.md
```

Non-FEATURE lines: none (matches P0-T6).
