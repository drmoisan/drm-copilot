Timestamp: 2026-11-05T06-36
Started: 2026-11-05T06:36:50.8516026Z
Command: C:/Program Files/Git/bin/sh.exe SCRATCH/issue-1082-repository-integrity.sh
EXIT_CODE: 0
Output Summary:

```text
Complete main-merge-base diff covered files=51; max logical lines=766; over-limit=0

Path                                                                           Lines
----                                                                           -----
tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1                   766
tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1             552
tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1   501
tests/scripts/dev_tools/test_execution_environment_brief_contracts.py            497
extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1           493
scripts/powershell/PoshQC/PoshQC.Testing.psm1                                    493

Current changed Python/PowerShell test and helper purity: 40 files; zero findings
Preserved extensions/drm-copilot/node_modules/.package-lock.json: SHA256=4733D753DC46BCDFFF6FD6DAB637C80F8B83C6AB5CF781CD2B9A07CCE58C5BC3
Preserved node_modules/.package-lock.json: SHA256=7DB9A42460E5D49835493222ACCD403E0545143996D867D784EBDD08BD368ECE
Preserved .venv/Scripts/python.exe: SHA256=6A74478B20739A9C814DCDB465A68CDF384B43447910399E02776D66A2BD1635
Preserved packages/mcp-server/node_modules/.package-lock.json: SHA256=ED66C4093C692B6589DEED3CE6460C7CCD034F129BDA144B188150719A918FAA
Host core.fsmonitor remains true.
drm-copilot-workspace 2026-11-05T02:03:32Z
d121cd8769a9f6e7048f513bb96993ca5eb631aaad9e92a65a45e27b21d70500 exited
Original ignored host payload preserved: SHA256=97643F5BFB6CCC57F69ED46A06A490E3EA2CF5A85EE5A8FA8FB920991BBA8A66
Tracked branch diff whitespace check passed.
```

Raw output: SCRATCH/issue-1082-repository-integrity.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
