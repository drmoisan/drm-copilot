# Policy Audit - Issue #756

- Branch: bug/cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756
- Base: origin/main @ 08ee030d9584bf15882fbb3654c8e38f34c7c359 (merge-base); head c9d082f1385177d7a8c47c1f0556d2e7e293ed0d
- Scope: full branch diff against base (74 files: 1 spec edit, 1 bats file, 29 fixture files, remainder feature-folder documentation and evidence)
- Work mode: minor-audit

## Executive Summary

The branch adds eight bats tests, 29 scenario fixture files, and one spec edit. No production source changed. Every applicable policy is satisfied. The fail-before requirement is met by an accepted exception because the tests pin pre-existing behavior. Shell checks and bats were verified through CI run 37716284664 and not locally (operator decision). Overall verdict: PASS with advisory items (see `remediation-inputs.2026-10-07T22-17.md`). No FAIL findings.

## Rejected Scope Narrowing

None. The caller prompt did not narrow scope. The statement that local bats and shell-qc were not run per operator decision is an evidence-availability fact, not a scope narrowing, and is assessed in sections 6 and 7.

## Evidence Location Compliance

PASS. `git diff origin/main...HEAD --name-only` contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence lives under `<FEATURE>/evidence/{baseline,qa-gates,regression-testing,other}/`. `validate_evidence_locations.py` is not present at `scripts/validate_evidence_locations.py` in this worktree; the manual path scan above substitutes for it. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred.

## 1. General Unit Test Policy Compliance

| Policy | Verdict | Evidence |
|---|---|---|
| Tests under `tests/` mirror layout | PASS | New tests extend the existing `tests/shell/` bats file; fixtures are under `tests/fixtures/cleanup_worktrees/scenarios/`. |
| No temp files | PASS | New tests use checked-in scenario fixtures and the git/scan stubs only. |
| Determinism, no sleeps or wall clock | PASS | No `sleep`, `date`, or timer use in the added lines. |
| Scenario completeness for targeted paths | PASS | Pairwise hard failure (rc 2, records unchanged), scan failure, stale-ref failure with higher and lower rc, and three rc-maximization orderings. |
| Fail-before evidence | PARTIAL | Tests pin pre-existing behavior, so a failing pre-change run is impossible. `fail-before-exception.2026-09-30T03-38.md` provides a control-scenario diff and an analytic mutation argument; mutations were not executed. Accepted as an exception. |
| Protected test surface untouched | PASS | `final-protected-test-surface-diff` is empty; the diff contains only added `child_of_pairwise_probe_error` and `report_scans_*` fixtures and the report-records bats file. |

### 1.1 Test File Location

`tests/shell/test_cleanup_worktrees_report_records.bats` mirrors the shell test layout. No test file was placed under a production source tree.

### 1.2 Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A, no TypeScript files changed in the branch diff
- TypeScript post-change coverage artifact: N/A, no TypeScript files changed in the branch diff
- PowerShell baseline coverage artifact: N/A, no PowerShell files changed in the branch diff
- PowerShell post-change coverage artifact: N/A, no PowerShell files changed in the branch diff
- Per-language comparison summary: only Bash has changed files; Bash comparison recorded in section 1.2.1 from the CI kcov artifacts (CI run 37716284664). TypeScript, PowerShell, and Python are not applicable because they have zero changed files.

### 1.2.1 Per-Language Coverage Comparison

- Bash: Baseline: 87.9% (library `cleanup_worktrees_report_records_lib.sh`) and 93.8% overall; Post-change: 95.2% library and 94.2% overall; Change: +7.3 points library, +0.4 points overall, no regression; Disposition: PASS; Evidence: CI run 37716284664, artifact `shell-coverage` (`kcov-final-756/cov.xml`) against baseline `kcov-baseline-756` (run 37645267440 at merge-base).

## 2. General Code Change Policy Compliance

| Policy | Verdict | Evidence |
|---|---|---|
| No production change beyond scope | PASS | `final-production-diff` records EMPTY for `.claude extensions scripts`; the branch name-status shows no path under those roots. |
| 500-line file limit | PASS | `tests/shell/test_cleanup_worktrees_report_records.bats` is 225 lines. |
| Tonality | PASS | Documents reviewed use factual wording. |
| Bundled-mirror rule (AC-6) | PASS | No `.claude/` production file changed, so no `extensions/.../claude-customizations` mirror update is required; #741 scope not absorbed (`cleanup_wt_scan_roots` count unchanged per `final-bats-scan-roots-references`). |

## 3. Language-Specific Code Change Policy Compliance

Bash (shell): the only changed executable-language file is the bats test file; no production shell source changed. Format and lint verdicts are recorded in section 7.
- TypeScript: N/A, zero changed files.
- PowerShell: N/A, zero changed files.
- Python: N/A, zero changed files.
- C#: N/A, zero changed files.

## 4. Language-Specific Unit Test Policy Compliance

Bash (bats): PASS. The eight new tests are independent, use fixtures and stubs, assert specific return codes and record contents, and run without external services. TypeScript, PowerShell, Python, and C# are N/A because they have zero changed files.

## 5. Test Coverage Detail

Languages with changed files: Bash (test and fixture files only; no production source). TypeScript, Python, PowerShell, and C# have zero changed files.

### 5.1 Coverage Metrics

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| TypeScript | 0 | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A (no changed files) |
| PowerShell | 0 | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A (no changed files) |
| Python | 0 | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A (no changed files) |
| Bash | 31 (1 bats file, 29 fixtures, 1 spec edit counted under documentation) | 8 new | PASS (CI) | 87.9% library, 93.8% overall | 95.2% library, 94.2% overall | N/A (no new executable production lines) |

### 5.2 Coverage Verification Detail

| Item | Result | Verdict |
|---|---|---|
| Bash overall line-rate (kcov, CI artifact `shell-coverage`, run 37716284664) | 94.2% (threshold 85%); baseline 93.8% from `kcov-baseline-756`, run 37645267440 at merge-base | PASS |
| Library `cleanup_worktrees_report_records_lib.sh` | 95.2% versus baseline 87.9%; not reduced | PASS |
| New files | Fixture data files only; no executable lines | PASS |
| Modified files | No production file modified; the bats file is test code outside the denominator | PASS |
| Changed-line hits | `final-ci-kcov-line-hits`: lines 290, 292, 296, 300, 304, 425 each hit 1; line numbers match the current library statements (read at lines 285-306 and 424-426) | PASS |

Branch coverage: kcov does not measure bash branches; exempt per policy. The cov.xml `<line>` rows are empty in this run, so per-line hits were taken from the kcov `.js` data in the same artifact. The evidence records this deviation; the verdict is unchanged.

## 6. Test Execution Metrics

| Stage | Verdict | Evidence |
|---|---|---|
| Unit tests (bats) | PASS (CI) | Run 37716284664 (workflow_dispatch, headSha 4f960432, conclusion success, confirmed with `gh run view`): step "Run shell-qc test with coverage" success; TAP ok 452-459 for the 8 new tests; zero `not ok`. |

Caveat: the verifying CI run targets head 4f960432, not c9d082f1. Per `final-ci-run`, commits after it change documentation under `docs/features/active/` only, and the diff list shows no non-document change beyond the test commit. No pull request exists yet, so no `pull_request` run is available.

## 7. Code Quality Checks

| Stage | Verdict | Evidence |
|---|---|---|
| Format and lint (shfmt diff, shellcheck) | PASS (CI) | Run 37716284664: step "Run shell-qc check" success. Not run locally (operator decision; EFC recorded). |
| Type check, architecture, contract, integration | N/A | No applicable stage for bash; no changed files in other languages. |
| Coverage exclusion policy | PASS | No `exclude` entries added; no coverage configuration in the diff. |

## 8. Gaps and Exceptions

1. Fail-before exception: accepted; see section 1 and `fail-before-exception.2026-09-30T03-38.md`.
2. CI evidence is from a `workflow_dispatch` run on head 4f960432, not the final head; later commits are documentation only.
3. Local bats and shell-qc were not executed (operator decision).
4. Advisory code-review items CR-756-01 through CR-756-04 are listed in `code-review.2026-10-07T22-17.md`.

## 9. Summary of Changes

- `docs/features/completed/` #631 `spec.md`: two statements rewritten to the invariant-section contract for a pairwise hard failure.
- `tests/shell/test_cleanup_worktrees_report_records.bats`: +93 lines, 8 new tests.
- 29 fixture files under `tests/fixtures/cleanup_worktrees/scenarios/`.
- Feature-folder documentation and evidence for issue #756.

## 10. Compliance Verdict

PASS with advisory items. No FAIL findings; no blocking findings. Remediation inputs contain advisory items only.

## Appendix A: Test Inventory

| Test group | Count | Fixtures |
|---|---|---|
| Pairwise probe hard failure (rc 2, records unchanged, verdict unchanged) | 2 | `child_of_pairwise_probe_error` |
| `run_report_scans` failure paths (rc 3, rc 5, rc 4) | 3 | `report_scans_*` |
| `run_report_scans` rc maximization (7/0, 7/9, 9/7) | 3 | `report_scans_*` |

## Appendix B: Toolchain Commands Reference

- Format and lint: CI step "Run shell-qc check" (shfmt diff, shellcheck).
- Tests with coverage: CI step "Run shell-qc test with coverage" (bats under kcov).
- Run lookup: `gh run view 37716284664`.
- Evidence location scan: `git diff origin/main...HEAD --name-only`.
