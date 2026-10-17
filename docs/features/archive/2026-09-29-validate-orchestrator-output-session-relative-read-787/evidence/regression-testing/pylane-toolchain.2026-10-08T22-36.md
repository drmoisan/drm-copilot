# Python Toolchain on PYLANE (P1-T6)

Timestamp: 2026-10-08T22-36

Command: poetry run black tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py
EXIT_CODE: 0
Output Summary: "All done!" and "1 file left unchanged." (no line beginning "reformatted")

Command: poetry run ruff check tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py
EXIT_CODE: 0
Output Summary: All checks passed!

Command: poetry run pyright tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py
EXIT_CODE: 0
Output Summary: 0 errors, 0 warnings, 0 informations

Result: PASS (no reformat, so P1-T3 needs no re-run).
