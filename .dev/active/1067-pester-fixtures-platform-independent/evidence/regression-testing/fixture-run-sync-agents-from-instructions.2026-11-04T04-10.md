# Fixture Run: sync-agents-from-instructions.Tests.ps1 (P5-T9)

Timestamp: 2026-11-04T04-10
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=20 Passed=20 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 tests=20 failed=0 (baseline: 3 failed)
- Changes: portable root `sync-agents-from-instructions-root`; in contexts `Get-DiscoveredInstructionFile` and `Get-AgentContent ordering` every `FullName` is built with `Join-Path`, the `Substring` length is `$script:Repo.Length + 1`, and `-RepoRootParam` and the copilot-instructions path use the root. The expected relative-path lists and ordering assertions are unchanged.
- PROBE POSHQC_SKIP_SCRIPT_EXECUTION=1 after the run: the suite still leaks the variable; this is fixed in P6-T1.
