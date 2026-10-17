# Policy Audit - Issue #842

- Timestamp: 2026-10-10T10-10
- Branch: bug/cleanup-worktrees-scan-root-derivation-follow-ups-842
- Diff base: 179c586676d0f942043e349f7666852c551f25fb..HEAD (996a010dc)
- Work mode: minor-audit (issue.md `## Acceptance Criteria`, AC-1..AC-7)
- Changed non-doc files: 3 shell scripts, 3 bundle mirrors, 2 fixtures, 1 bats suite (9 files)

## Rejected Scope Narrowing

None. The caller did not narrow scope. The caller marked AC-7, P2-T17 and P2-T18 as pending-CI; that is recorded as a pending status in feature-audit, not as a scope exclusion.

## Executive Summary

Overall verdict: PASS for all locally verifiable policies; bash line coverage post-change is pending the PR CI kcov run (P2-T17), which is the known and expected pending state and is not a blocking finding.

- Blocking findings: none.
- The only production change is one executable guard line (`cleanup_wt_is_absolute_path "$parent" || continue`, enumerate_lib.sh:352) plus two comment-only edits. Three bundle mirrors are byte-identical to their sources.
- Local gates: shfmt exit 0, shellcheck exit 0, bats 85/85 ok, bundle-parity pytest 14 passed, `validate_evidence_locations.py --root .` exit 0.
- Changed language: bash only. TypeScript, Python, PowerShell, and C# have zero changed files.

## 1. General Unit Test Policy Compliance

| Policy | Verdict | Evidence |
|---|---|---|
| Arrange-Act-Assert, independence, determinism | PASS | Five new tests use git stub fixtures; no clock, RNG, sleep, or network. |
| No temporary files | PASS | New tests use checked-in fixtures; no mktemp or temp writes. |
| Test location | PASS | Changes are under tests/shell/ and tests/fixtures/ only; no colocation. |
| Scenario completeness | PASS | Positive (D:/other retained), negative (D: dropped), backslash conversion, default-pair dedupe, and run_report single-scan call are covered. |

### 1.1 Test Result Summary

Local bats run: 85/85 ok (baseline 80 plus 5 new). Tests 17-19 fail before the fix and pass after; tests 20-21 characterize existing correct behavior.

### 1.2 Coverage Requirements

Thresholds: line coverage >= 85%; no branch threshold applies to bash (kcov does not measure branch coverage). Production files remain in the coverage denominator.

- TypeScript baseline coverage artifact: N/A (zero TypeScript files changed in the branch diff)
- TypeScript post-change coverage artifact: N/A (zero TypeScript files changed in the branch diff)
- PowerShell baseline coverage artifact: N/A (zero PowerShell files changed in the branch diff)
- PowerShell post-change coverage artifact: N/A (zero PowerShell files changed in the branch diff)
- Per-language comparison summary: Shell (bash) is INCOMPLETE pending the CI kcov run (P2-T17); TypeScript, PowerShell, Python, and C# are N/A with zero changed files.

### 1.2.1 Per-Language Coverage Comparison

- Shell (bash): Baseline: 94.2% kcov aggregate (enumerate library line-rate 0.953); Post-change: pending CI P2-T17, gate floor 85%; Change: not yet measurable, one executable line added and it is exercised by tests ok 17, 18, 19; New/changed-code coverage: 100% by inspection (1 of 1 added executable line, kcov confirmation pending); Disposition: INCOMPLETE; Evidence: evidence/baseline/shell-coverage-main.2026-10-10T09-35.md

## 2. General Code Change Policy Compliance

| Policy | Verdict | Evidence |
|---|---|---|
| Simplicity, separation of concerns | PASS | One-line guard reuses the existing shared predicate `cleanup_wt_is_absolute_path` at cleanup_worktrees_enumerate_lib.sh:352. |
| 500-line cap | PASS | enumerate_lib 418, scan_helper 173, detached_lib 301, scan_roots bats 314 (wc -l re-run in this review). |
| Error handling | PASS | A non-absolute candidate is dropped by design (issue.md Assumptions); no silent catch-all introduced. |
| Mirror byte-identity (three pairs) | PASS | `cmp` re-run in this review: identical for detached_lib, enumerate_lib, scan_helper. Bundle-parity pytest: 14 passed. |
| Tonality | PASS | Artifacts reviewed use factual wording. |

## 3. Language-Specific Code Change Policy Compliance

Language: bash (shell rules).

| Policy | Verdict | Evidence |
|---|---|---|
| SC1091 suppression states its reason | PASS | scan_helper.sh:43-44 comment precedes the directives at lines 45-46. |
| shfmt | PASS | evidence/qa-gates/shfmt.2026-10-10T09-52.md: exit 0, no output. |
| shellcheck | PASS | evidence/qa-gates/shellcheck.2026-10-10T09-52.md: exit 0, no output. |

## 4. Language-Specific Unit Test Policy Compliance

| Policy | Verdict | Evidence |
|---|---|---|
| bats suite structure and helpers | PASS | The `derive_run` helper matches the existing `roots_run` and `report_run` helpers; stderr is discarded through a brace group. |
| Fixtures checked in, no temp files | PASS | Two fixtures under tests/fixtures/. |
| Expect-fail before fix | PASS | Evidence under evidence/regression-testing shows tests 17-19 fail before and pass after. |

## 5. Test Coverage Detail

### 5.1 Coverage Metrics

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| TypeScript | 0 | N/A | N/A | N/A | N/A | N/A |
| PowerShell | 0 | N/A | N/A | N/A | N/A | N/A |
| Python | 0 | N/A (parity check only) | PASS | N/A | N/A | N/A |
| C# | 0 | N/A | N/A | N/A | N/A | N/A |
| Shell (bash) | 6 | 85 bats (5 new) | PASS | 94.2% kcov aggregate; 0.953 enumerate library | N/A (pending CI P2-T17) | 100% by inspection (1 of 1 added executable line) |

### 5.2 Notes

- Local artifact: no pre-existing kcov artifact for this branch exists in the worktree. kcov runs only in CI (`_shell-coverage.yml`).
- Baseline (main run 38054308295, evidence/baseline/shell-coverage-main.2026-10-10T09-35.md): aggregate 94.2%, enumerate_lib line-rate 0.953, scan_helper 0.873, detached_lib 1.000; all at or above 85%.
- Branch effect: the only production change is one new executable line (enumerate_lib.sh:352), exercised by three new tests (ok 17, 18, 19). The two other script edits are comments only, so no regression is possible on those lines.
- The artifact `evidence/qa-gates/shell-coverage-pr-run.TS.md` does not yet exist; it is produced under P2-T17.

## 6. Test Execution Metrics

- bats (targeted suite): 85/85 ok; ran as a background task because it exceeded 120 s.
- Bundle-parity pytest: 14 passed.
- shfmt: exit 0. shellcheck: exit 0.

## 7. Code Quality Checks

- Evidence Location Compliance: PASS. `validate_evidence_locations.py --root .` exit 0. No file in the diff is under artifacts/baselines, artifacts/qa, artifacts/evidence, or artifacts/coverage; all evidence is under FEATURE/evidence/<kind>/. No EVIDENCE_LOCATION_OVERRIDE_REJECTED events.
- Working tree cleanliness: PASS. `git status --short` is empty.
- Plan checklist: 41 checked, 2 unchecked (P2-T17, P2-T18). The 39/4 state recorded in plan-checklist-state.2026-10-10T09-58.md predates the checking of P2-T15 and P2-T16; current counts are consistent with that sequence.
- Every checked task has an artifact on disk (baseline 11, other, qa-gates 8, regression-testing 2). Handoff index paths all resolve to files listed in the diff.

## 8. Gaps and Exceptions

No blocking gaps. Non-blocking evidence observations:

- structural-checks records top-level EXIT_CODE 1 with ExpectedExitCode 1, which is the last grep's exit status. Individual results are enumerated and match.
- qa-gates/mirror-identity notes the pre-commit listing was not observable; scope.2026-10-10T09-56.md covers this against the merge base.

Pending (not blocking): AC-7 requires P2-T17 (kcov post-push) and P2-T18 (check-off), which need the PR and a CI run.

## 9. Summary of Changes

- cleanup_worktrees_enumerate_lib.sh: one guard line and a comment (M-3).
- cleanup_worktrees_scan_helper.sh: inline reason for the SC1091 suppression (M-2).
- cleanup_worktrees_detached_lib.sh: stale line-range reference replaced by a function reference (M-1).
- Three bundle mirrors updated to remain byte-identical.
- Two fixtures and five bats tests added (N-1 and M-3 coverage).

## 10. Compliance Verdict

PASS. No blocking findings and no remediation required. Bash post-change line coverage is pending the CI kcov run (P2-T17); the baseline is 94.2% and the changed executable line is covered by tests 17-19.

## Appendix A: Test Inventory

| Test | bats result | Purpose |
|---|---|---|
| ok 17 | PASS | derive_scan_roots drops a drive-relative parent (M-3, derive layer) |
| ok 18 | PASS | scan_roots emits no `D:` root for a `D:/wt` registration (M-3, scan_roots layer) |
| ok 19 | PASS | run_report performs a single scan with the exact argv (M-3, run_report layer) |
| ok 20 | PASS | backslash registration path converts to a forward-slash root (N-1) |
| ok 21 | PASS | backslash conversion on the combined root list, default-pair dedupe (N-1) |

## Appendix B: Toolchain Commands Reference

- Format: shfmt (evidence/qa-gates/shfmt.2026-10-10T09-52.md)
- Lint: shellcheck (evidence/qa-gates/shellcheck.2026-10-10T09-52.md)
- Unit tests: bats targeted suite under tests/shell/
- Mirror identity: `cmp` on the three source/bundle pairs; bundle-parity pytest
- Evidence locations: `validate_evidence_locations.py --root .`
- Coverage: kcov in CI only (`_shell-coverage.yml`)
