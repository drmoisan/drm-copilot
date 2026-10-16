# Final PoshQC Format (issue #953, P6-T1)

Timestamp: 2026-10-16T08-27
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; ...Get-FileHash -Algorithm SHA256 for primary-path items 1-19...; $before = (git status --porcelain) -join "`n"; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-final-format.log'); $exit = $LASTEXITCODE; $after = (git status --porcelain) -join "`n"; ...count lines starting with "Formatted: " and "Already formatted:"...; exit $exit' (script SCRATCH/issue-953-p6-t1.sh, run with sh)
EXIT_CODE: 0
Output Summary: Formatter exited 0. Log lines starting with "Formatted: ": 0. Log lines starting with "Already formatted:": 784 (of 784 log lines; two more than the baseline 782 because of the two new test files). git status --porcelain before equals after: True. Invoke-PoshQCFormat produced no diff (AC-07).

FORMATTED_LINES: 0
ALREADY_FORMATTED_LINES: 784
BEFORE_EQUALS_AFTER: True

HASH_BEFORE: scripts/powershell/PoshQC/settings/pester.runsettings.psd1 5F33F8E2C4224D2626D928A2A54453F2F4E991BE920763DBEDA1F0F12D95B1EE
HASH_BEFORE: extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 5F33F8E2C4224D2626D928A2A54453F2F4E991BE920763DBEDA1F0F12D95B1EE
HASH_BEFORE: scripts/powershell/PoshQC/PoshQC.psm1 CE9D8565CF915841A0C435DC52FAEFA8A4EAE08109736F6801C1E05945BAD834
HASH_BEFORE: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 CE9D8565CF915841A0C435DC52FAEFA8A4EAE08109736F6801C1E05945BAD834
HASH_BEFORE: scripts/powershell/PoshQC/README.md 3E1A3BBCCB0D2148ED625504F379DF499E380895E8FCE1435556A32B86A53859
HASH_BEFORE: extensions/drm-copilot/resources/powershell/PoshQC/README.md 3E1A3BBCCB0D2148ED625504F379DF499E380895E8FCE1435556A32B86A53859
HASH_BEFORE: .github/workflows/_poshqc.yml 4C2EA722BBC57558084F8C2BE2844F3AB3FA5FE326EF3DCEF7BC544611624F34
HASH_BEFORE: scripts/host-tools.manifest.json E6E4CC2404880E09BE582EC22CDBD30F9FA58D6F24D6B365DA3C2872A54484E6
HASH_BEFORE: .devcontainer/post-create.sh 7AA9190A669EC8FEA7726AAEA03F4C1FC0115643E1CB157D501B7283FB526041
HASH_BEFORE: .github/codex/codex-web-setup.sh F865EA45EF9AAA9BEB8655F252F34CD5103B1528CD254EE977EB780FD80BF3B9
HASH_BEFORE: tests/scripts/host-tools.manifest.Tests.ps1 A55D392791FBC0CD6E8C3E087D17190D8A68A1B671DD577B06978A3C57FA1377
HASH_BEFORE: tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 3DFAB438DB6B0886FDB6720440955CC43504E1A05B68A7ACA3F11BC890F3FD7F
HASH_BEFORE: extensions/drm-copilot/CHANGELOG.md FD2AB56B9A640A033F28FB4AC0B112820D85BE05021A10636513F2EEF5E51F73
HASH_BEFORE: tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 E7A9B7B7E1A2615082B4D696B753A9B7EBC5B9683137311AD6C95AE6EC498545
HASH_BEFORE: tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1 433F1023783AB84556F76F0E60763278D974147C05EDF161379A324222CF048F
HASH_BEFORE: scripts/powershell/PoshQC/PoshQC.Testing.psm1 A898747A299FF47D545547E45733248FF741A79966E5E90413570066E86108F3
HASH_BEFORE: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 A898747A299FF47D545547E45733248FF741A79966E5E90413570066E86108F3
HASH_BEFORE: tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 09761D16E403B98672EFC8EBC783FE4389D91258B6ABFE1A900BD45AF6A9FEED
HASH_BEFORE: tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1 B154AC913B0CA2762A4A8CE9C0CCC957496AAE517D9056E4BE51DFA666CEAE5C
