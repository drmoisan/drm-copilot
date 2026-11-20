# Code Review: Release-commit allowance leg of the preimplementation gates (#1201), cycle 1 re-audit

---

**Review Date:** 2026-11-18
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201`
**Feature Folder Selection Rule:** named by the caller; the folder's `issue.md` and `spec.md` carry issue #1201.
**Base Branch:** `main` (merge base `1b9e5746eaa5e32366de695e3f511dbc28700b08`, equal to `origin/main` after a fetch; `git merge-tree` reports no conflict)
**Head Branch:** `bug/release-commit-allowance-gate` at `4140c7bb54c3126bb5a35da0cfcb0f7b4bf53b6a`
**Review Type:** Re-audit after remediation cycle 1 (concurrent with CI run 44229371033 on PR #1202)

---

## Executive Summary

The full branch diff (52 paths outside `docs/`) was reviewed, with focus on the cycle-1 delta `89d0e5861..4140c7bb5`. The cycle-0 production change (allow-side release-commit allowance leg in both preimplementation gates, four byte-identical copies of two new hook files, push-down exclusion, manifests, documentation) is unchanged since the cycle-0 PASS review; `git diff 89d0e5861 4140c7bb5` lists no path outside `docs/` and `tests/`.

**What changed in cycle 1:**
- `tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1` (new on the branch): one `Reset-EpicStateProbeModuleBinding` call in the outer `BeforeAll`, after the helpers are dot-sourced and before the first `Register-EpicStateBaselineMock`. No line naming the probe changed.
- 18 pre-existing suites under `tests/scripts/claude-hooks`: one `AfterAll { Reset-EpicStateProbeModuleBinding }` each (file level, or in the Describe that runs the hook), with a dot-source of `EpicStateIsolation.Baseline.Helpers.ps1` inside the `AfterAll` for the two suites that did not already load it. A reviewer filter of every added line in the 18 files against the teardown vocabulary (`AfterAll`, the reset call, the helper dot-source, comments, braces, blank lines) left zero lines, and `git diff --numstat` shows zero deleted lines.

**Root-cause assessment:** sound. `validate-orchestrator-output.ps1` line 71 runs `Import-Module ... WorktreeRunResolution.psm1 -Force`, and two suites force-import that module directly; no other production `-Force` import of it exists (reviewer grep). `EpicScopeResolution.psm1` binds `Resolve-WorktreeEpicTarget` to the run-module instance current at its own load, so a later forced import leaves it calling a removed, unmocked instance, which returns `NoTarget` before `Get-EpicScopeCheckpointText` is reached. The reviewer reproduced the mechanism in one `pwsh` process: binding `fresh` after load, `stale` after the forced import, `scope-absent` after the reset, `fresh` after re-import, and still `fresh` after a second reset (the reset removes nothing when the binding is current). `poshqc / PowerShell hook suites (Linux)` passed in CI at head `4140c7bb5`.

**Top 3 risks:**
1. No static guard covers module-table replacement (the PoshQC leak scan has no module kind), so a future suite that loads `validate-orchestrator-output.ps1` in-process without a teardown reintroduces the class. The victim's `BeforeAll` reset keeps this suite order-independent regardless.
2. AC-7's parenthetical "no diff to any pre-existing test file" is now literally false; the judgment is recorded in the feature audit.
3. Merge remains blocked by the external npm advisory (Finding CI-2) until the `main`-side scoped exception lands and the branch is synced.

**PR readiness recommendation:** **No-Go until CI-2 clears** — no code finding blocks; the only blocker is the external audit advisory.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | CI: `NPM Audit Gate / npm audit (.)` and `(extensions/drm-copilot)` | run 44229371033 | Finding CI-2 persists at head `4140c7bb5`: GHSA-fc5q-39xc-vjpf (picomatch `<= 4.0.7`, no patched version) fails both audit jobs; `main` is affected the same way. | Land the scoped exception on `main` (coordinator-owned), merge `main` into the branch, and re-run CI. Do not change the audit gate on this branch. | External advisory with no in-branch remedy that keeps the gate intact; recorded as `external_dependency` in `remediation-inputs.2026-11-18T03-46.md`. | Job logs (`picomatch vulnerable to ReDoS through single-branch repeated extglobs`); advisory record `updated_at 2026-11-17T15:56:44Z`, `first_patched_version` none; `npm view picomatch version` 4.0.7. |
| Minor | `tests/scripts/claude-hooks/*` (18 suites) | file-level or Describe-level `AfterAll` | The leaker teardowns contradict the literal text of AC-7 ("no diff to any pre-existing test file"). The edits are additive teardown only and are required by the test-independence rule and by the cycle-1 inputs ("fix ... in the suite that leaks state as well"). | Record the deviation in the PR description; no code change. | Spec wording predates the discovered leak; repository test-isolation policy governs the fix. | `git diff --numstat 1b9e5746e HEAD -- tests` (0 deletions); reviewer added-line filter (0 non-teardown lines). |
| Info | `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` | `Reset-EpicStateProbeModuleBinding`, line 100 | The helper (unchanged, present on the merge base) removes only an `EpicScopeResolution` whose path is the fixture root's and whose bound run module is not a current instance, so a teardown in a suite that leaves no stale binding is a no-op. | None. | Safe to call unconditionally. | Reviewer single-process probe, `after-second-reset: fresh`. |
| Info | PoshQC leak scan | `scripts/powershell/PoshQC/PoshQC.LeakScan.psm1` | The leak scan records `env`, `global`, `location`, and `process` kinds only, so module-table replacement leaks are invisible to it. | Consider a follow-up issue for a module-table leak kind; not required for this item. | Explains why cycle 0 passed the leak scan. | Diagnosis section 5. |
| Info | CI: `poshqc / PowerShell QC shard 5` | first attempt | Failed in `Install PoshQC tooling` (`Failed to install Pester 6.2.0: Package 'Pester' failed to download`) before any test ran; a new attempt was pending at review time. | Confirm the new attempt passes at the S9 join. | Package-download failure outside the branch. | Job 134550520540 steps: install `failure`, test `skipped`. |
| Info | `artifacts/pester/powershell-coverage.xml` | n/a | The executor's report (03-14 UTC) predated head commit `4140c7bb5` (03-17 UTC), so the reviewer re-ran the PowerShell gate once; figures are identical. | None. | Coverage freshness is keyed to the newest commit touching `*.ps1`. | `evidence/qa-gates/review-pester.2026-11-18T03-46.md`. |

No covered file reaches 700 logical lines, so there is no file-size Warning row. The largest changed covered file is `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` at 539 logical lines (536 on the merge base), which is in the 500-line guidance tier and produces no finding.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Cycle 0: one entry, `Path(".claude/release-commit-allowance.json")`, appended to `EXCLUDED_RELATIVE_PATHS`. Unchanged in cycle 1.

#### Typing and API notes

- No new public Python API surface; no new Python module or test (AC-32).

#### Error handling and logging

- No new control flow.

### TypeScript implementation audit

#### What changed well

- Cycle 0: one entry appended to `EXCLUDED_RELATIVE_PATHS` with a three-test Jest contract. Unchanged in cycle 1.

#### Type safety and maintainability

- No suppression; ESLint, Prettier, and TSC clean in cycle 0.

#### Error handling and logging

- No new behavior.

### PowerShell implementation audit

#### What changed well

- The victim fix is placed correctly: after the gate, context, and helper dot-sources (which load the modules) and before mock registration, so `Register-EpicStateBaselineMock` re-imports a fresh `EpicScopeResolution` bound to the current run module, and the gate's by-name calls resolve to it.
- The leaker list was extended from 15 to 18 by a pre-push sweep that added the `&`-invocation route (`subagentstop-uncaught-error`, both `hook-dependency-failure` Claude suites). The reviewer's independent grep over the Linux job's folders found no further suite that runs the validator in-process or force-imports `WorktreeRunResolution.psm1` without a teardown or a six-module removal.
- The probe is unchanged; it failed on Linux before the fix (run 44214588875) and passed after it (run 44229371033).

#### API and safety notes

- No production, bundle, or helper file changed in cycle 1; the four-copy hook hashes are unchanged (self-review, parity suite green).
- Format 0 drift, PSScriptAnalyzer 0 findings, leak scan 0 failures over the 19 cycle-1 files.

#### Error handling and logging

- The reset uses `Remove-Module -ErrorAction Stop`; a failure surfaces as an `AfterAll` block failure rather than being swallowed.

---

## Test Quality Audit

The cycle-1 changes are fixture hygiene, not new tests. The regression test for CI-1 is the existing probe row, which discriminates: it failed under the stale binding on Linux and passes with the fix. A local fail-before run of that ordering was not attempted because it needs a single-process ordered run, which the owner's parallel-only rule excludes; the reviewer instead proved the mechanism with a diagnostic single-process module probe that runs no test suite.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1` — victim reset; probe rows pass on both surfaces (reviewer JUnit parse).
- The 18 leaker suites — teardown-only additions.
- `evidence/other/ci1-diagnosis.2026-11-18T02-06.md`, `ci1-diagnosis.2026-11-18T02-52.md` — mechanism and leaker list, cross-checked against the hook source and a reviewer grep.
- `evidence/regression-testing/ci1-folder-proof.2026-11-18T03-02.md` — Linux job file set, 15526 tests, 0 failures (parallel, so it does not reproduce the shared-process order).
- `evidence/qa-gates/final-qc-pester.2026-11-18T03-14.md`, `coverage-comparison.2026-11-18T03-14.md`, `final-qc-static-powershell.2026-11-18T03-02.md`, `review-pester.2026-11-18T03-46.md`.

### Quality assessment prompts

- **Determinism:** the fix removes cross-file state; no clock or randomness added.
- **Isolation:** each suite now restores the module table it disturbs.
- **Speed:** no measurable change (755.55 s reviewer run).
- **Diagnostics:** teardown comments name the cause.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Inspection of the diff; leak scan 0 failures. |
| No unsafe subprocess or command construction | ✅ PASS | Cycle 1 adds no process call. |
| Input validation at boundaries | ✅ PASS | Unchanged since cycle 0. |
| Error handling remains explicit | ✅ PASS | No catch added. |
| Configuration / path handling is safe | ⚠️ PARTIAL | Unchanged since cycle 0: the `-C` root comparison is case-insensitive by spec AD-5 (Minor finding of the cycle-0 review, deferred to the epic #1018 adaptation). |

---

## Research Log

No external research was required beyond the GitHub advisory record for GHSA-fc5q-39xc-vjpf and the npm registry version of picomatch.

---

## Verdict

The cycle-1 fix is correct, minimal, and applied on both the victim and leaker sides; the probe is intact and the Linux job is green at the reviewed head. The branch code carries no blocking finding. Merge is held only by Finding CI-2, an external advisory that this branch must not work around; it clears once the `main`-side exception lands and the branch is synced.
