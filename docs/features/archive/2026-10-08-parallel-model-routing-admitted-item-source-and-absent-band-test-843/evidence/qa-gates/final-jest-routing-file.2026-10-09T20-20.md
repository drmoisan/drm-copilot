# Final jest routing file, loop pass 3 (P2-T12)

Timestamp: 2026-10-09T20-20
Command: npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/parallel-planner-state-routing.test.ts --verbose
EXIT_CODE: 0
Output Summary:
Test Suites: 1 passed, 1 total
Tests:       24 passed, 24 total
BaselineJestRoutingCount (P0-T24): 22; passed count 24 equals 22 plus 2; no failed count.

CommandSubstitution: none for the planned command. As recorded in P1-T20, the planned command prints only summary lines in this environment (also true of the P0-T24 baseline), so the title lines were read from a supplementary run with an added flag:
SupplementaryCommand: npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/parallel-planner-state-routing.test.ts --verbose --reporters=default
SupplementaryEXIT_CODE: 0
Title lines (passing):
    √ reports checks 1, 5, and 9 with None when only the item band is absent
    √ reports checks 7 and 9 with None when only the receipt band is absent
Supplementary Tests line: Tests:       24 passed, 24 total
