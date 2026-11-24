# Final QC - Python Static - Issue #1228 ([P2-T2])

Timestamp: 2026-11-24T06-07
Command: `sh SCRATCH/issue-1228-pystatic.sh q1` (from the item worktree root with VIRTUAL_ENV unset: `poetry run black --check .`; `poetry run ruff check .`; `poetry run pyright`; `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`), launched from `artifacts/issue-1228/qa.sh q1`
EXIT_CODE: 0
Output Summary:
- Black check: EXIT_CODE 0; "1071 files would be left unchanged." (finding count 0; [P0-T2]: 0).
- Ruff: EXIT_CODE 0; "All checks passed!" (finding count 0; [P0-T2]: 0).
- Pyright: EXIT_CODE 0; "0 errors, 0 warnings, 0 informations" (finding count 0; [P0-T2]: 0).
- Codex generator `--check`: EXIT_CODE 0, no drift reported (AC-12).
- The item changes no Python file. The commands ran at 2026-11-24T06-02 (UTC). Result: PASS.
- Stamp correction: the earlier file `python-static.2026-11-24T06-05.md` carries the same results, but its stamp was not read from the clock before the write; the file's write time is 2026-11-24T06-06. That file is kept unchanged (evidence is append-only), and this file, stamped from a clock reading, is the artifact of record because it sorts last.
