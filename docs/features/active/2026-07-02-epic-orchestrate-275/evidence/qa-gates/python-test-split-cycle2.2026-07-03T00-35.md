# Python Test-File Split — Cycle 2 Consolidated Result

Timestamp: 2026-07-03T00-35

## Line-Count Result ([P1-T3])

- Command: `(Get-Content tests/scripts/dev_tools/test_validate_orchestration_artifacts.py | Measure-Object -Line).Lines`
- EXIT_CODE: 0
- Output Summary: Literal command returned `320`; cross-checked true value (via
  `Get-Content .Count` / `wc -l`) is **381**, well under the 500-line cap. Branch taken:
  **Primary branch (target achieved)**. See
  `evidence/qa-gates/python-linecount-result.2026-07-03T00-30.md`.

## Sibling Dispatch File Unmodified ([P1-T4])

- Command: `git diff --stat -- tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py`
- EXIT_CODE: 0
- Output Summary: Empty output — the cycle-1 sibling split file was not touched by this
  cycle's extraction.

## Full dev_tools Test-Suite Pass-Count Comparison ([P1-T5])

- Command: `poetry run pytest tests/scripts/dev_tools -q`
- EXIT_CODE: 0
- Output Summary: 1192 passed, 19 skipped, 0 failed — identical to the P0-T7 baseline
  (1192 passed, 19 skipped, 0 failed). Net-zero change confirmed.

## Toolchain Stage 1 — Format ([P2-T1])

- Command: `poetry run black --check scripts/dev_tools tests/scripts/dev_tools`
- EXIT_CODE: 0
- Output Summary: `211 files would be left unchanged.` Zero reformatting required.

## Toolchain Stage 2 — Lint ([P2-T2])

- Command: `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`
- EXIT_CODE: 0
- Output Summary: `All checks passed!` Zero lint violations.

## Toolchain Stage 3 — Type-Check ([P2-T3])

- Command: `poetry run pyright scripts/dev_tools tests/scripts/dev_tools`
- EXIT_CODE: 0
- Output Summary: `0 errors, 0 warnings, 0 informations`.

## Toolchain Stage 4 — Test with Coverage ([P2-T4])

- Command: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools`
- EXIT_CODE: 0
- Output Summary: 1192 passed, 19 skipped, 0 failed. Coverage `TOTAL`:
  `Stmts=9032, Miss=1242, Branch=3250, BrPart=447, Cover=83%` — identical to the P0-T7
  baseline (`Cover=83%`). No coverage regression.

## Overall Outcome

Single fix (test-file relocation) completed successfully. Post-fix line count of
`tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` is 381 (from a 513-line
baseline). All four Python toolchain stages pass with 0 errors/violations in a single pass.
No test was weakened, removed, or skipped; no production code or test assertion was changed.
