# Phase 0 Full Pester Baseline with Coverage ([P0-T8])

Timestamp: 2026-09-27T06-32
Command: sh <SCRATCHPAD>/p0-pester.sh (fresh PowerShell 7 process: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root $root -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1), then sh <SCRATCHPAD>/p0-parse.sh (R-COV over artifacts/pester/powershell-coverage.xml and JUnit root attributes of artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: Tests Passed: 5309, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0. JUnit root tests=5318 failures=0 errors=0; no testcase carries a failure or error child. Gate coverage: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 98.80 percent (covered=164, missed=2). Pester overall command coverage reported 95.24 percent over 112 files (informational).

Run window (local): RUN_START_LOCAL 2026-09-27T06-32-31, RUN_END_LOCAL 2026-09-27T06-36-49.

## Report last-write times

| Report | Last write (local) |
| --- | --- |
| `artifacts/pester/pester-junit.xml` | 2026-09-27T06-36-49 |
| `artifacts/pester/powershell-coverage.xml` | 2026-09-27T06-35-42 |

Both are at or after `Timestamp:` 2026-09-27T06-32.

## Console summary line

```
Tests Passed: 5309, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
```

(The console printed the counts with ANSI colour codes on separate segments; the line above is the same text with the colour codes removed.)

## JUnit root

- root element: `Pester`
- tests: 5318
- failures: 0
- errors: 0

Failed or errored testcases: none

## Coverage packages found (host root replaced)

- `<WORKSPACE_ROOT>/.claude/hooks`
- `<WORKSPACE_ROOT>/.claude/lib/blast-radius`
- `<WORKSPACE_ROOT>/.claude/lib/cleanup-manifest`
- `<WORKSPACE_ROOT>/.claude/lib/codex-routing`
- `<WORKSPACE_ROOT>/.claude/lib/discovery-validation`
- `<WORKSPACE_ROOT>/.claude/lib/hook-payload`
- `<WORKSPACE_ROOT>/.claude/lib/mermaid`
- `<WORKSPACE_ROOT>/.claude/lib/model-routing`
- `<WORKSPACE_ROOT>/.claude/lib/orchestrator-state`
- `<WORKSPACE_ROOT>/.claude/lib/project-file-merge`
- `<WORKSPACE_ROOT>/.claude/lib/worktree-resolution`
- `<WORKSPACE_ROOT>/.codex/hooks`
- `<WORKSPACE_ROOT>/.codex/scripts`
- `<WORKSPACE_ROOT>/scripts/dev-tools`
- `<WORKSPACE_ROOT>/scripts/powershell`
- `<WORKSPACE_ROOT>/scripts/powershell/PoshQC`

Package-name observation for R-COV: package names are absolute, drive-rooted paths using forward slashes after backslash replacement. The R-COV selection rule (name ends with `/.codex/hooks` and does not contain `extensions/`) matched exactly one package, and within it exactly one `sourcefile` named `enforce-orchestration-preimplementation-gate.ps1`.

## Coverage (R-COV)

```
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 98.80 | covered=164 | missed=2
```
