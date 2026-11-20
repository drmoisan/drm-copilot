# Feature Audit: expose-policy-audit-template-surface (#141)

**Audit Date:** 2026-04-11  
**Timestamp:** 2026-04-11T23-23  
**Base Branch:** `development`  
**Feature Folder:** `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141`

## Scope and Baseline

- **Base branch:** `development` (resolved in `artifacts/pr_context.summary.txt` as `origin/development @ 771979d530949ccb492fc79e1ec1f47cbb057401`)
- **Head ref context:** `feature/expose-policy-audit-template-surface-141 @ 771979d530949ccb492fc79e1ec1f47cbb057401`
- **PR context limitation:** the canonical PR context still shows an empty committed diff range because the reviewed feature work remains uncommitted in the working tree.
- **Work mode:** `full-feature`
- **Authoritative acceptance-criteria source files:** `spec.md` and `user-story.md`
- **Acceptance-criteria source rule applied:** `user-story.md` contains the actionable checkbox inventory for this review; `spec.md` provides the matching behavioral contract.
- **Evidence sources used:**
  - `artifacts/pr_context.summary.txt`
  - `artifacts/pr_context.appendix.txt`
  - prior review artifacts dated `2026-04-11T22-54`
  - remediation evidence dated `2026-04-11T22-54`
  - fresh reviewer reruns of `npm run lint`, `npm run typecheck`, and `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`

## Acceptance Criteria Inventory

Source: `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/user-story.md`

1. The published `drmCopilotExtension` MCP surface exposes the bundled policy-audit template markdown file and the bundled policy-audit `AGENTS.md` guidance file through a canonical tool or resource path that is available outside the source repository layout.
2. The VS Code extension contributes a matching command for retrieving or copying the same policy-audit template assets from the bundled extension surface.
3. Repository references that currently hardcode `docs/features/templates/policy_audit/AGENTS.md` are redirected to the MCP server surface, or any remaining exceptions are explicitly documented with rationale.
4. Regression coverage proves the new MCP and extension command behavior, and repository documentation or prompt references remain consistent with the published automation surface.

Spec parity note: `spec.md` continues to mirror the same four outcomes through the Behavior, Inputs / Outputs, API / CLI Surface, and Implementation Strategy sections.

## Acceptance Criteria Evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|-----------|--------|----------|--------------------------|-------|
| AC-1: MCP surface exposes both bundled policy-audit assets | PASS | The additive MCP tool remains wired through `src/mcp-tools.ts` and the shared service, and the bundled assets remain present under `extensions/drm-copilot/resources/templates/policy_audit/`. | `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` | Remediation did not regress the previously verified surface. |
| AC-2: VS Code command exposes the same asset surface | PASS | The command contribution remains present in `extensions/drm-copilot/package.json`, and the command tests still pass in the fresh reviewer rerun. | `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` | Remediation did not regress the previously verified command contract. |
| AC-3: Active references were redirected and exceptions were documented | PASS | Active repo guidance still points automation consumers to the MCP surface, and the documented source-artifact exceptions remain recorded in feature evidence. | `rg -n "docs/features/templates/policy_audit/AGENTS\\.md" .agents .codex .github docs extensions/drm-copilot/resources -g '!docs/features/archive/**'` | Remaining references continue to be limited to source-template and historical-evidence contexts. |
| AC-4: Regression coverage and documentation stay consistent with the published surface | FAIL | The remediated evidence now includes a deterministic changed-line proof, but that proof still fails for `mcp-tool-inputs.ts`, `mcp-tools.ts`, and `workflow-command-arguments.ts`, and the refreshed coverage summary still records `remediation required`. | `npm run lint`; `npm run typecheck`; `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` | The coverage-proof gap was analyzed but not closed. No approved exception was found, so AC-4 cannot be reported as complete. |

## Summary

**Overall feature readiness:** **REMEDIATION REQUIRED**

What remains verified:
- The new MCP policy-audit surface remains implemented.
- The matching VS Code command remains implemented.
- The bundled assets and redirected active references remain in place.
- The current workspace still passes lint, typecheck, and the full Jest unit suite with coverage.

What remains open:
1. The remediated changed-line proof still fails closed for three modified existing TypeScript production files.
2. The refreshed coverage summary therefore still records `remediation required`.
3. Because that gate is still open, the feature cannot be reported as PASS and `AC-4` cannot be checked off.

## Acceptance Criteria Check-off

This re-review did not change the acceptance-criteria source files.

- `user-story.md` AC-1 remains checked.
- `user-story.md` AC-2 remains checked.
- `user-story.md` AC-3 remains checked.
- `user-story.md` AC-4 remains unchecked because this review evaluated it as `FAIL`.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/user-story.md`
- Total AC items: 4
- Checked off (delivered): 3
- Remaining (unchecked): 1
- Items remaining:
  - `Regression coverage proves the new MCP and extension command behavior, and repository documentation or prompt references remain consistent with the published automation surface`
