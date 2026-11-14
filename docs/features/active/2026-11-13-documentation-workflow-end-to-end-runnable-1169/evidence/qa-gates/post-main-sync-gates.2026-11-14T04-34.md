# Post-main-sync parallel gates, second sync (issue #1169)

Timestamp: 2026-11-14T04-34
Context: origin/main (063504dc4, which carries the #1160 preimplementation-gate changes from PR #1174) was merged into the branch at 0f0db27cb. The four preimplementation-gate copies conflicted at the final allow and deny lines; both legs were kept (the #1160 bookkeeping staging leg first, then the #1169 docs-estate leg), and the deny text appends the cleanup, bookkeeping, and docs-estate suffixes. One two-line header comment in the Codex gate was condensed to one line so the file stays within the 500-line Codex hook cap (500 lines after the merge). The Claude and Codex gate copies are byte-identical to their bundle copies.

## PowerShell static check

Command: Invoke-Formatter (repository settings) and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 on both preimplementation-gate files
EXIT_CODE: 0
Output Summary: 0 formatter changes and 0 analyzer findings for each file.

## Pester gate

Command: sh SCRATCH/issue-1169-pester.sh postmerge2 (Invoke-PoshQCParallelTest over the item worktree root)
EXIT_CODE: 0
Output Summary:
- 8 shard processes, every shard exit 0, wall-clock 720.51 s.
- JUnit: 24065 tests, 24055 passed, 0 failed, 0 errors, 10 skipped.
- Repo-wide line coverage 95.94% (40128/41827).
- Per-file: .claude enforce-orchestration-preimplementation-gate.ps1 96.47%; .codex enforce-orchestration-preimplementation-gate.ps1 100.00%; .claude enforce-orchestration-preimplementation-gate-docs.ps1 97.04%; .codex enforce-orchestration-preimplementation-gate-docs.ps1 93.33%.

## pytest gate

Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch --cov-report=json:artifacts/python/coverage.json --cov-report=term-missing -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary: 16722 passed, 6 skipped, 0 failed; line 97.13% (34574/35595), branch 94.42% (12785/13540).
