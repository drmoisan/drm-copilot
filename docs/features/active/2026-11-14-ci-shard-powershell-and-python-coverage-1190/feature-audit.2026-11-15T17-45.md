# Feature Audit: PowerShell six-shard QC and Python 3.13 two-shard coverage (#1190)

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
- **Head branch/commit:** `feature/ci-shard-powershell-and-python` (commit `497bf51abae3ecbdf8845b4d799fd72a5930f8f2`)
- **Merge base:** `11c6ecde2e3080722c90bc63289bc160bf9596ea`
- **Evidence sources:**
  - Primary: the full branch diff `11c6ecde2..497bf51ab` and the PR context artifacts.
  - Feature evidence: `evidence/other/ci-measurement.2026-11-15T17-20.md` (workflow_dispatch run 43736520255 on the code head `5e8085e4b`, every job green), the baseline records, the phase gates, and the final QA records at `2026-11-15T01-16`.
  - Re-verified in this review: the workflow diffs; byte comparison of the six `execution-environment` copies and two `atomic-plan-contract` copies (identical); README rows; the helper source; the changed pinning tests; logical line counts; the checkbox state of the AC files.
- **Feature folder used:** `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` `## Acceptance Criteria` and `user-story.md` `## Acceptance Criteria` are the AC sources, each tracked independently.
- **Scope note:** No pull request exists yet. The head `497bf51ab` differs from the measured head `5e8085e4b` only by feature-folder documents.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/spec.md` - 12 checkbox items (9 checked at review start)
- `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/user-story.md` - 5 checkbox items (2 checked at review start)

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
| S12 | A measured CI run shows the PowerShell and primary-version Python legs each at or below the duration target, with run URL, per-job durations, and runner-queue trade-off | PARTIAL | The record exists with run URL, per-job durations, and the queue trade-off. Python critical path 11.3 minutes (shards 6.0 and 9.4) meets about 11. PowerShell shards measured 7.4, 13.6, 10.9, 12.5, 9.1, 9.9 minutes; shards 2 and 4 exceed the target and the longest is 13.6. | `ci-measurement.2026-11-15T17-20.md` | Unchecked. See finding F1. |
| U1 | PowerShell QC runs the owner-specified number of size-balanced shards; completeness and coverage merge pass; total count equals discovery | PASS | As S1; the shards are assigned from the committed weights. | As S1 | Checked off in this review. The time spread is tracked under S12. |
| U2 | Python coverage in the owner-specified number of shards whose union is the suite, verified, combined before thresholds | PASS | As S2 and S5. | - | Already checked. |
| U3 | Thresholds and Codecov behave as before on combined data; none lowered | PASS | As S4; the threshold arguments are unchanged. | - | Already checked. |
| U4 | Required gate still reports correctly and blocks on any shard failure | PASS | As S7. | - | Checked off in this review. |
| U5 | A measured CI run shows both legs each at or below the target, recorded as evidence | PARTIAL | As S12. | - | Unchecked. See finding F1. |

---

## Summary

**Overall Feature Readiness:** REMEDIATION_REQUIRED (one acceptance gap, no code defect)

**Criteria summary:**
- **PASS:** 15 criteria (11 in `spec.md`, 4 in `user-story.md`)
- **PARTIAL:** 2 criteria (S12, U5)
- **FAIL:** 0 criteria
- **Pending CI:** 0 criteria

### Shard-balance classification (caller request)

Classification: the weights-file adjustment is a **blocking finding (F1)**, with `Remediability: autonomous` and `Finding-Scope: contained`.

Reasoning:
1. Criterion S12 and U5 require both legs at or below the issue target (about 11 minutes). The measured longest PowerShell shard is 13.6 minutes, 24 percent above the target, and two of six shards exceed it. The criterion cannot be checked off while the measured result misses its stated target; a non-blocking classification would leave a delivered-looking criterion that is not met.
2. The plan's own trigger applies: the spec rollout fallback says to regenerate weights when the shard spread exceeds about 20 percent, and the measured spread is 84 percent of the shortest shard.
3. The longest shard being below the 16.9 minute baseline shows the change is an improvement; it does not meet the stated target, so it does not alter the classification. It does inform the scope.
4. The weights file `config/poshqc-shard-weights.json` is the existing tuning mechanism, and the mean shard time of about 10.6 minutes including setup means six balanced shards can reach the target. The fix is a data-only edit plus one CI re-measurement, with no change to a workflow, helper, public interface, validator contract, or hook decision, so the scope is contained and the remedy is autonomous.
5. The remediation is not on the light path: `config/poshqc-shard-weights.json` is outside the branch diff.

If the re-measured longest shard still exceeds the target after regeneration, the remedy cycle records the measured result and the criterion text stays unchecked; any change of the owner-specified shard count would be a separate owner decision and is not part of this finding.

**Recommended follow-up verification steps:**

1. Regenerate the PowerShell shard weights from the per-file timings of a CI run, commit, and rerun CI by workflow_dispatch.
2. Record the new per-job durations in a new `evidence/other/ci-measurement.<timestamp>.md` (append-only; keep the earlier record).
3. Re-audit; check off S12 and U5 only when both legs meet the target.

---

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
- Items remaining: S12 (measured CI run at or below the duration target; PowerShell longest shard 13.6 minutes), U5 (same criterion in the user story)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/spec.md` | 12 | 11 | 1 | S12 partial |
| `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/user-story.md` | 5 | 4 | 1 | U5 partial |

Newly checked off in this review: spec S1 and S7; user-story U1 and U4. The Definition of Done item "Behavior matches acceptance criteria in all documented environments" and the seeded condition "One real CI run on the PR proves the timings" stay unchecked until S12 is met; they are not acceptance criteria and were not modified.
