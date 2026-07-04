# P7-T9 — Final No-Python Audit (F11 ts-command-runtime-cleanup)

Timestamp: 2026-06-26T09-27

All four audit searches return zero matches.

## (1) Runtime Python references in src/ and test/
Command: `rg -n 'runtimeKind: "python"|detectRuntime\("python"\)' extensions/drm-copilot/src extensions/drm-copilot/test`
EXIT_CODE: 1 (no matches)
Output Summary: No `runtimeKind: "python"` assignment and no `detectRuntime("python")` call remains in the extension source or tests.

## (2) Bundled Python under resources/
Command: `rg --files extensions/drm-copilot/resources -g "*.py"`
EXIT_CODE: 1 (no matches)
Output Summary: Zero `.py` files under `extensions/drm-copilot/resources/` (all 13 template wrappers and the 41-file `scripts/dev_tools/**` tree removed; `resources/scripts/` directory removed).

## (3) Python union members in the runtime types
Command: `rg -n '"python" \| "powershell"|"python"' extensions/drm-copilot/src/command-runtime.ts extensions/drm-copilot/src/repo-automation-service-support.ts`
EXIT_CODE: 1 (no matches)
Output Summary: `RuntimeKind` is `"powershell"` and `ScriptExecutionOptions.runtimeKind` is `"powershell"`; no `"python"` union member remains.

## (4) Tests referencing bundled Python
Command: `rg -n 'extensions/drm-copilot/resources/scripts|extensions/drm-copilot/resources/templates/.*\.py' tests`
EXIT_CODE: 1 (no matches)
Output Summary: No Python test references the removed bundled Python tree.

## MCP prepack output (cross-reference P4-T6)
The MCP-server prepack produces zero `.py` files under `packages/mcp-server/resources` (see `mcp-prepack-no-python.md`).

Verdict: No remaining runtime dependency on a `python` interpreter exists for extension or MCP command execution. AC-F11-12 (AC-E4) satisfied.
