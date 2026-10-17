# r3 Final Bundle Identity (P5-T10)

Timestamp: 2026-10-16T22-38
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; foreach ($n in @('PoshQC.Shard.psm1', 'PoshQC.CoverageMerge.psm1', 'PoshQC.Testing.psm1', 'README.md')) { $a = (Get-FileHash -Algorithm SHA256 -LiteralPath "scripts/powershell/PoshQC/$n").Hash; $b = (Get-FileHash -Algorithm SHA256 -LiteralPath "extensions/drm-copilot/resources/powershell/PoshQC/$n").Hash; "PAIR_EQUAL: $n " + $(if ($a -ceq $b) { 'YES' } else { 'NO' }) + " $a" }' (SCRATCH/issue-953-r3-p5-t10.sh)
EXIT_CODE: 0
Output Summary:
- All four BUNDLE_PAIRS are byte-identical. Result: PASS (the README pair, which the parity pytest does not cover, is identical).

PAIR_EQUAL: PoshQC.Shard.psm1 YES
PAIR_EQUAL: PoshQC.CoverageMerge.psm1 YES
PAIR_EQUAL: PoshQC.Testing.psm1 YES
PAIR_EQUAL: README.md YES

Hashes:
- PoshQC.Shard.psm1 82AF2CC848B396A562DEE49F2652E3874A1755349DEB80DD5B6F68F09452E939
- PoshQC.CoverageMerge.psm1 4D64E8527F2FFD5D2E94A7FDB3C3AB7014104AFEA6BD8E7C2F3E684CBA3938B0
- PoshQC.Testing.psm1 F656CC6CAFEA86883F8141B0DA05151E4108B6C6E2AF2EF826FE8158C5FFBBE1
- README.md EB531C2E725C78D06F9FAC9CC211BBD7B72E83CC08B756BAB51218063DBFDE4B
