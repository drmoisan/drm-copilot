Timestamp: 2026-02-16T18-56-11-05:00
Command 1: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCFormat -Root ."
EXIT_CODE 1: 0
Command 2: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCAnalyze -Root ."
EXIT_CODE 2: 0
Command 3: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root ."
EXIT_CODE 3: 0
Output Summary:
- Final pass status: True
- Attempts: 1
- Format output lines: 35
- Analyze output lines: 2
- Test output lines: 40

--- Command 1 Output ---
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\dev-tools\format-powershell.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\dev-tools\link-feature-docs.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\dev-tools\link-parent-child.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\dev-tools\load-openai-key.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\dev-tools\new-potential-entry.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\dev-tools\publish-sideloaded-extension.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\dev-tools\run-actionlint.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\dev-tools\run-pester.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\dev-tools\run-psscriptanalyzer.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\dev-tools\sync-agents-from-instructions.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\dev-tools\tree.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\powershell\BootstrapPC\bootstrap-host.helpers.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\powershell\BootstrapPC\bootstrap-host.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\powershell\BootstrapPC\verify-host.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\powershell\PoshQC\convert-poshqc-coverage.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\powershell\PoshQC\PoshQC.psd1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\powershell\PoshQC\PoshQC.psm1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\powershell\PoshQC\settings\pester.runsettings.psd1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\scripts\powershell\PoshQC\settings\pssa.settings.psd1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\tests\fixtures\shell_qc\scripts\pwsh_script.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\agents-attribution.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\link-feature-docs.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\link-parent-child.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\new-potential-entry.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\run-actionlint.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\sync-agents-from-instructions.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\tree.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\lexile_scoring_model\pipeline_scripts\load-openai-key.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\BootstrapPC\bootstrap-host.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\PoshQC\Get-PoshQCFileList.Excludes.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\PoshQC\PoshQC.Comprehensive.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\PoshQC\PoshQC.EntryPoints.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\PoshQC\PoshQC.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\Support\TestHelpers.ps1

--- Command 2 Output ---
PSScriptAnalyzer passed: no findings under .

--- Command 3 Output ---
[95m
[95mStarting discovery in 13 files.[0m
[95mDiscovery found 270 tests in 295ms.[0m
[95mStarting code coverage.[0m
[95mRunning tests.[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\agents-attribution.Tests.ps1[0m[90m 289ms (29ms|190ms)[0m
What if: Performing the operation "Update section content" on target "## Feature Docs".
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\link-feature-docs.Tests.ps1[0m[90m 417ms (354ms|47ms)[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\link-parent-child.Tests.ps1[0m[90m 371ms (318ms|46ms)[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\new-potential-entry.Tests.ps1[0m[90m 233ms (157ms|54ms)[0m
actionlint not found; downloading local copy into tools/actionlint/bin...
Downloading https://github.com/rhysd/actionlint/releases/download/v1.7.7/actionlint_1.7.7_windows_amd64.zip ...
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\run-actionlint.Tests.ps1[0m[90m 787ms (663ms|84ms)[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\sync-agents-from-instructions.Tests.ps1[0m[90m 146ms (115ms|26ms)[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev-tools\tree.Tests.ps1[0m[90m 290ms (212ms|63ms)[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\lexile_scoring_model\pipeline_scripts\load-openai-key.Tests.ps1[0m[90m 50ms (32ms|14ms)[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\BootstrapPC\bootstrap-host.Tests.ps1[0m[90m 1.8s (1.65s|127ms)[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\PoshQC\Get-PoshQCFileList.Excludes.Tests.ps1[0m[90m 59ms (43ms|12ms)[0m
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
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\PoshQC\PoshQC.Comprehensive.Tests.ps1[0m[90m 1.13s (948ms|130ms)[0m
PSScriptAnalyzer 1.24.0 already present.
Pester 5.7.1 already present.
No PowerShell files found under C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\PoshQC
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\PoshQC\PoshQC.EntryPoints.Tests.ps1[0m[90m 436ms (404ms|25ms)[0m
[32m[+] C:\Users\DanMoisan\repos\drm-copilot\tests\scripts\powershell\PoshQC\PoshQC.Tests.ps1[0m[90m 311ms (222ms|73ms)[0m
[97mTests completed in 6.37s[0m
[32mTests Passed: 263, [0m[90mFailed: 0, [0m[93mSkipped: 7, [0m[90mInconclusive: 0, [0m[37m[0m[90mNotRun: 0[0m
[95mProcessing code coverage result.[0m
[32mCovered 66.02% / 0%. 933 analyzed Commands in 12 Files.[0m
Wrote Koverage coverage copy: C:\Users\DanMoisan\repos\drm-copilot\.\.\artifacts\pester\powershell-coverage.koverage.xml
