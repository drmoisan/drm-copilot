# Code Review: Preimplementation gate resolves sibling-worktree Bash to the session root (#1188), re-audit after remediation cycle 3

---

**Review Date:** 2026-11-15
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188`
**Feature Folder Selection Rule:** named by the caller; matches the issue number in `issue.md` and the branch `bug/gate-sibling-worktree-pytest-target`
**Base Branch:** `main` (merge base `38f87bc2c4bab54be8121ee546f9eb0dc92272ee`)
**Head Branch:** `bug/gate-sibling-worktree-pytest-target` at `06f085b30b352deb006126a4053cb2f39e26a37c` (PR #1191)
**Review Type:** Re-audit after remediation cycle 3 (light; findings R2 and E1)

---

## Executive Summary

The branch changes 107 files. Since the previous review it adds commit `97398574b` (R2 fix in the four classify copies, four Positive function and gate rows, one operands V3 row, the E1 correction line, and cycle 3 evidence) and merge commit `06f085b30`. The merge is neutral: the byte diff `97398574b..06f085b30` equals `1df569f65..38f87bc2c` (47 files, main's `test-execution-policy` and feature-document changes only).

Evidence reviewed: the PR context summary (generated 2026-11-15 21:30:46 UTC at the reviewed head), the full diff, the cycle 3 evidence, the reviewer's full Pester gate at the head (27323 run, 0 failed), blob-hash identity of the four classify and four operands copies, reviewer real-process probes of `Get-OrchestrationGateSupplementalPatternIndex`, `Test-ImplementationCommand`, and `Invoke-OrchestrationPreimplementationGateDecision` over 18 further command forms, and an eight-mutant discrimination probe of the cycle 3 code plus a rerun of the earlier seven mutants.

R2 is resolved: the four named forms and further variants (backtick and braced substitutions, two leading assignments, a nested substitution in the assignment) classify and deny `TARGET_WORKTREE_NOT_DERIVABLE`. The fix is monotonic: the first member of a run always lies outside every substitution and its tail is the whole run text, so every command classified before cycle 3 is still classified. E1 is resolved with one appended line. One blocking finding remains (R3): four guards that cycle 3 added are not pinned by any row.

**What changed:**
`.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` and its three copies (+24/-9 each; now 133 lines); `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1` (+9); `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Cases.ps1` (+1); four evidence files; the light-cycle checkboxes in `remediation-inputs.2026-11-15T20-57.md`.

**Top 3 risks:**
1. The unclosed-substitution filter's backtick arm and the per-member `npm`/`npx` word checks can regress without a failing row (R3); a regression would newly classify mention forms such as `` echo `npm --version` lint `` and deny them.
2. Wrapper payloads (`sh -c "npm run lint"`, `pwsh -Command "npm run lint"`) are unclassified by stage 1 on `main` and on this branch; pre-existing and tracked by the coordinator outside #1188 (Info row).
3. Isolated subagents receive the change only after merge, because hooks run from the default branch (spec rollout section).

**PR readiness recommendation:** **No-Go** until R3 is fixed (test rows only).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1` (rows for `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` and its three copies) | `$script:ClassifyFunctionRows` and `$script:ClassifyGateRows`; guards at lines 91-95 and 125-127 of the classify sibling | R3: four guards added in cycle 3 fail no row when reverted. N2 drops the backtick arm of the unclosed-substitution filter; N5 matches the npm pattern against the whole run text instead of the member tail; N6 and N7 drop the member `npm` and `npx` word checks. At the head the supplement leaves `` echo `npm --version` lint ``, `echo $(echo npm --version) lint`, `FOO=$(echo npx jest) ls`, and `FOO=$(echo npm x lint) npm --version` without an index; under the matching mutant each returns index 2 or 3, and the first two become classified by the gate. | Add function rows with `Indexes = @()` for the four commands, and Negative gate rows (`Expected = $false`) for `` echo `npm --version` lint `` and `echo $(echo npm --version) lint`; run them on both surfaces; record a probe showing N2, N5, N6, and N7 each fail at least one row. No production change. | The spec allows no newly classified command beyond the two supplement forms; these guards enforce that for the cycle 3 member loop, and a test that passes under the wrong implementation gives no protection. Coverage reads 100% because every guard line executes. | Reviewer reverted-mutant probe (`artifacts/scratch-issue-1188/review-r5-mutants.ps1`, `review-r5-probe2.ps1`): N1, N3, N4, N8 fail rows; N2, N5, N6, N7 fail none; control 0 failures |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `Test-ImplementationCommand` stage 1 | Wrapper payloads are unclassified: `sh -c "npm run lint"`, `bash -c "npx jest"`, and `pwsh -Command "npm run lint"` return false. | No change in this item; the coordinator tracks payload classification for the non-git patterns as a follow-up outside #1188. | Pre-existing on `main`; belongs to the stage-1 design of #1160 (recorded orchestrator decision). | Previous review probe; no stage-1 pattern changed in cycle 3 |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` | Form 1 | Mention forms whose top-level text carries the npm pattern are classified, for example `echo $(true) npm --prefix $(pwd) run lint`; they deny as unresolvable. | No change. | Within the spec's Form 1 definition; fail-closed direction. | Reviewer probe at the head |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` | run-start condition (line 69-70) | Mutant M4 (accept a run start without an opener in the gap) still fails no row, as in the previous review. | No change required in this item. | Cycle 1 code, unchanged in cycle 3; the probed forms show no behavior difference that a realistic command reaches. | Reviewer rerun of the earlier mutant probe |

No covered file is at or above 700 logical lines (largest production file: Codex epic-scope at 491; largest test file: `legacy-codex-hook-contracts.Tests.ps1` at 517). `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The member loop records each member's offset while building the joined text, so `Tail` is a substring of the already-built text and needs no second scan.
- Members inside an unclosed substitution are skipped, which keeps `echo $(npm --version) lint` unclassified; this was not prescribed by the finding and prevents a new false classification.
- The change is monotonic with respect to the cycle 1 behavior (the first member is never skipped and its tail is the full text).
- The four copies share blob `f15f4892`; the header and help text describe the new rule.
- Fail-before evidence (`r2-fail-before.2026-11-15T21-09.md`) records exactly the new rows failing per surface before the fix.

#### API and safety notes

- `Get-OrchestrationGateJoinedWordText` gains a `Member` property on each run object; `Text` and `First` are unchanged, and the function remains internal to the sibling and its tests.
- No I/O, no process start, no evaluation of command text.

#### Error handling and logging

- Unchanged: a failed dot-source of the classify sibling denies naming the file (I2 on both surfaces).

---

## Test Quality Audit

The four Positive function and gate rows and the V3 operands row discriminate the R2 fix (mutants N4 and N8 fail them). The `$(` arm of the new filter is pinned by the existing row `echo $(npm --version) lint` (N1 and N3 fail it). The backtick arm of the filter and the member-level word and tail checks have no discriminating row (R3).

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1` (cycle 3 rows).
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Cases.ps1` (leading-assignment V3 row).
- `evidence/regression-testing/r2-fail-before.2026-11-15T21-09.md`, `evidence/qa-gates/cycle3-pester-gate.2026-11-15T21-27.md`, `evidence/qa-gates/cycle3-powershell-static.2026-11-15T21-27.md`, `evidence/qa-gates/self-review.2026-11-15T20-38.md` (appended line).

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
| No unsafe subprocess or command construction | ✅ PASS | The sibling starts no process and evaluates no text. |
| Input validation at boundaries | ✅ PASS | Every probed non-literal operand of a classified command fails closed, including the leading-assignment forms. |
| Error handling remains explicit | ✅ PASS | No catch-all; deny reasons carry the reason code and detail. |
| Configuration / path handling is safe | ✅ PASS | Unchanged in cycle 3. |
| No hook invokes Python | ✅ PASS | No Python call added to a hook. |

---

## Research Log

No external research was required. Shell semantics were confirmed by real-process probes of the item worktree's hook code.

---

## Verdict

R2 and E1 are resolved, coverage and mirrors are complete, the merge is neutral, and the toolchain and CI are clean (one PowerShell shard pending at audit time). The branch is not ready to merge until R3 adds the discriminating Negative rows for the cycle 3 guards; the fix touches test data only.
