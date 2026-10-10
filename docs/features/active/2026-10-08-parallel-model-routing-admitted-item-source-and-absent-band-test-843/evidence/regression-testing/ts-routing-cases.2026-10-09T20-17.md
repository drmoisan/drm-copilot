# TypeScript routing cases (P1-T20)

Timestamp: 2026-10-09T20-17
Command: npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/parallel-planner-state-routing.test.ts --verbose
EXIT_CODE: 0
Output Summary:
Tests:       24 passed, 24 total
BaselineJestRoutingCount (P0-T24): 22; passed count 24 equals 22 plus 2.

CommandSubstitution: none for the planned command. Observation: the planned command, as in the P0-T24 baseline, prints only the summary lines in this environment and no per-test title lines, so the plan's title-line acceptance literal cannot be read from it. A supplementary run of the same file with the same flags plus `--reporters=default` was made to read the titles:
SupplementaryCommand: npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/parallel-planner-state-routing.test.ts --verbose --reporters=default
SupplementaryEXIT_CODE: 0
Title lines (passing):
    √ reports checks 1, 5, and 9 with None when only the item band is absent
    √ reports checks 7 and 9 with None when only the receipt band is absent
Supplementary Tests line: Tests:       24 passed, 24 total
