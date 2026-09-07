# Test-Support Module Derived Root — [P1-T3]

Timestamp: 2026-09-07T11-20
Task: [P1-T3]

Command: `Select-String -LiteralPath extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts -Pattern 'C:/workspace' -SimpleMatch -CaseSensitive`; `node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit`
EXIT_CODE: 0 for the `Select-String` invocation; 2 for the `tsc` invocation, unchanged from the [P0-T9] baseline exit code of 2

## Substitutions applied

All seven drive-letter workspace-root literals recorded by [P0-T8] were replaced:

| [P0-T8] line | Site | Replacement |
| --- | --- | --- |
| 21 | `INDEPENDENT_CONTEXT.expectedWorkspaceRoot` | `VIRTUAL_WORKSPACE_ROOT` |
| 53 | `createEnvelope` `binding.workspaceRoot` | `VIRTUAL_WORKSPACE_ROOT` |
| 131-136 | `archivePathFor` return | `workspacePath(...)` of `artifacts/orchestration/handoffs/sources/sha256/${sourceSha256}.json` |
| 138-143 | `candidatePathFor` return | `workspacePath(...)` of the `orchestrator-state` plus `.handoff-candidate-${envelopeSha256}.json` concatenation |
| 154 | `sourcePath` | `workspacePath(baseEnvelope.source.checkpointPath)` |
| 155-156 | `envelopePath` | `workspacePath("artifacts/orchestration/handoffs/handoff.json")` |
| 261 | request `workspaceRoot` | `VIRTUAL_WORKSPACE_ROOT` |

One additional occurrence was removed that [P0-T8] could not have recorded: the JSDoc block added by [P1-T1] quoted the drive-letter literal as an example in prose. The prose was reworded to say "a drive-letter literal" without quoting it, because the acceptance gate is a case-sensitive text search over the whole file and a prose mention would keep the count above zero while changing no behaviour.

## Results

- `C:/workspace` case-sensitive match count: 0 (required: 0)
- File line count: 323, unchanged by this task and within the 500-line limit
- Prettier: `npx prettier --check` on this file reported "All matched files use Prettier code style!", so [P2-T1] will not rewrite it

## Type check against the [P0-T9] baseline

- Total `error TS` lines: 331, identical to the baseline count.
- Normalized diagnostics absent from the baseline set: 0. No regression introduced.
- Per-changed-path counts unchanged: test-support 0/0, materializer test 0/0, production test 2/2, handlers test 3/3, `mcp-server-test-service.ts` 1/1, `mcp-server.test.ts` 1/1, orchestration-validation 9/9.

Clause 1 of this task's type acceptance is unsatisfiable at baseline as recorded in `../remediation-baseline/typescript-test-tree-typecheck.2026-09-07T03-16.md` and is not claimed as satisfied. The file this task edits carries 0 diagnostics before and after.

Output Summary: All seven recorded literals plus one prose mention introduced by [P1-T1] were replaced with the derived root, bringing the case-sensitive `C:/workspace` count in this file to 0. The type-check emits 331 `error TS` lines, normalized-identical to the [P0-T9] baseline with 0 new diagnostics and no per-file count change, so clause 2 passes. Prettier reports the file already conforms.
