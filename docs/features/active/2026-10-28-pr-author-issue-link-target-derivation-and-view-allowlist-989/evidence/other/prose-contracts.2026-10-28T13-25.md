# Prose Contracts and Tool-List Search (P4-T5)

Timestamp: 2026-10-28T13-25
Command: sh SCRATCH/issue-989-pt.sh (Invoke-PoshQCTest -ScanFolders tests/scripts/claude-runtime/pr-author-issue-link-contract.Tests.ps1, tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1, one process; counts from artifacts/pester/pester-junit.xml); git grep -n -F "gh pr edit *" -- . ":(exclude)docs/features" ":(exclude)extensions"
EXIT_CODE: 0

## Pester (artifacts/pester/pester-junit.xml)

- Total 58, passed 58, failed 0, skipped 0.
- PC-01, PC-02, PC-03, PC-04, PC-05 (skill), PC-05 (agent), PC-06 (skill), PC-06 (agent), PC-07: passed.
- AL-33 (frontmatter hooks block unchanged), AL-34 (every `gh`, `git`, `sha256sum`, and `date` code span in the agent and skill is an allowed form), AL-35: passed.
- AL-39 to AL-49: passed.

## Search for other pr-author tool lists

Fixed-string search for `gh pr edit *` over tracked files outside `docs/features/` and `extensions/`:

| Hit | Disposition |
|---|---|
| `.claude/agents/pr-author.md` (frontmatter `tools:` entry `"Bash(gh pr edit *)"`) | The pr-author tool list itself; it now also carries `"Bash(gh pr view *)"`. |

No other hit. No other tracked file outside the excluded trees carries a pr-author tool list, so no further entry is needed. The bundle copy under `extensions/` is updated by P5-T1.

Output Summary: 58 passed, 0 failed (all PC rows, AL-33 to AL-35, AL-39 to AL-49); one search hit, the pr-author agent tool list.
