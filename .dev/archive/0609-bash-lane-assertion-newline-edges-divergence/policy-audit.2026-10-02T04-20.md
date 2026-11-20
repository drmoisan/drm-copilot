# Policy Compliance Audit: bash lane assertion newline edges divergence (#609)

---

**Audit Date:** 2026-10-02
**Review pass:** 2 (corrected structure; supersedes `policy-audit.2026-10-02T04-00.md`, `policy-audit.2026-10-01T23-21.md`)
**Branch:** `bug/bash-lane-assertion-newline-edges-divergence-609` (PR #815)
**Local HEAD at review time:** `c9f006ad5f1fb3eea4233895bb9bd722e18535a5`
**Base:** `origin/main` at merge-base `1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9` (origin/main equals the merge-base; the branch is up to date)
**Work mode:** `full-bug` (AC source: `spec.md`)
**Code Under Test:** `.claude/lib/bash/parallel-lane-assertion.sh` and its bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-lane-assertion.sh`; `tests/shell/parallel_lane_assertion.bats`; `tests/fixtures/parallel_lane_assertion/edges_newline_separated.json`. The remaining 47 of 51 changed files are Markdown feature-folder documents and evidence.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Bash | 2 library files (canonical plus byte-identical mirror), 1 bats file, 1 JSON fixture | 507 bats tests (6 added); 83 pytest in the three planned files | PASS: bats `1..507` with no `not ok`; pytest 83 passed | 98.9% lines per-file (`parallel-lane-assertion.sh`, main run 36958806659) | 98.9% lines per-file (PR head run 36960736942); 93.7% lines merged repo-wide (run 36960130609) | 100% lines (changed line 88 `hits="1"`) |
| Python | 0 files | N/A | N/A | N/A (no Python files changed) | N/A (no Python files changed) | N/A |
| TypeScript | 0 files | N/A | N/A | N/A (no TypeScript files changed) | N/A (no TypeScript files changed) | N/A |
| PowerShell | 0 files | N/A | N/A | N/A (no PowerShell files changed) | N/A (no PowerShell files changed) | N/A |
| C# | 0 files | N/A | N/A | N/A (no C# files changed) | N/A (no C# files changed) | N/A |
| Markdown | 47 files | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: not applicable, no TypeScript in scope (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: not applicable, no TypeScript in scope (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: not applicable, no PowerShell in scope (zero PowerShell files changed on the branch)
- PowerShell post-change coverage artifact: not applicable, no PowerShell in scope (zero PowerShell files changed on the branch)
- Bash baseline coverage artifact: `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/qa-gates/ci-per-file-coverage.2026-10-02T03-44.md` (main run 36958806659, `line-rate` 0.989)
- Bash post-change coverage artifact: `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/qa-gates/ci-per-file-coverage.2026-10-02T03-44.md` and `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/qa-gates/ci-shell-coverage.2026-10-02T03-40.md`
- Per-language comparison summary: Section 1.2.1 of this document

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is absent, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** Do not synthesize or backfill audit evidence from memory or inference. If evidence is absent, stop and list the exact artifact paths.

---

## Executive Summary

The branch fixes a divergence in `pla_parse_edges` (line 88 of `.claude/lib/bash/parallel-lane-assertion.sh`): `read -ra tokens` consumed only the first newline-terminated record and did not treat CR, VT, or FF as separators, so bash and the Python authority produced different headers for newline-separated edge text. The fix replaces newline, CR, VT, and FF with spaces before `read`. The branch adds six `edges-parity:` bats cases, one JSON corpus fixture, and the byte-identical bundled mirror.

Verdict: PASS. Blocking findings: 0. The pass-1 coverage FAIL (pending CI) is closed by CI evidence: job `shell-coverage` is green, bats `1..507` shows no `not ok`, per-file line-rate is 0.989 against a 0.989 baseline, merged coverage is 93.7%, and the changed line is executed. The fail-first run at commit `1524e2d2` shows the four expected failures.

**Policy documents evaluated:**
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- PASS Bash: shfmt, shellcheck, and bats evidenced by the CI job `shell-coverage`
- N/A Python (zero Python files changed); the three planned pytest files were still run in pass 1 (83 passed)
- N/A TypeScript, PowerShell, C# (zero changed files)

**Template and tooling note:** The validator functions in `scripts/dev_tools/validate_policy_audit_artifact.py` define the required structure; this document follows the structure of the completed #716 policy audit. The pass-1 reference template named in the review request (`policy-audit.2026-10-01T23-21.md`) does not contain the validator-required headings in this worktree, so it was not used as the structural source.

**Temporary artifacts cleanup:**
- PASS No scripts were added on the branch; reviewer scratch output was not written into the repository.

---

## Rejected Scope Narrowing

No scope narrowing was requested in this pass. The caller asked for corrected replacement artifacts with the same substance as pass 1 and named no subset. The earlier partial rejection (a "PARTIAL/UNVERIFIED pending CI" instruction for bash coverage) is closed by the CI evidence in Section 1.2. The review covered the full `origin/main...HEAD` diff (51 files).

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` (pass-1 reviewer run, exit 0, no violations). The branch contains no evidence-affecting change after that run other than documentation.
- Branch diff scan for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: zero files (`git diff --name-only origin/main...HEAD -- artifacts coverage` returned no paths).
- All evidence files are under `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/{baseline,regression-testing,qa-gates,other}/`.
- `EVIDENCE_LOCATION_OVERRIDE_REJECTED`: none required.
- Status: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | The six new bats cases share only the helper `edges_header_is` and file-scope header variables; bats re-evaluates the file per test, so there is no cross-test state. |
| **Isolation** | PASS | Each case targets one separator class (newline, tab, CR, CRLF-terminated final token, undeclared-only vertices, mixed) and includes a single-line `101:202` control. |
| **Fast Execution** | PASS | No sleeps or waits; the cases invoke the library function directly. |
| **Determinism** | PASS | Escapes use ANSI-C literals; no clock, randomness, or network. CI run is green on the first attempt (`1..507`, no `not ok`). |
| **Readability & Maintainability** | PASS | Case titles carry the `edges-parity:` prefix and state the scenario; the helper asserts `"$status:${lines[0]}"` so a failure names both status and header. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline:** per-file `line-rate` 0.989 (98.9%) for `.claude/lib/bash/parallel-lane-assertion.sh` on main commit `1b1e349f`<br>**Artifact:** `evidence/qa-gates/ci-per-file-coverage.2026-10-02T03-44.md` (run 36958806659) |
| **No Coverage Regression** | PASS | **Post-change:** per-file 0.989 (98.9%) at PR head `5e854239` (run 36960736942)<br>**Change:** 0.0 percentage points. No regression. |
| **New Code Coverage >= 85% lines** | PASS | **Changed line:** line 88, `<line number="88" hits="1"/>` in the PR-head `cov.xml` (100% of changed lines executed). Per-file 98.9% >= 85%. |
| **Repo-wide line coverage >= 85%** | PASS | Job log `Bash coverage (lines): 93.7%` (run 36960130609, `evidence/qa-gates/ci-shell-coverage.2026-10-02T03-40.md`). |
| **Branch coverage** | N/A | kcov does not measure branch coverage; no branch gate applies to bash (`.claude/rules/general-unit-test.md`). |
| **Positive Flows** | PASS | Newline-separated, tab-separated, and mixed-separator values reach the same header as the single-line control. |
| **Negative Flows** | PASS | Undeclared-only vertices boundary case; advisory diagnostic still exits 0. |
| **Edge Cases** | PASS | CR, CRLF, and a CRLF-terminated final token (`$'101:202\r\n'`) isolate last-token corruption. |
| **Error Handling** | PASS | Cases assert `status = 0`; the change adds no command and no new exit status under `set -euo pipefail`. |
| **Concurrency / State Transitions** | N/A | Stateless parse function. |

### 1.2.1 Per-Language Coverage Comparison

- Bash: Baseline: 98.9% lines per-file (0.989 `line-rate`, main commit `1b1e349f`, run 36958806659) -> Post-change: 98.9% lines per-file (0.989, PR head `5e854239`, run 36960736942); 93.7% merged repo-wide lines. Change: 0.0 percentage points per-file, no regression. New/changed-code coverage: 100% of changed lines (line 88 `hits="1"`). Disposition: PASS. Evidence: `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/qa-gates/ci-per-file-coverage.2026-10-02T03-44.md`, `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/qa-gates/ci-shell-coverage.2026-10-02T03-40.md`.
- Python: no Python files changed; Disposition: N/A.
- TypeScript: no TypeScript files changed; Disposition: N/A.
- PowerShell: no PowerShell files changed; Disposition: N/A.

Currency: `git diff --name-only 757d99f1..HEAD` (fix commit to local HEAD `c9f006ad`) lists documentation paths only. The library, mirror, bats file, and fixture at HEAD are byte-identical to the CI-tested content.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `"$status:${lines[0]}"` comparison names both values. |
| **Arrange-Act-Assert Pattern** | PASS | Each case arranges the value, runs the library function, and asserts through the helper. |
| **Document Intent** | PASS | Case titles and the helper's contract comment state the purpose. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, process, or filesystem access beyond sourcing the library. |
| **Temporary files** | PASS | None created; the bats file contains 0 non-ASCII bytes and uses ANSI-C escapes. |
| **Environment Stability** | PASS | No reliance on mutable global state. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the policy review for PR #815. |

### 1.6 Coverage Exclusion Policy

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No production file excluded** | PASS | No coverage configuration or `exclude` entry appears in the branch diff. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` and `spec.md` state the objective and 17 acceptance criteria. |
| **Document the plan** | PASS | `plan.2026-09-29T18-29.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | One parameter expansion on line 88; no new command. |
| **Reusability** | PASS | The other `read -ra` sites read internally built space-joined lists and need no change. |
| **Separation of concerns** | PASS | Parsing change only; no I/O change. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Under 500 lines** | PASS | `wc -l`: library 497, bats 495, fixture 10. Margins of 3 and 5 lines. |
| **Write set** | PASS | Non-documentation changes are exactly the four planned files (library, mirror, bats, fixture). No change to `report-lane-assertion.sh`, `parallel-cohorts.sh`, `compute-cohorts.sh`, the two parity test files, `pack-manifests/core.json`, the Python authority, or `docs/features/completed/`. |
| **Mirror byte-identity** | PASS | `cmp` canonical versus mirror exit 0; the library diff is a single hunk at lines 82-88. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Comment accuracy** | PASS | The comment names newline, CR, VT, and FF and does not claim full Python equivalence. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | CI step `Run shell-qc check (shfmt diff + shellcheck)` success in run 36960736942. |
| **2. Linting** | PASS | Same CI step (shellcheck). |
| **3. Type checking** | N/A | Not applicable for bash. |
| **4. Architecture boundary** | N/A | No dependency structure change. |
| **5. Testing** | PASS | bats `1..507`, no `not ok` (run 36960130609); pytest 83 passed (pass-1 reviewer run). |
| **6-7. Contract / integration** | PASS | Push-down contract pytest is inside the 83; membership bats is inside the green CI job. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Supporting documents** | PASS | Feature folder holds issue, spec, plan, research, and evidence. |
| **Follow-ups recorded** | PASS | `evidence/other/follow-ups.2026-09-29T18-45.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3C: Bash Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **shfmt / shellcheck clean** | PASS | CI `shell-qc check` success. |
| **Fail-fast behavior preserved** | PASS | No new command; `set -euo pipefail` semantics unchanged. |
| **Dependencies** | PASS | None added. |

Sections 3A (Python), 3B (PowerShell), 3D (TypeScript), 3E (C#): N/A, zero changed files.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4C: Bash Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Test location mirrors source** | PASS | Cases are in the existing `tests/shell/parallel_lane_assertion.bats`; the fixture is in the existing `tests/fixtures/parallel_lane_assertion/` corpus directory. |
| **Fail-first evidence** | PASS | Run 36961456506 at `1524e2d2` shows four expected `not ok` (119, 121, 122, 124) plus the corpus fixture; the same cases are `ok` at `5e854239` (`evidence/regression-testing/bats-unit-before.2026-10-02T03-53.md`). |
| **Boundary guards** | PASS | Tab (120) and undeclared-only (123) pass before the fix by design. |

Sections 4A (Python), 4B (PowerShell): N/A, zero changed files.

---

## 5. Test Coverage Detail

### `pla_parse_edges` (`.claude/lib/bash/parallel-lane-assertion.sh`) (6 added bats cases)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| edges-parity: a newline-separated value matches the single-line control (ok 119) | Positive, fail-first | 88 | PASS |
| edges-parity: a tab-separated value (ok 120) | Edge case, boundary guard | 88 | PASS |
| edges-parity: a CR-separated value (ok 121) | Edge case, fail-first | 88 | PASS |
| edges-parity: a CRLF-terminated final token is kept (ok 122) | Edge case, fail-first | 88 | PASS |
| edges-parity: undeclared-only vertices (ok 123) | Negative, boundary guard | 88 | PASS |
| edges-parity: mixed separators with trailing newline (ok 124) | Edge case, fail-first | 88 | PASS |

**Coverage:** line 88 `hits="1"`; per-file line-rate 0.989.

**Not covered:** Python-only whitespace (`\x1c`-`\x1f`, `\x85`, `\xa0`, Unicode spaces) is a recorded follow-up, outside the spec.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 507 bats (CI); 83 pytest in the three planned files | PASS |
| Tests Passed | All; no `not ok` | PASS |
| Tests Failed | 0 | PASS |
| New Tests | 6 bats cases plus 1 corpus fixture node | PASS |
| Test File Size | 495 lines | PASS |
| Code Coverage | 93.7% lines merged; 98.9% lines per-file | PASS |

---

## 7. Code Quality Checks

**For Bash:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| shfmt and shellcheck | CI step `Run shell-qc check (shfmt diff + shellcheck)` | success (run 36960736942) | PASS |
| bats with kcov | CI step `Run shell-qc test with coverage` | success; `1..507`, 93.7% lines | PASS |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | PASS |
| Mirror | `cmp` canonical versus bundled mirror | exit 0 | PASS |
| File size | `wc -l` | 497 and 495, limit 500 | PASS |

**Notes:** `shfmt -d` on the `.bats` file reports whole-file differences that pre-date this branch; `shell-qc.sh` does not format `.bats` files.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **Stale pre-CI evidence (Info, non-blocking):** `evidence/other/ac-gaps.2026-09-29T18-45.md` and `evidence/other/ac-status-summary.2026-09-29T18-45.md` describe AC-6 and AC-14 as open (6 of 17 checked); `evidence/qa-gates/coverage-comparison.2026-09-29T18-45.md` and `evidence/regression-testing/fail-before-exception.2026-09-29T18-45.md` record pre-CI states; the "Gaps left unchecked" section of `ci-shell-coverage.2026-10-02T03-40.md` predates the two later CI artifacts. They are point-in-time records, no gate reads them, and `spec.md` (17 of 17) plus the three CI artifacts agree. Optional hygiene: add a superseding status summary with a new timestamp; do not edit the old files.
- **CI on head `c9f006ad` (Info):** The head delta from the last CI-green head `5e854239` is documentation only, so the shell verdicts carry over. Re-read the final CI state before merge.
- **Residual divergence (Info, recorded follow-up):** Python-only whitespace still differs; the comment does not claim equivalence.

### Approved Exceptions

None.

### Removed/Skipped Tests

None. No existing test was removed or modified.

---

## 9. Summary of Changes

### Files Modified

1. **`.claude/lib/bash/parallel-lane-assertion.sh`** (MODIFIED) - line 88 normalizes newline, CR, VT, FF to spaces before `read -ra tokens`; comment grew by two lines (497 lines).
2. **`extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-lane-assertion.sh`** (MODIFIED) - byte-identical mirror.
3. **`tests/shell/parallel_lane_assertion.bats`** (MODIFIED) - helper plus six `edges-parity:` cases (495 lines).
4. **`tests/fixtures/parallel_lane_assertion/edges_newline_separated.json`** (NEW) - corpus fixture derived from the Python authority.
5. **`docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/`** (NEW) - issue, spec, plan, research, evidence, and review artifacts.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All applicable policy requirements pass on CI evidence for the bash lane. Blocking findings: 0. Bash coverage verdict: PASS (per-file 0.989 versus 0.989 baseline; merged 93.7%; changed line executed).

### Policy-by-Policy Summary

| # | Policy area | Verdict |
|---|---|---|
| 1 | Evidence location compliance | PASS |
| 2 | File size limit (500 lines) | PASS |
| 3 | Write-set and untouched-file limits | PASS |
| 4 | Mirror byte-identity | PASS |
| 5 | Test file location and layout | PASS |
| 6 | Unit-test principles | PASS |
| 7 | Coverage exclusion policy | PASS |
| 8 | Bash coverage verification | PASS |
| 9 | Python coverage | PASS (zero `.py` files changed) |
| 10 | Mandatory toolchain loop, shell stages | PASS (CI authority) |
| 11 | Error handling and fail-fast | PASS |
| 12 | Dependencies | PASS |
| 13 | Tone policy | PASS |
| 14 | Acceptance-criteria tracking (17 of 17 checked) | PASS |
| 15 | CI-evidence artifact format (Timestamp, Command, EXIT_CODE, Output Summary) | PASS |
| 16 | Evidence currency | PASS with non-blocking observation |

### Metrics Summary

- 507 bats tests, no `not ok`; 83 pytest passed
- 98.9% per-file line coverage (baseline 98.9%); 93.7% merged
- Library 497 lines, bats 495 lines

### Recommendation

**Ready for merge**, subject to re-reading CI on the final head. No remediation is required.

---

## Appendix A: Test Inventory

1. edges-parity: a newline-separated value matches the single-line control (ok 119)
2. edges-parity: a tab-separated value (ok 120)
3. edges-parity: a CR-separated value (ok 121)
4. edges-parity: a CRLF-terminated final token is kept (ok 122)
5. edges-parity: undeclared-only vertices (ok 123)
6. edges-parity: mixed separators with trailing newline (ok 124)
7. Corpus parity case `the bash lane reproduces every lane-assertion corpus fixture` (includes `edges_newline_separated`)
8. pytest `test_reference_reproduces_every_corpus_fixture[edges_newline_separated]`

The 16 pre-existing cases in the bats file and the remaining suites are unchanged.

---

## Appendix B: Toolchain Commands Reference

**For Bash (executed by CI, `.github/workflows/_shell-coverage.yml`):**
```bash
sh scripts/bash/shell-qc.sh check
sh scripts/bash/shell-qc.sh test --coverage
```

**Repository-level:**
```bash
git diff origin/main...HEAD --stat
git merge-base HEAD origin/main
git diff --name-only 757d99f1..HEAD
cmp .claude/lib/bash/parallel-lane-assertion.sh extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-lane-assertion.sh
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run pytest tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py tests/scripts/dev_tools/test_parallel_lane_assertion.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-02
**Policy Version:** Current (as of audit date)
