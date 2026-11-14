# Quality-Tier Classification Check — feature-review (#1156)

Timestamp: 2026-11-14T04-29
Command: sh SCRATCH/qt.sh (from the item worktree root: <main checkout venv python> -m scripts.dev_tools.check_quality_tiers; the same module the CI step in `.github/workflows/_quality-checks.yml` runs as `poetry run python -m scripts.dev_tools.check_quality_tiers`)
EXIT_CODE: 1
Output Summary: `QT008: discovered project '.claude/lib/regeneration' has no entry`. The branch adds the folder `.claude/lib/regeneration/` (four files), which project discovery treats as a project, and `quality-tiers.yml` at the repository root has no entry for it. No other QT finding was reported. The executor's gate evidence did not run this check.
