# R3 Baseline Test with Coverage (P0-T8)

Timestamp: 2026-10-16T12-48
Command: D-COV-FRESH (pre); mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root; scan_folders = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"]); D-COV-FRESH (post); D-COV-READ; D-FILE-READ (the plan's inline awk program over artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary:
- Call disposition: returned without error (`ok: true`).
- D-COV-FRESH (pre): last-write `2026-10-16 07:18:57.719369100 -0400`; `3:<report name="Pester (10/16/2026 11:18:41)">`
- D-COV-FRESH (post): last-write `2026-10-16 08:47:04.939084600 -0400`; `3:<report name="Pester (10/16/2026 12:46:43)">`
- Both freshness values changed: the run rewrote the file.
- D-COV-READ: root LINE counter count `1`; `covered=8113 missed=4186 total=12299 pct=65.96` (local three-folder population; not comparable with CI)
- D-FILE-READ (`.claude/lib/worktree-resolution/WorktreeResolution.psm1`; local three-folder population; not comparable with CI):
  - `sourcefiles=1 covered=127 missed=17 listed=30 credited=18`
  - `credited-lines: 79 254 255 318 321 322 325 326 327 328 331 376 377 378 379 382 383 384`
  - `uncredited-lines: 144 150 247 284 319 323 329 363 446 453 454 460`
  - awk exit code 0
