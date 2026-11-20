# Coverage comparison - Pester (final gate against the Phase 0 baseline)

Timestamp: 2026-11-18T01-05
Command: comparison of evidence/qa-gates/final-qc-pester.2026-11-18T01-05.md with evidence/baseline/pester.2026-11-17T20-55.md; AC-7 check: `git diff --name-status <merge base of origin/main and HEAD> HEAD -- tests/scripts/claude-hooks tests/scripts/codex-hooks` and `git status --porcelain -- tests/scripts/claude-hooks tests/scripts/codex-hooks`
EXIT_CODE: 0
Output Summary:

| Measure | Phase 0 baseline | Final gate | Result |
|---|---|---|---|
| Tests (passed / failed) | 27476 / 0 | 28087 / 0 | no new failing test |
| Repo-wide line coverage | 96.05% (44864/46711) | 96.08% (45276/47121) | no drop |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 96.57% (169/175) | 96.61% (171/177) | no drop; both new lines covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 100.00% (180/180) | 100.00% (182/182) | no drop |
| .claude/hooks/hook-release-allowance-context.ps1 (new) | no pre-change run | 100.00% (171/171) | at or above 85% |
| .codex/hooks/hook-release-allowance-context.ps1 (new) | no pre-change run | 100.00% (171/171) | at or above 85% |
| .claude/hooks/enforce-orchestration-preimplementation-gate-release.ps1 (new) | no pre-change run | 100.00% (32/32) | at or above 85% |
| .codex/hooks/enforce-orchestration-preimplementation-gate-release.ps1 (new) | no pre-change run | 100.00% (32/32) | at or above 85% |

- The six uncovered lines of the Claude gate are the same pre-existing lines as in the baseline (6 uncovered before and after).
- AC-7: the name-status comparison lists only added files (A) in tests/scripts/claude-hooks and tests/scripts/codex-hooks: enforce-orchestration-preimplementation-gate-release.Tests.ps1, enforce-orchestration-preimplementation-gate.ReleaseAllowance.Cases.ps1, enforce-orchestration-preimplementation-gate.ReleaseAllowance.Tests.ps1, hook-release-allowance-context.Parity.Tests.ps1, hook-release-allowance-context.Tests.ps1, and codex-hooks/enforce-orchestration-preimplementation-gate-release-allowance.Tests.ps1. The porcelain status for both folders is empty. Every pre-existing test file in those folders passed unmodified in the final gate.
- Verdict: PASS for PowerShell (no new failure, no per-file or repo-wide drop, each new file at or above 85%).
