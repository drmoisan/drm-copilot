# Feature Audit: PowerShell six-shard QC and Python 3.13 two-shard coverage (#1190), reaudit after remediation cycle 1

---

**Audit Date:** 2026-11-15
**Feature Folder:** `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190`
**Base Branch:** `main`
**Head Branch:** `feature/ci-shard-powershell-and-python`
**Work Mode:** `full-feature`
**Audit Type:** Full audit of the branch diff against the merge base

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main`, merge base `11c6ecde2e3080722c90bc63289bc160bf9596ea`)
- **Head branch/commit:** `feature/ci-shard-powershell-and-python` (commit `7bda5fe2bc599be5be8460823b5171411d8e9d42`)
- **Merge base:** `11c6ecde2e3080722c90bc63289bc160bf9596ea`
- **Evidence sources:**
  - Primary: the full branch diff `11c6ecde2..7bda5fe2b` and the PR context artifacts.
  - Feature evidence: `evidence/other/ci-measurement.2026-11-15T17-20.md` (workflow_dispatch run 43736520255 on `5e8085e4b` and, after the weights regeneration, `evidence/other/ci-measurement.2026-11-15T19-10.md`: run 43749104502 on code head `26217c890`, every job green including `CI Required Gate`), the baseline records, the phase gates, and the final QA records at `2026-11-15T01-16`.
  - Re-verified in this review: the workflow diffs; byte comparison of the six `execution-environment` copies and two `atomic-plan-contract` copies (identical); README rows; the helper source; the changed pinning tests; logical line counts; the checkbox state of the AC files.
- **Feature folder used:** `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` `## Acceptance Criteria` and `user-story.md` `## Acceptance Criteria` are the AC sources, each tracked independently.
- **Scope note:** No pull request exists yet. The head `7bda5fe2b` differs from the measured code head `26217c890` only by feature-folder documents (`git diff --name-only 26217c890..HEAD`); `26217c890` differs from `5e8085e4b` by the data-only `config/poshqc-shard-weights.json` regeneration and feature-folder documents.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/spec.md` - 12 checkbox items (11 checked at review start)
- `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/user-story.md` - 5 checkbox items (4 checked at review start)

Numbering S1 to S12 and U1 to U5 follows file order.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S1 | `_poshqc.yml` declares six shards; completeness, coverage merge, and Pester discovery count pass in CI | PASS | Matrix `shard: [1, 2, 3, 4, 5, 6]`; run 43736520255 shows all six shards and the aggregator (1.8 minutes) green. | `git diff -- .github/workflows/_poshqc.yml`; `gh run view 43736520255` as recorded | Checked off in this review. |
| S2 | Python 3.13 coverage in two shards using the helper; deterministic and balanced; no new Python | PASS | `python-coverage-shard` matrix `[1, 2]`; helper SH01 and SH02; no `.py` added. | Workflow diff; Pester SH01, SH02 | Already checked. |
| S3 | Each shard uploads coverage data, JUnit, manifest | PASS | Upload step name `python-coverage-shard-${{ matrix.shard }}` lists the three paths; `if-no-files-found: error`. | Workflow diff | Already checked. |
| S4 | Combine job keeps the required name; combines, then unchanged thresholds and Codecov | PASS | Job name `Code Quality & Tests (3.13)`; `coverage combine` precedes `--min-line 85 --min-branch 75` and Codecov; context kept in run. | Workflow diff | Already checked. |
| S5 | Completeness check fails on a missing or duplicated file and on a JUnit total mismatch | PASS | SH09 absent, duplicate, and JUnit-sum cases; combine verify step. | Pester SH09 | Already checked. |
| S6 | Python compatibility runs unchanged and keep contexts | PASS | Matrix `["3.11", "3.12"]` with the same no-coverage step; contexts kept. | Workflow diff | Already checked. |
| S7 | `CI Required Gate` blocks on any shard failure; combine reports success on a docs-only run | PASS | The combine first step exits 1 unless the static and shard jobs succeeded; `ci-required-gate` needs `quality-checks7` and `poshqc`, whose results include every called job; the combine job runs under `if: always()` with every step gated on `inputs.run-heavy`, pinned by the run-heavy gating test for all three jobs; the run passed `CI Required Gate`. | Workflow diff; `ci.yml`; Pester gating test | Checked off in this review on static evidence plus the green gate; a failing-shard run was not exercised in CI. |
| S8 | actionlint passes on both workflows | PASS | actionlint 1.7.12, exit 0 (`task-check.P2-T2`, final static record). | Evidence read | Already checked. |
| S9 | Pester tests cover balanced assignment, deterministic order, absent file, duplicate; helper meets thresholds | PASS | SH01 to SH10; helper 89.86% lines. | Coverage artifact | Already checked. |
| S10 | Workflow-pinning tests updated and pass | PASS | Six-shard literal test, gating test, eight new contract tests; final gates 0 failures. | Gate records | Already checked. |
| S11 | Brief copies, `_REQUIRED_CONTEXTS` handling, README list new shards and contexts | PASS | Six brief copies byte-identical; `_ADDED_CONTEXTS` holds shards 4 to 6 and the Python job contexts; README rows 22 to 27 and the restructure paragraph. | `cmp`; diff | Already checked. |
| S12 | A measured CI run shows the PowerShell and primary-version Python legs each at or below the duration target, with run URL, per-job durations, and runner-queue trade-off | PARTIAL (non-blocking) | Records exist with run URLs, per-job durations, and the queue trade-off (two measurements). Run 43749104502 after the one permitted regeneration: Python 3.13 path 10.5 minutes (baseline 16.4) meets about 11; PowerShell shards 12.7, 10.2, 10.0, 8.4, 9.9, 10.4 minutes, longest 12.7 (before 13.6; baseline 16.9), so five of six shards are at or below the target and shard 1 is 15 percent above it. | `ci-measurement.2026-11-15T19-10.md` | Left unchecked; documented trade-off, see determination below. |
| U1 | PowerShell QC runs the owner-specified number of size-balanced shards; completeness and coverage merge pass; total count equals discovery | PASS | As S1; the shards are assigned from the committed weights. | As S1 | Checked off in this review. The time spread is tracked under S12. |
| U2 | Python coverage in the owner-specified number of shards whose union is the suite, verified, combined before thresholds | PASS | As S2 and S5. | - | Already checked. |
| U3 | Thresholds and Codecov behave as before on combined data; none lowered | PASS | As S4; the threshold arguments are unchanged. | - | Already checked. |
| U4 | Required gate still reports correctly and blocks on any shard failure | PASS | As S7. | - | Checked off in this review. |
| U5 | A measured CI run shows both legs each at or below the target, recorded as evidence | PARTIAL (non-blocking) | As S12. | - | Left unchecked. |

---

## Summary

**Overall Feature Readiness:** PASS (ready for pull request; one documented non-blocking PARTIAL)

**Criteria summary:**
- **PASS:** 15 criteria (11 in `spec.md`, 4 in `user-story.md`)
- **PARTIAL (non-blocking):** 2 criteria (S12, U5)
- **FAIL:** 0 criteria
- **Pending CI:** 0 criteria (the CI-dependent evidence is in: run 43749104502 is green on every job on the code head)

### Determination of F1 / S12 / U5 (caller request)

Classification: **non-blocking PARTIAL (documented trade-off)**. F1 from the review of 2026-11-15T17-45 is closed as a blocking finding.

Reasoning:
1. The one permitted regeneration was applied and verified: `cde1c4a3e` is a data-only change to `config/poshqc-shard-weights.json` (819 listed files, equal to the JUnit testsuite count), gated by the final Pester record (26885 tests, 0 failures, coverage unchanged at 96.00%).
2. The result is a material cut. The longest PowerShell shard fell from 16.9 minutes (baseline) to 13.6 (first run) to 12.7 (second run), a 25 percent cut of the long leg; the Python 3.13 path fell from 16.4 to 10.5 minutes and meets the target. The issue's own wording targets "about 11 minutes" and a material cut; the user story says "toward 11 minutes".
3. The residual is not remediable by weights. The projected per-file balance is 1.000, so the spread (8.4 to 12.7) comes from per-shard fixed cost and run-to-run runner variance of 1 to 3 minutes. A second regeneration chases noise, and the remediation plan limits the cycle to one regeneration and instructs recording the residual without altering the criterion.
4. The remaining lever is the shard count, which is an owner-specified input. A blocking finding with no autonomous remedy would only stall the item, so the gap is carried as a non-blocking trade-off, recorded in `evidence/other/ci-measurement.2026-11-15T19-10.md`, and surfaced for the owner.
5. The criteria stay unchecked because the literal text ("each at or below the target") is not met by shard 1 (12.7 minutes); they are not reported as PASS.

**Recommended follow-up (optional, owner decision):** raise the PowerShell shard count from six if a per-shard figure at or below 11 minutes is wanted; the weights file and workflow need no other change.

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/spec.md`, `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/user-story.md`
- Total AC items: 17 (12 + 5)
- Checked off (delivered): 15 (11 + 4)
- Remaining (unchecked): 2 (1 + 1)
- Items remaining: S12 and U5 (measured CI run with both legs at or below the target; Python met, PowerShell longest shard 12.7 minutes against about 11; non-blocking PARTIAL)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/spec.md` | 12 | 11 | 1 | S12 PARTIAL |
| `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/user-story.md` | 5 | 4 | 1 | U5 PARTIAL |

Newly checked off in this review: none. All 15 PASS criteria were already checked at review start (checked in review one and by the remediation cycle); each was re-verified against the unchanged workflow files and CI run 43749104502. S7 and U4, the criteria that depend on CI, are evidenced by the green `CI Required Gate` on the code head. The Definition of Done item "Behavior matches acceptance criteria in all documented environments" and the seeded condition "One real CI run on the PR proves the timings" stay unchecked; they are not acceptance criteria and were not modified.
