Timestamp: 2026-04-11T23:33:38-04:00
Sources:
- `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-coverage-summary.2026-04-11T22-03.md`
- `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/regression-testing/ts-changed-existing-source-coverage.2026-04-11T22-54.md`
- `extensions/drm-copilot/src/mcp-tool-inputs.ts`
- `extensions/drm-copilot/src/mcp-tools.ts`
- `extensions/drm-copilot/src/workflow-command-arguments.ts`
Output Summary:
- Current failing modified existing TypeScript production files: `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `extensions/drm-copilot/src/mcp-tools.ts`, and `extensions/drm-copilot/src/workflow-command-arguments.ts`.
- The current proof remains fail-closed because unresolved entries include both `uncovered` executable lines and `unmatched` changed lines that do not appear in the current `lcov.info` line map.

Unresolved Coverage Inventory:

1. `extensions/drm-copilot/src/mcp-tool-inputs.ts`
   - Classification: `uncovered`
   - Proof lines: `240, 241, 242, 243, 244, 245`
   - Source construct: `resolvePolicyAuditTemplateAssetToolInput(...)` declaration and first statements at lines `240-245`

2. `extensions/drm-copilot/src/mcp-tools.ts`
   - Classification: `unmatched`
   - Proof lines: `525-531`
   - Source construct: `case "resolve_policy_audit_template_asset"` dispatch block at lines `525-531`

3. `extensions/drm-copilot/src/workflow-command-arguments.ts`
   - Classification: `uncovered`
   - Proof lines: `75, 164, 165, 166, 167, 254, 255, 256, 257`
   - Source constructs:
     - line `75`: blank separator immediately after `ResolvePolicyAuditTemplateAssetInput`
     - lines `164-167`: `validatePolicyAuditTemplateAssetSelector(...)` call body
     - lines `254-257`: `isAbsolutePathLike(...)` body

4. `extensions/drm-copilot/src/workflow-command-arguments.ts`
   - Classification: `unmatched`
   - Proof lines: `571-598`
   - Source construct: `resolvePolicyAuditTemplateAssetInvocation(...)` declaration and direct invocation path at lines `571-598`
