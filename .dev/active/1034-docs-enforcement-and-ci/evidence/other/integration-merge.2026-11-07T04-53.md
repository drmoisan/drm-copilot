# Integration Merge - Issue 1034 Remediation Cycle 3 (P1-T2)

Timestamp: 2026-11-07T04-53
Command: sh SCRATCH/issue-1034-c2-suite.sh c3-p1t2 over the seven named suites; git diff -w --numstat MERGE_BASE HEAD -- .claude/lib/docs/Invoke-DocsCommand.ps1 .claude/lib/docs/DocsProfileCommands.psm1; pwsh SCRATCH/issue-1034-c3-table.ps1
EXIT_CODE: 0
Output Summary: PASS. 456 tests, 456 passed, 0 failed, 0 errored in the seven named suites. T11 holds: 0 deleted in each file, the `surface-delta` row sits directly under its anchor, and `Test-DocsCommandTable` returns no finding. Case B applies and needed no edit to either helper.

- `MERGE_COMMIT`: `4ad00fca2494b5c9555d1436799d8226756987fd`
- Merged tip: `e1f4d2e54dd877929f28fd5496231304d3c5308f`
- `MERGE_BASE` after the merge: `e1f4d2e54dd877929f28fd5496231304d3c5308f`

## Suite Results

| Suite | Total | Passed | Failed |
|---|---|---|---|
| `REVISION_SUITE` | 23 | 23 | 0 |
| `CLI_SUITE` | 48 | 48 | 0 |
| `tests/scripts/claude-lib/docs/DocsSurfaceDeltaCommands.Tests.ps1` | 15 | 15 | 0 |
| `HOOK_SUITE` | 149 | 149 | 0 |
| `COMPOUND_SUITE` | 71 | 71 | 0 |
| `HELPER_SUITE` | 115 | 115 | 0 |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | 35 | 35 | 0 |

## T11 Condition

`git diff -w --numstat MERGE_BASE HEAD`:

| File | Added | Deleted |
|---|---|---|
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | 67 | 0 |
| `.claude/lib/docs/DocsProfileCommands.psm1` | 1 | 0 |

The `surface-delta` row sits directly under `# --- 1034: surface-delta ---` in `Get-DocsCommandTable`. `Test-DocsCommandTable` over the 9 rows of `Get-DocsCommandTable` returns 0 findings. The stale `900008` anchor text of the criterion is N5, which stays deferred.

## Upstream Form of the InvokeProcess Member

Upstream changed the member from a scriptblock that called `Invoke-DocsProcess` by name to a closure over the root made with `GetNewClosure`, whose `[scriptblock] $Operation` parameter defaults to the private function `Invoke-DocsContextProcess`. That function runs `Invoke-DocsProcess` in the repository root. The four leading positional parameters (`FilePath`, `ArgumentList`, `StdinText`, `TimeoutSeconds`) and the result keys are unchanged.

## Case Applied

Case B of `## Integration Merge: Effect on This Item`: the member became a closure with the same positions and keys. It also adds an optional parameter and binds a working directory, which is the wording of Case A; Case B is applied because it is the stricter of the two, and the outcome of the two differs only in the comment review below.

- The bodies of `Resolve-DocsContextRevision` and `Read-DocsContextRevisionText` are unchanged: the positional call and `-C <Root>` still hold.
- `$invokeProcess` stays assigned above the `ResolveRevision` and `ReadRevisionText` closures.
- The comment above the two closures was reviewed and needs no correction. It states that the `InvokeProcess` parameter defaults to the member above, so every git call goes through `Invoke-DocsProcess`. That remains true through `Invoke-DocsContextProcess`, and the row 'routes the default wiring of <Member> through Invoke-DocsProcess once with git and a 30-second wait' passes for both members.

## Row Dispositions

| Suite | Row | Disposition |
|---|---|---|
| `REVISION_SUITE` | Rows that inject a stand-in | Unchanged, pass |
| `REVISION_SUITE` | 'routes the default wiring of <Member> through Invoke-DocsProcess once with git and a 30-second wait' | Unchanged, passes for `ResolveRevision` and `ReadRevisionText` |
| `CLI_SUITE` | 'exposes the same member names as the in-memory context, the four InvokeProcess parameters and the Operation seam' | Upstream's form kept, passes, so the merged member order equals `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1` |
| `CLI_SUITE` | 'forwards the four arguments unchanged to Invoke-DocsProcess and returns its result' | Upstream's, passes |
