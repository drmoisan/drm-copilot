# Repository Coverage Config (P6-T25)

Timestamp: 2026-10-02T08-45
Command: git/static-equivalent deviation DEV-P6-T25 (replaces `ConvertFrom-Json` in a `pwsh` child). Read tool on `config/poshqc-coverage.json`; `git -C <ROOT> hash-object config/poshqc-coverage.json` recorded in DEV-P3-T7 (`71d9bfcc52a93df274d0eb5cf8fcf12b667c78e3`; the file is unchanged since, `git status --porcelain` empty). Runtime proof: CI run A logged `Code coverage population: source=config; files=174` (https://github.com/drmoisan/drm-copilot/actions/runs/36983551836/job/110763341194, job log line 837), so `Get-PoshQCCoverageConfigRoot` parsed and validated the file in CI.
EXIT_CODE: 0
Output Summary: VERSION=1 ROOTS=.claude/hooks,.claude/lib,.codex/hooks,.codex/scripts,scripts
- File content (10 lines plus trailing newline): `{`, `"version": 1,`, `"roots": [`, the five roots one per line in the order above, `]`, `}`; two-space indentation; matches the D6 document.
- Acceptance (AC-10): output `VERSION=1 ROOTS=.claude/hooks,.claude/lib,.codex/hooks,.codex/scripts,scripts`. Met.
