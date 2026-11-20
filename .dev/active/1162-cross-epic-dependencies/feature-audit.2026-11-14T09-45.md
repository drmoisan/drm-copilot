# Feature Audit: cross-epic-dependencies (#1162)

**Audit Date:** 2026-11-14
**Feature Folder:** `docs/features/active/2026-11-09-cross-epic-dependencies-1162`
**Base Branch:** `main`
**Head Branch:** `feature/cross-epic-dependencies-1162`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after remediation cycle 1 (S7)

---

## Scope and Baseline

- **Base branch:** `main` (commit `1d9f14e2c595b0065ad42a24188620f320ac514c`, equal to `origin/main` after a fetch at review time)
- **Head branch/commit:** `feature/cross-epic-dependencies-1162` (commit `97f4e351dd0dc42d206c225eed9ed999322d3521`, clean worktree)
- **Merge base:** `1d9f14e2c595b0065ad42a24188620f320ac514c`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-14 09:40:39 UTC at head `97f4e351d`, range `1d9f14e2c..97f4e351d`), cross-checked with `git diff 1d9f14e2c..HEAD` (149 files)
  - Secondary: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/baseline/` and `evidence/remediation-baseline/` (Phase 0), `evidence/qa-gates/*.2026-11-14T09-*` (cycle final gates), `evidence/other/` (fail-before and pass-after records, main sync, frozen digests, autonomous decisions, preflight fixes)
  - Reviewer probes in SCRATCH: F1 mutant probe, main-merge neutrality, digest recomputation, blob parity, per-file coverage parse
- **Feature folder used:** `docs/features/active/2026-11-09-cross-epic-dependencies-1162`
- **Requirements source:** `spec.md` and `user-story.md`; `issue.md` also carries six mirrored checkbox criteria
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the authoritative sources. The six `issue.md` criteria mirror Issue AC1 to AC6 and are evaluated through the spec criteria grouped under each. The six unchecked boxes in `spec.md` belong to `## Definition of Done`, a template checklist that is not an AC source, and are left unchanged.
- **Scope note:** full branch diff against the merge base; no narrowing applied.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-09-cross-epic-dependencies-1162/spec.md` (25 checkbox items under `## Acceptance Criteria`, grouped by Issue AC1 to AC6)
- `docs/features/active/2026-11-09-cross-epic-dependencies-1162/user-story.md` (8 checkbox items)
- `docs/features/active/2026-11-09-cross-epic-dependencies-1162/issue.md` (6 checkbox items, mirrored issue criteria)

### Acceptance criteria

Spec (S1 to S25, in source order):
1. S1 to S5 (Issue AC1): skill section and references; both templates byte-identical; manifest error codes and CLI exit 1; Python and TypeScript MALFORMED parity; absent-key behavior unchanged.
2. S6 to S11 (Issue AC2): D11 PR match; main-sync exclusion test; both decision tables; pure functions and adapter tests; CLI contract and bounded wait; 85% line coverage of the two new files with clean PoshQC gates.
3. S12 to S15 (Issue AC3): launch hold and D4 procedure in skill and agent; Bash grant and Codex procedure; started-while-held invariant in three runtimes; D7 records and D10 handoff line documented.
4. S16 to S19 (Issue AC4): external nodes; cap exclusion and schedule; rendering; skill rule and 85% coverage of the part file.
5. S20 to S21 (Issue AC5): main hold in skill and agent; completion invariant in Python and TypeScript.
6. S22 to S25 (Issue AC6): planner-side surfaces; mirrors and pack manifests; frozen digests; existing contract tests pass with no hook change.

User story (U1 to U8): manifest key and kickoff rejection; absent-key behavior; pure decisions with mocked fail-closed adapters; main-sync PR never accepted; held feature gets no worktree, D4 merge, started-while-held flag; external nodes on the critical path; integration-to-main hold and completion gate; skills, agents, Codex variants, bundles, and contract tests.

Issue (I1 to I6): the six issue criteria.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S1 | Skill section, `## Epic Dependency Manifest` reference, `.agents` manifest contract | PASS | `## Cross-Epic Dependencies (cross_epic_depends_on)` carries syntax, codes, both tables, D4, D7 with the new status mapping, D8, D10, and D5; `cross-epic-skill-contract.Tests.ps1` passes in the post-merge Pester gate. | Reviewer read; `pester.2026-11-14T09-30.md` | Prior F2 note resolved |
| S2 | Both epic templates document the key and stay byte-identical | PASS | One blob id for both templates (reviewer `git ls-files -s`). | `git ls-files -s` | |
| S3 | Each manifest code and CLI exit 1 | PASS | `EpicCrossDependency.Tests.ps1` and `Invoke-EpicCrossReadiness.Tests.ps1` pass. | Pester gate | |
| S4 | MALFORMED parity in Python and TypeScript, both checkpoints | PASS | pytest 16822 passed, root Jest 5646 passed, 0 failed. | pytest and Jest gates | |
| S5 | Absent key behaves as before | PASS | Existing epic validator, wave, wave-barrier, and progress-report suites pass. | Pester, pytest, Jest gates | |
| S6 | D11 match rules incl. longer-token negative | PASS | Unchanged in the cycle; tests pass. | Pester gate | |
| S7 | Main-sync PR not matched | PASS | Dedicated test passes. | Pester gate | |
| S8 | Every row of both decision tables | PASS | Table-driven tests pass; row 2 (`PREREQ_IN_MAIN`) is now reachable from the stale-ref state through the adapters. | Pester gate; reviewer mutant probe | Prior F1 note resolved |
| S9 | Pure functions perform no I/O; adapter tests assert argument arrays and fail closed | PASS | Adapter suite asserts `fetch|-q|--prune|origin` and the stale-ref release; failed-fetch and thrown-wrapper rows still hold. | Pester gate; reviewer mutant probe (26 of 26 on head, 6 failures on the reverted-fetch mutant) | |
| S10 | CLI contract and bounded wait through seams | PASS | `Invoke-EpicCrossReadiness.Tests.ps1` passes, unchanged. | Pester gate | |
| S11 | Two new files at or above 85% lines; PoshQC gates clean | PASS | `EpicCrossDependency.psm1` 98.03%, `Invoke-EpicCrossReadiness.ps1` 100% (reviewer parse of `artifacts/pester/powershell-coverage.xml`); format, analyzer, and leak scan 0 findings. | `pester.2026-11-14T09-30.md`, `powershell-static.2026-11-14T09-09.md` | |
| S12 | Launch hold and D4 procedure in skill and agent | PASS | Text present; contract test passes; `PREREQ_IN_MAIN` path now reachable. | Pester gate | |
| S13 | Bash grant and Codex procedure; permission and citation tests | PASS | Permission and citation tests pass in the pytest gate. | pytest gate | |
| S14 | Started-while-held in three runtimes; fail-closed import | PASS | Parity suites pass; the mapping text matches the accepted statuses. | Pester, pytest, Jest gates | |
| S15 | D7 records and D10 line documented | PASS | Records paragraph plus the **Status mapping (D7).** paragraph on all four surfaces; `CES-STATUS-MAPPING` passes. | Pester gate | Prior F2 resolved |
| S16 | External nodes from checkpoint rows and the raw manifest value | PASS | `Get-EpicProgressReport.CrossEpic.Tests.ps1` passes; part file 56/56 lines. | Pester gate | |
| S17 | Cap exclusion; byte-identical schedule without external nodes | PASS | Schedule and CriticalPath suites pass. | Pester gate | |
| S18 | Rendering of external nodes and the `Cross-epic:` line | PASS | Render.CriticalPath and CrossEpic suites pass. | Pester gate | |
| S19 | Progress-report skill rule pinned; part file at or above 85% | PASS | `EpicProgressReport.SkillContract.Tests.ps1` passes; part file 100%. | Pester gate | |
| S20 | Main hold in skill and agent incl. D5 disclosure | PASS | Text present; contract test passes. | Pester gate | |
| S21 | Completion invariant in Python and TypeScript | PASS | `validate_cross_epic_main_gate` and the TypeScript twin; tests pass. | pytest and Jest gates | |
| S22 | Planner-side surfaces | PASS | Sections present; contract test passes. | Pester gate | |
| S23 | Mirrors and pack manifests match; push-down and generator checks pass | PASS | One blob id per source and copy (reviewer); push-down contract tests pass; Codex generator `--check` exit 0. | `git ls-files -s`; pytest gate; `python-static.2026-11-14T09-10.md` | |
| S24 | Frozen digests re-baselined after the final main merge | PASS | Reviewer SHA-256 of the committed surfaces equals the pinned values; `origin/main` has not moved since the merge `959b5f3e0`; `test_frozen_epic_surface_matches_pinned_baseline_digest` passes. | `git show HEAD:<path>` piped to `sha256sum`; pytest gate | Re-baselined after the #1156 merge |
| S25 | Existing contract tests pass; no hook change | PASS | All gates 0 failed; hook and settings diff empty. | Gates; `git diff --stat` | |
| U1 | Manifest key, kickoff rejection, documentation | PASS | S1 to S3. | as above | |
| U2 | Absent key unchanged | PASS | S5. | as above | |
| U3 | Pure decisions; mocked fail-closed adapters | PASS | S8 to S9. | as above | |
| U4 | Main-sync PR never accepted | PASS | S7. | as above | |
| U5 | Held feature no worktree; D4 merge; started-while-held flagged | PASS | S12, S14, S15. | as above | |
| U6 | External nodes on the critical path | PASS | S16 to S18. | as above | |
| U7 | Integration-to-main hold and completion gate | PASS | S20 and S21. | as above | |
| U8 | Surfaces, variants, bundles, contract tests | PASS | S22 to S25. | as above | |
| I1 to I6 | Issue criteria | PASS | Each maps to the spec group of the same Issue AC number, all PASS. | as above | |

---

## Summary

**Overall Feature Readiness:** READY for PR authoring. All 39 checkbox criteria evaluate PASS, and the two blocking findings of the prior review are closed.

**Criteria summary:**
- **PASS:** 39 criteria (25 spec, 8 user story, 6 issue)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. After the PR opens, the S9 gate confirms that the CI run on the PR head is green. No PR or CI run exists yet for this branch.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file if they are markdown checkboxes and not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 39 criteria were already checked and all evaluate PASS, so this review made no source-file change. No criterion depends solely on CI on the PR head, so none is listed as pending-CI. CI on the PR head remains the S9 gate's responsibility. The spec `## Definition of Done` checklist is not an AC source and is unchanged.

### AC Status Summary

- Source: `docs/features/active/2026-11-09-cross-epic-dependencies-1162/spec.md`, `docs/features/active/2026-11-09-cross-epic-dependencies-1162/user-story.md` (and the mirrored `issue.md` criteria)
- Total AC items: 39
- Checked off (delivered): 39
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-11-09-cross-epic-dependencies-1162/spec.md` | 25 | 25 | 0 | |
| `docs/features/active/2026-11-09-cross-epic-dependencies-1162/user-story.md` | 8 | 8 | 0 | |
| `docs/features/active/2026-11-09-cross-epic-dependencies-1162/issue.md` | 6 | 6 | 0 | Mirrored issue criteria |
