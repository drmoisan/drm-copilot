# Code Review: PoshQC coverage denominator reproducibility, round 2 evidence-only closure (#527)

---

**Review Date:** 2026-10-17
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527`
**Feature Folder Selection Rule:** supplied by the caller and confirmed against the branch diff (all 27 changed paths are inside it)
**Base Branch:** `main` (`18d6d1ccd455a280ca3b7a47ce4976f162e8803e`)
**Head Branch:** `bug/poshqc-coverage-denominator-527-r2` (`d16acad8147ec65c8a7928c732b40158b202b343`)
**Review Type:** Initial review of the round-2 branch

---

## Executive Summary

The branch contains three documentation commits: a round-2 research file and spec revision, a round-2 plan, and the execution evidence. It changes 27 files (950 insertions, 9 deletions), all Markdown under the feature folder. No production, test, configuration, workflow, or mirror file changed, which the reviewer confirmed with `git diff --name-only 18d6d1ccd..HEAD` (zero paths outside the feature folder).

**What changed:** `spec.md` gains a `## Revision 2026-10-17 (round 2)` section, a reworded acceptance criterion 1 (key set normalized to repository-relative `package|sourcefile`, CI comparison added), and four checked criteria (11, 12, 13, 19). The plan and 24 evidence files document three local denominator runs, a consumer-fixture run and check, three seeded shuffled-order runs, an acceptance-criteria verification table, a self-review, and scope checks.

**Top 3 risks:**
1. Acceptance criterion 1 has a CI leg that cannot be verified until the PR head has a successful full CI run. It is correctly left unchecked, but the closure auto-close reference must not be merged before that comparison is recorded.
2. The 14 criteria checked in round 1 rest on round-1 evidence, which the executor did not re-run. The implementation is on `origin/main`, so the risk is low.
3. The spec header still names the round-1 research file as the technical basis while the revision cites the round-2 research file.

**PR readiness recommendation:** **Conditional Go** - there is no code-quality defect in the diff; readiness depends on the acceptance-criterion 1 CI comparison (feature audit finding FA-B1).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` | header, line 9 | `Technical basis` names `research/research.2026-09-29T15-40.md`; the round-2 revision cites `research/research.2026-10-17T12-35.md`. | Add the round-2 research file to the header on the next spec edit. | Keeps the traceability chain unambiguous. | `git diff 18d6d1ccd..HEAD -- spec.md` shows the header unchanged. |
| Info | `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` | header (`Status`, `Version`) | `Status: Draft` and `Version: 0.3` were not advanced for a closed round. | Update at closure if the lifecycle requires it. | Cosmetic; no gate reads these fields. | Spec header lines 5 to 8. |
| Info | `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/evidence/qa-gates/ac-verification.2026-10-17T13-11.md` | Output Summary | States that 14 criteria checked in round 1 were not re-verified in round 2. | None. The statement is accurate and the implementation is on `origin/main`. | Transparent disclosure of verification scope. | Reviewer confirmed the module, the config file, and the runsettings shape exist on the head. |
| Info | `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/evidence/qa-gates/ci-leg-pending.2026-10-17T13-03.md` | whole file | The CI leg is recorded as `PENDING-CI` with the local values to compare (215 files, LINE total 19095, key hash `08ab3a8d...`). | Perform the S9 comparison and record it. | This is the only open item in the round; it is carried as feature finding FA-B1. | `ci-leg-pending.2026-10-17T13-03.md` lines 8 to 16. |

No Blocker or Major findings in this review. The single blocking item of the review is feature-audit finding FA-B1.

---

## Implementation Audit

No Python, TypeScript, PowerShell, or C# file changed, so no language implementation audit applies. The diff was reviewed as documentation and evidence.

### What changed well

- The plan states scope up front (evidence-only) and proves it twice with `git diff` and `git status` scope checks (`evidence/baseline/scope-check-start.2026-10-17T12-56.md`, `evidence/qa-gates/scope-check.2026-10-17T13-14.md`).
- The rewording of criterion 1 removes a real ambiguity: the leaf `sourcefile` name is not unique, so the key is now `package|sourcefile` normalized to repository-relative paths.
- Evidence files use the `SCRATCH` and `<ROOT>` tokens, so no host path is committed.
- Round-1 artifacts were superseded by newer files and not edited, consistent with the evidence conventions.

### Documentation accuracy notes

- The reviewer re-derived the key facts that can be checked offline: the consumer fixture is committed with exactly three files, `.gitignore` line 8 ignores `/tests/fixtures/poshqc-consumer/artifacts/`, the pre-fix reference artifact records `SAMPLE_PRESENT=0` and `STANDIN_PRESENT=1`, `PoshQC.Testing.psm1` is 479 lines, and `git status --porcelain` is empty.
- The numeric claims (215 files, LINE total 19095) are internally consistent across the determinism, shuffle, and pending-CI artifacts. The reviewer did not re-execute the runs.

---

## Test Quality Audit

No test was added or changed. The verification evidence was reviewed for sufficiency.

### Reviewed test and QA artifacts

- `evidence/qa-gates/determinism-comparison.2026-10-17T13-03.md` - three runs from three working directories; equal key sets, zero per-file differences, equal totals. Sufficient for the local legs of criterion 1.
- `evidence/regression-testing/order-independence-summary.2026-10-17T13-09.md` and the three seed artifacts - three distinct orders, zero failures, same key set and total. Sufficient for criterion 19.
- `evidence/regression-testing/post-fix-fixture-check.2026-10-17T13-04.md` and `post-fix-fixture-run.2026-10-17T13-04.md` - one sourcefile, covered lines 2, package `scripts`, no stand-in, zero failures. Sufficient for criteria 11 and 12 together with `evidence/qa-gates/fail-first-reference.2026-10-17T13-04.md`.
- `evidence/qa-gates/fixture-output-hygiene.2026-10-17T13-04.md` - empty porcelain before and after. Sufficient for criterion 13.
- `evidence/qa-gates/self-review.2026-10-17T13-12.md` - template walk with `FAIL_ROWS: 0`.

### Quality assessment prompts

- **Determinism:** runs vary the working directory and test order; all produced identical keys and totals.
- **Isolation:** the fixture run uses a separate root, and no drm-copilot path appears in its report.
- **Speed:** not recorded; not required by the criteria.
- **Diagnostics:** each artifact records command, exit code, and a summary with explicit values.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Round-2 files contain no credential pattern; the diff is Markdown only. |
| No unsafe subprocess or command construction | N/A | No code changed. |
| Input validation at boundaries | N/A | No code changed. |
| Error handling remains explicit | N/A | No code changed. |
| Configuration / path handling is safe | PASS | No host path in round-2 evidence (search for drive-letter user paths and the host user name returned nothing). |
| Unmet criteria remain unchecked | PASS | Criterion 1 remains `- [ ]` in `spec.md`; the other 18 are checked with evidence. |

---

## Research Log

No external research was required. The review used the repository diff, the PR context artifacts, the spec, the plan, and the feature evidence folder.

---

## Verdict

The documentation and evidence in this branch are accurate, consistent, and correctly scoped. There is no Blocker or Major code-review finding. The branch is ready for normal PR flow once the acceptance-criterion 1 CI comparison is recorded; that dependency is tracked as FA-B1 in the feature audit and in the remediation inputs for this review.
