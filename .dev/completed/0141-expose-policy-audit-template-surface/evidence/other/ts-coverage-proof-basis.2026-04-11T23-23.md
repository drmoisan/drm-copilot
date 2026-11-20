Timestamp: 2026-04-11T23:49:26-04:00
Sources:
- `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/other/ts-coverage-gap-baseline.2026-04-11T23-23.md`
- `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/other/ts-coverage-proof-baseline.2026-04-11T23-23.md`
- `extensions/drm-copilot/coverage/lcov.info`
- `extensions/drm-copilot/src/mcp-tool-inputs.ts`
- `extensions/drm-copilot/src/mcp-tools.ts`
- `extensions/drm-copilot/src/workflow-command-arguments.ts`
Output Summary:
- Every unresolved entry from `P0-T2` was checked against the file-specific `lcov.info` section.
- The focused coverage run from `P1-T5` showed that the policy-audit resolver entry paths execute their adjacent executable bodies even where some declaration, parameter-wrap, or blank separator lines remain zero-hit.
- Entries absent from the file-specific `lcov` line map or shown to be structural signature/separator lines adjacent to covered executable bodies were classified as `non-instrumented structural line`.
- No remaining uncovered executable line was confirmed in `mcp-tool-inputs.ts` or `workflow-command-arguments.ts` after that basis review.

Proof Basis Inventory:

1. `extensions/drm-copilot/src/mcp-tool-inputs.ts` lines `240-245`
   - Classification: `non-instrumented structural line`
   - Exact source text:
     - `240: export function resolvePolicyAuditTemplateAssetToolInput(`
     - `241:   rawInput: unknown,`
     - `242:   fallbackWorkspaceRoot?: string,`
     - `243: ): ResolvePolicyAuditTemplateAssetToolInput {`
     - `244:   const args = asToolArgumentObject(rawInput);`
     - `245:   const workspaceRoot = normalizeWorkspaceRoot(`
   - `lcov.info` line-map status:
     - `240: present, hits=0`
     - `241: present, hits=0`
     - `242: present, hits=0`
     - `243: present, hits=0`
     - `244: present, hits=0`
     - `245: present, hits=0`
   - Basis for structural classification:
     - Adjacent executable body lines `246-267` are present and covered in the same file-specific `lcov` section.
     - The zero-hit range is limited to the multi-line declaration and first wrapped call site of an entry path whose executable body is already covered.

2. `extensions/drm-copilot/src/mcp-tools.ts` lines `525-531`
   - Classification: `non-instrumented structural line`
   - Exact source text:
     - `525:       case "resolve_policy_audit_template_asset": {`
     - `526:         const input = resolvePolicyAuditTemplateAssetToolInput(rawInput);`
     - `527:         return toMcpToolResult(`
     - `528:           await service.resolvePolicyAuditTemplateAsset(input),`
     - `529:         );`
     - `530:       }`
     - `531: `
   - `lcov.info` line-map status:
    - `525-531: absent from the file-specific line map for src\mcp-tools.ts`

3. `extensions/drm-copilot/src/workflow-command-arguments.ts` line `75`
   - Classification: `non-instrumented structural line`
   - Exact source text:
     - `75: `
   - `lcov.info` line-map status:
     - `75: present, hits=0`
   - Basis for structural classification:
     - The line is a blank separator between declarations and has no executable statement text.

4. `extensions/drm-copilot/src/workflow-command-arguments.ts` lines `164-167`
   - Classification: `non-instrumented structural line`
   - Exact source text:
     - `164:     value,`
     - `165:     fieldName,`
     - `166:     POLICY_AUDIT_TEMPLATE_ASSET_SELECTORS,`
     - `167:   );`
   - `lcov.info` line-map status:
     - `164: present, hits=0`
     - `165: present, hits=0`
     - `166: present, hits=0`
     - `167: present, hits=0`
   - Basis for structural classification:
     - The enclosing executable return statement lines `159-163` and closing line `168` are covered.
     - The unresolved lines are only the wrapped argument lines of an already-covered call expression.

5. `extensions/drm-copilot/src/workflow-command-arguments.ts` lines `254-257`
   - Classification: `non-instrumented structural line`
   - Exact source text:
     - `254: function isAbsolutePathLike(filePath: string): boolean {`
     - `255:   return /^(?:[a-zA-Z]:[\\/]|\\\\|\/)/.test(filePath);`
     - `256: }`
     - `257: `
   - `lcov.info` line-map status:
     - `254: present, hits=0`
     - `255: present, hits=0`
     - `256: present, hits=0`
     - `257: present, hits=0`
   - Basis for structural classification:
     - The caller body in `normalizeWorkspaceDestinationPath` lines `258-269` is covered in the same file-specific `lcov` section.
     - The zero-hit range is limited to the helper declaration and separator line while the executable caller path is covered.

6. `extensions/drm-copilot/src/workflow-command-arguments.ts` lines `571-598`
   - Classification: `non-instrumented structural line`
   - Exact source text / construct:
     - `572: export function resolvePolicyAuditTemplateAssetInvocation(`
     - `575:   if (rawArgs.length === 0) {`
     - `579:   const parsedArgs = parseWorkflowCommandArguments(rawArgs, [`
     - `583:   const asset = validatePolicyAuditTemplateAssetSelector(`
     - `589:   return {`
     - `598: }`
   - `lcov.info` line-map status:
    - `571-598: absent from the file-specific line map for src\workflow-command-arguments.ts`
