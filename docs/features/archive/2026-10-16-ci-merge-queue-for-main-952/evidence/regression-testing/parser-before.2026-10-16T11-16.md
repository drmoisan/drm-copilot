# Parser Before (P4-T3, expect-fail)

Timestamp: 2026-10-16T11-16
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=[tests/scripts/claude-lib/ci-gate]
EXIT_CODE: 1
ExpectedExitCode: 1
Disposition: RAISED
Output Summary: Command exited with code 16.
Baseline (P0-T10 t-ci-gate): GREEN

Error text (verbatim): {"ok": false, "tool": "run_poshqc_test", "workspace_root": "WORKTREE_ROOT", "summary": "Command exited with code 16."}

Informational note (not an acceptance input): 15 rows are expected to fail (13 + 2 below); the child exit code is 16. Pester likely counts the failed `BeforeAll` of the parser suite as an additional failed block. Per the MCP observation rule, no count is asserted from the MCP result.

Supporting checks:
- Glob of `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`: No files found.
- `git grep -c -F -e "Invoke-MergeConfirmationParser" -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: exit 1, no output.

RowAttribution:
- tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1, all 13 Appendix G.2 cases: expected FAIL pre-change. Reason: the `BeforeAll` resolves and dot-sources `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`, which does not exist (Glob above), so every case in the Describe fails.
  1. maps MERGED with a merge commit to merged with the commit SHA and merge time
  2. throws when MERGED carries an empty merge commit oid
  3. throws when MERGED carries a null merge commit
  4. maps CLOSED to closed with an empty SHA and merge time
  5. maps OPEN with isInMergeQueue true to pending
  6. maps OPEN with a non-null autoMergeRequest and no isInMergeQueue field to pending
  7. maps OPEN with isInMergeQueue false and a null autoMergeRequest to not_queued
  8. maps OPEN with neither field present to not_queued
  9. throws on malformed JSON
  10. throws on an unrecognized state
  11. throws when the state field is absent
  12. emits compressed JSON with Status, MergeCommitSha, and MergedAt when -AsJson is set
  13. runs the script entry point when invoked directly
- tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1, both Appendix G.3 cases: expected FAIL pre-change. Reason: the core.json manifest has no `Invoke-MergeConfirmationParser` entry (git grep above exited 1).
  1. lists the merge confirmation parser path in core.json paths
  2. lists the merge confirmation parser path exactly once
- Pre-existing suites CiGate.Manifest.Tests.ps1 and Invoke-CiGateParser.Tests.ps1: expected PASS (unchanged).

CI job relied on later: poshqc / PowerShell QC.
