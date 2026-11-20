# Code Review — harden-small-path-completion-gate (Issue #207)

- Timestamp: 2026-06-19T19-02
- Base branch: main
- Merge-base SHA: db3d528ea9c8fb87e9ec21a4d96e4c263d347651
- Branch HEAD: 2b923604b083e0df20b24939694064dc87d184ae

## Executive Summary

The change adds a PreToolUse PowerShell hook (`.claude/hooks/enforce-completion-consistency.ps1`) that blocks writes to `artifacts/orchestration/orchestrator-state.json` when a checkpoint asserts completion without verifiable evidence (issue-num, feature-folder, and a success `ci_gate` with `head_sha`). It is registered in `.claude/settings.json` under `PreToolUse` for `Write|Edit`, and is covered by a 16-test Pester suite.

Code quality is good. The implementation mirrors the established sibling hook (`enforce-checkpoint-monotonic.ps1`) in structure, output contract, dot-source guard, and mockable JSON seam. Functions are small, single-purpose, and follow PowerShell advanced-function conventions. Formatting and PSScriptAnalyzer are clean; all tests pass. Separation of concerns is correctly applied: the pure decision function is isolated from environment/stdout I/O at the entrypoint.

No blocking findings. One non-blocking observation concerns the coverage denominator (the new production file is not enumerated in `pester.runsettings.psd1`); this is a pre-existing repository configuration pattern shared by the sibling completion-gate hooks and is recorded in the policy audit as a PARTIAL with a non-blocking remediation recommendation. Two minor (Info-level) observations on edge-case behavior are noted below; both are intentional and documented, requiring no change.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/hooks/enforce-completion-consistency.ps1` | L177 `Get-MissingCompletionEvidence` | `ci_gate` type check uses `-isnot [System.Management.Automation.PSCustomObject]`. A `ci_gate` supplied as a JSON array or scalar would be reported as a missing object, which is the correct conservative behavior, but the type test is tighter than a duck-typed property check. | No change required. The strict type check is intentional and fail-closed; it correctly rejects non-object `ci_gate` values. | Fail-closed on malformed evidence is the desired security posture for a completion gate. | Code L173-189; tests assert block when ci_gate absent (L88-98). |
| Info | `.claude/hooks/enforce-completion-consistency.ps1` | L229-241 | When `content` is absent (Edit-style call) or content is not valid JSON, the hook allows the write and defers to downstream tools. This means an Edit that injects a completion assertion into the checkpoint is not blocked by this hook. | No change required for this issue; the limitation is explicitly documented in the `.DESCRIPTION` block and matches `enforce-checkpoint-monotonic.ps1`. Consider, in a future iteration, a complementary gate that resolves the merged file content for Edit calls. | Edit supplies only a partial patch; validating it reliably requires the full target file, which the hook does not read. The documented deferral is a reasonable scope boundary consistent with the sibling hook. | Code L227-241; `.DESCRIPTION` L30-34; test L46-51. |
| Info | `.claude/hooks/enforce-completion-consistency.ps1` | L259 | Dot-source guard `if ($MyInvocation.InvocationName -eq '.') { return }` enables test dot-sourcing without executing the entrypoint. | No change required. | Matches the established repository hook pattern; verified working by the entrypoint tests that invoke the script as a file. | Code L258-261; tests L152-178. |
| Info | `.claude/settings.json` | L119-122 | New hook registered after `enforce-checkpoint-monotonic.ps1` in the same `Write|Edit` PreToolUse group. Both completion-gate hooks now run on every Write/Edit. | No change required. | Additive registration; JSON remains valid; hook short-circuits to allow for non-checkpoint paths so per-call overhead is bounded. | `git diff` settings.json; `json.load` valid. |
| Info | `.claude/hooks/enforce-completion-consistency.ps1` | coverage config | New production file is not in `pester.runsettings.psd1` `CodeCoverage.Path`, so its lines are excluded from the measured coverage denominator. | Non-blocking: add the new hook (and ideally sibling completion-gate hooks) to `CodeCoverage.Path`. Tracked in policy audit Coverage section and remediation inputs. | Per general-unit-test no-exclusion policy, production files should be in the denominator; the new logic is nonetheless fully exercised by 16 passing tests, so risk is low. | `pester.runsettings.psd1` L23-32 (unchanged on branch). |

## Positive Observations

- Pure decision logic (`Invoke-CompletionConsistencyDecision`, `Test-CompletionAsserted`, `Get-MissingCompletionEvidence`) is fully decoupled from I/O, enabling direct unit testing without environment or filesystem setup.
- The block reason string names each specific missing evidence field, satisfying the issue requirement for a "specific reason" and aiding remediation.
- The `variables.issue-num` / `variables.feature-folder` fallbacks are handled and tested, matching the checkpoint shape described in the issue.
- Backward compatibility is preserved: any checkpoint that does not assert completion is unconditionally allowed, and this is directly tested.
- Test suite covers positive, negative, edge, and error categories, including the mockable JSON-parse seam and the script entrypoint.

## Verdict

No blocking findings. The change is ready to merge from a code-quality standpoint. The coverage-denominator gap is recorded as a non-blocking remediation recommendation.
