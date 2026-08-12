# Parallel launcher fail-before evidence

## P3-T1 contract-test write

- Recorded: `2026-08-11T03:33:21.2192944-04:00`.
- Created `tests/scripts/codex-hooks/parallel-child-worktree-launcher.Tests.ps1` with six preimplementation contract cases.
- Extended `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` to preserve the isolated epic-child Codex home contract.
- Extended `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1` to preserve the exact existing public parameter sets: `LaunchSpecPath,MaxParallel,Supervisor,Wait,RepositoryRoot` and `ReceiptPath,Prompt,LastMessagePath`.
- Static contract coverage requires `surface=parallel`, `base_branch=main`, `pr_target=main`, no integration or fan-in fields, exact item/worktree/branch binding, immutable specification and checkpoint hashes, deterministic batch order, isolated `CODEX_HOME`, no epic-child environment variables, and matching resume evidence.
- The three planned parallel adapter files are absent before implementation, so the six new cases are expected to fail at their shared adapter-presence guard in P3-T2.

## P3-T1 quality gates

- `mcp__drm-copilot__run_poshqc_format`, scoped to the three test files: PASS.
- Initial `mcp__drm-copilot__run_poshqc_analyze`: FAIL with one `PSUseSingularNouns` finding for `Import-ParallelChildAdapters` at line 19.
- Corrected the helper name to `Import-ParallelChildAdapter` and restarted the loop.
- Final `mcp__drm-copilot__run_poshqc_format`: PASS.
- Final `mcp__drm-copilot__run_poshqc_analyze`: PASS with zero findings.
- Physical line counts: parallel contract 227; epic launcher 496; epic hardening/resume 474. All are at or below 500 lines.
- `git diff --check` for the three test files: PASS.
- `.claude/` diff: empty.

## P3-T2 expected-failure execution

- Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"` and `scan_folders=["tests/scripts/codex-hooks"]`.
- Result: expected FAIL, exit code 6.
- JUnit receipt: `artifacts/pester/pester-junit.xml`, written `2026-08-11T03:36:52-04:00`.
- Assertions: 496 total; 490 passed; 6 failed; 0 errors.
- All six failures are the new cases in `parallel-child-worktree-launcher.Tests.ps1`. Each failed at the shared adapter-presence assertion because these three preimplementation files are absent: `parallel-child-launch-contract.ps1`, `launch-parallel-child-batch.ps1`, and `resume-parallel-child.ps1`.
- Existing epic launcher, hardening, and resume coverage: 168 matched cases; 168 passed; 0 failed.
- No unrelated failure occurred. The fail-before result is accepted only for P3-T2.

### Recovery rerun

- Repeated the exact authoritative MCP command after recovery; result remained expected FAIL with exit code 6.
- JUnit receipt rewritten `2026-08-11T03:39:47-04:00`: 496 total, 490 passed, 6 failed, 0 errors, 76.674 seconds.
- The six failures shared one message and named only the three absent parallel adapter paths.
- Direct epic launcher plus hardening/resume owners: 41 passed, 0 failed. All seven epic-named suites in the scan: 142 passed, 0 failed.
