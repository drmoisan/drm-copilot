# R2 COV-1 U4 Isolation (isolation guard; H3-U4) (issue #935, remediation cycle 2)

Timestamp: 2026-10-16T10-50
Task: [P2-T7]
Command: D-ISO with unit U4. Revert: `git restore --source=b6be46b5e --worktree -- <the 9 U4 paths>` (exit 0). MCP `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = worktree root and `scan_folders` omitted. Restore: `git restore --source=HEAD --worktree -- <the same 9 paths>` (exit 0). D-FILE-READ: the inline `awk` program of the plan, verbatim, over `artifacts/pester/powershell-coverage.xml`.
EXIT_CODE: 0
MCP-DISPOSITION: returned
VALIDITY: VALID

Output Summary:
- Precondition: P2-T4 recorded `REPRODUCED`; P2-T5 recorded `U2: NO-EFFECT` (not `RESTORES`); the task runs.
- D-RECOVER: `git status --porcelain -- tests` empty; no recovery.
- U4 paths: created `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`; edited `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1`, `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1`, `tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`.
- Step 3 porcelain (9 lines: 7 ` M`, 2 ` D`):
  - ` M tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1`
  - ` M tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1`
  - ` M tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1`
  - ` D tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1`
  - ` M tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1`
  - ` M tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`
  - ` D tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`
  - ` M tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1`
  - ` M tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`
- Step 3 `git diff --quiet b6be46b5e -- <U4 paths>`: exit 0
- Step 5: `git status --porcelain -- tests` empty; `git diff --quiet HEAD -- tests` exit 0.
- D-COV-FRESH pre: `2026-10-16 06:33:59.591697100 -0400`; `3:<report name="Pester (10/16/2026 06:33:39)">`
- D-COV-FRESH post: `2026-10-16 06:48:31.328395700 -0400`; `3:<report name="Pester (10/16/2026 06:48:11)">` (both values changed: file rewritten)
- D-COV-READ: match count 1; `covered=11629 missed=667 total=12296 pct=94.58` (local population; not comparable with CI)
- D-FILE-READ (exit 0):
  - `sourcefiles=1 covered=142 missed=2 listed=30 credited=30`
  - `credited-lines: 79 144 150 247 254 255 284 318 319 321 322 323 325 326 327 328 329 331 363 376 377 378 379 382 383 384 446 453 454 460`
  - `uncredited-lines:` (empty)
- Valid-read tokens 1 to 7: none holds.
- Classification: covered_U4 = 142; covered_BASE = 142; covered_U4 >= covered_BASE.

U4: RESTORES
