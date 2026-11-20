# Remediation Inputs: codex-agent-role-config (Issue #306)

Timestamp: 2026-07-04T14-41
Feature Folder: `docs/features/active/2026-07-04-codex-agent-role-config-306`
Primary Requirements Source: `docs/features/active/2026-07-04-codex-agent-role-config-306/spec.md`
Review Artifacts:
- `docs/features/active/2026-07-04-codex-agent-role-config-306/policy-audit.2026-07-04T14-41.md`
- `docs/features/active/2026-07-04-codex-agent-role-config-306/code-review.2026-07-04T14-41.md`
- `docs/features/active/2026-07-04-codex-agent-role-config-306/feature-audit.2026-07-04T14-41.md`

## Remediation Trigger Summary

Remediation is required because:

1. Policy audit contains FAIL findings.
2. Current toolchain/hygiene checks failed:
   - `git diff --check f530d0e3ae7c5d0974b72cf0956e862dd94041c5..HEAD` exited 1.
   - `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` exited 1.
3. Code review contains a blocker for issue-specific hardcoding in reusable orchestration skills.
4. Feature audit has two FAIL acceptance criteria.

## Fix List

1. Remove issue #306-specific plan-path invariants from reusable skills.
   - Files:
     - `.agents/skills/orchestrate/SKILL.md`
     - `.agents/skills/orchestrator-workflow/SKILL.md`
     - `.agents/skills/feature-promotion-lifecycle/SKILL.md`
     - `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`
     - `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md`
     - `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-promotion-lifecycle/SKILL.md`
   - Expected behavior: Reusable skills keep generic deterministic `plan*.md` resolution and do not reference `2026-07-04-codex-agent-role-config-306` or `plan.2026-07-04T13-47.md`.
   - Verification:
     - `Select-String -Path <six skill files> -Pattern 'Issue #306 invariant|2026-07-04-codex-agent-role-config-306|plan\.2026-07-04T13-47'` returns no matches.
     - Root and bundled copies remain aligned for the generic plan-path rule.

2. Clean branch whitespace diagnostics.
   - Files: all files reported by current `git diff --check`, including feature evidence Markdown and `spec.md:88`.
   - Expected behavior: No trailing whitespace or blank-at-EOF diagnostics in the branch diff.
   - Verification:
     - `git diff --check f530d0e3ae7c5d0974b72cf0956e862dd94041c5..HEAD` exits 0.

3. Reconcile TypeScript formatting.
   - Files reported by check-only Prettier:
     - `extensions/drm-copilot/src/lib/codex-native-converter/rewrites.ts`
     - `extensions/drm-copilot/src/remove-worktrees.ts`
     - `extensions/drm-copilot/src/workflow-command-arguments.ts`
     - `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`
     - `extensions/drm-copilot/test/extension.push-down-claude-customizations.test.ts`
     - `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts`
   - Expected behavior: TypeScript formatting check passes or a policy-approved baseline exception is documented.
   - Verification:
     - `Push-Location extensions/drm-copilot; npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; Pop-Location` exits 0.

4. Refresh affected evidence and acceptance criteria.
   - Files:
     - `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/git-diff-check.final.md`
     - Any TypeScript formatting evidence updated by remediation.
     - `docs/features/active/2026-07-04-codex-agent-role-config-306/spec.md` if criteria 8 and 9 become supported after fixes.
   - Expected behavior: Evidence reflects current commands, not stale pass records.
   - Verification:
     - Evidence artifacts include `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`.
     - `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exits 0.
     - `mcp__drm_copilot.validate_orchestration_artifacts artifact_type=plan artifact_path=docs/features/active/2026-07-04-codex-agent-role-config-306/plan.2026-07-04T13-47.md` passes.

## Do Not Do

- Do not weaken policy documents or validators.
- Do not leave issue-specific plan paths in reusable skills.
- Do not mark acceptance criteria as checked without current verification evidence.
- Do not ignore `git diff --check` diagnostics in generated evidence.
- Do not claim PR readiness until a re-review passes.

## Required Context Package For Remediation Planning

- Remediation inputs: this file.
- PR context summary: `artifacts/pr_context.summary.txt`
- PR context appendix: `artifacts/pr_context.appendix.txt`
- Review artifacts:
  - `policy-audit.2026-07-04T14-41.md`
  - `code-review.2026-07-04T14-41.md`
  - `feature-audit.2026-07-04T14-41.md`
- Original plan: `docs/features/active/2026-07-04-codex-agent-role-config-306/plan.2026-07-04T13-47.md`
- Requirements: `docs/features/active/2026-07-04-codex-agent-role-config-306/spec.md`
