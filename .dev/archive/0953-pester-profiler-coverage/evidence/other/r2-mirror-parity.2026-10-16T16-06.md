# r2 mirror and parity (P4-T2)

Timestamp: 2026-10-16T16-06
Command: sh "SCRATCH/issue-953-r2-p4-t2.sh" (pwsh text: Copy-Item -LiteralPath scripts/powershell/PoshQC/<name> -Destination extensions/drm-copilot/resources/powershell/PoshQC/<name> -Force for PoshQC.Shard.psm1, PoshQC.CoverageMerge.psm1, PoshQC.Testing.psm1, README.md; then Get-FileHash -Algorithm SHA256 comparison per pair); poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q
EXIT_CODE: 0
Output Summary:
  PAIR_EQUAL: PoshQC.Shard.psm1 True
  PAIR_EQUAL: PoshQC.CoverageMerge.psm1 True
  PAIR_EQUAL: PoshQC.Testing.psm1 True
  PAIR_EQUAL: README.md True
  pytest: "1 passed in 0.06s" (AC-02)
