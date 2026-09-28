# Fail-Before Capture — New Suites Against the Unmodified Hooks (issue #516)

Timestamp: 2026-08-24T15-51
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a96d0b5541701860e` and `scan_folders` = `["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]`
EXIT_CODE: 38
ExpectedExitCode: 1

Note on the expectation field: the schema in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` allows a single integer expectation per artifact, and the plan fixes that value at `1`. The gate condition the plan actually states is "a non-zero exit code with at least one failed case in each new suite". PoshQC surfaces the Pester failed-test count as the process exit code, so the observed non-zero value is `38` — the total number of failing cases — rather than the generic `1`. The declared expectation is recorded as the plan specifies; the observed value is recorded verbatim and is non-zero, satisfying the stated acceptance condition. This is an `[expect-fail]` task: a failing run is the correct outcome here and only here.

## Run Result

```json
{"ok":false,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a96d0b5541701860e","summary":"Command exited with code 38."}
```

Counts read from `artifacts/pester/pester-junit.xml`:

```text
TOTAL tests=1600 failures=38 errors=0
enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1  tests=33 failures=19
codex-preimplementation-gate-absolute-paths.Tests.ps1                  tests=35 failures=19
```

All 38 repo-wide failures lie inside the two new suites, 19 in each. Every other suite in both scanned folders reported zero failures, including all six run-only files. Both new suites were discovered with zero discovery errors.

## Failed Case Names — Claude suite (19)

Checkpoint exemption, forward-slash absolute spelling (7):

```text
allows the forward-slash absolute spelling of artifacts/orchestration/orchestrator-state.json
allows the forward-slash absolute spelling of artifacts/orchestration/parallel-planner-state.json
allows the forward-slash absolute spelling of artifacts/orchestration/parallel-orchestrator-state.json
allows the forward-slash absolute spelling of artifacts/orchestration/epic-planner-state.json
allows the forward-slash absolute spelling of artifacts/orchestration/epic-orchestrator-state.json
allows the forward-slash absolute spelling of artifacts/orchestration/powershell-orchestrator-state.json
allows the forward-slash absolute spelling of artifacts/orchestration/csharp-orchestrator-state.json
```

Checkpoint exemption, backslash absolute spelling (7):

```text
allows the backslash absolute spelling of artifacts/orchestration/orchestrator-state.json
allows the backslash absolute spelling of artifacts/orchestration/parallel-planner-state.json
allows the backslash absolute spelling of artifacts/orchestration/parallel-orchestrator-state.json
allows the backslash absolute spelling of artifacts/orchestration/epic-planner-state.json
allows the backslash absolute spelling of artifacts/orchestration/epic-orchestrator-state.json
allows the backslash absolute spelling of artifacts/orchestration/powershell-orchestrator-state.json
allows the backslash absolute spelling of artifacts/orchestration/csharp-orchestrator-state.json
```

Remaining five:

```text
allows the POSIX-shaped absolute spelling of artifacts/orchestration/orchestrator-state.json
allows the leading dot-slash relative spelling of artifacts/orchestration/orchestrator-state.json
allows the forward-slash absolute spelling of a feature-folder .json artifact
allows the backslash absolute spelling of a feature-folder .json artifact
allows an absolute checkpoint path whose literal differs only in letter case
```

## Failed Case Names — Codex suite (19)

The Codex suite failed on exactly the same 19 case names, against the dot-sourced `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`. Both copies carry the identical defect, so both produce the identical failure set.

## Cases That Passed in the Same Run

Claude suite, 14 passing:

```text
allows the repo-relative spelling of <literal>            x7  (regression half)
allows the repo-relative spelling of a feature-folder .json artifact
denies an absolute path whose documentation prefix differs only in letter case
denies a synthetic absolute path ending in a production .ps1 file
denies a synthetic absolute path ending in a production .py file
denies a synthetic absolute path ending in a orchestration JSON whose name is not one of the seven literals
denies a synthetic absolute path ending in a checkpoint-named JSON with no preceding artifacts/orchestration segment
denies a synthetic absolute path ending in a checkpoint name reached only through a parent-directory hop
```

Codex suite, 16 passing: the same 14, plus the two `apply_patch` idempotence cases.

All five negative-half deny cases pass in each suite, which is the required demonstration that the gate is genuinely closed before the fix and is not being opened by the change.

## First Capture Discarded — a case that failed for the wrong reason

The first capture of this task exited 40, with 20 failures per suite. Inspection of the twentieth failure showed it was not a classification failure:

```text
ParameterBindingValidationException: Cannot bind argument to parameter 'FilePath' because it is an empty string.
```

Cause: the two case-sensitivity cases in each suite read their path from a variable assigned at Pester **discovery** time and referenced inside an `It` body, which executes in the **run** phase. A discovery-scope value is not visible there, so the path arrived empty and the case failed on parameter binding rather than on the decision under test. One of the two — the case-varied documentation **deny** case — is required to pass both before and after the fix, so a capture in which it fails is invalid regardless of the reason.

Remedy: both case-sensitivity cases in each suite were converted to `-ForEach` data-bound cases carrying `Description`, `Path`, and `Expected` keys, so the path arrives as case data. The count of discovered cases is unchanged at two per suite. This capture is the re-taken run after that correction. The correction is a test defect repair, not a change to the hook: no hook copy was modified at any point before or during this capture, which the [P0-T13] baseline hashes and the unchanged `git diff` confirm.

The principle applied is the plan's own: a case that reports the wrong result for the wrong reason proves nothing, so the capture was discarded and retaken rather than recorded.

## [P1-T13] Non-Vacuity Validation of This Capture

Timestamp: 2026-08-24T15-55
Command: comparison of the recorded per-case results above against the expected-failing set defined by [P1-T13], plus a `Select-String` structural audit of both suites' decision call sites
EXIT_CODE: 0

### The failing set is exactly the expected-failing set

[P1-T13] defines the expected-failing set as: every synthetic-absolute checkpoint allow case, every synthetic-absolute documentation allow case, the case-varied absolute checkpoint allow case, and the leading dot-slash relative checkpoint allow case.

| Expected-failing member | Count per suite | Observed failing | Match |
| --- | --- | --- | --- |
| Synthetic-absolute checkpoint allow (forward-slash) | 7 | 7 | yes |
| Synthetic-absolute checkpoint allow (backslash) | 7 | 7 | yes |
| Synthetic-absolute checkpoint allow (POSIX) | 1 | 1 | yes |
| Synthetic-absolute documentation allow | 2 | 2 | yes |
| Case-varied absolute checkpoint allow | 1 | 1 | yes |
| Leading dot-slash relative checkpoint allow | 1 | 1 | yes |
| **Total** | **19** | **19** | **yes** |

The observed failing set is neither larger nor smaller than the expected set, in either suite. No case outside the expected set failed.

### Every case required to pass did pass

- All 7 plain repo-relative checkpoint allow cases: **pass** in both suites.
- The repo-relative documentation allow case: **pass** in both suites.
- All 5 negative-half deny cases: **pass** in both suites.
- The case-varied documentation deny case: **pass** in both suites.
- Both Codex `apply_patch` idempotence cases: **pass**.

No case in the expected-failing set reported pass, so the capture is not vacuous and no case needs a missing not-ready argument added. The condition that would have required discarding and retaking this capture did not occur.

### Structural proof that no case can pass vacuously

The stronger guarantee is structural rather than per-case. A `Select-String` audit shows that neither suite contains any call to the decision function outside its checkpoint-supplying helpers:

```text
=== enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1
  Invoke-...Decision call sites : 1
  -CheckpointRaw arguments      : 1
=== codex-preimplementation-gate-absolute-paths.Tests.ps1
  Invoke-...Decision call sites : 2
  -CheckpointRaw arguments      : 2
```

The Claude suite has exactly one call site, inside `Get-GateDecisionFor`. The Codex suite has exactly two, inside `Get-GateDecisionFor` and `Get-GateDecisionForCommand`. Every one of them supplies `-CheckpointRaw (New-NotReadyCheckpointRaw)` unconditionally, and `New-NotReadyCheckpointRaw` returns a checkpoint whose `route_id` is the empty string and whose `lifecycle_ready` is `$false`.

Because every case in both suites reaches the decision function only through one of those helpers, there is no code path by which any case — allow or deny — can fall through to the on-disk `artifacts/orchestration/orchestrator-state.json`. This matters concretely here: a **ready** checkpoint does exist on disk in this worktree, so an omitted argument would have produced a silent vacuous pass. It cannot: the argument is supplied by construction, not by per-case discipline.

Verdict: **the [P1-T12] capture is valid and non-vacuous.** Proceeding to Phase 2 without retaking it.

Output Summary: Against the unmodified hook copies, both new suites fail as designed. EXIT_CODE 38 (non-zero, as required for this `[expect-fail]` task), with 19 failed cases in each new suite and zero failures anywhere else in the two scanned folders. Every failed case is a positive-half allow assertion that the unmodified hook answers `deny`: the 14 absolute checkpoint spellings, the POSIX spelling, the leading dot-slash spelling, the two absolute documentation spellings, and the case-varied absolute checkpoint spelling. All five negative-half deny cases and every plain repo-relative allow case pass in the same run, demonstrating the capture is non-vacuous and the gate is closed before the fix.
