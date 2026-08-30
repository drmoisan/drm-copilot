# Batch B08 gate — `orchestrator-state/OrchestratorStateCodexModelReceipts.psm1`

Timestamp: 2026-08-29T23-34

Command:
1. `mcp__drm-copilot__run_poshqc_format` against workspace root `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aee68cdb110fb5da7`
2. `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path"`
3. `mcp__drm-copilot__run_poshqc_analyze` against workspace root
4. `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path"`
5. `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts')"`
6. `pwsh -NoProfile -Command "Get-ChildItem -Path '.claude/state' -File -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force"`
7. `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`

EXIT_CODE: 0

Output Summary:
- Command 2 (observation source, final run): `Formatted: ` line count 0; `Already formatted: ` line count 428. Tree unchanged by the formatter. This matches `CombinedPreExistingFormatterDrift: none` recorded by `[P0-T14]`.
- Command 4 (observation source): output contains `PSScriptAnalyzer passed: no findings under C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aee68cdb110fb5da7`. AnalyzerClean: true
- Command 5 verbatim summary: `Tests Passed: 3873, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0`. Equal to the post-merge Pester baseline recorded by `[P0-T16]`.
- Command 5 coverage line: `Covered 94.24% / 0%. 10,723 analyzed Commands in 88 Files.`
- Command 6: files remaining under `.claude/state/` after removal: 0
- Command 7 exit code: 0, equal to `PostMergeParityExitCode: 0` recorded in `[P0-T12]`. `1 passed in 0.09s`

Comparand note (sequencing constraint 9): from batch B08 onward the parity comparand is
`PostMergeParityExitCode:` from `[P0-T12]`, not `BaselineParityExitCode:` from `[P0-T9]`, and the
Pester comparand is the `[P0-T16]` post-merge figure, not the `[P0-T7]` pre-merge figure.

Batch verification checks for the pair:
- Check 1 guard position: post-context line is `$ErrorActionPreference = 'Stop'`
- Check 2 column-0 imports lacking `-ErrorAction Stop`: 0
- Check 3 convention-sentence occurrences: 1
- Check 4 `git diff --no-index --quiet` module vs mirror: exit 0
- Column-0 `Import-Module` total: 2, unchanged from the pre-edit count
- Module line count after edit: 299 (cap 500)

Note on the batch-budget counter: `enforce-powershell-batch-budget.ps1` persists its per-session
counter under the invoking session repository's `.claude/state/`, not under the worktree being
edited. Gate command 6 clears the worktree path, which is what the parity walk in
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enumerates. The
session-repository counter file `powershell-batch-budget.default.json` was cleared separately
before this batch to satisfy sequencing constraint 2.

Note on the command 5 summary capture: `Invoke-PoshQCTest` emits the counts summary through
`Write-Information` as several separate records carrying ANSI colour codes. The verbatim line
recorded above is the ANSI-stripped concatenation of those records, which reproduces the format
string at `scripts/powershell/PoshQC/PoshQC.Testing.psm1:423`. Command 5 was issued twice: the
first issue truncated the captured summary before the `NotRun:` field, and the second issue with a
wider extraction produced the complete line recorded above. Both issues reported the same passed,
failed, and skipped counts.
