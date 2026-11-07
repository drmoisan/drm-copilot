# Contract Tests (P6-T6)

Timestamp: 2026-11-07T16-37
Command: sh SCRATCH/issue-1037-contract.sh phase6 (`env -u VIRTUAL_ENV poetry run pytest -n auto` over the twenty `tests/scripts/dev_tools/` modules listed in [P6-T6], then `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`); sh SCRATCH/issue-1037-jest.sh phase6 `test/lib/push-down/claude-pack-manifest-completeness.test.ts` (`node run-jest.cjs` in `extensions/drm-copilot/`)
EXIT_CODE: 0
Output Summary: Contract tests: 1011 passed, 0 failed, 0 errors (baseline [P0-T6]: 995 passed, 0 failed; the 16 added rows are parametrized cases over the new agents, skills and manifests). New failures relative to [P0-T6]: none. Codex generator `--check`: exit 0. Jest `claude-pack-manifest-completeness.test.ts`: 1 suite, 24 tests passed.

Owner directive 2026-11-07: parallel test gates only

The contract modules ran in one `pytest -n auto` run.
