# Phase gate P2

Timestamp: 2026-11-15T00-36
Command: stages 1 to 6 over the repository: Black check, Ruff check, and Pyright over the whole tree; formatter check and PSScriptAnalyzer over scripts/ci, tests/scripts/ci, and tests/scripts/workflows; actionlint 1.7.12 over _poshqc.yml and _quality-checks.yml; launcher pester suite (one Invoke-PoshQCParallelTest run, 8 workers); launcher pytest suite (one pytest -n auto run)
EXIT_CODE: 0
Output Summary: Black: 1070 files unchanged. Ruff: all checks passed. Pyright: 0 errors, 0 warnings. Formatter: 24 files, 0 would change. PSScriptAnalyzer: 24 files, 0 findings. actionlint: no output, exit 0. Pester gate: tests=26885, failures=0, errors=0, disabled=22. pytest gate: 16949 passed, 6 skipped, 0 failed (baseline 16941 passed, 6 skipped; the 8 added tests are the new workflow contract tests). Architecture-boundary and contract stages are part of the same suites.
