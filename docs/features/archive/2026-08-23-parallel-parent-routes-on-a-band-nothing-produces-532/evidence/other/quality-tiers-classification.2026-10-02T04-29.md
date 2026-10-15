# Property-Test Library Determination (P0-T9b)

Timestamp: 2026-10-02T04-29
Command: grep -c -E "^name = .hypothesis.$" poetry.lock
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
0
- grep -c -F "fast-check" extensions/drm-copilot/package.json exited 1
0
Determination: neither `hypothesis` (poetry.lock) nor `fast-check` (extensions/drm-copilot/package.json) is declared. The in-scope projects have no T1/T2 classification (`quality-tiers.yml` maps `scripts/dev_tools` to T4 and `extensions/drm-copilot` to T3; see DEV-6 in quality-tiers-tracked.2026-10-02T04-29.md) and no property-test library is approved, so no property-based test is added. The uniform 85% line / 75% branch thresholds still apply.
