# QA Gate Evidence — Issue #708

## P2-T6

Timestamp: 2026-09-27T08-45
Command: pwsh -NoProfile -Command 'Copy-Item -LiteralPath .claude/hooks/enforce-completion-consistency.ps1 -Destination extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1 -Force; Get-FileHash -Algorithm SHA256 -LiteralPath .claude/hooks/enforce-completion-consistency.ps1, extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1 | ForEach-Object { "SHA256=$($_.Hash)" }'
EXIT_CODE: 0
Output Summary:
- `.claude/hooks/enforce-completion-consistency.ps1` SHA256=F9CA16BFBD90E0A2223AB2222C0B7B8F0629DC4D835FF18AD319E407F39F07A5
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1` SHA256=F9CA16BFBD90E0A2223AB2222C0B7B8F0629DC4D835FF18AD319E407F39F07A5
- The two values are equal; the bundled copy is byte-identical.

## P4-T1

Timestamp: 2026-09-27T08-52
Command: pwsh -NoProfile -Command 'Import-Module PSScriptAnalyzer; foreach ($p in @(".claude/hooks/enforce-completion-consistency.ps1", "tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1")) { $n = (Get-Content -Raw -LiteralPath $p) -replace "`r?`n", "`n"; $f = Invoke-Formatter -ScriptDefinition $n -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; "FORMAT_UNCHANGED=$($f -eq $n) $p" }'
EXIT_CODE: 0
Output Summary:
- Route step `mcp__drm-copilot__run_poshqc_format` (scan_folders `.claude/hooks`, `tests/scripts/claude-hooks`): returned; summary "Ran bundled PoshQC format against '<repo>' with 2 selected scan folder(s)."
- HASH_BEFORE: hook SHA256=F9CA16BFBD90E0A2223AB2222C0B7B8F0629DC4D835FF18AD319E407F39F07A5; test SHA256=50847A0BE412140E9841CBDC2C6B28DEA3A642363A529D37B5534BDF0D2BC21C
- HASH_AFTER_ROUTE: hook SHA256=F9CA16BFBD90E0A2223AB2222C0B7B8F0629DC4D835FF18AD319E407F39F07A5; test SHA256=50847A0BE412140E9841CBDC2C6B28DEA3A642363A529D37B5534BDF0D2BC21C (equal to HASH_BEFORE for both files)
- FORMAT_UNCHANGED=True .claude/hooks/enforce-completion-consistency.ps1
- FORMAT_UNCHANGED=True tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1
- `git status --porcelain --untracked-files=all`: empty. No pre-existing formatter drift restored.

## P4-T2

Timestamp: 2026-09-27T08-53
Command: pwsh -NoProfile -Command 'Import-Module PSScriptAnalyzer; foreach ($p in @(".claude/hooks/enforce-completion-consistency.ps1", "tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1")) { $r = @(Invoke-ScriptAnalyzer -Path $p -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information); "PSSA_FINDINGS $p=$($r.Count)"; $r | ForEach-Object { "PSSA_RULE=$($_.RuleName) line=$($_.Line)" } }'
EXIT_CODE: 0
Output Summary:
- Route step `mcp__drm-copilot__run_poshqc_analyze`: returned; summary "Ran bundled PoshQC analyze against '<repo>' with 2 selected scan folder(s)."
- PSSA_FINDINGS .claude/hooks/enforce-completion-consistency.ps1=0
- PSSA_FINDINGS tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1=0
- No PSSA_RULE line printed.

## P4-T3

Timestamp: 2026-09-27T08-53
Command: not applicable (PowerShell has no type-check stage per .claude/rules/powershell.md)
EXIT_CODE: 0
Output Summary: type checking is not applicable to PowerShell

## P4-T4

Timestamp: 2026-09-27T08-55
Command: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders tests/scripts/claude-hooks'
EXIT_CODE: 0
Output Summary: baseline LINE_PCT=91.34 (P0-T8); post-change LINE_PCT=92.13; difference +0.79. Tests Passed: 1999, Failed: 0, Skipped: 0.
- Route step `mcp__drm-copilot__run_poshqc_test` (scan_folders `tests/scripts/claude-hooks`): returned; summary "Ran bundled PoshQC test against '<repo>' with 1 selected scan folder(s)."
- JUnit extraction (P0-T8 block, unchanged), EXIT_CODE 0:
  - SUITE_TESTCASES enforce-completion-consistency.Tests.ps1=47 (P0-T8: 47)
  - SUITE_TESTCASES enforce-completion-consistency.Payload.Tests.ps1=7 (P0-T8: 7)
  - SUITE_TESTCASES PreToolUseSchema.Contract.Tests.ps1=15 (P0-T8: 15)
  - SUITE_TESTCASES enforce-completion-consistency.EditTarget.Tests.ps1=12
  - No FAILED_CASE line printed (baseline failure set is also empty).
- Coverage extraction (P0-T8 block, unchanged), EXIT_CODE 0:
  - LINE_COVERED=117 LINE_MISSED=10 LINE_PCT=92.13
  - `LINE_PCT_BELOW_85` not printed; 92.13 -ge 85 holds.

## P4-T5

Timestamp: 2026-09-27T08-56
Command: pwsh -NoProfile -Command '[xml]$x = Get-Content -Raw -LiteralPath artifacts/pester/powershell-coverage.xml; $pk = @($x.SelectNodes("/report/package") | Where-Object { $n = ($_.GetAttribute("name") -replace "\\", "/").TrimEnd("/"); ($n -eq ".claude/hooks" -or $n.EndsWith("/.claude/hooks")) -and $n -notlike "*claude-customizations*" }); $sf = @($pk | ForEach-Object { $_.SelectNodes("sourcefile") } | Where-Object { $_.GetAttribute("name") -eq "enforce-completion-consistency.ps1" }); foreach ($nr in @(308, 374)) { $l = @($sf[0].SelectNodes("line") | Where-Object { [int]$_.GetAttribute("nr") -eq $nr }); if ($l.Count -eq 0) { "CHANGED_LINE $nr ci=absent" } else { "CHANGED_LINE $nr ci=$($l[0].GetAttribute("ci"))" } }'
EXIT_CODE: 0
Output Summary:
- grep located `& $CheckpointReader $CheckpointPath` at line 308 and `-CheckpointPath $filePath` at line 374.
- CHANGED_LINE 308 ci=1
- CHANGED_LINE 374 ci=1
- Both changed executable lines are covered.

## P4-T6

Timestamp: 2026-09-27T08-57
Command: pwsh -NoProfile -Command 'Get-FileHash -Algorithm SHA256 -LiteralPath .claude/hooks/enforce-completion-consistency.ps1, tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1 | ForEach-Object { "SHA256=$($_.Hash)" }'
EXIT_CODE: 0
Output Summary: 1 pass; no restarts.
- Before P4-T1 (final pass): hook SHA256=F9CA16BFBD90E0A2223AB2222C0B7B8F0629DC4D835FF18AD319E407F39F07A5; test SHA256=50847A0BE412140E9841CBDC2C6B28DEA3A642363A529D37B5534BDF0D2BC21C
- After P4-T5 (final pass): hook SHA256=F9CA16BFBD90E0A2223AB2222C0B7B8F0629DC4D835FF18AD319E407F39F07A5; test SHA256=50847A0BE412140E9841CBDC2C6B28DEA3A642363A529D37B5534BDF0D2BC21C
- Before and after hashes are equal for both files.

## P4-T7

Timestamp: 2026-09-27T08-58
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
EXIT_CODE: 0
Output Summary: `14 passed in 0.11s`
D9_OPTION: a
- Pre-deletion listing (`git status --porcelain --ignored --untracked-files=all -- .claude`):
  - `!! .claude/state/powershell-batch-budget.worktree-agent-a580ecd7399280c2a-36dcc9e4.json`
- Deleted (individually, via `pwsh -NoProfile -Command 'Remove-Item -LiteralPath .claude/state/powershell-batch-budget.worktree-agent-a580ecd7399280c2a-36dcc9e4.json'`, EXIT_CODE 0):
  - `.claude/state/powershell-batch-budget.worktree-agent-a580ecd7399280c2a-36dcc9e4.json`
- Post-deletion listing: empty. The deleted path does not appear.
- No PowerShell file was written after this step.

## P4-T8

Timestamp: 2026-09-27T08-59
Command: pwsh -NoProfile -Command 'Get-FileHash -Algorithm SHA256 -LiteralPath .claude/hooks/enforce-completion-consistency.ps1, extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1 | ForEach-Object { "SHA256=$($_.Hash)" }'
EXIT_CODE: 0
Output Summary:
- `.claude/hooks/enforce-completion-consistency.ps1` SHA256=F9CA16BFBD90E0A2223AB2222C0B7B8F0629DC4D835FF18AD319E407F39F07A5
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1` SHA256=F9CA16BFBD90E0A2223AB2222C0B7B8F0629DC4D835FF18AD319E407F39F07A5
- The two values are equal.

## P5-T1

Timestamp: 2026-09-27T09-01
Command: wc -l .claude/hooks/enforce-completion-consistency.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1 tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1
EXIT_CODE: 0
Output Summary:
- 423 `.claude/hooks/enforce-completion-consistency.ps1`
- 423 `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1`
- 227 `tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1`
- Each count is at most 500.

## P5-T2

Timestamp: 2026-09-27T09-01
Command: grep -c -E "TestDrive|New-TemporaryFile|Set-Location|Push-Location|GetTempPath|Set-Content|Out-File|New-Item|Get-Content|Test-Path|Get-ChildItem|origin/main" tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1; grep -c -E "[A-Za-z]:[\\\\/]" tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1
EXIT_CODE: 1
Output Summary: both commands print `0` (grep exits 1 on a zero count; the printed `0` is the gate value). No forbidden API token and no drive-letter path is present.

## P5-T3

Timestamp: 2026-09-27T09-01
Command: git diff --exit-code 74b2ca0a2bdf8a0bf9a032433fef20831707b574 -- tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1 tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1; git status --porcelain -- tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1 tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1
EXIT_CODE: 0
Output Summary: the diff exits 0 (empty) and the porcelain listing is empty; the three existing suites are unmodified.

## P5-T4

Timestamp: 2026-09-27T09-01
Command: git diff --name-only 74b2ca0a2bdf8a0bf9a032433fef20831707b574 -- .codex extensions/drm-copilot/resources/codex-and-agents-customizations; git status --porcelain --untracked-files=all -- .codex extensions/drm-copilot/resources/codex-and-agents-customizations
EXIT_CODE: 0
Output Summary: both outputs are empty; no `.codex` path or Codex bundle path is changed.

## P5-T5

Timestamp: 2026-09-27T09-02
Command: git diff --name-only 74b2ca0a2bdf8a0bf9a032433fef20831707b574; git status --porcelain --untracked-files=all
EXIT_CODE: 0
Output Summary: union of both listings:
- `.claude/hooks/enforce-completion-consistency.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1`
- `tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1`
- `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/evidence/baseline/baseline.md`
- `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/evidence/qa-gates/qa-gates.md`
- `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/evidence/regression-testing/edit-target-fail-before.md`
- `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/evidence/regression-testing/edit-target-pass-after.md`
- `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/issue.md`, `plan.2026-09-26T22-56.md`, `research/research.2026-09-27T03-00.md`, `spec.md` (feature documents committed by the preparation run)
- porcelain: `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/evidence/other/follow-ups.md` (untracked until the Phase 5 commit)
- No path outside the allowed set.

## P6-T9

Timestamp: 2026-09-27T09-05
AC9_PENDING: CI result for tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
Local evidence already recorded: P2-T6 and P4-T8 hash equality (SHA256=F9CA16BFBD90E0A2223AB2222C0B7B8F0629DC4D835FF18AD319E407F39F07A5 for both files) and P4-T7 (D9_OPTION: a, `14 passed`). Spec acceptance criterion 9 remains unchecked until the CI result is recorded; the feature-review step performs the check-off.

## P6-T9 CI result

Timestamp: 2026-09-27T13-10
AC9_CI_RESULT: PASS
PR: #726, head c7dcbb1cf156233ebc2f6f1b86ebe6dd439142cc; 19 of 19 checks pass, mergeStateStatus CLEAN.
CI job: `quality-checks7 / Code Quality & Tests (3.12)`, run 36320574333, job 108623494970. Log line: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py ....` followed by `5132 passed, 5 skipped`.
Result: spec acceptance criterion 9 checked off by the orchestrator (the feature-review step completed before the CI run existed, so the check-off it would have performed is recorded here).

## P6-T15

Timestamp: 2026-09-27T09-05
Command: grep -c -F -e "- [x]" docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/spec.md; grep -c -F -e "- [ ]" docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/spec.md
EXIT_CODE: 0
Output Summary: the first command prints `13` and the second prints `1`; the one unchecked item is criterion 9, held open by P6-T9.

### Acceptance Criteria Status
- Source: `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/spec.md` (section `## Acceptance Criteria`)
- Total AC items: 14
- Checked off (delivered): 13
- Remaining (unchecked): 1
- Items remaining: criterion 9 — "`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1` is byte-identical to `.claude/hooks/enforce-completion-consistency.ps1` (matching SHA-256 recorded in evidence), and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes in CI (and locally, with the #510 handling recorded per D9)." Outstanding pending the CI result.

## P6-T16

Timestamp: 2026-09-27T09-05
MergeBase: 74b2ca0a2bdf8a0bf9a032433fef20831707b574
All verification in this plan used the MergeBase above (recorded in P0-T3) as the `git diff` anchor. The pre-PR rebase and re-run of the verification set (spec "Merge-Order Independence", measure 4: P3-T1, P3-T2, and P4-T1 through P4-T8) is owned by the orchestration step that opens the pull request.
