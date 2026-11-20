# Kickoff-Contract Test Run — [P2-T9]

Timestamp: 2026-08-08T14-20

The [P2-T8] conditional split fired, so `tests/scripts/dev_tools/test_parallel_kickoff_contract_tables.py`
is appended to the pytest invocation as [P2-T9] directs, and both test modules
are collected in one run. The [P2-T6] split also produced the production helper
module `scripts/dev_tools/_parallel_kickoff_tables.py`, whose coverage is
recorded alongside the contract module and meets the same thresholds.

## Command (as planned)

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_kickoff_contract.py tests/scripts/dev_tools/test_parallel_kickoff_contract_tables.py -v --cov=scripts/dev_tools/parallel_kickoff_contract --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Output Summary: 49 passed, 0 failed. The tests executed and the command
succeeded, but coverage.py emitted `CoverageWarning: Module
scripts/dev_tools/parallel_kickoff_contract was never imported
(module-not-imported)` and reported no data. Cause: coverage.py resolves a
`--cov` value that contains path separators as a filesystem path and a value
without them as an importable module name; the slash-form spelling in the plan
text matches neither the installed package path nor an importable module, so no
measurement was collected. This is a spelling nuance of the coverage source
specification, not a test or module defect.

## Command (data-producing variant, same test set)

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_kickoff_contract.py tests/scripts/dev_tools/test_parallel_kickoff_contract_tables.py --cov=scripts.dev_tools.parallel_kickoff_contract --cov=scripts.dev_tools._parallel_kickoff_tables --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Output Summary: 49 passed, 0 failed. Coverage measured on both production
modules produced by Phase 2:

```
Name                                             Stmts   Miss Branch BrPart  Cover
scripts\dev_tools\_parallel_kickoff_tables.py       72      0     38      0   100%
scripts\dev_tools\parallel_kickoff_contract.py      91      0     26      0   100%
TOTAL                                              163      0     64      0   100%
```

Numeric coverage headline values:

| Module | Line coverage | Branch coverage | Line >= 85% | Branch >= 75% |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/parallel_kickoff_contract.py` | 100.00% (91/91 statements) | 100.00% (26/26 branches, 0 partial) | yes | yes |
| `scripts/dev_tools/_parallel_kickoff_tables.py` | 100.00% (72/72 statements) | 100.00% (38/38 branches, 0 partial) | yes | yes |
| Combined | 100.00% (163/163) | 100.00% (64/64) | yes | yes |

Every test passes and both modules exceed the uniform line (>= 85%) and branch
(>= 75%) thresholds in `.claude/rules/quality-tiers.md`.

## Deviation Recorded

The planned `--cov=scripts/dev_tools/parallel_kickoff_contract` spelling was
executed unchanged and exited 0, but collected no coverage data. To satisfy the
task's acceptance requirement for numeric module line and branch coverage
percentages, the identical test set was re-run with the dotted module spec
`--cov=scripts.dev_tools.parallel_kickoff_contract` (plus the helper module).
Both invocations are recorded above with their own `EXIT_CODE`. No test was
altered to produce this result.
