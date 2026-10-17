# r3 Shard Test Edits Verification (P3-T1, P3-T2, P3-T3)

Timestamp: 2026-10-16T22-01
Command: git diff --numstat 7558c7e42ec8c8955cb5f9997cca41afc6e3b797 -- tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1; export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $f = 'tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1'; ParseFile error count; (Get-Content -LiteralPath $f).Count; Select-String -SimpleMatch occurrence count of each of SH13, SH14, SH15' (SCRATCH/issue-953-r3-p3-t3.sh)
EXIT_CODE: 0
Output Summary:
- numstat: `51	0	tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1` (51 added, 0 deleted)
- PARSE_ERRORS=0
- LINES=223 (172 + 5 + 46; AC-15)
- OCCURRENCES SH13-SLICE-NEGATIVE-WEIGHT-THROWS 1
- OCCURRENCES SH14-WEIGHT-IGNORES-LINE-ENDINGS 1
- OCCURRENCES SH15-SELECT-WEIGHS-CHECKED-IN-FILES-BY-NORMALIZED-TEXT 1
- Result: PASS.
