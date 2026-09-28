Timestamp: 2026-08-31T11-26
Command: `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing`
EXIT_CODE: 1
Output Summary:
- Baseline result: 1 failed, 4244 passed, 5 skipped in 32.40 seconds.
- Pre-existing failure: `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest`.
- Failure detail: `.claude/skills/epic-orchestrate/SKILL.md` expected SHA-256 `d8d3425b5cc70bccfa1d1ab19266f9c90a0134d98a510aedcea636d24d5d078b`, observed `42cd106c1dc6982cfe4fb15fb3439bdde4eb1bbbc6a1a2db26a8739587ab4ca7`.
- Repository line coverage: 92.7087% (14101/15210 statements).
- Repository branch coverage: 85.2994% (4758/5578 branches).
- Coverage.py combined displayed coverage: 91%.
