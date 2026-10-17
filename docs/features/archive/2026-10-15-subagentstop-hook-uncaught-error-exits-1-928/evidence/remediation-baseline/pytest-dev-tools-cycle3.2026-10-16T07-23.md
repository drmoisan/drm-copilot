# Pytest dev-tools Baseline (remediation cycle 3)

Timestamp: 2026-10-16T07-23
Command: poetry run pytest tests/scripts/dev_tools/ -q
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Summary line: `2 failed, 7019 passed, 6 skipped in 37.51s`
- BASE_DEV_PASSED: 7019
- FAILED lines:
  - `FAILED tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/agents/epic-orchestrator.md-d5e5e3b015c810fd12911e0ecffee38e12122bcdf667683778c7bd6cbdf6f538]`
  - `FAILED tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/skills/epic-orchestrate/SKILL.md-0b1a629aa81d78673e43c8f2bbd825d1377e0d6ae114e15e8bb65450c5d8b4f2]`
- ERROR lines: none
- Environment note (deviation, recorded): the first run of this command at 2026-10-16T07-20 exited 2 with `Interrupted: 16 errors during collection` / `16 errors in 6.48s`; all 16 were `ModuleNotFoundError: No module named 'typer'` in `tests/scripts/dev_tools/codex_native_converter/`. `typer` is declared in `pyproject.toml` (line 18) and pinned in `poetry.lock`, but was absent from the untracked worktree `.venv`. `poetry install --no-interaction` (EXIT 0; `Installing dependencies from lock file`, `99 installs, 0 updates, 0 removals`) synchronized the environment to the existing lock; no tracked file changed (scoped porcelain outside FEATURE stayed empty). The command above was then re-run and is the recorded gate. P0-T5 was re-run after the sync with the identical result `2 failed, 34 passed`.

BASE_FAIL_SET:
tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/agents/epic-orchestrator.md-d5e5e3b015c810fd12911e0ecffee38e12122bcdf667683778c7bd6cbdf6f538]
tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/skills/epic-orchestrate/SKILL.md-0b1a629aa81d78673e43c8f2bbd825d1377e0d6ae114e15e8bb65450c5d8b4f2]
