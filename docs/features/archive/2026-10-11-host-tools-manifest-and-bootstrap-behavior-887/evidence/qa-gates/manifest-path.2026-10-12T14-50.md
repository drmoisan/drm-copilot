# Manifest Path Unnormalized (Issue 887)

Timestamp: 2026-10-12T14-50
Command: git grep -n -F "ChildPath '..\host-tools.manifest.json'" -- scripts/dev-tools/HostTooling.psm1; git diff -U0 origin/main...HEAD -- tests/scripts/dev-tools/HostTooling.Tests.ps1
EXIT_CODE: 0
Output Summary:
- git grep printed exactly one line: `scripts/dev-tools/HostTooling.psm1:24:    return (Join-Path -Path $PSScriptRoot -ChildPath '..\host-tools.manifest.json')` (Get-HostToolsManifestPath).
- Hunk headers in the -U0 diff (all of them):
  - `@@ -37,0 +38,5 @@ Describe 'Get-HostToolsManifestPath' {`
  - `@@ -142,0 +148,4 @@ Describe 'Invoke-HostNativeCommand' {`
  - `@@ -159,0 +169,27 @@ Describe 'Invoke-HostNativeCommand' {`
- Every old-side range has length 0 and so covers no line; no old-side range overlaps lines 31-37. The existing `*scripts/dev-tools/../host-tools.manifest.json` assertion is unchanged (AC-5).
