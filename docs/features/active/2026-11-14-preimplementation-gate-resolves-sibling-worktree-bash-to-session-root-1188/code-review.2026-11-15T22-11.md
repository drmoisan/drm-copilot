# Code Review: Preimplementation gate resolves sibling-worktree Bash to the session root (#1188), re-audit at head 861fecb75

---

**Review Date:** 2026-11-15
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188`
**Feature Folder Selection Rule:** named by the caller; matches the issue number in `issue.md` and the branch `bug/gate-sibling-worktree-pytest-target`
**Base Branch:** `main` (merge base `38f87bc2c4bab54be8121ee546f9eb0dc92272ee`)
**Head Branch:** `bug/gate-sibling-worktree-pytest-target` at `861fecb753d0befcf2907e094196d9e2a404c4d1` (PR #1191)
**Review Type:** Re-audit with owner directive OD-2 applied (finding R3 recorded as accepted deviation DEV-R3)

---

## Executive Summary

The branch changes 111 files. The only commit after the previously reviewed head `06f085b30` is `861fecb75`, which adds the previous review set (four files inside the feature folder). `git diff --quiet 06f085b30 861fecb75 -- . ':!docs'` exits 0, and `origin/main` still equals the merge base, so the code under review is unchanged and no base drift exists.

Evidence reviewed: the PR context summary (generated 2026-11-15 22:04:45 UTC at the reviewed head), the full diff, blob-hash identity of the four classify copies (`f15f48929`) and the four operands copies (`802f0449f`), the previous reviewer's full Pester gate on the identical tree, the CI merged PowerShell report and the Python coverage shards of run `43764064186` (downloaded and combined by the reviewer), and a rerun of the reverted-mutant probe at the head.

CI run `43764064186` on `06f085b30` completed with all 29 jobs successful, including PowerShell QC shard 5, which was pending at the previous audit. CI run `43766284142` on `861fecb75` succeeded with a documentation-only change scope.

R3 is recorded as DEV-R3, an owner-accepted non-blocking deviation (OD-2). No blocking finding remains.

**What changed since the previous review:**
Only review records in the feature folder (`policy-audit`, `code-review`, `feature-audit`, `remediation-inputs` at `2026-11-15T21-47`).

**Top 3 risks:**
1. DEV-R3: the backtick arm of the unclosed-substitution filter and the member-level `npm`/`npx` checks could regress without a failing row; a regression would newly classify and deny mention forms such as `` echo `npm --version` lint `` (fail-closed). Rows tracked in a follow-up issue.
2. Wrapper payloads (`sh -c "npm run lint"`, `pwsh -Command "npm run lint"`) are unclassified by stage 1 on `main` and on this branch; pre-existing and tracked in the same follow-up issue.
3. Isolated subagents receive the change only after merge, because hooks run from the default branch (spec rollout section).

**PR readiness recommendation:** **Go**, on the green CI of PR #1191.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major (accepted deviation DEV-R3, non-blocking) | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1` (rows for `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` and its three copies) | `$script:ClassifyFunctionRows` and `$script:ClassifyGateRows`; guards at lines 91-95 and 125-127 of the classify sibling | Previous finding R3: reverted mutants N2 (drop the backtick arm of the filter), N5 (npm pattern against the whole run text), N6 and N7 (drop the member `npm` and `npx` word checks) fail no row. | Add the four function rows with `Indexes = @()` and the two Negative gate rows named in `remediation-inputs.2026-11-15T21-47.md` in the coordinator-filed follow-up issue. | Owner directive OD-2 accepts this as non-blocking. The reviewer re-verified at the head that behavior is correct for all six probed forms and that a regression fails closed (benign mention forms would be denied, no command would be allowed that is denied today). | Reviewer rerun of `artifacts/scratch-issue-1188/review-r5-probe2.ps1` at the head: head returns no index for the four commands and leaves the two mention forms unclassified; each mutant changes at least one |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `Test-ImplementationCommand` stage 1 | Wrapper payloads are unclassified: `sh -c "npm run lint"`, `bash -c "npx jest"`, and `pwsh -Command "npm run lint"` return false. | No change in this item; tracked in the coordinator-filed follow-up issue with DEV-R3. | Pre-existing on `main`; belongs to the stage-1 design of #1160. | Earlier review probe; no stage-1 pattern changed since |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` | Form 1 | Mention forms whose top-level text carries the npm pattern are classified, for example `echo $(true) npm --prefix $(pwd) run lint`; they deny as unresolvable. | No change. | Within the spec's Form 1 definition; fail-closed direction. | Earlier reviewer probe |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` | run-start condition (lines 69-70) | Mutant M4 (accept a run start without an opener in the gap) fails no row. | No change required in this item. | Cycle 1 code; the probed forms show no behavior difference that a realistic command reaches. | Earlier reviewer mutant probe |

No covered file is at or above 700 logical lines (largest production file: Codex epic-scope at 491; largest test file: `legacy-codex-hook-contracts.Tests.ps1` at 517). `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The operands sibling resolves the target from every literal selector and absolute operand and fails closed on non-literal operands before any checkpoint read or listing call.
- The classify sibling evaluates each top-level member of a joined word, so a leading assignment does not hide an npm or npx command, while members inside an unclosed substitution are skipped.
- Four-copy byte identity of both siblings holds at the head; the parity suites pin it.
- Fail-before evidence exists for every remediation cycle.

#### API and safety notes

- The siblings are internal to the gates and their tests; no public surface changed.
- No I/O, no process start, no evaluation of command text in the siblings.

#### Error handling and logging

- A failed dot-source of either sibling denies naming the file (I1 and I2 on both surfaces).

---

## Test Quality Audit

Positive, Negative, and Control rows cover every specified form on both surfaces; coverage of both siblings is 100% per copy. The discrimination gap for four cycle 3 guards is the accepted deviation DEV-R3.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1` and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Cases.ps1`.
- `evidence/regression-testing/r2-fail-before.2026-11-15T21-09.md`, `evidence/qa-gates/cycle3-pester-gate.2026-11-15T21-27.md`, `evidence/qa-gates/cycle3-powershell-static.2026-11-15T21-27.md`.
- CI run `43764064186` artifacts `poshqc-test-results`, `python-coverage-shard-1`, `python-coverage-shard-2`.

### Quality assessment prompts

- **Determinism:** in-memory rows; no clock, file, or process access.
- **Isolation:** one row per form.
- **Speed:** full parallel gate 659.64 s wall clock.
- **Diagnostics:** `-Because` text names the command and expected indexes.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; leak scan 0 failures. |
| No unsafe subprocess or command construction | ✅ PASS | The siblings start no process and evaluate no text. |
| Input validation at boundaries | ✅ PASS | Every probed non-literal operand of a classified command fails closed. |
| Error handling remains explicit | ✅ PASS | No catch-all; deny reasons carry the reason code and detail. |
| Configuration / path handling is safe | ✅ PASS | Forward-slash, case-insensitive comparison against registered worktrees. |
| No hook invokes Python | ✅ PASS | No Python call added to a hook. |

---

## Research Log

No external research was required. Head behavior was confirmed by a real-process probe of the item worktree's hook code.

---

## Verdict

The code is unchanged since the previous review, CI is green on both heads, and coverage, mirrors, and evidence rules are met. R3 is recorded as the owner-accepted non-blocking deviation DEV-R3. The branch is ready to merge.
