# PowerShell Coverage Baseline (P1-T3)

Timestamp: 2026-10-13T11-14
Command: gh run download 38386628228 -n poshqc-test-results -D artifacts/scratch-903/ci-baseline-903 (executed by the orchestrator); poetry -C <worktree> run python -I artifacts/scratch-903/ps_cov_extract_903.py artifacts/scratch-903/ci-baseline-903/powershell-coverage.xml files (executor; reads the `LINE` counter of each `sourcefile` keyed by its enclosing `package` directory)
EXIT_CODE: 0

- Source run: https://github.com/drmoisan/drm-copilot/actions/runs/38386628228 (headSha 95d6c9b22088b885225b63313b7bdb34968caa40)
- Artifact state: present (`pester-junit.xml`, `powershell-coverage.xml`, `powershell-coverage.koverage.xml`); not ARTIFACT-ABSENT.

| File | Covered | Missed | Percent |
|---|---|---|---|
| .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 31 | 0 | 100.0 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 135 | 2 | 98.54 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 122 | 13 | 90.37 |
| .claude/hooks/feature-folder-resolution.ps1 | 111 | 0 | 100.0 |
| .codex/hooks/feature-folder-resolution.ps1 | 111 | 0 | 100.0 |
| .claude/hooks/enforce-completion-consistency.ps1 | 137 | 9 | 93.84 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 123 | 0 | 100.0 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 123 | 0 | 100.0 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 72 | 1 | 98.63 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 47 | 13 | 78.33 |

Output Summary: Ten numeric rows recorded from the PHASE0 CI coverage XML. Nine files are at or above 85% line coverage; `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` is at 78.33% (47 covered, 13 missed) at baseline.
