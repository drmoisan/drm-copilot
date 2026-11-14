# pytest gate — feature-review R4 (cycle 2) coverage re-measure at the merged head

Timestamp: 2026-11-14T09-23
Command: sh SCRATCH/r5-1159-pytest.sh (from the item worktree root: env -u VIRTUAL_ENV poetry run pytest -n auto -p no:cacheprovider --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:SCRATCH/r5-1159-pytest.json -rfE -q), started 2026-11-14T09:18:40Z, ended 2026-11-14T09:23:49Z, at head 5a58ecdc239fce59d73db7194cfaa371f3df355a
EXIT_CODE: 0
Output Summary: Run by the feature-review agent after the main-sync merge. 16730 passed, 6 skipped, 0 failed in 298.85 s (pytest-xdist). Repo-wide line coverage 97.13% (34574/35595), branch coverage 94.42% (12785/13540), read from the JSON report. artifacts/python/lcov.info written by this run. The 7 additional tests against pytest.2026-11-14T09-07.md arrived with the #1156 merge.
