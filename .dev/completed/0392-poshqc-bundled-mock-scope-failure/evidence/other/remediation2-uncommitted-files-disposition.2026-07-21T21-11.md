Timestamp: 2026-07-21T21-11

# Disposition Decision — Revision-1 Uncommitted Test Files

## Decision: KEEP (all three, unmodified from their revision-1 state)

The following three revision-1 test-file items are kept unmodified for revision 2:

1. `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1` (new file, 191 lines)
2. `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1` (new file, 141 lines)
3. `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1` (extension: +22 insertions)

## Rationale

Each of the three items was independently verified in revision 1 to correctly exercise its
assigned target lines of `PoshQC.Testing.psm1` when run in isolation. The defect that blocks
their coverage credit in a full bundled `Invoke-Pester` run is a coverage-measurement
interaction (repeated AST re-parse and re-dot-source of `PoshQC.Testing.psm1` via
`PoshQC.psm1`'s bootstrap loop on every `Import-Module -Force`), not a defect in the tests
themselves. This revision fixes that measurement defect rather than re-writing the tests, so
the tests are retained as-is. No further edits are made to these files as part of this task.

## git diff --stat output (proof no further edits made in this task)

```
 .../PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1    | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)
```

(The two new files are untracked, so they do not appear in `git diff --stat`; their current
line counts are 191 and 141 respectively, matching their revision-1 committed-to-working-tree
state. The only tracked modification is the 22-insertion extension to
`PoshQC.TestingSeamDefaults.Tests.ps1`, unchanged from revision 1.)
