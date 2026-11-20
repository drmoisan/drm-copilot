# Final QA — Parity and Completeness Suites (Issue #476)

Timestamp: 2026-08-16T17-43

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` (run from the repository root)

EXIT_CODE: 0

## Raw Output

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-15T12-46
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 20 items

tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py .... [ 20%]
......                                                                   [ 50%]
tests\scripts\dev_tools\test_push_down_claude_pack_manifest_completeness.py . [ 55%]
.                                                                        [ 60%]
tests\scripts\dev_tools\test_push_down_codex_and_agents_resource_contracts.py . [ 65%]
.......                                                                  [100%]

============================= 20 passed in 0.20s ==============================
```

## Comparison to Baseline

| Metric | Baseline (P0-T3) | Post-change (P5-T1) | Delta |
| --- | --- | --- | --- |
| Collected | 20 | 20 | 0 |
| Passed | 20 | 20 | 0 |
| Failed | 0 | 0 | 0 |
| Exit code | 0 | 0 | 0 |

Baseline artifact: `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/baseline/pytest-parity-baseline.2026-08-16T17-09.md`

## Significance

`test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` and `test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` compare each root runtime contract file against its bundle mirror. A green result over the 12 edited shipped Claude-surface files and 4 edited shipped Codex-surface files is mechanical confirmation of the AC8 byte-parity finding recorded independently by SHA256 in `evidence/qa-gates/ac8-byte-parity.2026-08-16T17-37.md`.

The two pack-manifest completeness tests pass because no file was added to or removed from any pack; only the content of already-listed files changed.

Output Summary: 20 passed, 0 failed, 0 errors, 0 skipped, in 0.20s. Exit code 0, identical to the baseline. Root/bundle byte parity and pack-manifest completeness hold across all 16 shipped edited files.
