# Python Coverage Consolidated Result (PA-B1, issue #527)

Timestamp: 2026-10-02T05-34
Command:
- Run A: poetry -C <ROOT> run pytest --cov --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info
- Run B: poetry -C <ROOT> run pytest --cov --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info
EXIT_CODE: Run A 0; Run B 0
Output Summary: Python line coverage is 93.53% (16129 of 17244 statements) and Python branch coverage is 86.77% (5406 of 6230 branches), measured over the sources `src` and `scripts/dev_tools` (pyproject.toml line 120). Both thresholds pass: line >= 85% and branch >= 75%. 6377 passed, 6 skipped in both runs.

Line Coverage: 93.53%
Branch Coverage: 86.77%
Branch Source: The configured Run A prints no branch columns (statement coverage only). Branch was measured by Run B with the `--cov-branch` command-line flag. The figure is read from the `coverage json` totals (python-coverage-totals.2026-10-02T05-31.md) and cross-checked against the LCOV `BRDA` counts (python-coverage-lcov-check.2026-10-02T05-32.md): 6230 total and 5406 covered, both EQUAL to the json totals.
Line Threshold (85%): PASS
Branch Threshold (75%): PASS

No Python production file changed on the branch, so no changed-line coverage regression is possible.

## Changed Python Files

Copied from python-changed-files.2026-10-02T05-33.md.

`git diff --name-only origin/main...HEAD -- '*.py'`:
```
tests/scripts/dev_tools/test_poshqc_bundled_parity.py
```

`git status --porcelain -- '*.py'`:
```
(no output)
```

## Python Coverage Artifact

- Glob for `artifacts/python/lcov.info` under <ROOT>: returned `artifacts/python/lcov.info` (file exists).
- Grep count for the literal `SF:` in that file: 210 (greater than zero).
- The file is git-ignored (`/artifacts`) and is not staged in Phase 2.
