# R2 COV-1 U2 Isolation (CallTarget split; H2) (issue #935, remediation cycle 2)

Timestamp: 2026-10-16T10-20
Task: [P2-T5]
Command: D-ISO with unit U2. Revert: `git restore --source=b6be46b5e --worktree -- tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` (exit 0). MCP `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = worktree root and `scan_folders` omitted. Restore: `git restore --source=HEAD --worktree -- <the same two paths>` (exit 0). D-FILE-READ: the inline `awk` program of the plan, verbatim, over `artifacts/pester/powershell-coverage.xml`.
EXIT_CODE: 0
MCP-DISPOSITION: returned
VALIDITY: VALID

Output Summary:
- Precondition: P2-T4 recorded `REPRODUCTION: REPRODUCED`; the task runs.
- D-RECOVER: `git status --porcelain -- tests` empty; no recovery.
- Step 3 porcelain (2 lines):
  - ` D tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1`
  - ` M tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`
- Step 3 `git diff --quiet b6be46b5e -- <U2 paths>`: exit 0
- Step 5: `git status --porcelain -- tests` empty; `git diff --quiet HEAD -- tests` exit 0.
- D-COV-FRESH pre: `2026-10-16 06:02:57.685236200 -0400`; `3:<report name="Pester (10/16/2026 06:02:35)">`
- D-COV-FRESH post: `2026-10-16 06:18:23.606539500 -0400`; `3:<report name="Pester (10/16/2026 06:18:07)">` (both values changed: file rewritten)
- D-COV-READ: match count 1; `covered=11614 missed=682 total=12296 pct=94.45` (local population; not comparable with CI)
- D-FILE-READ (exit 0):
  - `sourcefiles=1 covered=127 missed=17 listed=30 credited=18`
  - `credited-lines: 79 254 255 318 321 322 325 326 327 328 331 376 377 378 379 382 383 384`
  - `uncredited-lines: 144 150 247 284 319 323 329 363 446 453 454 460`
- Valid-read tokens 1 to 7: none holds.
- Classification: covered_U2 = 127; covered_HEAD = 127 (P2-T2); covered_BASE = 142 (P2-T3). covered_U2 <= covered_HEAD.

U2: NO-EFFECT
