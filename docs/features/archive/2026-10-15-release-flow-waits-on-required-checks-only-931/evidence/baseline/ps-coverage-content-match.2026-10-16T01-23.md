# Baseline Coverage Content Match (Issue #931)

Timestamp: 2026-10-16T01-23
Command: git cat-file -e adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99; git rev-parse adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99:scripts/dev-tools/Invoke-FullReleaseFlow.ps1; git rev-parse HEAD:scripts/dev-tools/Invoke-FullReleaseFlow.ps1
EXIT_CODE: 0
Output Summary: identical. The script blob at RUN_SHA and at HEAD is bd0fe585d764825cf6b96f6edf04f884a343b28d; the baseline run measured the same script content as the branch.

- `git cat-file -e adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`: exit 0 (object present locally; no fetch needed)
- Blob at RUN_SHA: `bd0fe585d764825cf6b96f6edf04f884a343b28d`
- Blob at HEAD: `bd0fe585d764825cf6b96f6edf04f884a343b28d`

Result: identical
