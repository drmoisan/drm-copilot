# Phase 1 Post-Registration Coverage Baseline — Issue #670

Timestamp: 2026-09-17T08-05
Task: [P1-T6]
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('scripts','tests/scripts')
EXIT_CODE: 2

Execution note: `tests/powershell` is removed from the scan list for the reason recorded in `phase0-pester-coverage.2026-09-13T20-46.md` (the folder does not exist and `Resolve-PoshQCScanFolders` throws on it; the executed test set is unchanged). Exit code 2 is `Run.Exit` reporting the two pre-existing environmental failures.

## Fixed failed-count derivation (JUnit)

`artifacts/pester/pester-junit.xml` (LastWriteTime 2026-09-17T08:04:11), `testsuites` element:

| Attribute | Value |
| --- | --- |
| `tests` | 4547 |
| `failures` | 2 |
| `errors` | 0 |

Failing nodes: the same two pre-existing environmental cases recorded in the Phase 0 baseline (`enforce-pr-author-skill.Tests.ps1:145` and `codex-pretooluse-integration.Tests.ps1:165`), both driven by the live gitignored `artifacts/orchestration/orchestrator-state.json`.

## Per-file line coverage (fixed derivation, `line`-element form)

Source: `artifacts/pester/powershell-coverage.xml` (LastWriteTime 2026-09-17T08:03:12).

| File | Covered | Total | Line coverage | At least 85.0 |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | 9 | 9 | 100.00 | yes |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 110 | 114 | 96.49 | yes |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 70 | 71 | 98.59 | yes |

The new file's row is present in the coverage report (package `.../agent-a51b6017c8cb9c138/.claude/hooks`, sourcefile `enforce-epic-merge-gate-authorization.ps1`), which proves the `CodeCoverage.Path` registration took effect in this runner; the analyzed-file count rose from 101 (Phase 0) to 102.

Output Summary:
- JUnit counts: tests=4547, failures=2, errors=0.
- `.claude/hooks/enforce-epic-merge-gate-authorization.ps1`: 100.00% (at least 85.0: yes).
- `.claude/hooks/enforce-epic-merge-gate.ps1`: 96.49% (at least 85.0: yes).
- `.codex/hooks/enforce-epic-merge-gate.ps1`: 98.59% (at least 85.0: yes).
- Total line coverage: 95.48% (covered 8915, missed 422).
- No pre-existing AC-40 gap. The failure set is unchanged from Phase 0 (same two environmental cases).
