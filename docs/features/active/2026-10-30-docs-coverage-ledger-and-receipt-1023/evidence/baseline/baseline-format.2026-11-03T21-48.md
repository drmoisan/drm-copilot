# PowerShell Formatting Baseline ([P0-T4])

Timestamp: 2026-11-03T21-48
Command: sh SCRATCH/issue-1023-format-check.sh (PowerShell 7: SCRATCH/issue-1023-format-check.ps1 compares Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 with the text of every .ps1 and .psm1 under .claude/lib/docs and tests/scripts/claude-lib/docs, and compares git status --porcelain --untracked-files=all before and after; nothing is written to the tree)
EXIT_CODE: 0
Output Summary: CHECKED=23, DIFFERING=0, STATUS_UNCHANGED=True. No pre-existing formatting drift in the 1020 modules, the entry script, or the 1020 suites; nothing to record as pre-existing.

## Output

```text
CHECKED=23
DIFFERING=0
STATUS_UNCHANGED=True
```

Checked-file count: 23 (9 under `.claude/lib/docs`, 14 under `tests/scripts/claude-lib/docs` including `Docs.TestSupport.psm1` and `fixtures/DocsAnalyzerFixture.psm1`). Differing-file count: 0.
