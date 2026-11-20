# Parity and Completeness Suite Baseline (Issue #476)

Timestamp: 2026-08-16T17-09

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

============================= 20 passed in 0.23s ==============================
```

Output Summary: 20 passed, 0 failed, 0 errors, 0 skipped, in 0.23s. This is the binding root/bundle byte-parity and pack-manifest-completeness surface for the 16 shipped files in the edit set; it is green at baseline, so any post-change failure attributable to a divergent root/mirror pair is a regression introduced by this change.
