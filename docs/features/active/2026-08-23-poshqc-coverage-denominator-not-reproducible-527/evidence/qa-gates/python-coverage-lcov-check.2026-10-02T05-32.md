# Python Coverage LCOV Cross-Check (issue #527)

Timestamp: 2026-10-02T05-32
Command: Grep tool in count mode against <ROOT>/artifacts/python/lcov.info for `^BRDA:`, `^BRDA:.*,1\s*$`, and `^BRDA:.*,(0|-)\s*$`
EXIT_CODE: 0
Output Summary: LCOV BRDA total 6230 equals num_branches 6230; covered BRDA 5406 equals covered_branches 5406; uncovered BRDA 824 plus covered 5406 equals the 6230 total. The LCOV artifact exists and carries branch records.

## Counts

- `^BRDA:` (all branch records): 6230
- `^BRDA:.*,1\s*$` (covered, hit value 1): 5406
- `^BRDA:.*,(0|-)\s*$` (uncovered, hit value 0 or -): 824

## Comparisons

- All BRDA count 6230 vs num_branches 6230 (P1-T4): EQUAL
- Covered BRDA count 5406 vs covered_branches 5406 (P1-T4): EQUAL
- Covered 5406 + uncovered 824 = 6230 vs total BRDA count 6230: EQUAL
