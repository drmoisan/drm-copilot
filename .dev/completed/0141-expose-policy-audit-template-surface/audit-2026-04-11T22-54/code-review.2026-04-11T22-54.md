# Code Review: expose-policy-audit-template-surface (#141)

**Review Date:** 2026-04-11  
**Timestamp:** 2026-04-11T22-54  
**Branch:** working tree review against `development`  
**Feature Folder:** `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141`

## Executive Summary

This review covers the uncommitted working tree implementing the new policy-audit asset surface for `drmCopilotExtension`. The feature work adds the semantic MCP tool `resolve_policy_audit_template_asset`, the matching VS Code command `drmCopilotExtension.resolvePolicyAuditTemplateAsset`, bundled copies of the two policy-audit assets, updated active repository references, and Jest coverage for the new surface.

The implementation itself is present and coherent. Service wiring exists in [repo-automation-service.ts](/c:/Users/DanMoisan/repos/drm-copilot/extensions/drm-copilot/src/repo-automation-service.ts), MCP metadata and dispatch exist in [mcp-tools.ts](/c:/Users/DanMoisan/repos/drm-copilot/extensions/drm-copilot/src/mcp-tools.ts), command registration and behavior exist in [document-workflow-commands.ts](/c:/Users/DanMoisan/repos/drm-copilot/extensions/drm-copilot/src/document-workflow-commands.ts), and the redirected active references are visible in [.github/agents/staged-review.agent.md](/c:/Users/DanMoisan/repos/drm-copilot/.github/agents/staged-review.agent.md) and [README.md](/c:/Users/DanMoisan/repos/drm-copilot/docs/features/templates/policy_audit/README.md). I also re-ran `npm run lint`, `npm run typecheck`, and `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` from `extensions/drm-copilot/`; all three passed in the current workspace.

The blocking gap is in the recorded policy-closure evidence, not in the core implementation. [ts-coverage-summary.2026-04-11T22-03.md](/c:/Users/DanMoisan/repos/drm-copilot/docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-coverage-summary.2026-04-11T22-03.md) explicitly records `Changed/new-code coverage disposition: remediation required`, so the review cannot report PASS against the approved plan and repository policy.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|----------|------|----------|---------|----------------|-----------|----------|
| Major | `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-coverage-summary.2026-04-11T22-03.md` | line 21 | The final coverage disposition remains open. The recorded evidence states that changed-line coverage for modified existing TypeScript files was not deterministically isolated, so repository policy closure was not achieved. | Add deterministic changed/new-code coverage proof for the modified existing TypeScript files, or document an approved exception if deterministic isolation is genuinely impossible, then refresh the coverage summary and QA summary artifacts. | The feature-review contract requires plan- and policy-grade evidence, not only passing unit tests. The current evidence supports implementation completeness, but it does not support a PASS verdict for the final QA/coverage obligation. | `ts-coverage-summary.2026-04-11T22-03.md` line 21; `plan.2026-04-11T22-03.md` P6-T5 acceptance text; fresh reviewer rerun of `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` on 2026-04-11T22-54 |

No additional Blocker or Major implementation defects were found in the reviewed surface.

## TypeScript Audit

### Command and MCP surface alignment

- The shared service exposes `resolvePolicyAuditTemplateAsset()` and returns `assetId`, `bundledSourcePath`, and optional `destinationPath` from a single service contract: [repo-automation-service.ts](/c:/Users/DanMoisan/repos/drm-copilot/extensions/drm-copilot/src/repo-automation-service.ts).
- The MCP surface advertises and dispatches `resolve_policy_audit_template_asset` with `asset` and optional `target_path`: [mcp-tools.ts](/c:/Users/DanMoisan/repos/drm-copilot/extensions/drm-copilot/src/mcp-tools.ts).
- The VS Code command resolves the same contract and either opens the bundled asset or copies it to `-target`: [document-workflow-commands.ts](/c:/Users/DanMoisan/repos/drm-copilot/extensions/drm-copilot/src/document-workflow-commands.ts).

### Asset bundling and parity

- The source and bundled policy-audit assets are byte-identical in the current workspace. Reviewer hash check on 2026-04-11T22-54 showed matching SHA-256 values for:
  - `docs/features/templates/policy_audit/AGENTS.md`
  - `extensions/drm-copilot/resources/templates/policy_audit/AGENTS.md`
  - `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`
  - `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`

### Reference redirection

- Active automation guidance now points to the MCP surface in [.github/agents/staged-review.agent.md](/c:/Users/DanMoisan/repos/drm-copilot/.github/agents/staged-review.agent.md:51).
- The source-template README now distinguishes source artifacts from the published automation surface and points automation consumers to the MCP tool: [README.md](/c:/Users/DanMoisan/repos/drm-copilot/docs/features/templates/policy_audit/README.md:25).
- The extension README documents both the new MCP tool and the new VS Code command: [README.md](/c:/Users/DanMoisan/repos/drm-copilot/extensions/drm-copilot/README.md:24).

## Test Quality Audit

- `test/repo-automation-service.test.ts` covers bundled-source resolution and copy-to-target behavior for the service surface.
- `test/mcp-tool-inputs.test.ts`, `test/mcp-server.test.ts`, and `test/workflow-command-arguments.test.ts` cover selector validation, target-path normalization, tool listing, and MCP dispatch.
- `test/extension.resolve-policy-audit-template.test.ts` covers interactive selection, direct open, and `-target` copy behavior.
- `test/extension.test.ts` confirms the new command is registered exactly once.
- Fresh reviewer rerun result: 16 suites passed, 245 tests passed, overall coverage 94.75% lines / 83.57% branches / 98.65% functions.

## Security / Correctness Checks

| Check | Status | Evidence |
|-------|--------|----------|
| Bundled asset resolution avoids repo-local runtime dependency | PASS | The resolver joins paths under `extensionRoot/resources/templates/policy_audit/` and does not read from `docs/features/templates/policy_audit/` at runtime. |
| Invalid asset selectors fail before service dispatch | PASS | Input validation exists in [workflow-command-arguments.ts](/c:/Users/DanMoisan/repos/drm-copilot/extensions/drm-copilot/src/workflow-command-arguments.ts) and [mcp-tool-inputs.ts](/c:/Users/DanMoisan/repos/drm-copilot/extensions/drm-copilot/src/mcp-tool-inputs.ts); Jest coverage includes invalid-selector tests. |
| Workspace copy behavior creates parent folders and preserves source path reporting | PASS | Service tests verify `mkdirSync`, `copyFileSync`, and result metadata. |

## Scope Notes

The canonical PR-context artifacts are present but show an empty commit range because the branch changes are not committed yet. This review treated that as a baseline limitation to document, not as permission to skip workspace inspection or artifact validation.

## Recommendation

**Needs revision before PASS.**

The `resolve_policy_audit_template_asset` MCP surface and `drmCopilotExtension.resolvePolicyAuditTemplateAsset` command are implemented and tested, and the active repository references were redirected with documented exceptions. The remaining blocker is the final QA/coverage evidence gap recorded by the feature's own coverage-summary artifact.
