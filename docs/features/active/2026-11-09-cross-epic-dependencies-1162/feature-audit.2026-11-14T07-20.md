# Feature Audit: cross-epic-dependencies (#1162)

**Audit Date:** 2026-11-14
**Feature Folder:** `docs/features/active/2026-11-09-cross-epic-dependencies-1162`
**Base Branch:** `main`
**Head Branch:** `feature/cross-epic-dependencies-1162`
**Work Mode:** `full-feature`
**Audit Type:** Initial feature review (S7)

---

## Scope and Baseline

- **Base branch:** `main` (commit `2c8dee6dd3a82f210561d9efe623767ae902de51`, equal to `origin/main` after a fetch at review time)
- **Head branch/commit:** `feature/cross-epic-dependencies-1162` (commit `73ecccd13b3f8f7601de848136eca93fdafaa328`, clean worktree)
- **Merge base:** `2c8dee6dd3a82f210561d9efe623767ae902de51`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-14 07:09:32 UTC at head `73ecccd13`, range `2c8dee6dd..73ecccd13`), cross-checked with `git diff 2c8dee6dd..73ecccd13` (117 files)
  - Secondary: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/baseline/` (Phase 0), `evidence/qa-gates/` (final gates 2026-11-14T05-53 to 07-04), `evidence/other/` (task checks, main syncs, preflight fixes, frozen digests, no-hook-change listing)
  - Reviewer evidence: `evidence/qa-gates/jest-root-gate.2026-11-14T07-12.md`, `evidence/qa-gates/pester-reviewer-gate.2026-11-14T07-32.md`, real-git stale-ref probe (SCRATCH)
- **Feature folder used:** `docs/features/active/2026-11-09-cross-epic-dependencies-1162`
- **Requirements source:** `spec.md` and `user-story.md`; `issue.md` also carries six mirrored checkbox criteria
- **Work mode resolution note:** `issue.md` line 9 carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the authoritative sources. The caller also named `issue.md`; its six criteria mirror Issue AC1 to AC6 and are evaluated through the spec criteria grouped under each. The spec `## Definition of Done` checkboxes are a template checklist, not acceptance criteria, and are left unchanged.
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
| S1 | Skill section, `## Epic Dependency Manifest` reference, `.agents` manifest contract | PASS | `## Cross-Epic Dependencies (cross_epic_depends_on)` at SKILL.md line 410 carries syntax, codes, both tables, D4, D7, D8, D10, and D5. `cross-epic-skill-contract.Tests.ps1` passes in the executor and reviewer Pester gates. | Reviewer read of the section; Pester gates | F2 concerns the D7 paragraph's missing status mapping, not the presence the criterion requires |
| S2 | Both epic templates document the key and stay byte-identical | PASS | Both templates have blob `e62c74c34`; `DocumentationEstateEpicTemplate.Tests.ps1` passes unchanged. | `git ls-files -s` of both templates | |
| S3 | Each manifest code and CLI exit 1 | PASS | `EpicCrossDependency.Tests.ps1` and `Invoke-EpicCrossReadiness.Tests.ps1` pass; reviewer read of `Get-EpicCrossDependencyManifestError` finds all nine codes. | Pester gates | |
| S4 | MALFORMED parity in Python and TypeScript, both checkpoints | PASS | `test_epic_cross_dependency_validation.py` and `test_epic_cross_dependency_parity_corpus.py` pass (pytest 16815 passed); `epic-orchestrator-state-cross-dependency.test.ts` passes (root Jest 5641 passed). | pytest and Jest gates | |
| S5 | Absent key behaves as before | PASS | Existing epic validator, wave, wave-barrier, and progress-report suites pass; every new check is key-gated in code. | Pester, pytest, Jest gates | |
| S6 | D11 match rules incl. longer-token negative | PASS | `Get-EpicCrossDependencyPrerequisitePr` applies exclusion, file rule, token rule (`-ccontains` on exact tokens), and dedupe; tests pass. | Pester gates; code reading | |
| S7 | Main-sync PR not matched | PASS | Dedicated test in `EpicCrossDependency.Tests.ps1` passes. | Pester gates | |
| S8 | Every row of both decision tables | PASS | Table-driven tests pass; the reviewer checked `Get-EpicCrossDependencyEdgeDecision` against spec rows 1 to 7 and the main-gate rows 1 to 5. | Pester gates; code reading | Pure functions are correct; F1 is in the gather step, not in these functions |
| S9 | Pure functions perform no I/O; adapter tests assert argument arrays and fail closed | PASS | Only `Invoke-EpicCrossGhExe` and `Invoke-EpicCrossGitExe` start processes; adapter suite passes. | Pester gates; code reading | F1: adapter suite does not model a stale remote-tracking ref |
| S10 | CLI contract and bounded wait through seams | PASS | `Invoke-EpicCrossReadiness.Tests.ps1` passes; the loop gives 10 evaluations and 9 injected sleeps at 540. | Pester gates; code reading | |
| S11 | Two new files at or above 85% lines; PoshQC gates clean | PASS | `EpicCrossDependency.psm1` 98.03%, `Invoke-EpicCrossReadiness.ps1` 100% (executor gate; reconfirmed in the reviewer run); format, analyzer, and leak scan 0 findings. | `pester.2026-11-14T06-55.md`, `pester-reviewer-gate.2026-11-14T07-32.md`, `powershell-static.2026-11-14T06-41.md` | |
| S12 | Launch hold and D4 procedure in skill and agent | PASS | Skill lines 440 to 468 and the agent `## Wave Scheduling` text; contract test passes. | Pester gates | F1 makes the stated `PREREQ_IN_MAIN` path unreachable when a stale ref exists; the text itself is present |
| S13 | Bash grant and Codex procedure; permission and citation tests | PASS | Grant present; `test_epic_orchestrator_permission_contracts.py` and `test_epic_skill_script_citations_shipped.py` pass in the pytest gate. | pytest gate | |
| S14 | Started-while-held in three runtimes; fail-closed import | PASS | Python, TypeScript, and PowerShell implementations emit the exact string; parity suites pass. | Pester, pytest, Jest gates | |
| S15 | D7 records and D10 line documented | PASS | Records paragraph and D10 line present in epic-orchestrate; `not merged` line in epic-plan; contract and validation tests pass. | Pester and pytest gates | F2: the records paragraph lacks the reason-to-status mapping (blocking finding, outside the literal criterion text) |
| S16 | External nodes from checkpoint rows and the raw manifest value | PASS | `Get-EpicProgressReport.CrossEpic.Tests.ps1` passes; part file at 100% lines. | Pester gates | |
| S17 | Cap exclusion; byte-identical schedule without external nodes | PASS | Schedule and CriticalPath suites pass. | Pester gates | |
| S18 | Rendering of external nodes and the `Cross-epic:` line | PASS | Render.CriticalPath and CrossEpic suites pass. | Pester gates | |
| S19 | Progress-report skill rule pinned; part file at or above 85% | PASS | `EpicProgressReport.SkillContract.Tests.ps1` passes; part file 100%. | Pester gates | |
| S20 | Main hold in skill and agent incl. D5 disclosure | PASS | Skill lines 475 to 506; contract test passes. | Pester gates | |
| S21 | Completion invariant in Python and TypeScript | PASS | `validate_cross_epic_main_gate` and the TypeScript twin; tests pass. | pytest and Jest gates | |
| S22 | Planner-side surfaces | PASS | Sections present in the six named files; contract test passes. | Pester gates | |
| S23 | Mirrors and pack manifests match; push-down and generator checks pass | PASS | One blob id per source and copy for all 16 Claude pairs and both Codex stored copies; push-down contract tests pass in the pytest gate. | `git ls-files -s`; pytest gate | |
| S24 | Frozen digests re-baselined after the final main merge | PASS | `parallel_orchestrator_surface_expectations.py` carries the `# RE-BASELINED by issue #1162.` paragraph; `test_frozen_epic_surface_matches_pinned_baseline_digest` passes; `origin/main` has not moved since. | pytest gate; `git rev-parse origin/main` | The F2 fix will require another re-baseline |
| S25 | Existing contract tests pass; no hook change | PASS | Gates 0 failed; `git diff --stat` of `.claude/hooks` and `.claude/settings.json` is empty. | Gates; `git diff` | |
| U1 | Manifest key, kickoff rejection, documentation | PASS | S1 to S3. | as above | |
| U2 | Absent key unchanged | PASS | S5. | as above | |
| U3 | Pure decisions; mocked fail-closed adapters | PASS | S8 to S9. | as above | F1 noted |
| U4 | Main-sync PR never accepted | PASS | S7. | as above | |
| U5 | Held feature no worktree; D4 merge; started-while-held flagged | PASS | S12 and S14. | as above | F1 and F2 noted |
| U6 | External nodes on the critical path | PASS | S16 to S18. | as above | |
| U7 | Integration-to-main hold and completion gate | PASS | S20 and S21. | as above | |
| U8 | Surfaces, variants, bundles, contract tests | PASS | S22 to S25. | as above | |
| I1 to I6 | Issue criteria | PASS | Each maps to the spec group of the same Issue AC number, all PASS. | as above | |

---

## Summary

**Overall Feature Readiness:** NOT READY. All 39 checkbox criteria evaluate PASS, but two blocking findings fall outside the literal criterion text.

**Criteria summary:**
- **PASS:** 39 criteria (25 spec, 8 user story, 6 issue)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. F1: the readiness CLI fetches without pruning. A deleted prerequisite integration branch is still read through its stale remote-tracking ref, so spec row 2 (`PREREQ_IN_MAIN`) and the D4 "no extra merge" path cannot be reached in that state (spec `## Alternate and edge flows`, third bullet).
2. F2: the D7 records paragraph names four statuses but no reason-to-status mapping. The started-while-held invariant rejects `released` on a launched feature.

**Recommended follow-up verification steps:**

1. After the fix, run the adapter suite with a stale-ref case and the contract test with the mapping sentence, then repeat the final gates and the frozen-digest re-baseline.
2. After the PR opens, confirm the CI run on the PR head is green; no CI run exists yet for this branch.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file if they are markdown checkboxes and not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 39 criteria were already checked by the executor and all evaluate PASS, so this review made no source-file change. No criterion depends solely on CI; none is listed as pending-CI. The spec `## Definition of Done` checklist is not an AC source and is unchanged.

### AC Status Summary

- Source: `docs/features/active/2026-11-09-cross-epic-dependencies-1162/spec.md`, `docs/features/active/2026-11-09-cross-epic-dependencies-1162/user-story.md` (and the mirrored `issue.md` criteria)
- Total AC items: 39
- Checked off (delivered): 39
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-11-09-cross-epic-dependencies-1162/spec.md` | 25 | 25 | 0 | F1 and F2 are blocking findings outside the literal criterion text |
| `docs/features/active/2026-11-09-cross-epic-dependencies-1162/user-story.md` | 8 | 8 | 0 | |
| `docs/features/active/2026-11-09-cross-epic-dependencies-1162/issue.md` | 6 | 6 | 0 | Mirrored issue criteria |
