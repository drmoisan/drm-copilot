# Pass-After Capture — Both New Suites (issue #516)

Timestamp: 2026-08-24T16-11
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a96d0b5541701860e` and `scan_folders` = `["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]`
EXIT_CODE: 0

This is the pass-after half of the fail-before capture recorded at `evidence/regression-testing/fail-before-new-suites.2026-08-23T23-25.md`. The command, the scan folders, and both suites are identical between the two runs; only the four hook copies changed in between.

## Run Result

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a96d0b5541701860e","summary":"Ran bundled PoshQC test against '...' with 2 selected scan folder(s)."}
```

```text
TOTAL tests=1600 failures=0 errors=0
  enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | tests=33 failures=0
  codex-preimplementation-gate-absolute-paths.Tests.ps1                 | tests=35 failures=0
```

## Fail-Before / Pass-After Comparison

| Run | Command | Exit code | Total tests | Failures | Claude suite failures | Codex suite failures |
| --- | --- | --- | --- | --- | --- | --- |
| Fail-before ([P1-T12]) | identical | 38 | 1600 | 38 | 19 | 19 |
| Pass-after ([P3-T6]) | identical | 0 | 1600 | 0 | 0 | 0 |

The total test count is identical at 1600 in both runs, so no case was added, removed, weakened, or renamed between them. All 38 failures cleared and no previously passing case regressed.

## Every Case in Both New Suites and Its Result

### `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` — 33 of 33 pass

```text
[pass] checkpoint exemption.allows the repo-relative spelling of artifacts/orchestration/orchestrator-state.json
[pass] checkpoint exemption.allows the forward-slash absolute spelling of artifacts/orchestration/orchestrator-state.json
[pass] checkpoint exemption.allows the backslash absolute spelling of artifacts/orchestration/orchestrator-state.json
[pass] checkpoint exemption.allows the repo-relative spelling of artifacts/orchestration/parallel-planner-state.json
[pass] checkpoint exemption.allows the forward-slash absolute spelling of artifacts/orchestration/parallel-planner-state.json
[pass] checkpoint exemption.allows the backslash absolute spelling of artifacts/orchestration/parallel-planner-state.json
[pass] checkpoint exemption.allows the repo-relative spelling of artifacts/orchestration/parallel-orchestrator-state.json
[pass] checkpoint exemption.allows the forward-slash absolute spelling of artifacts/orchestration/parallel-orchestrator-state.json
[pass] checkpoint exemption.allows the backslash absolute spelling of artifacts/orchestration/parallel-orchestrator-state.json
[pass] checkpoint exemption.allows the repo-relative spelling of artifacts/orchestration/epic-planner-state.json
[pass] checkpoint exemption.allows the forward-slash absolute spelling of artifacts/orchestration/epic-planner-state.json
[pass] checkpoint exemption.allows the backslash absolute spelling of artifacts/orchestration/epic-planner-state.json
[pass] checkpoint exemption.allows the repo-relative spelling of artifacts/orchestration/epic-orchestrator-state.json
[pass] checkpoint exemption.allows the forward-slash absolute spelling of artifacts/orchestration/epic-orchestrator-state.json
[pass] checkpoint exemption.allows the backslash absolute spelling of artifacts/orchestration/epic-orchestrator-state.json
[pass] checkpoint exemption.allows the repo-relative spelling of artifacts/orchestration/powershell-orchestrator-state.json
[pass] checkpoint exemption.allows the forward-slash absolute spelling of artifacts/orchestration/powershell-orchestrator-state.json
[pass] checkpoint exemption.allows the backslash absolute spelling of artifacts/orchestration/powershell-orchestrator-state.json
[pass] checkpoint exemption.allows the repo-relative spelling of artifacts/orchestration/csharp-orchestrator-state.json
[pass] checkpoint exemption.allows the forward-slash absolute spelling of artifacts/orchestration/csharp-orchestrator-state.json
[pass] checkpoint exemption.allows the backslash absolute spelling of artifacts/orchestration/csharp-orchestrator-state.json
[pass] checkpoint exemption.allows the POSIX-shaped absolute spelling of artifacts/orchestration/orchestrator-state.json
[pass] checkpoint exemption.allows the leading dot-slash relative spelling of artifacts/orchestration/orchestrator-state.json
[pass] documentation exemption.allows the repo-relative spelling of a feature-folder .json artifact
[pass] documentation exemption.allows the forward-slash absolute spelling of a feature-folder .json artifact
[pass] documentation exemption.allows the backslash absolute spelling of a feature-folder .json artifact
[pass] case handling.allows an absolute checkpoint path whose literal differs only in letter case
[pass] case handling.denies an absolute path whose documentation prefix differs only in letter case
[pass] negative half.denies a synthetic absolute path ending in a production .ps1 file
[pass] negative half.denies a synthetic absolute path ending in a production .py file
[pass] negative half.denies a synthetic absolute path ending in a orchestration JSON whose name is not one of the seven literals
[pass] negative half.denies a synthetic absolute path ending in a checkpoint-named JSON with no preceding artifacts/orchestration segment
[pass] negative half.denies a synthetic absolute path ending in a checkpoint name reached only through a parent-directory hop
```

### `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` — 35 of 35 pass

```text
[pass] checkpoint exemption.allows the repo-relative spelling of artifacts/orchestration/orchestrator-state.json
[pass] checkpoint exemption.allows the forward-slash absolute spelling of artifacts/orchestration/orchestrator-state.json
[pass] checkpoint exemption.allows the backslash absolute spelling of artifacts/orchestration/orchestrator-state.json
[pass] checkpoint exemption.allows the repo-relative spelling of artifacts/orchestration/parallel-planner-state.json
[pass] checkpoint exemption.allows the forward-slash absolute spelling of artifacts/orchestration/parallel-planner-state.json
[pass] checkpoint exemption.allows the backslash absolute spelling of artifacts/orchestration/parallel-planner-state.json
[pass] checkpoint exemption.allows the repo-relative spelling of artifacts/orchestration/parallel-orchestrator-state.json
[pass] checkpoint exemption.allows the forward-slash absolute spelling of artifacts/orchestration/parallel-orchestrator-state.json
[pass] checkpoint exemption.allows the backslash absolute spelling of artifacts/orchestration/parallel-orchestrator-state.json
[pass] checkpoint exemption.allows the repo-relative spelling of artifacts/orchestration/epic-planner-state.json
[pass] checkpoint exemption.allows the forward-slash absolute spelling of artifacts/orchestration/epic-planner-state.json
[pass] checkpoint exemption.allows the backslash absolute spelling of artifacts/orchestration/epic-planner-state.json
[pass] checkpoint exemption.allows the repo-relative spelling of artifacts/orchestration/epic-orchestrator-state.json
[pass] checkpoint exemption.allows the forward-slash absolute spelling of artifacts/orchestration/epic-orchestrator-state.json
[pass] checkpoint exemption.allows the backslash absolute spelling of artifacts/orchestration/epic-orchestrator-state.json
[pass] checkpoint exemption.allows the repo-relative spelling of artifacts/orchestration/powershell-orchestrator-state.json
[pass] checkpoint exemption.allows the forward-slash absolute spelling of artifacts/orchestration/powershell-orchestrator-state.json
[pass] checkpoint exemption.allows the backslash absolute spelling of artifacts/orchestration/powershell-orchestrator-state.json
[pass] checkpoint exemption.allows the repo-relative spelling of artifacts/orchestration/csharp-orchestrator-state.json
[pass] checkpoint exemption.allows the forward-slash absolute spelling of artifacts/orchestration/csharp-orchestrator-state.json
[pass] checkpoint exemption.allows the backslash absolute spelling of artifacts/orchestration/csharp-orchestrator-state.json
[pass] checkpoint exemption.allows the POSIX-shaped absolute spelling of artifacts/orchestration/orchestrator-state.json
[pass] checkpoint exemption.allows the leading dot-slash relative spelling of artifacts/orchestration/orchestrator-state.json
[pass] documentation exemption.allows the repo-relative spelling of a feature-folder .json artifact
[pass] documentation exemption.allows the forward-slash absolute spelling of a feature-folder .json artifact
[pass] documentation exemption.allows the backslash absolute spelling of a feature-folder .json artifact
[pass] case handling.allows an absolute checkpoint path whose literal differs only in letter case
[pass] case handling.denies an absolute path whose documentation prefix differs only in letter case
[pass] negative half.denies a synthetic absolute path ending in a production .ps1 file
[pass] negative half.denies a synthetic absolute path ending in a production .py file
[pass] negative half.denies a synthetic absolute path ending in a orchestration JSON whose name is not one of the seven literals
[pass] negative half.denies a synthetic absolute path ending in a checkpoint-named JSON with no preceding artifacts/orchestration segment
[pass] negative half.denies a synthetic absolute path ending in a checkpoint name reached only through a parent-directory hop
[pass] apply_patch idempotence.denies a repo-relative file-marker path for a production .ps1 file
[pass] apply_patch idempotence.allows a repo-relative file-marker path for a checkpoint literal
```

## The Negative Half Passed in Both Captures

The five negative-half deny cases in each suite, plus the case-varied documentation deny case and the two Codex `apply_patch` cases, reported **pass in the fail-before capture and pass in this capture**. The gate was closed before the change and remains closed after it. The change moved exactly the intended cases from deny to allow: the absolute and dot-slash spellings of the two exemptions the gate already granted in the plain repo-relative spelling.

Output Summary: EXIT_CODE 0 with 1600 tests passed, 0 failed, 0 errored across both scanned folders. Every one of the 68 cases in the two new suites reports pass: 33 of 33 in the Claude suite and 35 of 35 in the Codex suite. Against the identical command and the identical 1600-test population, the fail-before capture recorded 38 failures and this capture records 0, with every negative-half case passing in both, which is the required demonstration that the fix closed the reported gap without opening the gate.
