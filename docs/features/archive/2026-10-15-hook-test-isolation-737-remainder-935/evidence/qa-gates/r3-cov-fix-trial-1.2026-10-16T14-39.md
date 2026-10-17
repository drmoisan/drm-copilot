# R3 COV-1 Fix Trial 1: FX-1 (P3-T2)

Timestamp: 2026-10-16T14-39
Command: D-RECOVER (`git status --porcelain -- tests` empty); FX-1 edit (Edit tool) in `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1`: the line `. (Join-Path $PSScriptRoot 'EpicStateIsolation.HookReference.Helpers.ps1')` replaced by the plan's three verbatim lines (two comment lines and the `Parser]::ParseFile(...).GetScriptBlock())` dot-source); token checks; mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root; scan_folders omitted = repo-scope run); D-FILE-READ (the plan's inline awk program over artifacts/pester/powershell-coverage.xml); restore `git restore --source=HEAD --worktree -- tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` (exit 0)
EXIT_CODE: 0
MCP-DISPOSITION: returned
VALIDITY: VALID
covered: 127
TARGET: 142
Output Summary:
- Tree: P2-T5 commit `af4672b7d` plus the FX-1 edit.
- Token checks on `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` (all pass):
  - `grep -c -E -e '^ *[.] [(]Join-Path .PSScriptRoot .EpicStateIsolation[.]'` -> 0 (expected 0)
  - `grep -c -F -e 'GetScriptBlock())'` -> 1 (expected 1)
  - `grep -c -F -e 'adds no entry to the'` -> 1 (expected 1)
  - `awk 'END { print NR }'` -> 435 (expected P0-T4 433 + 2)
- D-COV-FRESH (pre): `2026-10-16 10:23:34.022736300 -0400`; `3:<report name="Pester (10/16/2026 14:23:17)">`
- D-COV-FRESH (post): `2026-10-16 10:37:28.650551400 -0400`; `3:<report name="Pester (10/16/2026 14:37:10)">` (both changed: rewritten)
- D-COV-READ: counter count `1`; `covered=11601 missed=698 total=12299 pct=94.32`
- D-FILE-READ (`.claude/lib/worktree-resolution/WorktreeResolution.psm1`):
  - `sourcefiles=1 covered=127 missed=17 listed=30 credited=18`
  - `credited-lines: 79 254 255 318 321 322 325 326 327 328 331 376 377 378 379 382 383 384`
  - `uncredited-lines: 144 150 247 284 319 323 329 363 446 453 454 460`
- Valid-read tokens 4 to 7: none held.
- Classification: call returned; VALID; covered 127 < TARGET 142 -> FIX-NOT-RESTORED. The candidate was restored.
- After the task: `git status --porcelain -- tests` empty; `git diff --quiet HEAD -- tests` exit 0.

TRIAL-1: FX-1 FIX-NOT-RESTORED
