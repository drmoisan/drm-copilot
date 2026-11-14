# hook-cleanup-context Suite Run (Issue #1026)

Timestamp: 2026-11-03T13-05
Command: sh SCRATCH/issue-1026-ps.sh SCRATCH/issue-1026-pester.txt tests/scripts/claude-hooks/hook-cleanup-context.Tests.ps1 (Invoke-Pester, JUnit to artifacts/pester/pester-junit.xml, coverage disabled)
EXIT_CODE: 0
Output Summary: JUnit testcases 40, passed 40, failed 0, skipped 0 (20 rows over each of the two repository copies, .claude and .codex). Every name quoted in P1-T3 appears in the JUnit testcase names, once per copy. Discovery-guard compliance (Get-EpicStateSuiteCompliance) reports 0 findings and no probe seam. File sizes: hook-cleanup-context.ps1 343 lines, the suite 255 lines.

Quoted names confirmed in the JUnit testcase names (count per name = 2, one per copy):

- `rejects **/*.md paths outside docs/ and .claude/agent-memory/`
- `compares the allowlist prefixes case-sensitively`
- `rejects operands with a .. segment or a character outside the plain set`
- `rejects a manifest with a wrong tool, a non-integer or wrong schema_version, an unparseable, future, or stale generated_at, or an empty run_id`
- `skips prunable, detached, and main-stanza records`
- `accepts both temporary-root spellings and rejects a path inside a registered worktree or the session root`
- `rejects a scratch path when a registered worktree lies under the temporary root`

Defects found and fixed during this task before the recorded run: a loop variable in `Test-CleanupScratchPath` shadowed the `-TemporaryRoot` parameter (case-insensitive names), and one test row built its array with the wrong operator precedence.
