# Bundled-Copy Identity (issue #953, P0-T18)

Timestamp: 2026-10-16T07-47
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $pairs = @(...four pairs...); $n = 0; foreach ($p in $pairs) { $n++; $a = (Get-FileHash -Algorithm SHA256 -LiteralPath $p[0]).Hash; $b = (Get-FileHash -Algorithm SHA256 -LiteralPath $p[1]).Hash; "{0} {1}" -f $p[0], $a; "{0} {1}" -f $p[1], $b; "PAIR_{0}_EQUAL: {1}" -f $n, $(if ($a -eq $b) { "YES" } else { "NO" }) }' (script SCRATCH/issue-953-p0-t18.sh, run with sh)
EXIT_CODE: 0
Output Summary: All four repository/bundled pairs are byte-identical (SHA256 equal). The mirror tasks P2-T2, P3-T3, P3-T4, and P5-T5 use Copy-Item; the Edit-tool branch is not needed.

PAIR_1_EQUAL: YES
PAIR_2_EQUAL: YES
PAIR_3_EQUAL: YES
PAIR_4_EQUAL: YES

```text
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 7C966E7A3F341868E004F59A9F79F0C88824C47DA97BAAE82BBC142A5A58BE05
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 7C966E7A3F341868E004F59A9F79F0C88824C47DA97BAAE82BBC142A5A58BE05
scripts/powershell/PoshQC/PoshQC.psm1 36715226C4726AE3AE3426A1898ABBDFBEFC71E2A034C0C5199EEA626A793BE0
extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 36715226C4726AE3AE3426A1898ABBDFBEFC71E2A034C0C5199EEA626A793BE0
scripts/powershell/PoshQC/README.md 9123DDE0CD283EC38D06506A2BE8F706A1A7979B5D962E286EC63EF20D22CE71
extensions/drm-copilot/resources/powershell/PoshQC/README.md 9123DDE0CD283EC38D06506A2BE8F706A1A7979B5D962E286EC63EF20D22CE71
scripts/powershell/PoshQC/PoshQC.Testing.psm1 1B2D124E590B0FBAF452FB82B2E08F94DD498026FE0BCC60038F40E8ABDAF6F0
extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 1B2D124E590B0FBAF452FB82B2E08F94DD498026FE0BCC60038F40E8ABDAF6F0
```
