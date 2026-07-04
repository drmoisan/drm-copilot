# Remediation Plan: codex-agent-role-config (Issue #306)

- **Issue:** #306
- **Feature Folder:** `docs/features/active/2026-07-04-codex-agent-role-config-306`
- **Plan Path:** `docs/features/active/2026-07-04-codex-agent-role-config-306/remediation-plan.2026-07-04T14-41.md`
- **Primary Requirements Source:** `docs/features/active/2026-07-04-codex-agent-role-config-306/remediation-inputs.2026-07-04T14-41.md`
- **Original Feature Plan:** `docs/features/active/2026-07-04-codex-agent-role-config-306/plan.2026-07-04T13-47.md`
- **Status:** Draft remediation plan

### Phase 0 — Remediation Baseline

- [x] [P0-T1] Read `AGENTS.md`, `.agents/skills/policy-compliance-order/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, `.agents/skills/typescript/SKILL.md`, `.agents/skills/python/SKILL.md`, and `docs/features/active/2026-07-04-codex-agent-role-config-306/remediation-inputs.2026-07-04T14-41.md`, then write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/remediation-baseline/phase0-remediation-instructions-read.md` with `Timestamp:`, `Command: policy/read`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P0-T2] Run `git diff --check f530d0e3ae7c5d0974b72cf0956e862dd94041c5..HEAD` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/remediation-baseline/git-diff-check.before-remediation.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` capturing the current whitespace diagnostics.
- [x] [P0-T3] Run `Push-Location extensions/drm-copilot; npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; Pop-Location` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/remediation-baseline/typescript-prettier-check.before-remediation.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` capturing the current formatting diagnostics.
- [x] [P0-T4] Run `Select-String` over the six root and bundled orchestration skill files for `Issue #306 invariant`, `2026-07-04-codex-agent-role-config-306`, and `plan.2026-07-04T13-47`, then write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/remediation-baseline/reusable-skill-issue306-hardcoding.before-remediation.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

### Phase 1 — Remove Reusable-Skill Issue Hardcoding

- [x] [P1-T1] Update `.agents/skills/orchestrate/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md` to remove the issue #306-specific invariant while preserving the generic deterministic `plan*.md` resolution rule.
- [x] [P1-T2] Update `.agents/skills/orchestrator-workflow/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md` to remove the issue #306-specific invariant while preserving the generic deterministic `plan*.md` resolution rule.
- [x] [P1-T3] Update `.agents/skills/feature-promotion-lifecycle/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-promotion-lifecycle/SKILL.md` to remove the issue #306-specific invariant while preserving the generic deterministic `plan*.md` resolution rule.
- [x] [P1-T4] Run the same `Select-String` hardcoding check from P0-T4 and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/regression-testing/reusable-skill-issue306-hardcoding.pass-after.md` with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` showing no matches.

### Phase 2 — Clean Formatting And Whitespace

- [x] [P2-T1] Remove trailing whitespace and blank-at-EOF diagnostics from added feature evidence and `docs/features/active/2026-07-04-codex-agent-role-config-306/spec.md` without changing evidence meaning.
- [x] [P2-T2] Reconcile TypeScript Prettier findings by running the repository formatter or applying equivalent formatting to the six files reported by P0-T3, then inspect the diff to confirm the changes are formatting-only.
- [x] [P2-T3] Run `git diff --check f530d0e3ae7c5d0974b72cf0956e862dd94041c5` to validate the working tree before the remediation commit, then write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/git-diff-check.remediation.md` with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P2-T4] Run `Push-Location extensions/drm-copilot; npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; Pop-Location` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/typescript-prettier-check.remediation.md` with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`.

### Phase 3 — Final Verification And Re-Review Readiness

- [x] [P3-T1] Run `poetry run black --check .` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/python-black.remediation.md` with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P3-T2] Run `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/evidence-location-validation.remediation.md` with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P3-T3] Run `mcp__drm_copilot.validate_orchestration_artifacts` with `artifact_type=plan` and `artifact_path=docs/features/active/2026-07-04-codex-agent-role-config-306/plan.2026-07-04T13-47.md`, then write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/plan-validation.remediation.md` with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P3-T4] Reconcile `docs/features/active/2026-07-04-codex-agent-role-config-306/spec.md` acceptance criteria 8 and 9 only after P1 through P3 evidence supports PASS, then write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/issue-updates/acceptance-criteria-checkoff.remediation.md` with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P3-T5] Request a feature re-review using the refreshed PR context and all remediation evidence; do not claim PR readiness until the re-review returns `REVIEW_STATUS: PASS`.
