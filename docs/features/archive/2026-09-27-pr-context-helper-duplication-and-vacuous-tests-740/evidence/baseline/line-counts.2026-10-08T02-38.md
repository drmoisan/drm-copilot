# Baseline Line Counts (P0-T16)

Timestamp: 2026-10-08T02-38
Command: git grep -c -E "^" -- extensions/drm-copilot/src/lib/pr-context/models.ts extensions/drm-copilot/src/lib/pr-context/collector-core.ts extensions/drm-copilot/src/lib/pr-context/render.ts extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts extensions/drm-copilot/test/lib/pr-context/models.test.ts extensions/drm-copilot/test/lib/pr-context/feature-docs.test.ts extensions/drm-copilot/jest.config.cjs
EXIT_CODE: 0
Output Summary: PASS. Eleven path:count lines. Two counts differ from D6 by more than one line (verification-evidence.ts 295 vs 293; jest.config.cjs 455 vs 356); both differences come from origin/main merged at 6dac65b0 (DEV-1, DEV-2). D6 headroom re-derived below; every projected count stays under 500.

```
extensions/drm-copilot/jest.config.cjs:455
extensions/drm-copilot/src/lib/pr-context/collector-core.ts:386
extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts:316
extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts:387
extensions/drm-copilot/src/lib/pr-context/models.ts:348
extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts:442
extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts:407
extensions/drm-copilot/src/lib/pr-context/render.ts:400
extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:295
extensions/drm-copilot/test/lib/pr-context/feature-docs.test.ts:311
extensions/drm-copilot/test/lib/pr-context/models.test.ts:237
```

## Re-derived D6 headroom

| File | Baseline | Planned growth | Projected | Headroom to 500 |
| --- | --- | --- | --- | --- |
| jest.config.cjs | 455 | about +15 | about 470 | about 30 |
| verification-evidence.ts | 295 | shrinks (two helpers removed) | under 295 | over 205 |
| models.ts | 348 | about +40 | about 388 | about 112 |
| models.test.ts | 237 | about +165 | about 402 | about 98 |
| feature-docs.test.ts | 311 | about +50 | about 361 | about 139 |

All other in-scope files only shrink.
