# Stage G Baseline Text Record (P0-T4)

Timestamp: 2026-11-08T03-38
Command: sh-launched PowerShell 7 scripts under SCRATCH, before any edit: a baseline-text recorder that reads every path of the plan's Surfaces and Baseline-Adjacent Places table (sources, bundles, and generated Codex variants), normalizes line endings, selects the lines matching the case-insensitive pattern baseline|regression|pre-change|Phase 0, hashes them and the whole file with SHA-256, classes each path with Get-ProcessReductionDerivedSource, and lists the entries whose ## Files Changed name the path; then Test-ProcessReductionLedger over Read-ProcessReductionLedger, Invoke-ProcessReductionChain over Read-ProcessReductionChainInput, and its -StopBefore replay for each stored-patch entry
EXIT_CODE: 0
Output Summary:
  Paths recorded: 52. Next free entry number: 0009 (entries 0001 to 0008 present), so the derived number equals the planned 0009.
  ledger IsValid=True entries=8 errors=0 names=0001 to 0008
  chain full IsValid=True errors=0
  stored-patch entries: 0001-parallel-only-test-gates.md, 0006-test-suite-baseline-restored.md, 0008-g13-guideline-cutoff.md
  chain StopBefore 0001-parallel-only-test-gates.md IsValid=True errors=0
  chain StopBefore 0006-test-suite-baseline-restored.md IsValid=True errors=0
  chain StopBefore 0008-g13-guideline-cutoff.md IsValid=True errors=0
  Every replay returned IsValid true with zero errors.

## Per-Path Records

| Path | Baseline lines | Lines SHA-256 | File SHA-256 | Class | Older entries |
| --- | --- | --- | --- | --- | --- |
| `.claude/skills/atomic-plan-contract/SKILL.md` | 33 | `bacedd858b5728204a99fb557b39f3df1617764e7b1651301333b4cf94213208` | `84ad9f517a37ca9fcccca0c97234bc7b90fb8f9fa2400756e496d83fcd93242c` | source | 0001,0003,0004,0005,0006,0008 |
| `.agents/skills/atomic-plan-contract/SKILL.md` | 32 | `f8cfaa28e171cf3223601b09ac0998dabb5d4b7f3eefa33ad5de53a1862c1377` | `f75bdd920be3fad0ab66b1d966692dbd2783c33a944c656998ac217e27a4a1ac` | source | 0001,0003,0004,0005,0006,0008 |
| `.github/skills/atomic-plan-contract/SKILL.md` | 28 | `ab701ee3ff16500d6b7c1eca8b70c9ee3b8838a07f7dfeea8bf77cf99c9ddfc1` | `cdb658e51225e2036436cf631e3e7ba08f13124b350d6fc7fe91f7b604bc392d` | source | 0001,0003,0004,0005,0006,0008 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | 33 | `bacedd858b5728204a99fb557b39f3df1617764e7b1651301333b4cf94213208` | `84ad9f517a37ca9fcccca0c97234bc7b90fb8f9fa2400756e496d83fcd93242c` | mirror of .claude/skills/atomic-plan-contract/SKILL.md | 0001,0003,0004,0005,0006,0008 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md` | 32 | `f8cfaa28e171cf3223601b09ac0998dabb5d4b7f3eefa33ad5de53a1862c1377` | `f75bdd920be3fad0ab66b1d966692dbd2783c33a944c656998ac217e27a4a1ac` | mirror of .agents/skills/atomic-plan-contract/SKILL.md | 0001,0003,0004,0005,0006,0008 |
| `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md` | 28 | `ab701ee3ff16500d6b7c1eca8b70c9ee3b8838a07f7dfeea8bf77cf99c9ddfc1` | `cdb658e51225e2036436cf631e3e7ba08f13124b350d6fc7fe91f7b604bc392d` | mirror of .github/skills/atomic-plan-contract/SKILL.md | 0001,0003,0004,0005,0006,0008 |
| `.claude/skills/feature-review-workflow/SKILL.md` | 8 | `40f707d8bbf909fde99de2fd37d720e126eda4c57be5ef36e6d09aa0551bf3f0` | `bc73fb06467d045d960b6f71b1f289838dc8cb0378abc3b529e30f7214557a3e` | source | 0001,0003,0006 |
| `.agents/skills/feature-review-workflow/SKILL.md` | 7 | `06bdd395fbab0d43e25c3941cac31b2a5896e1333fd52914e32bbe0582822f3b` | `27aa61d1396f5989f021dd486c44fb9caf81c38f19cb45484c2877572088ab48` | source | 0001,0003,0006 |
| `.github/skills/feature-review-workflow/SKILL.md` | 7 | `7185f989d77249c5f66432971dbe67d34fcf246fdc400bcceef40b587f88e55b` | `ac8fda39db01d97334516f84e938f36ac71ae51189731704f55b4b787285e7fa` | source | 0001,0003,0006 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` | 8 | `40f707d8bbf909fde99de2fd37d720e126eda4c57be5ef36e6d09aa0551bf3f0` | `bc73fb06467d045d960b6f71b1f289838dc8cb0378abc3b529e30f7214557a3e` | mirror of .claude/skills/feature-review-workflow/SKILL.md | 0001,0003,0006 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md` | 7 | `06bdd395fbab0d43e25c3941cac31b2a5896e1333fd52914e32bbe0582822f3b` | `27aa61d1396f5989f021dd486c44fb9caf81c38f19cb45484c2877572088ab48` | mirror of .agents/skills/feature-review-workflow/SKILL.md | 0001,0003,0006 |
| `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md` | 7 | `7185f989d77249c5f66432971dbe67d34fcf246fdc400bcceef40b587f88e55b` | `ac8fda39db01d97334516f84e938f36ac71ae51189731704f55b4b787285e7fa` | mirror of .github/skills/feature-review-workflow/SKILL.md | 0001,0003,0006 |
| `.claude/skills/orchestrate/SKILL.md` | 1 | `a671ffcceb5d54f2e2d02bcb73fd22f7f428fedfdeb3b0c8a7483783ec781b37` | `7091d17e66b3cf3e60446846d7cf7240d06ebdcc3d22e277feb717b116524f6f` | source | 0002,0003 |
| `.agents/skills/orchestrate/SKILL.md` | 1 | `a671ffcceb5d54f2e2d02bcb73fd22f7f428fedfdeb3b0c8a7483783ec781b37` | `f66264424b0f0bd5fe1b763b70cd0adacad6481e6ad057aec3785e52d4adf6f2` | source | 0002,0003 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` | 1 | `a671ffcceb5d54f2e2d02bcb73fd22f7f428fedfdeb3b0c8a7483783ec781b37` | `7091d17e66b3cf3e60446846d7cf7240d06ebdcc3d22e277feb717b116524f6f` | mirror of .claude/skills/orchestrate/SKILL.md | 0002,0003 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md` | 1 | `a671ffcceb5d54f2e2d02bcb73fd22f7f428fedfdeb3b0c8a7483783ec781b37` | `f66264424b0f0bd5fe1b763b70cd0adacad6481e6ad057aec3785e52d4adf6f2` | mirror of .agents/skills/orchestrate/SKILL.md | 0002,0003 |
| `.claude/agents/atomic-planner.md` | 5 | `e32d55c591313502bc8872cb2e057b321c4013e9a5dc5016b44131051c3fdb3f` | `775511d5c5f8b098fc15d8da6dfefe0da76034d3db2218ca823b5267913448db` | source | 0001,0005,0006,0008 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md` | 5 | `e32d55c591313502bc8872cb2e057b321c4013e9a5dc5016b44131051c3fdb3f` | `775511d5c5f8b098fc15d8da6dfefe0da76034d3db2218ca823b5267913448db` | mirror of .claude/agents/atomic-planner.md | 0001,0005,0006,0008 |
| `.codex/agents/atomic-planner.toml` | 5 | `236889c1870663badce3420affb81ed41e1d4bbee5f9d84debe02ce73c04ffff` | `34828192af822403c34c0bf2fc03fc9c25321cc17cafa8e57a20a4f3c514434c` | source | 0001,0005,0006 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml` | 5 | `236889c1870663badce3420affb81ed41e1d4bbee5f9d84debe02ce73c04ffff` | `34828192af822403c34c0bf2fc03fc9c25321cc17cafa8e57a20a4f3c514434c` | mirror of .codex/agents/atomic-planner.toml | 0001,0005,0006 |
| `.claude/agents/atomic-executor.md` | 4 | `e92254d854e4aa272cd6424ae97b04bd5e2963e68b0f95adccb8da2188e03586` | `b0144235fc50e042966eabb5d795c606af0f6614429ceabb738117582d453b34` | source | 0001,0003,0006 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md` | 4 | `e92254d854e4aa272cd6424ae97b04bd5e2963e68b0f95adccb8da2188e03586` | `b0144235fc50e042966eabb5d795c606af0f6614429ceabb738117582d453b34` | mirror of .claude/agents/atomic-executor.md | 0001,0003,0006 |
| `.codex/agents/atomic-executor.toml` | 4 | `4bc88f55e4d4584108726f90a0996d9803ad1b996d4a7452568ae22a784ce2af` | `fc3c5fe9cfbce8f3f8f6eaf6fb2d2b2db0a37b1db32771fe5a008f216fe025be` | source | 0001,0003,0006 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor.toml` | 4 | `4bc88f55e4d4584108726f90a0996d9803ad1b996d4a7452568ae22a784ce2af` | `fc3c5fe9cfbce8f3f8f6eaf6fb2d2b2db0a37b1db32771fe5a008f216fe025be` | mirror of .codex/agents/atomic-executor.toml | 0001,0003,0006 |
| `.claude/agents/feature-review.md` | 10 | `8720a409e53cd047f25a25e5af0534ff9d5d893059d70dcbb19ef5b3310d7259` | `90a24938c10296a0c981375c96bd71ffd7ca1a6dcdbbeb0a3b930f4a5c92f1a2` | source | 0001,0003,0006 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md` | 10 | `8720a409e53cd047f25a25e5af0534ff9d5d893059d70dcbb19ef5b3310d7259` | `90a24938c10296a0c981375c96bd71ffd7ca1a6dcdbbeb0a3b930f4a5c92f1a2` | mirror of .claude/agents/feature-review.md | 0001,0003,0006 |
| `.codex/agents/feature-review.toml` | 9 | `058cd63ceae0df8823d5726ae13e358ec5f68d893dbea89efa222dc792f0cdb2` | `bd65f5737642786fa13b072a64752a3fe01cfdf9e50260ecb7f8c86a4087ca00` | source | 0001,0006 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml` | 9 | `058cd63ceae0df8823d5726ae13e358ec5f68d893dbea89efa222dc792f0cdb2` | `bd65f5737642786fa13b072a64752a3fe01cfdf9e50260ecb7f8c86a4087ca00` | mirror of .codex/agents/feature-review.toml | 0001,0006 |
| `.codex/agents/atomic-planner-c1.toml` | 5 | `236889c1870663badce3420affb81ed41e1d4bbee5f9d84debe02ce73c04ffff` | `6ead8bd5ed96c593b81f96b9fc5451165bd1593fb58608560495e7801e558c2f` | generated | 0001,0005,0006 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c1.toml` | 5 | `236889c1870663badce3420affb81ed41e1d4bbee5f9d84debe02ce73c04ffff` | `6ead8bd5ed96c593b81f96b9fc5451165bd1593fb58608560495e7801e558c2f` | generated | 0001,0006 |
| `.codex/agents/atomic-planner-c2.toml` | 5 | `236889c1870663badce3420affb81ed41e1d4bbee5f9d84debe02ce73c04ffff` | `ad0ea89eae9f79b896d34ab6ff55d1a76065e7fd9cc5dbd572664d45981ab1ff` | generated | 0001,0006 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c2.toml` | 5 | `236889c1870663badce3420affb81ed41e1d4bbee5f9d84debe02ce73c04ffff` | `ad0ea89eae9f79b896d34ab6ff55d1a76065e7fd9cc5dbd572664d45981ab1ff` | generated | 0001,0006 |
| `.codex/agents/atomic-planner-c3.toml` | 5 | `236889c1870663badce3420affb81ed41e1d4bbee5f9d84debe02ce73c04ffff` | `d0417c131e0119c17699dd3ea4167dd20cb3f0ca364d9ce2fe3c86a356b8e9a1` | generated | 0001,0006 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3.toml` | 5 | `236889c1870663badce3420affb81ed41e1d4bbee5f9d84debe02ce73c04ffff` | `d0417c131e0119c17699dd3ea4167dd20cb3f0ca364d9ce2fe3c86a356b8e9a1` | generated | 0001,0006 |
| `.codex/agents/atomic-planner-c3-elevated.toml` | 5 | `236889c1870663badce3420affb81ed41e1d4bbee5f9d84debe02ce73c04ffff` | `5f2ba6b3079ea626fecf832108313f9b1a408d86ff6498f9c2e99a65b6fb518f` | generated | 0001,0006 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3-elevated.toml` | 5 | `236889c1870663badce3420affb81ed41e1d4bbee5f9d84debe02ce73c04ffff` | `5f2ba6b3079ea626fecf832108313f9b1a408d86ff6498f9c2e99a65b6fb518f` | generated | 0001,0006 |
| `.codex/agents/atomic-planner-c4.toml` | 5 | `236889c1870663badce3420affb81ed41e1d4bbee5f9d84debe02ce73c04ffff` | `f906f1aba9f0ea012ff6a29fb16fcf103c5429f67b6db99dc1dbb508902391c2` | generated | 0001,0006 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c4.toml` | 5 | `236889c1870663badce3420affb81ed41e1d4bbee5f9d84debe02ce73c04ffff` | `f906f1aba9f0ea012ff6a29fb16fcf103c5429f67b6db99dc1dbb508902391c2` | generated | 0001,0006 |
| `.codex/agents/atomic-executor-c1.toml` | 4 | `4bc88f55e4d4584108726f90a0996d9803ad1b996d4a7452568ae22a784ce2af` | `5ea25a1f6b159b464dc58a9f18ee6f48512190576c5c79adb217dded7c280b4c` | generated | 0001,0003,0006 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c1.toml` | 4 | `4bc88f55e4d4584108726f90a0996d9803ad1b996d4a7452568ae22a784ce2af` | `5ea25a1f6b159b464dc58a9f18ee6f48512190576c5c79adb217dded7c280b4c` | generated | 0001,0006 |
| `.codex/agents/atomic-executor-c2.toml` | 4 | `4bc88f55e4d4584108726f90a0996d9803ad1b996d4a7452568ae22a784ce2af` | `b5ecbae941e9a08817ecee077c3184fae4289894f9e9269f1ab0bac63d9a25fc` | generated | 0001,0006 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c2.toml` | 4 | `4bc88f55e4d4584108726f90a0996d9803ad1b996d4a7452568ae22a784ce2af` | `b5ecbae941e9a08817ecee077c3184fae4289894f9e9269f1ab0bac63d9a25fc` | generated | 0001,0006 |
| `.codex/agents/atomic-executor-c3.toml` | 4 | `4bc88f55e4d4584108726f90a0996d9803ad1b996d4a7452568ae22a784ce2af` | `98e64000f32c228654521c5957212aac5b7cf9d34abca126cb51e98b744960da` | generated | 0001,0006 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3.toml` | 4 | `4bc88f55e4d4584108726f90a0996d9803ad1b996d4a7452568ae22a784ce2af` | `98e64000f32c228654521c5957212aac5b7cf9d34abca126cb51e98b744960da` | generated | 0001,0006 |
| `.codex/agents/atomic-executor-c3-elevated.toml` | 4 | `4bc88f55e4d4584108726f90a0996d9803ad1b996d4a7452568ae22a784ce2af` | `543dcedd5286f25b76084df8d1b5f480f88fd037a5074c0052f7f75f9bd450b6` | generated | 0001,0006 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3-elevated.toml` | 4 | `4bc88f55e4d4584108726f90a0996d9803ad1b996d4a7452568ae22a784ce2af` | `543dcedd5286f25b76084df8d1b5f480f88fd037a5074c0052f7f75f9bd450b6` | generated | 0001,0006 |
| `.codex/agents/atomic-executor-c4.toml` | 4 | `4bc88f55e4d4584108726f90a0996d9803ad1b996d4a7452568ae22a784ce2af` | `29bd7fc4039cde20045b16a8d3a834732828344af664d9991d9244e28ea70fbb` | generated | 0001,0006 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c4.toml` | 4 | `4bc88f55e4d4584108726f90a0996d9803ad1b996d4a7452568ae22a784ce2af` | `29bd7fc4039cde20045b16a8d3a834732828344af664d9991d9244e28ea70fbb` | generated | 0001,0006 |
| `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` | 19 | `502c10095c5ae06c36ccf13f0351a29c7b2e24f6cf9b5393c73e438cdf361ccc` | `453000943f9e74db8a5d14ef6e8ecb911166b3972f1f2cc6c32efeae238853ca` | source | 0001,0006 |
| `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` | 19 | `502c10095c5ae06c36ccf13f0351a29c7b2e24f6cf9b5393c73e438cdf361ccc` | `453000943f9e74db8a5d14ef6e8ecb911166b3972f1f2cc6c32efeae238853ca` | mirror of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md | 0001,0006 |
| `docs/features/templates/policy_audit/AGENTS.md` | 6 | `fee8d07e407e6f471444dffa1fc07fbbbd372b2c91a97f2cb965a87cf0f2e7bf` | `114934b8d99f2fb031dadfc520040e69d38b881c5ae14eb1e6458fdf86544e5a` | source | 0001,0006 |
| `extensions/drm-copilot/resources/templates/policy_audit/AGENTS.md` | 6 | `fee8d07e407e6f471444dffa1fc07fbbbd372b2c91a97f2cb965a87cf0f2e7bf` | `114934b8d99f2fb031dadfc520040e69d38b881c5ae14eb1e6458fdf86544e5a` | mirror of docs/features/templates/policy_audit/AGENTS.md | 0001,0006 |

## Baseline Lines by Path

### .claude/skills/atomic-plan-contract/SKILL.md

````text
description: 'Atomic plan format and toolchain contract shared by planning and execution agents. Use when generating, validating, or executing atomic plans with Phase 0, baseline capture, and final QA loops.'
Shared rules for atomic plan formatting, Phase 0 requirements, baseline capture, and final QA loops.
- Enforcing Phase 0 baseline capture and final QA loops.
1) Baseline capture block
- baseline capture for each language that has explicit baseline command tasks in the plan: static baselines (format, lint, type check, and analyzer findings) and, for each language with mandatory coverage policy, one `Phase 0 baseline` run of its test gate (one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, one Jest coverage run).
	- one baseline artifact per baseline command step (no aggregate-only baseline artifact)
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
	- baseline test-step artifacts for languages with mandatory coverage policy MUST include the pass and fail counts and numeric coverage headline values in `Output Summary:` (repo-wide percent and the percent of each in-scope file), read from the one parallel gate run.
- final-QC test commands for languages with mandatory coverage policy MUST run in coverage mode and record numeric post-change coverage values from the single gate run in `Output Summary:`, compared with the `Phase 0 baseline` run of the same gate.
	- Phase 0 baseline capture,
- orchestrator MUST delegate to executor to run Phase 0 only,
- orchestrator MUST checkpoint Phase 0 evidence before branching.
Branching after Phase 0:
## Phase 0 Requirements
Phase 0 carries no routine policy-read task. Agents still follow the reading order defined in `policy-compliance-order`, and a plan that keeps a policy-read task stays valid.
Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched and, for each language in scope with coverage policy, one `Phase 0 baseline` run of its test gate: one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, and one Jest coverage run where TypeScript is in scope. Each test-suite baseline artifact records the pass and fail counts, the repo-wide coverage, and the coverage of each in-scope file. The final gate's run of the same gate is compared with it: no new failing test, no per-file or repo-wide coverage drop, the thresholds still apply, and new behavior is tested. A new file has no pre-change run and is judged against the thresholds. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.
A plan written before this rule that captures static baselines only stays valid: preflight does not return it as a defect, its final gate reads coverage against the thresholds, and its audit records `N/A - no pre-change run`.
For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless these artifacts exist:
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.
Evidence paths in plan tasks MUST resolve to `<FEATURE>/evidence/<kind>/`. A plan that names an alternative location (e.g., `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`) fails preflight validation and must be corrected before execution begins.
For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless these artifacts exist:
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.
- The approved plan MUST include explicit baseline and final-QC coverage capture tasks: the `Phase 0 baseline` run and the final gate run, each one run of the language's parallel gate.
- Baseline and final-QC artifacts MUST record numeric coverage values (not placeholders such as `UNVERIFIED`).
- Where policy requires no-regression and new-code thresholds, the plan MUST include a delta/threshold verification task that reports, with post-change figures from the single gate run:
	- baseline coverage, from the `Phase 0 baseline` artifact,
- Each changed file meets the coverage thresholds and shows no drop against the `Phase 0 baseline`; a new file has no pre-change run and is judged against the thresholds. New behavior is tested.
Any regression test task expected to fail must be tagged with `[expect-fail]` and include an auditable evidence artifact per `evidence-and-timestamp-conventions`.
- **Check that the task-ordering does not make the condition unsatisfiable.** No rule covers this. A gate that runs a test path containing deliberately-failing cases added by an earlier task, before the later task that makes them pass, cannot exit 0. A baseline captured after a write-mode formatter has already repaired pre-existing drift becomes either a blanket waiver or makes a later gate unsatisfiable. Read each acceptance condition against the state the plan will actually be in when its task runs.
- `minor-audit` plans MUST include baseline evidence tasks (static baselines and the `Phase 0 baseline` test-suite run), targeted verification evidence tasks read from the gate run, and end-state evidence tasks.
- `minor-audit` execution/validation/audit MUST fail closed when `spec.md` or `user-story.md` exists unexpectedly in the active folder, when the explicit `## Acceptance Criteria` section is missing from `issue.md`, when required Phase 0 artifacts are missing, or when checklist state contradicts evidence on disk.
````

### .agents/skills/atomic-plan-contract/SKILL.md

````text
description: 'Atomic plan format and toolchain contract shared by planning and execution agents. Use when generating, validating, or executing atomic plans with Phase 0, baseline capture, and final QA loops.'
Shared rules for atomic plan formatting, Phase 0 requirements, baseline capture, and final QA loops.
- Enforcing Phase 0 baseline capture and final QA loops.
1) Baseline capture block
- baseline capture for each language that has explicit baseline command tasks in the plan: static baselines (format, lint, type check, and analyzer findings) and, for each language with mandatory coverage policy, one `Phase 0 baseline` run of its test gate (one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, one Jest coverage run).
	- one baseline artifact per baseline command step (no aggregate-only baseline artifact)
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
	- baseline test-step artifacts for languages with mandatory coverage policy MUST include the pass and fail counts and numeric coverage headline values in `Output Summary:` (repo-wide percent and the percent of each in-scope file), read from the one parallel gate run.
- final-QC test commands for languages with mandatory coverage policy MUST run in coverage mode and record numeric post-change coverage values from the single gate run in `Output Summary:`, compared with the `Phase 0 baseline` run of the same gate.
	- Phase 0 baseline capture,
- orchestrator MUST delegate to executor to run Phase 0 only,
- orchestrator MUST checkpoint Phase 0 evidence before branching.
Branching after Phase 0:
## Phase 0 Requirements
Phase 0 carries no routine policy-read task. Agents still follow the reading order defined in `policy-compliance-order`, and a plan that keeps a policy-read task stays valid.
Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched and, for each language in scope with coverage policy, one `Phase 0 baseline` run of its test gate: one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, and one Jest coverage run where TypeScript is in scope. Each test-suite baseline artifact records the pass and fail counts, the repo-wide coverage, and the coverage of each in-scope file. The final gate's run of the same gate is compared with it: no new failing test, no per-file or repo-wide coverage drop, the thresholds still apply, and new behavior is tested. A new file has no pre-change run and is judged against the thresholds. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.
A plan written before this rule that captures static baselines only stays valid: preflight does not return it as a defect, its final gate reads coverage against the thresholds, and its audit records `N/A - no pre-change run`.
For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless these artifacts exist:
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.
Evidence paths in plan tasks MUST resolve to `<FEATURE>/evidence/<kind>/`. A plan that names an alternative location (e.g., `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`) fails preflight validation and must be corrected before execution begins.
For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless these artifacts exist:
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.
- The approved plan MUST include explicit baseline and final-QC coverage capture tasks: the `Phase 0 baseline` run and the final gate run, each one run of the language's parallel gate.
- Baseline and final-QC artifacts MUST record numeric coverage values (not placeholders such as `UNVERIFIED`).
- Where policy requires no-regression and new-code thresholds, the plan MUST include a delta/threshold verification task that reports, with post-change figures from the single gate run:
	- baseline coverage, from the `Phase 0 baseline` artifact,
- Each changed file meets the coverage thresholds and shows no drop against the `Phase 0 baseline`; a new file has no pre-change run and is judged against the thresholds. New behavior is tested.
Any regression test task expected to fail must be tagged with `[expect-fail]` and include an auditable evidence artifact per `evidence-and-timestamp-conventions`.
- `minor-audit` plans MUST include baseline evidence tasks (static baselines and the `Phase 0 baseline` test-suite run), targeted verification evidence tasks read from the gate run, and end-state evidence tasks.
- `minor-audit` execution/validation/audit MUST fail closed when `spec.md` or `user-story.md` exists unexpectedly in the active folder, when the explicit `## Acceptance Criteria` section is missing from `issue.md`, when required Phase 0 artifacts are missing, or when checklist state contradicts evidence on disk.
````

### .github/skills/atomic-plan-contract/SKILL.md

````text
description: 'Atomic plan format and toolchain contract shared by planning and execution agents. Use when generating, validating, or executing atomic plans with Phase 0, baseline capture, and final QA loops.'
Shared rules for atomic plan formatting, Phase 0 requirements, baseline capture, and final QA loops.
- Enforcing Phase 0 baseline capture and final QA loops.
1) Baseline capture block
- baseline capture for each language that has explicit baseline command tasks in the plan: static baselines (format, lint, type check, and analyzer findings) and, for each language with mandatory coverage policy, one `Phase 0 baseline` run of its test gate (one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, one Jest coverage run).
	- one baseline artifact per baseline command step (no aggregate-only baseline artifact)
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
	- baseline test-step artifacts for languages with mandatory coverage policy MUST include the pass and fail counts and numeric coverage headline values in `Output Summary:` (repo-wide percent and the percent of each in-scope file), read from the one parallel gate run.
- final-QC test commands for languages with mandatory coverage policy MUST run in coverage mode and record numeric post-change coverage values from the single gate run in `Output Summary:`, compared with the `Phase 0 baseline` run of the same gate.
	- Phase 0 baseline capture,
- orchestrator MUST delegate to executor to run Phase 0 only,
- orchestrator MUST checkpoint Phase 0 evidence before branching.
Branching after Phase 0:
## Phase 0 Requirements
Phase 0 carries no routine policy-read task. Agents still follow the reading order defined in `policy-compliance-order`, and a plan that keeps a policy-read task stays valid.
Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched and, for each language in scope with coverage policy, one `Phase 0 baseline` run of its test gate: one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, and one Jest coverage run where TypeScript is in scope. Each test-suite baseline artifact records the pass and fail counts, the repo-wide coverage, and the coverage of each in-scope file. The final gate's run of the same gate is compared with it: no new failing test, no per-file or repo-wide coverage drop, the thresholds still apply, and new behavior is tested. A new file has no pre-change run and is judged against the thresholds. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.
A plan written before this rule that captures static baselines only stays valid: preflight does not return it as a defect, its final gate reads coverage against the thresholds, and its audit records `N/A - no pre-change run`.
For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless these artifacts exist:
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.
- The approved plan MUST include explicit baseline and final-QC coverage capture tasks: the `Phase 0 baseline` run and the final gate run, each one run of the language's parallel gate.
- Baseline and final-QC artifacts MUST record numeric coverage values (not placeholders such as `UNVERIFIED`).
- Where policy requires no-regression and new-code thresholds, the plan MUST include a delta/threshold verification task that reports, with post-change figures from the single gate run:
	- baseline coverage, from the `Phase 0 baseline` artifact,
- Each changed file meets the coverage thresholds and shows no drop against the `Phase 0 baseline`; a new file has no pre-change run and is judged against the thresholds. New behavior is tested.
Any regression test task expected to fail must be tagged with `[expect-fail]` and include an auditable evidence artifact per `evidence-and-timestamp-conventions`.
- `minor-audit` plans MUST include baseline evidence tasks (static baselines and the `Phase 0 baseline` test-suite run), targeted verification evidence tasks read from the gate run, and end-state evidence tasks.
- `minor-audit` execution/validation/audit MUST fail closed when `spec.md` or `user-story.md` exists unexpectedly in the active folder, when the explicit `## Acceptance Criteria` section is missing from `issue.md`, when required Phase 0 artifacts are missing, or when checklist state contradicts evidence on disk.
````

### extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md

````text
description: 'Atomic plan format and toolchain contract shared by planning and execution agents. Use when generating, validating, or executing atomic plans with Phase 0, baseline capture, and final QA loops.'
Shared rules for atomic plan formatting, Phase 0 requirements, baseline capture, and final QA loops.
- Enforcing Phase 0 baseline capture and final QA loops.
1) Baseline capture block
- baseline capture for each language that has explicit baseline command tasks in the plan: static baselines (format, lint, type check, and analyzer findings) and, for each language with mandatory coverage policy, one `Phase 0 baseline` run of its test gate (one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, one Jest coverage run).
	- one baseline artifact per baseline command step (no aggregate-only baseline artifact)
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
	- baseline test-step artifacts for languages with mandatory coverage policy MUST include the pass and fail counts and numeric coverage headline values in `Output Summary:` (repo-wide percent and the percent of each in-scope file), read from the one parallel gate run.
- final-QC test commands for languages with mandatory coverage policy MUST run in coverage mode and record numeric post-change coverage values from the single gate run in `Output Summary:`, compared with the `Phase 0 baseline` run of the same gate.
	- Phase 0 baseline capture,
- orchestrator MUST delegate to executor to run Phase 0 only,
- orchestrator MUST checkpoint Phase 0 evidence before branching.
Branching after Phase 0:
## Phase 0 Requirements
Phase 0 carries no routine policy-read task. Agents still follow the reading order defined in `policy-compliance-order`, and a plan that keeps a policy-read task stays valid.
Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched and, for each language in scope with coverage policy, one `Phase 0 baseline` run of its test gate: one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, and one Jest coverage run where TypeScript is in scope. Each test-suite baseline artifact records the pass and fail counts, the repo-wide coverage, and the coverage of each in-scope file. The final gate's run of the same gate is compared with it: no new failing test, no per-file or repo-wide coverage drop, the thresholds still apply, and new behavior is tested. A new file has no pre-change run and is judged against the thresholds. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.
A plan written before this rule that captures static baselines only stays valid: preflight does not return it as a defect, its final gate reads coverage against the thresholds, and its audit records `N/A - no pre-change run`.
For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless these artifacts exist:
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.
Evidence paths in plan tasks MUST resolve to `<FEATURE>/evidence/<kind>/`. A plan that names an alternative location (e.g., `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`) fails preflight validation and must be corrected before execution begins.
For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless these artifacts exist:
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.
- The approved plan MUST include explicit baseline and final-QC coverage capture tasks: the `Phase 0 baseline` run and the final gate run, each one run of the language's parallel gate.
- Baseline and final-QC artifacts MUST record numeric coverage values (not placeholders such as `UNVERIFIED`).
- Where policy requires no-regression and new-code thresholds, the plan MUST include a delta/threshold verification task that reports, with post-change figures from the single gate run:
	- baseline coverage, from the `Phase 0 baseline` artifact,
- Each changed file meets the coverage thresholds and shows no drop against the `Phase 0 baseline`; a new file has no pre-change run and is judged against the thresholds. New behavior is tested.
Any regression test task expected to fail must be tagged with `[expect-fail]` and include an auditable evidence artifact per `evidence-and-timestamp-conventions`.
- **Check that the task-ordering does not make the condition unsatisfiable.** No rule covers this. A gate that runs a test path containing deliberately-failing cases added by an earlier task, before the later task that makes them pass, cannot exit 0. A baseline captured after a write-mode formatter has already repaired pre-existing drift becomes either a blanket waiver or makes a later gate unsatisfiable. Read each acceptance condition against the state the plan will actually be in when its task runs.
- `minor-audit` plans MUST include baseline evidence tasks (static baselines and the `Phase 0 baseline` test-suite run), targeted verification evidence tasks read from the gate run, and end-state evidence tasks.
- `minor-audit` execution/validation/audit MUST fail closed when `spec.md` or `user-story.md` exists unexpectedly in the active folder, when the explicit `## Acceptance Criteria` section is missing from `issue.md`, when required Phase 0 artifacts are missing, or when checklist state contradicts evidence on disk.
````

### extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md

````text
description: 'Atomic plan format and toolchain contract shared by planning and execution agents. Use when generating, validating, or executing atomic plans with Phase 0, baseline capture, and final QA loops.'
Shared rules for atomic plan formatting, Phase 0 requirements, baseline capture, and final QA loops.
- Enforcing Phase 0 baseline capture and final QA loops.
1) Baseline capture block
- baseline capture for each language that has explicit baseline command tasks in the plan: static baselines (format, lint, type check, and analyzer findings) and, for each language with mandatory coverage policy, one `Phase 0 baseline` run of its test gate (one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, one Jest coverage run).
	- one baseline artifact per baseline command step (no aggregate-only baseline artifact)
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
	- baseline test-step artifacts for languages with mandatory coverage policy MUST include the pass and fail counts and numeric coverage headline values in `Output Summary:` (repo-wide percent and the percent of each in-scope file), read from the one parallel gate run.
- final-QC test commands for languages with mandatory coverage policy MUST run in coverage mode and record numeric post-change coverage values from the single gate run in `Output Summary:`, compared with the `Phase 0 baseline` run of the same gate.
	- Phase 0 baseline capture,
- orchestrator MUST delegate to executor to run Phase 0 only,
- orchestrator MUST checkpoint Phase 0 evidence before branching.
Branching after Phase 0:
## Phase 0 Requirements
Phase 0 carries no routine policy-read task. Agents still follow the reading order defined in `policy-compliance-order`, and a plan that keeps a policy-read task stays valid.
Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched and, for each language in scope with coverage policy, one `Phase 0 baseline` run of its test gate: one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, and one Jest coverage run where TypeScript is in scope. Each test-suite baseline artifact records the pass and fail counts, the repo-wide coverage, and the coverage of each in-scope file. The final gate's run of the same gate is compared with it: no new failing test, no per-file or repo-wide coverage drop, the thresholds still apply, and new behavior is tested. A new file has no pre-change run and is judged against the thresholds. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.
A plan written before this rule that captures static baselines only stays valid: preflight does not return it as a defect, its final gate reads coverage against the thresholds, and its audit records `N/A - no pre-change run`.
For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless these artifacts exist:
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.
Evidence paths in plan tasks MUST resolve to `<FEATURE>/evidence/<kind>/`. A plan that names an alternative location (e.g., `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`) fails preflight validation and must be corrected before execution begins.
For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless these artifacts exist:
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.
- The approved plan MUST include explicit baseline and final-QC coverage capture tasks: the `Phase 0 baseline` run and the final gate run, each one run of the language's parallel gate.
- Baseline and final-QC artifacts MUST record numeric coverage values (not placeholders such as `UNVERIFIED`).
- Where policy requires no-regression and new-code thresholds, the plan MUST include a delta/threshold verification task that reports, with post-change figures from the single gate run:
	- baseline coverage, from the `Phase 0 baseline` artifact,
- Each changed file meets the coverage thresholds and shows no drop against the `Phase 0 baseline`; a new file has no pre-change run and is judged against the thresholds. New behavior is tested.
Any regression test task expected to fail must be tagged with `[expect-fail]` and include an auditable evidence artifact per `evidence-and-timestamp-conventions`.
- `minor-audit` plans MUST include baseline evidence tasks (static baselines and the `Phase 0 baseline` test-suite run), targeted verification evidence tasks read from the gate run, and end-state evidence tasks.
- `minor-audit` execution/validation/audit MUST fail closed when `spec.md` or `user-story.md` exists unexpectedly in the active folder, when the explicit `## Acceptance Criteria` section is missing from `issue.md`, when required Phase 0 artifacts are missing, or when checklist state contradicts evidence on disk.
````

### extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md

````text
description: 'Atomic plan format and toolchain contract shared by planning and execution agents. Use when generating, validating, or executing atomic plans with Phase 0, baseline capture, and final QA loops.'
Shared rules for atomic plan formatting, Phase 0 requirements, baseline capture, and final QA loops.
- Enforcing Phase 0 baseline capture and final QA loops.
1) Baseline capture block
- baseline capture for each language that has explicit baseline command tasks in the plan: static baselines (format, lint, type check, and analyzer findings) and, for each language with mandatory coverage policy, one `Phase 0 baseline` run of its test gate (one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, one Jest coverage run).
	- one baseline artifact per baseline command step (no aggregate-only baseline artifact)
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
	- baseline test-step artifacts for languages with mandatory coverage policy MUST include the pass and fail counts and numeric coverage headline values in `Output Summary:` (repo-wide percent and the percent of each in-scope file), read from the one parallel gate run.
- final-QC test commands for languages with mandatory coverage policy MUST run in coverage mode and record numeric post-change coverage values from the single gate run in `Output Summary:`, compared with the `Phase 0 baseline` run of the same gate.
	- Phase 0 baseline capture,
- orchestrator MUST delegate to executor to run Phase 0 only,
- orchestrator MUST checkpoint Phase 0 evidence before branching.
Branching after Phase 0:
## Phase 0 Requirements
Phase 0 carries no routine policy-read task. Agents still follow the reading order defined in `policy-compliance-order`, and a plan that keeps a policy-read task stays valid.
Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched and, for each language in scope with coverage policy, one `Phase 0 baseline` run of its test gate: one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, and one Jest coverage run where TypeScript is in scope. Each test-suite baseline artifact records the pass and fail counts, the repo-wide coverage, and the coverage of each in-scope file. The final gate's run of the same gate is compared with it: no new failing test, no per-file or repo-wide coverage drop, the thresholds still apply, and new behavior is tested. A new file has no pre-change run and is judged against the thresholds. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.
A plan written before this rule that captures static baselines only stays valid: preflight does not return it as a defect, its final gate reads coverage against the thresholds, and its audit records `N/A - no pre-change run`.
For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless these artifacts exist:
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.
- The approved plan MUST include explicit baseline and final-QC coverage capture tasks: the `Phase 0 baseline` run and the final gate run, each one run of the language's parallel gate.
- Baseline and final-QC artifacts MUST record numeric coverage values (not placeholders such as `UNVERIFIED`).
- Where policy requires no-regression and new-code thresholds, the plan MUST include a delta/threshold verification task that reports, with post-change figures from the single gate run:
	- baseline coverage, from the `Phase 0 baseline` artifact,
- Each changed file meets the coverage thresholds and shows no drop against the `Phase 0 baseline`; a new file has no pre-change run and is judged against the thresholds. New behavior is tested.
Any regression test task expected to fail must be tagged with `[expect-fail]` and include an auditable evidence artifact per `evidence-and-timestamp-conventions`.
- `minor-audit` plans MUST include baseline evidence tasks (static baselines and the `Phase 0 baseline` test-suite run), targeted verification evidence tasks read from the gate run, and end-state evidence tasks.
- `minor-audit` execution/validation/audit MUST fail closed when `spec.md` or `user-story.md` exists unexpectedly in the active folder, when the explicit `## Acceptance Criteria` section is missing from `issue.md`, when required Phase 0 artifacts are missing, or when checklist state contradicts evidence on disk.
````

### .claude/skills/feature-review-workflow/SKILL.md

````text
### Baseline and evidence
- Use `artifacts/pr_context.appendix.txt` as the baseline-diff appendix for raw evidence and exact anchors.
- Baseline fields are read from the plan's `Phase 0 baseline` artifact. A baseline field is recorded as `N/A - no pre-change run` only for a language or file with no pre-change run (a new file, or an item whose plan predates the `Phase 0 baseline` rule and captured static baselines only), and the comparison line then reads `Baseline: N/A - no pre-change run -> Post-change: <percent>. Change: N/A.`
        - Coverage thresholds (threshold precedence per `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md`: when the repository's root `CLAUDE.md` states line or branch coverage thresholds, those thresholds govern; otherwise the default thresholds below govern; each metric falls back independently, so a root `CLAUDE.md` that states only one of the two thresholds governs only that metric). The branch threshold applies only to branch-capable languages — TypeScript, Python, and C#. PowerShell is a coverage language and is fully subject to the line threshold and the no-regression requirement, but Pester measures command (instruction) coverage and line coverage only, so no branch percentage exists to evaluate and no branch threshold applies to it (see `.claude/rules/powershell.md`). Do not flag a missing PowerShell branch figure as FAIL:
          - Modified files (changed but previously existing): line coverage >= 85%, and branch coverage >= 75% for branch-capable languages, read from the single gate run, new behavior is tested, and no regression on changed lines relative to the `Phase 0 baseline`. Flag as FAIL otherwise.
     - `## Scope and Baseline`
   - Use the resolved base branch in the baseline section.
     - coverage below the governing thresholds defined in step 5 (repo-wide per language, modified files including any regression on changed lines against the `Phase 0 baseline`, or new files)
````

### .agents/skills/feature-review-workflow/SKILL.md

````text
### Baseline and evidence
- Use `artifacts/pr_context.appendix.txt` as the baseline-diff appendix for raw evidence and exact anchors.
- Baseline fields are read from the plan's `Phase 0 baseline` artifact. A baseline field is recorded as `N/A - no pre-change run` only for a language or file with no pre-change run (a new file, or an item whose plan predates the `Phase 0 baseline` rule and captured static baselines only), and the comparison line then reads `Baseline: N/A - no pre-change run -> Post-change: <percent>. Change: N/A.`
        - Coverage thresholds: when the repository's root `CLAUDE.md` states a line or branch coverage threshold, that threshold governs; otherwise the defaults govern (line 85%, branch 75% for branch-capable languages). Each metric falls back independently. New files and modified files must meet the governing line threshold (and the branch threshold where measured), read from the single gate run, and new behavior is tested; modified files must also show no regression on changed lines against the `Phase 0 baseline`. Repo-wide coverage per language must meet the governing thresholds. Flag as FAIL otherwise.
     - `## Scope and Baseline`
   - Use the resolved base branch in the baseline section.
     - coverage below the governing thresholds defined in step 5 (repo-wide per language, modified files including any regression on changed lines against the `Phase 0 baseline`, or new files)
````

### .github/skills/feature-review-workflow/SKILL.md

````text
### Baseline and evidence
- Use `artifacts/pr_context.appendix.txt` as the baseline-diff appendix for raw evidence and exact anchors.
- Baseline fields are read from the plan's `Phase 0 baseline` artifact. A baseline field is recorded as `N/A - no pre-change run` only for a language or file with no pre-change run (a new file, or an item whose plan predates the `Phase 0 baseline` rule and captured static baselines only), and the comparison line then reads `Baseline: N/A - no pre-change run -> Post-change: <percent>. Change: N/A.`
     - `## Scope and Baseline`
   - Use the resolved base branch in the baseline section.
     - coverage below the governing thresholds (the root `CLAUDE.md` thresholds when stated, otherwise the defaults: line 85%, branch 75% for branch-capable languages; repo-wide per language, modified files including any regression on changed lines against the `Phase 0 baseline`, or new files)
- Report a covered file above 800 lines that has no entry in `config/file-size-baseline.json`, and any added or increased entry in `config/file-size-baseline.json`, as a blocking policy finding.
````

### extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md

````text
### Baseline and evidence
- Use `artifacts/pr_context.appendix.txt` as the baseline-diff appendix for raw evidence and exact anchors.
- Baseline fields are read from the plan's `Phase 0 baseline` artifact. A baseline field is recorded as `N/A - no pre-change run` only for a language or file with no pre-change run (a new file, or an item whose plan predates the `Phase 0 baseline` rule and captured static baselines only), and the comparison line then reads `Baseline: N/A - no pre-change run -> Post-change: <percent>. Change: N/A.`
        - Coverage thresholds (threshold precedence per `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md`: when the repository's root `CLAUDE.md` states line or branch coverage thresholds, those thresholds govern; otherwise the default thresholds below govern; each metric falls back independently, so a root `CLAUDE.md` that states only one of the two thresholds governs only that metric). The branch threshold applies only to branch-capable languages — TypeScript, Python, and C#. PowerShell is a coverage language and is fully subject to the line threshold and the no-regression requirement, but Pester measures command (instruction) coverage and line coverage only, so no branch percentage exists to evaluate and no branch threshold applies to it (see `.claude/rules/powershell.md`). Do not flag a missing PowerShell branch figure as FAIL:
          - Modified files (changed but previously existing): line coverage >= 85%, and branch coverage >= 75% for branch-capable languages, read from the single gate run, new behavior is tested, and no regression on changed lines relative to the `Phase 0 baseline`. Flag as FAIL otherwise.
     - `## Scope and Baseline`
   - Use the resolved base branch in the baseline section.
     - coverage below the governing thresholds defined in step 5 (repo-wide per language, modified files including any regression on changed lines against the `Phase 0 baseline`, or new files)
````

### extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md

````text
### Baseline and evidence
- Use `artifacts/pr_context.appendix.txt` as the baseline-diff appendix for raw evidence and exact anchors.
- Baseline fields are read from the plan's `Phase 0 baseline` artifact. A baseline field is recorded as `N/A - no pre-change run` only for a language or file with no pre-change run (a new file, or an item whose plan predates the `Phase 0 baseline` rule and captured static baselines only), and the comparison line then reads `Baseline: N/A - no pre-change run -> Post-change: <percent>. Change: N/A.`
        - Coverage thresholds: when the repository's root `CLAUDE.md` states a line or branch coverage threshold, that threshold governs; otherwise the defaults govern (line 85%, branch 75% for branch-capable languages). Each metric falls back independently. New files and modified files must meet the governing line threshold (and the branch threshold where measured), read from the single gate run, and new behavior is tested; modified files must also show no regression on changed lines against the `Phase 0 baseline`. Repo-wide coverage per language must meet the governing thresholds. Flag as FAIL otherwise.
     - `## Scope and Baseline`
   - Use the resolved base branch in the baseline section.
     - coverage below the governing thresholds defined in step 5 (repo-wide per language, modified files including any regression on changed lines against the `Phase 0 baseline`, or new files)
````

### extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md

````text
### Baseline and evidence
- Use `artifacts/pr_context.appendix.txt` as the baseline-diff appendix for raw evidence and exact anchors.
- Baseline fields are read from the plan's `Phase 0 baseline` artifact. A baseline field is recorded as `N/A - no pre-change run` only for a language or file with no pre-change run (a new file, or an item whose plan predates the `Phase 0 baseline` rule and captured static baselines only), and the comparison line then reads `Baseline: N/A - no pre-change run -> Post-change: <percent>. Change: N/A.`
     - `## Scope and Baseline`
   - Use the resolved base branch in the baseline section.
     - coverage below the governing thresholds (the root `CLAUDE.md` thresholds when stated, otherwise the defaults: line 85%, branch 75% for branch-capable languages; repo-wide per language, modified files including any regression on changed lines against the `Phase 0 baseline`, or new files)
- Report a covered file above 800 lines that has no entry in `config/file-size-baseline.json`, and any added or increased entry in `config/file-size-baseline.json`, as a blocking policy finding.
````

### .claude/skills/orchestrate/SKILL.md

````text
All other `artifacts/` sub-paths (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`) are FORBIDDEN for evidence output and will be blocked by the `enforce-evidence-locations.ps1` PreToolUse hook.
````

### .agents/skills/orchestrate/SKILL.md

````text
All other `artifacts/` sub-paths (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`) are FORBIDDEN for evidence output and will be blocked by the `enforce-evidence-locations.ps1` PreToolUse hook.
````

### extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md

````text
All other `artifacts/` sub-paths (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`) are FORBIDDEN for evidence output and will be blocked by the `enforce-evidence-locations.ps1` PreToolUse hook.
````

### extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md

````text
All other `artifacts/` sub-paths (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`) are FORBIDDEN for evidence output and will be blocked by the `enforce-evidence-locations.ps1` PreToolUse hook.
````

### .claude/agents/atomic-planner.md

````text
- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)
3. Include explicit coverage-bearing baseline and final-QA testing tasks for each language where policy requires coverage: static baseline tasks, one `Phase 0 baseline` run of each test gate, and final-QA coverage tasks with per-file coverage read from the single gate run and compared with the `Phase 0 baseline`.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md

````text
- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)
3. Include explicit coverage-bearing baseline and final-QA testing tasks for each language where policy requires coverage: static baseline tasks, one `Phase 0 baseline` run of each test gate, and final-QA coverage tasks with per-file coverage read from the single gate run and compared with the `Phase 0 baseline`.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### .codex/agents/atomic-planner.toml

````text
- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)
3. Include explicit coverage-bearing baseline and final-QA testing tasks for each language where policy requires coverage: static baseline tasks, one `Phase 0 baseline` run of each test gate, and final-QA coverage tasks with per-file coverage read from the single gate run and compared with the `Phase 0 baseline`.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml

````text
- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)
3. Include explicit coverage-bearing baseline and final-QA testing tasks for each language where policy requires coverage: static baseline tasks, one `Phase 0 baseline` run of each test gate, and final-QA coverage tasks with per-file coverage read from the single gate run and compared with the `Phase 0 baseline`.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### .claude/agents/atomic-executor.md

````text
The Phase 0 baseline and the final gate are each one run of these gates, and the final gate is compared with the `Phase 0 baseline`: no new failing test and no per-file or repo-wide coverage drop.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md

````text
The Phase 0 baseline and the final gate are each one run of these gates, and the final gate is compared with the `Phase 0 baseline`: no new failing test and no per-file or repo-wide coverage drop.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### .codex/agents/atomic-executor.toml

````text
The Phase 0 baseline and the final gate are each one run of these gates, and the final gate is compared with the `Phase 0 baseline`: no new failing test and no per-file or repo-wide coverage drop.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor.toml

````text
The Phase 0 baseline and the final gate are each one run of these gates, and the final gate is compared with the `Phase 0 baseline`: no new failing test and no per-file or repo-wide coverage drop.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### .claude/agents/feature-review.md

````text
3. `docs/features/active/<feature-or-selected-version>/feature-audit.<timestamp>.md` — acceptance criteria verification relative to baseline
- PR context appendix artifact (secondary; full baseline diff)
- **Modified files** (files that existed before and were changed): line coverage >= 85%, and branch coverage >= 75% for branch-capable languages, read from the single gate run, new behavior is tested, and no regression on changed lines relative to the `Phase 0 baseline`.
The branch threshold applies only to branch-capable languages — TypeScript, Python, and C#. PowerShell is a coverage language and is fully subject to the line threshold and the no-regression requirement, but Pester measures command (instruction) coverage and line coverage only, so no branch percentage exists to evaluate and no branch threshold applies to it (see `.claude/rules/powershell.md`). Do not record FAIL for an absent PowerShell branch figure.
   - For each modified file: if coverage on changed lines has regressed from the `Phase 0 baseline`, or line or branch coverage, read from the single gate run, is below the governing modified-file thresholds defined in Coverage Thresholds, flag as FAIL and add to remediation triggers.
- Report a covered file above 800 lines that has no entry in `config/file-size-baseline.json`, and any added or increased entry in `config/file-size-baseline.json`, as a blocking policy finding.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
The reviewer MUST scan the branch diff for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. Each such file is a FAIL-level finding. Record each occurrence under the heading `## Evidence Location Compliance` in `policy-audit.<timestamp>.md`, listing the file path and its canonical replacement. Use `validate_evidence_locations.py --root .` to scan for violations; if the script exits non-zero, add all reported paths as FAIL findings.
````

### extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md

````text
3. `docs/features/active/<feature-or-selected-version>/feature-audit.<timestamp>.md` — acceptance criteria verification relative to baseline
- PR context appendix artifact (secondary; full baseline diff)
- **Modified files** (files that existed before and were changed): line coverage >= 85%, and branch coverage >= 75% for branch-capable languages, read from the single gate run, new behavior is tested, and no regression on changed lines relative to the `Phase 0 baseline`.
The branch threshold applies only to branch-capable languages — TypeScript, Python, and C#. PowerShell is a coverage language and is fully subject to the line threshold and the no-regression requirement, but Pester measures command (instruction) coverage and line coverage only, so no branch percentage exists to evaluate and no branch threshold applies to it (see `.claude/rules/powershell.md`). Do not record FAIL for an absent PowerShell branch figure.
   - For each modified file: if coverage on changed lines has regressed from the `Phase 0 baseline`, or line or branch coverage, read from the single gate run, is below the governing modified-file thresholds defined in Coverage Thresholds, flag as FAIL and add to remediation triggers.
- Report a covered file above 800 lines that has no entry in `config/file-size-baseline.json`, and any added or increased entry in `config/file-size-baseline.json`, as a blocking policy finding.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
The reviewer MUST scan the branch diff for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. Each such file is a FAIL-level finding. Record each occurrence under the heading `## Evidence Location Compliance` in `policy-audit.<timestamp>.md`, listing the file path and its canonical replacement. Use `validate_evidence_locations.py --root .` to scan for violations; if the script exits non-zero, add all reported paths as FAIL findings.
````

### .codex/agents/feature-review.toml

````text
3. `docs/features/active/<feature-or-selected-version>/feature-audit.<timestamp>.md` — acceptance criteria verification relative to baseline
- PR context appendix artifact (secondary; full baseline diff)
- **New and modified files**: line coverage must meet the governing line threshold (and the branch threshold where measured), read from the single gate run, and new behavior is tested; modified files must also show no regression on changed lines against the `Phase 0 baseline`.
   - For each modified file: if line coverage has regressed from the `Phase 0 baseline` or, read from the single gate run, is below the governing line threshold, flag as FAIL and add to remediation triggers.
- Report a covered file above 800 lines that has no entry in `config/file-size-baseline.json`, and any added or increased entry in `config/file-size-baseline.json`, as a blocking policy finding.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
The reviewer MUST scan the branch diff for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. Each such file is a FAIL-level finding. Record each occurrence under the heading `## Evidence Location Compliance` in `policy-audit.<timestamp>.md`, listing the file path and its canonical replacement. Use `validate_evidence_locations.py --root .` to scan for violations; if the script exits non-zero, add all reported paths as FAIL findings.
````

### extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml

````text
3. `docs/features/active/<feature-or-selected-version>/feature-audit.<timestamp>.md` — acceptance criteria verification relative to baseline
- PR context appendix artifact (secondary; full baseline diff)
- **New and modified files**: line coverage must meet the governing line threshold (and the branch threshold where measured), read from the single gate run, and new behavior is tested; modified files must also show no regression on changed lines against the `Phase 0 baseline`.
   - For each modified file: if line coverage has regressed from the `Phase 0 baseline` or, read from the single gate run, is below the governing line threshold, flag as FAIL and add to remediation triggers.
- Report a covered file above 800 lines that has no entry in `config/file-size-baseline.json`, and any added or increased entry in `config/file-size-baseline.json`, as a blocking policy finding.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
The reviewer MUST scan the branch diff for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. Each such file is a FAIL-level finding. Record each occurrence under the heading `## Evidence Location Compliance` in `policy-audit.<timestamp>.md`, listing the file path and its canonical replacement. Use `validate_evidence_locations.py --root .` to scan for violations; if the script exits non-zero, add all reported paths as FAIL findings.
````

### .codex/agents/atomic-planner-c1.toml

````text
- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)
3. Include explicit coverage-bearing baseline and final-QA testing tasks for each language where policy requires coverage: static baseline tasks, one `Phase 0 baseline` run of each test gate, and final-QA coverage tasks with per-file coverage read from the single gate run and compared with the `Phase 0 baseline`.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c1.toml

````text
- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)
3. Include explicit coverage-bearing baseline and final-QA testing tasks for each language where policy requires coverage: static baseline tasks, one `Phase 0 baseline` run of each test gate, and final-QA coverage tasks with per-file coverage read from the single gate run and compared with the `Phase 0 baseline`.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### .codex/agents/atomic-planner-c2.toml

````text
- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)
3. Include explicit coverage-bearing baseline and final-QA testing tasks for each language where policy requires coverage: static baseline tasks, one `Phase 0 baseline` run of each test gate, and final-QA coverage tasks with per-file coverage read from the single gate run and compared with the `Phase 0 baseline`.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c2.toml

````text
- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)
3. Include explicit coverage-bearing baseline and final-QA testing tasks for each language where policy requires coverage: static baseline tasks, one `Phase 0 baseline` run of each test gate, and final-QA coverage tasks with per-file coverage read from the single gate run and compared with the `Phase 0 baseline`.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### .codex/agents/atomic-planner-c3.toml

````text
- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)
3. Include explicit coverage-bearing baseline and final-QA testing tasks for each language where policy requires coverage: static baseline tasks, one `Phase 0 baseline` run of each test gate, and final-QA coverage tasks with per-file coverage read from the single gate run and compared with the `Phase 0 baseline`.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3.toml

````text
- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)
3. Include explicit coverage-bearing baseline and final-QA testing tasks for each language where policy requires coverage: static baseline tasks, one `Phase 0 baseline` run of each test gate, and final-QA coverage tasks with per-file coverage read from the single gate run and compared with the `Phase 0 baseline`.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### .codex/agents/atomic-planner-c3-elevated.toml

````text
- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)
3. Include explicit coverage-bearing baseline and final-QA testing tasks for each language where policy requires coverage: static baseline tasks, one `Phase 0 baseline` run of each test gate, and final-QA coverage tasks with per-file coverage read from the single gate run and compared with the `Phase 0 baseline`.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3-elevated.toml

````text
- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)
3. Include explicit coverage-bearing baseline and final-QA testing tasks for each language where policy requires coverage: static baseline tasks, one `Phase 0 baseline` run of each test gate, and final-QA coverage tasks with per-file coverage read from the single gate run and compared with the `Phase 0 baseline`.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### .codex/agents/atomic-planner-c4.toml

````text
- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)
3. Include explicit coverage-bearing baseline and final-QA testing tasks for each language where policy requires coverage: static baseline tasks, one `Phase 0 baseline` run of each test gate, and final-QA coverage tasks with per-file coverage read from the single gate run and compared with the `Phase 0 baseline`.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c4.toml

````text
- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)
3. Include explicit coverage-bearing baseline and final-QA testing tasks for each language where policy requires coverage: static baseline tasks, one `Phase 0 baseline` run of each test gate, and final-QA coverage tasks with per-file coverage read from the single gate run and compared with the `Phase 0 baseline`.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### .codex/agents/atomic-executor-c1.toml

````text
The Phase 0 baseline and the final gate are each one run of these gates, and the final gate is compared with the `Phase 0 baseline`: no new failing test and no per-file or repo-wide coverage drop.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c1.toml

````text
The Phase 0 baseline and the final gate are each one run of these gates, and the final gate is compared with the `Phase 0 baseline`: no new failing test and no per-file or repo-wide coverage drop.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### .codex/agents/atomic-executor-c2.toml

````text
The Phase 0 baseline and the final gate are each one run of these gates, and the final gate is compared with the `Phase 0 baseline`: no new failing test and no per-file or repo-wide coverage drop.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c2.toml

````text
The Phase 0 baseline and the final gate are each one run of these gates, and the final gate is compared with the `Phase 0 baseline`: no new failing test and no per-file or repo-wide coverage drop.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### .codex/agents/atomic-executor-c3.toml

````text
The Phase 0 baseline and the final gate are each one run of these gates, and the final gate is compared with the `Phase 0 baseline`: no new failing test and no per-file or repo-wide coverage drop.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3.toml

````text
The Phase 0 baseline and the final gate are each one run of these gates, and the final gate is compared with the `Phase 0 baseline`: no new failing test and no per-file or repo-wide coverage drop.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### .codex/agents/atomic-executor-c3-elevated.toml

````text
The Phase 0 baseline and the final gate are each one run of these gates, and the final gate is compared with the `Phase 0 baseline`: no new failing test and no per-file or repo-wide coverage drop.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3-elevated.toml

````text
The Phase 0 baseline and the final gate are each one run of these gates, and the final gate is compared with the `Phase 0 baseline`: no new failing test and no per-file or repo-wide coverage drop.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### .codex/agents/atomic-executor-c4.toml

````text
The Phase 0 baseline and the final gate are each one run of these gates, and the final gate is compared with the `Phase 0 baseline`: no new failing test and no per-file or repo-wide coverage drop.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c4.toml

````text
The Phase 0 baseline and the final gate are each one run of these gates, and the final gate is compared with the `Phase 0 baseline`: no new failing test and no per-file or repo-wide coverage drop.
All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.
If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
````

### docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md

````text
| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
- TypeScript baseline coverage artifact: [path or `N/A - out of scope`]
- PowerShell baseline coverage artifact: [path or `N/A - out of scope`]
Baseline coverage is read from the plan's `Phase 0 baseline` artifact, one run of the language's gate. A baseline cell or field records `N/A - no pre-change run` only for a new file or for a plan written before the `Phase 0 baseline` rule that captured static baselines only.
**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope (or `N/A - no pre-change run` where that record applies), plus changed/new-code coverage when required.
**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.
| **Baseline Coverage Documented** | [✅/❌/N/A] [PASS/FAIL/N/A] | **Baseline:** [N]% lines, [N]% functions, read from the `Phase 0 baseline` artifact (or `N/A - no pre-change run`)<br>**Command:** `Invoke-PoshQCParallelTest` or `poetry run pytest -n auto` (one run of the gate)<br>**Artifact:** [path]<br>**Timestamp:** [YYYY-MM-DD HH:MM] |
| **No Coverage Regression** | [✅/❌/N/A] [PASS/FAIL/N/A] | **Post-change coverage:** [N]% lines, [N]% functions, read from the single gate run<br>**Change:** [+/-N]% lines, [+/-N]% functions against the `Phase 0 baseline`<br>**Status:** [No regression / Regression detected: justification]<br>**Example:** "Baseline: 85.2% → Post-change: 87.1% (+1.9%) ✅ PASS" |
- [Language]: Baseline: [N]% [unit] (from the `Phase 0 baseline` artifact, or `N/A - no pre-change run`) -> Post-change: [N]% [unit]. Change: [+/-N]% [unit delta] (or N/A). New/changed-code coverage: [N]% or `N/A - out of scope`. Disposition: [PASS/FAIL/N/A]. Evidence: [artifact path(s)].
| **At or below the 800-line hard limit** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Report logical line counts for all covered files. FAIL for a file above 800 lines without a `config/file-size-baseline.json` entry, a baselined file that grew, or an added or increased baseline entry. Note each file at or above 700 lines as a non-blocking Warning. Note any exceptions.] |
#### 3A.1 Tooling & Baseline
#### 3B.1 Tooling & Baseline
| **Cohesive and at or below the 800-line hard limit** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Report logical line counts. FAIL for a file above 800 lines without a baseline entry or a baselined file that grew. Note each file at or above 700 lines as a non-blocking Warning.] |
#### 3C.1 Tooling & Baseline
| **At or below the 800-line hard limit** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Report logical line counts. FAIL for a file above 800 lines without a baseline entry or a baselined file that grew. Note each file at or above 700 lines as a non-blocking Warning.] |
| Test File Size | [N] logical lines | [✅/❌] PASS at or below 800 lines, FAIL above 800 without a baseline entry; note a non-blocking Warning at or above 700 lines |
**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is missing.
- [✅/⚠️/❌] Tooling & Baseline: [Brief status]
- [✅/⚠️/❌] Tooling & Baseline: [Brief status]
````

### extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md

````text
| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
- TypeScript baseline coverage artifact: [path or `N/A - out of scope`]
- PowerShell baseline coverage artifact: [path or `N/A - out of scope`]
Baseline coverage is read from the plan's `Phase 0 baseline` artifact, one run of the language's gate. A baseline cell or field records `N/A - no pre-change run` only for a new file or for a plan written before the `Phase 0 baseline` rule that captured static baselines only.
**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope (or `N/A - no pre-change run` where that record applies), plus changed/new-code coverage when required.
**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.
| **Baseline Coverage Documented** | [✅/❌/N/A] [PASS/FAIL/N/A] | **Baseline:** [N]% lines, [N]% functions, read from the `Phase 0 baseline` artifact (or `N/A - no pre-change run`)<br>**Command:** `Invoke-PoshQCParallelTest` or `poetry run pytest -n auto` (one run of the gate)<br>**Artifact:** [path]<br>**Timestamp:** [YYYY-MM-DD HH:MM] |
| **No Coverage Regression** | [✅/❌/N/A] [PASS/FAIL/N/A] | **Post-change coverage:** [N]% lines, [N]% functions, read from the single gate run<br>**Change:** [+/-N]% lines, [+/-N]% functions against the `Phase 0 baseline`<br>**Status:** [No regression / Regression detected: justification]<br>**Example:** "Baseline: 85.2% → Post-change: 87.1% (+1.9%) ✅ PASS" |
- [Language]: Baseline: [N]% [unit] (from the `Phase 0 baseline` artifact, or `N/A - no pre-change run`) -> Post-change: [N]% [unit]. Change: [+/-N]% [unit delta] (or N/A). New/changed-code coverage: [N]% or `N/A - out of scope`. Disposition: [PASS/FAIL/N/A]. Evidence: [artifact path(s)].
| **At or below the 800-line hard limit** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Report logical line counts for all covered files. FAIL for a file above 800 lines without a `config/file-size-baseline.json` entry, a baselined file that grew, or an added or increased baseline entry. Note each file at or above 700 lines as a non-blocking Warning. Note any exceptions.] |
#### 3A.1 Tooling & Baseline
#### 3B.1 Tooling & Baseline
| **Cohesive and at or below the 800-line hard limit** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Report logical line counts. FAIL for a file above 800 lines without a baseline entry or a baselined file that grew. Note each file at or above 700 lines as a non-blocking Warning.] |
#### 3C.1 Tooling & Baseline
| **At or below the 800-line hard limit** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Report logical line counts. FAIL for a file above 800 lines without a baseline entry or a baselined file that grew. Note each file at or above 700 lines as a non-blocking Warning.] |
| Test File Size | [N] logical lines | [✅/❌] PASS at or below 800 lines, FAIL above 800 without a baseline entry; note a non-blocking Warning at or above 700 lines |
**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is missing.
- [✅/⚠️/❌] Tooling & Baseline: [Brief status]
- [✅/⚠️/❌] Tooling & Baseline: [Brief status]
````

### docs/features/templates/policy_audit/AGENTS.md

````text
   - **Fill in baseline coverage metrics** from the plan's `Phase 0 baseline` artifact (per language that has coverage). Record a baseline field as `N/A - no pre-change run` only for a new file or for a plan written before the `Phase 0 baseline` rule that captured static baselines only.
     - Compare post-change coverage with the `Phase 0 baseline` to verify no regression (per language).
     - Use concrete examples showing calculations: "Baseline: 85.2% → Post-change: 87.1% (+1.9%) ✅"
     - No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.
     - If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.
     - Metrics summary (with deterministic baseline/post-change/new code coverage)
````

### extensions/drm-copilot/resources/templates/policy_audit/AGENTS.md

````text
   - **Fill in baseline coverage metrics** from the plan's `Phase 0 baseline` artifact (per language that has coverage). Record a baseline field as `N/A - no pre-change run` only for a new file or for a plan written before the `Phase 0 baseline` rule that captured static baselines only.
     - Compare post-change coverage with the `Phase 0 baseline` to verify no regression (per language).
     - Use concrete examples showing calculations: "Baseline: 85.2% → Post-change: 87.1% (+1.9%) ✅"
     - No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.
     - If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.
     - Metrics summary (with deterministic baseline/post-change/new code coverage)
````
