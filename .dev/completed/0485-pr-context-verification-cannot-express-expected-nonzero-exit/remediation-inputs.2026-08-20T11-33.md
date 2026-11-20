# Remediation Inputs: PR-Context ExpectedExitCode Evidence Key (#485)

- Cycle entry timestamp: 2026-08-20T11-33
- Authored by: feature-review agent (initial review pass)
- Source audit artifacts:
  - `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/policy-audit.2026-08-20T11-33.md`
  - `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/code-review.2026-08-20T11-33.md`
  - `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/feature-audit.2026-08-20T11-33.md`

## Finding Summary

- Blocking findings: **0**
- Major findings: **1** (manifesting as two PARTIAL acceptance criteria, AC10 and AC17)
- Minor findings: **2**
- Merge disposition: **Conditional Go.** No finding requires a code change on branch `bug/pr-context-verification-cannot-express-expected-nonzero-exit-485`. The Major finding's remediation is the promotion of a separate, pre-existing defect.

## Remediation-Required Findings

### F1 — AC10 and AC17 are PARTIAL: cross-runtime corpus parity blocked by the deferred duplicate-required-key precedence divergence

- Severity: **Major** (acceptance-criteria gap; not merge-blocking for this branch)
- AC references: spec.md:488 (AC10), spec.md:495 (AC17), both correctly left unchecked (`- [ ]`)
- Affected files (for the follow-up fix, not this branch):
  - `scripts/dev_tools/pr_context/verification_evidence.py` (parse loop assigns unconditionally; LAST occurrence of a duplicated required key wins)
  - `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` (parse loop guards with `!parsed.has(key)`; FIRST occurrence wins; comment at lines 125-126 incorrectly claims it mirrors the Python semantics)
- Observed behavior: the corpus comparison over 641 single-`EXIT_CODE` artifacts reports 5 content differences plus 1 presence difference between the two runtimes, all caused by pre-existing artifacts carrying a duplicated `Command:` or `Timestamp:` line. 165 further artifacts with two or more `EXIT_CODE:` lines were excluded and counted per AC10's exclusion clause. No difference touches an `EXIT_CODE` row, a `Normalized result` row, or the new `Expected EXIT_CODE` row.
- Expected behavior (per AC10/AC17 as written): zero cross-runtime differences over single-`EXIT_CODE` artifacts.
- Why this branch does not fix it: converging the precedence changes the reported result for real existing artifacts, which contradicts this fix's additive requirement (spec Invariant A). The spec explicitly defers the defect ("Out of scope" and "Post-fix monitoring or clean-up tasks") and records that its true scope is duplicate-REQUIRED-KEY precedence, wider than the duplicate-`EXIT_CODE` framing AC10 assumed.
- Required remediation action:
  1. Promote the duplicate-REQUIRED-KEY precedence divergence as its own bug via the potential-to-issue path (the unchecked "Next Step" item in `issue.md`). Scope statement: any duplicated required key (`Timestamp`, `Command`, `EXIT_CODE`), not only `EXIT_CODE`; include the six single-`EXIT_CODE` artifacts measured at execution time and the recommended convergence direction (first-wins, per research §3.3).
  2. In that follow-up, converge both parse loops, correct the misleading TypeScript comment, and re-run the cross-runtime corpus comparison; AC10 and AC17 of this feature become satisfiable then.
- Verification command (post-follow-up): the corpus comparison procedure recorded in `evidence/other/additive-corpus-parity.2026-08-20T09-53.md` (cross-runtime leg), expected 0 differences over single-`EXIT_CODE` artifacts.
- Evidence: `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence/other/additive-corpus-parity.2026-08-20T09-53.md`; spec.md "Delivered outcome (recorded 2026-08-20)".

### F2 — `scripts/dev_tools/pr_context/collector.py` remains over the 500-line limit (623 lines)

- Severity: **Minor** (pre-existing violation; this branch added 4 lines, within the spec AC20 cap of 5)
- Required remediation action: schedule the extraction already recorded in spec.md "Post-fix monitoring or clean-up tasks" (also covers `tests/scripts/dev_tools/test_collect_pr_context_part4.py`). Not required on this branch.
- Verification command: `(Get-Content scripts/dev_tools/pr_context/collector.py).Count` <= 500 after extraction.

### F3 — Head commit not pushed to origin

- Severity: **Minor** (operational readiness, not a policy finding)
- Observed: branch is 1 commit ahead of `origin/bug/pr-context-verification-cannot-express-expected-nonzero-exit-485` (origin at `468dbe1e`; local head `a1a68417`).
- Required remediation action: push the branch before PR authoring.
- Verification command: `git status -sb` shows no `[ahead N]` marker.

## Do-Not-Do List

- Do not converge the duplicate-required-key precedence on this branch; it would violate the additive requirement (Invariant A) and change reported results for existing artifacts.
- Do not edit AC10/AC17 in `spec.md` to force a PASS; the exclusion-clause widening belongs to the follow-up defect's spec.
- Do not check off AC10 or AC17 in `spec.md` while the residual differences exist.
- Do not weaken, exclude, or reconfigure coverage measurement; no coverage change is needed (all thresholds pass).
- Do not modify policy documents under `.claude/rules/` or `.github/instructions/`.
- Do not edit pre-existing tests; the existing-tests-unmodified invariant (AC25) must continue to hold.

## Handoff Note

No in-branch code-change remediation cycle is required: zero Blocking findings exist, all toolchain and coverage gates pass, and the sole Major finding is remediated by promoting a separate pre-existing defect (F1 step 1), which is a lifecycle action rather than a plan-executable code change on this branch. Consequently this review pass did not author a `remediation-plan.md`; if the orchestrator elects to run a formal remediation cycle for F1, route plan authoring through `remediation-handoff-atomic-planner` with this file as the cycle's remediation inputs, targeting the potential-to-issue promotion and the follow-up fix described above.
