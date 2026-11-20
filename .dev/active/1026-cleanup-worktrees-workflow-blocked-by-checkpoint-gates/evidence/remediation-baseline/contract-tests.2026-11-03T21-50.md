# Baseline Contract Tests (P0-T5)

Timestamp: 2026-11-03T21-50
Command: sh SCRATCH/issue-1026-contracts.sh baseline (poetry run pytest --strict-markers --strict-config -q --junitxml=SCRATCH/issue-1026-pytest-baseline.xml over the ten CONTRACT_MODULES pytest files; then poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check)
EXIT_CODE: 0
Output Summary: pytest exit 0, 175 passed, 0 failed, 0 errors, 0 skipped (JUnit tests=175 failures=0 errors=0); generator --check exit 0.

- Pytest exit code: 0
- Generator `--check` exit code: 0
