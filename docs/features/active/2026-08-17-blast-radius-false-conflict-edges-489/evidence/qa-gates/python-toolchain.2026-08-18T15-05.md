# Python Final QA Gates (Issue #489)

Timestamp: 2026-08-18T15-05

Loop note: the first pass of this loop was restarted once. `poetry run pyright`
reported 32 errors in `tests/scripts/dev_tools/test_blast_radius_mandate_reads.py`
(a test helper declared `-> object`, so every attribute access on the returned
radius was unresolvable). The helper's return annotation was corrected to
`BlastRadius` and the loop was restarted from formatting. The figures below are
the final clean pass.

## P8-T1 Formatting

Timestamp: 2026-08-18T15-05
Command: `poetry run black .`
EXIT_CODE: 0
Output Summary: All done. 425 files left unchanged; no file reformatted on the
final pass. Re-verified with `poetry run black --check .`, which reports
"425 files would be left unchanged".

## P8-T2 Linting

Timestamp: 2026-08-18T15-05
Command: `poetry run ruff check .`
EXIT_CODE: 0
Output Summary: All checks passed. Zero findings. No suppression (`# noqa`) was
added anywhere on this branch.

## P8-T3 Type Checking

Timestamp: 2026-08-18T15-05
Command: `poetry run pyright`
EXIT_CODE: 0
Output Summary: 0 errors, 0 warnings, 0 informations. No `# type: ignore` was
added anywhere on this branch.

## P8-T4 Full Test Suite With Coverage

Timestamp: 2026-08-18T15-05
Command: `poetry run pytest --cov --cov-branch`
EXIT_CODE: 0
Output Summary: 3938 passed, 5 skipped in 19.00s (baseline: 3888 passed,
5 skipped; the 50 additional tests are this feature's new cases). The 5 skips
are the pre-existing `test_parallel_manifest_bash_parity.py` accessor-expectation
skips, unchanged from baseline.

Numeric coverage headline, computed on the same formula the Phase 0 baseline
artifact used (`covered/total` for statements; `(num_branches - partial)/num_branches`
for branches):

- line 92.43% (13527/14635) — baseline 92.40% (13479/14587)
- branch 89.63% (4815/5372) — baseline 89.60% (4801/5358)

Both are above the uniform thresholds (line >= 85%, branch >= 75%) and neither
regressed. For completeness, coverage.py's stricter `covered_branches/num_branches`
figure is 84.90% (4561/5372), also above the 75% threshold; the baseline artifact
did not record that variant, so it is reported for information only and is not
used for the delta.

## P8-T5 Changed-Module Coverage

Timestamp: 2026-08-18T15-05
Command: `poetry run pytest tests/scripts/dev_tools/ --cov=scripts.dev_tools._blast_radius_extraction --cov=scripts.dev_tools._blast_radius_validation --cov=scripts.dev_tools._blast_radius_guards --cov=scripts.dev_tools._blast_radius_normalization --cov=scripts.dev_tools.compute_blast_radius --cov-branch --cov-report=term-missing`
EXIT_CODE: 0
Output Summary: 3850 passed, 5 skipped in 10.17s. Per-module figures:

| Module | Stmts | Miss | Branch | BrPart | Line | Branch |
| --- | --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_extraction.py` | 108 | 0 | 48 | 0 | 100% | 100% |
| `scripts/dev_tools/_blast_radius_guards.py` | 19 | 0 | 10 | 0 | 100% | 100% |
| `scripts/dev_tools/_blast_radius_normalization.py` | 13 | 0 | 6 | 0 | 100% | 100% |
| `scripts/dev_tools/_blast_radius_validation.py` | 101 | 0 | 32 | 0 | 100% | 100% |
| `scripts/dev_tools/compute_blast_radius.py` | 71 | 0 | 10 | 0 | 100% | 100% |
| TOTAL | 312 | 0 | 106 | 0 | 100% | 100% |

All five changed modules report line 100% and branch 100%, well above the
line >= 85% / branch >= 75% gate (AC-H2 Python half).

Command-form note: the dotted-module `--cov=` form is used because
`--cov=<path>` and `--cov=<path>.py` collect no data on this host.
