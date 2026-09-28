# MCP Server Test Derived Root — [P1-T9]

Timestamp: 2026-09-07T11-36
Task: [P1-T9]

Command: `Select-String -LiteralPath extensions/drm-copilot/test/mcp-server.test.ts -Pattern 'C:/workspace' -SimpleMatch -CaseSensitive`; `(Get-Content -LiteralPath extensions/drm-copilot/test/mcp-server.test.ts).Count`; `node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit`
EXIT_CODE: 0 for the `Select-String` and line-count invocations; 2 for the `tsc` invocation, unchanged from the [P0-T9] baseline exit code of 2

## Substitutions applied

`PUSH_DOWN_CODEX_ARTIFACT_PATH`, `VIRTUAL_WORKSPACE_ROOT`, and `workspacePath` were added to the existing named-import list from `./mcp-server-test-service`. That import block is the only site where lines were added, as the task requires.

The four substitution rules were applied to all 73 matching lines recorded by [P0-T8]:

1. Every bare `"C:/workspace"` became `VIRTUAL_WORKSPACE_ROOT`, widening the token by eight characters. The widest line carrying a bare literal was pre-change line 369, `arguments: { workspace_root: "C:/workspace" },`, at 51 characters; at 59 characters after substitution it remains well inside the 80-character print width, so no such line wrapped.
2. Every `"C:/workspace/<suffix>"` became `workspacePath("<suffix>")`, except the two long push-down artifact literals at pre-change lines 189 and 211.
3. The six mock `summary` strings embedding the quoted root, at pre-change lines 251, 279, 307, 335, 363, and 382, became template literals interpolating `VIRTUAL_WORKSPACE_ROOT`.
4. The hard-lock summary at pre-change line 464 became a template literal interpolating `workspacePath("docs/features/active/feature-123/plan.md")`.

Both push-down artifact sites were three-line arrays whose sole element was the long literal. Each was written as the collapsed single line `artifacts: [PUSH_DOWN_CODEX_ARTIFACT_PATH],`, which is the form Prettier produces at print width 80; leaving the three-line form would have made [P2-T1] rewrite the file.

No composite literal needed moving into `mcp-server-test-service.ts` beyond the push-down artifact path already added by [P1-T7], because the post-change line count came in under 500 without further extraction.

## Results

- `C:/workspace` case-sensitive match count: 0 (required: 0)
- Post-change line count: 483. Delta from the pre-change 490: -7. Required: at most 500.
  The delta decomposes as +3 for the three imported names, -4 for the two three-line push-down arrays collapsing to one line each, and -6 for the six two-line `summary:` properties collapsing to one line each.
- Prettier: `npx prettier --check` reported "All matched files use Prettier code style!", so [P2-T1] will not rewrite this file.

## Type check against the [P0-T9] baseline

- Total `error TS` lines: 331, identical to the baseline count.
- Normalized diagnostics absent from the baseline set: 0. No regression introduced.
- Per-changed-path counts unchanged, including `mcp-server.test.ts` at 1 both before and after. That single pre-existing diagnostic is `TS2339` on a `mockResolvedValue` access; it concerns Jest mock typing and not a workspace-root value.

Clause 1 of this task's type acceptance is unsatisfiable at baseline as recorded in `../remediation-baseline/typescript-test-tree-typecheck.2026-09-07T03-16.md` and is not claimed as satisfied.

Output Summary: All 73 recorded literal lines were substituted in place, bringing the case-sensitive `C:/workspace` count in this file to 0. The post-change line count is 483, a delta of -7 from the pre-change 490 and 17 lines inside the 500-line limit. The type-check emits 331 `error TS` lines, normalized-identical to the [P0-T9] baseline with 0 new diagnostics and no per-file count change, so clause 2 passes. Prettier reports the file already conforms.
