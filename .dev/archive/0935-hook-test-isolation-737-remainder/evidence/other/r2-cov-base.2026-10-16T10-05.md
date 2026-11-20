# R2 COV-1 I-C: BASE Repo-Scope Run (all five units reverted) (issue #935, remediation cycle 2)

Timestamp: 2026-10-16T10-05
Task: [P2-T3]
Command: D-ISO with unit set U1, U2, U3, U4, U5 (all 18 unit-table paths). Revert: `git restore --source=b6be46b5e --worktree -- <18 paths>` (exit 0). MCP `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = worktree root and `scan_folders` omitted. Restore: `git restore --source=HEAD --worktree -- <18 paths>` (exit 0). D-FILE-READ: the inline `awk` program of the plan, verbatim, over `artifacts/pester/powershell-coverage.xml`.
EXIT_CODE: 0
MCP-DISPOSITION: returned
VALIDITY: VALID

Output Summary:
- D-RECOVER: `git status --porcelain -- tests` empty; no recovery.
- Tree measured: HEAD `b61ce2de2` with the 18 unit-table paths at their `b6be46b5e` content (test tree equal to `b6be46b5e`'s).
- Step 3 porcelain (18 lines: 11 ` M`, 7 ` D`):
  - ` M tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1`
  - ` M tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1`
  - ` M tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1`
  - ` D tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1`
  - ` D tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1`
  - ` M tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`
  - ` M tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1`
  - ` M tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`
  - ` D tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`
  - ` M tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1`
  - ` M tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`
  - ` D tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1`
  - ` M tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`
  - ` D tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1`
  - ` M tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1`
  - ` D tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Helpers.ps1`
  - ` D tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1`
  - ` M tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
- Step 3 `git diff --quiet b6be46b5e -- <18 paths>`: exit 0
- Step 5: `git status --porcelain -- tests` empty; `git diff --quiet HEAD -- tests` exit 0.
- D-COV-FRESH pre: `2026-10-16 05:47:12.495090500 -0400`; `3:<report name="Pester (10/16/2026 05:46:54)">`
- D-COV-FRESH post: `2026-10-16 06:02:57.685236200 -0400`; `3:<report name="Pester (10/16/2026 06:02:35)">` (both values changed: file rewritten)
- D-COV-READ: match count 1; `covered=11629 missed=667 total=12296 pct=94.58` (local population; not comparable with CI)
- D-FILE-READ (exit 0):
  - `sourcefiles=1 covered=142 missed=2 listed=30 credited=30`
  - `credited-lines: 79 144 150 247 254 255 284 318 319 321 322 323 325 326 327 328 329 331 363 376 377 378 379 382 383 384 446 453 454 460`
  - `uncredited-lines:` (empty)
- Valid-read tokens 1 to 7: none holds.
- covered_BASE = 142.
