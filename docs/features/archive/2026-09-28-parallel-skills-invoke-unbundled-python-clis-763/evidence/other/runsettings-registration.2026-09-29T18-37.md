# Coverage Registration in Both Runsettings Files (P5-T6, P5-T7)

Timestamp: 2026-09-29T18-37
Command: sh SCRATCH/run-ps.sh SCRATCH/psd1-parse.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ; git grep -c -F -e .claude/lib/parallel-drift/ -- scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ; cp scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 ; sh SCRATCH/mirror-check.sh scripts/powershell/PoshQC/settings/pester.runsettings.psd1
EXIT_CODE: 0
Output Summary:
- P5-T6: the six B28 lines were inserted after line 324 (inside `CodeCoverage.Path`, before the
  closing parenthesis). `PSD1-OK file=scripts/powershell/PoshQC/settings/pester.runsettings.psd1`;
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:3` (the three registered paths).
- P5-T7: `MIRROR SAME scripts/powershell/PoshQC/settings/pester.runsettings.psd1`,
  `MIRROR-SUMMARY same=1 diff=0 missing=0`.
