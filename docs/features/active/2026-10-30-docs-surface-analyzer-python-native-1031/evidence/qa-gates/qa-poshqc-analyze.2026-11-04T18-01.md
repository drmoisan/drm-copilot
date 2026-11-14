# [P6-T8] PSScriptAnalyzer (direct)

Timestamp: 2026-11-04T18-01
Command: sh SCRATCH/issue-1031-psstatic.sh qa-ps2 (direct Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file over the PoshQC scan folders)
EXIT_CODE: 0
Output Summary: "ANALYZE files=681 findings=0 errors=0": zero findings in files this plan created or changed and a total of 0, not above the [P0-T7] total of 0.

## Remediation (first pass)

The first pass (qa-ps, 2026-11-04T17-40) reported 22 Warning findings, all in the four new Pester files: PSUseLiteralInitializerForHashtable (4; ordinal-comparer selection tables), PSUseShouldProcessForStateChangingFunctions (5; New-Test* helper names) and PSReviewUnusedParameter (13; InvokeProcess fakes that declared unused parameters). They were fixed without suppressions:
- the selection tables use @{} literals (the analyzers read only fixed lower-case keys);
- New-TestInput, New-TestContext, New-TestResponseText and New-TestNativeContext became ConvertTo-TestInput, Get-TestContext, ConvertTo-TestResponseText and Get-TestNativeContext;
- the recording seam forwards all four seam arguments to the fake, and a fake that ignores them declares no parameter.
The four suites then passed (63 tests, 0 failed, SCRATCH/issue-1031-p6fix.out) and the loop restarted from [P6-T1]. The first pass also reported one analyzer exception on extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 (an unchanged file); a standalone PSSA run of that file and this full re-run report no exception.
