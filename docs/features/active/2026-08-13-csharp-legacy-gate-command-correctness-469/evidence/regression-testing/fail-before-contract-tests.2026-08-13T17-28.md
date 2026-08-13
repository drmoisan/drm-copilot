# Fail-Before — Legacy Gate Content Contract Tests (Issue #469)

Timestamp: 2026-08-13T17-28

Command:
```
poetry run pytest \
  tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_legacy_variant_files_contain_corrected_gate_commands \
  tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_legacy_variant_files_exclude_stale_gate_commands \
  tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_codex_legacy_variant_files_contain_corrected_gate_commands \
  tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_codex_legacy_variant_files_exclude_stale_gate_commands
```

EXIT_CODE: 1

Output Summary:
- Result: **4 failed, 0 passed** (0.10s). This is the expected `[expect-fail]` outcome for plan task [P1-T8]: the four regression tests were authored before the Phase 2 content correction and fail against the current stale variant content. It is fail-before proof for AC9, AC10, and AC11, not a defect.
- Failing tests:
  - `test_claude_legacy_variant_files_contain_corrected_gate_commands`
  - `test_claude_legacy_variant_files_exclude_stale_gate_commands`
  - `test_codex_legacy_variant_files_contain_corrected_gate_commands`
  - `test_codex_legacy_variant_files_exclude_stale_gate_commands`
- Representative assertion message, Claude surface (required-substring test):
  `AssertionError: Required legacy gate substring missing from .claude-variants\csharp-legacy\rules\csharp.md: dotnet tool run csharpier format .`
- Representative assertion message, Codex surface (file-scoped forbidden-literal test):
  `AssertionError: Stale legacy gate substring present in .agents-variants\csharp-legacy\skills\csharp\SKILL.md: csharpier .`
- Assertion granularity note: the expected count is measured per pytest test function, not per violating span. Both exclude tests fail on the first file-scoped forbidden literal encountered; the span-scoped `/p:Nullable=enable` predicate is asserted after the file-scoped literals in the same test function and is exercised in the Phase 2 pass-after run.
- Coverage was disabled for this targeted run (`--no-cov`); coverage is recorded by the Phase 0 baseline and Phase 4 final-QA full-suite runs.
