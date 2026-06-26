# Codex-Native-Converter Extension/Service Spawn-Assertion Search (P8-T6)

Timestamp: 2026-06-26T12-20

## Purpose

Per plan task [P8-T6], search `extensions/drm-copilot/test/` for any additional
test (beyond the three MCP tests handled in P8-T5) that asserts a Python spawn
for `run_codex_native_converter`, and rewrite each to assert the in-process
result contract using injected fakes.

## SearchScope

- `extensions/drm-copilot/test/` (entire directory tree)

## SearchPatterns

- `codex_native_converter.py`
- `buildRunCodexNativeConverterOptions`
- `runtimeKind`
- `executeBundledScriptFromExtensionRoot`
- `spawn` (in codex test context)

## SearchResult

Two tests asserted the Python spawn for this tool and were rewritten:

1. `extensions/drm-copilot/test/repo-automation-service.codex-native-converter.test.ts`
   - Previously asserted `spawn("python", ["...codex_native_converter.py", ...])`
     argv and the stdout `Artifact root:` parse.
   - Rewritten to inject an `InMemoryFileSystem` into `createRepoAutomationService`
     and assert the in-process result contract (`tool`, `workspaceRoot`, exact
     `summary`, single artifact path) plus apply-mode destination writes.

2. `extensions/drm-copilot/test/extension.workflow-commands.test.ts`
   - The review-mode case previously asserted the `codex_native_converter.py`
     spawn argv. Rewritten to assert no `node:child_process` spawn occurs and
     that the in-process converter wrote `conversion-report.md` through the
     mocked filesystem.
   - The apply-mode blank-destination case already asserted `spawn` was not
     called (UI early-return before the service call); it remains valid and is
     unchanged.

After the rewrites, a repository-wide search for `codex_native_converter.py`
under `extensions/drm-copilot/test/` returns:

- SearchResult: none.

## Verification

- Command: `node run-jest.cjs test/extension.workflow-commands.test.ts test/repo-automation-service.codex-native-converter.test.ts`
- EXIT_CODE: 0
- Output Summary: Test Suites: 2 passed, 2 total; Tests: 41 passed, 41 total.

No remaining test asserts a Python spawn of `codex_native_converter.py` for the
`run_codex_native_converter` tool.
