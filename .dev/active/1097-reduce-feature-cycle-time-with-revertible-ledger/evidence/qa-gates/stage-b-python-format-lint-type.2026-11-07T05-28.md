# Stage B Python Format, Lint, and Type Gate

Timestamp: 2026-11-07T05-28
Command: poetry run black --check, poetry run ruff check --no-fix, and poetry run pyright on tests/scripts/dev_tools/test_stage_timing_checkpoint_key.py
EXIT_CODE: 0
Output Summary: Final pass: Black reports 1 file would be left unchanged (exit 0), Ruff reports all checks passed (exit 0), Pyright reports 0 errors, 0 warnings, 0 informations (exit 0). The first pass found Ruff E501 on 12 docstring lines and Black wanted to reformat the file; both were repaired in the new test file (docstrings re-wrapped, Black applied) and the whole loop was re-run from Black, which then passed in a single pass. Pyright also prints a note that no .venv subdirectory exists in the worktree and a notice about a newer Pyright version; neither is a finding.
