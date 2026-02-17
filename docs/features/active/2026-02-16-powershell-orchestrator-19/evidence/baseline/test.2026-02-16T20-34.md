Timestamp: 2026-02-16T20-34
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."
EXIT_CODE: 0
Output Summary:
[95m
[95mStarting discovery in 12 files.[0m
[95mDiscovery found 213 tests in 1.28s.[0m
[95mStarting code coverage.[0m
[95mRunning tests.[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\agents-attribution.Tests.ps1[0m[90m 675ms (128ms|422ms)[0m
What if: Performing the operation "Update section content" on target "## Feature Docs".
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\link-feature-docs.Tests.ps1[0m[90m 1.04s (886ms|89ms)[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\link-parent-child.Tests.ps1[0m[90m 1.07s (951ms|56ms)[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\new-potential-entry.Tests.ps1[0m[90m 943ms (713ms|84ms)[0m
actionlint not found; downloading local copy into tools/actionlint/bin...
Downloading https://github.com/rhysd/actionlint/releases/download/v1.7.7/actionlint_1.7.7_windows_amd64.zip ...
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\run-actionlint.Tests.ps1[0m[90m 2.02s (1.72s|101ms)[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\sync-agents-from-instructions.Tests.ps1[0m[90m 519ms (419ms|38ms)[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\tree.Tests.ps1[0m[90m 849ms (638ms|68ms)[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\lexile_scoring_model\pipeline_scripts\load-openai-key.Tests.ps1[0m[90m 181ms (145ms|14ms)[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\PoshQC\Get-PoshQCFileList.Excludes.Tests.ps1[0m[90m 104ms (68ms|13ms)[0m
Already formatted: /repo/test.ps1
Formatted: /repo/test.ps1
Already formatted: /repo/test.ps1
PSScriptAnalyzer passed: no findings under /repo
PSScriptAnalyzer passed: no findings under /repo
No Pester test files found under configured paths for root /repo
No Pester test files found under configured paths for root /repo
No Pester test files found under configured paths for root /repo
No Pester test files found under configured paths for root /repo
No Pester test files found under configured paths for root /repo
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\PoshQC\PoshQC.Comprehensive.Tests.ps1[0m[90m 2.42s (2.09s|111ms)[0m
PSScriptAnalyzer 1.24.0 already present.
Pester 5.7.1 already present.
No PowerShell files found under C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\PoshQC
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\PoshQC\PoshQC.EntryPoints.Tests.ps1[0m[90m 1.4s (1.3s|51ms)[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\PoshQC\PoshQC.Tests.ps1[0m[90m 1.31s (1.11s|67ms)[0m
[97mTests completed in 12.59s[0m
[32mTests Passed: 206, [0m[90mFailed: 0, [0m[93mSkipped: 7, [0m[90mInconclusive: 0, [0m[37m[0m[90mNotRun: 0[0m
[95mProcessing code coverage result.[0m
[32mCovered 66.02% / 0%. 933 analyzed Commands in 12 Files.[0m
Wrote Koverage coverage copy: C:\Users\DanMoisan\repos\drm-copilot\.\.\artifacts\pester\powershell-coverage.koverage.xml

