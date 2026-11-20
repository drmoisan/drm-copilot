# Final QC — Pyright (Phase 6, [P6-T3])

Timestamp: 2026-08-25T10-13

Command: `poetry run pyright`

EXIT_CODE: 0

Output Summary:
- Error count: 0
- Warning count: 0
- Informations: 0
- Raw terminal line: `0 errors, 0 warnings, 0 informations`
- Two non-diagnostic notices were emitted and are not findings: a `venv .venv subdirectory not found` notice (Pyright resolved the Poetry interpreter regardless, as the zero-error result over the configured source set shows) and a Pyright version-availability notice (v1.1.409 -> v1.1.411).
- No file was modified by this stage, so the Phase 6 loop continues to [P6-T4] without restarting.
- Loop iteration: 1
