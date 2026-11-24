# Fail-Before - Exact-Name Root Files (remediation cycle 1)

Plan: remediation-plan.2026-11-24T08-32.md
Task: [P1-T2] [expect-fail]
Timestamp: 2026-11-24T09-47
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-lib/docs/DocsFamilyCheck.Tests.ps1 tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Invoke-PoshQCParallelTest: workers=2; wall-clock=106.82s; exit code=1. Shard 1 (Invoke-DocsCommand.Tests.ps1) exited 1: 48 passed, 1 failed. Shard 2 (DocsFamilyCheck.Tests.ps1) exited 3: 25 passed, 3 failed. No merged artifact was written (failed run); counts are read from artifacts/pester/parallel/shard-1 and shard-2 (shard.log and pester-junit.xml).
- Failing tests (exactly the four expected; every other test of the selection passed):
  1. `Read-DocsFamilyEvidence root-file name case` > `does not accept a wrong-case root security.md or codeowners from a case-insensitive TestFile`: "Expected $false, because a root security.md is not the exact name SECURITY.md, but got $true." The `RootFile` value is `$true`, so the case-insensitive seam satisfies the rule before the fix.
  2. `Read-DocsFamilyEvidence root-file name case` > `accepts the exact root names from a case-insensitive TestFile after one root listing`: "Expected exactly @('ListFile docs/security', 'TestFile SECURITY.md', 'TestFile CODEOWNERS', 'ListFile '), ... but got @('ListFile docs/security', 'TestFile SECURITY.md', 'TestFile CODEOWNERS')." No root listing is made before the fix.
  3. `Read-DocsFamilyEvidence root-file name case` > `reports DOCS_FAMILY_ROOT_FILE_MISSING for a wrong-case root CODEOWNERS beside an exact SECURITY.md`: "Expected 1, because only the wrong-case CODEOWNERS is missing, but got 0."
  4. `New-DocsCommandContext (read-only against committed files)` > `lists only the top-level repository-root files for the empty relative root`: "RuntimeException: DOCS_CONTEXT_PATH_INVALID: '' is not a repository-relative path." (thrown by `Get-DocsContextFullPath` from `Get-DocsContextFileList` before RP-2).
- Passing as expected before the fix: `makes no root listing when both root probes are negative`.
- No queue timeout on this run.
