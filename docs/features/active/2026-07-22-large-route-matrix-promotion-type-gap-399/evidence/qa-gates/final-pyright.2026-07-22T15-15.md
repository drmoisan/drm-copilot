# Final QC — Pyright Type Check (Issue #399)

Timestamp: 2026-07-22T15-15
Command: `poetry run pyright`
EXIT_CODE: 0
Output Summary: 0 errors, 0 warnings, 0 informations (clean pass). Non-fatal notices about a missing `.venv` subdirectory and an available newer pyright version were emitted; neither affects the result. The prior editor hints about unaccessed new symbols were transient (symbols are now referenced by the wired-in call and the new tests).
