# Policy Compliance Audit: cleanup-worktrees scan helper drive-letter gitdir classification (Issue #706)

---

**Audit Date:** 2026-09-27  
**Branch:** `bug/cleanup-report-registration-lost-false-positive-706` @ `81d4e16b109525a2f965b7353cd2f9492f6225ef`  
**Base:** `main` (`origin/main` @ `849aae609787172240c1ae7c33d10d6dd337d497`; merge base is the same SHA)  
**Code Under Test:**
- `scripts/bash/cleanup_worktrees_scan_helper.sh` (MODIFIED, bash production)
- `tests/shell/test_cleanup_worktrees_scan_helper.bats` (MODIFIED, bats tests; append-only)
- `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit` (NEW, checked-in fixture)
- 55 Markdown files under `docs/features/active/cleanup-report-registration-lost-false-positive-706/` (issue, spec, plan, research, evidence; documentation only)

**Template source:** the installed drm-copilot extension payload file `resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, which is the file the MCP resolver `resolve_policy_audit_template_asset` copies for selector `template`. The MCP tool is not in this agent's tool list, so the payload file was read directly; its content is the resolver's source asset.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Bash | 1 production file, 1 bats file, 1 fixture | 5 tests in the changed bats file (4 new); 430 bats tests in the CI run | ✅ CI: 0 not ok; local: 17 pass, 0 fail (three cleanup-worktrees suites) | 93.3% lines repo-wide; 86.8% lines for the changed file (46/53) | 93.3% lines repo-wide; 87.5% lines for the changed file (49/56) | 100% (6/6 new or modified instrumented lines hit) |
| TypeScript | 0 files | N/A | N/A | N/A - no changed files | N/A - no changed files | N/A - no changed files |
| Python | 0 files | N/A | N/A | N/A - no changed files | N/A - no changed files | N/A - no changed files |
| PowerShell | 0 files | N/A | N/A | N/A - no changed files | N/A - no changed files | N/A - no changed files |
| C# | 0 files | N/A | N/A | N/A - no changed files | N/A - no changed files | N/A - no changed files |

Bash coverage is measured by kcov (line coverage only). Per `.claude/rules/quality-tiers.md` and `.claude/rules/shell.md`, no branch-coverage gate applies to bash.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- Bash baseline coverage artifact: `docs/features/active/cleanup-report-registration-lost-false-positive-706/evidence/baseline/ci-shell-coverage.2026-09-27T10-09.md` and `evidence/baseline/kcov-per-file.2026-09-27T10-10.md` (CI run 36324413557, `cov.xml` from the `shell-coverage` artifact)
- Bash post-change coverage artifact: `docs/features/active/cleanup-report-registration-lost-false-positive-706/evidence/qa-gates/ci-shell-coverage.2026-09-27T10-48.md`, `evidence/qa-gates/kcov-per-file.2026-09-27T10-49.md`, and `evidence/qa-gates/kcov-new-line-hits.2026-09-27T10-49.md` (CI run 36326020967)
- Per-language comparison summary: Section 1.2.1 of this audit and `evidence/qa-gates/coverage-delta.2026-09-27T10-50.md`

Coverage artifact note: the repository's default bash coverage path is `artifacts/pester/kcov/cov.xml`. Per `.claude/rules/shell.md`, CI (`.github/workflows/_shell-coverage.yml`) is canonical for bash coverage; the `cov.xml` produced by the post-change workflow_dispatch run was downloaded by the executor and its per-file class block is transcribed in the evidence files above. This review inspected those recorded figures and did not regenerate coverage.

---

## Executive Summary

The branch fixes issue #706: `scan_helper_gitdir_target_exists` treated a Git for Windows pointer target such as `C:/.../.git/worktrees/<name>` as relative, prefixed the worktree directory, and reported the target missing, which made report mode emit `WARN|registration-lost` for healthy worktrees. The fix adds a pure predicate `scan_helper_is_absolute_path` (slash-leading or drive letter plus `/` or `\`), isolates the existence check in `scan_helper_target_present` as a test seam, and rewires the two affected lines. Four bats tests and one fixture were added; the existing test and all consumer files are unchanged.

**Policy documents evaluated:**
- ✅ `CLAUDE.md`
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md`
- ✅ `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- N/A Python (no changed files)
- N/A PowerShell (no changed files)
- N/A TypeScript (no changed files)
- N/A C# (no changed files)
- ✅ Bash: `.claude/rules/shell.md` (shfmt + shellcheck + bats + kcov)

Toolchain results: CI run 36326020967 at code-identical commit 3bcaee4d concluded success (shfmt diff clean, shellcheck clean, 0 `not ok`, `Bash coverage (lines): 93.3%`). The reviewer re-ran `sh scripts/bash/shell-qc.sh check`, `shellcheck`, `shfmt -d`, and the three cleanup-worktrees bats suites locally; all exited 0 (17/17 tests ok). A read-only real-host comparison showed the pre-fix logic reporting 33 of 33 pointer-bearing worktrees as missing their target, and the fixed helper reporting 1 (a genuine loss whose target directory is absent). Evidence: `evidence/qa-gates/reviewer-verification.2026-09-27T10-48.md`.

No Blocker or Major findings. One Minor finding (evidence filename timestamps later than the commits that contain them) and several Nit/Info observations are recorded in the code review.

**Temporary artifacts cleanup:**
- ✅ No temporary script was added to the repository. The executor's kcov downloads and the reviewer's comparison script were written only to session scratchpads.
- ✅ No new tooling script was kept.

---

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller supplied the base branch, the feature folder, the AC source, and the statement "bats and kcov are not available in this worktree". That statement is not a narrowing instruction; it was tested and found partly inaccurate (bats ran locally through `npx --yes bats`; kcov was not run locally). The audit covers the full `origin/main...HEAD` diff (58 files).

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — EXIT_CODE 0, no violations reported.
- Command: `git diff --name-only origin/main...HEAD | grep -E '^artifacts/|^\.github/'` — no output (exit 1). The branch writes no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All branch evidence is under `docs/features/active/cleanup-report-registration-lost-false-positive-706/evidence/{baseline,regression-testing,qa-gates,other}/`. Result: PASS.

## Workflow Rule: modified-workflow-needs-green-run

The branch diff modifies no path under `.github/workflows/**`, `.github/actions/**`, or `scripts/benchmarks/**`. The rule does not fire. No enforcement hook (`.claude/hooks/**`) or `.claude/settings.json` is modified.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Each `@test` runs the helper in its own child process (`bash "${HELPER}"` or `bash -c`); the function redefinition in test 1 exists only in that child. `setup()` sets only path variables. No shared mutable state. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Test 1: drive-letter target present, no prefix. Test 2: drive-letter target absent. Tests 3 and 4: the predicate's true and false outcomes. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Local run of 17 tests across three suites completed within a single short invocation; the new tests invoke one child shell each, with no network or git process. |
| **Determinism** - Consistent results | ✅ PASS | Checked-in fixture; exact-string seam in test 1; test 2 relies on `C:/fixture-repo/...` being absent on the host (stated as a spec assumption). No clock, RNG, or sleep. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive test names; each test carries a comment stating the scenario, issue number, and why the `load_helper` shim clears `nounset`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 93.3% lines repo-wide; 86.8% (46/53) for `cleanup_worktrees_scan_helper.sh`<br>**Command:** `gh workflow run _shell-coverage.yml` (run 36324413557), per-file class block from `cov.xml`<br>**Timestamp:** recorded in `evidence/baseline/ci-shell-coverage.2026-09-27T10-09.md` and `evidence/baseline/kcov-per-file.2026-09-27T10-10.md` |
| **No Coverage Regression** | ✅ PASS | **Post-change:** 93.3% lines repo-wide; 87.5% (49/56) for the changed file<br>**Change:** 0.0 points repo-wide; +0.7 points per file<br>**Status:** No regression. Zero-hit lines unchanged at 7 (all pre-existing statements). |
| **New Code Coverage** | ✅ PASS | **Modified file:** `scripts/bash/cleanup_worktrees_scan_helper.sh`<br>**New/modified-line coverage:** 6/6 = 100% (lines 83, 84, 94, 116, 117, 119 each hits >= 1)<br>**Method:** line numbers located by content, hits read from the CI `cov.xml` class block (`evidence/qa-gates/kcov-new-line-hits.2026-09-27T10-49.md`). No new production file was added. |
| **Comprehensive Coverage** | ✅ PASS | `scan_helper_is_absolute_path` (lines 73-85): tests 1, 3, 4 plus existing test (relative path). `scan_helper_target_present` (lines 87-95): test 2 and existing test (real body); test 1 (redefined). `scan_helper_gitdir_target_exists` (lines 97-124): all five tests. Untested: the 7 pre-existing zero-hit lines (du fallback, empty override, empty target, usage paths); unchanged by this branch. |
| **Positive Flows** - Valid inputs | ✅ PASS | Test 1 (drive-letter target present yields `|1|1|`); test 3 (`/abs`, `C:/x`, `c:/x`, `C:\x` classified absolute). Total positive: 2. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Test 2 (drive-letter target absent yields `|1|0|`); test 4 (`../rel`, `rel`, `C:rel`, empty classified not absolute). Total negative: 2. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Lowercase drive, backslash separator, drive-relative `C:rel`, and the empty string (tests 3 and 4). |
| **Error Handling** - Error paths | ✅ PASS | No error path changed. Test 2 confirms an absent target yields `0` with exit status 0, not a failure. |
| **Concurrency** - If applicable | N/A | Single-process, read-only helper. |
| **State Transitions** - If applicable | N/A | Stateless functions. |

### 1.2.1 Per-Language Coverage Comparison

- Bash: Baseline: 93.3% lines repo-wide (changed file 86.8%, 46/53) -> Post-change: 93.3% lines repo-wide (changed file 87.5%, 49/56). Change: +0.0% repo-wide, +0.7% for the changed file. New/changed-code coverage: 100% (6 of 6 new or modified instrumented lines hit). Disposition: PASS. Evidence: `docs/features/active/cleanup-report-registration-lost-false-positive-706/evidence/qa-gates/coverage-delta.2026-09-27T10-50.md`, `evidence/qa-gates/kcov-new-line-hits.2026-09-27T10-49.md`, `evidence/baseline/kcov-per-file.2026-09-27T10-10.md`.
- TypeScript: N/A - zero changed files on the branch. Disposition: N/A.
- Python: N/A - zero changed files on the branch. Disposition: N/A.
- PowerShell: N/A - zero changed files on the branch. Disposition: N/A.
- C#: N/A - zero changed files on the branch. Disposition: N/A.

Thresholds applied: line >= 85% repo-wide and per changed file, no regression on changed lines (uniform rule). Also checked against the agent-contract figures (repo-wide >= 80%, modified file >= 80%, new file >= 90%): all satisfied; there is no new production file. Bash coverage verdict: **PASS**.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Tests 3 and 4 print each misclassified candidate (`classified relative: [C:/x]`), demonstrated in `evidence/regression-testing/predicate-negative-control.2026-09-27T10-29.md`. Test 1's failure output shows the full record (`fail-before.2026-09-27T10-17.md`). |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Arrange (`drive_root`, env seam), act (`run ...`), assert (`status`, output pattern). |
| **Document Intent** | ✅ PASS | Names state the observable behavior; comments cite issue #706 and explain the seam. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, no git process, no scratch repository. |
| **Use Mocks/Stubs** | ✅ PASS | `scan_helper_target_present` is redefined in test 1 (function-override seam, spec D2); `CLEANUP_WT_SCAN_GITFILE_NAME=dotgit` is the existing pointer-name seam. |
| **Environment Stability** | ✅ PASS | No temporary files (`evidence/qa-gates/test-portability.2026-09-27T10-51.md`: no `mktemp`, `BATS_*TMPDIR`, `git init`, `origin/`, or host path in added lines). Fixture is LF (`git ls-files --eol`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document, with `code-review.2026-09-27T10-48.md` and `feature-audit.2026-09-27T10-48.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` (#706) and `spec.md` Context and Root Cause Analysis. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.md`; research file under `research/`. |
| **Document the plan** | ✅ PASS | `plan.2026-09-26T22-56.md` (two preflight revisions recorded in commits 0c72c3fa and c84938ed). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One glob predicate and a one-line seam; rejected alternatives (`cygpath`, per-directory `git rev-parse`) recorded in spec D1. |
| **Reusability** | ✅ PASS | The predicate is a named function. A near-identical glob exists in `scripts/bash/cleanup_worktrees_preserve_lib.sh:161`; sharing it would require the standalone helper to source a library (recorded as a Nit in the code review). |
| **Extensibility** | ✅ PASS | Classification rules live in one function; record format and CLI unchanged. |
| **Separation of concerns** | ✅ PASS | Pure classification (`scan_helper_is_absolute_path`) is separated from filesystem I/O (`scan_helper_target_present`). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Both functions are placed directly above their only caller. |
| **Under 500 lines** | ✅ PASS | Helper 182 lines; bats file 101 lines (`wc -l`, `evidence/qa-gates/line-counts.2026-09-27T10-51.md`). |
| **Public vs internal** | ✅ PASS | CLI surface (`scan-dirs`) unchanged; new functions use the `scan_helper_` prefix. |
| **No circular dependencies** | ✅ PASS | The helper sources nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `scan_helper_is_absolute_path`, `scan_helper_target_present`. |
| **Docs/docstrings** | ✅ PASS | Each function has an args/returns comment block; the file header now defines "absolute". |
| **Comment why, not what** | ✅ PASS | Comments explain the Git for Windows pointer form, the drive-relative exclusion, and why the seam exists. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `sh scripts/bash/shell-qc.sh format` (executor) and `shfmt -d` (reviewer)<br>**Result:** no rewrite; no diff. CI shfmt 3.8.0 diff clean. |
| **2. Linting** | ✅ PASS | **Command:** `sh scripts/bash/shell-qc.sh check`; `shellcheck -f gcc scripts/bash/cleanup_worktrees_scan_helper.sh`<br>**Result:** exit 0, no findings, no suppression added. |
| **3. Type checking** | N/A | Bash has no type checker; `bash -n` syntax check passed (`evidence/qa-gates/qc-step3-syntax.2026-09-27T10-45.md`). |
| **4. Testing** | ✅ PASS | **Command:** `npx --yes bats <three suites>` (local, 17/17 ok); CI `shell-qc.sh test --coverage` (0 not ok). |
| **Full toolchain loop** | ✅ PASS | Pass 1 failed in CI (run 36325350057: three new tests aborted under kcov because of `set -u` and the kcov PS4 trace); tests were adjusted, and pass 2 completed clean locally and in CI. |
| **Explicit reporting** | ✅ PASS | Commands and exit codes recorded under `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Conventional commit messages (`fix(706)`, `test(706)`, `docs(706)`). |
| **Design choices explained** | ✅ PASS | `spec.md` D1-D10. |
| **Update supporting documents** | ✅ PASS | Helper header comment updated. The SKILL.md copies were intentionally left unchanged (D4; they already state the intended contract). |
| **Provide next steps** | ✅ PASS | D7 follow-up candidates: unscanned worktree locations and `CLEANUP_WT_ORPHAN_ROOTS` colon splitting. |

---

## 3. Language-Specific Code Change Policy Compliance

Only bash has changed code on this branch. Python, PowerShell, TypeScript, C#, and JSON sections are omitted (zero changed files).

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | ✅ PASS | **Command:** `sh scripts/bash/shell-qc.sh format` / `shfmt -d`<br>**Result:** no changes (executor pass 2; reviewer re-run; CI). |
| **Linting with shellcheck** | ✅ PASS | **Command:** `sh scripts/bash/shell-qc.sh check`<br>**Result:** exit 0 locally (reviewer) and in CI run 36326020967. |
| **Testing with bats** | ✅ PASS | **Command:** `npx --yes bats ...` locally; `shell-qc.sh test --coverage` in CI<br>**Result:** 17/17 local; 0 not ok in CI (tests 426-430 ok). |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | ✅ PASS | `#!/usr/bin/env bash` (unchanged). |
| **Error handling** | ✅ PASS | `set -euo pipefail` unchanged; the predicate and seam use `${1:-}` so they are safe under `nounset`. |
| **Under 500 lines** | ✅ PASS | 182 lines. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4C: Bash (bats) Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework** | ✅ PASS | bats, in `tests/shell/test_cleanup_worktrees_scan_helper.bats` (existing file for this helper). |
| **Checked-in fixtures, no temp files** | ✅ PASS | New fixture `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit`; no temp-file APIs in added lines. |
| **Coverage (kcov, line only)** | ✅ PASS | Repo-wide 93.3%; changed file 87.5%; 6/6 changed lines hit. |
| **Fail-before / pass-after** | ✅ PASS | `evidence/regression-testing/fail-before.2026-09-27T10-17.md` (test 1 not ok against the unmodified helper, record `|1|0|`); `pass-after.2026-09-27T10-25.md`; predicate negative control `predicate-negative-control.2026-09-27T10-29.md`. |
| **Test location** | ✅ PASS | `tests/shell/` per `.claude/rules/shell.md`. |

---

## 5. Test Coverage Detail

### `scan_helper_is_absolute_path` (4 tests exercise it directly or through the scan)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| scan_helper_is_absolute_path returns 0 for slash-leading and drive-letter paths | Positive / Edge Case | 83-84 | ✅ |
| scan_helper_is_absolute_path returns non-zero for relative, drive-relative, and empty paths | Negative / Edge Case | 83-84 | ✅ |
| scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory | Positive (regression) | 83-84, 116, 119 | ✅ |
| scan-dirs emits has_gitfile/target_exists/size for each candidate directory (existing) | Positive / Negative (relative targets) | 83-84, 116-117, 119 | ✅ |

**Coverage:** 100% of the function's instrumented lines (83, 84).

### `scan_helper_target_present` (2 tests execute the real body)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| scan-dirs reports target_exists 0 for a drive-letter gitdir target that does not exist | Negative | 94 | ✅ |
| scan-dirs emits has_gitfile/target_exists/size for each candidate directory (existing) | Positive / Negative | 94 | ✅ |

**Coverage:** 100% of instrumented lines (94).

### `scan_helper_gitdir_target_exists` (modified lines)

**Coverage:** lines 116, 117, 119 each hits >= 1. **Not covered:** lines 113-114 (empty-target early return), pre-existing and unchanged.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (changed bats file) | 5 (1 existing + 4 new) | ✅ |
| Tests Passed (local, three suites) | 17 (100%) | ✅ |
| Tests Failed | 0 local; 0 in CI run 36326020967 | ✅ |
| Execution Time | Not separately timed; single short local invocation | ✅ Fast |
| Functions Tested (new or modified) | 3/3 (100%) | ✅ |
| Test File Size | 101 lines | ✅ Maintainable |
| Code Coverage | 93.3% lines repo-wide; 87.5% lines changed file; branch not measured by kcov | ✅ |

---

## 7. Code Quality Checks

**For Bash:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| shfmt | `sh scripts/bash/shell-qc.sh check` (stage 1) / `shfmt -d scripts/bash/cleanup_worktrees_scan_helper.sh` | No diff | ✅ |
| shellcheck | `shellcheck -f gcc scripts/bash/cleanup_worktrees_scan_helper.sh` | No findings | ✅ |
| Syntax | `bash -n scripts/bash/cleanup_worktrees_scan_helper.sh` (executor) | Exit 0 | ✅ |
| bats | `npx --yes bats tests/shell/test_cleanup_worktrees_scan_helper.bats tests/shell/test_cleanup_worktrees_report_records.bats tests/shell/test_cleanup_worktrees_scan_seam.bats` | 17/17 ok | ✅ |
| kcov (CI) | `_shell-coverage.yml` workflow_dispatch run 36326020967 | 93.3% lines; success | ✅ |

**Notes:** The CI coverage run's head SHA is 3bcaee4d, not the branch head 81d4e16b. The two commits after 3bcaee4d change only feature-folder Markdown (verified with `git diff --name-only 3bcaee4d..HEAD`), so the measured code is identical to the head. Local shfmt is v3.12.0 while CI pins 3.8.0; both report no diff.

---

## 8. Gaps and Exceptions

### Identified Gaps

- Evidence timestamp accuracy (Minor, non-blocking): from commit be344727 onward, evidence filenames and `Timestamp:` values are 4 to 18 minutes later than the commits that contain them (for example `other/commit-final.2026-09-27T10-55.md` is in commit 81d4e16b dated 10:40:13 -0400; `qa-gates/ci-shell-coverage.2026-09-27T10-48.md` records a dispatch at 14:28:06Z, which is 10:28 local). The substantive evidence is cross-checkable through CI run IDs and file hashes, which this review verified; the timestamps themselves are not reliable as creation times.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All four planned tests are implemented.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **9bc188e8** - docs(bug): create active folder for #706 registration-lost false positive
2. **524ee6e2** - docs(bug): add #706 root-cause research
3. **38a04e96** - docs(bug): add #706 spec with design decisions D1-D7
4. **2576ead4** - docs(bug): add #706 atomic plan
5. **dc1baf2e** - docs(bug): record #706 decisions D8-D10 in spec
6. **0c72c3fa** - docs(bug): revise #706 plan per preflight round 1
7. **c84938ed** - docs(bug): revise #706 plan per preflight round 2
8. **0bc4cd26** - docs(706): record phase 0 baseline evidence
9. **be344727** - test(706): add drive-letter gitdir regression fixture and tests
10. **3efc3ddf** - fix(706): treat drive-letter gitdir targets as absolute in scan helper
11. **df1caba5** - test(706): add absolute-path predicate tests and negative control
12. **b6d86d8c** - test(706): record final local QC loop for scan helper drive-letter fix
13. **3bcaee4d** - test(706): load scan helper via function so kcov tracing does not abort
14. **91a8cec3** - docs(706): record CI coverage, scope checks, and AC check-off
15. **81d4e16b** - docs(706): record commit-final evidence and check off P4-T23

### Files Modified

1. **scripts/bash/cleanup_worktrees_scan_helper.sh** (MODIFIED, +28/-3)
   - Adds `scan_helper_is_absolute_path` and `scan_helper_target_present`.
   - `scan_helper_gitdir_target_exists` prefixes the worktree directory only for non-absolute targets and checks existence through the seam.
   - Header comment defines absolute targets.
2. **tests/shell/test_cleanup_worktrees_scan_helper.bats** (MODIFIED, +67/-0)
   - Four appended tests; the existing test is unchanged.
3. **tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit** (NEW)
   - Single line `gitdir: C:/fixture-repo/.git/worktrees/wt_drive`.
4. **docs/features/active/cleanup-report-registration-lost-false-positive-706/** (NEW, 55 Markdown files)
   - issue, spec, research, plan, and execution evidence.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All applicable policies are satisfied for the only changed language (bash). Coverage evidence is numeric for baseline, post-change, and changed lines. The one gap (evidence timestamp accuracy) is a documentation-metadata issue that does not affect any gate result.

**Fail-closed reminder:** baseline, QA, and coverage-comparison artifacts are all present and were inspected.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: issue, research, spec, and plan present.
- ✅ Design Principles: pure predicate separated from I/O seam.
- ✅ Module & File Structure: 182 and 101 lines.
- ✅ Naming, Docs, Comments: descriptive and rationale-focused.
- ✅ Toolchain Execution: clean in CI and in the reviewer's local re-run.
- ✅ Summarize & Document: spec D1-D10 and conventional commits.

#### Language-Specific Code Change Policy (Section 3)

**For Bash:**
- ✅ Tooling & Baseline: shfmt, shellcheck, bats clean.
- ✅ Bash Script Design: shebang and strict mode unchanged; nounset-safe parameters.

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independent, isolated, deterministic tests.
- ✅ Coverage & Scenarios: 93.3% repo-wide, 87.5% changed file, 6/6 changed lines.
- ✅ Test Structure: clear diagnostics demonstrated by the negative control.
- ✅ External Dependencies: none; function-override seam only.
- ✅ Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For Bash:**
- ✅ Framework & Scope: bats in `tests/shell/`.
- ✅ Test Style & Structure: checked-in fixture, no temp files.
- ✅ Naming & Readability: behavior-stating names.
- ✅ Toolchain: CI kcov run success.

---

### Metrics Summary

- ✅ 17/17 local tests passing; 0 failing tests in CI run 36326020967
- ✅ 3/3 new or modified functions tested
- ✅ 93.3% bash line coverage repo-wide; 87.5% for the changed file
- ✅ Tests in `tests/shell/`, fixture in `tests/fixtures/`
- ✅ All code quality checks passing

---

### Recommendation

**Ready for merge**

Proceed with normal PR flow. Before opening the PR, rebase on `main` per repository practice and let the PR-context CI run confirm the result at the rebased head. Optionally correct the evidence timestamp drift noted in Section 8; it is not a merge prerequisite.

---

## Appendix A: Test Inventory

### Complete Test List

`tests/shell/test_cleanup_worktrees_scan_helper.bats`:

1. scan-dirs emits has_gitfile/target_exists/size for each candidate directory (existing, unchanged)
2. scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory (new)
3. scan-dirs reports target_exists 0 for a drive-letter gitdir target that does not exist (new)
4. scan_helper_is_absolute_path returns 0 for slash-leading and drive-letter paths (new)
5. scan_helper_is_absolute_path returns non-zero for relative, drive-relative, and empty paths (new)

Consumer suites run unchanged: `tests/shell/test_cleanup_worktrees_report_records.bats` (9 tests), `tests/shell/test_cleanup_worktrees_scan_seam.bats` (3 tests).

---

## Appendix B: Toolchain Commands Reference

**For Bash (commands used in this audit):**
```bash
# Scope
git diff --stat origin/main...HEAD
git diff --name-only 3bcaee4d..HEAD
git log --oneline origin/main..HEAD

# Format and lint (check-only)
sh scripts/bash/shell-qc.sh check
shellcheck -f gcc scripts/bash/cleanup_worktrees_scan_helper.sh
shfmt -d scripts/bash/cleanup_worktrees_scan_helper.sh

# Tests
npx --yes bats tests/shell/test_cleanup_worktrees_scan_helper.bats \
  tests/shell/test_cleanup_worktrees_report_records.bats \
  tests/shell/test_cleanup_worktrees_scan_seam.bats

# Integrity
sha256sum scripts/bash/cleanup_worktrees_scan_helper.sh tests/shell/test_cleanup_worktrees_scan_helper.bats \
  tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit
git ls-files --eol scripts/bash/cleanup_worktrees_scan_helper.sh

# Evidence locations
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .

# Coverage (executor, CI canonical; inspected, not re-run)
gh workflow run _shell-coverage.yml --ref bug/cleanup-report-registration-lost-false-positive-706
gh run download 36326020967 --name shell-coverage --dir <scratchpad>
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-09-27  
**Policy Version:** Current (as of audit date)
