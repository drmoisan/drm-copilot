# Remediation Inputs (Issue #543)

Review-Verdict: REMEDIATION_REQUIRED

**Entry timestamp:** 2026-10-02T07-08
**Feature folder:** `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`
**Base branch:** `main` (merge base `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`)
**Head audited:** `bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543` @ `9ad8e5a375d1c42f7ea4511e333e873e18ffad47` (the three audit artifacts were committed afterwards in `b2aa51d0`)
**Work mode:** `full-bug`; AC source is `spec.md` only
**Review pass:** re-audit after remediation cycle 1 (prior inputs: `remediation-inputs.2026-10-02T05-58.md`)
**Blocking finding count:** 1

## Audit Artifacts

- `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/policy-audit.2026-10-02T07-08.md` (Section 8: PA-5 blocking; PA-1, PA-2, PA-4 resolved; PA-3 non-blocking)
- `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/code-review.2026-10-02T07-08.md` (Findings Table: CR-10 Blocker, the same finding as PA-5; CR-1, CR-2, CR-9 resolved; CR-3 to CR-8 non-blocking)
- `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/feature-audit.2026-10-02T07-08.md` (20 PASS, 0 PARTIAL, 0 UNVERIFIED, 0 FAIL; readiness NEEDS REVISION on the non-AC finding PA-5)

## Trigger Justification

Remediation is triggered under `.claude/skills/feature-review-workflow/SKILL.md` step 8 on one clause:

- "the policy audit contains meaningful FAIL or PARTIAL results": PA-5 is a FAIL, and policy-audit Section 2.5 "Explicit reporting" is PARTIAL for the same reason.

Both prior blocking findings (PA-1/CR-1 and PA-2/CR-2) are resolved. All 20 acceptance criteria evaluate PASS and are checked in `spec.md`. Coverage is artifact-verified for both changed coverage languages (Python and TypeScript). The reviewer's re-run of Black, Ruff, Pyright, Prettier, tsc, targeted pytest (118 passed), and targeted Jest (133 passed) at `9ad8e5a3` was clean. No production-code or test defect was found.

## Findings

### R1 — Residual composed `Timestamp:` value in a second row (PA-5, CR-10)

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The correction is a one-value edit plus one added line in a single Markdown evidence file inside the feature folder. The replacement value is stated in this file and in both source audits, and no external system, policy change, or human decision is involved.

**Problem.** `evidence/other/python-batch-budget.2026-10-02T05-01.md` line 31, under `### Reset 1 (P2-T4)`, records `Timestamp: 2026-10-02T05-30`. Reviewer observations recorded in `policy-audit.2026-10-02T07-08.md` Section 8: the file's write time is 05:18:16 (`ls -l --time-style=+%H:%M:%S`, captured before the review wrote any file), and the last commit touching the file is `af88dd58` at 05:19:12 (`git log --format="%h %ci" -- <file>`). The recorded value is later than both, so it was composed rather than read from the host clock. It also matches the fixed 5-minute schedule identified in prior finding PA-2. This violates `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` line 49, which applies to every `Timestamp` value. The prior pass did not list this row because its scan used `grep -m1`, which reads only the first `Timestamp:` row of each file.

**Observed values (reviewer, captured before any edit; date 2026-10-02).** Path is relative to the feature folder's `evidence/` directory. Do not re-read the write time after editing, because editing changes it. Use only the values below.

| Artifact | Line | Recorded `Timestamp:` | Observed write time | Corrected `Timestamp:` value |
|---|---|---|---|---|
| `other/python-batch-budget.2026-10-02T05-01.md` | 31 | 2026-10-02T05-30 | 05:18:16 | `2026-10-02T05-18` |

**Required change.**

1. In `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md`, replace line 31 `Timestamp: 2026-10-02T05-30` with `Timestamp: 2026-10-02T05-18`. Do not add another `Timestamp:` row.
2. Immediately after that row, add one line: `Timestamp-Correction: original value 2026-10-02T05-30 was composed on a fixed schedule rather than read from the host clock; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T07-08.md), an upper bound on the command run time.`
3. Do not rename the file. Its filename suffix `05-01` already falls within the D-TIMESTAMPS treatment recorded in `plan.2026-09-29T16-06.md` `## Plan Deviations`, which states that filename suffixes are not clock readings.
4. Change no other content in this file or in any other artifact, except for the optional N1 header correction below. Do not re-run the recorded command to obtain a new value.
5. As part of verification, scan every `Timestamp:` row in every evidence file (`grep -rn`, not `grep -m1`), as recommended in `code-review.2026-10-02T07-08.md` risk 3, and confirm that no other row carries a value later than its file's write time.

**Verification commands.**

```bash
# from the worktree root
grep -rn "^Timestamp: 2026-10-02T05-30$" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/
# Expect no output
grep -n "^Timestamp" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md
# Expect line 3 `Timestamp: 2026-10-02T05-01` (or `05-18` if N1 is applied), line 31 `Timestamp: 2026-10-02T05-18`,
# and line 32 `Timestamp-Correction: original value 2026-10-02T05-30 ...`
grep -rc "^Timestamp:" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/ | grep -v ":1$"
# Expect exactly one line: the python-batch-budget file with a count of 2; neither of its values is later than 2026-10-02T05-18
grep -rc "^Timestamp-Correction:" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/ | grep -c ":1$"
# Expect 36 (the 35 R2 artifacts plus python-batch-budget). If N1 is also applied, expect 35, and
# `grep -rc "^Timestamp-Correction:" <evidence>/ | grep ":2$"` returns only the python-batch-budget file
grep -rn "^Timestamp:" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/
# Whole-file scan; compare each value with the file's write time and confirm none is later
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
# Expect exit 0
```

**Definition of done.** Line 31 of `evidence/other/python-batch-budget.2026-10-02T05-01.md` reads `Timestamp: 2026-10-02T05-18`, followed directly by one `Timestamp-Correction:` line naming the original value `2026-10-02T05-30`. No `Timestamp:` row in any evidence file carries a value later than its file's observed write time. No other file is changed apart from the optional N1 edit and the new remediation evidence. `validate_evidence_locations.py` exits 0.

## Non-blocking Items (optional in this cycle)

- **N1 (PA-3), OPTIONAL — header correction in the same file.** The line-3 header of `evidence/other/python-batch-budget.2026-10-02T05-01.md` records `Timestamp: 2026-10-02T05-01`, a reused reading; the file was written at 05:18:16. The value is not later than the write time, so it does not block. Both audits recommend applying it together with R1. If applied:
  - Replace line 3 `Timestamp: 2026-10-02T05-01` with `Timestamp: 2026-10-02T05-18`.
  - Immediately after line 3, add `Timestamp-Correction: original value 2026-10-02T05-01 was a reused reading rather than a clock reading for this artifact; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T07-08.md), an upper bound on the write time.`
  - The line numbers of the R1 row then move down by one (to line 32, with its correction line at 33). Apply R1 by content match, not by line number.
  - The other 17 `evidence/baseline/` artifacts that share the `05-01` reading remain non-blocking; their per-file write-time minutes are listed in `remediation-inputs.2026-10-02T05-58.md` N1 if they are corrected later.
- **CR-3 (Minor).** Moving the three `test_readiness_integrity_*` tests to a mirror-layout file is optional; the plan authorized the current placement.
- **CR-6 / CR-7 (Nit).** Optional import merge and stronger assertions. Do not combine these with R1 unless the full toolchain loop is re-run.
- **CR-8 (Info).** No action in this cycle. The PR body must say "Partially addresses #543" and must not use a closing keyword.

## Do-not-do List

1. Do not change any production code, test code, or guidance file; R1 is an evidence correction only.
2. Do not edit any file under `.claude/rules/`, `.github/instructions/`, `.claude/**`, or `.github/**`.
3. Do not compose or estimate any timestamp. Use the observed value in the R1 table, and read the host clock for every new artifact written during remediation.
4. Do not write evidence under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or `artifacts/evidence/`.
5. Do not edit the three audit artifacts listed above or any prior review artifact.
6. Do not modify `scripts/dev_tools/validate_orchestration_artifacts.py` (the Python CLI deferral stands).
7. Do not change the checkbox state or text of any acceptance criterion in `spec.md`; all 20 are PASS and checked.
8. Do not expand scope to the Codex-only topology or model-routing receipt checks; they are outside this spec.

## Exit Gate for This Cycle

The cycle closes when a re-audit finds the R1 definition of done met, all 20 acceptance criteria still PASS, and zero blocking findings.
