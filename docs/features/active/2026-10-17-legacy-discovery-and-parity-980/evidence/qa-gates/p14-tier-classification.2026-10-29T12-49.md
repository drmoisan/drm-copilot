# P14-T13 Tier classification

Timestamp: 2026-10-29T12-49
Task: [P14-T13] Re-run repository and publication contracts under the tiered file-size policy, discharging [P13-T6].
Command: poetry run python -m scripts.dev_tools.check_quality_tiers
EXIT_CODE: 0
Output Summary: `quality-tiers: OK (28 entries, 28 discovered projects)`. P13-T6 recorded 27 of 27; the additional project arrived with the rebase onto main and is classified.
Run window 2026-10-29T12-46 to 12-49 UTC on the final tree (`git status --porcelain` empty at start and end).
Result: PASS
