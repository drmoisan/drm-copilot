# Code Review: SubagentStop Hooks Resolve the Item Worktree (#1105)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105`
**Base Branch:** `main` (merge base `bad886e304990d26af56d6bcabc9d543518492e9`, the merge base of `origin/main` and `HEAD` after a fetch)
**Head Branch:** `bug/hooks-read-main-checkout-1105` @ `8b1103ea0527187f121d5090db8819b1c573f49e`
**Review Type:** Re-review after remediation cycle 2, light path (prior review `code-review.2026-11-07T17-13.md` at `5a866484f`)

---

## Executive Summary

The branch makes six SubagentStop hooks resolve advertised artifact paths and coverage reports against the item worktree instead of the session root. The 17-13 review found F1 to F3 resolved and raised F4. Cycle 2 changed three `ParameterFilter` expressions in `tests/scripts/claude-hooks/validate-feature-review-coverage.TargetWorktree.Tests.ps1` (lines 216 to 218) from `$Root` to `$PesterBoundParameters['Root']`, re-checked spec criterion 8, and recorded one parallel gate run. No production file, bundle copy, manifest, or brief changed since the 17-13 review.

- **F4 resolved.** The reviewer ran the case against the original hook and a mutant hook that adds an unrooted read of the PR context summary, under plain `Invoke-Pester` and under a host with an outer `$Root`. The original passes in both hosts and the mutant fails in both. The pre-fix test file, run as a control, passes the mutant in the rooted host, so the probe host reproduces the original defect.
- **No regression.** PSScriptAnalyzer 0 findings and no formatter difference on the changed file; the coverage target, freshness, and helper suites pass 79 of 79 from the rooted host; the executor gate reports 15759 tests, 0 failed; the ten bundle hook copies remain byte-identical.

**What changed well:**
The fix is limited to the three expressions the remediation inputs named. `$PesterBoundParameters` holds only the arguments the hook actually passed, so the `-Times 0` filter now matches an unrooted call regardless of the variables the runner defines.

**Top 3 risks:**
1. F5 (Nit, outside the diff): a future suite that loads a bundle hook copy in-process without cleanup would break later suites in the same shard that register a module-scoped baseline mock. The failure is loud.
2. A prompt that names `base branch: main` before the item `branch:` label resolves to the session root. This matches the model-routing gate, which reads the same first signal.
3. Criterion 16 depends on CI on the PR head, which has not run yet.

**PR readiness recommendation:** **Ready.** No blocking finding.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Nit | `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` (not in the branch diff) | `Register-EpicStateBaselineMock`, line 55 | F5, carried from the 17-13 review. `Mock -ModuleName <name>` throws when a bundle copy and a repository copy of the same module are loaded. The branch's only in-process loader of a bundle hook copy (ThresholdsGuard) removes the bundle modules in its `AfterAll`. | No change on this branch. If the helper is revisited, have it name the duplicate module paths in its error. | The helper pre-dates the branch, and no suite on this head triggers the failure. Not blocking. | 17-13 reviewer reproduction; the cycle 2 parallel gate ran 8 shards with 0 failures. |

F4 from the 17-13 review is resolved and is not listed as an open finding. No covered file reaches the 700-line advisory tier (largest production file `validate-planner-output.ps1` at 473 logical lines; largest test file `validate-feature-review-coverage.Coverage.Tests.ps1` at 481; the cycle 2 file at 413), so no `Warning` row applies. `config/file-size-baseline.json` is not in the branch diff.

---

## Python

No Python file changed. The contract modules that pin mirrors, the manifest, and the brief passed in the cycle 1 gate, and none of their inputs changed in cycle 2.

## TypeScript

No TypeScript file changed.

## PowerShell

**Cycle 2 change:** three filter expressions in one test file. PSScriptAnalyzer with the repository settings reports 0 findings and `Invoke-Formatter` reports no difference (reviewer run). The executor's run over `.claude/hooks`, `tests/scripts/claude-hooks`, and `tests/scripts/codex-hooks` reports 0 analyzer findings and 0 files that formatting would change.

**Production code:** unchanged since the 17-13 review, which verified the helper, the six hooks, the `..` rejection, the single transcript read, and the session-root invariant by real-process probes. Coverage from the cycle 2 gate: 100.00% on the helper (92 of 92), 97.96% on the freshness sibling (48 of 49), and 98.33% to 100.00% on the eight edited hooks; repo-wide 94.06%.

## C#

No C# file changed.

---

## Test Quality

- **Discrimination (F4).** The fixed `-Times 0` assertion fails a mutant that adds an unrooted summary read, in both hosts. The two `-Times 1` assertions in lines 216 and 217 now also read the bound value, so a rooted read with a different root no longer depends on an outer `$Root` lookup.
- **Host dependence.** A search of every branch-added `ParameterFilter` line found none that reads `$Root`. The 17-13 review established that the other filters read parameters every production call site binds by name.
- **Seams.** Unchanged: in-memory transcript, worktree list, git, and file-content seams; no test reads or creates a file.

## Security and Correctness

Cycle 2 changes no production code and adds no process call.

---

**Review completed by:** feature-review agent
