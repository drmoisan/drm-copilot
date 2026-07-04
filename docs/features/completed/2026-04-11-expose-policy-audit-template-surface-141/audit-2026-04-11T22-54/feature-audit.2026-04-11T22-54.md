# Feature Audit: expose-policy-audit-template-surface (#141)

**Audit Date:** 2026-04-11  
**Timestamp:** 2026-04-11T22-54  
**Base Branch:** `development`  
**Feature Folder:** `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141`

## Scope and Baseline

- **Base branch:** `development` (resolved in `artifacts/pr_context.summary.txt` as `origin/development @ 771979d530949ccb492fc79e1ec1f47cbb057401`)
- **Head ref context:** `feature/expose-policy-audit-template-surface-141 @ 771979d530949ccb492fc79e1ec1f47cbb057401`
- **PR context limitation:** the canonical PR context shows an empty committed diff range because the feature work is still uncommitted in the working tree.
- **Work mode:** `full-feature`
- **Authoritative acceptance-criteria source files:** `spec.md` and `user-story.md`
- **Acceptance-criteria source rule applied:** `user-story.md` contains the actionable checkbox acceptance criteria for this review. `spec.md` provides matching behavioral contract text but not a separate checkbox inventory.
- **Evidence sources used:**
  - `artifacts/pr_context.summary.txt`
  - `artifacts/pr_context.appendix.txt`
  - feature-folder evidence under `evidence/baseline/`, `evidence/regression-testing/`, `evidence/other/`, and `evidence/qa-gates/`
  - fresh reviewer reruns of `npm run lint`, `npm run typecheck`, and `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`

## Acceptance Criteria Inventory

Source: `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/user-story.md`

1. The published `drmCopilotExtension` MCP surface exposes the bundled policy-audit template markdown file and the bundled policy-audit `AGENTS.md` guidance file through a canonical tool or resource path that is available outside the source repository layout.
2. The VS Code extension contributes a matching command for retrieving or copying the same policy-audit template assets from the bundled extension surface.
3. Repository references that currently hardcode `docs/features/templates/policy_audit/AGENTS.md` are redirected to the MCP server surface, or any remaining exceptions are explicitly documented with rationale.
4. Regression coverage proves the new MCP and extension command behavior, and repository documentation or prompt references remain consistent with the published automation surface.

Spec parity note: the contract text in `spec.md` mirrors the same four outcomes through the Behavior, Inputs / Outputs, API / CLI Surface, and Implementation Strategy sections.

## Acceptance Criteria Evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|-----------|--------|----------|--------------------------|-------|
| AC-1: MCP surface exposes both bundled policy-audit assets | PASS | Service and MCP wiring exist in `src/repo-automation-service.ts` and `src/mcp-tools.ts`; bundled assets exist under `extensions/drm-copilot/resources/templates/policy_audit/`; source and bundled copies are byte-identical by reviewer hash check. | `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`; reviewer SHA-256 comparison on 2026-04-11T22-54 | The workspace contains the new additive tool `resolve_policy_audit_template_asset` and both bundled assets. |
| AC-2: VS Code command exposes the same asset surface | PASS | Command contribution exists in `package.json`; handler and interactive/direct behavior exist in `src/document-workflow-commands.ts`; command tests cover interactive open, direct open, and copy-to-target behavior. | `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` | The new command `drmCopilotExtension.resolvePolicyAuditTemplateAsset` is registered and tested. |
| AC-3: Active references were redirected and exceptions were documented | PASS | `.github/agents/staged-review.agent.md` now points to the MCP surface; `docs/features/templates/policy_audit/README.md` now distinguishes source-artifact usage from automation usage; `evidence/other/reference-redirection-summary.2026-04-11T22-03.md` documents the preserved exceptions. | `rg -n "docs/features/templates/policy_audit/AGENTS\\.md" .agents .codex .github docs extensions/drm-copilot/resources -g '!docs/features/archive/**'` | Reviewer rerun matches the recorded evidence: remaining references are confined to requirement and historical-evidence files. |
| AC-4: Regression coverage and documentation stay consistent with the published surface | PARTIAL | Regression suites and docs updates exist and the current workspace passes Jest, lint, and typecheck. However `evidence/qa-gates/ts-coverage-summary.2026-04-11T22-03.md` records `Changed/new-code coverage disposition: remediation required`, so the final policy-grade coverage proof is incomplete. | `npm run lint`; `npm run typecheck`; `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` | Behavior coverage for the new tool and command exists, but the approved plan's final coverage-disposition requirement is not closed as PASS. |

## Summary

**Overall feature readiness:** **REMEDIATION REQUIRED**

What is complete:
- The new MCP tool surface exists and is wired through the shared service.
- The matching VS Code command exists and behaves as documented.
- The bundled assets are present and match the source templates.
- The active repository references were redirected and preserved exceptions were documented.
- The current workspace passes `npm run lint`, `npm run typecheck`, and the full Jest unit suite with coverage.

What remains open:
1. The approved plan's final coverage-disposition artifact still reports `remediation required`.
2. Because that policy-grade evidence gap remains open, the review cannot report PASS for the feature as a whole.

## Acceptance Criteria Check-off

This review updated the authoritative checkbox source to reflect the evidence-verified state:
- `user-story.md` AC-1 remains checked.
- `user-story.md` AC-2 remains checked.
- `user-story.md` AC-3 remains checked.
- `user-story.md` AC-4 was reverted to unchecked because the review evaluated it as `PARTIAL`.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/user-story.md`
- Total AC items: 4
- Checked off (delivered): 3
- Remaining (unchecked): 1
- Items remaining:
  - `Regression coverage proves the new MCP and extension command behavior, and repository documentation or prompt references remain consistent with the published automation surface`
