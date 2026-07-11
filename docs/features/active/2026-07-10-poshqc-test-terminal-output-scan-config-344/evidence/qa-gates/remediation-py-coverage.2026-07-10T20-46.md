# Python Test Coverage — R3 (Remediation Cycle 1)

- Issue: #344
- Timestamp: 2026-07-10T20-46
- Command: `poetry run pytest --cov --cov-report=lcov:artifacts/python/lcov.info`
- EXIT_CODE: 0

## Output Summary

- Test result: `1309 passed in 6.64s`. 0 failures. This suite includes the eight-pair parity test (`tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources`), which passed.
- `Coverage LCOV written to file artifacts/python/lcov.info`. The artifact `artifacts/python/lcov.info` now exists (`Test-Path` = True), resolving R3 (previously absent).
- Repo-wide Python coverage (aggregated from lcov `LF:`/`LH:` records):
  - Lines: 8073/9320 = **86.62%** (>= 85% threshold: PASS).
  - Branches: not emitted. The lcov contains no `BRF:`/`BRH:`/`BRDA:` records (BRF total = 0, BRDA lines = 0). Branch measurement is not enabled in the repo coverage configuration for this command (`--cov-branch` is not applied); branch percentage is therefore not measured for this artifact.
- No-regression note: this branch changes no Python production code (only the test file `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` was modified on the branch), so changed-line coverage regression is structurally impossible per the remediation-inputs R3 expected behavior. The repo-wide line figure of 86.62% is above the 85% threshold.
