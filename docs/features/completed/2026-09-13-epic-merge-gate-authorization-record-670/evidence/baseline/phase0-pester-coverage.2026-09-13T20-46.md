# Phase 0 Pester and Coverage Baseline — Issue #670

Timestamp: 2026-09-17T07-57
Task: [P0-T7]
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('scripts','tests/scripts')
EXIT_CODE: 2

## Execution note (scan-folder deviation)

The plan's command names `-ScanFolders @('scripts','tests/powershell','tests/scripts')`. `tests/powershell` does not exist in this tree (nor at the base ref; `git ls-tree -d origin/epic/worktree-scoped-state-resolution-integration tests/` lists only `fixtures`, `schemas`, `scripts`, `shell`, `unit`). Run as written, `Resolve-PoshQCScanFolders` throws at `scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1:126` (`Failed to resolve scan folder 'tests/powershell'`) before any test runs. The folder was removed from the scan list. A missing folder contributes zero test files, so the executed test set is identical to the one the plan intended. The same substitution is applied to [P1-T6], [P7-T1] and [P8-T4].

The process exit code is 2 because `Run.Exit` is `$true` and the run recorded failures (see below).

## Fixed failed-count derivation (JUnit)

`([xml](Get-Content -Raw -LiteralPath 'artifacts/pester/pester-junit.xml')).testsuites` (LastWriteTime 2026-09-17T07:56:58):

| Attribute | Value |
| --- | --- |
| `tests` | 4547 |
| `failures` | 2 |
| `errors` | 0 |

Failing testcase nodes (pre-existing, environmental):

1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` (`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:145`, expected `allow`, got `deny`).
2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits` (`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1:165`; `enforce-epic-wave-barrier.ps1` denies with `EPIC_WAVE_BARRIER_BLOCKED: '670' cannot mutate until every depends_on edge is merged ...`).

Both failures read the live, gitignored orchestration checkpoint `artifacts/orchestration/orchestrator-state.json`, which exists in this worktree because this is an active epic-child run for #670 (the delegation instructions forbid editing it). Neither test touches a file in this plan's change surface. They are recorded as the pre-change baseline failure set.

## Coverage derivation (fixed)

Source: `artifacts/pester/powershell-coverage.xml` (LastWriteTime 2026-09-17T07:55:51). Per-file rows selected by `sourcefile/@name` equal to the leaf name and parent `package/@name` ending with the file's directory. Form used: child `line` elements (`ci > 0` over total).

| File | Package | Covered lines | Total lines | Line coverage | At least 85.0 |
| --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | `.../agent-a51b6017c8cb9c138/.claude/hooks` | 118 | 122 | 96.72 | yes |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | `.../agent-a51b6017c8cb9c138/.codex/hooks` | 70 | 71 | 98.59 | yes |

Total line coverage (report-level `counter type="LINE"`): covered 8914, missed 422, 95.48 percent.

Output Summary:
- JUnit counts: tests=4547, failures=2, errors=0 (three integers by the fixed derivation).
- Total line coverage: 95.48%.
- `.claude/hooks/enforce-epic-merge-gate.ps1`: 96.72% (at least 85.0: yes).
- `.codex/hooks/enforce-epic-merge-gate.ps1`: 98.59% (at least 85.0: yes).
- No pre-existing AC-40 coverage gap.
- Two pre-existing environmental failures, both driven by the live gitignored `artifacts/orchestration/orchestrator-state.json`; they are outside this change surface and will recur in later whole-tree runs while that checkpoint is present.
