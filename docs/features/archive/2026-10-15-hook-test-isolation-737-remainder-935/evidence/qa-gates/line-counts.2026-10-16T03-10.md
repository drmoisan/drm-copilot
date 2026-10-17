# Final Line Counts (P6-T5, AC-20)

Timestamp: 2026-10-16T03-10
Command: awk 'END { print NR }' <path> (run once per Write-Set code file, from SCRATCH/935/issue-935/p6-static.sh)
EXIT_CODE: 0

Output Summary: all 18 Write-Set code files are at or below 500 lines; each of the four I-3 originals is below 500. PASS.

| Path | Lines |
| --- | --- |
| tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1 (created) | 376 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1 (created) | 356 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1 (created) | 91 |
| tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1 (created) | 124 |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Helpers.ps1 (created) | 47 |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1 (created) | 221 |
| tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1 (created) | 108 |
| tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 | 428 |
| tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 | 288 |
| tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1 | 224 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | 335 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | 288 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | 362 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | 356 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 (I-3 original) | 428 |
| tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 (I-3 original) | 418 |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 (I-3 original) | 271 |
| tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1 (I-3 original) | 402 |
