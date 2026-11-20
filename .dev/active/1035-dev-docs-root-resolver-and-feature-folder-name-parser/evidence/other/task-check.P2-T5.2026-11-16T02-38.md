# Task Check P2-T5

Timestamp: 2026-11-16T02-38
Command: sh SCRATCH/issue-1035-tscheck.sh (npx prettier --write src/lib/resolve/file-prompt-variables.ts test/lib/resolve/file-prompt-variables.test.ts; npx eslint <same>; npx tsc -p ./ --noEmit and tsconfig.jest.json; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension test/lib/resolve)
EXIT_CODE: 0
Output Summary: Changed files: extensions/drm-copilot/src/lib/resolve/file-prompt-variables.ts (resolveNameFromFeatureFoldername delegates to parseFeatureFolderName per D-P14: issue-first and date-first-with-issue names yield the feature, every other name is returned whole; the now-unused isAllDigits helper removed), test/lib/resolve/file-prompt-variables.test.ts (existing dated, feature-123 and versioned cases unchanged; new issue-first case 1016-foo-bar -> foo-bar and a date-first-without-issue case). Selection rule: the mirrored test file plus test/lib/resolve (file-prompt-core.ts and file-prompt-transforms.ts import the module). Prettier exit 0, ESLint exit 0, tsc exit 0, Jest 5 suites 62 tests passed (one queue timeout on the machine lock before the run).
