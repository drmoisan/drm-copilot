# R4 Co-Run and Isolation Check (P5-T4, issue #935; pre-mortem risk 4)

Timestamp: 2026-10-17T01-27
Command:
- (1) mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root) with scan_folders = the eight paths `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`; then D-JUNIT-SUITE and D-JUNIT-ORDER
- (2a) mcp__drm-copilot__run_poshqc_test with scan_folders = ["tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1"]; then D-JUNIT-SUITE
- (2b) mcp__drm-copilot__run_poshqc_test with scan_folders = ["tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1"]; then D-JUNIT-SUITE
- D-JUNIT-SUITE: `awk '{ sub(/\r$/, "") } /<testcase / { c = $0; sub(/.* classname="/, "", c); sub(/".*/, "", c); sub(/.*[^A-Za-z0-9._-]/, "", c); total[c]++; if ($0 ~ / status="Passed"/ && $0 ~ /\/>$/) pass[c]++ } END { for (s in total) printf "%s tests=%d passed=%d\n", s, total[s], pass[s] + 0 }' artifacts/pester/pester-junit.xml` (output piped through `LC_ALL=C sort` for a stable listing; line order is not significant)
- D-JUNIT-ORDER: `grep -o -E -e '<testsuite name="[^"]*' artifacts/pester/pester-junit.xml | awk '{ sub(/.*[^A-Za-z0-9._-]/, ""); print }'`
EXIT_CODE: 0

Output Summary (local co-run and isolated runs; not compared with CI):
- Dispositions: (1) returned, (2a) returned, (2b) returned.
- `stat -c %y artifacts/pester/pester-junit.xml`: (1) pre `2026-10-16 21:22:28.904590600 -0400`, post `2026-10-16 21:25:07.463605500 -0400`; (2a) pre `2026-10-16 21:25:07.463605500 -0400`, post `2026-10-16 21:26:14.568686400 -0400`; (2b) pre `2026-10-16 21:26:14.568686400 -0400`, post `2026-10-16 21:27:10.320111300 -0400`. Each pair differs.
- Step (1) D-JUNIT-SUITE (eight lines, one per co-run file):
  - `enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1 tests=5 passed=5`
  - `enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 tests=22 passed=22`
  - `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 tests=371 passed=371`
  - `enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1 tests=42 passed=42`
  - `enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 tests=10 passed=10`
  - `enforce-gate-suites.EpicStateIsolation.Tests.ps1 tests=25 passed=25`
  - `enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 tests=54 passed=54`
  - `enforcement-hooks-no-python-invocation.Tests.ps1 tests=32 passed=32`
- Step (1) D-JUNIT-ORDER (container order as the JUnit file lists it): `enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1`, `enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1`, `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`, `enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`, `enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1`, `enforce-gate-suites.EpicStateIsolation.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`, `enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`.
- Step (2a) D-JUNIT-SUITE: `enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 tests=22 passed=22` (equals step (1): 22).
- Step (2b) D-JUNIT-SUITE: `enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1 tests=42 passed=42` (equals step (1): 42).
- Discovery cross-check: step (1) `tests=371` equals `JUNIT_TOTAL=371` in `r4-perf-timing-after.2026-10-17T01-09.md` (the P4-T11 isolated Discovery run).
- SHUFFLE-COMPARISON: not available (the lexicographically greatest `r4-perf-shuffled-run.*.md`, `r4-perf-shuffled-run.2026-10-17T01-10.md`, holds `PERF-TIMING-REFUSED:` and no `ORDER-PRESERVED: YES` line; the direct seeded run was refused by the worktree isolation guard).
- Limitation: the runner fixes the container order (sorted by full path) and Pester does not randomise test order within a container; this check varies which suites run together, not their order.
- Result: every acceptance condition holds (no ORDER-CHECK-MISMATCH).
