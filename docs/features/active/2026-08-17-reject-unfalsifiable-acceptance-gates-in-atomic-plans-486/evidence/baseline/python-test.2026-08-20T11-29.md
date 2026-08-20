# Python Test and Coverage Baseline

Timestamp: 2026-08-20T11-29
Task: [P0-T5]
Issue: #486
Working directory: worktree root `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a61259d5432e08b89`

Command: `poetry run pytest tests/scripts/dev_tools -q --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Output Summary:

- Test result: 3850 passed, 0 failed, 5 skipped in 15.94s. The five skips are pre-existing parity-fixture skips in `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py` and are unrelated to this feature.
- Coverage target module `scripts/dev_tools/validate_orchestration_artifacts.py`:
  - Stmts 127, Miss 8 — line coverage 93.70%
  - Branch 52, BrPart 8 — branch coverage 84.62%
  - Combined `Cover` column as reported by pytest-cov: 91%
  - Missing: 66, 113->98, 117-121, 132, 147, 314, 316, 318, 341->345
- The dotted-module coverage form `--cov=scripts.dev_tools.validate_orchestration_artifacts` collected data, confirming the measurement is real.
