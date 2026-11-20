# Clean Layout [P0-T3] — remediation cycle 1

Timestamp: 2026-11-20T19-14
Command: sh SCRATCH/issue-1016-clean-layout.sh (git -C <worktree> ls-files docs; porcelain capture; pwsh -NoProfile -File SCRATCH/issue-1016-clean-layout.ps1, which runs Move-Item of each existing moved-root directory into SCRATCH/clean-layout/ and Test-Path of each afterwards; porcelain capture and cmp)
EXIT_CODE: 0
Output Summary: `git ls-files docs` lists only `docs/README.md`; no tracked path was found under a moved root. Relocated to SCRATCH/clean-layout/: `docs/features` (0 files; empty directory tree left by the move), `docs/research` (0 files; empty directory tree), `docs/discovery` (0 files; empty directory tree). `docs/engineering`: none present. After the move Test-Path is False for all four directories. Porcelain output before and after the move is byte-identical (cmp). No tracked file changed.

| Directory | Result | Files |
| --- | --- | --- |
| docs/features | relocated | 0 |
| docs/research | relocated | 0 |
| docs/engineering | none present | - |
| docs/discovery | relocated | 0 |
