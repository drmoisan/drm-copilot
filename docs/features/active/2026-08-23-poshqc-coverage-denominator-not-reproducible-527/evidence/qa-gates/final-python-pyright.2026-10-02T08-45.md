# Final Python Type Check (P6-T22)

Timestamp: 2026-10-02T08-45
Command: poetry -C <ROOT> run pyright <ROOT>/tests/scripts/dev_tools/test_poshqc_bundled_parity.py
EXIT_CODE: 0
Output Summary: `0 errors, 0 warnings, 0 informations`. Pyright also printed a `venv .venv subdirectory not found in venv path` notice and a newer-version notice; neither affects the result.
- Acceptance: exit code 0 and output containing `0 errors`. Met.
