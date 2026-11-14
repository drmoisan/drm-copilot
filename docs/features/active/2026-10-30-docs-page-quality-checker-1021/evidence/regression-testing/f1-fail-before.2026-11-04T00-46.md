# F1 Fail-Before - issue #1021, remediation cycle 1

Timestamp: 2026-11-04T00-46
Task: [P1-T1] [expect-fail]
Command: `sh SCRATCH/issue-1021-runfile.sh tests/scripts/claude-lib/docs/DocsPageFrontMatter.Tests.ps1` (one PowerShell 7 process, `Invoke-Pester` with `Run.PassThru`; per-case values from `sh SCRATCH/issue-1021-run.sh SCRATCH/issue-1021-probe.ps1` against the unmodified module)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: Pester total=109 passed=108 failed=1. The one failure is the new test `ConvertFrom-DocsPageYamlScalar value forms.resolves a flow sequence whose double-quoted item ends in an escaped backslash`, failing on its first assertion (`Expected $true, but got $false.` for `["a\\", b]`). The new case `["a\", b]` of `reports the construct <Construct> for <Text>` passes. The runner exits 0 because `Invoke-Pester` runs without `Run.Exit`; the result comes from the PassThru counts.

## Per-case results before [P1-T2]

| Case | Form | Observed before the fix | Result against the new assertion |
|---|---|---|---|
| `["a\\", b]` | value | Ok False, Construct `unclosed flow sequence` | FAIL (expected Ok True, items `a\`, `b`) |
| `tags: ["a\\", b]` | block | `DOCS_PAGE_FRONT_MATTER_UNSUPPORTED` | FAIL (expected no code) |
| `["a\\\"", b]` | value | Ok True, items `a\"`, `b` | PASS (regression guard; the one-character look-back keeps the item open at the escaped quote and closes it at the next quote) |
| `tags: ["a\\\"", b]` | block | no code, items `a\"`, `b` | PASS (regression guard) |
| `["a\", b]` | value, construct test | Ok False, Construct `unclosed flow sequence` | PASS |
| `tags: ["a\", b]` | block | `DOCS_PAGE_FRONT_MATTER_UNSUPPORTED` | PASS |

The expect-fail outcome is met: the new test fails before [P1-T2] because of the `["a\\", b]` case, as the preflight-corrected acceptance of [P1-T1] states.
