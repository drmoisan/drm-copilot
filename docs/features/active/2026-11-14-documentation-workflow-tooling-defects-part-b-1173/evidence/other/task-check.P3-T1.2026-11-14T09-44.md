# Task Check P3-T1

Timestamp: 2026-11-14T09-44
Command: sh SCRATCH/issue-1173-p0t1.sh issue-1173-static-p3t1.txt (Invoke-Formatter check and PSScriptAnalyzer with pssa.settings.psd1); sh SCRATCH/issue-1173-taskcheck.sh issue-1173-sel-p3t1.txt p3t1-before / p3t1-after (New-PesterConfiguration, Run.Path = selection, Run.Exit = $true)
EXIT_CODE: 0
Output Summary:
- Changed files: .claude/lib/docs/DocsJson.psm1 (new exported Get-DocsTextSha256Hex -Bytes: CRLF and lone CR mapped to LF at byte level, BOM kept, then the DiscoveryEncoding SHA-256; LF-only input takes the raw-byte path; CR-bearing input is copied in runs between CR bytes; function help and module .DESCRIPTION), its bundle copy (cmp: byte-identical), tests/scripts/claude-lib/docs/DocsJson.Tests.ps1.
- Selection rule: mirrored test of the changed module. The new function changes no existing behavior; the call-site replacement and its dependents are P3-T2.
- Static (3 files): the first run raised a PSScriptAnalyzer NullReferenceException on the module while it used [System.Array]::Resize with a [ref] argument; replaced with an explicit copy into a right-sized array; recorded pass: format drift 0, PSScriptAnalyzer findings 0, exit 0.
- Fail-before (new cases written first, function absent): exit 2; 2 failed (Get-DocsTextSha256Hex not found).
- Pass-after: exit 0; 29 passed, 0 failed, 0 skipped. Cases: LF, CRLF, lone-CR and mixed byte forms give one hash equal to the raw-byte hash of the LF form; empty, LF-only and BOM-led content equal Get-DocsBytesSha256Hex; a BOM is kept.
