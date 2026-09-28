# Isolated QA Rerun

Timestamp: 2026-08-31
Issue: #615
Environment: Windows PowerShell; isolated clone; Poetry Python 3.13.12

Scratch paths:

- Failed first clone: `C:\Users\DanMoisan\AppData\Local\Temp\drm-copilot-qa-615-f4bd4edf3ab84d5fb0dd961e377a2316` (left in place because checkout hit Windows filename-length errors).
- QA clone: `C:\Users\DanMoisan\AppData\Local\Temp\q615-6c5707cd` (left in place; no cleanup mutation performed).

Implementation-byte comparison:

- Main file: `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
- Main SHA-256: `018F39BEE1F9DB1F0ADD38FD430B398A270124749C4479827BA6FA06C932CCE2`
- Isolated SHA-256: `018F39BEE1F9DB1F0ADD38FD430B398A270124749C4479827BA6FA06C932CCE2`
- Result: exact byte match.

Commands and results, in required order:

1. `poetry run black .` — exit 0; 459 files unchanged.
2. `poetry run ruff check .` — exit 0; all checks passed.
3. `poetry run pyright` — exit 0; 0 errors, 0 warnings, 0 informations. Poetry reported the clone-local `.venv` was absent and used the configured environment.
4. `poetry run pytest --cov=. --cov-report=term-missing` — exit 0; 4245 passed, 5 skipped in 41.75s; total coverage 93% (15210 statements, 1109 missed).
5. `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` — exit 0; 36 passed in 0.17s.

Changed-file summary:

- The isolated clone contains only the copied issue 615 implementation file as a working-tree change.
- No runtime skill, mirror, production file, or unrelated file was changed.
- Main worktree `.claude/state` and `.claude/worktrees` were not accessed for mutation.

Conclusion: all required isolated Python QA gates pass.
