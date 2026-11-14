# Remediation Baseline — Quality Tiers Check, R1 fail-before (cycle 1, [P0-T2])

Timestamp: 2026-11-14T04-52
Command: sh SCRATCH/issue-1156-tiers.sh (from the worktree root: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.check_quality_tiers)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- QT008: discovered project '.claude/lib/regeneration' has no entry
- This is the only output line; finding R1 reproduces before the fix.
