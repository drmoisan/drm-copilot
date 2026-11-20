# r3 Mirror and Parity (P4-T7)

Timestamp: 2026-10-16T22-04
Command: (1) export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; foreach ($n in @('PoshQC.Shard.psm1', 'README.md')) { Copy-Item -LiteralPath "scripts/powershell/PoshQC/$n" -Destination "extensions/drm-copilot/resources/powershell/PoshQC/$n" -Force }; foreach ($n in @(<four BUNDLE_PAIRS names>)) { ... "PAIR_EQUAL: $n $($a -ceq $b)" }' (SCRATCH/issue-953-r3-p4-t7.sh); (2) poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q
EXIT_CODE: 0
Output Summary:
- PAIR_EQUAL: PoshQC.Shard.psm1 True
- PAIR_EQUAL: PoshQC.CoverageMerge.psm1 True
- PAIR_EQUAL: PoshQC.Testing.psm1 True
- PAIR_EQUAL: README.md True
- pytest summary line: `1 passed in 0.06s` (AC-02)
- The bundled copies were written only with Copy-Item through the Tool route; no Write or Edit call targeted a bundled file.
- Result: PASS.
