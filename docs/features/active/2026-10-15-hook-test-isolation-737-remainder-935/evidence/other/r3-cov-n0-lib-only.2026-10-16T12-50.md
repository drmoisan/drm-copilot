# R3 COV-1 Node N0: claude-lib-only Attribution and TARGET (P1-T1)

Timestamp: 2026-10-16T12-50
Command: D-RECOVER (`git status --porcelain -- tests`); D-COV-FRESH (pre); mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root; scan_folders = ["tests/scripts/claude-lib/worktree-resolution"]); D-COV-FRESH (post); D-COV-READ; D-FILE-READ (the plan's inline awk program over artifacts/pester/powershell-coverage.xml). Revert/restore: none (no isolation set for N0).
EXIT_CODE: 0
MCP-DISPOSITION: returned
VALIDITY: VALID
LINE-SET-CHECK: applied (P0-T3 recorded MODULE-UNCHANGED); listed=30
TARGET: 142 (TARGET-SOURCE: lib-only)
TARGET-CHECK: EQUALS-ESTABLISHED
Output Summary:
- D-RECOVER: `git status --porcelain -- tests` empty before the task; nothing restored.
- Step-3 porcelain / diff: not applicable (no isolation set).
- D-COV-FRESH (pre): `2026-10-16 08:47:04.939084600 -0400`; `3:<report name="Pester (10/16/2026 12:46:43)">`
- D-COV-FRESH (post): `2026-10-16 08:50:28.688222200 -0400`; `3:<report name="Pester (10/16/2026 12:50:04)">` (both changed: rewritten)
- D-COV-READ: counter count `1`; `covered=674 missed=11625 total=12299 pct=5.48` (local population; not compared with CI)
- D-FILE-READ (`.claude/lib/worktree-resolution/WorktreeResolution.psm1`):
  - `sourcefiles=1 covered=142 missed=2 listed=30 credited=30`
  - `credited-lines: 79 144 150 247 254 255 284 318 319 321 322 323 325 326 327 328 329 331 363 376 377 378 379 382 383 384 446 453 454 460`
  - `uncredited-lines:`
- Valid-read tokens 4 to 7: none held (file rewritten; counter present; sourcefiles=1; listed=30).
- After the task: `git status --porcelain -- tests` empty.
