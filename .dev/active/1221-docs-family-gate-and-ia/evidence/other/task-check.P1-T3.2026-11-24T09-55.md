# Task Check - [P1-T3]

Plan: remediation-plan.2026-11-24T08-32.md
Timestamp: 2026-11-24T09-55
Command: sh SCRATCH/issue-1221-static.sh <changed files>; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-lib/docs tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1 tests/scripts/harness/HarnessInventory.Tests.ps1; sha256sum <both copies>
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Changed files: .claude/lib/docs/Invoke-DocsCommand.ps1 (`Get-DocsContextFileList`: an empty `RelativeRoot` returns the top-directory file names of the repository root, ordinal-sorted, via `[System.IO.Directory]::EnumerateFiles` with `TopDirectoryOnly`; every other value still passes `Get-DocsContextFullPath`; `.SYNOPSIS` and the `New-DocsCommandContext` `.DESCRIPTION` ListFile sentence updated), and its byte copy extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/Invoke-DocsCommand.ps1 (written by `cp`, not Write or Edit).
- Selection and rule: `tests/scripts/claude-lib/docs/` (the mirrored test `Invoke-DocsCommand.Tests.ps1` and every test that dot-sources `Invoke-DocsCommand.ps1`), plus `docs-authoring-roles.Skills.Tests.ps1` and `HarnessInventory.Tests.ps1`, which name the file (plan task text).
- Format (check-only): exit 0, 0 of 2 files need formatting. Analyzer: exit 0, 0 findings. Logical lines: 632 in each copy.
- Hash equality: both copies sha256 f32cd54964fa3c3ca63fcd3dd8e505ad898c306bb11fbddc17a714b1ef7923e1.
- Pester: Invoke-PoshQCParallelTest workers=8; wall-clock=308.88s; exit 1; 2832 passed, 3 failed (shard logs; no merged artifact on a failed run). The three failures are exactly the remaining P1-T2 expect-fail cases in `Read-DocsFamilyEvidence root-file name case`: `does not accept a wrong-case root security.md or codeowners from a case-insensitive TestFile`, `accepts the exact root names from a case-insensitive TestFile after one root listing`, `reports DOCS_FAMILY_ROOT_FILE_MISSING for a wrong-case root CODEOWNERS beside an exact SECURITY.md`.
- `It 'lists only the top-level repository-root files for the empty relative root'` passed. `It 'tests existence and lists files sorted'` and `It 'rejects a non-relative path in <_>'` passed unchanged; `DocsWriteBoundary.Tests.ps1`, `DocsLedgerCommands.Tests.ps1`, and the skill and inventory suites passed.
- No queue timeout on this run. Not a gate; no coverage is claimed from this run.
