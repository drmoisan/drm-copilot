# Stage I Stored Patch and Chain Check (P2-T2)

Timestamp: 2026-11-08T17-07
Command: sh launcher stored under SCRATCH (issue-1097-i-genpatch.sh): git add of the 37 Files Changed paths of entry 0010 outside the ledger folder, then git diff --cached --binary --no-renames HEAD over those paths written to docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch, then git apply -R --check of the patch; then a PowerShell 7 script stored under SCRATCH (issue-1097-i-chain.ps1): Test-ProcessReductionLedger over Read-ProcessReductionLedger, Invoke-ProcessReductionChain over Read-ProcessReductionChainInput -RepositoryRoot <worktree root>, the same chain with -StopBefore 0009-less-evidence.md, a FinalText comparison of every non-derived patch path with its HEAD text after line-ending normalization, and SHA-256 of both frozen files from FinalText
EXIT_CODE: 0
Output Summary:
  Patch: 37 file sections, 189437 bytes; 37 paths staged; git apply -R --check exit 0 against the live tree.
  Test-ProcessReductionLedger: IsValid True, 0 errors, 10 index rows, 10 entries.
  Invoke-ProcessReductionChain (all 10 entries): IsValid True, 0 errors.
  Invoke-ProcessReductionChain -StopBefore 0009-less-evidence.md: IsValid True, 0 errors.
  Replay: 16 source paths equal to HEAD; 10 created files absent; 11 byte-identical bundle copies skipped as derived paths; 0 different.
  Frozen digests from the replay equal the P0-T5 digests: .claude/agents/epic-orchestrator.md e0691d2a05dfd97b886694262eb900293f38d9927fc2803f7e4574af856ce740; .claude/skills/epic-orchestrate/SKILL.md 65f34506ae2d0505f47f79bfbfcbbd9d7c7f78dccc0e9213bc6c9b8222101b76.
  The changes stay uncommitted until P3-T5, per the plan.

Replay detail:

- EQUAL-TO-HEAD .agents/skills/epic-orchestrate/SKILL.md
- EQUAL-TO-HEAD .agents/skills/epic-run/SKILL.md
- EQUAL-TO-HEAD .claude/agents/epic-orchestrator.md
- EQUAL-TO-HEAD .claude/hooks/enforce-epic-wave-barrier.ps1
- ABSENT-AS-EXPECTED .claude/hooks/epic-wave-barrier-early-start.ps1
- EQUAL-TO-HEAD .claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1
- EQUAL-TO-HEAD .claude/skills/epic-orchestrate/SKILL.md
- EQUAL-TO-HEAD .claude/skills/epic-run/SKILL.md
- EQUAL-TO-HEAD .codex/agents/epic-orchestrator.toml
- EQUAL-TO-HEAD .codex/hooks/enforce-epic-wave-barrier.ps1
- ABSENT-AS-EXPECTED .codex/hooks/epic-wave-barrier-early-start.ps1
- EQUAL-TO-HEAD extensions/drm-copilot/jest.config.cjs
- DERIVED (skipped by the chain) extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md
- DERIVED (skipped by the chain) extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1
- DERIVED (skipped by the chain) extensions/drm-copilot/resources/claude-customizations/.claude/hooks/epic-wave-barrier-early-start.ps1
- DERIVED (skipped by the chain) extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1
- DERIVED (skipped by the chain) extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md
- DERIVED (skipped by the chain) extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-run/SKILL.md
- EQUAL-TO-HEAD extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
- DERIVED (skipped by the chain) extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md
- DERIVED (skipped by the chain) extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-run/SKILL.md
- DERIVED (skipped by the chain) extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml
- DERIVED (skipped by the chain) extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-wave-barrier.ps1
- DERIVED (skipped by the chain) extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/epic-wave-barrier-early-start.ps1
- EQUAL-TO-HEAD extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json
- EQUAL-TO-HEAD extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts
- ABSENT-AS-EXPECTED extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-wave-barrier.ts
- ABSENT-AS-EXPECTED extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-early-start.test.ts
- EQUAL-TO-HEAD scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py
- ABSENT-AS-EXPECTED tests/fixtures/epic_wave_barrier/early-start-edge-cases.json
- ABSENT-AS-EXPECTED tests/scripts/claude-hooks/enforce-epic-wave-barrier.EarlyStart.Tests.ps1
- ABSENT-AS-EXPECTED tests/scripts/claude-hooks/EpicWaveEarlyStart.Cases.Helpers.ps1
- ABSENT-AS-EXPECTED tests/scripts/claude-runtime/early-start-skill-contract.Tests.ps1
- EQUAL-TO-HEAD tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
- ABSENT-AS-EXPECTED tests/scripts/codex-hooks/enforce-epic-wave-barrier.EarlyStart.Tests.ps1
- EQUAL-TO-HEAD tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
- ABSENT-AS-EXPECTED tests/scripts/dev_tools/test_epic_wave_barrier_early_start.py
