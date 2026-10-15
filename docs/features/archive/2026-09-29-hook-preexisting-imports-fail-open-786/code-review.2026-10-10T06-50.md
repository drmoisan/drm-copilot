# Code Review: Hook pre-existing imports fail open (#786, bundled #792)

---

**Review Date:** 2026-10-10
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its suffix matches issue 786.
**Base Branch:** `origin/epic/enforcement-hook-precision-integration` (merge base `86e457a003be0c60b65e01156e4cccd6495dfd1a`)
**Head Branch:** `origin/bug/hook-preexisting-imports-fail-open-exec-786` at `76559b6df` (local branch name `bug/hook-preexisting-imports-fail-open-resume-786`)
**Review Type:** Initial review

---

## Executive Summary

The branch closes the fail-open path for module imports and dot-sources in every registered PreToolUse and SubagentStop hook on the Claude and Codex surfaces. It adds one import-free helper, `hook-dependency-guard.ps1` (115 lines, four byte-identical copies), and applies a uniform pattern in 57 production hook files: a bootstrap `try` around the helper dot-source, one single-statement `try` per dependency edge, a dependency-failure check as the first statement of the decision function, and an `exit 2` tail check after the dot-source early return. The #690 per-hook guard copies are migrated, the #850 merge-gate guard is folded into the helper, the #787/#840 handlers (H7, H8) are converted after their proofs showed exit-1 behaviour, and the #565 handlers (H1 to H6) remain as named exemptions with fail-closed proofs. AST-based structural and stdout guards discover hooks from the registrations. Evidence reviewed: the full branch diff (267 files), regenerated PR context, the feature evidence tree, reviewer-run mirror, line-count, Python-invocation, temp-file, and #690-remnant checks, and the coverage XML.

**What changed:**
Production: 2 new helper copies, 35 modified `.claude/hooks` files, 20 modified `.codex/hooks` files, their 57 bundle mirrors, and 2 pack manifests. Tests: 21 new test files, 3 new test-support files, and 11 modified pre-existing test files (variable-reset updates plus the seven recorded H7/H8 assertion changes).

**Top 3 risks:**
1. Four changed Codex hooks are below 85% line coverage in the standard full Pester run, and five regress against baseline; the cause is attributed to profiler attribution but is not identified.
2. AC-6 is not met for the named-exemption edges (H1, H4, H5, H6), which acquire the payload before denying; the spec text and the 2026-10-09 decision are inconsistent on this point.
3. The H8 conversion changes the block reason token for an `OrchestratorStateEpicWaveBarrier.psm1` load failure from `EPIC_WAVE_BARRIER_UNEVALUABLE:` to `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` and extends the block from the epic leg to every orchestrator artifact type; the updated test no longer asserts a leading token.

**PR readiness recommendation:** **Needs Revision** — the fail-closed behaviour is implemented and verified, but the uniform PowerShell coverage gate fails on four Codex files and AC-6 needs an operator decision.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.codex/hooks/enforce-epic-child-worktree-binding.ps1`, `.codex/hooks/enforce-epic-planning-only.ps1`, `.codex/hooks/hook-dependency-guard.ps1`, `.codex/hooks/validate-bash.ps1` | whole file; helper lines 103-111; `validate-bash.ps1:305-306`; `enforce-orchestration-preimplementation-gate.ps1:467-468` | Line coverage in the full run is 74.70, 82.25, 57.89, and 80.25 (floor 85). Five Codex files regress against baseline (95.62 -> 74.70, 95.71 -> 82.25, 100.00 -> 80.25, 100.00 -> 86.55, 98.68 -> 98.09). Changed non-exempt lines are reported uncovered in the helper decision body and two hook tails. | Root-cause the attribution loss before changing the measurement route. Candidates to bisect: (a) the `-Global` pre-loads added by RS-10 in `b83b121f9`, which leave module instances in the session; (b) the Claude and Codex helper copies defining identically named functions in one session; (c) remaining `[scriptblock]::Create` mocks. If no test-side cause is found, request an operator decision on a per-surface coverage pass and record it in `deviations.md`. Re-record per-file results in `evidence/qa-gates/`. | Line coverage >= 85% and no regression are uniform gates (`.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`); AC-24 depends on them. | `evidence/qa-gates/final-pester-coverage.md`, `coverage-comparison.md`, `p10-coverage-pass2.md`; reviewer parse of `artifacts/pester/powershell-coverage.xml` reproduced 74.70 / 82.25 / 80.25 in a second full run (MCP route, 06:29). |
| Major | `.claude/hooks/enforce-feature-folder-order.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-parallel-drift-gate.ps1`, `enforce-parallel-cohort-barrier.ps1` | entry points (for example `enforce-epic-wave-barrier.ps1:360-366`) | For the exempt `feature-folder-resolution.ps1` edge, the entry point reads the payload (`& $ReadPayload`) before the scoped handler denies. AC-6 requires that the entry point call no HookPayload function on a dependency failure. The deny itself is correct and fail-closed. | Operator decision: amend AC-6 to exclude named-exemption edges (consistent with keeping the handlers unchanged; for H1 the BF-1 rule requires the payload to classify the path), or require a pre-payload check for H4 to H6 only. | Spec text and delivered behaviour diverge; an unchecked AC prevents closure. | `evidence/other/handler-conversions.md` (AC-6 GAP line), `evidence/other/ac-status.md`; `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1:27-28` excludes listed exemption edges from B1. |
| Minor | `.claude/hooks/validate-orchestrator-output.ps1`, `validate-orchestrator-output-resolution.ps1` | guard block lines 51-60; former `:294-297` handler | H8 conversion: a Layer 2 module failure now blocks every orchestrator artifact type (not only the epic leg) with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` instead of `EPIC_WAVE_BARRIER_UNEVALUABLE:`. The updated assertion at `validate-orchestrator-output.WaveBarrier.Tests.ps1:246` checks `ExitCode 2` and the module name but no leading token. | Add an assertion that `$result.Reason` starts with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:`, and state the token change and the broadened scope in the PR body (the PR-BODY-NOTE mentions exit 2 but not the token change). | C6 keeps leading tokens stable; consumers of the reason text should be told of the change. | `git diff ...HEAD -- .claude/hooks/validate-orchestrator-output-resolution.ps1`; `evidence/other/handler-conversions.md`. |
| Minor | `.claude/hooks/validate-orchestrator-output.ps1` | lines 51 and 59 | `OrchestratorState.psm1` is imported twice: once without `-Global` and once with `-Global` (RS-10). | Keep one guarded import (the `-Global` form) and remove the other. | Duplicate `-Force` imports reload the module and add ambiguity about which instance tests mock. | `git diff` of the file. |
| Minor | `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` | H8 row, lines 461-473; proof record | At proof time the H8 row never reached the epic leg: the result was a `TARGET_WORKTREE_AMBIGUOUS` block computed from live worktree checkpoints on the host. The CONVERT decision remains valid because the Change Log admits a cited code path and both files had no `exit 2`. | Record in `fail-closed-proof.H8.md` that the decision rests on the cited exit-1 tail, not on the runtime row. Post-conversion the row is host-independent. | Proof evidence should state which leg it exercised. | `evidence/other/fail-closed-proof.H8.md` runner output. |
| Minor | `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/coverage-comparison.md` | `.claude/hooks/validate-orchestrator-output-resolution.ps1` row | A modified file is treated as new (`NO-REGRESSION: n/a`) because the baseline run had no row for it. Post value is 98.94%. | Record its baseline value or state why it is absent. | The no-regression rule applies to modified files. | `agg.py` over the baseline and final evidence lists it as without a baseline row. |
| Nit | `.claude/hooks/enforce-epic-wave-barrier.ps1`, `enforce-parallel-drift-gate.ps1`, `enforce-parallel-cohort-barrier.ps1` | lines 53-64, 78-86, 67-77 | After the #690 migration the scoped variable is initialized immediately before its `try`, so `if (-not $script:<Name>ResolutionImportFailure)` is always true and the comment "an earlier recorded failure is kept" no longer applies. | Simplify the catch to a plain assignment and update the comment, if the exemption terms allow editing the handler text. | Dead conditional and stale comment. | File inspection. |
| Nit | `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` | lines 453, 468 | `finally` resets `$script:OrchestratorOutputResolverImportFailure` and `$script:OrchestratorOutputWaveBarrierImportFailure`, which no longer exist in production. | Remove the stale resets. | Dead cleanup. | File inspection. |
| Info | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | whole file | Exactly 500 lines (and mirror); no headroom under the cap. | Extract a sibling before any further addition. | 500-line cap. | `wc -l`. |
| Info | `artifacts/pester/powershell-coverage.xml` | n/a | The on-disk artifact was last written by the MCP `run_poshqc_test` route (06:29), which uses the installed extension's coverage settings and contains no entry for either helper copy. | Re-run the in-repo `Invoke-PoshQCTest` after remediation so the artifact matches the evidence. | The policy-audit coverage source should match the recorded run. | Reviewer grep: 0 matches for `hook-dependency-guard` in the XML. |
| Info | `.claude/hooks/*.ps1`, `.codex/hooks/*.ps1` | four hooks | Plan check [P9-T7] (c) counts `python` in reason-prefix literals (`PYTHON_LARGE_PATH_REQUIRED:`, `Python unit test purity hook:`, `check-python-test-purity:`). No added line invokes Python; the no-Python guard passes. | Revise the plan check to match invocation forms only. | Plan hygiene; AC-26 is met. | Reviewer grep of added hook lines for `python|poetry|py -m`: 12 matches, all string literals. |

No other Blocker findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The helper is import-free, writes to no stream, initializes its list only when absent (so `enforce-completion-consistency.ps1` dot-sourcing `enforce-checkpoint-monotonic.ps1` keeps earlier records), and reads state through `Get-Variable` so it is strict-mode safe.
- Each guard is one line with one statement in the `try` (FR-2.6), and every guarded `Import-Module` carries `-ErrorAction Stop`; the structural test asserts both, with here-string fixtures that prove each check can fail (F1 to F8).
- The merge-gate ordering hazard is removed: `enforce-epic-merge-gate-resolution.ps1` no longer defines `Get-EpicMergeGateImportFailureDecision` or calls a function from `-authorization.ps1`.
- `validate-orchestrator-output.ps1` moves `$ErrorActionPreference = 'Stop'` after the guards, so a failed guard does not become script-terminating before the tail check (FR-3.3).
- #850 assessment: the #850 `WorktreeItemResolution.psm1` guard recorded into the #690 variable `$script:EpicMergeGateResolutionImportFailure` and denied through the #690 decision function; it is now one helper-guarded line next to the `WorktreeRunResolution.psm1` line, and both failures are recorded instead of the first only. Treating #850 as having no separate handler is correct; the `ItemResolution` suite was updated to arrange the failure through `Add-HookDependencyFailure`.

#### API and safety notes

- `Get-HookDependencyFailureDecision` returns an ordered dictionary for PreToolUse and a `pscustomobject` for SubagentStop. SubagentStop decision functions therefore return a different shape on dependency failure than on their normal paths (`@{ Ok; Message }`). The tails handle the dependency case before calling the decision function, so process behaviour is correct; in-process callers must handle both shapes.
- Seven runtime pre-loads use `-Global` (RS-10). In a hook's own `pwsh -File` process this is equivalent to a script-level import; it was introduced for the shared test session.

#### Error handling and logging

- Fail-closed proofs reviewed:
  - H1 (`enforce-feature-folder-order.ps1`): the resolver functions are called only at lines 220-221, after the plan-path gate (returns allow for non-plan paths using hook-local `Test-IsFeaturePlanPath` and `$script:FeaturePlanLeafPattern`) and after the failure check (denies). BF-1 was decided correctly: a non-plan write is never subject to a resolver-dependent check, so its allow is not an allow on import failure. Sound.
  - H2 (modes sibling, both surfaces): every early return in `Get-EpicOrchestrationReadinessFailure` and `Get-ParallelOrchestrationReadinessFailure` is a non-empty failure, and the `feature-folder-resolution-import` return precedes every resolver call (`Select-FeatureFolderTarget`); the target-folder function returns nothing on failure. The single-feature path calls no resolver function. Sound.
  - H3 (`enforce-prd-feature-before-planner-helpers.ps1`): `Resolve-PrdFeatureWorkMode` returns `$null` on failure and the parent denies on `-not $workMode`. Sound.
  - H4, H5, H6: the scoped check is the second statement of the decision function, after the helper check and before payload parsing, and denies unconditionally. Sound (fail-closed for all requests, including ones that would not need the resolver).
  - H7, H8: both ended in `Write-Error` then `exit 1`, which does not block a SubagentStop; conversion to the helper (exit 2 with stderr reason) is correct under the Change Log conversion rule.
- `exemption-decisions.md`, `handler-conversions.md`, and the exemption list in `HookImportFailureExemptions.Helpers.ps1` agree: H1 to H6 exempt with justifications; H7 and H8 absent from the list and their variables removed.

---

## Test Quality Audit

The full Pester run passes (9495 passed, 0 failed). Behaviour suites drive every registered hook per direct edge with the C3 mocks; structural and #792 suites use here-string fixtures and an injectable reader; proofs are in a dedicated FailClosed suite per surface. No test writes files.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` — B1 asserts deny, leading token, dependency name, and `Should -Invoke Read-ClaudeHookRawPayload -Times 0 -Exactly`; exempt edges are excluded and covered by the FailClosed suite.
- `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` — S1 to S8 over repository and mirror roots; F1 to F8 prove each failure condition is reported.
- `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1` — N1 to N8; 25 passed (`p9-stdout-guard.md`).
- `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` — H1 to H8 proofs with control rows.
- `evidence/qa-gates/final-pester-coverage.md` — per-file coverage; four files below floor.
- `evidence/other/handler-conversions.md` — seven assertion changes, each with a reason.

### Quality assessment prompts

- **Determinism:** import failures are simulated only through mocks; checkpoint readers are mocked. Test order affects coverage attribution in the full run, which indicates residual session state between containers.
- **Isolation:** one row per hook and edge; B2 removes helper functions from the session and the next container re-dot-sources them.
- **Speed:** 57 ms per test on average.
- **Diagnostics:** `-Because` carries the decision or stderr text.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens added. |
| No unsafe subprocess or command construction | ✅ PASS | No new process invocation; no Python (reviewer grep of added hook lines). |
| Input validation at boundaries | ✅ PASS | Dependency check precedes payload parsing for every non-exempt edge. |
| Error handling remains explicit | ✅ PASS | Single-statement `try`; failures recorded with the first exception line; blocking result names the dependency. |
| Configuration / path handling is safe | ✅ PASS | Paths built with `Join-Path $PSScriptRoot`; registrations in `.claude/settings.json` and `.codex/config.toml` unchanged. |
| Fail-closed on dependency failure | ⚠️ PARTIAL | Every dependency failure denies or blocks (verified by tests and proofs). For exempt edges the deny follows payload acquisition (AC-6 gap). |

---

## Research Log

No external research was required. Vendor hook semantics (exit 2 blocks; other non-zero exits do not) were taken from `research/research.2026-10-08T14-00.md` as cited in the spec.

---

## Verdict

The implementation achieves its primary goal: a dependency load failure in any registered PreToolUse or SubagentStop hook on either surface now produces a deny or an exit-2 block that names the dependency, the six retained handlers are shown to be fail-closed, the two fail-open handlers are converted, and the structural and stdout guards will detect regressions. Code quality is good; the remaining code findings are Minor or Nit.

The branch is not ready for merge. The uniform PowerShell coverage gate fails on four Codex files in the standard full run, and AC-6 remains unmet for the named-exemption edges pending an operator decision. Both are listed in `remediation-inputs.2026-10-10T06-50.md`.
