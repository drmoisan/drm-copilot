# P5-T9 Bundled Parity After Mirror

Timestamp: 2026-10-02T08-55
Command: poetry -C <ROOT> run pytest <ROOT>/tests/scripts/dev_tools/test_poshqc_bundled_parity.py
EXIT_CODE: 0
Output Summary: 1 passed in 0.06s. `POSHQC_PARITY_PATHS` now includes `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` (P5-T8), and every listed repo-root PoshQC file matches its bundled copy under `extensions/drm-copilot/resources/powershell/PoshQC/`. P5-T9 acceptance (exit 0, `1 passed`) is met. Python coverage is not applicable (D11).

## Output

```text
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 1 item

tests\scripts\dev_tools\test_poshqc_bundled_parity.py .                  [100%]

============================== 1 passed in 0.06s ==============================
```

Note: `poetry -C <ROOT>` with absolute paths replaces the plan's repository-root working directory, because this worktree-isolated session runs each command without a `cd`. An earlier identical run that added `-p no:cacheprovider` also printed `1 passed`; the run recorded above uses the plan's arguments.
