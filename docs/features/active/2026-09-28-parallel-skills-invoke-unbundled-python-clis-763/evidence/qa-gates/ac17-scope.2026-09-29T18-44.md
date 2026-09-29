# AC17 Scope Check Against BASE_SHA (P6-T8)

Timestamp: 2026-09-29T18-44
Command: git diff --name-only 12db46245ba7683b5d6ccb676312a4b22a39b0ce HEAD ; git status --porcelain
EXIT_CODE: 0
Output Summary:
- HEAD at this check: `c2aa6db3` (Phase 5 commit).
- The name-only list contains none of:
  `.claude/hooks/enforce-powershell-batch-budget.ps1`,
  `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`,
  `scripts/dev_tools/push_down_claude_customizations.py`,
  `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`, `.claude/settings.json`,
  `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`.
- Porcelain status lists only paths under FEATURE: ` M` the checklist file
  `plan.2026-09-29T14-14.md` and `??` this phase's seven uncommitted evidence artifacts
  (qa-gates/ac1-ac8-pester, ac11-agent-diff, ac16-python-reference, ac8-hook-diff,
  ac9-invocation-sweep; regression-testing/guard-cli-after-port, guard-repo-after-port).

Diff anchor: BASE_SHA per DV2.

## Full name-only list (BASE_SHA..HEAD)

Non-FEATURE paths (54):
.claude/agents/parallel-orchestrator.md
.claude/hooks/enforce-parallel-abandon-gate.ps1
.claude/lib/bash/abandon-parallel-item.sh
.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1
.claude/lib/parallel-drift/ParallelDrift.psm1
.claude/lib/parallel-drift/ParallelDriftHalt.psm1
.claude/skills/parallel-orchestrate/SKILL.md
.claude/skills/parallel-remove/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/abandon-parallel-item.sh
extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-drift/ParallelDrift.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-drift/ParallelDriftHalt.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-remove/SKILL.md
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
scripts/dev_tools/skill_bundle_contract.py
scripts/dev_tools/skill_bundle_contract_cli.py
scripts/powershell/PoshQC/settings/pester.runsettings.psd1
tests/fixtures/parallel_abandon/gh-close-fails.json
tests/fixtures/parallel_abandon/gh-not-on-path.json
tests/fixtures/parallel_abandon/git-remove-fails.json
tests/fixtures/parallel_abandon/joined-option-form.json
tests/fixtures/parallel_abandon/option-abbreviation.json
tests/fixtures/parallel_abandon/refuse-detach-disposition.json
tests/fixtures/parallel_abandon/refuse-missing-confirmation.json
tests/fixtures/parallel_abandon/success.json
tests/fixtures/parallel_abandon/unknown-option.json
tests/fixtures/parallel_abandon_path/gh
tests/fixtures/parallel_abandon_path/git
tests/fixtures/parallel_abandon_path_git_only/git
tests/fixtures/parallel_drift/error-item-key-missing.json
tests/fixtures/parallel_drift/error-items-not-a-list.json
tests/fixtures/parallel_drift/error-non-object-root.json
tests/fixtures/parallel_drift/escape-without-conflict.json
tests/fixtures/parallel_drift/halt-both-starts-absent.json
tests/fixtures/parallel_drift/halt-drifter-started-later.json
tests/fixtures/parallel_drift/halt-equal-start-timestamps.json
tests/fixtures/parallel_drift/halt-one-pair.json
tests/fixtures/parallel_drift/halt-one-start-absent.json
tests/fixtures/parallel_drift/halt-several-pairs.json
tests/fixtures/parallel_drift/malformed-peer-radius-fails-closed.json
tests/fixtures/parallel_drift/no-escape-empty-changed-paths.json
tests/fixtures/parallel_drift/no-escape-inside-radius.json
tests/fixtures/parallel_drift/non-object-edge-ignored.json
tests/fixtures/parallel_drift/peer-not-in-flight-ignored.json
tests/fixtures/parallel_drift/peer-radius-iso-timestamp-evaluated.json
tests/fixtures/parallel_drift/reversed-existing-edge-not-new.json
tests/fixtures/parallel_drift/tolerated-overlap-under-conflict-tolerance.json
tests/fixtures/parallel_drift_cli/checkpoint.json
tests/fixtures/parallel_drift_cli/config.json
tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1
tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1
tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1
tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1
tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1
tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py
tests/scripts/dev_tools/test_parallel_abandon_token_seam.py
tests/scripts/dev_tools/test_parallel_drift_parity.py
tests/scripts/dev_tools/test_skill_bundle_contract_cli.py
tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py
tests/shell/parallel_abandon.bats
tests/shell/parallel_abandon_parity.bats
tests/shell/parallel_bash_manifest_membership.bats
tests/shell/parallel_payload_only.bats

FEATURE paths (docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/):
plan.2026-09-29T14-14.md and the committed evidence artifacts under evidence/baseline (15),
evidence/other (15), evidence/qa-gates (1), and evidence/regression-testing (20), each named in the
command output and all under FEATURE.
