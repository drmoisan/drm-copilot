# Phase 0 disposition tests

Timestamp: 2026-11-07T21-10
Command: (1) Pytest: the two disposition files read from the JUnit report of the Phase 0 parallel pytest run (poetry run pytest -n auto --cov --cov-branch ... --junitxml=SCRATCH/issue-1038-pytest-baseline-junit.xml), classname filter test_new_active_feature_folder_part2 and test_discovery_documentation_contracts. (2) Jest: extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts `for epic copies only epic.md and epic-status.md, never initiative.md` — not run locally; covered by CI `drm-copilot-extension-tests` (pending-CI).
EXIT_CODE: 0
Output Summary: tests/scripts/dev_tools/test_new_active_feature_folder_part2.py: 14 passed, 0 failed, 0 skipped. tests/scripts/dev_tools/test_discovery_documentation_contracts.py: 32 passed, 0 failed, 0 skipped. Jest io.test.ts: pending-CI (drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) and (windows-latest)).

Owner-directive substitution (owner directive 2026-11-07, decision 1): [P0-T12] names a single-file Jest run and a Pytest run on the two files. Per the directive, the two Pytest files' results are read from the parallel pytest run, and the single Jest test is recorded as covered by CI `drm-copilot-extension-tests` (pending-CI) because this child changes no TypeScript.
