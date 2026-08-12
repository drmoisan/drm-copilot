# P6-T32 Python Test and Coverage Receipt

Timestamp: `2026-08-10T20-25`

Command: `poetry run pytest -o addopts='' --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/commit-steward-python-coverage.2026-08-10T20-25.json`

EXIT_CODE: `0`

Output Summary: Pytest collected `3,939` tests and completed with `3,934 passed`, `5 skipped`, and `0 failed` in `16.22s`. Coverage JSON SHA-256 is `3B191B5C8B1F2508CB1D6898501A6CB27F7372942A197B692DE8E43EBA2005EF`.

## Numeric Coverage

- Repository lines: `14,290 / 15,505` (`92.1638%`), above the `85%` floor and one covered line above P6-T19's `14,289 / 15,505` (`92.16%`).
- Repository branches: `4,866 / 5,776` (`84.2452%`), above the `75%` floor and one covered branch above P6-T19's `4,865 / 5,776` (`84.23%`).
- `resolve_codex_deployment.py`: lines `89 / 90` (`98.8889%`); branches `21 / 22` (`95.4545%`).
- `generate_codex_agent_variants.py`: lines `116 / 128` (`90.6250%`); branches `38 / 46` (`82.6087%`).
- Verification-only publisher owners remain at lines `101 / 103` (`98.0583%`) and `98 / 99` (`98.9899%`).
- The two correction additions are constant tuple members and add `0` executable coverage lines; both containing production owners exceed the required `90%` line floor. No changed executable line regressed.

## Repository Invariants

- All eleven correction-scoped Python production/test owners remain at or below `416` lines; the `500`-line limit has `0` violations.
- New suppression findings: `0`; temporary-file API/pattern findings: `0`.
- Dependency/lockfile status entries: `0`.
- `.claude/` status entries: `0`; `.codex/state` is absent.
- `git diff --check`: exit `0`.

Result: `PASS`.
