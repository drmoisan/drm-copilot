# R4 Coverage Mode Check (P0-T4, issue #935)

Timestamp: 2026-10-16T23-42
Command: grep -c -F -e 'UseBreakpoints' scripts/powershell/PoshQC/settings/pester.runsettings.psd1
EXIT_CODE: 1

Output Summary:
- Printed count: `0` (grep exits 1 when the count is 0; the count is the observation). `UseBreakpoints` is not set, so Pester default breakpoint coverage is in effect; this plan does not change it.
- CI figures (quoted from `Established Facts`, not re-derived; CI quotations): post-change root line coverage 89.66% (16531/18437) at `048d76cd8`, the former PR #956 head, CI run 38963921545; baseline 90.42% (`adb9aa5f0`).
