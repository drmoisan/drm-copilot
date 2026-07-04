# Feature Audit: Issue #232 Harden Orchestrate Skill

**Audit Date:** 2026-06-25
**Feature Folder:** `docs/features/active/2026-06-24-harden-orchestrate-skill-232`
**Base Branch:** `main`
**Head Branch:** `feature/harden-orchestrate-skill-232` at `8ed845dfa0af0a60cc01e04de6d58467ad29f188`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

## Scope and Baseline

- **Base branch:** `main` resolved as `origin/main` at `4a20713a4be32afa759915b3e7e24ac4f005eb35`
- **Head branch/commit:** `feature/harden-orchestrate-skill-232` at `8ed845dfa0af0a60cc01e04de6d58467ad29f188`
- **Merge base:** `4a20713a4be32afa759915b3e7e24ac4f005eb35`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/`
  - Additional evidence: current review command outputs recorded in `policy-audit.2026-06-25T13-51.md`
- **Feature folder used:** `docs/features/active/2026-06-24-harden-orchestrate-skill-232`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` contains `- Work Mode: full-feature`, so the authoritative acceptance criteria are `spec.md` and `user-story.md`.
- **Scope note:** The user supplied base branch, merge-base SHA, feature folder, PR context artifact paths, and Issue #232 canonical number. The PR context was current for branch head `8ed845d` before this review wrote new artifacts.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/spec.md` - primary feature specification
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/user-story.md` - user-story acceptance criteria

### From `spec.md`

1. `orchestrate` defines the already-active main session as the canonical orchestrator runtime and distinguishes that runtime from any optional orchestrator profile.
2. `orchestrate` requires read-only scope assessment and route selection before lifecycle MCP tools such as `new_potential_entry`, `potential_to_issue`, and `new_active_feature_folder`.
3. The lifecycle contract requires a pre-issue branch before potential-entry creation and a branch rename after promotion so the final branch includes the numeric issue number.
4. `orchestrate` requires checkpoint state with `route_id`, `required_agents`, `required_skills`, `required_mcp_tools`, and derived `work-mode` before implementation edits, formatters, tests, staging, commits, or implementation delegation.
5. Lifecycle MCP usage is ordered as route metadata persistence, pre-issue branch setup, potential entry creation, potential-to-issue promotion, post-promotion branch rename, and active feature folder creation.
6. Violation handling requires blocked checkpoint state and remediation documentation when implementation work occurs before required orchestration gates.
7. Review delegation naming uses `feature-reviewer` for route-required receipts and preserves `feature-review` only for the skill/workflow name.
8. Executable pre-implementation gates in `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` block implementation edits, formatters, tests, staging, commits, and implementation delegation until Issue #232 route metadata, lifecycle readiness, and checkpoint state are present.
9. Lifecycle sequencing and completion enforcement in `scripts/dev_tools/validate_orchestrator_state.py`, `.codex/hooks/enforce-checkpoint-monotonic.ps1`, `.claude/hooks/enforce-checkpoint-monotonic.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, and `.claude/hooks/enforce-completion-consistency.ps1` reject out-of-order Issue #232 checkpoint transitions and reject completion without required PR and CI evidence.
10. MCP-only template resolver enforcement exposes `resolve_policy_audit_template_asset` through the TypeScript MCP files and `scripts/dev_tools/validate_policy_audit_artifact.py` rejects fallback template behavior.
11. PR and current-head CI completion gates require `pr_gate` evidence, require `ci_gate.head_sha` to match `pr_gate.head_sha`, and use `scripts/orchestration/Invoke-CiGateParser.ps1` to emit CI head SHA metadata.
12. Canonical Issue #232 remediation evidence is stored under the feature folder `evidence/` path and records fail-before exceptions, regression results, QA gates, and acceptance traceability without using non-canonical artifact evidence paths.

### From `user-story.md`

1. The skill defines an entry-point contract that identifies the already-active main session as the orchestrator runtime and distinguishes that runtime from any optional orchestrator profile.
2. The skill requires read-only scope assessment and route selection before lifecycle MCP tools such as `new_potential_entry`, `potential_to_issue`, and `new_active_feature_folder`.
3. The lifecycle contract requires pre-issue branch creation before potential-entry creation and branch rename after promotion so the final branch includes the numeric issue number.
4. The skill defines a pre-implementation gate requiring matching checkpoint state, route metadata, and lifecycle readiness before edits, formatters, tests, staging, commits, or implementation delegation.
5. The skill defines ordered lifecycle MCP usage and derives `work-mode` from the selected route.
6. The skill defines violation handling when implementation work occurs before the required orchestration gates.
7. The skill aligns review-delegate naming with route-required `feature-reviewer` receipts while preserving `feature-review` as the skill/workflow name.
8. The companion lifecycle skill is updated when branch sequencing belongs in `feature-promotion-lifecycle` rather than only in `orchestrate`.
9. As an orchestrating agent, I am blocked by executable pre-implementation gates in `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` until Issue #232 route metadata, lifecycle readiness, and checkpoint state are present.
10. As a repository maintainer, I can verify lifecycle sequencing and completion enforcement through the validator and checkpoint hooks so Issue #232 cannot be marked complete from out-of-order checkpoints or without required PR and CI evidence.
11. As a policy reviewer, I can verify MCP-only template resolver enforcement through the TypeScript MCP files and `scripts/dev_tools/validate_policy_audit_artifact.py`.
12. As a repository maintainer, I can verify Issue #232 DONE status requires `pr_gate`, requires `ci_gate.head_sha` to match `pr_gate.head_sha`, and uses `scripts/orchestration/Invoke-CiGateParser.ps1` to capture current-head CI metadata.
13. As an auditor, I can find canonical Issue #232 remediation evidence under the feature folder `evidence/` path.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S1 | Canonical main-session orchestrator runtime | PASS | `.agents/skills/orchestrate/SKILL.md` and bundled skill resources are changed; PR context feature excerpts record completion. | `artifacts/pr_context.summary.txt` review | No blocker found for this criterion. |
| S2 | Read-only scope assessment before lifecycle MCP tools | PASS | Feature docs and prior evidence record sequencing checks. | `rg -n "read-only scope assessment" .agents/skills/orchestrate/SKILL.md` | No blocker found for this criterion. |
| S3 | Pre-issue branch before potential entry and branch rename after promotion | PASS | `final-branch-sequencing.md` records required phrase checks. | Evidence artifact command in `final-branch-sequencing.md` | No blocker found for this criterion. |
| S4 | Checkpoint state before implementation operations | PARTIAL | Skill text and validators exist, but executable enforcement does not cover all operation surfaces. | Config and hook inspection; direct hook command-payload invocation | Formatters, tests, staging, commits, and delegation remain outside the new pre-implementation hook. |
| S5 | Ordered lifecycle MCP usage | PASS | `final-lifecycle-order.md` records stale ordering checks. | Evidence artifact command in `final-lifecycle-order.md` | No blocker found for this criterion. |
| S6 | Violation handling with blocked checkpoint state and remediation documentation | PASS | Orchestrate skill and feature evidence reference blocked state and remediation requirements. | PR context and feature evidence review | No blocker found for this criterion. |
| S7 | Review delegation naming uses `feature-reviewer` receipts | PASS | Routing config changed from `feature-review` to `feature-reviewer`; final review-delegate evidence passed. | `rg -n "feature-reviewer" config/orchestration-routing.json` | No blocker found for this criterion. |
| S8 | Executable pre-implementation gates block edits, formatters, tests, staging, commits, and delegation | FAIL | `.claude/settings.json` does not register the new Claude hook; Codex bundled config wires the hook only to `Write|Edit`; command payload invocation returns allow. | `Select-String .claude/settings.json`; `Select-String extensions/.../.codex/config.toml`; direct hook invocation | This is the primary acceptance blocker. |
| S9 | Lifecycle sequencing and completion enforcement reject out-of-order and incomplete completion states | PASS | PoshQC tests and orchestrator-state validator passed; current state validator returned ok with `require_complete=true`. | `mcp__drm_copilot.validate_orchestration_artifacts` | No blocker found for this criterion. |
| S10 | MCP-only template resolver enforcement | PASS | MCP resolver was available and used to create this audit; TypeScript tests passed. | `mcp__drm_copilot.resolve_policy_audit_template_asset`; `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | No blocker found for this criterion. |
| S11 | PR and current-head CI completion gates | PASS | Validator and completion evidence exist; orchestrator-state complete validation passed. | `mcp__drm_copilot.validate_orchestration_artifacts` | No blocker found for this criterion. |
| S12 | Canonical Issue #232 evidence storage | PASS | Feature evidence is under `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/`; PR context lists those artifacts. | `Get-ChildItem docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence -Recurse` | No blocker found for this criterion. |
| U1-U8 | User-story instruction and lifecycle wording criteria | PASS | User-story criteria U1 through U8 align with skill and lifecycle document changes. | PR context summary and diff inspection | No blocker found for these criteria. |
| U9 | User-story executable pre-implementation gate criterion | FAIL | Same enforcement gap as S8. | Same as S8 | Source checkbox is checked, but review evidence does not support PASS. |
| U10-U13 | User-story validation, template resolver, PR/CI, and evidence criteria | PASS | Validator, MCP resolver, and evidence checks passed except policy coverage thresholds recorded separately. | Commands listed in policy audit Appendix B | No blocker found for these criteria. |

## Summary

**Overall Feature Readiness:** BLOCKED

**Criteria summary:**
- **PASS:** 23 criteria or grouped criteria
- **PARTIAL:** 1 criterion
- **UNVERIFIED:** 0 criteria
- **FAIL:** 2 criteria

**Top gaps preventing PASS:**

1. `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` is not registered in `.claude/settings.json`.
2. The Codex pre-implementation gate is registered only for `Write|Edit`, not for Bash command or delegation surfaces required by Issue #232.
3. The hook is hardcoded to Issue #232 state and needs generalization or strict scoping.

**Recommended follow-up verification steps:**

1. Add registration and tests proving Claude and Codex pre-implementation gates run for every required operation surface.
2. Add tests proving non-232 workflows are not blocked by Issue #232 constants, or explicitly scope the hook so it only applies during Issue #232 remediation.
3. Rerun `git diff --check`, PoshQC tests with coverage, Python coverage, TypeScript full package coverage, and artifact validators.

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, passing criteria may remain checked. Criteria evaluated as PARTIAL or FAIL require remediation before they can be treated as delivered. The source files currently have all listed criteria checked; this audit records that the executable pre-implementation gate criteria are not supported by the reviewed evidence and require remediation.

### AC Status Summary

- Source: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/spec.md`, `docs/features/active/2026-06-24-harden-orchestrate-skill-232/user-story.md`
- Total AC items: 25
- Checked off (delivered): 22
- Remaining (unchecked or requiring reconciliation): 3
- Items remaining: Spec criterion 4 partial, spec criterion 8 fail, user-story criterion 9 fail.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-06-24-harden-orchestrate-skill-232/spec.md` | 12 | 10 | 2 | Checkbox source currently marks all items checked; remediation must reconcile S4 and S8. |
| `docs/features/active/2026-06-24-harden-orchestrate-skill-232/user-story.md` | 13 | 12 | 1 | Checkbox source currently marks all items checked; remediation must reconcile U9. |

No source-file checkbox edits were made during this review because remediation is required and the review is not an implementation-fix pass.
