# Parity Hash — pester.runsettings.psd1 (Issue #392)

Timestamp: 2026-07-21T18-01
Command: `Get-FileHash -Algorithm SHA256` on repo-root and bundled `settings/pester.runsettings.psd1` after `cp` mirror.
EXIT_CODE: 0
Output Summary:
- Repo-root `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`: `34C5A4121DB1742FFFA315B5CDBA0BC8664C07E15590DD86D304C7AA27079DB2`
- Bundled `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`: `34C5A4121DB1742FFFA315B5CDBA0BC8664C07E15590DD86D304C7AA27079DB2`
- EQUAL = True. Byte-identical parity confirmed.
