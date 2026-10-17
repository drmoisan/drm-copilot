# R3 Final QA Test with Coverage (three folders), Loop Pass 1 (P4-T3)

Timestamp: 2026-10-16T15-32
Command: D-COV-FRESH (pre); mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root; scan_folders = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-runtime"]); D-COV-FRESH (post); D-COV-READ; D-FILE-READ (the plan's inline awk program over artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary:
- Tree: HEAD `3ab81c26f`.
- Call disposition: returned without error (`ok: true`).
- D-COV-FRESH (pre): `2026-10-16 11:12:38.576914000 -0400`; `3:<report name="Pester (10/16/2026 15:12:18)">`
- D-COV-FRESH (post): `2026-10-16 11:30:50.042768000 -0400`; `3:<report name="Pester (10/16/2026 15:30:28)">` (both changed: rewritten)
- D-COV-READ (local three-folder population; not comparable with CI): counter count `1`; `covered=8113 missed=4186 total=12299 pct=65.96`
- D-FILE-READ, `.claude/lib/worktree-resolution/WorktreeResolution.psm1` (local three-folder population; not comparable with CI):
  - `sourcefiles=1 covered=127 missed=17 listed=30 credited=18`
  - `credited-lines: 79 254 255 318 321 322 325 326 327 328 331 376 377 378 379 382 383 384`
  - `uncredited-lines: 144 150 247 284 319 323 329 363 446 453 454 460`
  - awk exit code 0
- The three-folder root and per-file values equal the P0-T8 baseline values (covered 8113 / missed 4186; per-file 127 / 17 / 18).
