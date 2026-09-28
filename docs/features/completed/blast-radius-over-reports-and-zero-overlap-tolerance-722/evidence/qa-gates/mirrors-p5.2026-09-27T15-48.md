# Phase 5 Mirrors (P5-T8, with the P5-T7 parse check)

Timestamp: 2026-09-27T15-48
Command: sh SCRATCH/run-ps.sh SCRATCH/copy-file.ps1 -Source <primary> -Destination <mirror> (three runs) ; sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 (six paths)
EXIT_CODE: 0
Output Summary: Each of the three A10 runs printed its COPIED line. The two SHA256 values of each of the three primary/mirror pairs are equal (scheduling module, facade, Pester runsettings). The P5-T7 parse check of the edited runsettings (A11) exited 0 and printed its PSD1-OK line.

## P5-T7 parse check

Command: sh SCRATCH/run-ps.sh SCRATCH/psd1-parse.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1
EXIT_CODE: 0

```text
PSD1-OK file=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
```

## A10 copy runs

| Source | Destination | Printed |
| --- | --- | --- |
| .claude/lib/blast-radius/BlastRadiusScheduling.psm1 | extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1 | COPIED .claude/lib/blast-radius/BlastRadiusScheduling.psm1 |
| .claude/lib/blast-radius/BlastRadius.psm1 | extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1 | COPIED .claude/lib/blast-radius/BlastRadius.psm1 |
| scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 | COPIED scripts/powershell/PoshQC/settings/pester.runsettings.psd1 |

## A5 hashes

```text
.claude/lib/blast-radius/BlastRadiusScheduling.psm1 Hash=50F8AE215463F0B53A8E23CAFF8EE8D829CD003ADBA67C75D53C515A60F2CE24
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1 Hash=50F8AE215463F0B53A8E23CAFF8EE8D829CD003ADBA67C75D53C515A60F2CE24
.claude/lib/blast-radius/BlastRadius.psm1 Hash=956A92B632104B2427B6C2FA8C5E9D8252A71ABD223B81440B899DA9FEF93B0E
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1 Hash=956A92B632104B2427B6C2FA8C5E9D8252A71ABD223B81440B899DA9FEF93B0E
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 Hash=D20500185850A9E318C539AC54F29594DA74CD16D34944C001D80D79853AE4BF
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 Hash=D20500185850A9E318C539AC54F29594DA74CD16D34944C001D80D79853AE4BF
```

| Pair | Equal |
| --- | --- |
| BlastRadiusScheduling module | yes |
| BlastRadius facade | yes |
| Pester runsettings | yes |

SCRATCH denotes the executor session scratchpad directory (outside the repository).
