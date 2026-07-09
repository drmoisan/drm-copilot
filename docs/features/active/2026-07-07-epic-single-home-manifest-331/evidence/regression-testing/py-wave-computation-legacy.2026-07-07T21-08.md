# Regression — epic_wave_computation.py Byte-Identical (#331)

Timestamp: 2026-07-07T21-08
Command: poetry run pytest tests/scripts/dev_tools/test_epic_wave_computation.py -v
EXIT_CODE: 0
Output Summary: 8 passed, same pass set as the P0-T6 reference.

No algorithmic change required (research §3: compute_wave_numbers is already a
pure, key-agnostic function over string keys and does not read the manifest file).

Unmodified-file evidence:
- `git status --porcelain scripts/dev_tools/epic_wave_computation.py` returns empty
  (the file is unmodified).
- `git diff --stat` shows no change to
  tests/scripts/dev_tools/test_epic_wave_computation.py (the legacy test is
  byte-identical).
