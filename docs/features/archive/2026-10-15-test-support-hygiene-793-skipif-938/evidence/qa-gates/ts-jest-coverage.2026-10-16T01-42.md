Timestamp: 2026-10-16T01-42
Command: npm --prefix extensions/drm-copilot run test:coverage
WorkingDirectory: extensions/drm-copilot (effective: npm --prefix runs the script, node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary, in that directory)
EXIT_CODE: 0
Note: DEVIATION. The plan literal `npx jest --config jest.config.cjs --coverage` requires the tool working directory to be extensions/drm-copilot, which the Bash tool cannot set without a chained cd (disallowed). A first attempt from the worktree root ran the root Jest project (273 suites, 4019 tests, table reporter, lines 97.85 / branches 92) and a second attempt with --rootDir produced exit 1 ("Coverage data not found" lines) with 270 suites; neither is used as evidence. The package script `test:coverage` runs the same Jest project (jest.config.cjs of the extension, reporters lcov + text-summary) with the extension as working directory.
Output Summary:
Test Suites: 270 passed, 270 total
Tests:       4002 passed, 4002 total
Coverage summary:
Statements   : 97.26% ( 51159/52596 )
Branches     : 92.28% ( 7561/8193 )
Functions    : 91.63% ( 1523/1662 )
Lines        : 97.26% ( 51159/52596 )
"does not meet" lines: none
LineCoveragePercent: 97.26
BranchCoveragePercent: 92.28
LineThreshold: 85
BranchThreshold: 75
ThresholdVerdict: MET
Command2: git status --porcelain --untracked-files=all -- extensions/drm-copilot/coverage
EXIT_CODE2: 0
Output Summary2: (empty)
