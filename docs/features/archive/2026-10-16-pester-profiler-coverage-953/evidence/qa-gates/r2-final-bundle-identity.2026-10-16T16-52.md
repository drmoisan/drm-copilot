# r2 final bundle identity (P5-T6)

Timestamp: 2026-10-16T16-52
Command: sh "SCRATCH/issue-953-r2-p5-t6.sh" (pwsh text: foreach ($n in @('PoshQC.Shard.psm1', 'PoshQC.CoverageMerge.psm1', 'PoshQC.Testing.psm1', 'README.md')) { $a = (Get-FileHash -Algorithm SHA256 -LiteralPath "scripts/powershell/PoshQC/$n").Hash; $b = (Get-FileHash -Algorithm SHA256 -LiteralPath "extensions/drm-copilot/resources/powershell/PoshQC/$n").Hash; "PAIR_EQUAL: $n $(if ($a -eq $b) { 'YES' } else { 'NO' }) $a" })
EXIT_CODE: 0
Output Summary: all four BUNDLE_PAIRS are byte-identical; the README pair (outside the parity pytest) is identical.

PAIR_EQUAL: PoshQC.Shard.psm1 YES
PAIR_EQUAL: PoshQC.CoverageMerge.psm1 YES
PAIR_EQUAL: PoshQC.Testing.psm1 YES
PAIR_EQUAL: README.md YES

Hashes: PoshQC.Shard.psm1 BB41B6E206BB9CCE3B502A69B045ED558859EF48AEA67C7ABD815BFB3790DF7E; PoshQC.CoverageMerge.psm1 4D64E8527F2FFD5D2E94A7FDB3C3AB7014104AFEA6BD8E7C2F3E684CBA3938B0; PoshQC.Testing.psm1 F656CC6CAFEA86883F8141B0DA05151E4108B6C6E2AF2EF826FE8158C5FFBBE1; README.md AEF68D1874B4F74C2F71DD379DBD476A29FCDAD80A602F45CF2F7D75908A5FD1
