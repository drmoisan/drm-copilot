# Code Review: Epic Child CI Opt-Out (#1233)

**Review Date:** 2026-11-24
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1233-epic-child-ci-opt-out/`
**Feature Folder Selection Rule:** named by the caller and matching issue #1233 and the branch name
**Base Branch:** `main` (merge base `c030729de4703f961ff27489d4890919f6e0587e`)
**Head Branch:** `feature/epic-child-ci-opt-out-1233` (head `502309bcd2de1b549fec6c154c3eee33dd9e402e`; no pull request yet)
**Review Type:** Re-audit after remediation cycle 1

---

## Executive Summary

This re-audit covers the full branch diff `c030729de..502309bcd` and, in detail, the cycle-1 changes `0fc83af8b..502309bcd`: commit `282b8f50c` (ordinal reads in the PowerShell validator and the merge-gate helper, four case-variant fixtures, new merge-gate rows, a new completion-helper suite, the Codex header blank line), `a1608a009` (QA records and the S7/U7 check-off), the main-sync merge `71fe3e9a5` (#1228), and `fa8963062` (ledger renumber `0014` to `0015`).

Specific checks performed:

- F1 closure: `Get-OrchestratorStateCompletionLocalQcGateError` reads `local_qc_gate`, `conclusion`, `review_mode`, `remediation_loop`, `review_outcomes`, and both `head_sha` values through `Get-CheckpointObjectOrdinalMember`, and the presence check uses the new private `Get-MissingOrdinalGateKey`; `Get-MissingGateKey` and its `ci_gate` and `pr_gate` callers are unchanged. The fail-before record shows the four new `OCC-CORPUS-*` rows failing on the unchanged module.
- Minor closure: `Test-EpicMergeGateChildCiOptOut`, `Get-EpicMergeGateChildCiLivePullRequest`, and `Get-EpicMergeGateChildLocalQcResult` read every #1233 key through `Get-EpicMergeGateChildCiOrdinalProperty` (`-ceq`); stage L2 reads the reviewed head through `Get-EpicMergeGateChildLocalQcReviewedHead`. Stages 1 to 6 still use the pre-existing accessor. The fail-before record lists 12 Claude and 15 Codex new rows failing on the unchanged helper.
- Nits: `$ciGate = (` restored; the Codex gate header has its blank line, and its bundle copy matches.
- Mirrors at head: helper blob `551012393` and completion-helper blob `2573b573a` in all four locations; every changed bundle copy equals its source.
- Main sync: per-path numstat of the branch against its old base (`23458fade..a1608a009`) equals that against the new base (`c030729de..71fe3e9a5`); the nine paths touched on both sides carry identical branch hunks.
- Renumber: README row, entry heading, `reduction: 0015`, the rule source, the generated rule, its bundle copy, and spec D7 name `0015`; no other branch file names `0014` for this entry. The chain and ledger suites pass on the committed tree.
- Cross-runtime probe: nine checkpoint variants through the Python, TypeScript, and PowerShell validators. Python and PowerShell agree on case-variant keys and on JSON `null` fields; TypeScript returns no error for `null` `evidence_path` and `verified_at` (F2). The three runtimes also differ on three non-ASCII whitespace characters (Minor, pre-existing).

**Top 3 risks:**
1. Validator parity: the TypeScript validator, which backs the MCP `validate_orchestration_artifacts` route, accepts an opted-out checkpoint whose required local-QC fields are `null` (F2, blocking).
2. `child_ci` is self-declared by the item checkpoint; the live-base check, the concurrent review, and the evidence file bound it (disclosed in the rule and ledger `0015`).
3. Isolated subagents run the default branch's hooks, so the gate and completion behavior is proven by mocked Pester rows until the branch merges; the pull request's own `CI` run is still to come.

**PR readiness recommendation:** **No-Go** until F2 is remediated.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `extensions/drm-copilot/src/lib/validate/orchestrator-state-child-ci.ts` (through `missingObjectKeys` in `extensions/drm-copilot/src/lib/validate/orchestrator-state-completion.ts`) | `validateCompletionLocalQcGate`, call to `missingObjectKeys`; helper line `item === undefined` | F2. `missingObjectKeys` treats a key as missing only when its value is `undefined` or a blank string, so a JSON `null` value counts as present. For `opt-out-accepted.json` with `evidence_path` and `verified_at` set to `null`, TypeScript returns no error, while Python (`item is None`) and PowerShell (`$null -eq $item`) return `local_qc_gate missing required fields: evidence_path, verified_at.`. With both `head_sha` values `null`, Python and PowerShell emit the missing-field string and the head-binding string; TypeScript emits only the head-binding string. | Treat `null` as missing in `missingObjectKeys` (`item === undefined \|\| item === null`), which also aligns the pre-existing `ci_gate` and `pr_gate` checks with Python (a reviewer probe shows TypeScript accepting a `ci_gate` with `null` `head_sha` and `verified_at` that Python rejects). Add a corpus fixture with `null` `evidence_path` and `verified_at` and one with `null` head values, whose `expected_errors` are the Python output, and a `ci_gate` null row in the TypeScript completion tests. | Spec S7 and U7 require each validator to emit each listed string for its failing condition; the corpus is the parity contract, and it has no null-valued field. The TypeScript validator is the MCP route, so it would pass a completion the Python validator and the completion hooks refuse. | Reviewer probe: esbuild bundle of the branch module, `validate_completion_gate_evidence`, and `Get-OrchestratorStateCompletionCiGateError` on nine variants; outputs differ only in the rows named here and in the Minor row below. |
| Minor | `scripts/dev_tools/validate_orchestrator_state.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-completion.ts`, `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` | `_missing_object_keys` (`str.strip`), `missingObjectKeys` (`String.prototype.trim`), `Get-MissingOrdinalGateKey` and `Get-MissingGateKey` (`IsNullOrWhiteSpace`) | The three blank-string tests use different whitespace sets. A field holding only U+0085 is missing in Python and PowerShell, present in TypeScript; U+001C is missing only in Python; U+FEFF is missing only in TypeScript. The same helpers serve the pre-existing `ci_gate` and `pr_gate` checks. | Optional, and cheap to fold into the F2 cycle: name one whitespace set (for example the JSON whitespace characters plus the Unicode `White_Space` property) and apply it in the three helpers, with one corpus fixture per differing character; otherwise record the difference as a known limitation. | A checkpoint writer does not produce these characters in practice, and the behavior predates #1233, so it does not weaken the reduction's bounds. | Reviewer probe variants `nel`, `fs1c`, `bom`. |
| Info | `.dev/engineering/process-reductions/0015-epic-child-ci-opt-out.md` | `## Summary`, `Merge commit: pending (PR #1233)` | The README format names the pull request number in this line; `#1233` is the issue number, and no pull request exists yet. Commits before the renumber carry `(reduction: 0014)` in their subjects, which now names #1228's entry; the renumber commit body records this. | Back-fill the line with the merge commit at the records stage as the README states; no change to commit history. | The checker requires only the line's format; history is not rewritten. | README line 31; `git log c030729de..HEAD`. |
| Info | `artifacts/pester/powershell-coverage.xml` | whole file | The canonical report is the executor's post-renumber targeted run (18 suites), which does not run the corpus suite; the module reads 0/153 in it. | None. Per-file figures come from the R1 selection evidence and the reviewer's targeted run. | Owner-directed targeted runs after the final QC gate. | `post-sync-renumber-check.2026-11-24T17-38.md`; reviewer parse. |

No Blocker finding. No covered file is at or above 700 lines (largest: `extensions/drm-copilot/jest.config.cjs`, 689 logical lines; child-CI helper 629; completion-checks module 592), so no file-size Warning row applies, and `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- `Get-MissingOrdinalGateKey` has the contract of `Get-MissingGateKey` and leaves the pre-#1233 function and its callers untouched, so no earlier ledger region moves.
- `Get-EpicMergeGateChildCiOrdinalProperty` returns `, $property.Value`, so a one-element `review_outcomes` array is not unrolled; `Get-EpicMergeGateChildLocalQcReviewedHead` checks `[System.Array]` and a non-empty list before indexing.
- The `gh` JSON reads (`headRefOid`, `baseRefName`) use the same accessor; their spelling is fixed by `gh`, so behavior on real output is unchanged.
- The completion helpers already compared names with `-ccontains`; the new suite pins that without editing the helper.

#### API and safety notes

- New functions have `[CmdletBinding()]`, `[OutputType()]`, comment-based help, and approved verbs; none is exported.
- The `#1233` header paragraph states that the opt-out reads its keys by ordinal name.

#### Error handling and logging

- Unchanged from the initial review: lookup failures return `$null` and deny; the whole-body `try/catch` converts unexpected errors into a deny.

### Python implementation audit

- No Python production change in this cycle. The probe confirms Python treats `None` and whitespace-only strings (by `str.strip`) as missing.

### TypeScript implementation audit

- No TypeScript production change in this cycle. `validateCompletionLocalQcGate` delegates presence to `missingObjectKeys`, whose `undefined`-only absence test is the cause of F2. Property reads are case-sensitive, so the four case-variant fixtures pass without change, as the fail-before companion runs recorded.

---

## Test Quality Audit

The cycle adds four case-variant-key fixtures (each asserted by all three corpus suites), 12 Claude and 15 Codex merge-gate rows (predicate, fallback, L1, L2, and accessor rows), and `enforce-completion-helpers.OrdinalKeys.Tests.ps1`. Each set has a fail-before record with `ExpectedExitCode: 1` naming exactly the new rows, which shows the rows discriminate. Case-variant rows are built from literal JSON or a single ordinal `-creplace`, avoiding the case-insensitive ordered-dictionary overrides.

Gap: no fixture holds a JSON `null` field value or a non-ASCII whitespace value, so the corpus does not detect F2 or the Minor row.

### Reviewed test and QA artifacts

- `evidence/regression-testing/fail-before-f1.2026-11-24T15-25.md`
- `evidence/regression-testing/fail-before-merge-gate-ordinal.2026-11-24T15-56.md`
- `evidence/qa-gates/r1-final-pester-selection.2026-11-24T17-08.md` (3589 tests, 0 failures)
- `evidence/qa-gates/r1-final-pytest-selection.2026-11-24T17-22.md` (78 passed)
- `evidence/qa-gates/r1-final-jest-selection.2026-11-24T17-22.md` (27 passed)
- `evidence/qa-gates/r1-coverage-comparison.2026-11-24T17-23.md`
- `evidence/qa-gates/r1-contract-check.2026-11-24T17-22.md`
- `evidence/qa-gates/post-sync-renumber-check.2026-11-24T17-38.md`
- `evidence/qa-gates/self-review.2026-11-24T17-25.md`

---

## Documentation and Contract Audit

- The rule change is made through `scripts/harness-generation/sources/rules/orchestrator-state.md`; the generated rule and bundle copy name `0015`, and `-Check` reports no drift after the renumber.
- Ledger `0015` gains a revert block for the Claude gate header reflow made by the post-sync line-cap fix; the chain suites pass on the committed tree.
- `.github/workflows/ci.yml`, both `enforce-epic-merge-gate-review.ps1` copies, `.claude/hooks/enforce-epic-merge-gate.ps1` (in this cycle), `.claude/lib/docs`, and the agent sources are unchanged.

---

## Verdict

**REMEDIATION_REQUIRED.** F1 and the three cycle-0 observations are closed. One blocking finding (F2, Major, autonomous, contained) remains; the Minor whitespace-set row is non-blocking and can be folded into the same cycle.
