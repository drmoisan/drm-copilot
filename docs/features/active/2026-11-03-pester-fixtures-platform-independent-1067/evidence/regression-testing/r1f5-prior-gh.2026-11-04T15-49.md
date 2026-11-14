# R1-F5 restore keeps a prior gh definition (P1-T7)

Timestamp: 2026-11-04T15-49
Command: sh SCRATCH/issue-1067-prior.sh (section prior-gh: pwsh -NoProfile -File SCRATCH/issue-1067-prior-gh.ps1, which defines a global gh function returning issue-1067-prior-gh, runs Invoke-Pester with Run.PassThru over tests/scripts/dev-tools/link-feature-docs.Tests.ps1, then invokes the resolved gh function)
EXIT_CODE: 0

```
TOTAL Tests=21 Passed=21 Failed=0
PRIOR-GH-AFTER=issue-1067-prior-gh
FAILED=0
```

The run also printed one `What if:` host line from an existing `-WhatIf` test in the suite; it is not a failure.

Output Summary: PRIOR-GH-AFTER=issue-1067-prior-gh and a failed count of 0; the AfterAll restore branch (`Set-Item -Path Function:\global:gh`) reinstates the prior definition after the suite replaced it.
