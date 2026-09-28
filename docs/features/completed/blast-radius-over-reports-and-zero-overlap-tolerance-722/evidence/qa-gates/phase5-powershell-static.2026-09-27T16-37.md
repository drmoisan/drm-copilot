# Phase 5 PowerShell Format and Lint (P5-T14)

Timestamp: 2026-09-27T16-37
Command: sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 <seven files> ; mcp__drm-copilot__run_poshqc_format (scan_folders = seven files) ; sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 <seven files> ; sh SCRATCH/run-ps.sh SCRATCH/ps-format-check.ps1 <seven files> ; mcp__drm-copilot__run_poshqc_analyze (scan_folders = seven files)
EXIT_CODE: 0
Output Summary: PASS. The MCP format call returned ok=true without raising and changed one file, tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 (hashtable key alignment in one BeforeAll helper; 6 lines, whitespace only). A6 then printed FORMAT-SUMMARY ChangedCount=0. The MCP analyze call returned ok=true without raising. Because a hash changed, P5-T10 and P5-T13 were re-run (artifacts pester-part-a.2026-09-27T16-35.md and pester-directory-p5.2026-09-27T16-37.md; both pass with results identical to the first runs). No mirror was affected: the changed file is a test file with no bundled mirror, and the three mirrored primaries kept their hashes. A second MCP format call left all seven hashes unchanged, so the loop closed on a clean pass.

## Files (the six files of P5-T2 through P5-T7 and the P5-T12 file)

1. tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1
2. tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1
3. tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
4. .claude/lib/blast-radius/BlastRadiusScheduling.psm1
5. .claude/lib/blast-radius/BlastRadius.psm1
6. scripts/powershell/PoshQC/settings/pester.runsettings.psd1
7. tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1

## Hashes before the format call (A5, exit 0)

```text
tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 Hash=700D22477DE51F665C287EDA5C30E2CFF828738B8A390ABF7AECE0E4AB75430F
tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 Hash=655698F99675EC4E6AE753F2176D16A339C4349F223484AED404FE116C23ACA5
tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 Hash=3616B21297D78031158CCBEB9241F4CCED0801F2DDC20CD464BC3E1315D62926
.claude/lib/blast-radius/BlastRadiusScheduling.psm1 Hash=50F8AE215463F0B53A8E23CAFF8EE8D829CD003ADBA67C75D53C515A60F2CE24
.claude/lib/blast-radius/BlastRadius.psm1 Hash=956A92B632104B2427B6C2FA8C5E9D8252A71ABD223B81440B899DA9FEF93B0E
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 Hash=D20500185850A9E318C539AC54F29594DA74CD16D34944C001D80D79853AE4BF
tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 Hash=2C60AF021CBD05291542E3CF4C9DAD137792581038A06CB688C0B7F1FC21C219
```

## MCP format call

```text
{"ok":true,"tool":"run_poshqc_format","summary":"Ran bundled PoshQC format ... with 7 selected scan folder(s)."}
```

## Hashes after the format call (A5, exit 0)

```text
tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 Hash=27B74F59BD95F5B93A9F1DFDE880E670041E408C2C12EE0E0633D757CEDA6404   (changed)
tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 Hash=655698F99675EC4E6AE753F2176D16A339C4349F223484AED404FE116C23ACA5
tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 Hash=3616B21297D78031158CCBEB9241F4CCED0801F2DDC20CD464BC3E1315D62926
.claude/lib/blast-radius/BlastRadiusScheduling.psm1 Hash=50F8AE215463F0B53A8E23CAFF8EE8D829CD003ADBA67C75D53C515A60F2CE24
.claude/lib/blast-radius/BlastRadius.psm1 Hash=956A92B632104B2427B6C2FA8C5E9D8252A71ABD223B81440B899DA9FEF93B0E
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 Hash=D20500185850A9E318C539AC54F29594DA74CD16D34944C001D80D79853AE4BF
tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 Hash=2C60AF021CBD05291542E3CF4C9DAD137792581038A06CB688C0B7F1FC21C219
```

The formatter change (git diff against HEAD) re-aligns the "=" column of one hashtable literal in the
BeforeAll helper of BlastRadiusScheduling.Tests.ps1 to the width of over_breadth_fraction; no token
changed.

## A6 read-only format check (exit 0)

```text
FORMAT file=tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 Changed=False
FORMAT file=tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 Changed=False
FORMAT file=tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 Changed=False
FORMAT file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 Changed=False
FORMAT file=.claude/lib/blast-radius/BlastRadius.psm1 Changed=False
FORMAT file=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 Changed=False
FORMAT file=tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 Changed=False
FORMAT-SUMMARY ChangedCount=0
```

## MCP analyze call

```text
{"ok":true,"tool":"run_poshqc_analyze","summary":"Ran bundled PoshQC analyze ... with 7 selected scan folder(s)."}
```

## Re-run rule applied

- Mirror re-copy: not required. The changed file has no bundled mirror; the three mirrored primaries
  (.claude/lib/blast-radius/BlastRadiusScheduling.psm1, .claude/lib/blast-radius/BlastRadius.psm1,
  scripts/powershell/PoshQC/settings/pester.runsettings.psd1) are unchanged.
- P5-T10 re-run: pester-part-a.2026-09-27T16-35.md (FailedCount=0 in all three runs; 50/50, 6/6, 5/5).
- P5-T13 re-run: pester-directory-p5.2026-09-27T16-37.md (496/496, 6/6, 5/5).

## Second format pass (loop closure)

A second MCP format call over the same seven files returned ok=true; a following A5 run printed the
same seven hashes as the "after" set above, so no file changed on the second pass.

SCRATCH denotes the executor session scratchpad directory (outside the repository).
