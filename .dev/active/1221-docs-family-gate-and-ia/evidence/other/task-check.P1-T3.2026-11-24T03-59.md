# Task Check - P1-T3 (Issue #1221)

Timestamp: 2026-11-24T03-59
Command: sh SCRATCH/issue-1221-static-ps.sh check <files>; sh SCRATCH/issue-1221-pssa-one.sh <file> (Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, one fresh pwsh per file); sh <worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <selection>
EXIT_CODE: 0
Output Summary: Format 0 files needing format; analyzer 0 findings on each of the 3 files; Pester selection 169 passed, 0 failed (4 shards, exit 0). The selection run's own coverage (not gate evidence) shows DocsFamilyCheck.psm1 at 95/95 lines.

## Changed Files

- `.claude/lib/docs/DocsFamilyCheck.psm1` (new; exports `Read-DocsFamilyEvidence`, `Get-DocsFamilyStatus`, `Get-DocsFamilyFinding`; 284 lines)
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsFamilyCheck.psm1` (byte-identical bundle copy, verified with `cmp`)
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (entry `.claude/lib/docs/DocsFamilyCheck.psm1`, placed before `DocsValidation.psm1`)
- `tests/scripts/claude-lib/docs/DocsFamilyCheck.Tests.ps1` (new; three Describe blocks)

The module and tests were authored by the earlier executor run (WIP commit on this branch) and verified on resume against plan P1-T3 and spec `## Behavior`: every listed case is present, including the trailing-slash case, the `.png`/`.txt`/`.MD` suffix case, `artifact_path` on every finding row, and the `next_action` tokens.

## Selection and Rule

- Plan P1-T3 acceptance: `DocsFamilyCheck.Tests.ps1`, `Docs.Manifest.Tests.ps1`, `ClaudeLibModuleConvention.Tests.ps1`, `DocsNeutrality.Tests.ps1`.

## Commands and Exit Codes

| Step | Command | EXIT_CODE | Result |
|---|---|---|---|
| Format | static-ps check over the 3 PowerShell files | 0 | FILES_NEEDING_FORMAT=0 |
| Analyze | pssa-one per file (3 runs) | 0 | FINDINGS=0 each |
| Pester (first attempt) | launcher pester -TestPath (4 files) | 1 | 1 failure: `Docs core.json manifest membership.ships byte-identical bundled counterparts`, caused by the in-progress P1-T5 edit of `DocsValidateCommands.psm1` before its bundle copy was refreshed |
| Pester (after the P1-T5 bundle refresh) | launcher pester -TestPath (4 files) | 0 | TESTS=169 FAILURES=0 |

## Note on the Analyzer Route

The folder-batch analyzer of `SCRATCH/issue-1221-static-ps.ps1` (which imports PoshQC with `-Force` before PSScriptAnalyzer) threw a null-reference error and then stalled on `DocsFamilyCheck.psm1`; the same file analyzes in 1.1 s in a fresh pwsh that imports only PSScriptAnalyzer. The per-file route is used for the remaining task checks; the phase gate records its own analyzer route.
