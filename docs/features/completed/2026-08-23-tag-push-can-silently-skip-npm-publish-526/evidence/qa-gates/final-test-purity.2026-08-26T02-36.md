# Final QA Loop — Stage 7 — Test Purity

Timestamp: 2026-08-26T04-23

> Filename-stamp substitution note: the filename carries the fixed cycle stamp `2026-08-26T02-36`
> required by the plan, whose acceptance conditions assert exact filenames. The `Timestamp:` field
> records the actual execution stamp, `2026-08-26T04-23`. Same convention as Phases 0 through 3.

Command: `pwsh -NoProfile -Command 'Select-String -Path ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1, ./tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1, ./tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1, ./tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1 -Pattern "New-TemporaryFile|GetTempFileName|TestDrive|Start-Sleep|env:TEMP"'`

EXIT_CODE: 0

## Output Summary

### Prohibited temporary-path and wall-clock facilities — match counts per file

The scan covered the four release-tooling test files. **Every count is 0.**

| File | `New-TemporaryFile` | `GetTempFileName` | `TestDrive` | `Start-Sleep` | `$env:TEMP` |
|---|---|---|---|---|---|
| `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` | **0** | **0** | **0** | **0** | **0** |
| `tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1` | **0** | **0** | **0** | **0** | **0** |
| `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` | **0** | **0** | **0** | **0** | **0** |
| `tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1` | **0** | **0** | **0** | **0** | **0** |

This satisfies AC22 (no temporary-path facility referenced, no `Start-Sleep` called) across all four
files. All waits go through the mocked `Invoke-Sleep` seam, and all fixture content is supplied as
in-memory string literals.

### No real external process is invoked

A targeted search for real-process invocation forms — the call operator applied to `gh`, `npm`, or
`git`; `Start-Process`; `Invoke-Expression`; and a bare statement-initial `gh`, `npm`, or `git` —
returned **no match in any of the four files**. Every external interaction goes through the mocked
`Invoke-GhExe`, `Invoke-NpmExe`, `Invoke-GitExe`, and `Invoke-Sleep` seams. This is the second clause
of AC21.

### Classification of every textual `npm`, `gh`, and `git` match

Two of the four files contain no textual match at all:

- `tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1` — 0 matching lines.
- `tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1` — 0 matching lines.

The remaining two contain 14 and 16 matching lines respectively. Every one is classified below into
one of the four permitted categories: **mock payload**, **test title**, **mock declaration**, or
**assertion pattern**. A fifth category, **explanatory comment**, is used where the match sits in a
comment that documents the mocking rationale; a comment is inert text and invokes nothing.

#### `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` — 14 matching lines

| Line | Classification | Basis |
|---|---|---|
| 17 | mock payload | In-memory `gh run view` JSON literal; job/step named `Publish to npm` |
| 18 | mock payload | In-memory JSON literal, publish step `skipped` |
| 19 | mock payload | In-memory JSON literal, publish step absent |
| 29 | explanatory comment | States that external surfaces are mocked, so no real `gh`, `npm`, or wall-clock wait |
| 72 | mock payload | `Invoke-NpmExe` mock return value `npm error code E404` |
| 94 | test title | `passes the package operand in exact-version form to the npm seam` |
| 113 | mock payload | `Invoke-NpmExe` mock return value `npm error code E404` |
| 163 | test title | `does not invoke the npm seam when the registry-resolution check is skipped` |
| 165 | explanatory comment | Notes there is no npm version for check (c) to resolve on the extension path |
| 225 | mock payload | In-memory JSON literal deserialized by `ConvertFrom-Json` |
| 227 | assertion pattern | `-JobName 'Publish to npm' -StepName 'Publish to npm'` operand on a pure-function call |
| 234 | mock payload | In-memory JSON literal, conclusion `cancelled` |
| 236 | assertion pattern | Job/step name operand on a pure-function call |
| 351 | explanatory comment | Notes the npm seam never resolves so check (c) runs its full default budget |

#### `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` — 16 matching lines

| Line | Classification | Basis |
|---|---|---|
| 25 | explanatory comment | Names the contexts requiring mocks |
| 26 | explanatory comment | States that without the mocks a confirmed run would spawn a real `npm` process |
| 27 | explanatory comment | States the same for a real `gh` process and a disk read |
| 87 | test title | `returns 2 and invokes no git wrapper when ConfirmToken is 'no'` |
| 92 | mock declaration | `Mock -CommandName Invoke-GitExe` throwing if the seam is reached |
| 103 | mock declaration | `Mock -CommandName Invoke-GitExe` throwing if the seam is reached |
| 154 | assertion pattern | Asserts the captured `WorkflowFileName` equals `publish-mcp-npm.yml` |
| 332 | mock declaration | `Mock -CommandName Invoke-GitExe` throwing if the seam is reached |
| 363 | mock declaration | `Mock -CommandName Invoke-GitExe` throwing if the seam is reached |
| 373 | test title | `Context "git seam failures"` |
| 374 | test title | `returns 1 when 'git pull origin main' fails` |
| 393 | test title | `returns 1 when 'git tag' creation fails` |
| 414 | assertion pattern | `Should -Match "Failed to create git tag"` |
| 417 | test title | `returns 1 when 'git push' of a tag fails` |
| 438 | assertion pattern | `Should -Match "Failed to push git tag"` |
| 483 | explanatory comment | States that no real `git` executable is invoked and the run is deterministic |

No match in either file is an invocation. Every match is a string literal supplied to a mock, a test
or context title, a `Mock -CommandName` declaration naming a seam, an assertion pattern matched
against a captured message, or a comment.

### Mock-signature parity

One defect was found and corrected during this phase group, and is recorded here because it belongs
to the same purity family. The `Invoke-TagPublishVerification` mock in
`tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` still declared `[int]$IntervalSeconds` and
`[int]$MaxAttempts` — parameters the production function no longer has after task P2-T1 replaced them
with the six per-check budgets. The file was green only because `Invoke-ReleaseTagPushGuarded` passes
neither, so the stale parameters went unbound. The mock's `param()` block was brought into parity
with the production signature (`RunIntervalSeconds`, `RunMaxAttempts`, `StepIntervalSeconds`,
`StepMaxAttempts`, `NpmIntervalSeconds`, `NpmMaxAttempts`), and the file passes at 21 of 21 tests
afterwards. The two remaining mocks that declare `IntervalSeconds` and `MaxAttempts` — of
`Wait-ForWorkflowRun` and `Test-PublishStepConclusion` in
`tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` — were checked against the production
source and are in parity: both functions genuinely declare those two parameters.

The stage changed no file on disk beyond that correction, which was applied before stage 1 of this
loop iteration and was therefore covered by every stage of it. This is loop iteration 1.
