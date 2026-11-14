# Existing Suites After the Fix (issue #1001)

Timestamp: 2026-10-31T06-23
Command: sh SCRATCH/issue-1001-run.sh SCRATCH/issue-1001-pester.ps1 -Pattern "^(enforce-epic-merge-gate|enforce-pr-author-skill|enforce-model-routing-receipt).*\.Tests\.ps1$" -Paths "tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1,tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1,tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1,tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1" -Tag existing (one Pester process, JUnit to artifacts/pester/pester-junit.xml)
EXIT_CODE: 0

Files run (39): `HOOK_SUITES` (35 files under tests/scripts/claude-hooks whose names start with enforce-epic-merge-gate, enforce-pr-author-skill, or enforce-model-routing-receipt, including the three new EpicModeStrict suites) plus the four named cross-suites:

- tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-merge-gate.EpicModeStrict.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1
- tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1
- tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicModeStrict.Tests.ps1
- tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1
- tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1
- tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.BodyNumber.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.EpicModeStrict.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1
- tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1
- tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1
- tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1
- tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1

Existing-test-file check: `git diff --name-status MERGE_BASE -- tests` (MERGE_BASE = ccec4eba82e272d27f7d81c0e0657a93110de5fb) lists only the three added EpicModeStrict suites (status A); no existing test file is modified.

Output Summary (read from artifacts/pester/pester-junit.xml): tests=721, failures=0, errors=0, skipped=0, suites=39. Includes enforce-epic-merge-gate.MergeQueue, .DocsOnly, .Authorization, and .GreenCiDecision, which assert the final deny text verbatim.
