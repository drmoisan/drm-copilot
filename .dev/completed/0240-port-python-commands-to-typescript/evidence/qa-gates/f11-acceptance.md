# P7-T10 — F11 Acceptance + Epic Completion (F11 ts-command-runtime-cleanup)

Timestamp: 2026-06-26T09-27

## F11 Acceptance Criteria — line-by-line

| AC | Status | Evidence |
|---|---|---|
| AC-F11-1: helloPython runs in-process via `src/lib/hello-message.ts`, preserves command ID + package.json contribution + `artifacts/hello_python.txt`=`hello_python:ok\n`; no Python spawn | PASS | P1-T1..T5; `test/lib/hello-message.test.ts` (100% cov); `test-coverage-final.md`; integration test asserts in-process write |
| AC-F11-2: `command-runtime.ts` has no `"python"` branch; `RuntimeKind`=`"powershell"`; `detectRuntime()` PowerShell-only; PowerShell behavior unchanged | PASS | P2-T1/T2; `no-python-audit.md` search (3) zero matches; PowerShell tests pass |
| AC-F11-3: `ScriptExecutionOptions.runtimeKind`=`"powershell"`; no `runtimeKind: "python"` in src/ | PASS | P2-T3, P3; `typecheck-final.md` EXIT 0; `no-python-audit.md` search (1) zero |
| AC-F11-4: Four dead Python option builders + orphaned imports removed; in-process exports intact; workflows.ts <= 500 lines | PASS | P3-T1; workflows.ts = 133 lines; typecheck EXIT 0 |
| AC-F11-5: No bundled Python ships; all `resources/templates/*.py` + `resources/scripts/dev_tools/**` removed; `.vscodeignore` excludes `**/*.py` + `resources/scripts/**`; PowerShell + DATA payloads retained | PASS | P4-T1..T4; `no-python-audit.md` search (2) zero; PoshQC/claude-customizations present |
| AC-F11-6: MCP-server prepack copies no Python; payloads preserved | PASS | P4-T5/T6; `mcp-prepack-no-python.md` (0 `.py`, payloads present) |
| AC-F11-7: Exactly the bundled-Python-dependent Python tests removed/edited; no source tests, PoshQC parity, or DATA-payload contract tests weakened | PASS | P5-T1..T5; `python-test-bundled-reference-final-check.md`; see deviation note below |
| AC-F11-8: README no longer claims a Python runtime; describes in-process TS; helloPython listed; PowerShell bullets accurate | PASS | P6-T1; acceptance grep zero matches |
| AC-F11-9: TS suite green (format/lint/typecheck/Jest); hello-message.ts line >= 85% / branch >= 75%; no overall src coverage regression | PASS | `format-final.md`, `lint-final.md`, `typecheck-final.md`, `test-coverage-final.md` (116 suites/1389 tests; All files 96.62%/88.29%); `coverage-delta.md` (line +0.45, branch flat); hello-message.ts 100%/100% |
| AC-F11-10: Python suite green; line >= 85% / branch >= 75%; CI not broken | PASS | `python-test-final.md` (1123 passed, 0 failed; line 85.72%, branch 85.97%); `python-coverage-delta.md` (no regression) |
| AC-F11-11 (AC-E3): RepoAutomationService in-process; `"python"` branch + bundled Python removed | PASS | P2, P3, P4; `no-python-audit.md` |
| AC-F11-12 (AC-E4): No runtime `python` dependency for extension/MCP execution | PASS | `no-python-audit.md` (4 searches zero); `mcp-prepack-no-python.md` |
| AC-F11-13 (epic completion): epic #240 ACs realized; AC-E3/AC-E4 marked satisfied in spec | PASS | this artifact; spec.md AC-E3/AC-E4 set `[x]`; issue-update mirror recorded |

## Epic #240 Completion Verification

- AC-E1 (parity for every Python command) — delivered by F1–F10. The F11 audit confirms no `runtimeKind: "python"` and no live bundled-Python reference remains in `src/`, consistent with all 12 commands already wired to in-process TS before F11. (Cite: F10 acceptance artifact `qa-gates/f10-acceptance.md`.)
- AC-E2 (coverage line >= 85% / branch >= 75% for ported modules) — delivered by F1–F10 and maintained by F11 (`test-coverage-final.md`: All files 96.62%/88.29%; new hello-message.ts 100%/100%). (Cite: F10 acceptance artifact.)
- AC-E3 (in-process; `"python"` branch + bundled Python removed) — delivered by F11. spec.md AC-E3 set to `[x]`.
- AC-E4 (no `python` runtime dependency) — delivered by F11. spec.md AC-E4 set to `[x]`.
- AC-E5 (CI gates pass) — both suites green at F11 completion (TS: format/lint/typecheck/Jest EXIT 0; Python: pytest EXIT 0); confirmed by P7-T1..T8.

## Deviation note (recorded for audit)

Two bundled-Python-dependent Python tests not enumerated in the plan's P0-T2 inventory or P5 list failed after Phase 4 removed the bundled tree: `test_bundled_module_imports_without_repo_root_scripts_package` in `tests/scripts/dev_tools/test_push_down_claude_customizations.py` and in `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`. Both exclusively loaded the removed bundled `dev_tools` modules via `_bundled_scripts_root()`/`_bundled_only_sys_path()` helpers. Consistent with the P5 surgical-edit pattern (P5-T3) and the AC-F11-7/AC-F11-10 intent (remove exactly the bundled-Python-dependent tests; keep the Python suite green), each bundled function and its now-unused helpers/imports were removed; all source-behavior tests in both files were retained. Black/Ruff/Pyright clean on the edited files; full Python suite green (0 failures).

Verdict: All 13 F11 acceptance criteria PASS. Epic #240 ACs AC-E1..E5 satisfied. F11 — the final feature of epic #240 — is complete.
