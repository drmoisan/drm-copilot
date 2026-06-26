# Codex-Native-Converter MCP Spawn-Assertion Search (P8-T5)

Timestamp: 2026-06-26T12-20

## Purpose

Per plan task [P8-T5], determine whether the three MCP-layer codex tests assert a
Python spawn of `resources/templates/codex_native_converter.py` for the
`run_codex_native_converter` tool. If none do, this negative-evidence artifact is
required.

## SearchScope

- `extensions/drm-copilot/test/mcp-tools.codex-native-converter.test.ts`
- `extensions/drm-copilot/test/codex-native-converter-handlers.test.ts`
- `extensions/drm-copilot/test/mcp-tool-inputs.codex-native-converter.test.ts`

## SearchPatterns

- `codex_native_converter.py`
- `runtimeKind`
- `buildRunCodexNativeConverterOptions`
- `executeBundledScript`
- `spawn`
- `python`

## SearchResult

- `codex_native_converter.py`: none in any of the three files.
- `runtimeKind`: none.
- `buildRunCodexNativeConverterOptions`: none.
- `executeBundledScript`: none.
- `python`: none.
- `spawn`: one occurrence in `mcp-tools.codex-native-converter.test.ts` line 12
  (`spawn: jest.fn()`), a module-level defensive mock of `node:child_process`.
  It is never referenced in any assertion and no spawn argv is asserted for this
  command. The test asserts dispatch and the in-process result contract via a
  mocked `RepoAutomationService.runCodexNativeConverter`.

## Conclusion

None of the three MCP tests assert a Python spawn of
`codex_native_converter.py`. The input-schema (mcp-tool-inputs) and handler
(codex-native-converter-handlers) tests assert input normalization; the
mcp-tools test asserts dispatch and the in-process result shape. All three pass
unchanged after the F10 in-process rewire:

- Command: `node run-jest.cjs test/mcp-tools.codex-native-converter.test.ts test/codex-native-converter-handlers.test.ts test/mcp-tool-inputs.codex-native-converter.test.ts`
- EXIT_CODE: 0
- Output Summary: Test Suites: 3 passed, 3 total; Tests: 4 passed, 4 total.

No assertion changes were required; the input-schema and dispatch assertions are
preserved verbatim.
