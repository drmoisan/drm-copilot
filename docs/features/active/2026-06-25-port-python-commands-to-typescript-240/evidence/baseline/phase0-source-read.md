# Phase 0 — F10 Source and Wiring Read (ts-codex-native-converter)

Timestamp: 2026-06-26T11-29

Files Read (authoritative Python source modules):
- scripts/dev_tools/codex_native_converter/models.py (460 lines)
- scripts/dev_tools/codex_native_converter/models_intermediate.py (226 lines)
- scripts/dev_tools/codex_native_converter/inventory.py (217 lines)
- scripts/dev_tools/codex_native_converter/classifier.py (484 lines)
- scripts/dev_tools/codex_native_converter/section_intent.py (249 lines)
- scripts/dev_tools/codex_native_converter/parser.py (292 lines)
- scripts/dev_tools/codex_native_converter/mapping.py (234 lines)
- scripts/dev_tools/codex_native_converter/rewrites.py (485 lines)
- scripts/dev_tools/codex_native_converter/validation.py (418 lines)
- scripts/dev_tools/codex_native_converter/pipeline.py (462 lines)
- scripts/dev_tools/codex_native_converter/intermediate_state.py (271 lines)
- scripts/dev_tools/codex_native_converter/reporting.py (433 lines)
- scripts/dev_tools/codex_native_converter/_pipeline_traces.py (139 lines)
- scripts/dev_tools/codex_native_converter/_reporting_topology.py (175 lines)
- scripts/dev_tools/codex_native_converter/engine.py (499 lines)
- scripts/dev_tools/codex_native_converter/cli.py (308 lines)
- scripts/dev_tools/codex_native_converter/__init__.py (24 lines)
- scripts/dev_tools/codex_native_converter/__main__.py (23 lines)

Wiring targets:
- extensions/drm-copilot/resources/templates/codex_native_converter.py
- extensions/drm-copilot/src/repo-automation-service.ts (481 lines; runCodexNativeConverter at lines 227-231)
- extensions/drm-copilot/src/repo-automation-service-workflows.ts (262 lines; buildRunCodexNativeConverterOptions at lines 68-105, RunCodexNativeConverterInput at lines 30-38)
- extensions/drm-copilot/src/mcp-handlers/codex-native-converter-handlers.ts
- extensions/drm-copilot/src/mcp-tool-inputs.ts
- extensions/drm-copilot/src/lib/file-system.ts (shared F1 FileSystem; exposes glob/isFile/exists/isDirectory/listDirectory/readTextFile/writeTextFile/ensureDir; toPosixPath helper)

Python test files (16) under tests/scripts/dev_tools/codex_native_converter/:
- test_classifier.py, test_cli_apply.py, test_cli_entrypoints.py, test_cli_review.py, test_end_to_end.py, test_intermediate_state.py, test_inventory.py, test_mapping.py, test_parser.py, test_prompt_decomposition_end_to_end.py, test_reporting.py, test_reporting_topology_end_to_end.py, test_rewrites.py, test_section_classifier.py, test_section_intent.py, test_validation.py

Porting notes captured during read:
- classifier.py and parser.py read source content via Path.read_text and resolve(); the TS port injects FileSystem.readTextFile. Optional reads (classifier _read_optional_text) catch OSError -> ""; the TS port wraps readTextFile in try/catch -> "".
- inventory.py uses rglob over supported roots and resolve()/relative_to with an escape-root ValueError; the TS port uses FileSystem listDirectory/isDirectory/isFile/exists with POSIX relative normalization and preserves the exact "Selected path escapes the declared source root: <path>" message.
- mapping.py, section_intent.py, rewrites.py, validation.py, _reporting_topology.py, _pipeline_traces.py are pure logic (no I/O).
- reporting.py defines ConverterFileSystem Protocol (mkdir/write_text); the TS port adapts the shared FileSystem (ensureDir/writeTextFile).
- engine.py orchestrates; ConversionRunResult has mapping_records, validation_findings, report_paths, generated_output, wrote_destination, translation_traces.
- cli.py uses Typer; error strings: "source_root must point to an existing directory.", "apply mode requires --destination-root.", "source_ecosystem must be 'github-copilot' or 'claude'." Apply raises Exit(1) when not wrote_destination and any blocking.
- Existing spawn-asserting test: test/repo-automation-service.codex-native-converter.test.ts asserts the Python spawn argv (P8-T6 target). The three P8-T5 files (mcp-tools, handlers, mcp-tool-inputs) assert dispatch/normalization only; mcp-tools mocks spawn but does not assert this command's argv.

Note: This shared epic evidence folder previously held the F9 phase0-source-read.md; F9's content remains in git history and is referenced by the F9 plan. This file now records the F10 source read per the F10 plan task P0-T2.
