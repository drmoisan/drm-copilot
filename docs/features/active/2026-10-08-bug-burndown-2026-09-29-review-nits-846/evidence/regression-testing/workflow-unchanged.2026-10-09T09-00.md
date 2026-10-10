# Regression: no workflow file changed ([P8-T9], AC-33)

Merge-base substitution: anchored commands use 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a (recorded by [P0-T4]) in place of the plan literal e7d3779b398604af919678c16c877c8539a86cc0.

Timestamp: 2026-10-09T21-46
Command: git diff --name-only 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a -- .github/workflows/
EXIT_CODE: 0
Output Summary: nothing printed.

## Block 2

Command: git status --porcelain --untracked-files=all -- .github/workflows/
EXIT_CODE: 0
Output Summary: nothing printed.

## Block 3

Command: poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q
EXIT_CODE: 0
Output Summary: `52 passed in 0.10s`; zero failed.

Acceptance (AC-33): the two git blocks print nothing; pytest exits 0 with zero failed. PASS.
