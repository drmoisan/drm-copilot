# pytest Gate Baseline (Phase 0, issue #1231)

Timestamp: 2026-11-23T23-56
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch --cov-report=json:artifacts/python/coverage-1231-p0.json --junitxml=artifacts/python/junit-1231-p0.xml -q (one pytest -n auto run through the launcher; integration and golden lanes excluded)
EXIT_CODE: 0
Output Summary:
- 17104 passed, 6 skipped, 0 failed in 189.23s.
- Failing tests: none.
- Repo-wide coverage (artifacts/python/coverage-1231-p0.json totals): lines 35372 of 36090 statements covered (98.01%); branches 13100 of 13722 covered (95.47%); combined percent_covered_display 97.
- No Python production file is in scope for issue #1231, so no per-file Python threshold applies.
- Note: before this run started, the four new #1231 hook files had been written under .claude/hooks together with their bundle copies and core.json entries, so the push-down resource and manifest contract tests read a consistent tree. No existing production file had been edited.
