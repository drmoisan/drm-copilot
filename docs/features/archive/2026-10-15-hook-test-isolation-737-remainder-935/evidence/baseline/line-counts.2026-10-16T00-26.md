# Baseline Line Counts (P0-T3)

Timestamp: 2026-10-16T00-26
Command: awk 'END { print NR }' <path> (run once per path below)
EXIT_CODE: 0

Output Summary: all 11 counts equal the plan's expected values (the four I-3 files are included in the 11 Write-Set edit files). PASS.

| Path | Count | Expected |
| --- | --- | --- |
| tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 | 474 | 474 |
| tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 | 267 | 267 |
| tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1 | 207 | 207 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | 197 | 197 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | 280 | 280 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | 350 | 350 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | 333 | 333 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 (I-3) | 500 | 500 |
| tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 (I-3) | 500 | 500 |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 (I-3) | 500 | 500 |
| tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1 (I-3) | 500 | 500 |
