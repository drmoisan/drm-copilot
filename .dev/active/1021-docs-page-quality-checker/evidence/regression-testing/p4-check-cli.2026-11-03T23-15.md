# P4 Check CLI and Dispatch Row - Issue #1021

Timestamp: 2026-11-03T23-15
Task: [P4-T3]
Command: `sh SCRATCH/issue-1021-failnames.sh tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1 issue-1021-p4-cli-check.txt`; `sh SCRATCH/issue-1021-failnames.sh tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1 issue-1021-p4-cli-invoke.txt` (PowerShell 7 `Invoke-Pester` with the repository run settings over each branch-current suite; `Run.PassThru`)
EXIT_CODE: 0
Output Summary: `DocsPageCheck.Tests.ps1` TOTAL=79 PASSED=79 FAILED=0 (68 from [P4-T1] and [P4-T2] plus 11 CLI tests); `Invoke-DocsCommand.Tests.ps1` TOTAL=47 PASSED=47 FAILED=0. Both FAILED_BLOCKS=0, FAILED_CONTAINERS=0. CI: CI-PESTER.

## Dispatch row

`git diff --unified=0 MERGE_BASE -- .claude/lib/docs/Invoke-DocsCommand.ps1` holds one hunk, `@@ -57,0 +58 @@ function Get-DocsCommandTable`, adding exactly the spec row directly under `# --- 1021: check ---` (module join `DocsPageCheck.psm1`, function `Invoke-DocsCheckCommand`, options `Profile = 'value'` and `Path = 'multi'`); no other line changed.

## 1020 tests (dispositions from `1020-test-dispositions`)

| Test | Disposition |
|---|---|
| `returns no finding for the committed table` | unchanged; passes with the `check` row |
| `carries the anchors 1020, 1021, 1022, 1023, 1024 and 1034 in order, with no placeholder or 1031 anchor` | unchanged; passes (the row sits after the 1021 anchor) |
| `exits 0 for -Help and reads nothing; with -Json the envelope has no findings and result usage` | unchanged; passes (membership-style bound) |
| `contains the check row directly under the 1021 anchor` | added (the membership assertion that `1020-test-dispositions` assigns to [P4-T3]); no existing test was edited |

## CLI contexts added to `DocsPageCheck.Tests.ps1`

Through `Invoke-DocsCommandCli -Command 'check'` with an in-memory `-Context`: `Test-DocsCommandTable` returns no finding and the table contains `check`; exit 0 with the text report line `check: pages=4 roots=1`; exit 1 for a findings set and for `DOCS_PROFILE_MISSING`; exit 2 with exactly one `DOCS_CLI_ARGUMENTS` and `result` null for a non-relative `-Profile`, a non-relative `-Path`, and a repeated `-Profile`; exit 3 with `DOCS_CLI_RUNTIME` for a context whose `ReadBytes` throws an `IOException`; `-Json` stdout byte-identical across two runs and across a reversed `ListFile` order, with findings equal to their `Get-DocsOrderedFinding` order; the `-Json` document of a clean, a findings and a usage-error run validates against the composed `docs-command-envelope` schema through `Test-DocsArtifactText -ArtifactKind 'docs-command-envelope'` (the CR-9 route recorded in `1020-precondition`).

Correction during the task: the result key assertion first compared the key order of the parsed (unordered) hashtable; it now compares the ordinal-sorted key set.
