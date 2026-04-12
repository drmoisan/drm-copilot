# Policy Compliance Audit: bundle-link-parent-child-into-extension (Issue #144)

**Audit Date:** 2026-04-12  
**Feature Folder:** `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144`  
**Base Branch:** `development`  
**Code Under Test:**
- `extensions/drm-copilot/package.json`
- `extensions/drm-copilot/src/extension-command-helpers.ts`
- `extensions/drm-copilot/src/extension.ts`
- `extensions/drm-copilot/src/mcp-tool-inputs.ts`
- `extensions/drm-copilot/src/mcp-tools.ts`
- `extensions/drm-copilot/src/repo-automation-service.ts`
- `extensions/drm-copilot/src/workflow-command-arguments.ts`
- `extensions/drm-copilot/resources/templates/link-parent-child.ps1`
- `extensions/drm-copilot/README.md`
- Targeted Jest suites under `extensions/drm-copilot/test/`

## Coverage Metrics by Language

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|---------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 6 production files, 6 test files | 268 Jest tests | [✅] 268 pass, 0 fail | Not separately captured for this feature | Current full suite passed | New entrypoints are covered by targeted unit and integration tests |
| PowerShell | 1 bundled template file | 252 Pester tests | [✅] 252 pass, 0 fail, 7 skipped | Repository baseline pre-existed feature work | Current full suite passed | Bundled template path is covered by TypeScript integration tests; root behavior remains covered by existing Pester tests |
| JSON / Markdown | 5 files | N/A | [✅] structural review only | N/A | N/A | N/A |

## Executive Summary

The current feature state is **[✅] FULLY COMPLIANT / Review Ready**. The extension now contributes `drmCopilotExtension.linkParentChild`, the shared repo-automation service launches the bundled `resources/templates/link-parent-child.ps1` asset with preserved PowerShell parameter names, and the MCP server exposes the same workflow as `link_parent_child` with explicit child and parent issue-number inputs. The final relevant toolchain pass completed successfully for JSON formatting and validation, TypeScript formatting, lint, typecheck, full Jest, and the repository PowerShell format, analyze, and test commands.

**Policy documents evaluated:**
- [✅] `.github/instructions/general-code-change.instructions.md`
- [✅] `.github/instructions/general-unit-test.instructions.md`
- [✅] `.github/instructions/typescript-code-change.instructions.md`
- [✅] `.github/instructions/typescript-unit-test.instructions.md`
- [✅] `.github/instructions/powershell-code-change.instructions.md`
- [✅] `.github/instructions/powershell-unit-test.instructions.md`

## 1. General Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence / Isolation / Determinism | [✅] [PASS] | The added Jest tests use the existing mocked VS Code and subprocess harnesses. No new external dependency was introduced. |
| Coverage of positive, negative, and edge flows | [✅] [PASS] | Tests cover interactive prompting, direct invocation, invalid issue numbers, MCP normalization, service dispatch, and bundled-path execution. |
| Readability and maintainability | [✅] [PASS] | New test names are scenario-based and map directly to the delivered contract. |

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clear scoped plan | [✅] [PASS] | The active feature folder contains `issue.md`, `spec.md`, `user-story.md`, `research.md`, and the canonical `plan.2026-04-12T15-09.md`. |
| Additive implementation | [✅] [PASS] | The root script remains intact, and the change adds the bundled command and MCP surfaces without removing the legacy task path. |
| Shared-service routing | [✅] [PASS] | Both the VS Code command and MCP tool call the shared repo-automation service rather than new bespoke subprocess logic. |
| Final toolchain loop | [✅] [PASS] | The final command sequence passed: JSON format, TS format, PowerShell format, JSON validate, TS lint, PowerShell analyze, TS typecheck, TS test, PowerShell test. |

## 3. Language-Specific Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| TypeScript typing and explicit contracts | [✅] [PASS] | `workflow-command-arguments.ts`, `mcp-tool-inputs.ts`, and `mcp-tools.ts` add explicit typed validation for the new surface. |
| PowerShell contract preservation | [✅] [PASS] | The bundled script preserves `-ChildIssueNumber` and `-ParentIssueNumber`, and the service forwards those flags unchanged. |

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| TypeScript unit tests use Jest | [✅] [PASS] | The new coverage is added under the existing Jest suites in `extensions/drm-copilot/test/`. |
| PowerShell behavior remains covered by Pester | [✅] [PASS] | The repository Pester suite still passes, including `tests/scripts/dev-tools/link-parent-child.Tests.ps1`. |

## 5. Test Coverage Detail

| Area | Status | Evidence |
|------|--------|----------|
| Command registration and prompting | [✅] [PASS] | `extensions/drm-copilot/test/extension.workflow-commands.test.ts` |
| Bundled execution path | [✅] [PASS] | `extensions/drm-copilot/test/extension.integration.test.ts` |
| Repo automation service dispatch | [✅] [PASS] | `extensions/drm-copilot/test/repo-automation-service.test.ts` |
| MCP input normalization and server dispatch | [✅] [PASS] | `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` and `extensions/drm-copilot/test/mcp-server.test.ts` |

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Jest Suites Passed | 16 | [✅] |
| Jest Tests Passed | 268 | [✅] |
| Pester Tests Passed | 252 | [✅] |
| Pester Tests Skipped | 7 | [✅] |

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| JSON Format | `poetry run python -m scripts.dev_tools.format_json` | Passed | [✅] |
| TypeScript Format | `npm --prefix extensions/drm-copilot run format` | Passed after one restart-triggering formatting pass | [✅] |
| PowerShell Format | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCFormat -Root '.' }"` | Passed | [✅] |
| JSON Validate | `poetry run python -m scripts.dev_tools.validate_json` | Passed | [✅] |
| TypeScript Lint | `npm --prefix extensions/drm-copilot run lint` | Passed | [✅] |
| PowerShell Analyze | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCAnalyze -Root '.' }"` | Passed after one transient analyzer retry | [✅] |
| TypeScript Typecheck | `npm --prefix extensions/drm-copilot run typecheck` | Passed | [✅] |
| TypeScript Tests | `npm --prefix extensions/drm-copilot run test:unit` | Passed | [✅] |
| PowerShell Tests | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCTest -Root '.' }"` | Passed | [✅] |

## 8. Gaps and Exceptions

### Identified Gaps

None for the delivered link-parent-child feature surface.

### Approved Exceptions

None.

### Removed/Skipped Tests

None for the changed extension and bundled-script surface.

## 9. Summary of Changes

### Files Modified

1. **Extension command and validation**
   - Added `drmCopilotExtension.linkParentChild` plus required-issue-number prompt and direct invocation parsing.

2. **Shared automation and MCP surface**
   - Added repo-automation service support plus semantic MCP tool `link_parent_child`.

3. **Bundled runtime asset and docs**
   - Added bundled `resources/templates/link-parent-child.ps1` and documented the new published surfaces in `extensions/drm-copilot/README.md`.

4. **Tests**
   - Added targeted Jest coverage for command registration, prompting, bundled execution, service dispatch, MCP normalization, and MCP dispatch.

## 10. Compliance Verdict

### Overall Status: [✅] FULLY COMPLIANT

The current feature state satisfies the relevant policy requirements for the delivered extension command, bundled PowerShell template, and MCP tool surface.

### Policy-by-Policy Summary

- [✅] General code change policy
- [✅] General unit test policy
- [✅] TypeScript code change policy
- [✅] TypeScript unit test policy
- [✅] PowerShell code change policy
- [✅] PowerShell unit test policy

### Recommendation

**Review ready**

## Appendix A: Test Inventory

- `extensions/drm-copilot/test/extension.workflow-commands.test.ts`
- `extensions/drm-copilot/test/extension.integration.test.ts`
- `extensions/drm-copilot/test/repo-automation-service.test.ts`
- `extensions/drm-copilot/test/mcp-tool-inputs.test.ts`
- `extensions/drm-copilot/test/mcp-server.test.ts`
- `extensions/drm-copilot/test/workflow-command-arguments.test.ts`
- `tests/scripts/dev-tools/link-parent-child.Tests.ps1`

## Appendix B: Toolchain Commands Reference

```text
poetry run python -m scripts.dev_tools.format_json
npm --prefix extensions/drm-copilot run format
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCFormat -Root '.' }"
poetry run python -m scripts.dev_tools.validate_json
npm --prefix extensions/drm-copilot run lint
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCAnalyze -Root '.' }"
npm --prefix extensions/drm-copilot run typecheck
npm --prefix extensions/drm-copilot run test:unit
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCTest -Root '.' }"
```
