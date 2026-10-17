# Final QC: TypeScript coverage comparison ([P11-T6])

Timestamp: 2026-10-09T21-59
Loop-Iteration: 1
Command: git diff --name-status 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a -- extensions/drm-copilot/src
EXIT_CODE: 0
Output Summary: the anchored diff over extensions/drm-copilot/src printed nothing: no production TypeScript file changed. Post-Lines 97.16 >= Baseline-Lines 97.16; Post-Branches 91.71 >= Baseline-Branches 91.7; both above 85 / 75. PASS. Merge-base 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a is used in place of e7d3779b398604af919678c16c877c8539a86cc0 per the recorded-value substitution rule.

| Metric | Baseline ([P0-T22]) | Post-change ([P11-T5]) |
| --- | --- | --- |
| Lines | 97.16 (51037/52524) | 97.16 (51037/52524) |
| Branches | 91.7 (7521/8201) | 91.71 (7524/8204) |
| Test suites | 257 | 258 |
| Tests | 3925 | 3925 |

- Changed-code coverage: not applicable. No production TypeScript file changed; the changes are a split of test/subagent-tree-command.test.ts into two suites plus a test-support module.
- `collectCoverageFrom` in extensions/drm-copilot/jest.config.cjs is `["src/**/*.ts", "!src/**/*.d.ts"]`, so the new test-support module under test/ is outside the coverage population and needs no threshold entry.
- Observation: the branch denominator changed from 8201 to 8204 (covered 7521 to 7524) although no file under src/ changed relative to the merge-base. The cause was not investigated; the line totals are identical.
