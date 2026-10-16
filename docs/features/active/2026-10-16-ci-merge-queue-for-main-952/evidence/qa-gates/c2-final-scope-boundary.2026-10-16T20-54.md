# Remediation cycle 2 - changed-path scope boundary (P4-T10)

Timestamp: 2026-10-16T20-54
Command: git diff --name-only 21c7338aeccb0122d7cbed24c994039741478bce HEAD; git status --porcelain; git diff -U0 21c7338aeccb0122d7cbed24c994039741478bce HEAD -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T17-18.md; git diff -U0 21c7338aeccb0122d7cbed24c994039741478bce HEAD -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-followups.md
EXIT_CODE: 0
Output Summary: OUTSIDE_PATHS=10 FEATURE_NON_EVIDENCE_PATHS=2 PY_PATHS=0 FROZEN_SURFACES_CHANGED=0 PLAN_NONCHECKBOX_CHANGES=0 POLICY_FOLLOWUPS_APPEND_ONLY=true

`REM_BASE_SHA=21c7338aeccb0122d7cbed24c994039741478bce` (from `c2-branch-state.2026-10-16T19-36.md`); HEAD at the time of the commands: `547e18d7b81037a95ab0dede12e91056f2a6e504`. All four commands exited 0.

## Union of name-only and porcelain paths, excluding FEATURE/evidence/

Outside the feature folder (10), equal to `## Files Written`:

```text
.claude/hooks/hook-docs-only-diff.ps1
.codex/hooks/hook-docs-only-diff.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1
tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1
tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1
tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1
tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1
tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1
tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1
```

Inside the feature folder, non-evidence (2):

```text
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-followups.md
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T17-18.md   (committed diff and porcelain ` M`)
```

Every other path is under `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/` (31 committed evidence files in the name-only list: 4 under `other/`, 9 under `regression-testing/`, 18 under `remediation-baseline/`; 14 untracked `??` Phase 4 evidence files in the porcelain list).

## Absence checks

- Frozen surfaces (`.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `.github/workflows/_poshqc.yml`, `.claude/hooks/hook-command-invocation.ps1`, the PoshQC module and settings including both `pester.runsettings.psd1` copies, `config/poshqc-coverage.json`, `.claude/rules/**`, `.github/instructions/**`): none present (`FROZEN_SURFACES_CHANGED=0`).
- Both gates (`.claude/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`) and all four helper copies (`enforce-epic-merge-gate-command.ps1`): none present.
- `FEATURE/spec.md`: not present.
- `.py` paths: none (`PY_PATHS=0`).

## Plan diff (committed range)

- 38 lines begin `-- [ ] [P` and 38 lines begin `+- [x] [P`; no other `-` or `+` line besides the `--- a/` and `+++ b/` headers.
- Pairing check: after replacing the leading `-- [ ] ` and `+- [x] ` with one common token, every resulting line occurs exactly twice (0 unpaired lines), so each removed line has an added line with the same text and `[x]` in place of `[ ]` (`PLAN_NONCHECKBOX_CHANGES=0`).
- The working-tree modification of the plan (porcelain ` M`) holds only the Phase 4 check-offs made after the Phase 3 commit.

## policy-followups.md diff

One hunk, `@@ -47,0 +48,28 @@`, and no removed line other than the `--- a/` header (`POLICY_FOLLOWUPS_APPEND_ONLY=true`).
