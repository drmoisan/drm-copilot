Timestamp: 2026-03-14T23-57
Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.test.ts test/extension.potential-to-issue.test.ts test/extension.new-active-feature-folder.test.ts --coverage --coverageReporters=text-summary
EXIT_CODE: 0
Output Summary:
Direct-mode Jest scenarios passed for `newPotentialEntry direct -ShortName invocation skips prompts`, `newPotentialEntry direct mode rejects missing -ShortName value`, `newPotentialEntry direct mode rejects duplicate -ShortName flag`, `newPotentialBugEntry direct --short-name invocation skips prompts`, `newPotentialBugEntry direct mode rejects invalid short-name pattern`, `potentialToIssue direct invocation skips active-editor and prompt UI`, `potentialToIssue direct mode rejects unknown flag`, `potentialToIssue direct mode rejects invalid work mode`, `newActiveFeatureFolder direct invocation forwards issue number without prompts`, `newActiveFeatureFolder direct invocation omits issue number without prompts`, `newActiveFeatureFolder direct mode rejects non-digit issue number`, and `newActiveFeatureFolder direct mode rejects invalid type`.
Coverage summary: Statements 77.38% (1016/1313), Branches 88.75% (142/160), Functions 75% (27/36), Lines 77.38% (1016/1313).
Test Suites: 3 passed, 3 total. Tests: 66 passed, 66 total.
