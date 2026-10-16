# R3 COV-1 Node N1: HEAD Repo-Scope Run at the Merged Head (P1-T2)

Timestamp: 2026-10-16T13-08
Command: D-RECOVER (`git status --porcelain -- tests`); D-ISO with S empty: revert none (S empty), restore none (S empty); mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root; scan_folders omitted = repo-scope run); D-FILE-READ (the plan's inline awk program over artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
MCP-DISPOSITION: returned
HEAD-REPO-RUN: returned
VALIDITY: VALID
LINE-SET-CHECK: applied (P0-T3 recorded MODULE-UNCHANGED); listed=30
covered_HEAD: 127
N1: REPRODUCED
Output Summary:
- Tree at run: HEAD `8b82782d3` (Phase 0 commit).
- D-RECOVER: `git status --porcelain -- tests` empty; nothing restored.
- Step 3 (S empty): no revert; porcelain empty; no diff check required.
- Step 5: `git status --porcelain -- tests` empty; `git diff --quiet HEAD -- tests` exit 0.
- D-COV-FRESH (pre): `2026-10-16 08:50:28.688222200 -0400`; `3:<report name="Pester (10/16/2026 12:50:04)">`
- D-COV-FRESH (post): `2026-10-16 09:05:39.382027400 -0400`; `3:<report name="Pester (10/16/2026 13:05:18)">` (both changed: rewritten)
- D-COV-READ: counter count `1`; `covered=11602 missed=697 total=12299 pct=94.33` (local population; not compared with CI)
- D-FILE-READ (`.claude/lib/worktree-resolution/WorktreeResolution.psm1`):
  - `sourcefiles=1 covered=127 missed=17 listed=30 credited=18`
  - `credited-lines: 79 254 255 318 321 322 325 326 327 328 331 376 377 378 379 382 383 384`
  - `uncredited-lines: 144 150 247 284 319 323 329 363 446 453 454 460`
- Classification: TARGET 142; covered_HEAD 127 < 142 -> N1 REPRODUCED.
