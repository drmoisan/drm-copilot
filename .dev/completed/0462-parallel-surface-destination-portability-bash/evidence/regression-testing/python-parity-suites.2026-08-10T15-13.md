# Python Parity Suites — Corpus Bound to the Python Authority

Timestamp: 2026-08-10T15-13

Task: [P2-T5]
Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py -q`
EXIT_CODE: 0

## Output Summary

- Result: **109 passed, 5 skipped**, 0 failed, in 0.19s.
- Cohort suite (`test_parallel_cohort_bash_parity.py`): 31 tests — 1 corpus-floor
  assertion plus 30 parametrized fixture cases. Corpus size 30, declared floor 20.
- Manifest suite (`test_parallel_manifest_bash_parity.py`): 83 tests — 1 corpus-floor
  assertion, 41 parametrized validator cases, 41 parametrized accessor cases. Corpus
  size 41, declared floor 24.
- The 5 skips are the accessor cases for the five fixtures whose frontmatter never
  parses (`manifest_m1_missing_opening_fence`, `manifest_m1_unterminated_fence`,
  `manifest_m1_non_mapping_frontmatter`, `manifest_m1_empty_frontmatter`,
  `manifest_m1_yaml_parse_failure`). Those fixtures declare no accessor expectation
  because there is no mapping to hand the accessors; their validator cases run and pass.
- Zero fixture defects were found: every hand-authored expectation matched the Python
  reference implementation on the first run, so no expectation was adjusted to fit
  observed output.

## Supporting toolchain checks on the two new files

- `poetry run black <both files>` — EXIT_CODE 0, "2 files left unchanged".
- `poetry run ruff check <both files>` — EXIT_CODE 0, "All checks passed!".
- `poetry run pyright <both files>` — EXIT_CODE 0, "0 errors, 0 warnings, 0 informations".

## Significance

This task binds both shared corpora to the Python authority before any bash code
exists. From this point the corpora are the fixed contract: the bash lane
([P3-T14], [P3-T15]) must reproduce these same expectations, and neither lane may
relax an expectation without the other observing the change.

The expectations were authored by hand from the reference modules' documented
message templates, not generated from the implementations, so the corpus is an
independent pin rather than a snapshot of current behavior.
