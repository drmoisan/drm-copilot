# Final QA — Test Purity — P7-T9

Timestamp: 2026-08-26T02-05

Note on filename stamp: the plan fixes every evidence filename at `.2026-08-24T13-10.md`. This
execution ran on 2026-08-26, so the executor substituted its own `yyyy-MM-ddTHH-mm` stamp
(`2026-08-26T02-05`) in that same position. The path prefix and base name are unchanged.

Command:

```
grep -nE "New-TemporaryFile|GetTempFileName|TEMP|TestDrive|Start-Sleep" <the five test files>
grep -nE "npm |gh |git |Start-Process|Invoke-Expression" <the five test files>
grep -nE "Mock (-CommandName )?Invoke-(GhExe|NpmExe|Sleep)" tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1
```

EXIT_CODE: 1 for the first command (grep exits 1 on zero matches, which is the required outcome
here), 0 for the second and third.

## Scope

The five test files this change adds or modifies. The three production `.ps1` files enumerated by
P7-T8 are outside this check, as the task states.

## Check 1 — temporary-path facilities

Searched literals: `New-TemporaryFile`, `GetTempFileName`, `TEMP` (which also catches `$env:TEMP`),
`TestDrive`.

**Zero matches across all five files.** The grep returned exit code 1, its zero-match signal.

## Check 2 — `Start-Sleep`

Searched literal: `Start-Sleep`. Included in the same grep as check 1.

**Zero matches across all five files.** No test performs a wall-clock wait. Poll counts are asserted
through the `Invoke-Sleep` seam, which is mocked in
`tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` at line 70 with a body that discards
its `Seconds` argument and returns immediately.

## Check 3 — real external process invocations

A second search enumerated every line mentioning `npm`, `gh`, `git`, `Start-Process`, or
`Invoke-Expression` across the five files. Every match was classified. No match is a real external
process invocation:

| Match class | Example | Why it is not a real invocation |
|---|---|---|
| Mock return payloads | `return @{ Output = @('npm error code E404'); ExitCode = 1 }` | An in-memory hashtable built inside a `Mock -MockWith` body; no process starts |
| Test names | `It "passes the package operand in exact-version form to the npm seam"` | A string literal in a test title |
| Mock declarations | `Mock -CommandName Invoke-GitExe -MockWith { ... throw "git wrapper should not be invoked" }` | Replaces the seam; the throw is an assertion that the seam is not reached |
| Assertion patterns | `$script:capturedMessage \| Should -Match "Failed to push git tag"` | A regex matched against a captured in-memory string |
| Workflow-YAML text matches | `Where-Object { $_.Text -match 'npm publish' }` | A regex matched against workflow YAML read from disk as text; nothing is executed |

The two workflow-invariant suites read `.github/workflows/*.yml` from disk as text and assert over
its content. Reading a committed repository file is not an external process, not a network call, and
not a temporary file; it is the only way to assert a workflow invariant offline.

## Per-file verdicts

| # | Test file | Temp facility | `Start-Sleep` | Real `npm`/`gh`/`git` process | Verdict |
|---|---|---|---|---|---|
| 1 | `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` | none | none | none — all three seams mocked | **CLEAN** |
| 2 | `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` | none | none | none — 51 mock declarations cover every seam | **CLEAN** |
| 3 | `tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1` | none | none | none — pure function, no seam needed | **CLEAN** |
| 4 | `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` | none | none | none — reads workflow YAML as text | **CLEAN** |
| 5 | `tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1` | none | none | none — reads workflow YAML as text | **CLEAN** |

All five verdicts are clean.

## Supporting detail

**File 1** mocks all three wrapper seams in its `BeforeAll`: `Invoke-GhExe` (line 46),
`Invoke-NpmExe` (line 61), and `Invoke-Sleep` (line 70), with a per-test `Invoke-NpmExe` override at
line 119. It dot-sources `scripts/dev-tools/Invoke-ReleaseVerification.ps1` rather than executing it,
so the dot-source guard keeps the entry-point block from running. All JSON payloads are in-memory
string literals deserialized in the test; all `.codex/config.toml` fixture content is supplied as an
in-memory string.

**File 2** declares 51 mocks. Per P3-T2, every context that invokes `Invoke-ReleaseTagPushGuarded`
with a confirmed token declares mocks for `Test-NpmVersionResolved`, `Invoke-TagPublishVerification`,
and `Get-CodexPinnedMcpVersion`, so no confirmed-token path reaches a real `npm` process, a real `gh`
process, or a filesystem read of `.codex/config.toml`. Several contexts additionally mock
`Invoke-GitExe` with a body that throws if reached, which asserts non-invocation rather than
permitting it.

**File 3** needs no mock at all. `Get-UnpublishedTagVersion` is a pure set difference over two string
collections; the tests supply in-memory arrays and assert the result. The file dot-sources the
production module so Pester attributes coverage to the on-disk file.

**Files 4 and 5** read their workflow file from disk and assert over parsed text. They declare no
mocks because they invoke nothing.

## Suite-level corroboration

The full Pester suite (3638 passed, 0 failed, 9 skipped, recorded by P7-T3) completed in 109.71
seconds for roughly 3600 tests. A suite containing a real `npm view`, a real `gh run list`, or a real
`Start-Sleep` poll would exhibit wall-clock cost far above that. The absence of such cost corroborates
the textual verdicts above.

Output Summary: All five test files added or modified by this change are clean on all three purity
checks. Zero references to `New-TemporaryFile`, `GetTempFileName`, the TEMP environment variable, or
`TestDrive`; zero calls to `Start-Sleep`; and zero real invocations of `npm`, `gh`, or `git` — every
external interaction goes through a mocked wrapper seam, and every `npm`/`gh`/`git` textual match was
classified as a mock payload, a test name, a mock declaration, an assertion pattern, or a
workflow-YAML text match. This satisfies AC21 and AC22.
