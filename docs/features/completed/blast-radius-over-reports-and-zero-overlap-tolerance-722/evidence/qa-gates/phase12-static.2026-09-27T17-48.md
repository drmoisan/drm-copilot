# Phase 12 Static Gates, Python and PowerShell (P12-T8)

Timestamp: 2026-09-27T17-48
Command: poetry run black tests/scripts/dev_tools/test_blast_radius_historical_runs.py ; poetry run black --check (same file) ; poetry run ruff check --no-fix (same file) ; poetry run pyright (same file) ; sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 ; mcp__drm-copilot__run_poshqc_format (scan_folders = that file) ; file-hashes again ; sh SCRATCH/run-ps.sh SCRATCH/ps-format-check.ps1 (that file) ; mcp__drm-copilot__run_poshqc_analyze (scan_folders = that file)
EXIT_CODE: 0
Output Summary: Python: the write-mode black run reformatted the P12-T5 file ("1 file reformatted."), so P12-T7 was re-run (historical-after-tests.2026-09-27T17-48.md: 24 passed; Pester 9/9, FailedCount=0). After the reformat, black check mode exits 0 and prints "1 file would be left unchanged."; ruff exits 0 with "All checks passed!"; pyright exits 0 with "0 errors, 0 warnings, 0 informations". PowerShell: the MCP format call returned ok=true without raising and left the P12-T6 file's hash unchanged; A6 prints FORMAT-SUMMARY ChangedCount=0; the MCP analyze call returned ok=true without raising. The file has no bundled mirror, so no mirror re-copy applies.

## Python (tests/scripts/dev_tools/test_blast_radius_historical_runs.py)

| Command | EXIT_CODE | Output |
| --- | --- | --- |
| poetry run black (write mode) | 0 | reformatted tests\scripts\dev_tools\test_blast_radius_historical_runs.py; 1 file reformatted. |
| poetry run black --check | 0 | 1 file would be left unchanged. |
| poetry run ruff check --no-fix | 0 | All checks passed! |
| poetry run pyright | 0 | 0 errors, 0 warnings, 0 informations |

Loop note: the reformat changed a tracked file, so the dependent test task P12-T7 was re-run on the reformatted file; the check, lint, and type runs above were taken on the reformatted file, and no further change occurred.

## PowerShell (tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1)

| Step | Result |
| --- | --- |
| A5 before format | Hash=1AB0C0CB8763964E9B557A901107B0390F6D93D23C7E9DCC9826666E4623A8E0 |
| MCP format | returned `{"ok":true,"tool":"run_poshqc_format",...,"summary":"Ran bundled PoshQC format ... with 1 selected scan folder(s)."}` |
| A5 after format | Hash=1AB0C0CB8763964E9B557A901107B0390F6D93D23C7E9DCC9826666E4623A8E0 (unchanged) |
| A6 | FORMAT file=tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 Changed=False; FORMAT-SUMMARY ChangedCount=0 |
| MCP analyze | returned `{"ok":true,"tool":"run_poshqc_analyze",...,"summary":"Ran bundled PoshQC analyze ... with 1 selected scan folder(s)."}` |

SCRATCH denotes the executor session scratchpad directory (outside the repository).
