# Code Review: Orchestration Completion-Gate and Tooling Friction (#744) — Re-audit R4, Remediation Cycle 1

- **Branch:** `bug/orchestration-completion-gate-and-tooling-friction-744` @ `c5293961b6d1f6c132e56b35b87a9e65f35f4dfb`
- **Base:** `main`, merge base `b080a69ecb60b65d016362b21fffed0a34be9144`
- **Diff:** `git diff b080a69ecb60b65d016362b21fffed0a34be9144..HEAD` (116 files: 28 outside the feature folder, 88 inside)
- **Review date:** 2026-10-02
- **Work mode:** full-bug
- **Prior review:** `code-review.2026-10-02T02-02.md` (head `45506adc`)

## Executive Summary

The code and documentation-surface changes are identical to those reviewed at `45506adc`. `git diff --stat 93c9be9f..c5293961 -- . ":(exclude)docs"` prints nothing, and commit `c5293961` touches only files under the feature folder. The prior assessment of the Python parser fix, the comment-only TypeScript change, the documentation contract tests, and the 11 byte-identical mirrors therefore stands. The reviewer re-ran 260 targeted tests at the new head, and all passed.

The prior blocking item CR-0 (PA-1, inaccurate `Timestamp:` values in 27 Phase 0-4 evidence artifacts) is resolved. The remediation diff consists of 27 removed `Timestamp: 2026-10-02T01-17` rows, 27 replacement `Timestamp:` rows whose values match the R1 table, and 27 identical `Timestamp-Correction:` lines. No other line changed. The single-row discipline was preserved: no artifact has a second `Timestamp:` row, so the first-occurrence parser this branch introduces reads the corrected value. The regenerated PR context renders the corrected values, which confirms this.

CR-1 is deferred to a follow-up, as the remediation plan records. A new Minor item, CR-5 (cross-reference of policy audit PA-3), records one sub-minute `Timestamp:` inconsistency in an artifact outside the R1 set.

Findings: 0 Blocking, 0 Major, 2 Minor, 3 Informational.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/skills/acceptance-criteria-tracking/SKILL.md` (and the `.agents` and `.github` copies) | `### When Orchestrators Enforce AC Tracking` | CR-1 (carried forward, deferred). The sentence "Orchestrators do not directly check off AC items." has no cross-reference to the `### CI-Dependent Criteria` exception. `remediation-plan.2026-10-02T02-02.md` records the deferral to a follow-up by caller directive. | File a follow-up to append "except CI-dependent criteria, per `### CI-Dependent Criteria`" in all three copies and their mirrors. | The text is not contradictory, because the new subsection names itself as the exception. The deferral is acceptable for a Minor item. | `.claude/skills/acceptance-criteria-tracking/SKILL.md:91`; remediation plan line 19 |
| Minor | `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/regression-testing/pester-doc-contracts.2026-09-30T03-18.md` | line 3 | CR-5 (PA-3). `Timestamp: 2026-10-02T01-44` is later than the file's last write time, 01:43:48. The file has been unchanged since commit `65e331e6` (01:44:04), so the value was not a clock reading taken while the command ran. | Correct the value to `2026-10-02T01-43` and add one `Timestamp-Correction:` line, in a later cycle or a follow-up. | The defect class is the same as PA-1, but the error is under one minute and does not invert ordering against any commit. | `ls -l --time-style=+%H:%M:%S`; `git log` for the file |
| Informational | `tests/scripts/dev_tools/pr_context/test_verification_evidence_first_occurrence.py` | lines 105-106, 119, 144, 157 | CR-3 (carried forward). Some asserts carry no failure message. | Optional. | Readability only; pytest assertion rewriting prints both operands. | File lines cited |
| Informational | `tests/scripts/dev_tools/pr_context/test_verification_evidence_first_occurrence.py` | lines 17-19 | CR-2 (carried forward). Imports `SHAPE_CASES` from another test module. | None required. | Reuse over duplication; specified by the plan. | File lines cited |
| Informational | `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` | lines 110-114 | CR-4 (carried forward). The JSDoc's "in both" clause repeats the "Mirrors Python" lead-in. | None required. | Wording only. | `git diff` hunk `@@ -108,9 +108,10 @@` |

## Detailed Review

### Remediation commit `c5293961`

- Scope: 48 files, all under the feature folder. They are 27 corrected evidence artifacts across `baseline/` (18), `regression-testing/` (6), and `other/` (3); 19 new remediation-cycle artifacts under `remediation-baseline/` and `qa-gates/`; one added line in `plan.2026-09-30T03-18.md`; and the new `remediation-plan.2026-10-02T02-02.md`.
- Correctness of values: each of the 27 corrected values equals the corresponding entry in the R1 table, which was built from write times observed before any edit. Because the remediation re-wrote these files, their current write times (02:42-02:44) cannot be used to re-derive the values. The reviewer compared them against the recorded table instead.
- Ordering check after correction: the fail-before/pass-after artifacts now read 01-25 and 01-26 (before the parser fix commit `c768450a` at 01:27:41) and 01-27 (pass-after, at or before the fix commit). `fail-before-doc-contracts` reads 01-31, before the documentation test commit `845d4a21` at 01:31:46. The run-versus-commit inversions that motivated PA-1 no longer exist.
- Parser interaction: `Timestamp-Correction` is not one of the four schema keys, so the parser ignores it. The regenerated summary renders `other/py-shape06-comment-check` as 01-27 and `other/ts-comment-check`/`other/ts-comment-only-diff` as 01-28.
- Remediation-cycle evidence: each of the 19 new artifacts states a `Timestamp:` at or before its write time, and all precede the commit time (02:52:21). The 11 discoverable rows render `pass`.
- Plan deviation entry: complete (artifacts, original value, basis, reason, statement that no command was re-run). The plan validator passes.

### Code and documentation surfaces

Unchanged since `45506adc`. See `code-review.2026-10-02T02-02.md` Detailed Review for the Python parser, TypeScript comments, documentation contract tests, documentation surfaces, and the D-V8-COMMENT-LINES and D-COMPLETED-ATTEMPTS evaluations. Those conclusions are re-confirmed by the reviewer test run below.

## Verification Performed

- `poetry run python -m pytest` targeted run at `c5293961` (two new modules, `tests/scripts/dev_tools/pr_context/`, parallel-surface contracts, both push-down modules including the issue-#510 node, collector expected-exit contract, minor-audit AC contracts): 260 passed.
- `git show c5293961 -U0` line tally over the corrected evidence folders: 27 `-Timestamp:`, 27 `+Timestamp:`, 27 `+Timestamp-Correction:`, nothing else.
- lcov parse of both coverage artifacts: figures unchanged from the prior review.
- PR context regenerated for Head SHA `c5293961`: 49 verification-evidence rows, all `pass`.
- `validate_evidence_locations.py --root .`: exit 0.
