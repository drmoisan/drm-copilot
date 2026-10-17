# R3 Final Repo-Scope Coverage Run, Loop Pass 1 (P4-T4)

Timestamp: 2026-10-16T15-50
Command: D-COV-FRESH (pre); mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root; scan_folders omitted = repo-scope run); D-COV-FRESH (post); D-COV-READ; D-FILE-READ (the plan's inline awk program over artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
MCP-DISPOSITION: returned
VALIDITY: VALID
LINE-SET-CHECK: applied (P0-T3 recorded MODULE-UNCHANGED); listed=30
TARGET: 142
Output Summary:
- Tree: HEAD `3ab81c26f` (final tree; no kept candidate).
- D-COV-FRESH (pre): `2026-10-16 11:30:50.042768000 -0400`; `3:<report name="Pester (10/16/2026 15:30:28)">`
- D-COV-FRESH (post): `2026-10-16 11:47:57.999822700 -0400`; `3:<report name="Pester (10/16/2026 15:47:40)">` (both changed: rewritten)
- D-COV-READ (root LINE counter; local repo-scope population; not compared with CI): counter count `1`; `covered=11602 missed=697 total=12299 pct=94.33`
- D-FILE-READ, `.claude/lib/worktree-resolution/WorktreeResolution.psm1`:
  - `sourcefiles=1 covered=127 missed=17 listed=30 credited=18`
  - `credited-lines: 79 254 255 318 321 322 325 326 327 328 331 376 377 378 379 382 383 384`
  - `uncredited-lines: 144 150 247 284 319 323 329 363 446 453 454 460`
  - awk exit code 0
- Valid-read tokens 4 to 7: none held.
- Classification: VALID; covered 127 < TARGET 142.

FINAL-ATTRIBUTION: NOT-RESTORED
