# Shared MCP Fixture Derived Root — [P1-T7]

Timestamp: 2026-09-07T11-30
Task: [P1-T7]

Command: `Select-String -LiteralPath extensions/drm-copilot/test/mcp-server-test-service.ts -Pattern 'C:/workspace' -SimpleMatch -CaseSensitive`, plus the same command for each of `export const VIRTUAL_WORKSPACE_ROOT`, `export function workspacePath`, and `export const PUSH_DOWN_CODEX_ARTIFACT_PATH`; `node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit`
EXIT_CODE: 0 for every `Select-String` invocation; 2 for the `tsc` invocation, unchanged from the [P0-T9] baseline exit code of 2

## Change made

`import * as path from "node:path";` was added immediately after the existing `@jest/globals` import at line 1. Above `createMockService`, three exported members were added, each with a JSDoc block:

- `export const VIRTUAL_WORKSPACE_ROOT`, declared as `path` continued by `.resolve("virtual-workspace")` and `.replaceAll("\\", "/")`.
- `export function workspacePath(repositoryPath: string): string`, returning the constant joined to its argument with a single forward slash.
- `export const PUSH_DOWN_CODEX_ARTIFACT_PATH`, whose value is `workspacePath("artifacts/codex-and-agents-customizations/push-down-20260405T174500Z.json")`. It is declared here rather than in `mcp-server.test.ts` because that file carries only ten lines of headroom against the 500-line limit.

`workspaceRoot` in `createPreparedTransitionCase` was set to `VIRTUAL_WORKSPACE_ROOT`. The `arguments.workspace_root` member already reads `request.workspaceRoot`, so it inherits the derived value with no further edit; that line was not touched.

## Results

- `C:/workspace` case-sensitive match count: 0 (required: 0)
- `export const VIRTUAL_WORKSPACE_ROOT`: 1 match (required: exactly 1)
- `export function workspacePath`: 1 match (required: exactly 1)
- `export const PUSH_DOWN_CODEX_ARTIFACT_PATH`: 1 match (required: exactly 1)
- File line count: 117 (pre-change 87; within the 500-line limit)
- Prettier: `npx prettier --check` reported "All matched files use Prettier code style!"

## Type check against the [P0-T9] baseline

- Total `error TS` lines: 331, identical to the baseline count.
- Normalized diagnostics absent from the baseline set: 0. No regression introduced.
- Per-changed-path counts unchanged, including `mcp-server-test-service.ts` at 1 both before and after. That single pre-existing diagnostic is `TS2322` on the `transitionPreparedOrchestration` mock assignment at line 28; it concerns Jest mock typing and not a workspace-root value, so this task neither introduces nor clears it.

Clause 1 of this task's type acceptance is unsatisfiable at baseline as recorded in `../remediation-baseline/typescript-test-tree-typecheck.2026-09-07T03-16.md` and is not claimed as satisfied.

Output Summary: The shared MCP fixture module now derives its workspace root at run time. All three required exports are present exactly once, the drive-letter literal count in this file is 0, and the file grew from 87 to 117 lines. The type-check emits 331 `error TS` lines, normalized-identical to the [P0-T9] baseline with 0 new diagnostics and no per-file count change, so clause 2 passes.
