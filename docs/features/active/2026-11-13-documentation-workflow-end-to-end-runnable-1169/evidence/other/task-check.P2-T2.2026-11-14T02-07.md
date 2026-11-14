# Task Check P2-T2 (Remediation Cycle 1)

Timestamp: 2026-11-14T02-07
Command: git -C <item worktree> grep -c Get-OrchestrationDocsEstateFileText -- .claude .codex extensions tests; git -C <item worktree> grep -n "Mock Get-WorktreeResolutionGitFileText" -- tests (transparency grep); sh SCRATCH/issue-1169-tc.sh R1-P2-T2 "<four docs-leg copies, three docs suites>" "<eight suites>"
EXIT_CODE: 0
Output Summary:
- Changed files: .claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1 (Get-OrchestrationDocsEstateFileText deleted; Get-OrchestrationDocsEstateContextResult reads the profile with Get-WorktreeResolutionGitFileText -Path and declines with an empty suffix when the text is null or empty; .NOTES names Get-WorktreeResolutionGitFileText as a call-time dependency), byte-copied to the other three copies; the three docs suites (enforce-orchestration-preimplementation-gate.DocsEstate.Tests.ps1, codex-hooks/enforce-orchestration-preimplementation-gate-docs.Tests.ps1, docs-estate-workflow.EndToEnd.Tests.ps1): token removed from the baseline lists, each profile mock replaced by a Mock Get-WorktreeResolutionGitFileText filtered to a `$Path` ending in docs/documentation-estate/docs-profile.json after `\` is replaced with `/`, each Should -Invoke moved to the new seam with that filter and the same count, and one row per gate suite (`reads the docs profile once beneath the resolved root` and its `(codex)` twin) asserting one profile read beneath /synthetic-worktrees/docs-run.
- Token check: `git grep -c Get-OrchestrationDocsEstateFileText -- .claude .codex extensions tests` finds no match (exit 1, no output).
- The docs-leg file holds no `Get-Content`, `ReadAllText`, or `ReadAllLines` token (count 0); 347 lines.
- SHA-256 of all four copies: 1d0ea64d1f2455cc564d0f8c06d62b35bc2c104c435317d6683101f7da231c85 (equal).
- Transparency grep result: the only path-agnostic non-null mocks of Get-WorktreeResolutionGitFileText are in tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 (it dot-sources only the epic-scope file and never reaches the docs leg); EpicStateIsolation.Baseline.Helpers.ps1 mocks it only with an epic-checkpoint path filter; the three docs suites use the profile-path filter. No guard added, as the plan decided.
- Selection rule: suites the plan names (Discovery, both cleanup suites, the three docs suites, Parity) plus test files that name the changed docs-leg file (legacy-codex-hook-contracts.Tests.ps1).
- Format 0 findings, lint 0 findings (7 files); type check not applicable.
- Pester: 779 passed, 0 failed, 0 skipped.
