# R3 COV-1 Node N3: S-C (four edited guard suites) Reverted (P1-T4)

Timestamp: 2026-10-16T13-42
Command: D-RECOVER; revert `git restore --source=5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea --worktree -- tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1` (exit 0); mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root; scan_folders omitted = repo-scope run); restore `git restore --source=HEAD --worktree -- <the same four paths>` (exit 0); D-FILE-READ (the plan's inline awk program over artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
MCP-DISPOSITION: raised (`Command exited with code 8.`; the stderr excerpt returned by the MCP runtime contained unrelated publish-verification text and no Pester output). A raised call does not by itself invalidate the read; freshness decides.
VALIDITY: VALID
LINE-SET-CHECK: applied (P0-T3 recorded MODULE-UNCHANGED); listed=30
N3: NO-EFFECT
Output Summary:
- D-RECOVER: `git status --porcelain -- tests` empty; nothing restored.
- Step-3 porcelain (four ` M` lines, as expected):
  - ` M tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1`
  - ` M tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`
  - ` M tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1`
  - ` M tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`
  - `git diff --quiet 5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea -- <S>` exit 0.
- Step 5: `git status --porcelain -- tests` empty; `git diff --quiet HEAD -- tests` exit 0.
- D-COV-FRESH (pre): `2026-10-16 09:23:52.616188400 -0400`; `3:<report name="Pester (10/16/2026 13:23:31)">`
- D-COV-FRESH (post): `2026-10-16 09:40:34.292087400 -0400`; `3:<report name="Pester (10/16/2026 13:40:11)">` (both changed: rewritten)
- D-COV-READ: counter count `1`; `covered=11602 missed=697 total=12299 pct=94.33`
- D-FILE-READ (`.claude/lib/worktree-resolution/WorktreeResolution.psm1`):
  - `sourcefiles=1 covered=127 missed=17 listed=30 credited=18`
  - `credited-lines: 79 254 255 318 321 322 325 326 327 328 331 376 377 378 379 382 383 384`
  - `uncredited-lines: 144 150 247 284 319 323 329 363 446 453 454 460`
- Classification: covered 127 < TARGET 142; 127 <= covered_HEAD 127 -> N3 NO-EFFECT.
- The raise is likely caused by REF-content suites failing against the HEAD helpers; this is not verified, because the MCP result carries no per-row output.
