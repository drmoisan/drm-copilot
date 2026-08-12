# P3-T4 child launch runtime and persistence evidence

- Task: `[P3-T4]`
- Result: PASS
- Files and physical line counts:
  - `.codex/scripts/codex-child-launch-runtime.ps1`: 245
  - `.codex/scripts/codex-child-launch-persistence.ps1`: 256
  - `.codex/scripts/launch-epic-child-wave.ps1`: 449
  - `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1`: 497
- PoshQC format: PASS after the final correction; no subsequent mutation.
- PoshQC analyze: PASS with zero findings after correcting `PSUseOutputTypeCorrectly` and `PSShouldProcess` findings and restarting the loop.
- Focused Pester: PASS, 53 passed, 0 failed, 0 errors. Breakdown: attestation 12/12, hardening and resume 19/19, worktree launcher and process behavior 22/22.
- Public compatibility: launcher script parameters and all nine pre-existing public wrapper parameter lists match `HEAD` exactly.
- Runtime proof: immutable argument and environment construction, bound-worktree external `codex exec`, isolated `CODEX_HOME`, and no in-session agent authority passed. Exact process capture returned exit `7`, stdout `prefix<LF>tail`, and stderr `stderr`.
- Persistence and scheduling proof: active-to-completed atomic receipt transitions, schedule-lock creation, and `MaxParallel=4` slot results of `4`, `1`, and `0` for running counts `0`, `3`, and `4` passed.
- Repository checks: `.claude` diff count `0`; `git diff --check` exit `0`.
