# TS Coverage Comparison ([P7-T6])

Timestamp: 2026-09-26T22-14

Command:
1. `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary --coverageReporters=lcov` (from `extensions/drm-copilot`; the [P7-T5] run, iteration 2)
2. `git diff -U0 b67453837646fd2dd4f5ac692f76e6f7703fe798 -- extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts extensions/drm-copilot/src/lib/pr-context/autoclose.ts extensions/drm-copilot/src/lib/pr-context/collector-core.ts`
3. `DA:` lookup for each added line in `extensions/drm-copilot/coverage/lcov.info` under the matching `SF:` record (session scratch helper reading the lcov file).

EXIT_CODE:
1. 0
2. 0
3. 0

Output Summary:
- Totals, baseline ([P0-T14]) -> final ([P7-T5]): Lines 96.88% (48372/49925) -> 96.89% (48510/50063); Branches 90.76% (6941/7647) -> 90.79% (6970/7677). No total decreased.
- Per-file rows, baseline -> final (% Lines / % Branch):
  - `pr-context-service-call.ts`: 100 / 93.33 -> 100 / 93.75
  - `collector-core.ts`: 97.97 / 91.22 -> 97.97 / 89.28 (file not edited; see note)
  - `render-pr-helpers.ts`: 87.52 / 93.75 -> 87.52 / 93.75 (not edited)
  - `autoclose.ts` (TS_BUILDER_FILE): 98.65 / 95.55 -> 98.68 / 95.74
  - `executable-resolver.ts` (new code): 100 / 100 (>= 85% lines, >= 75% branches)
- Note on `collector-core.ts`: the file has no diff. Its branch percentage fell because every in-repo caller now supplies `whichGh` (the service call forwards `input.whichGh ?? defaultWhichGh`), so the `whichGh === undefined` arm of the existing conditional spread in `collectPrContext` is no longer exercised. The file remains above the 75% branch floor and its per-file threshold passes.
- Diff hunks appear only in `autoclose.ts` (TS_BUILDER_STATE PARAM-ONLY) and `pr-context-service-call.ts` (always). No hunk in `collector-core.ts` (TS_CALLSITE PRESENT) or `render-pr-helpers.ts` (not the builder file).
- Added lines and hits (`SF:src\lib\pr-context\autoclose.ts`): `DA:236,1`, `DA:237,1`, `DA:277,68`, `DA:278,35`, `DA:279,35`, `DA:280,35`.
- Added lines and hits (`SF:src\lib\pr-context\pr-context-service-call.ts`): `DA:24,1`, `DA:30,1`, `DA:89,1`, `DA:90,1`, `DA:91,1`, `DA:92,1`, `DA:93,1`, `DA:94,1`, `DA:116,1`, `DA:117,1`, `DA:118,1`, `DA:119,1`, `DA:120,1`, `DA:152,33`.
- Every added line has a `DA:` entry with hits > 0; no added line lacks a `DA:` entry. Acceptance met.
