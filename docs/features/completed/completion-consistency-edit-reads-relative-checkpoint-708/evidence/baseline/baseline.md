# Baseline Evidence — Issue #708

## P0-T1

Timestamp: 2026-09-27T08-29
Policy Order: CLAUDE.md, then repository tone policy, then general code-change and unit-test policies, then PowerShell-specific policies, then `.claude/rules` mirrors.
Files read (in order):

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.github/instructions/general-code-change.instructions.md`
4. `.github/instructions/general-unit-test.instructions.md`
5. `.github/instructions/powershell-code-change.instructions.md`
6. `.github/instructions/powershell-unit-test.instructions.md`
7. `.claude/rules/general-code-change.md`
8. `.claude/rules/general-unit-test.md`
9. `.claude/rules/quality-tiers.md`
10. `.claude/rules/powershell.md`
11. `.claude/rules/tonality.md`

Command: git status --porcelain -- .github .claude/rules CLAUDE.md
EXIT_CODE: 0
Output Summary: empty output; no policy file modified.

## P0-T2

Timestamp: 2026-09-27T08-29
Command: git branch --show-current
EXIT_CODE: 0
Output Summary: bug/completion-consistency-edit-reads-relative-checkpoint-708

## P0-T3

Timestamp: 2026-09-27T08-29
Command: git merge-base HEAD origin/main; git status --porcelain --untracked-files=all
EXIT_CODE: 0
MergeBase: 74b2ca0a2bdf8a0bf9a032433fef20831707b574
Output Summary: merge-base recorded above; porcelain listing (verbatim) is empty.

## P0-T4

Timestamp: 2026-09-27T08-29
Command: grep -n -F "CheckpointReader 'artifacts/orchestration" .claude/hooks/enforce-completion-consistency.ps1; grep -n -F "Resolve-EditedCheckpointContent" .claude/hooks/enforce-completion-consistency.ps1; grep -n -F "are allowed by this hook" .claude/hooks/enforce-completion-consistency.ps1
EXIT_CODE: 0
Output Summary:
- `300:    $onDisk = & $CheckpointReader 'artifacts/orchestration/orchestrator-state.json'`
- `262:function Resolve-EditedCheckpointContent {`
- `366:        $content = Resolve-EditedCheckpointContent -ToolInput $toolInput -CheckpointReader $CheckpointReader`
- `34:    are allowed by this hook, matching enforce-checkpoint-monotonic.ps1. For`

LINES_MATCH_SPEC: yes
REGION_STATE: literal-present

## P0-T5

Timestamp: 2026-09-27T08-29
Command: pwsh -NoProfile -Command 'Get-FileHash -Algorithm SHA256 -LiteralPath .claude/hooks/enforce-completion-consistency.ps1, extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1 | ForEach-Object { "SHA256=$($_.Hash)" }'
EXIT_CODE: 0
Output Summary:
- `.claude/hooks/enforce-completion-consistency.ps1` SHA256=659662C08537F12C0EC717BFBC5A0313E8795423B960A3C6C4D21A1F73E964F5
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1` SHA256=659662C08537F12C0EC717BFBC5A0313E8795423B960A3C6C4D21A1F73E964F5

BASELINE_BUNDLE_IDENTICAL: yes

## P0-T6

Timestamp: 2026-09-27T08-29
Command: pwsh -NoProfile -Command 'Import-Module PSScriptAnalyzer; $p = ".claude/hooks/enforce-completion-consistency.ps1"; $n = (Get-Content -Raw -LiteralPath $p) -replace "`r?`n", "`n"; $f = Invoke-Formatter -ScriptDefinition $n -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; "FORMAT_UNCHANGED=$($f -eq $n) $p"'
EXIT_CODE: 0
Output Summary: FORMAT_UNCHANGED=True .claude/hooks/enforce-completion-consistency.ps1

## P0-T7

Timestamp: 2026-09-27T08-29
Command: pwsh -NoProfile -Command 'Import-Module PSScriptAnalyzer; $p = ".claude/hooks/enforce-completion-consistency.ps1"; $r = @(Invoke-ScriptAnalyzer -Path $p -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information); "PSSA_FINDINGS $p=$($r.Count)"; $r | ForEach-Object { "PSSA_RULE=$($_.RuleName) line=$($_.Line)" }'
EXIT_CODE: 0
Output Summary: PSSA_FINDINGS .claude/hooks/enforce-completion-consistency.ps1=0 (no PSSA_RULE lines; no findings).

## P0-T8

Timestamp: 2026-09-27T08-29
Command: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders tests/scripts/claude-hooks'
EXIT_CODE: 0
Output Summary: Tests Passed: 1987, Failed: 0, Skipped: 0; LINE_PCT=91.34 for `.claude/hooks/enforce-completion-consistency.ps1` (LINE_COVERED=116 LINE_MISSED=11).

JUnit extraction (P0-T8 JUnit block run against `artifacts/pester/pester-junit.xml`), EXIT_CODE 0, printed lines:

- SUITE_TESTCASES enforce-completion-consistency.Tests.ps1=47
- SUITE_TESTCASES enforce-completion-consistency.Payload.Tests.ps1=7
- SUITE_TESTCASES PreToolUseSchema.Contract.Tests.ps1=15
- SUITE_TESTCASES enforce-completion-consistency.EditTarget.Tests.ps1=0 (expected at baseline; file not yet created)

Baseline failure set (FAILED_CASE lines): none.

Coverage extraction (P0-T8 coverage block run against `artifacts/pester/powershell-coverage.xml`), EXIT_CODE 0, printed line:

- LINE_COVERED=116 LINE_MISSED=11 LINE_PCT=91.34

`LINE_PCT_BELOW_85` was not printed.

## P0-T9

Timestamp: 2026-09-27T08-29
Command: git status --porcelain --ignored --untracked-files=all -- .claude; poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
EXIT_CODE: 0
Output Summary: `.claude` listing is empty (no untracked or ignored entries). Pytest summary line: `14 passed in 0.16s`. No BASELINE_PARITY_NOTE recorded.

## P0-T10

Timestamp: 2026-09-27T08-29
Command: wc -l .claude/hooks/enforce-completion-consistency.ps1
EXIT_CODE: 0
Output Summary: 415 lines (at most 500).
