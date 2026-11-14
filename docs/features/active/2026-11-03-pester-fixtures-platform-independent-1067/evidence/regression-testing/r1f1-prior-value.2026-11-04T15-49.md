# R1-F1 restore keeps a pre-existing value (P1-T6)

Timestamp: 2026-11-04T15-49
Command: sh SCRATCH/issue-1067-prior.sh (section prior-value: pwsh -NoProfile -File SCRATCH/issue-1067-prior-value.ps1, which sets POSHQC_SKIP_SCRIPT_EXECUTION=prior, then runs Invoke-Pester with Run.PassThru over tests/scripts/dev-tools/link-feature-docs.Tests.ps1 and tests/scripts/dev-tools/link-parent-child.Tests.ps1 in the same process)
EXIT_CODE: 0

```
TOTAL Tests=43 Passed=43 Failed=0
PRIOR-VALUE-AFTER=prior
FAILED=0
```

The run also printed one `What if: Performing the operation "Update section content" on target "## Feature Docs".` host line, written by an existing `-WhatIf` test in `link-feature-docs.Tests.ps1`; it is not a failure.

Output Summary: PRIOR-VALUE-AFTER=prior and a failed count of 0 (43 of 43 passed); both suites restore the value that existed before their BeforeAll instead of removing it.
