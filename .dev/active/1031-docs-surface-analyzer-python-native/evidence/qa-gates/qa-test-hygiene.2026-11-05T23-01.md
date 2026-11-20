# [P6-T16] Test hygiene: purity-hook decisions and temporary-file token search

Timestamp: 2026-11-05T23-01
Command: sh SCRATCH/issue-1031-purity.sh (PowerShell 7 `-NoProfile -File SCRATCH/issue-1031-purity.ps1`; dot-sources `.claude/hooks/check-python-test-purity.ps1` and `.claude/hooks/check-powershell-test-purity.ps1` and calls `Invoke-PythonTestPurityDecision` / `Invoke-PowerShellTestPurityDecision` with a PreToolUse envelope per file)
EXIT_CODE: 3
Output Summary: 15 Python test files (14 modules plus `conftest.py`) return no decision under a whole-file Write payload. Of 12 new or edited Pester files, 10 return no decision under a whole-file Write payload. The two edited guard files (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` and `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1`) return the `Start-Process` decision on whole-file content. The same decision is returned for their `MERGE_BASE` content: the guard's own `Start-Process` detection text and fixture predate this branch, and no branch-added line contains it. When the branch-added lines of each of the 8 edited Pester files are evaluated as an Edit payload (the content the hook evaluates for an edit), there are 0 decisions. Positive controls (`import tempfile`, `New-TemporaryFile`) each return a decision, so the evaluation can fail. The helper exits 3 for a whole-file decision and 1 for an added-content decision; it exited 3. Every file this feature created returns no decision, and no edit this feature made introduces a violation (S19).

## Purity decisions

| Payload | Files | Decisions |
|---|---|---|
| Write, whole file, new Python test files | 15 | 0 |
| Write, whole file, new Pester files (4) | 4 | 0 |
| Write, whole file, edited Pester and guard helper files (8) | 8 | 2 (pre-existing `Start-Process` text in the two guard files) |
| Edit, branch-added lines only, edited Pester and guard helper files | 8 | 0 |
| Write, `MERGE_BASE` content of the two guard files | 2 | 2 (pre-existing) |
| Positive controls (one per hook) | 2 | 2 |

`MERGE_BASE` = `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`.

## Temporary-file token search

Command: grep -r -i -n -e tempfile -e New-TemporaryFile -e TestDrive -e GetTempPath -e GetTempFileName -e 'env:TEMP' tests/scripts/claude-lib/docs
EXIT_CODE: 1
Output Summary: no output (grep exit 1 = no match) across 125 files under `TESTS`. This is a plain filesystem search, so it covers untracked files; `git status --porcelain --untracked-files=all -- tests/scripts/claude-lib/docs` lists no untracked file.
