# Preflight Validation - Plan plan.2026-09-29T21-55.md (Issue #739)

Timestamp: 2026-09-29T22-40
Reviewer: atomic-executor (DIRECTIVE: PREFLIGHT VALIDATION ONLY)
Plan: docs/features/active/2026-09-27-npm-token-guard-gaps-739/plan.2026-09-29T21-55.md
Signal: PREFLIGHT: REVISIONS REQUIRED
Convergence: CONVERGENCE: NO FURTHER ROUNDS EXPECTED

## Defects

### D1 - P1-T4 mandates a docstring summary line that fails Ruff E501

- Location: P1-T4 (summary text "Return the line numbers of ``text`` that reference the ``NPM_TOKEN`` secret or variable.").
- Rule: `pyproject.toml` `[tool.ruff.lint] select` includes `E` (E501, line-length 88); P1-T14 and P2-T2 require `All checks passed!`.
- Observation: a prototype module written to the plan's instructions (scratchpad, not the repository) and checked with `poetry run ruff check --no-fix --config pyproject.toml --extend-ignore S101` reported `E501 Line too long (95 > 88)` on that summary line when written on one line at 4-space indentation. Black does not wrap docstrings. P1-T4 quotes the text with no wrap allowance, unlike P1-T2.
- Impact: P1-T14 and P2-T2 cannot pass while the summary is copied as a single line.

### D2 - The 500-line cap has a narrow margin and P1-T19 stops Phase 1 with no in-file remedy

- Location: P1-T19 (and P2-T14, AC11); Phase 1 constraints.
- Observation: the same prototype, which uses one-line docstrings for every added test and compact helper docstrings, measures 483 lines before Black and 487 lines after Black (`poetry run black --check --diff` added 4 lines). The prototype collects 52 nodes, matching P1-T17. Multi-line test docstrings in the style of the existing `test_find_npm_token_references_detects_reintroduced_reference` would add roughly 3-4 lines per test across 5 new tests, which reaches or exceeds 500.
- Impact: P1-T19 then stops Phase 1 after execution has begun, and the plan provides no in-file remedy.

## Validator warnings assessed (not defects)

- G4 (`--cov --cov-branch`, P0-T12, P2-T5): pytest-cov declares `--cov` with an optional value; argparse does not consume a following `--`-prefixed token, so `--cov` takes its value from `[tool.coverage.run] source = ["src", "scripts/dev_tools"]`. The identical command recorded `TOTAL ... 91%` and `5132 passed` in `docs/features/completed/unused-npm-token-secret-712/evidence/baseline/baseline-pytest-coverage.2026-09-27T09-14.md`. Both tasks also pass `--cov-report=term-missing` (G9 satisfied).
- G6 (`grep -c ""`, P0-T16, P1-T19, P2-T14): the empty pattern counts lines; observed output `263` on the current module, which matches P0-T16. The `< 500` conditions can fail.

## Verified (no defect)

- Structure: three phases, headings and task IDs sequential (P0-T1..T19, P1-T1..T22, P2-T1..T27); all evidence paths under `<FEATURE>/evidence/{baseline,regression-testing,other,qa-gates}/`; Phase 2 command tasks are unconditional; every write task names its file as the first backticked path; no task writes under `.github/`.
- Citations: module is 263 lines; docstring lines 1-18; baseline probe printed `True False False False True False False` (exit 0); replacement docstring probe printed `False True True True True True True`; targeted run printed `17 passed`; runbook counts: `features/active/unused-npm-token-secret-712` 1, `human-action-pending.2026-09-27T09-19.md` 0, `(spec decision D5)` 0, `Do not change acceptance criterion AC4` 0, `features/active` 1 and `issue.md` 1 (both on line 136 only); `### Recording completion` heading present; runbook has LF endings; pending record carries `Status: pending`; `spec.md` defines D5 and AC4; `scripts/dev_tools/check_python_coverage_thresholds.py` prints `line coverage <pct> is below the required floor <floor>.` / `branch coverage ...` to stderr and returns 1 on breach; `addopts` contains `-ra`; `artifacts/` is gitignored; `.claude/agents/python-typed-engineer.md` exists; `git status --porcelain -- .github` printed nothing; `git diff --name-only origin/main...HEAD` lists only the feature folder's issue.md, plan, and research file.
- Regexes: all 42 fixture cases in P1-T5..P1-T15 and the existing cases produce the plan's expected results; none of the four patterns matches any `*.yml`/`*.yaml` line under `.github/` in the current tree.
- Prototype: `poetry run pyright` reported `0 errors, 0 warnings, 0 informations`; 46 in-memory helper tests passed.
