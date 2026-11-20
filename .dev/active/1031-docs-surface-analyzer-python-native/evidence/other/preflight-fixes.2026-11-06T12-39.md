# Preflight Fixes - remediation cycle 1 (issue #1031)

Timestamp: 2026-11-06T12-39
Plan: docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/remediation-plan.2026-11-05T23-18.md
Signal: PREFLIGHT: ALL CLEAR
Validator: MCP `validate_orchestration_artifacts` (plan) ok before and after the fixes; branch-current `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan` exit 0 before and after the fixes.

## Fix 1 - `## Execution Context`, Comment audit contract

- Defect class: validator-blind unsatisfiable-literal risk (statement detection undefined); trivial, the asserted counts are unchanged.
- Observation: a line-only match of loop headers ending in a colon over the twelve `PYLIB` files finds 90 headers; the reviewer's AST count is 91. The difference is the multi-line parenthesized `for result in (` loop of `cli.py`, so the [P0-T7] condition "at least 91 R-LOOP" could fail for a line-only audit. The test modules `test_docs_python_native_cli_argparse.py`, `_cli_click.py` and `_cli_typer.py` hold 12 `def`/`class`/loop lines inside triple-quoted fixture sources; flagging them would make the [P3-T7] and [P6-T16] `VERDICT: PASS` conditions unreachable without changing fixtures and assertions.
- Change: the contract now defines a header as the logical line through bracket balance to its closing colon and states that lines inside string literals are skipped.

## Fix 2 - [P0-T2] match definition and dispositions

- Defect class: existing-test search scope (validator-blind); trivial, the purpose of the search is unchanged.
- Observation: the file-name search matches unrelated fixture text in `TESTS/DocsAnalyzerPythonCli.Tests.ps1`, `TESTS/DocsAnalyzerPythonHttp.Tests.ps1`, `TESTS/DocsSurface.Tests.ps1`, `TESTS/fixtures/python-native-corpus.json`, `TESTS/fixtures/python-surface-corpus.json`, `tests/scripts/dev_tools/test_build_discovery_runtime_io.py` and `tests/scripts/dev_tools/test_discovery_build_identity.py`, and the symbol search for `Context` matches Pester `Context` blocks. None was in the disposition list, so the "any other match stops execution" clause would have fired on unrelated text. The `docs_python_native/source.py` literal in `test_ast_parse_is_the_only_parse_call` had no stated disposition.
- Change: a counted match is now one that references the `docs_python_native` package, a listed PowerShell function or the error code, or a path under `docs_python_native/`; the unrelated matches are named with disposition unchanged; the safety-test literal is recorded as unchanged.
- Verification: every test import of a moved symbol was enumerated against the tree; all nine importing test modules are already named in the [P0-T2] dispositions.

## Fix 3 - [P0-T6] baseline finding count

- Defect class: literal correction of a baseline count; trivial, the total of 20 is unchanged.
- Observation: `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the two modules and their `MIRROR` copies reports 20 findings: 16 Warning and 4 Information (`PSUseOutputTypeCorrectly` on `Get-DocsPythonNativeKind`, two per copy). The plan required "20 Warning findings".
- Change: the acceptance now states 20 findings (16 Warning, 4 Information).

## Checked and not changed

- [P5-T3] is deferred by design. No executed task edits, checks or depends on S4, U4, S13 or U13: [P5-T1] edits no `## Acceptance Criteria` line, [P6-T20] and [P6-T21] record the four as `N/A-pending-owner-decision`, and the traceability row marks them non-blocking.
- The other 18 `.ps1`/`.psm1` files of the branch diff have zero analyzer findings and zero formatter differences, so [P1-T3] and [P6-T7] are satisfiable.
- Prior evidence shows the five `LIB` files with no missed changed line, so [P6-T9] is satisfiable once the new throw has its test.
- The [P5-T1] tokens `InvokeInterpreter`, `Get-DocsDeclarationDigest` and `AnalyzerIds` occur only outside `## Acceptance Criteria`.
- Manifest ordinal positions and the 7-added, 1-deleted numstat of [P4-T2] match the current `python.json`.
