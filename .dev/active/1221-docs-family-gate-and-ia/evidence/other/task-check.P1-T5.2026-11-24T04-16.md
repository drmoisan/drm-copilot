# Task Check - P1-T5 (Issue #1221)

Timestamp: 2026-11-24T04-16
Command: sh SCRATCH/issue-1221-static-ps.sh check|write <files>; sh SCRATCH/issue-1221-pssa-one.sh <file>; cmp <module> <bundle copy>; sh <worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <selection>
EXIT_CODE: 0
Output Summary: Format 0 files needing format (after one formatter write of the new test file); analyzer 0 findings on the module, its bundle copy, and the new test file; bundle copy byte-identical. Pester: the 28-file selection passed except 2 cases of the new test file (test-side defects, fixed); the re-run of the new file and DocsValidateCommands.Tests.ps1 passed 32 of 32.

## Changed Files

- `.claude/lib/docs/DocsValidateCommands.psm1` (`Invoke-DocsValidateCommand`: in docs-complete mode, after the input read, `Read-DocsFamilyEvidence` over `$Context.TestFile` and `$Context.ListFile`, passed as `-FamilyEvidence`; `DocsFamilyCheck.psm1` import; help note)
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsValidateCommands.psm1` (byte-identical)
- `tests/scripts/claude-lib/docs/DocsValidateCommands.Families.Tests.ps1` (new; drafted by the earlier executor run in SCRATCH, placed and completed on resume)

## Selection and Rule

- Plan P1-T5 acceptance: the new file, `DocsValidateCommands.Tests.ps1`, `DocsLedgerCommands.Properties.Tests.ps1`; plus every test file that names `DocsValidateCommands` or `Invoke-DocsCommand.ps1` (`grep -rlE "DocsValidateCommands|Invoke-DocsCommand\.ps1" tests --include=*.Tests.ps1`) and `Docs.Manifest.Tests.ps1`: 28 files (SCRATCH/issue-1221-sel-p1t5b.txt).
- Removed from the local selection because the launcher refuses the integration lane (suffix `integration.tests.ps1`): `DocsCompleteIntegration.Tests.ps1`, `DocsReferenceIntegration.Tests.ps1` (CI evidence; see `lane-deviation.2026-11-23T13-34.md`).

## Commands and Exit Codes

| Step | Command | EXIT_CODE | Result |
|---|---|---|---|
| Format | static-ps check (new test file) | 1 | 1 file needing format (assignment alignment) |
| Format write | static-ps write (new test file) | 0 | aligned; re-check FILES_NEEDING_FORMAT=0 |
| Analyze | pssa-one per file (module, bundle, test) | 0 | FINDINGS=0 each |
| Pester attempt (29 files) | launcher pester -TestPath | 2 | TEST_EXECUTION_POLICY_BLOCKED: integration lane (DocsReferenceIntegration.Tests.ps1) |
| Pester (28 files) | launcher pester -TestPath | 1 | shards 1-7 green; shard 8: 60 passed, 2 failed, both in the new file |
| Pester re-run after the fix | launcher pester -TestPath (new file, DocsValidateCommands.Tests.ps1) | 0 | TESTS=32 FAILURES=0 |

## Failures Fixed (test side only)

1. `exits 1 with a failing receipt and DOCS_FAMILY_PAGE_MISSING for a missing family`: the helper `Get-TestReadLog` returns its list with a leading comma, so piping the call straight into `Should -Contain` passed the list as one item; the result is now assigned first.
2. `keeps exit 0 and a passing receipt when the family findings are info only`: the expected order was wrong; `Get-DocsOrderedFinding` orders the pointer `/legacy_exclusions` before `/required_families/0/exclusion`. The expectation now follows the production order; no assertion was removed.
