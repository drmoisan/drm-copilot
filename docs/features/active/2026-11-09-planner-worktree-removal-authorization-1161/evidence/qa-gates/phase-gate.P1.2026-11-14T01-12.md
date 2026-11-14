# Phase gate P1 (remediation cycle 1)

Timestamp: 2026-11-14T01-12
Command: bash SCRATCH/issue-1161-gate-static.sh; sh SCRATCH/issue-1161-pytest.sh p1gate; sh SCRATCH/issue-1161-jest.sh p1gate (in the item worktree; stages listed below)
EXIT_CODE: 0
Output Summary: One clean pass of stages 1 to 6 for Python and TypeScript with no restart: no step failed or changed a file (`git status --porcelain` identical before and after the static stages). pytest: 16722 passed, 6 skipped, 0 failed (one `pytest -n auto` run). Jest in `extensions/drm-copilot`: 342 suites, 5554 passed, 0 failed (normal workers). No `[expect-fail]` test remains failing.

| Stage | Command | EXIT_CODE | Result |
|---|---|---|---|
| 1. Format (Python) | `env -u VIRTUAL_ENV poetry run black --check .` | 0 | `1063 files would be left unchanged.` |
| 1. Format (TypeScript) | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` | 0 | `All matched files use Prettier code style!` |
| 2. Lint (Python) | `env -u VIRTUAL_ENV poetry run ruff check .` | 0 | `All checks passed!` |
| 2. Lint (TypeScript) | `npx eslint --no-error-on-unmatched-pattern src test` | 0 | 0 findings |
| 3. Type check (Python) | `env -u VIRTUAL_ENV poetry run pyright` | 0 | 0 errors, 0 warnings, 0 informations |
| 3. Type check (TypeScript) | `npx tsc -p ./ --noEmit`; `npx tsc -p tsconfig.jest.json --noEmit` | 0 | 0 errors each |
| 4. Architecture boundary | none: the repository has no `.dependency-cruiser.cjs` and no architecture-test project | N/A | not applicable |
| 5. Unit (Python) | `env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1161-pytest-p1gate.json --cov -q -rfE` | 0 | 16722 passed, 6 skipped, 0 failed in 240.59 s |
| 5. Unit (TypeScript) | `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` | 0 | 5554 passed, 0 failed |
| 6. Contract | `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`, plus the contract tests under `tests/scripts/dev_tools/` that run in the stage 5 pytest run | 0 | clean; 0 failures |

Test-count delta against the Phase 0 baseline: pytest 16714 to 16722 (+8: four new fixtures, each a row of the two parametrized corpus tests); Jest 5546 to 5554 (+8, the same rows).
