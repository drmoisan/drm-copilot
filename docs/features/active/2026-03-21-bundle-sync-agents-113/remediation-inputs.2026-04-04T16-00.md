# Remediation Inputs: bundle-sync-agents-113

**Timestamp:** 2026-04-04T16-00  
**Source:** `policy-audit.2026-04-04T16-00.md` + `code-review.2026-04-04T16-00.md`  
**Feature:** 2026-03-21-bundle-sync-agents-113  
**Branch:** feature/bundle-sync-agents-113  
**Base:** origin/development

---

## Required Fixes

### Fix 1 — Split `extensions/drm-copilot/src/extension.ts` to restore 500-line compliance

**Severity:** Blocker (policy §4 hard limit)  
**File:** `extensions/drm-copilot/src/extension.ts`  
**Current state:** 592 lines (limit: 500). Baseline was 486.

**Root cause:** Two additions in this branch pushed it over 500:
- In-scope: `syncAgentsFromInstructions` command handler (~16 lines)
- Out-of-scope: MCP provider registration (`mcpDidChangeEmitter`, `mcpProviderDisposable`) + subscriptions push (~90 lines combined)

**Expected behavior after fix:**  
`extension.ts` must be ≤500 lines. The MCP provider logic should be extracted into a new file `extensions/drm-copilot/src/mcp-provider.ts` that exports a `registerMcpServerProvider(context, output)` function. The `syncAgentsFromInstructions` handler can remain in `extension.ts` since after MCP extraction the file will be around 500 lines (486 + 16 = ~502, which may still require extraction of one more handler — see note below).

**Suggested split:**
1. Create `extensions/drm-copilot/src/mcp-provider.ts` containing the MCP EventEmitter, provider definition, and a named export `registerMcpProvider(context: vscode.ExtensionContext): vscode.Disposable[]`.
2. In `extension.ts`, replace the inline MCP block with `const mcpDisposables = registerMcpProvider(context)` and spread into `context.subscriptions.push(...)`.
3. Verify `extension.ts` is ≤500 lines after extraction.

**Note:** If `extension.ts` is still >500 lines after MCP extraction, extract the `syncAgentsFromInstructions` handler into a module barrel or composable function following the same pattern used by the existing `command-runtime.ts` pattern.

**Acceptance criteria:**
- `(Get-Content extensions/drm-copilot/src/extension.ts).Count` ≤ 500
- `extensions/drm-copilot/src/mcp-provider.ts` exists and exports the MCP registration
- `npm --prefix extensions/drm-copilot run typecheck` exits 0
- `npm --prefix extensions/drm-copilot run test:unit` exits 0 with all 102+ tests passing

---

### Fix 2 — Split `tests/scripts/dev_tools/test_push_down_copilot_customizations.py` to restore 500-line compliance

**Severity:** Blocker (policy §4 hard limit)  
**File:** `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`  
**Current state:** 583 lines (limit: 500). Baseline was 438.

**Root cause:** `test_sync_agents_script_reference_rewrites_to_live_command` and associated fixtures added 145 lines to an already-large test file.

**Expected behavior after fix:**  
All sync-agents and rewrite-catalog tests for `push_down_copilot_customizations_rewrites.py` are moved to a new file `tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py`. Both the original file and the new file must be ≤500 lines.

**Suggested split:**
1. Create `tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py` containing:
   - Any shared fixtures needed for catalog tests (copy or import from conftest if applicable)
   - `test_sync_agents_script_reference_rewrites_to_live_command`
   - Any other catalog-specific tests currently in the monolithic file
2. Remove moved tests from `test_push_down_copilot_customizations.py`.
3. Ensure both files remain focused: the original should cover orchestration/push-down behavior; the new file should cover rewrite catalog correctness.

**Acceptance criteria:**
- `(Get-Content tests/scripts/dev_tools/test_push_down_copilot_customizations.py).Count` ≤ 500
- `(Get-Content tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py).Count` ≤ 500
- `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py -v` exits 0 with all tests passing
- `poetry run pyright` exits 0
- Coverage for `push_down_copilot_customizations_rewrites.py` remains ≥90%

---

### Fix 3 — Add behavioral tests for MCP provider callbacks in `extension.ts`

**Severity:** Major (policy Unit Test §2 — new code ≥90% coverage)  
**File:** `extensions/drm-copilot/test/extension.test.ts` (or `extension.integration.test.ts`)  
**Current state:** `provideMcpServerDefinitions` callback body and conditional `serverDef.cwd` assignment are not invoked in any test. Only structural registration is asserted.

**Expected behavior after fix:**  
A test (or tests) must:
1. Capture the `provideMcpServerDefinitions` callback registered with `registerMcpServerDefinitionProviderMock`.
2. Invoke the callback and verify that `McpStdioServerDefinition` is constructed with `"drmCopilotExtension"`, `"node"`, and a path ending in `"out/mcp-server.js"`.
3. Verify that when `workspaceFolders` is non-empty, `serverDef.cwd` is set to the workspace URI.
4. Verify that `resolveMcpServerDefinition` is a function that returns its `server` argument.

**If MCP is extracted to `mcp-provider.ts` (Fix 1):** Unit tests for the provider can be placed in a dedicated `mcp-provider.test.ts` file. This is the preferred approach.

**Acceptance criteria:**
- `npm --prefix extensions/drm-copilot run test:unit` exits 0
- TypeScript functions coverage recovers to ≥85% (from current 78.26%)
- The new tests explicitly call `provideMcpServerDefinitions()` and assert on the `McpStdioServerDefinition` constructor arguments and `cwd` assignment
- `npm --prefix extensions/drm-copilot run typecheck` exits 0 after adding the tests

---

## Do Not Do

- Do not remove the `syncAgentsFromInstructions` command handler or change its routing behavior.
- Do not change the bundled PowerShell template or root sync script as part of this remediation — those are correct.
- Do not weaken type checking (`strict` in `tsconfig.json`) or add blanket `// @ts-ignore` to make coverage errors disappear.
- Do not suppress Ruff/Pyright/PSScriptAnalyzer errors with file-level suppressions.
- Do not reduce the total Python test count or remove passing tests from either Python test file during the split.
- Do not merge unrelated changes (new features, additional commands) while fixing these three items.
- Do not use temporary files on the filesystem in any new unit tests.

---

## Unmet Policy Criteria (Minimum Changes to Satisfy)

| Policy Requirement | Minimum Fix |
|--------------------|-------------|
| `extension.ts` ≤ 500 lines | Extract MCP provider to `mcp-provider.ts`; verify line count |
| Test file ≤ 500 lines | Split Python test file at rewrite-catalog boundary |
| New code ≥ 90% TypeScript functions coverage | Add behavioral tests for MCP callbacks; ideally in `mcp-provider.test.ts` |

These three items are required for policy compliance. The feature acceptance criteria are already met and do not require changes.

---

## Verification Commands (Post-Remediation)

Run the full toolchain loop in order until all pass:

```
# Python
poetry run black .
poetry run ruff check
poetry run pyright
poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing

# TypeScript
npm --prefix extensions/drm-copilot run format
npm --prefix extensions/drm-copilot run lint
npm --prefix extensions/drm-copilot run typecheck
npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary

# PowerShell (if any PS files changed)
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."
```

Line count verification:
```
(Get-Content extensions/drm-copilot/src/extension.ts).Count          # must be ≤500
(Get-Content tests/scripts/dev_tools/test_push_down_copilot_customizations.py).Count  # must be ≤500
(Get-Content tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py).Count  # must be ≤500
```
