# R2 COV-1 I-A: claude-lib worktree-resolution Suites Only (H0) (issue #935, remediation cycle 2)

Timestamp: 2026-10-16T09-33
Task: [P2-T1]
Command: D-RECOVER (`git status --porcelain -- tests`); D-COV-FRESH (pre); MCP `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = worktree root and `scan_folders` = `["tests/scripts/claude-lib/worktree-resolution"]`; D-COV-FRESH (post); D-COV-READ; D-FILE-READ (the inline `awk` program of the plan, verbatim, over `artifacts/pester/powershell-coverage.xml`). Revert/restore commands: none (not a D-ISO run).
EXIT_CODE: 0
MCP-DISPOSITION: returned
VALIDITY: VALID

Output Summary:
- D-RECOVER: `git status --porcelain -- tests` empty; no recovery.
- Tree measured: HEAD `b61ce2de2` (Phase 1 commit).
- D-COV-FRESH pre: `2026-10-16 05:30:42.964056800 -0400`; `3:<report name="Pester (10/16/2026 05:30:25)">`
- D-COV-FRESH post: `2026-10-16 05:32:59.301962200 -0400`; `3:<report name="Pester (10/16/2026 05:32:44)">` (both values changed: file rewritten)
- D-COV-READ: match count 1; `covered=674 missed=11622 total=12296 pct=5.48` (single-folder population; informational)
- D-FILE-READ (exit 0):
  - `sourcefiles=1 covered=142 missed=2 listed=30 credited=30`
  - `credited-lines: 79 144 150 247 254 255 284 318 319 321 322 323 325 326 327 328 329 331 363 376 377 378 379 382 383 384 446 453 454 460`
  - `uncredited-lines:` (empty)
- Valid-read tokens 4 to 7: FILE-NOT-REWRITTEN no; COUNTER-MISSING no; FILE-ENTRY-NOT-UNIQUE no (sourcefiles=1); LINE-SET-INCOMPLETE no (listed=30).
- Observation: run alone, the claude-lib worktree-resolution suites credit all 30 lines and reach 142 covered, equal to the CI value on main. Every one of the 30 lines executes and is attributable when no earlier suite compiled the module (H0 refuted for all 30; uncredited set empty).
