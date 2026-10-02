# Coverage delta (#647, AC-11)

Timestamp: 2026-10-01T23-18
Command: compare evidence/baseline/coverage.2026-10-01T23-18.md with evidence/qa-gates/final-coverage.2026-10-01T23-18.md ; read DA records from extensions/drm-copilot/coverage/lcov.info for the SF records ending in codex-native-converter/index.ts and codex-native-converter/models.ts
EXIT_CODE: 0

| Metric | Baseline | Final | Delta |
|---|---|---|---|
| Lines | 97.07% (50618/52144) | 97.07% (50618/52144) | 0.00 |
| Branches | 91.35% (7391/8090) | 91.35% (7391/8090) | 0.00 |

LINES_BASE_PCT: 97.07, LINES_FINAL_PCT: 97.07
BRANCHES_BASE_PCT: 91.35, BRANCHES_FINAL_PCT: 91.35

Changed-code coverage (production lines changed in this branch):
- src/lib/codex-native-converter/index.ts: DA:18,1  DA:21,1  DA:23,1  DA:32,1
- src/lib/codex-native-converter/models.ts: DA:25,1  DA:26,1  DA:28,1  DA:30,1  DA:32,1
- Result: 9 covered / 9 lines with a DA record (100%).

Note: the Functions denominator fell from 1672 to 1663, consistent with the `type` modifiers removing value re-exports of the nine type-only names from the transpiled modules; Lines and Branches are unchanged.

Output Summary: LINES_FINAL_PCT >= LINES_BASE_PCT and BRANCHES_FINAL_PCT >= BRANCHES_BASE_PCT; every changed line with a DA record has a hit count > 0.
