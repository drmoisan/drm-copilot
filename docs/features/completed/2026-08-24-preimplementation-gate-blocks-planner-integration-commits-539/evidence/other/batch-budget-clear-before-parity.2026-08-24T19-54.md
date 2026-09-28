# Batch-Budget Whole-Directory Clear Before Push-Down Parity — issue #539 [P4-T5]

Timestamp: 2026-08-24T19-54

Command:

```
pwsh -NoProfile -Command 'Get-ChildItem -Path .claude/state -File -Force -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("PRE-CLEAR " + $_.FullName + " " + (Get-Content -Raw $_.FullName)); Remove-Item -LiteralPath $_.FullName -Force }'
pwsh -NoProfile -Command 'Get-ChildItem -Path .claude/state -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name'
```

EXIT_CODE: 0

## Scope of this clear

This is the WHOLE-DIRECTORY clear, deliberately broader than the narrow
`powershell-batch-budget.*.json` filter used by the four inter-phase resets
([P2-T7], [P3-T7], [P4-T9], [P5-T9]). `.claude/state/` is gitignored in its entirety
(`.gitignore` entry `.claude/state/`) and holds no tracked file, while
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enumerates every file
under repo `.claude/` from the filesystem, excluding only `.claude/settings.local.json` and
`.claude/agent-memory/**`. Any resident file therefore fails the parity assertion with
`Repo file missing from bundle`, whichever budget hook wrote it.

## Deleted files

Exactly one file was enumerated and deleted:

| Full path | Kind | prodFiles count | testFiles count |
| --- | --- | --- | --- |
| `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adcd2df193c6616e5\.claude\state\python-batch-budget.default.json` | Python batch-budget state | 3 | 0 |

Pre-clear content of the deleted file:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    "C:/Users/DANMOI~1/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot/bad11e1e-20fb-4715-8e4c-637b56f54dc7/scratchpad/cov.py",
    "C:/Users/DANMOI~1/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot/bad11e1e-20fb-4715-8e4c-637b56f54dc7/scratchpad/cov_extract.py",
    "C:/Users/DANMOI~1/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot/bad11e1e-20fb-4715-8e4c-637b56f54dc7/scratchpad/junit_summary.py"
  ],
  "testFiles": []
}
```

The three recorded `prodFiles` entries are scratchpad-resident throwaway extraction scripts from
the Phase 0 through Phase 3 coverage-extraction steps, not repository production files.

No `powershell-batch-budget.*.json` file was present. The Phase 4 production-file writes
([P4-T1], [P4-T2], [P4-T3]) were performed with `Copy-Item` through the shell rather than the
file-editing tool, so the PowerShell budget hook recorded no state for them.

## Post-clear directory listing

The listing command emitted no names. `.claude/state/` contains zero files.

Output Summary: PASS. One file enumerated and deleted — `python-batch-budget.default.json`
(prodFiles 3, testFiles 0). Zero `powershell-batch-budget.*.json` files were present. The
post-clear listing is empty, so `.claude/state/` contains zero files immediately before
[P4-T6] runs. Both commands exited 0.
