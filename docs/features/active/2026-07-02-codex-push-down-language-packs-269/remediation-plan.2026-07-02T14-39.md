# Remediation Plan: Codex Push-Down Language Packs (#269) Whitespace Findings

- Issue: #269
- Feature folder: `docs/features/active/2026-07-02-codex-push-down-language-packs-269`
- Primary requirements source: `docs/features/active/2026-07-02-codex-push-down-language-packs-269/remediation-inputs.2026-07-02T14-39.md`
- Review artifacts:
  - `docs/features/active/2026-07-02-codex-push-down-language-packs-269/policy-audit.2026-07-02T14-39.md`
  - `docs/features/active/2026-07-02-codex-push-down-language-packs-269/code-review.2026-07-02T14-39.md`
  - `docs/features/active/2026-07-02-codex-push-down-language-packs-269/feature-audit.2026-07-02T14-39.md`
- PR context:
  - `artifacts/pr_context.summary.txt`
  - `artifacts/pr_context.appendix.txt`
- Original feature plans:
  - `docs/features/active/2026-07-02-codex-push-down-language-packs-269/plan.2026-07-02T13-15.md`
  - `docs/features/active/2026-07-02-codex-push-down-language-packs-269/plan.2026-07-02T13-20.md`
- Work mode: `full-feature`

### Phase 0 — Remediation Baseline

- [x] [P0-T1] Read AGENTS.md, .agents/skills/general-code-change/SKILL.md, .agents/skills/general-unit-test/SKILL.md, .agents/skills/policy-compliance-order/SKILL.md, .agents/skills/evidence-and-timestamp-conventions/SKILL.md, .agents/skills/atomic-plan-contract/SKILL.md, and docs/features/active/2026-07-02-codex-push-down-language-packs-269/remediation-inputs.2026-07-02T14-39.md.
  - Acceptance: Write `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/remediation-baseline/phase0-whitespace-instructions-read.md` with `Timestamp:`, `Policy Order:`, and the explicit file list in this order: `AGENTS.md`, `.agents/skills/general-code-change/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, `.agents/skills/policy-compliance-order/SKILL.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, `docs/features/active/2026-07-02-codex-push-down-language-packs-269/remediation-inputs.2026-07-02T14-39.md`.
- [x] [P0-T2] Capture the current whitespace failure by running `git diff --check 51867789325248793a241886033c3ce86681f9ad...HEAD`.
  - Acceptance: Write `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/remediation-baseline/whitespace-check-baseline.md` with `Timestamp:`, `Command: git diff --check 51867789325248793a241886033c3ce86681f9ad...HEAD`, `EXIT_CODE: 1`, and `Output Summary:` listing each reported path and line.

### Phase 1 — Whitespace Remediation

- [x] [P1-T1] Remove trailing whitespace from `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/baseline/typescript-jest-coverage-baseline.md` on lines reported by the baseline whitespace check.
  - Acceptance: The file content is unchanged except for removing trailing whitespace from the reported lines.
- [x] [P1-T2] Remove trailing whitespace from `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/typescript-jest-coverage-final.md` on the line reported by the baseline whitespace check.
  - Acceptance: The file content is unchanged except for removing trailing whitespace from the reported line.
- [x] [P1-T3] Remove the extra blank line at EOF from `docs/features/active/2026-07-02-codex-push-down-language-packs-269/research/2026-07-02T13-23-codex-push-down-language-packs-269-research.md`.
  - Acceptance: The research artifact content remains unchanged except for the EOF blank-line correction.

### Phase 2 — Final Validation

- [x] [P2-T1] Rerun `git diff --check 51867789325248793a241886033c3ce86681f9ad...HEAD`.
  - Acceptance: Write `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/whitespace-check-final.md` with `Timestamp:`, `Command: git diff --check 51867789325248793a241886033c3ce86681f9ad...HEAD`, `EXIT_CODE: 0`, and `Output Summary: no whitespace errors reported`.
- [x] [P2-T2] Rerun `python scripts/dev_tools/validate_evidence_locations.py --root .`.
  - Acceptance: Write `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/evidence-location-validation-whitespace-remediation.md` with `Timestamp:`, `Command: python scripts/dev_tools/validate_evidence_locations.py --root .`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P2-T3] Re-run the feature review workflow for docs/features/active/2026-07-02-codex-push-down-language-packs-269 and capture the generated post-remediation policy-audit, code-review, and feature-audit artifact paths.
  - Acceptance: Write `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/post-remediation-review-artifacts.md` with `Timestamp:`, `Issue: #269`, and the exact generated artifact paths.
- [x] [P2-T4] Validate the generated post-remediation policy-audit artifact with mcp__drm_copilot.validate_orchestration_artifacts using artifact_type policy-audit.
  - Acceptance: Record the validator `ok: true` result in `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/post-remediation-review-validation.md`.
- [x] [P2-T5] Validate the generated post-remediation code-review artifact with mcp__drm_copilot.validate_orchestration_artifacts using artifact_type code-review.
  - Acceptance: Record the validator `ok: true` result in `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/post-remediation-review-validation.md`.
- [x] [P2-T6] Validate the generated post-remediation feature-audit artifact with mcp__drm_copilot.validate_orchestration_artifacts using artifact_type feature-audit.
  - Acceptance: Record the validator `ok: true` result in `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/post-remediation-review-validation.md`.
- [x] [P2-T7] Confirm the generated post-remediation review outcome.
  - Acceptance: The generated feature-audit reports `REVIEW_STATUS: PASS`, or the plan records new remediation-required findings with exact artifact paths under `docs/features/active/2026-07-02-codex-push-down-language-packs-269/`.
