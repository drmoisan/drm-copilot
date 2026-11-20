# Jest Extension Gate [P2-T6] — remediation cycle 1

Timestamp: 2026-11-20T20-13
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage --coverageReporters=lcov --coverageReporters=text-summary (through sh SCRATCH/issue-1016-g-jest.sh, final QA loop pass 2, head 520617870; normal workers; thresholds of extensions/drm-copilot/jest.config.cjs with jest.development-docs-migration-coverage.json)
EXIT_CODE: 0
Output Summary: Test Suites: 412 passed, 412 total; Tests: 6707 passed, 6707 total; 0 failed. No coverage threshold failure was reported (per-file thresholds pass). Totals: lines 97.59% (74531/76371), branches 94.96% (11909/12541); Phase 0 baseline lines 97.58% (74504/76344), branches 94.95% (11903/12536).

| File | Phase 0 lines | Final lines | Phase 0 branches | Final branches | Result |
| --- | --- | --- | --- | --- | --- |
| `extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts` | 156/156 (100.00%) | 181/181 (100.00%) | 21/21 (100.00%) | 27/27 (100.00%) | PASS |
| `extensions/drm-copilot/src/lib/development-docs-migration/migration-plan.ts` | 587/587 (100.00%) | 589/589 (100.00%) | 145/148 (97.97%) | 145/147 (98.64%) | PASS |

Changed-line coverage (node SCRATCH/issue-1016-c1changed.cjs SCRATCH/c1f2.lcov.info f744ce9e0): `layout-map.ts` 25 added lines, 25 covered, 6 branches taken of 6 (the new `isMappedTargetPath`); `migration-plan.ts` 3 added lines, 3 covered, 5 branches taken of 5 (the changed `scanRewrites` condition and its import). Both files meet the 85% line and 75% branch thresholds and are not below their Phase 0 figures.

Loop note: in the [P1-T8] run, `migration-plan.ts` measured 144/147 branches (97.96%), because the F1 change lowered the v8 branch denominator from 148 to 147 with the same three branches untaken. The final-loop fix (commit 520617870) adds the case "names no open choice when only held items require the decision file" to `migration-plan.test.ts`, which takes the reachable `open choices: none` branch.
