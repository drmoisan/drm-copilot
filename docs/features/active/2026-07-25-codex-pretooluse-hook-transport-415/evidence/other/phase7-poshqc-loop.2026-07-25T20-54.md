# Phase 7 — PoshQC Loop, Full Workspace (Issue #415)

Timestamp: 2026-07-25T20-54

Convention C3 loop, `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53`, full workspace.

## Loop restart (recorded)

The first attempt at this loop **failed at the analyze stage**, and the C3 restart rule was applied rather than worked around.

- Attempt 1, stage 2: `mcp__drm-copilot__run_poshqc_analyze` → EXIT_CODE **1**, `{"ok":false, ..., "summary":"Command exited with code 1.", "stderr_excerpt":"Exception: PSScriptAnalyzer reported 1 issue(s)."}`
- Diagnosis, by running PSScriptAnalyzer directly against the changed and added files with the repository settings at `scripts/powershell/PoshQC/settings/pssa.settings.psd1`:

```
tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1:109 [Warning] PSUseShouldProcessForStateChangingFunctions -
  Function 'New-CodexPreToolPayload' has verb that could change system state. Therefore, the function has to support 'ShouldProcess'.
```

- Root cause: the new integration suite defined its payload builder with the `New-` verb, which PSScriptAnalyzer classifies as state-changing. The function only formats a JSON string and changes no state.
- Fix: renamed `New-CodexPreToolPayload` to `ConvertTo-CodexPreToolPayload` (2 occurrences), matching the verb already used by the sibling transport suite. The analyzer finding was fixed at its cause; no suppression was added and no rule was excluded.
- The loop was then **restarted from stage 1** as convention C3 requires.

## Command / EXIT_CODE per stage (final, clean pass)

| Stage | Command | EXIT_CODE | Result |
|---|---|---|---|
| 1 | `mcp__drm-copilot__run_poshqc_format` | 0 | zero files changed |
| 2 | `mcp__drm-copilot__run_poshqc_analyze` | 0 | 0 errors, 0 warnings, 0 information |
| 3 | `mcp__drm-copilot__run_poshqc_test` | 0 | 1391 tests, 0 failures |

**All three stages passed in one uninterrupted pass** after the restart.

## Output Summary

**Test counts:** `tests="1391"`, `failures="0"`, `errors="0"`, `disabled="9"`, `time="97.302"`.

The workspace total rose from 1358 to **1391** (+33), which is exactly the two new suites: 27 tests in `codex-pretooluse-transport.Tests.ps1` and 6 in `codex-pretooluse-integration.Tests.ps1`. The 9 skipped tests are the same pre-existing host-conditional cases recorded at baseline.

Suite wall time rose from about 45 s to 97 s. The increase is inherent to the mandated coverage: the two new suites perform roughly 130 real `pwsh` process spawns, because `spec.md` requires process-level rather than in-process verification of the stdin/stdout transport.

**Line-coverage headline:** `LINE missed="235" covered="2151"` → total 2386 → **90.15%**, above the 85% threshold. Branch coverage is not separately measurable in this toolchain (`spec.md:248`).

**No `.codex/state/` writes:** `ls .codex/state` → "No such file or directory" after the full workspace run.

## Work delivered in this phase

`[P7-T1]` and `[P7-T2]` created two new test files, the maximum the plan permits. The split follows the plan's authorized fallback: the config.toml-derived cases live in the integration file, the payload-shaped cases in the transport file.

| File | Lines | Tests | Content |
|---|---|---|---|
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` | 269 | 27 | `[P7-T1]`(a)(b)(c)(d) and `[P7-T2]`(a)(b2) |
| `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | 198 | 6 | `[P7-T2]`(b1)(c) |

Both are within the 500-line cap, and both live under `tests/` mirroring the production tree, per `.claude/rules/general-unit-test.md`.

Every process-level case feeds stdin through `System.Diagnostics.ProcessStartInfo` with `RedirectStandardInput` and bakes poisoned `CLAUDE_TOOL_INPUT` / `CLAUDE_SESSION_ID` into each invocation, so **no temporary file is created anywhere** (Hard Constraint 5) and the poisoned-environment requirement of AC5 is satisfied per invocation rather than by a single dedicated case.

`[P7-T3]` ran the targeted suite and captured the pass-after artifact at `FEATURE/evidence/regression-testing/pass-after.2026-07-25T20-46.md`: 194 tests, 0 failures across `tests/scripts/codex-hooks`, including the 32-row pass-after counterpart to the fail-before table (all 32 exit 0 with empty stdout) and the 59-invocation config-driven integration matrix.

### Determinism notes

- The two checkpoint `Edit` deny cases use an `old_string` sentinel that cannot occur in the on-disk checkpoint, so they resolve identically whether the checkpoint is present, absent, or arbitrary. No test depends on mutable on-disk state.
- The preimplementation-gate deny cases are unit-level with an injected `-CheckpointRaw '{}'`, so they never read the repository's live `artifacts/orchestration/orchestrator-state.json`.
- No test uses `Start-Sleep`, a retry, or a wall-clock wait.

## Batch accounting (convention C2)

0 production units, 2 new test files. Within the plan's explicit limit of at most 2 new test files for this phase.
