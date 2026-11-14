# Remediation cycle 2 — final tier-classification check ([P1-T8])

Timestamp: 2026-11-14T09-02
Command: sh SCRATCH/issue-1159-c2-qt.sh (from the worktree root: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.check_quality_tiers --repo-root <worktree root>, the CI step's form)
EXIT_CODE: 0
Output Summary: "quality-tiers: OK (34 entries, 34 discovered projects)". Entry and discovered-project counts are equal; no QT line printed. At the [P0-T1] baseline (remediation-baseline/quality-tiers.2026-11-14T08-45.md) the same command exited 1 with QT008 for `.claude/lib/hook-dispatch` (finding F1).
