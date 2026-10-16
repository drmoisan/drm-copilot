# r2 bundled-copy identity baseline (P0-T11)

Timestamp: 2026-10-16T15-34
Command: sh "SCRATCH/issue-953-r2-p0-t11.sh" (pwsh text: foreach ($n in @('PoshQC.Shard.psm1', 'PoshQC.CoverageMerge.psm1', 'PoshQC.Testing.psm1', 'README.md')) { $a = (Get-FileHash -Algorithm SHA256 -LiteralPath "scripts/powershell/PoshQC/$n").Hash; $b = (Get-FileHash -Algorithm SHA256 -LiteralPath "extensions/drm-copilot/resources/powershell/PoshQC/$n").Hash; "PAIR_EQUAL: $n $(if ($a -eq $b) { 'YES' } else { 'NO' }) $a" })
EXIT_CODE: 0
Output Summary: all four BUNDLE_PAIRS are byte-identical (SHA256).

PAIR_EQUAL: PoshQC.Shard.psm1 YES
PAIR_EQUAL: PoshQC.CoverageMerge.psm1 YES
PAIR_EQUAL: PoshQC.Testing.psm1 YES
PAIR_EQUAL: README.md YES

Hashes: PoshQC.Shard.psm1 11329227B415ABE85E600BCB895F73E295A04EA032E6556CD0B2EFD21B5A940F; PoshQC.CoverageMerge.psm1 5B1C10B1E3E09E9C3D981D4A3D61BB8BA008410C97C4FD560003033D88256A95; PoshQC.Testing.psm1 741953759A74E451D1726AB2516BC01B9BEBE083B5C5E46D6E68CA3069A43692; README.md 3E1A3BBCCB0D2148ED625504F379DF499E380895E8FCE1435556A32B86A53859
