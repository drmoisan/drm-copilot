# Verification Capture Sites (Issue 887)

Timestamp: 2026-10-12T14-50
Command: git diff --exit-code origin/main...HEAD -- scripts/dev-tools/HostVerification.psm1; git grep -n -F 'ArgumentList $VersionArgs -MergeErrorStream' -- scripts/dev-tools/HostTooling.psm1
EXIT_CODE: 0
Output Summary:
- git diff --exit-code origin/main...HEAD -- scripts/dev-tools/HostVerification.psm1: no output, exit 0 (file unchanged).
- Supplementary read of HostVerification.psm1: lines 46, 77, and 82 each pass -MergeErrorStream and none passes -StreamToHost.
- git grep printed exactly one line: `scripts/dev-tools/HostTooling.psm1:202:    $result = Invoke-HostNativeCommand -FilePath $commandInfo.Source -ArgumentList $VersionArgs -MergeErrorStream` (the Get-CommandVersion call); the line does not contain StreamToHost (AC-12).
