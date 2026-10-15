# Fail-Before Exception: #846 CR-1 (P4-T19)

Timestamp: 2026-10-13T11-27

WhyFailingRunImpossible: CR-1 characterizes production text that is already correct. `scripts/dev_tools/check_quality_tiers.py:185` already renders `cannot list tracked files: ` before the git exit detail, so for an empty or whitespace-only stderr the emitted line is already `QT009: cannot list tracked files: git ls-files exited with code 128`. Tightening the assertion from a prefix check to that exact line cannot fail before the change. The literal used is the research-corrected form; the review literal omitted the `cannot list tracked files: ` prefix.

## Alternative proof

P4-T18 (`evidence/regression-testing/p8-846-cr1-after.2026-10-13T11-27.md`): `test_main_returns_one_with_qt009_when_git_exits_nonzero[empty-stderr]` and `[whitespace-only-stderr]` both PASSED (17 passed, EXIT_CODE 0) with no production change.
