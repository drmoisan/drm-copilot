# Feature Audit: PoshQC coverage denominator reproducibility, round 2 evidence-only closure (#527)

---

**Audit Date:** 2026-10-17
**Feature Folder:** `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527`
**Base Branch:** `main`
**Head Branch:** `bug/poshqc-coverage-denominator-527-r2`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review of the round-2 branch

---

## Scope and Baseline

- **Base branch:** `main` (commit `18d6d1ccd455a280ca3b7a47ce4976f162e8803e`)
- **Head branch/commit:** `bug/poshqc-coverage-denominator-527-r2` (commit `d16acad8147ec65c8a7928c732b40158b202b343`)
- **Merge base:** `18d6d1ccd455a280ca3b7a47ce4976f162e8803e`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/evidence/**`
  - Additional evidence: `plan.2026-10-17T08-20.md`, `spec.md` section `## Revision 2026-10-17 (round 2)`
- **Feature folder used:** `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527`
- **Requirements source:** `spec.md`, section `## Acceptance Criteria`
- **Work mode resolution note:** `issue.md` carries `Work Mode: full-bug`, so `spec.md` is the only AC source.
- **Scope note:** the branch diff is documentation and evidence only. The implementation (PR #821 lineage and later changes) is on `origin/main`. Criteria 2 through 10 and 14 through 18 were delivered and checked in round 1; their implementation artifacts are present on the head and the round-1 evidence remains in the feature folder. Round 2 delivered and checked criteria 11, 12, 13, and 19, and left criterion 1 pending CI. No pull request exists yet, so no CI result exists for the PR head.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` - only source (checkbox-backed)

### Acceptance criteria (labels abbreviated; full text is in `spec.md`)

1. Deterministic derivation (identical normalized `package|sourcefile` keys and LINE totals across runs, third run from outside the tree, local denominator equals the CI merged report)
2. Route independence
3. Derived population contents
4. Precedence order
5. Observability
6. Config validation
7. Absolute root
8. Allow-list removed
9. Parity preserved
10. `config/poshqc-coverage.json` exists and a self-hosted run logs source `config`
11. Consumer fixture coverage
12. Consumer isolation
13. Fixture output hygiene
14. New code coverage
15. Existing suite
16. Documentation
17. No temporary files in tests
18. `PoshQC.Testing.psm1` and every new file at or under 500 lines
19. Order independence

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Deterministic derivation | PARTIAL | Local legs pass: runs A, B, C (three working directories) report 215 files, LINE total 19095, identical key hash, zero per-file differences (`evidence/qa-gates/determinism-comparison.2026-10-17T13-03.md`). The CI leg ("local denominator equals the CI merged report for the same production tree") is `PENDING-CI` (`evidence/qa-gates/ci-leg-pending.2026-10-17T13-03.md`). | `git grep -n -F -e '- [ ] Deterministic derivation:' HEAD -- docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` | CI-dependent criterion; no PR exists. Owner of the check-off is the item's own orchestrator run at S9. See FA-B1. |
| 2 | Route independence | PASS | Round-1 fail-first and pass evidence: `evidence/regression-testing/fail-first-coverage-tests.2026-10-02T08-45.md`, `evidence/regression-testing/pass-after-new-tests.2026-10-02T08-45.md`; test file present on the head. | `git ls-tree -r --name-only HEAD tests/scripts/powershell/PoshQC` | Checked in round 1; not re-run in round 2. |
| 3 | Derived population contents | PASS | `evidence/regression-testing/pass-after-new-tests.2026-10-02T08-45.md`; `PoshQC.Coverage.psm1` present. | `git ls-tree HEAD scripts/powershell/PoshQC/PoshQC.Coverage.psm1` | Checked in round 1. |
| 4 | Precedence order | PASS | `evidence/regression-testing/pass-after-new-tests.2026-10-02T08-45.md`. | not re-run | Checked in round 1. |
| 5 | Observability | PASS | `evidence/regression-testing/pass-after-invokesummary.2026-10-02T08-45.md`; round-2 runs log `source=config` and `source=fallback; files=1`. | not re-run | Checked in round 1 and re-observed in round 2. |
| 6 | Config validation | PASS | `evidence/regression-testing/fail-first-coverageconfig-tests.2026-10-02T08-45.md`, `evidence/regression-testing/pass-after-named-tests.2026-10-02T08-45.md`. | not re-run | Checked in round 1. |
| 7 | Absolute root | PASS | `evidence/regression-testing/pass-after-named-tests.2026-10-02T08-45.md`; run C from outside the tree matched run A in round 2. | not re-run | Checked in round 1. |
| 8 | Allow-list removed | PASS | `evidence/qa-gates/runsettings-shape.2026-10-02T08-45.md`; the head runsettings file has a single `CodeCoverage` reference. | `grep -c CodeCoverage scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (returned 1) | Reviewer-observed. |
| 9 | Parity preserved | PASS | `evidence/regression-testing/parity-after-mirror.2026-10-02T08-55.md`, `evidence/qa-gates/final-python-pytest-parity.2026-10-02T08-45.md`. | not re-run | Checked in round 1; no PoshQC file changed in round 2. |
| 10 | `config/poshqc-coverage.json` and source `config` | PASS | File present on the head; round-2 runs A, B, C log `source=config`. | `git ls-tree HEAD config/poshqc-coverage.json` | Reviewer-observed. |
| 11 | Consumer fixture coverage | PASS | `evidence/regression-testing/post-fix-fixture-run.2026-10-17T13-04.md` (source `fallback`, 1 file, 0 failures), `evidence/regression-testing/post-fix-fixture-check.2026-10-17T13-04.md` (covered LINE count 2), pre-fix reference `evidence/qa-gates/fail-first-reference.2026-10-17T13-04.md`; the reviewer confirmed the pre-fix artifact records `SAMPLE_PRESENT=0` and `STANDIN_PRESENT=1`. | `git ls-tree -r --name-only HEAD tests/fixtures/poshqc-consumer` | Checked in round 2. The fixture has exactly three committed files and no coverage config. |
| 12 | Consumer isolation | PASS | `post-fix-fixture-check.2026-10-17T13-04.md`: one sourcefile `Sample.psm1`, package `scripts`, stand-in absent, zero outside packages. | not re-run | Checked in round 2. |
| 13 | Fixture output hygiene | PASS | `evidence/qa-gates/fixture-output-hygiene.2026-10-17T13-04.md`; reviewer re-ran `git status --porcelain` (empty) and `git check-ignore -v tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml` (rule `.gitignore:8`). | `git status --porcelain` | Reviewer-observed. |
| 14 | New code coverage | PASS | `evidence/qa-gates/coverage-new-code.2026-10-02T08-45.md`, `evidence/qa-gates/coverage-aggregate.2026-10-02T08-45.md`. | not re-run | Checked in round 1. The repository aggregate below 85% was recorded as evidence-only per the spec Coverage Policy. |
| 15 | Existing suite | PASS | `evidence/qa-gates/final-pwsh-test-run-a.2026-10-02T08-45.md`, `final-pwsh-format`, `final-pwsh-analyze`. Round-2 shuffled runs of the PoshQC test directory had zero failures. | not re-run | Checked in round 1. |
| 16 | Documentation | PASS | `evidence/qa-gates/readme-documentation.2026-10-02T08-45.md`. | not re-run | Checked in round 1. |
| 17 | No temporary files in tests | PASS | `evidence/qa-gates/test-purity.2026-10-02T08-45.md`. | not re-run | Checked in round 1; no test changed in round 2. |
| 18 | File size limits | PASS | `evidence/qa-gates/line-limits.2026-10-02T08-45.md`; `PoshQC.Testing.psm1` is 479 lines on the head. | `wc -l scripts/powershell/PoshQC/PoshQC.Testing.psm1` | Reviewer-observed. |
| 19 | Order independence | PASS | `evidence/regression-testing/order-independence-summary.2026-10-17T13-09.md` and the three seed artifacts: zero failures, three distinct orders, same key set and LINE total as run A. | not re-run | Checked in round 2. |

---

## Findings

### FA-B1 - Acceptance criterion 1 CI leg unverified

- Severity: Blocking
- Remediability: awaiting_ci
- Criterion: 1, Deterministic derivation: "The local denominator equals the CI merged report for the same production tree."
- Gap: the local legs pass, but no CI run exists for the PR head, so the equality with the CI merged report is unverified. The spec revision cites an orchestrator-measured CI figure (215 files, LINE total 19095) from earlier runs; that is context, not a recorded comparison under `evidence/`.
- Required action (item's own orchestrator run, at S9): compare the run A values in `evidence/qa-gates/ci-leg-pending.2026-10-17T13-03.md` with the `Merged PowerShell line coverage` aggregator line of the newest full CI run of the PR head whose `CI full run` job succeeded, record the comparison under `evidence/qa-gates/`, check off criterion 1 in `spec.md`, and re-run the CI gate against the final head.

---

## Summary

**Overall Feature Readiness:** BLOCKED (pending CI only; no defect found)

**Criteria summary:**
- **PASS:** 18 criteria
- **PARTIAL:** 1 criterion
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. Criterion 1 CI leg (FA-B1).

**Recommended follow-up verification steps:**

1. After the PR is opened and its full CI run succeeds, record the CI comparison for criterion 1 and check it off.
2. Use an auto-close reference in the PR only after that comparison is recorded.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, criteria evaluated as PASS are checked off in the source file when not already checked; PARTIAL criteria stay unchecked. The reviewer made no change to `spec.md`: the 18 PASS criteria were already checked, and criterion 1 remains unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md`
- Total AC items: 19
- Checked off (delivered): 18
- Remaining (unchecked): 1
- Items remaining: Deterministic derivation (CI leg pending)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` | 19 | 18 | 1 | Checkbox-backed; no source change made by this review |
