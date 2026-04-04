# Remediation Plan: bundle-sync-agents-113 (2026-04-04T16-00)

- **Issue:** #113
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-04T16-00
- **Status:** Awaiting atomic plan
- **Version:** 1.0

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- TypeScript Code Change: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- Python Code Change: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Remediation Inputs

Spec (authoritative): [`remediation-inputs.2026-04-04T16-00.md`](remediation-inputs.2026-04-04T16-00.md)  
Secondary context: [`spec.md`](spec.md)

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Review and Baseline Capture

- [x] [P0-T1] Read `.github/instructions/general-code-change.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md` before touching any production or test code
  - Acceptance: All five policy files read in full before any file changes are committed

- [x] [P0-T2] Capture baseline TypeScript toolchain state by running format check, lint, type-check, and unit tests with coverage on the current unmodified branch
  - Command: `npm --prefix extensions/drm-copilot run format -- --check && npm --prefix extensions/drm-copilot run lint && npm --prefix extensions/drm-copilot run typecheck && npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary`
  - Acceptance: Evidence artifact written to `docs/features/active/2026-03-21-bundle-sync-agents-113/evidence/baselines/ts-baseline.2026-04-04T16-00.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including functions coverage percentage
  - Note: All baseline steps expected to pass; baseline exit codes must be 0

- [x] [P0-T3] Capture baseline Python toolchain state by running format check, lint, type-check, and tests with coverage on the current unmodified branch
  - Command: `poetry run black --check . && poetry run ruff check && poetry run pyright && poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing -q`
  - Acceptance: Evidence artifact written to `docs/features/active/2026-03-21-bundle-sync-agents-113/evidence/baselines/python-baseline.2026-04-04T16-00.md` with same required fields including overall coverage percentage

- [x] [P0-T4] Record baseline line counts for the two violating files
  - Commands: `(Get-Content extensions/drm-copilot/src/extension.ts).Count` and `(Get-Content tests/scripts/dev_tools/test_push_down_copilot_customizations.py).Count`
  - Acceptance: Evidence artifact at `docs/features/active/2026-03-21-bundle-sync-agents-113/evidence/baselines/line-count-baseline.2026-04-04T16-00.md` records current counts (592 and 583) and limit (500)

---

### Phase 1 — Extract MCP Provider from `extension.ts` (Fix F1)

- [x] [P1-T1] Create `extensions/drm-copilot/src/mcp-provider.ts` containing:
  - An exported function `registerMcpProvider(context: vscode.ExtensionContext): vscode.Disposable[]`
  - Move the `mcpDidChangeEmitter` (EventEmitter instance), `mcpProviderDisposable` registration block, and all `provideMcpServerDefinitions` / `resolveMcpServerDefinition` callback logic out of `extension.ts` into this file
  - Import `vscode` and any other required modules at the top of the new file
  - The function must return the array of disposables so the caller can push them to `context.subscriptions`
  - Acceptance: `mcp-provider.ts` exists, compiles without errors, and exports `registerMcpProvider` with correct signature

- [x] [P1-T2] Update `extensions/drm-copilot/src/extension.ts` to use the extracted provider:
  - Remove all inline MCP block code replaced by Phase 1 Task 1
  - Add import: `import { registerMcpProvider } from "./mcp-provider";`
  - Replace removed block with: `const mcpDisposables = registerMcpProvider(context); context.subscriptions.push(...mcpDisposables);`
  - Acceptance: `extension.ts` line count ≤ 500; confirmed by `(Get-Content extensions/drm-copilot/src/extension.ts).Count`

- [x] [P1-T3] Verify TypeScript compiles cleanly after file extraction
  - Command: `npm --prefix extensions/drm-copilot run typecheck`
  - Acceptance: Exit code 0, no new type errors

---

### Phase 2 — Add Behavioral Tests for MCP Provider Callbacks (Fix F3)

- [x] [P2-T1] Create `extensions/drm-copilot/test/mcp-provider.test.ts` (or add tests to `extension.test.ts` if the provider is tested as a unit through the extension activation mock) with:
  - A mock for `vscode.EventEmitter` and `vscode.Disposable`
  - Test: "registerMcpProvider registers a provider and returns disposables" — calls `registerMcpProvider` with a mock context and verifies the return value is an array of disposable objects
  - Test: "provideMcpServerDefinitions constructs McpStdioServerDefinition with expected args" — captures the `provideMcpServerDefinitions` callback registered with the mock provider, invokes it, and asserts `McpStdioServerDefinition` was called with `("drmCopilotExtension", expect.stringContaining("node"), expect.stringContaining("mcp-server.js"))` or equivalent constructor args
  - Test: "provideMcpServerDefinitions assigns cwd when workspace is non-empty" — sets `vscode.workspace.workspaceFolders` to a mock value, calls `provideMcpServerDefinitions`, and asserts `serverDef.cwd` equals the workspace URI
  - Test: "resolveMcpServerDefinition returns the server argument unchanged" — invokes `resolveMcpServerDefinition` with a mock server object and asserts the same object is returned
  - Acceptance: All 4 new tests pass; `npm --prefix extensions/drm-copilot run test:unit` exits 0

- [x] [P2-T2] Verify TypeScript functions coverage recovers to ≥ 85% after adding behavioral tests
  - Command: `npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary`
  - Acceptance: Functions coverage ≥ 85% (recovering from 78.26% baseline); exit code 0

---

### Phase 3 — Split Python Test File (Fix F2)

- [x] [P3-T1] Create `tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py` containing:
  - Module docstring describing this file covers the rewrite-catalog correctness tests
  - Import the required modules and fixtures from `conftest.py` or directly (do NOT use temporary file fixtures)
  - Move `test_sync_agents_script_reference_rewrites_to_live_command` and any other tests whose sole subject is `push_down_copilot_customizations_rewrites.py` from `test_push_down_copilot_customizations.py` into this file
  - All moved tests must be type-annotated and pass Pyright
  - Acceptance: New file created; `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py -v` exits 0 with all moved tests passing

- [x] [P3-T2] Remove the moved tests from `tests/scripts/dev_tools/test_push_down_copilot_customizations.py` so it is ≤ 500 lines
  - Acceptance: `(Get-Content tests/scripts/dev_tools/test_push_down_copilot_customizations.py).Count` ≤ 500

- [x] [P3-T3] Verify both Python test files comply with policy (line count, Pyright, Ruff)
  - Commands: `poetry run pyright tests/scripts/dev_tools/test_push_down_copilot_customizations.py tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py && poetry run ruff check tests/scripts/dev_tools/test_push_down_copilot_customizations.py tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py`
  - Acceptance: Both exit 0; no new errors

---

### Phase 4 — Final QC Loop

> Perform this phase only after all Phase 1–3 tasks are complete. Rerun from the first failing step if any step changes files or fails.

- [x] [P4-T1] Run TypeScript format check (check-only)
  - Command: `npm --prefix extensions/drm-copilot run format -- --check`
  - Acceptance: Exit code 0; evidence artifact at `docs/features/active/2026-03-21-bundle-sync-agents-113/evidence/qa-gates/ts-format-final.2026-04-04T16-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:`

- [x] [P4-T2] Run TypeScript lint
  - Command: `npm --prefix extensions/drm-copilot run lint`
  - Acceptance: Exit code 0; evidence artifact at `docs/features/active/2026-03-21-bundle-sync-agents-113/evidence/qa-gates/ts-lint-final.2026-04-04T16-00.md`

- [x] [P4-T3] Run TypeScript type-check
  - Command: `npm --prefix extensions/drm-copilot run typecheck`
  - Acceptance: Exit code 0; evidence artifact at `docs/features/active/2026-03-21-bundle-sync-agents-113/evidence/qa-gates/ts-typecheck-final.2026-04-04T16-00.md`

- [x] [P4-T4] Run TypeScript unit tests with coverage
  - Command: `npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary`
  - Acceptance: All tests pass (102+ including 4 new MCP tests); functions coverage ≥ 85%; evidence artifact at `docs/features/active/2026-03-21-bundle-sync-agents-113/evidence/qa-gates/ts-test-final.2026-04-04T16-00.md` with numeric functions coverage in `Output Summary:`

- [x] [P4-T5] Run Python format check (check-only)
  - Command: `poetry run black --check .`
  - Acceptance: Exit code 0; evidence artifact at `docs/features/active/2026-03-21-bundle-sync-agents-113/evidence/qa-gates/python-format-final.2026-04-04T16-00.md`

- [x] [P4-T6] Run Python lint
  - Command: `poetry run ruff check`
  - Acceptance: Exit code 0; evidence artifact at `docs/features/active/2026-03-21-bundle-sync-agents-113/evidence/qa-gates/python-lint-final.2026-04-04T16-00.md`

- [x] [P4-T7] Run Python type-check
  - Command: `poetry run pyright`
  - Acceptance: 0 errors reported; evidence artifact at `docs/features/active/2026-03-21-bundle-sync-agents-113/evidence/qa-gates/python-typecheck-final.2026-04-04T16-00.md`

- [x] [P4-T8] Run Python tests with coverage
  - Command: `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing -q`
  - Acceptance: All 905+ tests pass; overall coverage ≥ 80%; evidence artifact at `docs/features/active/2026-03-21-bundle-sync-agents-113/evidence/qa-gates/python-test-final.2026-04-04T16-00.md` with coverage percentages in `Output Summary:`

- [x] [P4-T9] Verify final line counts for all three modified files
  - Commands: `(Get-Content extensions/drm-copilot/src/extension.ts).Count` (must be ≤500), `(Get-Content tests/scripts/dev_tools/test_push_down_copilot_customizations.py).Count` (must be ≤500), `(Get-Content tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py).Count` (must be ≤500)
  - Acceptance: All three counts ≤ 500; evidence recorded in `docs/features/active/2026-03-21-bundle-sync-agents-113/evidence/qa-gates/line-count-final.2026-04-04T16-00.md`

---

## Test Plan

- **Unit (TypeScript):** 4 new behavioral tests in `mcp-provider.test.ts` covering `registerMcpProvider`, `provideMcpServerDefinitions` constructor, `cwd` assignment, and `resolveMcpServerDefinition` identity
- **Unit (Python):** Moved tests continue to pass from new split file; no reduction in test count
- **Manual verification:** `(Get-Content <file>).Count` line count checks for all three modified/created files

## Open Questions / Notes

- If `extension.ts` remains >500 after MCP extraction: extract the `syncAgentsFromInstructions` command handler into a composable function in a module barrel following the existing extension patterns.
- No PowerShell changes are required by this remediation; the Pester test suite findings remain green and should not be disturbed.
- Atomic executor must NOT touch `policy-audit`, `code-review`, or `feature-audit` MD files in this folder.

