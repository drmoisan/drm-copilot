# Code Review: pytest-xdist and concurrent Pester test cycle (#1048), re-audit R4

---

**Review Date:** 2026-10-31
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048`
**Feature Folder Selection Rule:** Supplied by the caller; it is the only active feature folder changed on the branch and its suffix matches issue 1048 in the branch name.
**Base Branch:** `main` (merge base `58b81ca577943cd2944b62ee23ff3a3d1d737092`)
**Head Branch:** `feature/pytest-xdist-parallel-test-cycle-1048` at `522abaadee33779de6b687335bbd4f64f93033f8`
**Review Type:** Re-review after remediation cycle 1 (full branch diff in scope; cycle-1 delta verified by command)

---

## Executive Summary

Remediation cycle 1 changed one test file, `spec.md`, and evidence. `git diff 522abaade~1..522abaade --name-status` lists no production file and no bundle file. Production code, the workflow, and the bundles are byte-for-byte what the prior review (head `d817f4075`) examined, so the prior implementation assessment (no Blocker or Major defect) stands.

CR-1 (F1) is resolved: the two `.vscode/tasks.json` criteria now state a verifiable condition and are checked. CR-2 is resolved: PR10 and PR11 execute the two `-Root` fallback assignments, which the coverage artifact now reports as executed.

**Top risks:**
1. The CI effect is unmeasured: `-n auto` against `-n 4`, the shard spread after the weights change, and the green branch-head run need a pull request and are Pending-S9 (non-blocking, owned by orchestrator step 9).
2. `--strict-markers`, `--strict-config`, and `xfail_strict` now apply to every pytest run, including Python 3.10 to 3.12 legs that were exercised locally on one version; the CI matrix result is part of Pending-S9.
3. CR-3 (Info): children started before a failed start are not awaited.

**PR readiness recommendation:** **Ready for pull request creation** - no code defect blocks the PR; the CI-dependent items cannot exist before the PR is opened.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/spec.md` | `## Acceptance Criteria`, the `.vscode/tasks.json` items in Part 1 and Part 2 | CR-1 (= F1) resolved. The `spec.md` diff replaces only the clause "passes governed-JSON validation" in the two items with the JSONC-parse condition and changes the two checkboxes from `[ ]` to `[x]`. The fresh JSONC parse reports 55 tasks and all five labels, matching `evidence/other/spec-ac-jsonc-amendment.2026-10-31T21-19.md`. | No action. | The amended criteria are verifiable by command and were verified in this review. | `git diff 522abaade~1..522abaade -- spec.md`; JSONC parse of `.vscode/tasks.json`. |
| Info | `tests/scripts/powershell/PoshQC/PoshQC.ParallelRunner.Tests.ps1` | PR10 and PR11 | CR-2 resolved. PR10 removes the `Root` seam and asserts the shard argument and shard directory use the current location; PR11 passes `relative-root` and asserts the resolved full path. Both use `NewState` and `NewSeams`, mock no new function, and restore the location in `finally`. The file has no `Start-Process`, `Start-Sleep`, `TestDrive`, or temp-path call. JaCoCo lines 408 and 411 read `ci="1"`; `PoshQC.Parallel.psm1` is 97.33% (146 of 150), above the 97% bar. | No action. | Closes the untested path normalization at no cost in determinism. | Diff; test file search; `artifacts/pester/powershell-coverage.xml`. |
| Info | `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` | `Invoke-PoshQCParallelTest`, start loop | CR-3 (carried, unchanged). A throw from `ResetShardDirectory` or `StartShardProcess` for shard k leaves earlier children running without a wait. | Optional. | Merged artifacts are never written on this path. | Function body. |
| Info | `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` | `Invoke-PoshQCPwshExe` | CR-4 (carried, deviation D2). The wrapper body is four executable lines that unit tests cannot run under the repository purity rule. | No action. | Lines stay in the coverage denominator; no exclusion. | JaCoCo lines 263, 264, 266, 267. |
| Info | `.github/workflows/_quality-checks.yml` | `Run tests with Pytest` | CR-5 (carried, unchanged). The step gains only `-n auto`; the file is not in the cycle-1 delta. | Measure against `-n 4` at step 9. | The modified workflow needs a green branch-head run. | `git diff --name-status`. |

No Blocker, Major, or Minor findings. No covered file is at or above 700 logical lines (the cycle-1 test file is 302), so no file-size Warning applies.

---

## Implementation Audit

### Python implementation audit

No Python file changed in cycle 1. The prior audit of `pyproject.toml`, `poetry.lock`, and the four test files stands (head `d817f4075` content is unchanged at `522abaade`).

### PowerShell implementation audit

#### What changed well

- PR10 and PR11 read the expected root from `Get-Location` inside the same `Push-Location` block that the code under test uses, so the expectation cannot drift from the process location.
- PR10 asserts both the shard command argument (`-Root '<expected>'`) and the reset directory prefix `artifacts/pester/parallel`, which covers the two consumers of the resolved root.
- No production PowerShell, bundle, README, or manifest file was modified.

#### API and safety notes

- No exported function or parameter changed.

#### Error handling and logging

- Unchanged.

---

## Test Quality Audit

PR10 and PR11 follow Arrange, Act, Assert and carry case ids in their names. The shuffled-order record (seeds 7, 1048, 20261031; 237 passed, 0 failed each) and the PoshQC folder run (229 tests, 0 failures) show no ordering dependence from the two cases that change the process location, because the location is restored in `finally`.

### Reviewed test and QA artifacts

- `tests/scripts/powershell/PoshQC/PoshQC.ParallelRunner.Tests.ps1`
- `evidence/qa-gates/pester-poshqc.2026-10-31T21-31.md`, `evidence/regression-testing/pester-shuffle.2026-10-31T21-31.md`, `evidence/regression-testing/pester-single-process.2026-10-31T21-31.md`
- `evidence/other/cr2-production-unchanged.2026-10-31T21-31.md`, `evidence/other/cr2-test-disposition.2026-10-31T21-31.md`

### Quality assessment prompts

- **Determinism:** No clock, RNG, environment variable, temp file, or process.
- **Isolation:** The location change is scoped by `try`/`finally`.
- **Speed:** Both cases run without a process start.
- **Diagnostics:** PR10 carries a `-Because` text.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Cycle-1 diff inspected. |
| No unsafe subprocess or command construction | PASS | No production change. |
| Input validation at boundaries | PASS | No production change. |
| Error handling remains explicit | PASS | No production change. |
| Configuration / path handling is safe | PASS | PR10 and PR11 now pin the root normalization behavior. |

---

## Research Log

No external research was required. Evidence came from the cycle-1 diff, the JaCoCo artifact, the persisted QA records, and a JSONC parse of `.vscode/tasks.json`.

---

## Verdict

The implementation and the remediation meet the spec's behavior and the repository's design, seam, coverage, and determinism rules. F1 and CR-2 are resolved and no new defect was found. The CI-dependent measurements and the branch-head green run remain with orchestrator step 9.
