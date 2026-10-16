# Remediation Inputs — Cycle 4 review (issue #935)

Review-Verdict: HALT_NON_REMEDIABLE

Timestamp: 2026-10-16T16-02
Head reviewed: `ddadd0835e302f3e45cd60808356e7cb5872ca3e` (PR #956)
Review artifacts:
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/policy-audit.2026-10-16T16-02.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/code-review.2026-10-16T16-02.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/feature-audit.2026-10-16T16-02.md`
Prior inputs: `remediation-inputs.2026-10-16T11-25.md` (COV-1 autonomous; DOC-1, EV-1, CR-R4, CR-R5). Cycle 3 fixed CR-R4, CR-R5 and EV-1; COV-1 ended `human_decision_required (NO-WRITE-SET-CANDIDATE-RESTORES)` and the decision is recorded in `evidence/other/cov1-decision.2026-10-16T15-56.md`.

## Finding COV-1: PR CI line coverage remains below the baseline (AC-24)

Severity: Blocking
Remediability: external_dependency
Remediability-Evidence: The recorded decision selects Pester profiler mode (option 2), delivered by issue #953 / PR #959 outside this item, and directs that #935 must not change coverage configuration (AC-21 keeps `scripts/` out of the diff). PR #959 is not merged: `origin/main` at `d72ec6a10` contains no #953 or #959 commit. Cycle 3 showed that no Write Set change restores the attribution at the merged head (terminal T-U4-NO-LONGER; FX-1, FX-2 and FX-23 each left 127).

Observed:
- PR CI run 38922641167 (pull_request event, head `3ab81c26f`, code identical to HEAD), artifact `poshqc-test-results`, root LINE counter: covered 16531, missed 1906, 89.66%. Runs 38915587310 and 38914467202 report the same counters.
- Baseline 90.42% (`adb9aa5f0`, run 38730332356). Main at the merge-base `5bdf22d0f`: 90.45% (run 38885440106).
- Main at `5d2d9a972` (run 38911869997), same 18437-line population as the PR run: 90.23% (16636 covered). The PR run is 105 covered lines lower, in unchanged production modules:
  - `.claude/lib/orchestrator-state/`: CompletionChecks -25, EpicWaveBarrier -11, IssueAdoption -20, ModelReceipts -21, Receipts -21, RoutingContract -5, Unconditional -1.
  - `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`: -1.
- `.claude/lib/worktree-resolution/WorktreeResolution.psm1`: 112/144 in both the PR run and main at `5d2d9a972`; 142/144 on main at `3fc83c8c3` (run 38907131337). Main lost this attribution without any #935 change.

Expected:
- The Pester coverage file from `poshqc / PowerShell QC` on the final PR head shows root line coverage not lower than the 90.42% baseline and not below 85% (AC-24).
- No production file is excluded, and no coverage configuration or `scripts/` or `config/` file is changed by #935 (AC-21).

Settlement steps (owner: orchestrator, after the external dependency clears):
1. Wait for PR #959 to merge into `main`.
2. Merge `origin/main` into `bug/hook-test-isolation-737-remainder-935` (no force-push) and push.
3. Read the PR CI coverage file on the new head. Compare the root LINE counter with the 90.42% baseline and with main CI at the same population, and diff every per-file counter. Do not decide AC-24 from `WorktreeResolution.psm1` = 142 alone (see EV-2).
4. If the root figure meets the baseline, record AC-24 PASS. Otherwise apply the decision record's option-1 fallback: record AC-24 as accepted with the per-file evidence, and report the attribution loss as a follow-up for filing.

## Non-blocking related findings (fix in the same item)

- DOC-1 (Low, carried): the PR #956 description covers cycle 1 only and calls COV-1 a denominator mismatch. Update it with cycles 2 and 3, the decision record path, the dependency on PR #959 and the final AC-24 figure. Owner: orchestrator (pr-author re-run).
- EV-2 (Low): `evidence/other/cov1-decision.2026-10-16T15-56.md` settles AC-24 by re-measuring `WorktreeResolution.psm1` against TARGET 142. Main CI at `5d2d9a972` already reads 112 for that file, and the PR's same-population loss is in other modules. Record the root-level and full per-file comparison of settlement step 3 in the AC-24 evidence.
- SYNC-1 (Info): the branch is behind `origin/main` (`d72ec6a10`). Settlement step 2 resolves it.

## Pending CI (non-blocking)

- PC-1: final-head confirmation of AC-1..AC-8, AC-10..AC-12, AC-14..AC-19 and AC-23 on run 38928004778 (queued at review time) or on the head after settlement step 2. Each was satisfied in run 38922641167. Owner: orchestrator at S9.
