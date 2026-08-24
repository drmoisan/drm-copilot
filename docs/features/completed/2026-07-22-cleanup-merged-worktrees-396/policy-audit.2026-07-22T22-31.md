# Policy Compliance Audit: cleanup-merged-worktrees (Issue #396) — Remediation Cycle 3 Re-audit (Final Pass)

---

**Audit Date:** 2026-07-22
**Audit Type:** Remediation cycle 3 re-audit — final pass of the 3-pass remediation cap (prior audits: `policy-audit.2026-07-22T09-23.md`, `policy-audit.2026-07-22T10-00.md`, `policy-audit.2026-07-22T21-16.md`)
**Code Under Test:**
- `scripts/bash/cleanup-worktrees.sh` (92 lines — CLI wrapper, unchanged in cycle 3)
- `scripts/bash/cleanup_worktrees_enumerate_lib.sh` (236 lines — enumeration/protection; cycle-3 fixes to `enumerate_branches` and `compute_protected`)
- `scripts/bash/cleanup_worktrees_lib.sh` (476 lines — classification ladder; cycle-3 fixes at both NEW-1 diff-tree sites, the D-rung ls-tree conversion, the minus-present structural removal, and `run_report` up-front captures)
- `scripts/bash/cleanup_worktrees_actions_lib.sh` (382 lines — consolidation/deletion/apply driver; cycle-3 fixes for NEW-4 and consumers, `run_apply` up-front captures and classification rc propagation, and two fail-closed idiom conversions)
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` and its bundled mirror (unchanged since cycle 1)
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (MODIFIED in cycle 1; unchanged since)
- `tests/shell/test_cleanup_worktrees_{enumeration,classification,consolidation,deletion,cli,hard_failures}.bats` (6 suites; `test_cleanup_worktrees_hard_failures.bats` is NEW in cycle 3, 17 tests, 172 lines)
- `tests/fixtures/cleanup_worktrees/**` (8 new cycle-3 scenario directories; stub extended with the `ls-tree` KEY)
- `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/**` (scoping docs, plans, research, evidence, review artifacts)

**Review scope:** full branch diff `b2351cbc..6c891b73` (base `main`, merge base `b2351cbc3fb3916f516d77567a1c9e40457c8981`), 255 files, +6985/-0. Languages with changed files: Bash (shell), Markdown, and JSON (one pack-manifest config file). Python, TypeScript, PowerShell, and C# have zero changed source files on this branch.

**Cycle-3 delta re-audited (commits `556749f8`, `a1b39a4d`, `6c891b73`):**
- `556749f8` — cycle-3 hard-failure suite (17 tests), 8 scenario fixtures, stub `ls-tree` KEY.
- `a1b39a4d` — the cycle-3 production fix: guarded parent-shell capture at every UNGUARDED site in the plan's exhaustive call-site audit (NEW-1 both sites, NEW-2, NEW-3 both consumers plus the enumerate pipeline, NEW-4 plus both consumers, the D-rung ls-tree conversion, the minus-present structural removal, the `run_apply` classification rc capture, and the two fail-closed consistency conversions).
- `6c891b73` — cycle-3 QA evidence and plan check-offs (docs only; verified with `git diff --name-only a1b39a4d..HEAD`).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Bash | 5 shell files (4 production + 1 test stub) + 6 bats suites | 102 total (17 new in cycle 3) | PASS 102 pass, 0 fail (CI run 29973982957) | 90.4% lines (run 29970805348) | 91.5% lines | classification lib 93.2%, enumerate lib 92.1%, wrapper 100.0%, actions lib 92.8% (all at or above 85%) |
| Markdown | ~60 docs/evidence/review files | N/A | N/A (docs) | N/A | N/A | N/A |
| JSON | 1 config manifest (`core.json`, cycle-1 change) | 9 contract tests | PASS (verified in cycle-1 re-audit; file unchanged since) | N/A (config manifest, verified by contract tests) | N/A (config manifest, verified by contract tests) | N/A (config manifest, verified by contract tests) |

Coverage verdicts (explicit, per language with changed files):
- **Bash: PASS.** Repo-wide 91.5% lines at or above 85% and above the 90.4% cycle-2 baseline (no regression, +1.1). Per-file: `cleanup-worktrees.sh` 100.0%, `cleanup_worktrees_lib.sh` 93.2%, `cleanup_worktrees_enumerate_lib.sh` 92.1%, `cleanup_worktrees_actions_lib.sh` 92.8%. Branch coverage is not measurable by kcov for bash; per `.claude/rules/shell.md` there is no bash branch-coverage gate. Independently re-verified in this re-audit by parsing the downloaded CI artifact `artifacts/pester/kcov-ci/cov.xml` (Cobertura line-rate: overall 0.915; per-class 1.000 / 0.932 / 0.921 / 0.928 — exact match to the evidence artifact). The green run 29973982957 is at `a1b39a4d`; the delta `a1b39a4d..6c891b73` is six `docs/features/**` files (verified with `git diff --name-only`), so the run is representative of head code content. The enumerate lib moved 95.1% -> 92.1% per-file (still above the 85% floor); the plan's no-regression comparison is on the overall figure, which improved.
- **JSON (`core.json`): PASS.** Config manifest, not a coverage-bearing language; unchanged since the cycle-1 re-audit that verified it (contract tests 9/9, CI run 29925971964).
- Python: N/A (zero changed files). TypeScript: N/A (zero changed files). PowerShell: N/A (zero changed files). C#: N/A (zero changed files).

### Coverage Evidence Checklist

- Bash baseline coverage artifact: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/remediation-baseline/coverage-baseline-reference.2026-07-22T21-16.md` (run 29970805348, 90.4% lines)
- Bash post-change coverage artifact: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/qa-gates/final-shell-coverage-ci.2026-07-22T21-16.md` (run 29973982957, 91.5% lines) plus downloaded `artifacts/pester/kcov-ci/cov.xml` (re-parsed by this reviewer)
- Per-language comparison summary: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/qa-gates/coverage-delta.2026-07-22T21-16.md` and section 1.2.1 below
- TypeScript baseline coverage artifact: `N/A - out of scope (zero changed TypeScript files on this branch)`
- TypeScript post-change coverage artifact: `N/A - out of scope (zero changed TypeScript files on this branch)`
- PowerShell baseline coverage artifact: `N/A - out of scope (zero changed PowerShell files on this branch)`
- PowerShell post-change coverage artifact: `N/A - out of scope (zero changed PowerShell files on this branch)`
- Python / C# artifacts: `N/A - zero changed files on this branch`

**Threshold basis (assumption documented):** the uniform tier rule per `.claude/rules/quality-tiers.md` (Authoritative Decision #2) applies: line coverage at or above 85% for new files, modified files, and repo-wide, with no regression. The 90% "new code" figure in the legacy policy-audit template text is superseded by the uniform rule (precedent: #393 and the prior #396 cycle audits). All files pass under either reading.

---

## Rejected Scope Narrowing

None detected. The caller instruction requested "the full feature-review-workflow SKILL contract end-to-end against this branch's diff versus main (same scope as before, no scope narrowing)" and additionally directed an independent, line-by-line sweep of every git invocation in the three libraries and the CLI wrapper, not limited to the previously named findings. The audit scope is the full feature-vs-base diff `b2351cbc..6c891b73`. The remediation plan's scope statements are executor scope constraints, not audit scope constraints, and were not applied to this audit.

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` -> exit 0 (no violations), re-run in this cycle.
- Branch diff inspection (`git diff --name-only origin/main...HEAD`): zero files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All feature evidence lives at the canonical `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/{baseline,qa-gates,remediation-baseline,regression-testing,other}/` paths. **PASS.**

---

## Executive Summary

This re-audit confirms remediation cycle 3 resolved every open fail-open finding (NEW-1 both sites, NEW-2, NEW-3, NEW-4) and every additional unguarded site identified by the plan's exhaustive call-site audit. This is the final pass of the 3-pass remediation cap; the caller directed maximal thoroughness on one question: does any git invocation remain anywhere in the three libraries or the CLI wrapper whose exit status is discarded, captured in an unreachable subshell, or otherwise not checked before its output is treated as authoritative for a classification or protection decision?

**Answer: no.** This reviewer performed an independent, line-by-line sweep of all four production files at head (`6c891b73`), enumerating every `cleanup_wt_git` invocation and every consumer of a git-backed producer, without reference to the plan's own audit table. Findings of the sweep:

1. **Zero fail-open sites remain.** Every authoritative git read uses guarded parent-shell capture (`out=$(cmd) || rc=$?` with an explicit rc branch) or an rc-mapped verdict ladder (`|| rc=$?` with 0/1/>1 mapping where non-zero is expected). The idiom grep over the three libraries finds zero `< <(...)` or `mapfile`/`readarray` reads over git-backed producers and zero `|| true` on an authoritative git capture. The only surviving `< <(` is `done < <(printf '%s\n' "$ce")` (a local variable, not git); every surviving `|| true` is non-git (arithmetic, grep on a captured variable) or an accepted best-effort site whose failure direction is fail-closed (Design Decision 9, documented in the actions-lib header and re-verified individually in this sweep).
2. **The fixes are genuine and behavior-verified.** Fail-before evidence is a deliberate red CI run 29972970639 at `556749f8` with exactly the 13 constructible fail-before tests failing and the pre-fix fail-open verdicts recorded per site; pass-after is green run 29973982957 at `a1b39a4d` (102/102). The three structurally-unfailable sites are covered by the exception dossier `fail-before-exception.2026-07-22T21-16.md`. This reviewer additionally reproduced six fixed paths locally under the checked-in stub (diff_tree_error, ls_tree_error, rev_parse_error_protection, enumerate_error via run_report and run_apply, consolidation_path_error) — all now fail closed with the required verdicts — plus both D-rung behavior-preservation guards.
3. **A novel reviewer-built probe confirms the accepted-safe classification.** A scratchpad-only stub scenario (no repository mutation) injecting a hard `git rev-parse <branch>:<path>` failure (rc 128) into `_blob_equal` on an A-status residual yields `UNIQUE|<path>` -> `BRANCH|...|NOT_MERGED` — fail-closed as this sweep predicted; no delete-eligible verdict is reachable from that failure.
4. **CI and coverage:** run 29973982957 confirmed green via `gh run view` (headSha `a1b39a4d`, conclusion success, this branch); `a1b39a4d..HEAD` is docs-only; coverage re-parsed from the downloaded Cobertura artifact and matches the evidence exactly (overall 91.5%; all four production files at or above 92.1%; no overall regression).
5. **Format/lint:** local `shfmt -d` and `shellcheck` over the four production files are clean (reviewer corroboration); executor evidence `final-shell-format.2026-07-22T21-16.md` and `final-shell-check.2026-07-22T21-16.md` record exit 0 in a single clean pass.
6. **Header contracts are now true.** The classification-lib header claim "A hard git failure never resolves to a MERGED_* verdict" — falsified in cycle 2 — now holds under every reproduction attempted.

The remaining findings are the two accepted Minors carried since cycle 1 (CR-2 stub-marker re-emission, CR-4 call-graph redundancy) and one Info-level, spec-inherent observation newly recorded by this sweep (a branch whose `main..branch` range contains only merge commits — for example an evil-merge conflict resolution — produces empty `git cherry` output and classifies MERGED_EQUIVALENT; this is a semantic property of the AC2-prescribed cherry/patch-id ladder with truthful git exit codes, not an exit-status defect; see `code-review.2026-07-22T22-31.md`). None of these is a remediation trigger.

No `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` paths are modified anywhere in the branch diff, so the `modified-workflow-needs-green-run` rule does not fire; green branch-content CI runs exist regardless.

**Policy documents evaluated:**
- PASS `general-code-change` policy (`.claude/rules/general-code-change.md`)
- PASS `general-unit-test` policy (`.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- PASS Bash: `.claude/rules/shell.md` (shfmt + shellcheck + bats + kcov) — all gates green at head code content.
- PASS JSON manifest: unchanged since cycle-1 verification.
- N/A Python, PowerShell, TypeScript, C#: zero changed files.
- PASS Tonality (`.claude/rules/tonality.md`): cycle-3 plan, evidence, code comments, and test comments use neutral, factual language.

**Temporary artifacts cleanup:**
- PASS No temporary or throwaway scripts in the diff. Reviewer reproductions used session-scratchpad fixtures outside the repository.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | The 17 new hard-failure tests are scenario-isolated via `CLEANUP_WT_STUB_SCENARIO`; each test sources the libraries in a fresh `bash -c` process. CI TAP order-independent. |
| **Isolation** | PASS | Each test targets one function-level failure mode under one injected git failure; assertions name the exact required verdict and status. |
| **Fast Execution** | PASS | Stub-driven; no real git repositories; the 102-test suite completes within the CI job without timeout. |
| **Determinism** | PASS | Canned fixture outputs and exit codes; no time, randomness, or network. |
| **Readability & Maintainability** | PASS | Every test carries an intent comment naming the finding (NEW-1..NEW-4, D-rung, conversions) and the required post-fix behavior. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | 90.4% lines (run 29970805348) recorded in `evidence/remediation-baseline/coverage-baseline-reference.2026-07-22T21-16.md` before the cycle-3 changes. |
| **No Coverage Regression** | PASS | Post-change 91.5% lines (+1.1 overall). Re-parsed from `cov.xml` by this reviewer. Per-file all at or above 92.1% for the four in-scope files. |
| **New Code Coverage** | PASS | Modified `cleanup_worktrees_lib.sh` 93.2% (was 90.2%), `cleanup_worktrees_enumerate_lib.sh` 92.1%, `cleanup_worktrees_actions_lib.sh` 92.8% (was 89.8%); new test suite excluded from coverage denominator per policy. |
| **Comprehensive Coverage** | PASS | Hard-failure scenarios now cover every previously untested fail-open path: diff-tree (both call shapes), ls-tree D-rung, rev-parse protection, for-each-ref enumeration, worktree-list in apply mode, consolidation-path derivation and both consumers, plus fail-closed conversion guards. |
| **Positive/Negative/Edge/Error** | PASS | AC8 scenarios, cycle-2 error paths, cycle-3 error paths, and two behavior-preservation pairs (deleted-path present/absent on main). |
| **Concurrency** | N/A | Single-process CLI tool. |

### 1.2.1 Per-Language Coverage Comparison

- Bash: Baseline: 90.4% lines -> Post-change: 91.5% lines. Change: +1.1% lines. New/changed-code coverage: 92.1% minimum per changed production file (93.2% classification lib, 92.1% enumerate lib, 92.8% actions lib, 100.0% wrapper). Disposition: PASS. Evidence: `evidence/qa-gates/coverage-delta.2026-07-22T21-16.md`, `artifacts/pester/kcov-ci/cov.xml` (reviewer re-parse), CI run 29973982957.
- TypeScript: `N/A - zero changed files on this branch`.
- Python: `N/A - zero changed files on this branch`.
- PowerShell: `N/A - zero changed files on this branch`.
- C#: `N/A - zero changed files on this branch`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Exact-match assertions on report lines and status codes; negative assertions explicitly exclude each delete-eligible verdict; bats prints the failing assertion line. |
| **Arrange-Act-Assert Pattern** | PASS | Scenario env (arrange), `run env ... bash -c` (act), status/output assertions (assert), via the shared `runin` helper. |
| **Document Intent** | PASS | Suite header and per-test comments name the pre-fix fail-open behavior and the required post-fix behavior. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | Git fully stubbed via `CLEANUP_WT_GIT_BIN`; no real repository, network, or filesystem mutation. |
| **Use Mocks/Stubs** | PASS | Checked-in recording git stub replaying canned fixtures; writes nothing to disk; new `ls-tree` KEY documented in the stub header. |
| **Environment Stability** | PASS | No temporary files anywhere in the test suites; all 8 new scenario directories are checked in. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This re-audit document plus the three prior cycle audits. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `remediation-inputs.2026-07-22T21-16.md` names each finding, line, consequence, and required fix; the plan adds an exhaustive call-site audit table verified against head (P1-T1, `callsite-audit.2026-07-22T21-16.md`). |
| **Read existing change plans** | PASS | `evidence/remediation-baseline/phase0-instructions-read.2026-07-22T21-16.md` records the P0-T1 policy reading order. |
| **Document the plan** | PASS | `remediation-plan.2026-07-22T21-16.md` (6 phases, all tasks checked), with binding design decisions on the capture pattern, internal hard-error tokens, D-rung ls-tree disambiguation, driver up-front captures, and the fail-before exception dossier. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | One uniform guarded-capture pattern applied at every fixed site; hard errors reuse the existing `ANCESTRY_ERROR` report state via internal tokens rather than new report states; the minus-present fix removes a call rather than guarding it. |
| **Fail fast and explicitly** | PASS | Every authoritative git read observes its exit status in the parent shell and fails closed with a stderr diagnostic and/or a hard-error verdict. Reviewer sweep found zero remaining silent-error paths on authoritative reads. |
| **Scope discipline** | PASS | Cycle-3 delta touches exactly the planned files; CR-2/CR-4 accepted Minors untouched; CR-1/CR-3 not reopened. |
| **Fail-before / pass-after evidence** | PASS | Red run 29972970639 (exactly the 13 constructible fail-before tests failing, pre-fix verdicts recorded) paired with green run 29973982957 (102/102); dossier covers the 3 structurally-unfailable sites. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Enumeration/protection, classification ladder, and mutating actions remain in separate libraries with documented sourcing order. |
| **Under 500 lines** | PASS | Reviewer-verified `wc -l`: wrapper 92, classification lib 476, enumerate lib 236, actions lib 382, stub 208, hard-failure suite 172. All within cap. Matches `evidence/qa-gates/file-size-caps.2026-07-22T21-16.md`. |
| **No circular dependencies** | PASS | Linear source order: enumerate lib -> classification lib -> actions lib -> wrapper. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names / conventional commits** | PASS | `fix(shell): propagate git hard failures across all worktree call sites (#396)`; docstrings updated with the new hard-error contracts and token semantics. |
| **Comment accuracy** | PASS | The classification-lib header invariant ("A hard git failure never resolves to a MERGED_* verdict") now holds under every reproduction attempted; the enumerate-lib and actions-lib headers accurately describe the guarded reads and the accepted best-effort sites. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `bash scripts/bash/shell-qc.sh format` — exit 0, no rewrites (`evidence/qa-gates/final-shell-format.2026-07-22T21-16.md`). Reviewer corroboration: local `shfmt -d` clean over the four production files and the stub. |
| **2. Linting** | PASS | **Command:** `bash scripts/bash/shell-qc.sh check` — exit 0 (`evidence/qa-gates/final-shell-check.2026-07-22T21-16.md`). Reviewer corroboration: local `shellcheck` clean over all four production files. |
| **3. Type checking** | N/A | Bash has no type-check stage per `.claude/rules/shell.md`; reviewer ran `bash -n` on all four files (clean). |
| **4. Testing** | PASS | **Command:** CI dispatch of `_shell-coverage.yml` (bats/kcov unavailable locally per `.claude/rules/shell.md`). Run 29973982957: success, TAP `1..102`, 0 failures. Reviewer verified conclusion and headSha via `gh run view`. |
| **Full toolchain loop** | PASS | Single clean pass recorded in `evidence/qa-gates/final-qa-summary.2026-07-22T21-16.md`. |
| **Explicit reporting** | PASS | All commands, exit codes, run IDs/URLs recorded in the Phase 5 evidence artifacts. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages and the final QA summary describe the fix per call site, the re-grep result, and the closure statement. |
| **Update supporting documents** | PASS | Library headers and function docstrings updated; remediation plan checklist fully checked; stub header documents the new KEY. |
| **Provide next steps** | PASS | With zero blocking findings, the next step is PR authoring; no further remediation cycle is required. |

---

## 3. Language-Specific Code Change Policy Compliance

Sections for Python, PowerShell, TypeScript, and C# are omitted: zero changed source files in those languages on this branch.

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | PASS | **Command:** `bash scripts/bash/shell-qc.sh format` — exit 0 (executor evidence); reviewer-local `shfmt -d` clean. |
| **Linting with shellcheck** | PASS | **Command:** `bash scripts/bash/shell-qc.sh check` — exit 0 (executor evidence); reviewer-local `shellcheck` clean; suppressions limited to justified SC1091 with inline rationale. |
| **Testing with bats** | PASS | CI run 29973982957: 102/102 pass, 0 failures (bats/kcov not runnable locally on this host). |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | PASS | `#!/usr/bin/env bash` in all production files and the stub; `#!/usr/bin/env bats` in the suites. |
| **Error handling** | PASS | Wrapper uses `set -euo pipefail`; every authoritative git read uses guarded parent-shell capture or an rc-mapped verdict ladder; accepted best-effort sites are individually justified in the actions-lib header and were individually re-assessed fail-closed in this sweep. |
| **Under 500 lines** | PASS | 92 / 476 / 236 / 382 lines (reviewer-verified). |

---

## 4. Language-Specific Unit Test Policy Compliance

Bash/bats: unchanged framework conventions from prior audits (suites in `tests/shell/` mirroring `scripts/bash/`, checked-in fixtures, seam-stubbed git binary, no temp files). The 17 new tests follow the established patterns and close the hard-failure scenario gap noted in the cycle-2 audit. PASS.

---

## 5. Test Coverage Detail

Cycle-3 additions (all passing in run 29973982957; tests 1-13 deterministically red in run 29972970639 pre-fix):

| Test | Scenario | Fixed site | Status |
|------|----------|-----------|--------|
| 1 classify_branch ANCESTRY_ERROR on diff-tree failure | diff_tree_error | NEW-1 site 1 | PASS |
| 2 classify_residual_commit RESIDUAL_ERROR | residual_namestatus_error | NEW-1 site 2 | PASS |
| 3 classify_branch ANCESTRY_ERROR on ls-tree failure | ls_tree_error | D-rung | PASS |
| 4 compute_protected non-zero on rev-parse failure | rev_parse_error_protection | NEW-2 | PASS |
| 5 classify_branch ANCESTRY_ERROR for current branch | rev_parse_error_protection | NEW-2 propagation | PASS |
| 6 enumerate_branches non-zero, empty stdout | enumerate_error | enumerate pipeline | PASS |
| 7 run_report non-zero, no lines | enumerate_error | NEW-3 site 1 | PASS |
| 8 run_apply non-zero, no ACTION lines | enumerate_error | NEW-3 site 2 | PASS |
| 9 run_apply non-zero on worktree-list failure | worktree_list_error | run_apply capture | PASS |
| 10-11 consolidation_worktree_path fails closed | consolidation_path_error / _empty | NEW-4 | PASS |
| 12-13 both consolidation-path consumers guarded | consolidation_path_error | NEW-4 consumers | PASS |
| 14-15 D-rung behavior preservation (present/absent on main) | deleted_path_on_main / _absent | guards | PASS |
| 16 reverify_delete_eligible BLOCKED-REVERIFY | worktree_list_error | conversion guard | PASS |
| 17 remove_worktree_safe BLOCKED-DIRTY on status failure | dirty_worktree_status_error | conversion guard | PASS |

Reviewer-independent local reproductions at head (checked-in stub, Git Bash): tests 1, 3, 5, 7, 8, 10 semantics reproduced exactly (`ANCESTRY_ERROR`/rc 2 or rc 128 with no output), plus guards 14/15, plus the novel `_blob_equal` hard-failure probe (scratchpad scenario) confirming `UNIQUE -> NOT_MERGED` fail-closed.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Bash suite (CI, run 29973982957) | 102 (TAP `1..102`), 0 failures | PASS |
| Fail-before run (29972970639 at `556749f8`) | exactly the 13 fail-before tests failing; guards and all 85 pre-existing pass | PASS (genuine fail-before) |
| Delta from green-run commit to head | 6 files, all `docs/features/**` (`git diff --name-only a1b39a4d..HEAD`) | PASS (docs-only) |
| Code Coverage | 91.5% bash lines overall; 100.0 / 93.2 / 92.1 / 92.8 per production file | PASS |
| File-size caps | all production/test shell files at or under 476 lines | PASS |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| CI run identity | `gh run view 29973982957 --json headSha,conclusion,headBranch` | success at `a1b39a4d` on this branch | PASS |
| Coverage re-parse | `grep line-rate artifacts/pester/kcov-ci/cov.xml` | overall 0.915; per-class 1.000 / 0.932 / 0.921 / 0.928 (matches evidence) | PASS |
| shfmt (reviewer-local) | `shfmt -d` over 4 production files + stub | clean | PASS |
| shellcheck (reviewer-local) | `shellcheck` over 4 production files | clean | PASS |
| Syntax | `bash -n` over 4 production files | clean | PASS |
| Fail-open idiom scan | grep for `< <(`, `mapfile`, `readarray`, `\|\| true` over the three libraries | zero instances over git-backed producers / authoritative captures | PASS |
| Independent line-by-line call-site sweep | reviewer enumeration of every `cleanup_wt_git` invocation and git-backed consumer at head | zero fail-open sites; every discarded exit status is at an individually-verified fail-closed best-effort site | PASS |
| Fixed-path reproductions | 8 stub-scenario invocations at head (6 hard-failure + 2 guards) | all fail closed with required verdicts | PASS |
| Novel accepted-safe probe | scratchpad scenario: `_blob_equal` rev-parse rc 128 on A-status residual | verdict UNIQUE on docs/x.md, branch state NOT_MERGED, rc 0 (fail-closed) | PASS |
| Evidence locations | `python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | PASS |

---

## 8. Gaps and Exceptions

### Identified Gaps

- **None blocking.** The independent sweep found zero remaining git invocations whose exit status is discarded, lost in a subshell/pipeline, or unchecked before the output feeds a classification or protection decision.
- **NEW-1 (both sites): RESOLVED.** Guarded diff-tree captures with `DIFF_TREE_ERROR`/`RESIDUAL_ERROR` tokens mapping to `ANCESTRY_ERROR`/return 2; reproduced fixed by this reviewer.
- **NEW-2: RESOLVED.** `compute_protected` rev-parse hard failures are fatal; the current-branch degrade to `MERGED_CLEAN` is no longer reproducible (now `ANCESTRY_ERROR`/rc 2).
- **NEW-3: RESOLVED.** `run_report`/`run_apply` capture `enumerate_branches` up front; `enumerate_branches` captures for-each-ref before sorting.
- **NEW-4: RESOLVED.** `consolidation_worktree_path` and both consumers fail closed; the malformed `-wt/documentationandmemories` derivation is impossible (reproduced: rc 128, empty stdout).
- **D-rung ambiguity (cycle-2 Info): RESOLVED.** The exit-only `rev-parse main:<path>` probe is replaced by a guarded `ls-tree` capture distinguishing hard failure from legitimate absence; behavior-preservation guards 14/15 pin both directions.
- **CR-2 (Minor, accepted):** stub-aware `stub-git:` re-emission in `cherry_pick_candidates` — unchanged, accepted since cycle 1.
- **CR-4 (Minor, accepted):** call-graph redundancy — unchanged, accepted since cycle 1; note the cycle-3 minus-present refactor removed one duplicate `git cherry` invocation.
- **Info (new, spec-inherent, non-blocking):** a branch whose `main..branch` range contains only merge commits (e.g. an evil-merge conflict resolution) produces empty `git cherry` output (git cherry skips merge commits) and classifies `MERGED_EQUIVALENT` despite a non-empty tree diff. All git exit codes on that path are checked; this is a semantic property of the AC2-prescribed cherry/patch-id ladder, not an exit-status defect, and is recorded for a potential follow-up issue in `code-review.2026-07-22T22-31.md`.

### Approved Exceptions

- Fail-before exception dossier `evidence/regression-testing/fail-before-exception.2026-07-22T21-16.md` covers the three sites with no constructible pre-fix failing observation (minus-present structural removal; two already-fail-closed conversions), each with a documented impossibility rationale and an alternative proof.

### Removed/Skipped Tests

- None. 0 skips in the TAP output; `EXIT_CODE: SKIPPED` appears in no cycle-3 evidence artifact.

---

## 9. Summary of Changes

### Commits in This PR/Branch (cycle-3 delta)

1. **556749f8** — test(shell): add cycle-3 hard-failure fail-open suite, fixtures, and stub ls-tree key (#396)
2. **a1b39a4d** — fix(shell): propagate git hard failures across all worktree call sites (#396)
3. **6c891b73** — docs(shell): record cycle-3 final QA evidence and plan check-offs (#396)

Full branch inventory: prior audits (`policy-audit.2026-07-22T09-23.md` section 9 and successors).

### Files Modified (cycle-3 delta)

1. **scripts/bash/cleanup_worktrees_lib.sh** (MODIFIED) — guarded diff-tree captures (`DIFF_TREE_ERROR`, `RESIDUAL_ERROR`), ls-tree D-rung, `MINUS_PRESENT` token replacing the second cherry invocation, `run_report` up-front captures, header contract updated.
2. **scripts/bash/cleanup_worktrees_enumerate_lib.sh** (MODIFIED) — `enumerate_branches` parent-shell for-each-ref capture; `compute_protected` fatal rev-parse handling.
3. **scripts/bash/cleanup_worktrees_actions_lib.sh** (MODIFIED) — `consolidation_worktree_path` and consumers guarded; `run_apply` up-front captures and classification rc propagation; `reverify_delete_eligible`/`remove_worktree_safe` idiom conversions; header guarded-read invariant.
4. **tests/shell/test_cleanup_worktrees_hard_failures.bats** (NEW) — 17 tests (13 fail-before + 4 guards).
5. **tests/fixtures/cleanup_worktrees/** — 8 new scenario directories; stub `ls-tree` KEY.
6. **docs/features/active/2026-07-22-cleanup-merged-worktrees-396/** — remediation plan/inputs, baseline/QA/regression evidence, this audit set.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

All toolchain, coverage, file-size, evidence-location, and test-policy gates PASS at branch-head code content. Every fail-open finding from cycles 1-3 (CR-1, NEW-1 through NEW-4, the D-rung ambiguity, and every additional site in the exhaustive audit) is verified resolved with genuine fail-before/pass-after CI evidence or a documented impossibility dossier. The caller-directed independent line-by-line sweep found zero remaining git invocations with a discarded or unreachable exit status feeding a classification or protection decision. The remaining CR-2/CR-4 accepted Minors and one spec-inherent Info observation do not block merge.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: remediation inputs/plan/baseline evidence complete, including the verified exhaustive call-site audit.
- PASS Design Principles: uniform guarded-capture pattern; fail-fast on every authoritative read.
- PASS Module & File Structure: all caps respected (largest file 476 lines).
- PASS Naming, Docs, Comments: header invariants now hold.
- PASS Toolchain Execution: single clean pass; CI green; coverage verified.
- PASS Summarize & Document: closure statement complete; next step is PR authoring.

#### Language-Specific Code Change Policy (Section 3)
- PASS Bash: tooling and error handling.

#### General Unit Test Policy (Section 1)
- PASS Core Principles, Coverage & Scenarios, Structure, External Dependencies.

#### Language-Specific Unit Test Policy (Section 4)
- PASS Bash/bats conventions.

---

### Metrics Summary

- PASS 102/102 bats tests green in CI at head code content (run 29973982957); genuine fail-before run captured (29972970639, exactly the 13 expected failures)
- PASS 91.5% bash line coverage repo-wide (baseline 90.4%, +1.1); all four production files at or above 92.1%; no overall regression
- PASS shfmt/shellcheck clean (executor evidence + reviewer-local corroboration)
- PASS Evidence-location validator exit 0; all files within size caps
- PASS Generalized hard-failure invariant: independent sweep + 9 reproductions, zero fail-open paths remaining

---

### Recommendation

**Go.** Zero blocking findings. All acceptance criteria remain satisfied (see `feature-audit.2026-07-22T22-31.md`), every remediation finding across all three cycles is resolved and independently verified, and the branch is within the 3-pass remediation cap with no further cycle required. Proceed to PR authoring.

---

## Appendix A: Test Inventory

Bash suite: 102 tests total — the 85 tests inventoried through the cycle-2 audit (80 original + 5 cycle-2 hard-failure tests) plus the 17 cycle-3 tests in `tests/shell/test_cleanup_worktrees_hard_failures.bats` (13 fail-before hard-failure tests + 4 pass-before regression guards), listed in section 5.

---

## Appendix B: Toolchain Commands Reference

**Cycle-3 verification commands used in this re-audit:**
```bash
# CI run identity and conclusion
gh run view 29973982957 --json headSha,conclusion,headBranch   # success at a1b39a4d
git diff --name-only a1b39a4d..HEAD                            # docs-only delta to head

# Coverage re-parse (downloaded Cobertura artifact)
grep -oE '<coverage[^>]*line-rate="[0-9.]+"' artifacts/pester/kcov-ci/cov.xml
grep -oE 'filename="[^"]*cleanup[^"]*"[^>]*line-rate="[0-9.]+"' artifacts/pester/kcov-ci/cov.xml

# Local format/lint/syntax corroboration (CI versions canonical per .claude/rules/shell.md)
shfmt -d scripts/bash/cleanup-worktrees.sh scripts/bash/cleanup_worktrees_lib.sh \
  scripts/bash/cleanup_worktrees_enumerate_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh
shellcheck scripts/bash/cleanup-worktrees.sh scripts/bash/cleanup_worktrees_lib.sh \
  scripts/bash/cleanup_worktrees_enumerate_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh
bash -n scripts/bash/cleanup*.sh

# Idiom sweep
grep -n '< <(\|mapfile\|readarray\||| true' scripts/bash/cleanup_worktrees_*.sh scripts/bash/cleanup-worktrees.sh

# Fixed-path reproductions (checked-in stub + checked-in scenarios; read-only)
CLEANUP_WT_GIT_BIN=tests/fixtures/cleanup_worktrees/stub-bin/git \
CLEANUP_WT_STUB_SCENARIO=tests/fixtures/cleanup_worktrees/scenarios/diff_tree_error \
  bash -c "source scripts/bash/cleanup_worktrees_enumerate_lib.sh && \
           source scripts/bash/cleanup_worktrees_lib.sh && classify_branch feature-dtfail"
# -> BRANCH|feature-dtfail|ANCESTRY_ERROR, rc 2 (repeated for ls_tree_error,
#    rev_parse_error_protection, enumerate_error, consolidation_path_error, guards 14/15)

# Novel accepted-safe probe (scratchpad-only scenario; no repo mutation)
# _blob_equal: rev-parse.feature-bfail_docs_x.md.rc = 128 with an A-status residual
# -> classify_residual_commit prints UNIQUE|docs/x.md; classify_branch prints
#    BRANCH|feature-bfail|NOT_MERGED, rc 0 (fail-closed; never delete-eligible)

# Evidence locations
python scripts/dev_tools/validate_evidence_locations.py --root .
```

**Bash toolchain reference:** `bash scripts/bash/shell-qc.sh format|check|test` (bats/kcov via CI dispatch of `_shell-coverage.yml` on this host).

---

**Audit Completed By:** feature-review agent (Claude Code)
**Audit Date:** 2026-07-22
**Policy Version:** Current (as of audit date)

**Reviewer assumptions (documented per policy):**
1. MCP server tools were unavailable in this session; artifact structure follows the bundled canonical templates at `extensions/drm-copilot/resources/templates/policy_audit/`, and artifact validation was run via the CLI `python scripts/dev_tools/validate_orchestration_artifacts.py`.
2. Coverage thresholds applied are the uniform tier rule (85% line / 75% branch) per `.claude/rules/quality-tiers.md`; kcov cannot measure bash branch coverage, and `.claude/rules/shell.md` defines no bash branch gate.
3. CI verification relies on the green run 29973982957 at `a1b39a4d`; the branch head `6c891b73` differs only by six `docs/features/**` files (verified with `git diff --name-only a1b39a4d..HEAD`).
4. The evaluation standard applied is the orchestrator's cycle-2/cycle-3 escalation rationale: any hard git failure resolving to a delete-eligible verdict or weakened protection is Blocking. Under that standard, zero blocking paths remain.
