# TypeScript Coverage Comparison and Changed-Line Coverage — [P9-T6]

Timestamp: 2026-09-26T20-26
Loop iteration: 1
Command: git diff -U0 ae8d2ce32c95cf03d55ffb544f2514d83ebfc620 -- extensions/drm-copilot/src/lib/pr-context/models.ts extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts extensions/drm-copilot/src/lib/pr-context/collector-core.ts
EXIT_CODE: 0
Output Summary:
Scope anchor: ae8d2ce32c95cf03d55ffb544f2514d83ebfc620 ([P0-T5]). Baseline from [P0-T24]; final from [P9-T5]. The diff printed 31 hunks.

Totals (text-summary), baseline -> final:
- Lines: 96.85% (48119/49681) -> 96.88% (48311/49866) (no decrease)
- Branches: 90.55% (6884/7602) -> 90.68% (6928/7640) (no decrease)

Per-file rows (% Lines, % Branch), baseline -> final:
- models.ts: 100 -> 100; 100 -> 100 (no decrease)
- feature-docs-parsers.ts: 96.89 -> 96.9; 88.52 -> 88.7 (no decrease)
- render-feature-excerpts.ts: 95.08 -> 96.68; 84.26 -> 87.09 (no decrease)
- render-pr-helpers.ts: 88.77 -> 87.52; 93.02 -> 93.75. Relocation: buildCloseCandidatesSection and buildIssuesToAutocloseSection moved to autoclose.ts (spec D7) and are re-exported, which removed covered lines from this file's denominator. Final values meet the floors (87.52 >= 85 % Lines; 93.75 >= 75 % Branch).
- collector-core.ts: 97.89 -> 97.97; 89.85 -> 91.22. Relocation: classifyReferences, classifyOne, and formatRef moved to autoclose.ts. Final values meet the floors (97.97 >= 85; 91.22 >= 75).
- New code, autoclose.ts: 98.65 % Lines, 95.55 % Branch (floors 85 / 75 met).

Added lines (+ side of every hunk) with their `DA:<line>,<hits>` entry under the matching `SF:` record of extensions/drm-copilot/coverage/lcov.info:
  - collector-core.ts: DA:33,1, DA:34,1, DA:35,1, DA:36,1, DA:110,1, DA:111,1, DA:112,1, DA:113,1, DA:114,1, DA:203,47, DA:204,47, DA:205,47, DA:206,47, DA:238,47, DA:239,47, DA:242,47, DA:244,47, DA:245,47, DA:251,47, DA:255,15, DA:256,15, DA:258,17, DA:259,17, DA:260,17, DA:261,17
  - feature-docs-parsers.ts: DA:18,1, DA:70,1, DA:72,1, DA:73,1, DA:74,1, DA:83,142
  - models.ts: DA:19,1, DA:20,1, DA:48,1 through DA:70,1 (each of lines 48-70 has hits 1)
  - render-feature-excerpts.ts: DA:21,1, DA:63,1, DA:65,1, DA:66,1, DA:67,1, DA:76,22, DA:79,22
  - render-pr-helpers.ts: DA:9,1, DA:15,1, DA:16,1, DA:21,1, DA:157,1, DA:159,1, DA:160,1, DA:161,1, DA:170,90, DA:173,90, DA:310,1, DA:311,1, DA:312,1, DA:313,1, DA:314,1, DA:315,1
Result: 79 added lines have a DA entry; all 79 have hits > 0 (zero with hits 0). Totals did not decrease; no per-file percentage decreased for a file that received no relocated-out code. PASS.
