# Feature Audit: Blast-radius overlap and cost performance (#776)

**Audit Date:** 2026-09-29
**Feature Folder:** `docs/features/active/2026-09-29-blast-radius-overlap-perf-776`
**Base Branch:** `main`
**Head Branch:** `bug/blast-radius-overlap-perf-776`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review (after remediation cycle 1)

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` at `37096891e1c3b93d222f772f3b1e3581298e0af0`)
- **Head branch/commit:** `bug/blast-radius-overlap-perf-776` (commit `0f54efe14f48af70a590af4897fd83edb6b61eb8`)
- **Merge base:** `37096891e1c3b93d222f772f3b1e3581298e0af0`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-09-30 00:47:09 UTC for head `0f54efe1`; current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/**` (baseline, remediation-baseline, qa-gates, other), indexed by `evidence/other/r1-small-audit-handoff.2026-09-29T20-47.md`
  - Additional evidence: commands run by this review (blast-radius Pester directory, PSScriptAnalyzer, formatter check, JaCoCo re-parse, changed-line coverage, file hashes, mutation probes, `gh pr list`, `gh run list`)
- **Feature folder used:** `docs/features/active/2026-09-29-blast-radius-overlap-perf-776`
- **Requirements source:** `issue.md`, section `## Acceptance Criteria`
- **Work mode resolution note:** `issue.md` line 12 reads `- Work Mode: minor-audit`, so only the explicit `## Acceptance Criteria` section of `issue.md` is authoritative. The checkboxes under `## Proposed Fix / Validation Ideas` and `## Next Step` are not acceptance criteria.
- **Scope note:** Executor evidence was recorded against `BASE_SHA 43c9e95e`. `git diff --stat 43c9e95e 37096891` over `.claude/lib/blast-radius`, `tests/scripts/claude-lib/blast-radius`, `tests/fixtures/blast_radius`, the bundled blast-radius mirrors, and `scripts/dev_tools/compute_blast_radius.py` is empty, so that evidence applies to the merge base without adjustment. Head SHA-256 hashes of all ten in-scope files match the hashes recorded in `evidence/qa-gates/r1-format.2026-09-29T20-27.md` and `r1-mirror-hashes.2026-09-29T20-43.md`.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/issue.md` — only source (`## Acceptance Criteria`)

### Acceptance criteria

1. `BlastRadius.HistoricalRuns.Tests.ps1`, `BlastRadius.Parity.Tests.ps1`, and every other blast-radius Pester suite pass with no edits to their fixtures or assertions.
2. A before/after local timing of `BlastRadius.HistoricalRuns.Tests.ps1` with coverage disabled is recorded as evidence and shows a material reduction from the 190s baseline.
3. The CI PowerShell QC job duration on the PR head is measurably lower than in run 1043 (838s).
4. Exported function signatures and return values of the blast-radius modules are unchanged.
5. Line coverage stays at or above 85% for every touched production file, and no touched file exceeds 500 lines.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Blast-radius suites pass with no fixture or assertion edits | PASS | This review: 611 total, 610 passed, 0 failed, 1 skipped across all 22 blast-radius suites; HistoricalRuns 9/9, Parity 80/80 (executor JUnit). `git diff --name-status 37096891..HEAD` shows only `A` entries under `tests/`; no fixture and no existing test file changed. Evidence: `evidence/qa-gates/r1-full-suite-pester.2026-09-29T20-41.md`, `r1-scope-and-fixture-immutability.2026-09-29T20-44.md`. | `Invoke-Pester` (Pester 5.6.1, Run.Path `tests/scripts/claude-lib/blast-radius`); `git diff --name-only 37096891..HEAD -- tests/fixtures` (empty); `git diff --diff-filter=M --name-only 37096891..HEAD -- tests/` (empty) | The four new test files are additions and do not edit existing assertions. |
| 2 | Before/after local timing with coverage disabled shows a material reduction | PASS | Before: median 213.12 s (`evidence/baseline/historical-runs-timing.2026-09-29T19-09.md`, Pester 5.6.1, coverage disabled). After: runs 47.18, 37.99, 40.09 s, median 40.09 s (`evidence/qa-gates/r1-historical-runs-timing.2026-09-29T20-33.md`). Ratio 5.32 against the plan threshold of 4.00 (`r1-timing-comparison.2026-09-29T20-33.md`). This review observed 46.1 s for the container inside a full-directory run. | Executor `timing.ps1 -Runs 3`; this review `Invoke-Pester` container duration | The issue cites 190 s; the same-host baseline measured by the plan was 213.12 s. Both comparisons show a reduction of about 79% or more. |
| 3 | CI PowerShell QC job duration on the PR head is lower than 838 s | UNVERIFIED | No PR exists for the branch and no workflow run exists for the head SHA. The handoff (`evidence/other/r1-small-audit-handoff.2026-09-29T20-47.md`) assigns this check to the orchestrator after the PR run, with a target of at most 700 s for `poshqc / PowerShell QC`. | `gh pr list --head bug/blast-radius-overlap-perf-776 --state all` (returned `[]`); `gh run list --branch bug/blast-radius-overlap-perf-776` (returned `[]`) | Cannot be evaluated before the PR is opened. This is not a code defect. |
| 4 | Exported signatures and return values unchanged | PASS | Export subset: 64 of 64 baseline signatures present verbatim; one authorized addition, `Get-OverlappingPathPair` (`evidence/qa-gates/r1-export-subset.2026-09-29T20-43.md`). Return values: 132 pinned costs and all pair lists hash-equal to the pre-change pin (`r1-cost-and-pairs-equivalence.2026-09-29T20-31.md`); Parity suite 80/80; `Get-SmallestPathOverlap` returns `$null` for no overlap, matching the prior `Get-OrdinalSmallestEntry` contract (source inspection). | Executor `export-subset.ps1`, `pin-cost-and-pairs.ps1`; this review `git show 37096891:...` and diff inspection | Remediation input item 5 redefined the check as a subset comparison because of the one authorized addition. The existing signatures and return values are unchanged. |
| 5 | Line coverage at least 85% per touched production file; no touched file over 500 lines | PASS | Re-parsed `artifacts/pester/powershell-coverage.xml`: Glob 100% (77/77), Conflict 97.94% (95/97), Scheduling 100% (116/116). Changed-line coverage recomputed against the merge base: 25/25, 62/63, 2/2. Line counts: 454, 469, 483; new tests 139, 169, 141, 74. | `python <scratchpad>/cov.py`; `python <scratchpad>/changed_cov.py`; `wc -l` | Mirrors are byte-identical to the measured primaries. |

---

## Summary

**Overall Feature Readiness:** PASS (pending AC-3 at the PR CI run)

**Criteria summary:**
- **PASS:** 4 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC-3 needs the PR CI run: the `poshqc / PowerShell QC` job duration on the PR head must be recorded and compared with 838 s (run 1043).

**Recommended follow-up verification steps:**

1. After the PR is opened, read the `poshqc / PowerShell QC` job duration for the head SHA (`gh run view <run-id> --json jobs`), record it under `evidence/qa-gates/`, and check off AC-3 when it is below 838 s.
2. Optionally address the Minor code-review finding (policy-audit gap G-1: unreachable concrete-concrete branch in `Test-PathOverlapRecordPair`) before merge.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

AC-1, AC-2, AC-4, and AC-5 were already checked in `issue.md` by the executor, and this review confirms each as PASS. AC-3 is UNVERIFIED and remains unchecked. This review made no change to `issue.md`.

### AC Status Summary

- Source: `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/issue.md`
- Total AC items: 5
- Checked off (delivered): 4
- Remaining (unchecked): 1
- Items remaining: The CI PowerShell QC job duration on the PR head is measurably lower than in run 1043 (838s).

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/issue.md` | 5 | 4 | 1 | Checkbox-backed; AC-3 awaits the PR CI run |
