# P6-T17 Format check (read-only) Phase 6 files

Timestamp: 2026-10-09T00-38
Command: sh SCRATCH/run-ps.sh SCRATCH/ps-format-check.ps1 .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 .claude/hooks/enforce-pr-author-skill-helpers.ps1 .claude/hooks/enforce-pr-author-skill.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1
EXIT_CODE: 0
Output Summary:
  FORMAT-SUMMARY ChangedCount=0

## Full output

```text
FORMAT file=.claude/hooks/enforce-pr-author-skill.artifact-root.ps1 Changed=False
FORMAT file=.claude/hooks/enforce-pr-author-skill-helpers.ps1 Changed=False
FORMAT file=.claude/hooks/enforce-pr-author-skill.ps1 Changed=False
FORMAT file=tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 Changed=False
FORMAT file=tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 Changed=False
FORMAT file=tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 Changed=False
FORMAT file=tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 Changed=False
FORMAT file=tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 Changed=False
FORMAT file=tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 Changed=False
FORMAT file=tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 Changed=False
FORMAT-SUMMARY ChangedCount=0
```

## CMD-GIT-STATUS (git status --porcelain)

```text
 M .claude/hooks/enforce-pr-author-skill-helpers.ps1
 M .claude/hooks/enforce-pr-author-skill.ps1
 M docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/gate-wiring-order.md
 M docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/plan.2026-10-08T13-54.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1
 M extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
 M tests/fixtures/worktree-resolution/README.md
 M tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1
 M tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1
 M tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
 M tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
 M tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1
 M tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1
?? .claude/hooks/enforce-pr-author-skill.artifact-root.ps1
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/analyze-p6.2026-10-09T00-38.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/context-exists-removed-issue824.2026-10-09T00-37.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/context-exists-removed-pra-tests.2026-10-09T00-35.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/context-exists-removed-repo.2026-10-09T00-38.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/context-exists-removed-target-resolution.2026-10-09T00-36.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/epic-checkpoint-isolation-pra-tests.2026-10-09T00-35.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/epic-state-isolation-p6.2026-10-09T00-38.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/format-p6.2026-10-09T00-38.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/regression-testing/pr-author-artifact-root-fail-before.2026-10-09T00-28.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/regression-testing/pr-author-artifact-root-pass-after.2026-10-09T00-38.md
?? extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.artifact-root.ps1
?? tests/fixtures/worktree-resolution/pr-author/item-own-epic-mode/artifacts/pr_body_1.md
?? tests/fixtures/worktree-resolution/pr-author/item-own-epic-mode/artifacts/pr_body_1.receipt.json
?? tests/fixtures/worktree-resolution/pr-author/item-own-epic-mode/artifacts/pr_context.summary.txt
?? tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
```

Every status line names a P6 file, a fixture copy, the fixture README, a mirror, CORE, WLOG, a FEATURE evidence path, or PLAN.
