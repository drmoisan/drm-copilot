# Fail-Before F1 [P1-T1] — remediation cycle 1

Timestamp: 2026-11-20T19-17
Command: sh <worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension "--testPathPatterns=development-docs-migration/(migration-apply|migration-plan)\.test\.ts"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Test Suites: 2 failed, 2 total; Tests: 2 failed, 30 passed, 32 total. The two failing cases are exactly the [P1-T1] cases, before the [P1-T2] fix:
- `applyMigrationPlan > yields an empty plan on a second links-only apply when a moved record keeps an old prefix` (second.rewrites holds `.dev/active/1016-foo/notes.md`, because `scanRewrites` treats the moved record as outside the moved trees).
- `buildMigrationPlan behavior > classifies a record at a mapped target as in-tree on a post-move dry run` (inTreeReferencesAndLinks is empty; the record is listed under outsideRewrites).
Every other case of the two files passes.
