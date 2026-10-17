# Policy Compliance Audit: cleanup-merged-worktrees scan roots and orphan-root split (Issue #741)

**Audit Date:** 2026-10-02  
**Code Under Test:** `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`, `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh`, `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh`, `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`, `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`, `.claude/skills/cleanup-merged-worktrees/SKILL.md`, the six byte-identical mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/`, `tests/shell/test_cleanup_worktrees_scan_roots.bats` (new), `tests/shell/test_cleanup_worktrees_scan_helper.bats` (modified), `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_derived/worktree-list.out` (new). The remaining changed files are feature-folder Markdown documents.

**Review scope:** full branch diff `origin/main...HEAD` (merge base `71f8dcb49d8ce5d1402ff441855a64be15b37f29`, head `5c783c066abb505ade1b1e7902a679c74bced84b`). PR context regenerated for this review: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated 2026-10-02 08:29:59 UTC, Head SHA `5c783c06`).

**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` (the asset the MCP template selector `template` resolves to). The MCP tool surface was not available to this review agent, so the bundled file was read directly.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Bash | 5 production files (+5 mirrors), 2 bats files, 1 fixture | 521 bats tests (16 new) | PASS: 521 ok, 0 not ok | 93.7% lines | 93.8% lines | 98.8% |
| Python | 0 files | N/A | N/A | N/A (no Python files changed) | N/A (no Python files changed) | N/A |
| TypeScript | 0 files | N/A | N/A | N/A (no TypeScript files changed) | N/A (no TypeScript files changed) | N/A |
| PowerShell | 0 files | N/A | N/A | N/A (no PowerShell files changed) | N/A (no PowerShell files changed) | N/A |
| C# | 0 files | N/A | N/A | N/A (no C# files changed) | N/A (no C# files changed) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript files changed on the branch
- PowerShell baseline coverage artifact: N/A - no PowerShell files changed on the branch
- PowerShell post-change coverage artifact: N/A - no PowerShell files changed on the branch
- Bash baseline coverage artifact: CI run 36978610292 `shell-coverage` artifact `cov.xml` (head `df5eb303`), recorded in `evidence/baseline/shell-coverage-ci.2026-10-02T03-47.md`
- Bash post-change coverage artifact: CI run 36982722154 `shell-coverage` artifact `cov.xml` (head `10c6ac29`), recorded in `evidence/qa-gates/shell-coverage-ci.2026-10-02T04-21.md`
- Per-language comparison summary: Section 1.2.1 of this audit

---

## Executive Summary

The branch moves `cleanup_wt_scan_roots` from the report-records library into the enumeration library, adds registration-derived scan roots (`cleanup_wt_derive_scan_roots`) and a drive-letter-safe override splitter (`cleanup_wt_split_roots`), consolidates the absolute-path predicate into one shared function (`cleanup_wt_is_absolute_path`), deduplicates the scan-helper test loader, and updates the wrapper usage text and `SKILL.md`. Only bash and Markdown files changed.

All gates evaluated PASS. Formatting and lint were re-run locally by this review (`shfmt -d`, `shellcheck`, both exit 0) and passed in the CI `shell-qc.sh check` step on head `10c6ac29`. The bats suite passed in CI (`1..521`, zero `not ok`). kcov line coverage was verified by this review from the downloaded baseline and final `cov.xml` artifacts: every changed production file is at or above 85%, the repository aggregate rose from 93.7% to 93.8%, and no previously covered line became uncovered. Mirror parity, the 500-line limit, the no-temporary-files rule, the evidence-location rule, and the #756 boundary were each verified.

Three non-blocking Minor observations and one Nit are recorded (Section 8). No blocking finding exists.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md`
- ✅ `.claude/rules/tonality.md` (applied to feature-folder documents and this review)

**Language-specific policies evaluated:**
- N/A `python-code-change` + `python-unit-test` (no Python files changed)
- N/A `powershell-code-change` + `powershell-unit-test` (no PowerShell files changed)
- ✅ Bash: `.claude/rules/shell.md` (shfmt + shellcheck + bats + kcov)
- N/A JSON (no JSON files changed)

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script was added to the branch. Scratch scripts A1 and A2 named in the plan were not written (DEV-2); the executor used plain git plus Read/Grep. This review's coverage-comparison script lives only in the session scratchpad, outside the repository.
- ✅ No ongoing tooling script was added.

## Rejected Scope Narrowing

None detected. The caller prompt listed changed files that match the full `origin/main...HEAD` diff and directed that properly cited CI results be accepted as bats/kcov evidence (operator decision Option A, 2026-10-01). That instruction changes the evidence source, not the scope; coverage for the one changed language (Bash) was still verified and is reported with an explicit PASS verdict.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` -> exit 0, no output.
- Branch diff scan: `git diff --name-only origin/main...HEAD` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence lives under `docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/evidence/{baseline,regression-testing,qa-gates,other}/`.
- Result: PASS. No FAIL-level evidence-location finding.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Each bats test launches its own `bash -c` child through `run env ...` with explicit environment; `setup()` only resolves paths and sets the stub exec bit. No test reads state written by another. |
| **Isolation** - Each test targets single behavior | ✅ PASS | `test_cleanup_worktrees_scan_roots.bats` has 16 tests: 4 for root composition (AC-1/2/4), 7 for the separator contract (AC-5), 1 for the single-scan run_report path (AC-6), 4 for the shared predicate and its preserve caller (AC-7). Each test asserts one behavior. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | All tests use checked-in stubs; no network or real git repository. Full CI shell job with kcov completed in about 5 minutes for 521 tests (run 36982722154). |
| **Determinism** - Consistent results | ✅ PASS | Inputs are fixed fixture files under `tests/fixtures/cleanup_worktrees/scenarios/`; git and the filesystem scan are replaced by `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_SCAN_BIN` stubs; derived roots are emitted in `LC_ALL=C` order. No clock or randomness is involved. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive `@test` names, an AC tag comment in each test, and three file-local runners (`roots_run`, `roots_run_raw`, `report_run`) with header comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 93.7% lines (Bash aggregate)<br>**Command:** CI `_shell-coverage.yml` dispatch, run 36978610292 on `df5eb303`<br>**Timestamp:** 2026-10-02 07:26 UTC dispatch<br>Recorded before production change in `evidence/baseline/shell-coverage-ci.2026-10-02T03-47.md`. |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 93.8% lines<br>**Change:** +0.1% lines<br>**Status:** No regression on changed lines. Per-file rates for `report_records_lib` (0.890 -> 0.879) and `scan_helper` (0.875 -> 0.873) fell because covered lines were removed; this review compared the uncovered-line source text in both `cov.xml` files and found the uncovered set unchanged in both files (20 and 7 lines respectively). |
| **New Code Coverage** | ✅ PASS | **New/modified production lines:** 83 instrumented changed lines, 82 covered = 98.8% (threshold 85%; also meets the 90% new-code figure in the reviewer instructions).<br>**Calculation method:** `git diff -U0` added-line ranges intersected with `<line hits>` entries in the final `cov.xml`; independently confirmed by this review's baseline/final comparison. The one missed line is `cleanup_worktrees_enumerate_lib.sh:370` (process-substitution terminator of a loop whose body executed). |
| **Comprehensive Coverage** | ✅ PASS | `cleanup_wt_is_absolute_path` (enumerate_lib 257-271): 2 direct tests + 2 caller tests; `cleanup_wt_split_roots` (273-317): 7 tests; `cleanup_wt_derive_scan_roots` (319-372): 3 tests + 1 run_report test; `cleanup_wt_scan_roots` (374-416): 4 tests + 3 pre-existing tests in `test_cleanup_worktrees_report_records.bats`. Untested: backslash-form registration paths in derivation (Nit N-1). |
| **Positive Flows** - Valid inputs | ✅ PASS | Derived roots appended after default pair; derived roots appended after override roots; drive-letter root kept whole; `;`, `:` and newline separators; drive-letter source_path rejected as absolute. **Total positive tests:** 9 |
| **Negative Flows** - Invalid inputs | ✅ PASS | Relative override segment dropped with a stderr diagnostic; relative, drive-relative (`C:rel`) and empty paths classified non-absolute. **Total negative tests:** 2 |
| **Edge Cases** - Boundary conditions | ✅ PASS | Empty segments (`::`, trailing `;;`); glob `/*` kept literally; case-variant duplicate (`/Scratch/PlanHome`) emitted once; prefix boundary (`/repo/main-wt/a-wt` kept although `/repo/main-wt/a` is registered); five exclusion classes asserted absent. **Total edge case tests:** 4 |
| **Error Handling** - Error paths | ✅ PASS | `parse_worktree_list` hard failure with override emits exactly the override roots (new test); hard failure with no override emits no root (pre-existing test 450, unchanged and passing). **Total error handling tests:** 2 |
| **Concurrency** - If applicable | N/A | Pure string functions in a single-process CLI; no concurrency. |
| **State Transitions** - If applicable | N/A | The functions are stateless. |

### 1.2.1 Per-Language Coverage Comparison

- Bash: Baseline: 93.7% lines -> Post-change: 93.8% lines. Change: +0.1% lines. New/changed-code coverage: 98.8% (82 of 83 instrumented changed lines). Disposition: PASS. Evidence: CI runs 36978610292 and 36982722154 `shell-coverage` artifacts; `evidence/qa-gates/shell-coverage-ci.2026-10-02T04-21.md`; `evidence/qa-gates/coverage-delta.2026-10-02T04-22.md`.

Per-file Bash line rates (final run 36982722154; threshold 85%):

| File | Baseline | Final | Status |
|---|---|---|---|
| `cleanup_worktrees_enumerate_lib.sh` | 92.4% (85/92) | 95.3% (164/172) | PASS |
| `cleanup_worktrees_report_records_lib.sh` | 89.0% (162/182) | 87.9% (145/165) | PASS (uncovered set unchanged) |
| `cleanup_worktrees_preserve_lib.sh` | 90.6% (192/212) | 90.6% (192/212) | PASS |
| `cleanup_worktrees_scan_helper.sh` | 87.5% (49/56) | 87.3% (48/55) | PASS (uncovered set unchanged) |
| `cleanup-worktrees.sh` | 97.6% (41/42) | 97.6% (41/42) | PASS |

Branch coverage: not applicable to Bash; kcov does not measure branch coverage (`.claude/rules/shell.md`, `.claude/rules/quality-tiers.md`).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Predicate tests print each misclassified candidate (`classified relative: [..]`); the exclusion test echoes `excluded root emitted: <line>`; count-based assertions neutralize `grep -c` exit 1 so the count is reported. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Arrange via fixture scenario and env; Act via the runner; Assert via `[ ... ]` checks on `$status`, `${lines[@]}` and `$output`. |
| **Document Intent** | ✅ PASS | Each test carries a comment naming the AC it verifies and the scenario. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, no real git repository, no real filesystem scan outside checked-in fixture trees. |
| **Use Mocks/Stubs** | ✅ PASS | `tests/fixtures/cleanup_worktrees/stub-bin/git` and `stub-bin/scan` through the existing seams; function-override seam for `cleanup_wt_is_absolute_path` and `scan_helper_target_present`. |
| **Environment Stability** | ✅ PASS | `grep -n -E "mktemp|BATS_TMPDIR|BATS_TEST_TMPDIR|tee "` over both changed bats files returned no match; no test writes a file. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, `code-review.2026-10-02T04-30.md`, and `feature-audit.2026-10-02T04-30.md` form the review set. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` Summary, Scope Decisions, and AC-1..AC-12. |
| **Read existing change plans** | ✅ PASS | `research/research.2026-09-29T22-35.md`; preflight rounds 1 and 2 under `evidence/other/`. |
| **Document the plan** | ✅ PASS | `plan.2026-09-29T22-26.md` with `## Plan deviations` DEV-1..DEV-8. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Three small pure functions plus a rewritten composer; the splitter is a single character walk with no word splitting. |
| **Reusability** | ✅ PASS | One shared `cleanup_wt_is_absolute_path` replaces two duplicate predicates; `normalize_wt_path` reused for dedup and exclusion; one file-local `run_helper_sourced` replaces three inline loaders. |
| **Extensibility** | ✅ PASS | Override and derived roots are composed in one place; separator contract documented in code, usage text, and `SKILL.md`. |
| **Separation of concerns** | ✅ PASS | Root derivation and splitting are pure string functions; filesystem access stays behind `CLEANUP_WT_SCAN_BIN`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Root composition moved next to `parse_worktree_list` and `normalize_wt_path` in the enumeration library, which every consumer already sources first. |
| **Under 500 lines** | ✅ PASS | `wc -l`: enumerate_lib 416, report_records_lib 439, preserve_lib 492, scan_helper 171, cleanup-worktrees.sh 243, test_cleanup_worktrees_scan_roots.bats 242, test_cleanup_worktrees_scan_helper.bats 77. `SKILL.md` (579) is Markdown and exempt. |
| **Public vs internal** | ✅ PASS | Functions follow the existing `cleanup_wt_` prefix convention; `scan_helper_is_absolute_path` removed with no remaining reference (structural grep). |
| **No circular dependencies** | ✅ PASS | The scan helper sources the enumeration library; the enumeration library sources nothing. Preserve-library consumers (wrapper and four bats suites) all source the enumeration library first (Grep over the repository). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `cleanup_wt_split_roots`, `cleanup_wt_derive_scan_roots`, `cleanup_wt_is_absolute_path`. |
| **Docs/docstrings** | ✅ PASS | Each new function has a header comment stating purpose, arguments, return contract and rationale. |
| **Comment why, not what** | ✅ PASS | Comments explain why ancestors are excluded, why relative entries are dropped, and why no word splitting is used. One stale cross-file line reference (Minor M-1). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `shfmt -d <5 changed .sh files>` (re-run by this review, exit 0) and CI `shell-qc.sh check` on `10c6ac29` (success). |
| **2. Linting** | ✅ PASS | **Command:** `shellcheck <5 changed .sh files>` (re-run by this review, exit 0) and CI `shell-qc.sh check` (success). |
| **3. Type checking** | N/A | Bash has no type-check stage (`.claude/rules/shell.md`). |
| **4. Testing** | ✅ PASS | **Command:** CI `shell-qc.sh test --coverage`, run 36982722154: `1..521`, 0 `not ok` (verified by this review from the run log). |
| **Full toolchain loop** | ✅ PASS | CI run on the final production head passed format, lint and test in one pass. |
| **Explicit reporting** | ✅ PASS | Commands and results recorded under `evidence/` and in this audit. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `598691e7` message and `evidence/other/small-audit-handoff.2026-10-02T04-24.md`. |
| **Design choices explained** | ✅ PASS | `issue.md` Scope Decisions; function header comments. |
| **Update supporting documents** | ✅ PASS | Wrapper usage text and `SKILL.md` `ORPHAN_DIR` bullet updated and mirrored. |
| **Provide next steps** | ✅ PASS | Non-blocking follow-ups listed in Section 8. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | ✅ PASS | **Command:** `shfmt -d` (local v3.12.0, exit 0) and CI `bash scripts/bash/shell-qc.sh check` (shfmt 3.8.0, success on `10c6ac29`). |
| **Linting with shellcheck** | ✅ PASS | **Command:** `shellcheck` (local 0.11.0, exit 0) and CI `shell-qc.sh check` (success). One new `# shellcheck disable=SC1091` in `cleanup_worktrees_scan_helper.sh:44` has no inline reason (Minor M-2, non-blocking). |
| **Testing with bats** | ✅ PASS | **Command:** CI `bash scripts/bash/shell-qc.sh test --coverage` (run 36982722154): 521 ok, 0 not ok. Local bats was not run under the binding operator decision (DEV-2); CI evidence is accepted per that decision. |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | ✅ PASS | Executable scripts keep `#!/usr/bin/env bash`; libraries are sourced. |
| **Error handling** | ✅ PASS | `cleanup_wt_scan_roots` captures `parse_worktree_list` with `|| rc=$?` and degrades to override-only or no roots; the scan helper keeps `set -euo pipefail`; relative override entries are rejected with a stderr diagnostic. |
| **Under 500 lines** | ✅ PASS | See Section 2.3. |

Sections 3A (Python), 3B (PowerShell), and 3D (JSON): N/A, no files of those languages changed.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4C: Bash (bats) Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Location** | ✅ PASS | Tests are in `tests/shell/*.bats`, the repository's established location for skill-bundled bash scripts. |
| **No temporary files** | ✅ PASS | Checked-in fixture `scan_roots_derived/worktree-list.out`; no file writes. |
| **Stubs through seams** | ✅ PASS | `CLEANUP_WT_GIT_BIN`, `CLEANUP_WT_SCAN_BIN`, `CLEANUP_WT_STUB_SCENARIO`. |
| **kcov compatibility** | ✅ PASS | Scan-helper sourcing kept inside a function (`source_helper`) per the kcov `BASH_SOURCE`/nounset constraint; rationale stated once (AC-8). |
| **Coverage expectation** | ✅ PASS | All changed production files >= 85% line coverage (Section 1.2.1). |

Sections 4A (Python) and 4B (PowerShell): N/A, no files of those languages changed.

---

## 5. Test Coverage Detail

### cleanup_wt_scan_roots / cleanup_wt_derive_scan_roots (6 new tests + 3 pre-existing)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| appends registration-derived parents after the default pair | Positive | enumerate_lib 319-416 | ✅ |
| excludes the main worktree, its ancestors, and paths equal to or inside a registered worktree | Edge Case | 319-372 | ✅ |
| appends derived roots after the override roots | Positive | 374-416 | ✅ |
| emits exactly the override roots when the worktree listing hard-fails | Error Handling | 374-416 | ✅ |
| run_report passes a registration-derived root to its single filesystem scan | Positive (integration of report path) | report_records 124-144 | ✅ |
| pre-existing: derives both roots / honors override / emits no root on hard failure | Positive / Error Handling | 374-416 | ✅ |

**Coverage:** 164/172 instrumented lines in enumerate_lib (95.3%); changed lines 79/80.

**Not covered:** line 370 (`done < <(...)` terminator; the loop body on line 369 is hit, so this is most likely a kcov attribution effect).

### cleanup_wt_split_roots (7 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| keeps a drive-letter root whole | Positive | 273-317 | ✅ |
| splits colon-separated drive-letter roots | Positive | 273-317 | ✅ |
| splits on semicolons | Positive | 273-317 | ✅ |
| splits on newlines | Positive | 273-317 | ✅ |
| drops empty segments | Edge Case | 273-317 | ✅ |
| keeps a glob character literally | Edge Case | 273-317 | ✅ |
| drops a relative segment with a stderr diagnostic | Negative | 273-317 | ✅ |

### cleanup_wt_is_absolute_path and preserve_relative_path_reason (4 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| returns 0 for slash-leading and drive-letter paths | Positive | 257-271 | ✅ |
| returns non-zero for relative, drive-relative, and empty paths | Negative | 257-271 | ✅ |
| preserve_relative_path_reason honors an override of the shared predicate | Positive (call-site proof) | preserve_lib 161 | ✅ |
| preserve_relative_path_reason rejects a drive-letter source_path | Positive | preserve_lib 161-162 | ✅ |

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 521 (bats, CI) | ✅ |
| Tests Passed | 521 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | about 5 min for the CI kcov job | ✅ Acceptable for kcov-instrumented run |
| Average Time per Test | not separately reported by CI | N/A |
| Discovery Time | not separately reported by CI | N/A |
| Functions/Classes Tested | 4/4 new or moved functions | ✅ |
| Test File Size | 242 and 77 lines | ✅ Maintainable |
| Code Coverage | 93.8% lines (Bash aggregate); branch not measured by kcov | ✅ |

---

## 7. Code Quality Checks

**For Bash:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| shfmt | `shfmt -d <changed .sh>` | no diff, exit 0 | ✅ |
| shellcheck | `shellcheck <changed .sh>` | no findings, exit 0 | ✅ |
| bats + kcov | CI `shell-qc.sh test --coverage` run 36982722154 | 521 ok, 93.8% | ✅ |
| Mirror parity | `cmp -- <canonical> <mirror>` for 6 files | all identical | ✅ |
| Bundle contract | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 14 passed (executor evidence) | ✅ |

**Notes:** Python, TypeScript, PowerShell and C# toolchains were not run because no files of those languages changed. The commit after `10c6ac29` (`5c783c06`) changes only feature-folder documents (`git diff --name-only 10c6ac29 HEAD`), so the CI results apply to the current head's code.

---

## 8. Gaps and Exceptions

### Identified Gaps

No blocking gap. Non-blocking observations:

- M-1 (Minor, non-blocking): `cleanup_worktrees_detached_lib.sh:46` (and its mirror) cites `cleanup_worktrees_enumerate_lib.sh:115-116`; the header grew by three lines, so the cited lines are now 118-119. The file is outside the branch diff; the drift is a side effect of this change.
- M-2 (Minor, non-blocking): `cleanup_worktrees_scan_helper.sh:44` adds `# shellcheck disable=SC1091` without an inline reason, while `.claude/rules/shell.md` asks for the reason to be stated. The paired `# shellcheck source=` directive names the target, and the same bare form is used at more than ten existing sites (for example `cleanup-worktrees.sh:22-52`, `.claude/lib/bash/compute-cohorts.sh:31`). No lint or behavior risk.
- M-3 (Minor, non-blocking): `cleanup_wt_derive_scan_roots` does not pass derived candidates through `cleanup_wt_is_absolute_path`. A registered worktree located directly under a drive root on a drive other than the main worktree's (for example `D:/wt`) would produce the drive-relative candidate `D:`. The record is advisory and read-only, and git porcelain paths are absolute, so the impact is limited to an extra scan root.
- N-1 (Nit, non-blocking): no test drives a backslash-form registration path (`C:\x\y`) through the derivation's `${paths[i]//\\//}` conversion.

### Approved Exceptions

- DEV-2 (operator decision 2026-10-01, Option A): bats and kcov evidence is taken from CI `_shell-coverage.yml` runs on pushed heads instead of local runs. Accepted as binding.

### Removed/Skipped Tests

1. **"scan_helper_is_absolute_path returns 0 ..."** and **"scan_helper_is_absolute_path returns non-zero ..."** - removed from `test_cleanup_worktrees_scan_helper.bats` in `48c6023d`/`598691e7`.
   - **Reason:** the predicate moved to `cleanup_wt_is_absolute_path`.
   - **Impact:** none; the same #706 cases run against the shared function in `test_cleanup_worktrees_scan_roots.bats` (tests 467-468).
   - **Justification:** AC-7 requires the cases to pass against the shared function.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **b3ee174f** - docs(741): add feature folder and research for scan-root derivation
2. **5d2c81d9** - docs(741): add acceptance criteria and scope decisions
3. **74e946aa** - docs(741): add minimal-audit atomic plan
4. **92d30be5** - docs(741): record preflight round 1 (revisions required)
5. **f6d04e1c** - docs(741): revise plan per preflight round 1
6. **f9d25326** - docs(741): record preflight round 2 (all clear)
7. **df5eb303** - Merge remote-tracking branch 'origin/main'
8. **99fba25a** - docs(741): record Phase 0 baseline evidence and plan deviations
9. **48c6023d** - test(741): add scan-roots suite and derived-roots fixture
10. **71983f41** - docs(741): record CI-sourced baseline and expect-fail evidence
11. **598691e7** - fix(741): derive cleanup-worktrees scan roots from registrations and split orphan roots drive-safely
12. **0bc8061c** - docs(741): record CI-sourced pass-after evidence and Phase 1 completion
13. **10c6ac29** - docs(741): record Phase 2 QA gate evidence and plan deviations
14. **5c783c06** - docs(741): record final CI coverage, coverage delta, AC check-off, and audit handoff

### Files Modified

1. **`.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh`** (MODIFIED) - adds `cleanup_wt_is_absolute_path`, `cleanup_wt_split_roots`, `cleanup_wt_derive_scan_roots`, and the rewritten `cleanup_wt_scan_roots`.
2. **`.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh`** (MODIFIED) - removes the old `cleanup_wt_scan_roots`; header comments updated.
3. **`.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh`** (MODIFIED) - line 161 calls the shared predicate.
4. **`.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`** (MODIFIED) - sources the enumeration library; local predicate removed.
5. **`.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`** (MODIFIED) - usage text for `CLEANUP_WT_ORPHAN_ROOTS`.
6. **`.claude/skills/cleanup-merged-worktrees/SKILL.md`** (MODIFIED) - `ORPHAN_DIR` bullet.
7. **Six mirrors under `extensions/drm-copilot/resources/claude-customizations/`** (MODIFIED) - byte-identical copies.
8. **`tests/shell/test_cleanup_worktrees_scan_roots.bats`** (NEW) - 16 tests.
9. **`tests/shell/test_cleanup_worktrees_scan_helper.bats`** (MODIFIED) - `run_helper_sourced` helper; predicate tests moved.
10. **`tests/fixtures/cleanup_worktrees/scenarios/scan_roots_derived/worktree-list.out`** (NEW) - ten-registration fixture.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All evaluated policy requirements pass. Four non-blocking observations (M-1, M-2, M-3, N-1) are recorded for optional follow-up; none affects correctness of the delivered behavior or any gate.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan, research and preflight present
- ✅ Design Principles: one shared predicate; pure root functions
- ✅ Module & File Structure: all files under 500 lines
- ✅ Naming, Docs, Comments: complete; one stale cross-reference (M-1)
- ✅ Toolchain Execution: shfmt, shellcheck, bats all clean
- ✅ Summarize & Document: usage text and SKILL.md updated

#### Language-Specific Code Change Policy (Section 3)

**For Bash:**
- ✅ Tooling & Baseline: shfmt and shellcheck clean locally and in CI
- ✅ Bash Script Design: error handling and fail-safe degradation preserved
- ✅ Structure: under 500 lines; bare SC1091 suppression noted (M-2)

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independent, isolated, deterministic
- ✅ Coverage & Scenarios: 93.8% aggregate; 98.8% changed lines
- ✅ Test Structure: AAA with diagnostic output
- ✅ External Dependencies: stubs only; no temporary files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Bash:**
- ✅ Framework & Scope: bats under `tests/shell/`
- ✅ Test Style & Structure: file-local runners; one kcov-safe loader
- ✅ Naming & Readability: AC-tagged test names
- ✅ Toolchain: CI `shell-qc.sh test --coverage`

---

### Metrics Summary

- ✅ 521/521 bats tests passing (100%)
- ✅ 4/4 new or moved functions tested
- ✅ 93.8% Bash line coverage (baseline 93.7%)
- ✅ 98.8% changed-line coverage (82/83)
- ✅ Every changed production file at or above 85% line coverage (lowest 87.3%)
- ✅ Mirror parity verified for all six files

---

### Recommendation

**Ready for merge**

No blocking finding. Optional follow-ups: refresh the line reference in `cleanup_worktrees_detached_lib.sh:46` (M-1), add a one-line reason to the scan-helper SC1091 suppression (M-2), guard derived candidates with the shared absolute-path predicate (M-3), and add a backslash-path derivation test (N-1).

---

## Appendix A: Test Inventory

### Complete Test List

`tests/shell/test_cleanup_worktrees_scan_roots.bats` (new, CI TAP 455-470):
1. cleanup_wt_scan_roots appends registration-derived parents after the default pair
2. cleanup_wt_scan_roots excludes the main worktree, its ancestors, and paths equal to or inside a registered worktree
3. cleanup_wt_scan_roots appends derived roots after the override roots
4. cleanup_wt_scan_roots emits exactly the override roots when the worktree listing hard-fails
5. CLEANUP_WT_ORPHAN_ROOTS keeps a drive-letter root whole
6. CLEANUP_WT_ORPHAN_ROOTS splits colon-separated drive-letter roots
7. CLEANUP_WT_ORPHAN_ROOTS splits on semicolons
8. CLEANUP_WT_ORPHAN_ROOTS splits on newlines
9. CLEANUP_WT_ORPHAN_ROOTS drops empty segments
10. CLEANUP_WT_ORPHAN_ROOTS keeps a glob character literally
11. CLEANUP_WT_ORPHAN_ROOTS drops a relative segment with a stderr diagnostic
12. run_report passes a registration-derived root to its single filesystem scan
13. cleanup_wt_is_absolute_path returns 0 for slash-leading and drive-letter paths
14. cleanup_wt_is_absolute_path returns non-zero for relative, drive-relative, and empty paths
15. preserve_relative_path_reason honors an override of the shared absolute-path predicate
16. preserve_relative_path_reason rejects a drive-letter source_path as absolute

`tests/shell/test_cleanup_worktrees_scan_helper.bats` (modified, CI TAP 452-454):
1. scan-dirs emits has_gitfile/target_exists/size for each candidate directory
2. scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory
3. scan-dirs reports target_exists 0 for a drive-letter gitdir target that does not exist

`tests/shell/test_cleanup_worktrees_report_records.bats` (unchanged; relevant tests CI TAP 448-450):
1. cleanup_wt_scan_roots derives both roots from the main worktree path
2. cleanup_wt_scan_roots honors the CLEANUP_WT_ORPHAN_ROOTS override
3. cleanup_wt_scan_roots emits no root when the worktree listing hard-fails

---

## Appendix B: Toolchain Commands Reference

Commands run by this review:

```bash
# Scope and PR context
git diff --name-only origin/main...HEAD
git diff origin/main...HEAD -- .claude/skills/cleanup-merged-worktrees/
poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main

# Formatting and linting (changed production scripts)
shfmt -d .claude/skills/cleanup-merged-worktrees/scripts/{cleanup_worktrees_enumerate_lib,cleanup_worktrees_report_records_lib,cleanup_worktrees_preserve_lib,cleanup_worktrees_scan_helper}.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh
shellcheck <same five files>

# Mirror parity
cmp -- .claude/skills/cleanup-merged-worktrees/<f> extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/<f>

# Evidence locations
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .

# CI evidence (read-only)
gh run view 36978610292 --json conclusion,headSha
gh run view 36979697644 --json conclusion,headSha
gh run view 36981519472 --json conclusion,headSha
gh run view 36982722154 --json status,conclusion,headSha,workflowName
gh run view 36982722154 --log
gh run download 36978610292 -n shell-coverage
gh run download 36982722154 -n shell-coverage
# Baseline/final cov.xml comparison of uncovered-line source text (session scratchpad script, not committed)
```

Repository shell toolchain (CI canonical, per `.claude/rules/shell.md`):

```bash
bash scripts/bash/shell-qc.sh check
bash scripts/bash/shell-qc.sh test --coverage
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-10-02  
**Policy Version:** Current (as of audit date)
