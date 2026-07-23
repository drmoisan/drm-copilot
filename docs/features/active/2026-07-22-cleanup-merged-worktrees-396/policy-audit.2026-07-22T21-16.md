# Policy Compliance Audit: cleanup-merged-worktrees (Issue #396) — Remediation Cycle 2 Re-audit (CR-1)

---

**Audit Date:** 2026-07-22
**Audit Type:** Remediation cycle 2 re-audit (prior audits: `policy-audit.2026-07-22T09-23.md`, `policy-audit.2026-07-22T10-00.md`)
**Code Under Test:**
- `scripts/bash/cleanup-worktrees.sh` (NEW, 92 lines — sources three libraries after cycle-2 split)
- `scripts/bash/cleanup_worktrees_enumerate_lib.sh` (NEW in cycle 2, 209 lines — pure-move split of the enumeration/protection function group)
- `scripts/bash/cleanup_worktrees_lib.sh` (NEW, 411 lines — classification ladder; CR-1 call sites fixed in cycle 2)
- `scripts/bash/cleanup_worktrees_actions_lib.sh` (NEW, 300 lines — unchanged in cycle 2 per plan scope)
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` and its bundled mirror (unchanged since cycle 1)
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (MODIFIED in cycle 1; unchanged in cycle 2)
- `tests/shell/test_cleanup_worktrees_{enumeration,classification,consolidation,deletion,cli}.bats` (5 suites; enumeration and classification suites extended in cycle 2 with 5 hard-failure tests)
- `tests/fixtures/cleanup_worktrees/**` (3 new hard-failure scenario directories added in cycle 2: `worktree_list_error`, `cherry_error`, `rev_list_error`)
- `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/**` (scoping docs, plans, research, evidence, review artifacts)

**Review scope:** full branch diff `b2351cbc..921b5c40` (base `main`, merge base `b2351cbc3fb3916f516d77567a1c9e40457c8981`), 178 files, +5078/-0. Languages with changed files: Bash (shell), Markdown, and JSON (one pack-manifest config file). Python, TypeScript, PowerShell, and C# have zero changed source files on this branch.

**Cycle-2 delta re-audited (commits `a71ab00e`, `e09c0e92`, `8ba4fb79`, `921b5c40`):**
- `e09c0e92` — pure-move split of `cleanup_worktrees_enumerate_lib.sh` out of `cleanup_worktrees_lib.sh`; 3 hard-failure fixture scenarios; 5 fail-before bats tests.
- `8ba4fb79` — the CR-1 production fix: guarded parent-shell capture replacing the dead or-capture (`rc=$?`) idiom inside process substitutions at the three cited call sites and their consuming reads.
- `921b5c40` — Phase 4 QA evidence and plan check-offs (docs only).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Bash | 5 shell files (4 production + 1 test stub) + 5 bats suites | 85 total (5 new in cycle 2) | PASS 85 pass, 0 fail (CI run 29970805348) | 89.0% lines (run 29922832766) | 90.4% lines | enumerate lib 95.1%, classification lib 90.2%, wrapper 100.0%, actions lib 89.8% (all at or above 85%) |
| Markdown | ~40 docs/evidence/review files | N/A | N/A (docs) | N/A | N/A | N/A |
| JSON | 1 config manifest (`core.json`, cycle-1 change) | 9 contract tests | PASS (verified in cycle-1 re-audit; file unchanged since) | N/A (config manifest, verified by contract tests) | N/A (config manifest, verified by contract tests) | N/A (config manifest, verified by contract tests) |

Coverage verdicts (explicit, per language with changed files):
- **Bash: PASS.** Repo-wide 90.4% lines at or above 85% and above the 89.0% cycle baseline (no regression). Per-file: `cleanup-worktrees.sh` 100.0%, `cleanup_worktrees_lib.sh` 90.2%, `cleanup_worktrees_enumerate_lib.sh` 95.1% (new file), `cleanup_worktrees_actions_lib.sh` 89.8%. Branch coverage is not measurable by kcov for bash; per `.claude/rules/shell.md` there is no bash branch-coverage gate. Independently re-verified in this re-audit by parsing the downloaded CI artifact `artifacts/pester/kcov-ci/cov.xml` (Cobertura line-rate: overall 0.904; per-class 1.000 / 0.902 / 0.951 / 0.898 — exact match to the evidence artifact). The green run 29970805348 is at `8ba4fb79`; the delta `8ba4fb79..921b5c40` is six `docs/features/**` files (verified with `git diff --name-only`), so the run is representative of head code content.
- **JSON (`core.json`): PASS.** Config manifest, not a coverage-bearing language; unchanged since the cycle-1 re-audit that verified it (contract tests 9/9, CI run 29925971964).
- Python: N/A (zero changed files). TypeScript: N/A (zero changed files). PowerShell: N/A (zero changed files). C#: N/A (zero changed files).

### Coverage Evidence Checklist

- Bash baseline coverage artifact: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/remediation-baseline/coverage-baseline-reference.2026-07-23T00-30.md` (run 29922832766, 89.0% lines)
- Bash post-change coverage artifact: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/qa-gates/final-shell-coverage-ci.2026-07-23T00-30.md` (run 29970805348, 90.4% lines) plus downloaded `artifacts/pester/kcov-ci/cov.xml` (re-parsed by this reviewer)
- Per-language comparison summary: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/qa-gates/coverage-delta.2026-07-23T00-30.md` and section 1.2.1 below
- TypeScript baseline coverage artifact: `N/A - out of scope (zero changed TypeScript files on this branch)`
- TypeScript post-change coverage artifact: `N/A - out of scope (zero changed TypeScript files on this branch)`
- PowerShell baseline coverage artifact: `N/A - out of scope (zero changed PowerShell files on this branch)`
- PowerShell post-change coverage artifact: `N/A - out of scope (zero changed PowerShell files on this branch)`
- Python / C# artifacts: `N/A - zero changed files on this branch`

**Threshold basis (assumption documented):** the uniform tier rule per `.claude/rules/quality-tiers.md` (Authoritative Decision #2) applies: line coverage at or above 85% for new files, modified files, and repo-wide, with no regression. The 90% "new code" figure in the legacy policy-audit template text is superseded by the uniform rule (precedent: #393 and the prior #396 cycle audits). All files pass under either reading.

---

## Rejected Scope Narrowing

None detected. The caller instruction explicitly requested "the full feature-review-workflow SKILL contract end-to-end against this branch's diff versus main (same scope as before, no scope narrowing)" and additionally directed the reviewer to check hard-failure behavior at call sites beyond those enumerated by CR-1. The audit scope is the full feature-vs-base diff `b2351cbc..921b5c40`. The remediation plan's "CR-1 only" statement is an executor scope constraint, not an audit scope constraint, and was not applied to this audit.

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` -> exit 0 (no violations), re-run in this cycle.
- Branch diff inspection (`git diff --name-status b2351cbc..HEAD`): zero files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All feature evidence lives at the canonical `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/{baseline,qa-gates,remediation-baseline,regression-testing,other}/` paths. **PASS.**

---

## Executive Summary

This re-audit confirms remediation cycle 2 resolved finding CR-1 as specified: all three cited fail-open call sites (worktree-list read in `parse_worktree_list`, cherry read in `classify_cherry_equivalent`, rev-list read in `select_cherry_pick_candidates`) and their consuming reads (`compute_protected`, `classify_branch`, `run_report`) now use guarded parent-shell capture, map hard git failures to `ANCESTRY_ERROR` / non-zero returns, and are covered by five new bats tests with genuine fail-before evidence (red CI run 29970355445 at `e09c0e92`) and pass-after evidence (green CI run 29970805348 at `8ba4fb79`, 85/85 tests).

This reviewer independently verified:
1. **No fail-open idiom remains at the CR-1 sites:** `grep` confirms zero or-capture (`rc=$?`) assignments inside process substitutions in the two classification/enumeration libraries; the three fixed sites use `out=$(cmd)` with guarded rc capture in the parent shell.
2. **Tests are genuine:** the five new tests assert non-zero status and the absence of delete-eligible verdicts under stub-injected hard failures; the fail-before run shows exactly those five tests failing with all 80 pre-existing tests passing.
3. **CI and coverage:** run 29970805348 confirmed green via `gh run view` (headSha `8ba4fb79`, conclusion success); `8ba4fb79..HEAD` is docs-only; coverage re-parsed from the downloaded Cobertura artifact and matches the evidence exactly (overall 90.4%; all four production files at or above 85%; no regression).
4. **Format/lint:** local `shfmt -d` and `shellcheck` over the four production shell files are clean (reviewer corroboration); executor evidence `final-shell-format.2026-07-23T00-30.md` and `final-shell-check.2026-07-23T00-30.md` record exit 0.

**However**, the caller's generalized invariant check — "no hard git failure can still resolve to a delete-eligible verdict or a protection-weakened worktree list anywhere in the classification/enumeration/consolidation code paths" — **fails**. This reviewer deterministically reproduced (using scratchpad-only stub scenarios, no repo mutation) two residual fail-open paths outside CR-1's enumerated sites:
1. **Blocking (NEW-1):** a hard `git diff-tree` failure (exit 128, empty output) on a residual commit resolves to `BRANCH .. MERGED_EQUIVALENT` with status 0 — a delete-eligible verdict from a hard git failure, surviving the same-process re-verification. Call sites: `cleanup_worktrees_lib.sh` line 127 (rc swallowed by an or-true) and line 197 (rc lost in a process substitution).
2. **Major (NEW-2):** hard failures of `git rev-parse --abbrev-ref HEAD` and `--show-toplevel` inside `compute_protected` (lines 166-167) degrade silently to an empty current-branch/current-path protection, allowing the current branch to classify `MERGED_CLEAN` (reproduced). Git-native backstops (refusal to delete a checked-out branch or remove the current working tree) bound the practical impact.

Details, reproductions, and remediation guidance: `code-review.2026-07-22T21-16.md` and `remediation-inputs.2026-07-22T21-16.md`. Under the orchestrator's cycle-2 escalation standard (a known fail-open path in the classification ladder of a destructive tool is Blocking for this feature), NEW-1 blocks merge.

No `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` paths are modified anywhere in the branch diff, so the `modified-workflow-needs-green-run` rule does not fire; green branch-content CI runs exist regardless.

**Policy documents evaluated:**
- PASS `general-code-change` policy (`.claude/rules/general-code-change.md`) — with the error-handling gap noted in section 8
- PASS `general-unit-test` policy (`.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- PASS Bash: `.claude/rules/shell.md` (shfmt + shellcheck + bats + kcov) — all gates green at head code content.
- PASS JSON manifest: unchanged since cycle-1 verification.
- N/A Python, PowerShell, TypeScript, C#: zero changed files.
- PASS Tonality (`.claude/rules/tonality.md`): cycle-2 plan, evidence, and code comments use neutral, factual language.

**Temporary artifacts cleanup:**
- PASS No temporary or throwaway scripts in the diff. Reviewer reproductions used session-scratchpad fixtures outside the repository.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | New hard-failure tests are scenario-isolated via `CLEANUP_WT_STUB_SCENARIO`; each test sources the libraries in a fresh `bash -c` process. CI TAP order-independent. |
| **Isolation** | PASS | Each new test targets one function-level failure mode (parse, classify, report) under one injected failure. |
| **Fast Execution** | PASS | Stub-driven; no real git repositories; suite of 85 completes within the CI job without timeout. |
| **Determinism** | PASS | Canned fixture outputs and exit codes; no time, randomness, or network. |
| **Readability & Maintainability** | PASS | New tests carry intent comments naming the fail-open bug and the required post-fix behavior. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | 89.0% lines (run 29922832766) recorded in `evidence/remediation-baseline/coverage-baseline-reference.2026-07-23T00-30.md` before the cycle-2 changes. |
| **No Coverage Regression** | PASS | Post-change 90.4% lines (+1.4). Re-parsed from `cov.xml` by this reviewer. |
| **New Code Coverage** | PASS | New file `cleanup_worktrees_enumerate_lib.sh` 95.1%; modified `cleanup_worktrees_lib.sh` 90.2% (pre-split combined baseline 88.5%). |
| **Comprehensive Coverage** | PARTIAL | The five new hard-failure tests cover the three CR-1 sites. No test covers the residual diff-tree hard-failure path (NEW-1) or the rev-parse protection-degrade path (NEW-2); both were reproduced by this reviewer outside the suite. |
| **Positive/Negative/Edge/Error** | PARTIAL | AC8 scenarios plus CR-1 error paths covered; the diff-tree and rev-parse error paths remain untested (see section 8). |
| **Concurrency** | N/A | Single-process CLI tool. |

### 1.2.1 Per-Language Coverage Comparison

- Bash: Baseline: 89.0% lines -> Post-change: 90.4% lines. Change: +1.4% lines. New/changed-code coverage: 90.2% minimum per changed production file (95.1% for the new enumerate lib, 90.2% for the modified classification lib, 100.0% wrapper, 89.8% actions lib). Disposition: PASS. Evidence: `evidence/qa-gates/coverage-delta.2026-07-23T00-30.md`, `artifacts/pester/kcov-ci/cov.xml` (reviewer re-parse), CI run 29970805348.
- TypeScript: `N/A - zero changed files on this branch`.
- Python: `N/A - zero changed files on this branch`.
- PowerShell: `N/A - zero changed files on this branch`.
- C#: `N/A - zero changed files on this branch`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Exact-match assertions on report lines and status codes; bats prints the failing assertion line. |
| **Arrange-Act-Assert Pattern** | PASS | Scenario env (arrange), `run bash -c` (act), status/output assertions (assert). |
| **Document Intent** | PASS | Each new test has a comment naming the pre-fix fail-open behavior and the required post-fix behavior. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | Git fully stubbed via `CLEANUP_WT_GIT_BIN`; no real repository, network, or filesystem mutation. |
| **Use Mocks/Stubs** | PASS | Checked-in recording git stub replaying canned fixtures; writes nothing to disk. |
| **Environment Stability** | PASS | No temporary files anywhere in the test suites; fixtures are checked in. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This re-audit document plus the two prior cycle audits. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `remediation-inputs.2026-07-23T00-30.md` names the exact finding, lines, consequences, and required fix. |
| **Read existing change plans** | PASS | `evidence/remediation-baseline/phase0-instructions-read.2026-07-23T00-30.md` records the P0-T1 policy reading order. |
| **Document the plan** | PASS | `remediation-plan.2026-07-23T00-30.md` (5 phases, all tasks checked), including binding design decisions on the capture pattern, hard-error verdict mapping, and the 500-line-cap-driven pure-move split. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Uniform guarded-capture pattern applied consistently; hard errors reuse the existing `ANCESTRY_ERROR` state rather than introducing new report states. |
| **Fail fast and explicitly** | PARTIAL | The CR-1 sites now fail fast. However, two residual silent-error paths remain (NEW-1 diff-tree or-true swallow and process-substitution rc loss; NEW-2 rev-parse fallback-to-empty), violating the "do not silently ignore errors" rule in a destructive code path. See section 8 and the code review. |
| **Scope discipline** | PASS | Cycle-2 delta touches exactly the planned files; `cleanup_worktrees_actions_lib.sh` untouched per plan. |
| **Fail-before / pass-after evidence** | PASS | Red run 29970355445 (exactly the 5 new tests failing) paired with green run 29970805348 (85/85). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Pure-move split keeps enumeration/protection separate from the classification ladder; sourcing order documented and enforced in wrapper and suites. |
| **Under 500 lines** | PASS | Reviewer-verified `wc -l`: wrapper 92, classification lib 411, enumerate lib 209, actions lib 300, stub 193, largest bats suite 168. All within cap. Matches `evidence/qa-gates/file-size-caps.2026-07-23T00-30.md`. |
| **No circular dependencies** | PASS | Linear source order: enumerate lib -> classification lib -> actions lib -> wrapper. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names / conventional commits** | PASS | `fix(shell): propagate git hard failures in worktree classification (#396)`; function docstrings updated with the new hard-error contracts. |
| **Comment accuracy** | PARTIAL | The updated header of `cleanup_worktrees_lib.sh` (lines 24-28) states "A hard git failure never resolves to a MERGED_* verdict." This claim is falsified by the reproduced NEW-1 path (diff-tree hard failure resolves to MERGED_EQUIVALENT). The header must be corrected or, preferably, made true by fixing NEW-1. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `bash scripts/bash/shell-qc.sh format` — exit 0, no rewrites (`evidence/qa-gates/final-shell-format.2026-07-23T00-30.md`). Reviewer corroboration: local `shfmt -d` clean over all four production files. |
| **2. Linting** | PASS | **Command:** `bash scripts/bash/shell-qc.sh check` — exit 0 (`evidence/qa-gates/final-shell-check.2026-07-23T00-30.md`). Reviewer corroboration: local `shellcheck` clean over all four production files. |
| **3. Type checking** | N/A | Bash has no type-check stage per `.claude/rules/shell.md`. |
| **4. Testing** | PASS | **Command:** CI dispatch of `_shell-coverage.yml` (bats/kcov unavailable locally per `.claude/rules/shell.md`). Run 29970805348: success, TAP `1..85`, 0 failures. Reviewer verified conclusion and headSha via `gh run view`. |
| **Full toolchain loop** | PASS | Single clean pass recorded in `evidence/qa-gates/final-qa-summary.2026-07-23T00-30.md`. |
| **Explicit reporting** | PASS | All commands, exit codes, run IDs/URLs recorded in the Phase 4 evidence artifacts. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages and the final QA summary describe the fix per call site. |
| **Update supporting documents** | PASS | Library headers and function docstrings updated; remediation plan checklist fully checked. |
| **Provide next steps** | PARTIAL | Cycle-2 closure was recorded, but the residual fail-open paths (NEW-1, NEW-2) require a further remediation cycle before merge. |

---

## 3. Language-Specific Code Change Policy Compliance

Sections for Python, PowerShell, TypeScript, and C# are omitted: zero changed source files in those languages on this branch.

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | PASS | **Command:** `bash scripts/bash/shell-qc.sh format` — exit 0 (executor evidence); reviewer-local `shfmt -d` clean. |
| **Linting with shellcheck** | PASS | **Command:** `bash scripts/bash/shell-qc.sh check` — exit 0 (executor evidence); reviewer-local `shellcheck` clean; suppressions limited to justified SC1091 with inline rationale. |
| **Testing with bats** | PASS | CI run 29970805348: 85/85 pass, 0 failures (bats/kcov not runnable locally on this host). |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | PASS | `#!/usr/bin/env bash` in all production files and the stub. |
| **Error handling** | PARTIAL | Wrapper uses `set -euo pipefail`; CR-1 sites now use guarded parent-shell capture. Residual silent-error paths at the diff-tree reads and the rev-parse protection reads remain (NEW-1, NEW-2). |
| **Under 500 lines** | PASS | 92 / 411 / 209 / 300 lines (reviewer-verified). |

---

## 4. Language-Specific Unit Test Policy Compliance

Bash/bats: unchanged framework conventions from prior audits (suites in `tests/shell/` mirroring `scripts/bash/`, checked-in fixtures, seam-stubbed git binary, no temp files). The five new tests follow the established patterns. PASS, with the coverage-gap note in section 1.2 (no test for the NEW-1/NEW-2 paths).

---

## 5. Test Coverage Detail

Cycle-2 additions (all passing in run 29970805348):

| Test | Suite | Scenario | Status |
|------|-------|----------|--------|
| worktree_list_error: classify_branch reports ANCESTRY_ERROR, never a delete-eligible verdict | classification | injected worktree-list exit 128 | PASS |
| worktree_list_error: run_report returns non-zero and emits no MERGED or WORKTREE lines | classification | injected worktree-list exit 128 | PASS |
| cherry_error: classify_branch reports ANCESTRY_ERROR on a git cherry hard failure | classification | injected cherry exit 128, empty output | PASS |
| rev_list_error: classify_branch returns non-zero with no fabricated COMMIT record | classification | injected rev-list exit 128 | PASS |
| parse_worktree_list returns non-zero and emits no records on a git worktree-list hard failure | enumeration | injected worktree-list exit 128 | PASS |

**Not covered:** the diff-tree hard-failure path in `classify_cherry_equivalent` (line 127) and `classify_residual_commit` (line 197), and the rev-parse hard-failure path in `compute_protected` (lines 166-167). Reviewer reproductions in `code-review.2026-07-22T21-16.md`.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Bash suite (CI, run 29970805348) | 85 (TAP `1..85`), 0 failures | PASS |
| Fail-before run (29970355445 at `e09c0e92`) | exactly the 5 new tests failing; 80/80 pre-existing pass | PASS (genuine fail-before) |
| Delta from green-run commit to head | 6 files, all `docs/features/**` (`git diff --name-only 8ba4fb79..HEAD`) | PASS (docs-only) |
| Code Coverage | 90.4% bash lines overall; 100.0 / 90.2 / 95.1 / 89.8 per production file | PASS |
| File-size caps | all production/test shell files at or under 411 lines | PASS |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| CI run identity | `gh run view 29970805348 --json headSha,conclusion,headBranch` | success at `8ba4fb79` on this branch | PASS |
| Coverage re-parse | `grep line-rate artifacts/pester/kcov-ci/cov.xml` | overall 0.904; per-class 1.000 / 0.902 / 0.951 / 0.898 (matches evidence) | PASS |
| shfmt (reviewer-local) | `shfmt -d` over 4 production files | clean | PASS |
| shellcheck (reviewer-local) | `shellcheck` over 4 production files | clean | PASS |
| Fail-open idiom scan | `grep` for or-capture inside process substitutions in the two classification/enumeration libs | none remaining at CR-1 sites | PASS |
| Generalized hard-failure invariant | reviewer stub reproductions (scratchpad scenarios) | NEW-1: diff-tree failure resolves to MERGED_EQUIVALENT status 0; NEW-2: rev-parse failures degrade protection to MERGED_CLEAN | FAIL |
| Evidence locations | `python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | PASS |

---

## 8. Gaps and Exceptions

### Identified Gaps

- **NEW-1 (Blocking):** hard `git diff-tree` failure resolves to the delete-eligible verdict `MERGED_EQUIVALENT`. Two call sites: `cleanup_worktrees_lib.sh` line 127 (`dt=$(cleanup_wt_git diff-tree ... 2>/dev/null)` with an or-true swallowing the exit code; empty output then treated as a droppable empty commit) and line 197 (name-status diff-tree read inside a process substitution, exit code lost; empty stream yields CONTENT_ON_MAIN). Deterministically reproduced by this reviewer: a scenario with cherry emitting one `+` residual and diff-tree exiting 128 with no output classifies `BRANCH .. MERGED_EQUIVALENT` with status 0, and the same wrong verdict repeats in `reverify_delete_eligible`, so apply mode would remove the worktree and delete the branch, destroying unique content. This is the same defect class the orchestrator escalated to Blocking in cycle 2 and violates the invariant recorded in the remediation plan (Design Decision 3) and in the library's own updated header. Remediation required — see `remediation-inputs.2026-07-22T21-16.md`.
- **NEW-2 (Major):** `compute_protected` lines 166-167 fall back to empty strings when `git rev-parse --abbrev-ref HEAD` or `--show-toplevel` fails hard, silently weakening the dual current-branch/current-worktree protection (reproduced: the current branch classifies `MERGED_CLEAN` under injected rev-parse failures). Practical impact bounded by git-native refusals (cannot delete a checked-out branch; cannot remove the current working tree), hence Major, not Blocking.
- **NEW-3 (Minor):** `enumerate_branches` hard failure is lost in the `run_report` (line 409) and `run_apply` (line 298) process substitutions: an empty branch list yields a status-0 "clean" report (silent false success). Fail-closed destructively; reporting defect only.
- **NEW-4 (Minor):** `consolidation_worktree_path` (actions lib line 31) loses a `parse_worktree_list` hard failure in `mapfile < <(...)`, deriving a malformed consolidation path from an empty main-worktree value.
- **Comment-accuracy gap:** the classification lib header claims hard git failures never resolve to MERGED verdicts; falsified by NEW-1 until fixed.
- **CR-1: RESOLVED.** Verified fixed at all three cited call sites and their consuming reads, with genuine fail-before/pass-after CI evidence.

### Approved Exceptions

- None required.

### Removed/Skipped Tests

- None. 0 skips in the TAP output; `EXIT_CODE: SKIPPED` appears in no cycle-2 evidence artifact.

---

## 9. Summary of Changes

### Commits in This PR/Branch (cycle-2 delta)

1. **a71ab00e** — docs: record remediation cycle 1 reaudit confirming zero blocking (#396)
2. **e09c0e92** — test(shell): add CR-1 hard-failure fixtures/tests, split enumeration lib (#396)
3. **8ba4fb79** — fix(shell): propagate git hard failures in worktree classification (#396)
4. **921b5c40** — docs(shell): record CR-1 Phase 4 QA evidence and plan check-offs (#396)

Full branch inventory: prior audits (`policy-audit.2026-07-22T09-23.md` section 9, `policy-audit.2026-07-22T10-00.md` section 9).

### Files Modified (cycle-2 delta)

1. **scripts/bash/cleanup_worktrees_enumerate_lib.sh** (NEW) — pure-move split; `parse_worktree_list` and `compute_protected` hardened with guarded capture.
2. **scripts/bash/cleanup_worktrees_lib.sh** (MODIFIED) — cherry/rev-list guarded capture; `CHERRY_ERROR` internal verdict; `classify_branch`/`run_report` hard-error propagation; header contract updated.
3. **scripts/bash/cleanup-worktrees.sh** (MODIFIED) — sources the enumerate lib first.
4. **tests/shell/test_cleanup_worktrees_{enumeration,classification,consolidation,deletion}.bats** (MODIFIED) — enumerate-lib sourcing; 5 new hard-failure tests.
5. **tests/fixtures/cleanup_worktrees/scenarios/{worktree_list_error,cherry_error,rev_list_error}/** (NEW) — hard-failure fixtures.
6. **docs/features/active/2026-07-22-cleanup-merged-worktrees-396/** — remediation plan/inputs, baseline/QA/regression evidence.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

All toolchain, coverage, file-size, evidence-location, and test-policy gates PASS at branch-head content, and finding CR-1 is verified resolved with genuine regression evidence. The audit is not fully compliant because the caller-directed generalized hard-failure invariant fails: reviewer-reproduced residual fail-open paths (NEW-1 Blocking, NEW-2 Major) remain in the classification/enumeration code, and the classification library header asserts an invariant (no hard git failure resolves to a MERGED verdict) that NEW-1 falsifies. Under the error-handling policy ("do not silently ignore errors") and the orchestrator's cycle-2 escalation standard, NEW-1 blocks merge.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: remediation inputs/plan/baseline evidence complete.
- ⚠️ Design Principles: fail-fast PARTIAL (residual silent-error paths NEW-1, NEW-2).
- PASS Module & File Structure: split executed; all caps respected.
- ⚠️ Naming, Docs, Comments: header invariant claim falsified by NEW-1.
- PASS Toolchain Execution: single clean pass; CI green; coverage verified.
- ⚠️ Summarize & Document: next-steps must include remediation cycle 3.

#### Language-Specific Code Change Policy (Section 3)
- ⚠️ Bash: tooling PASS; error-handling PARTIAL (NEW-1, NEW-2).

#### General Unit Test Policy (Section 1)
- PASS Core Principles, Structure, External Dependencies.
- ⚠️ Coverage & Scenarios: hard-failure scenario coverage incomplete (NEW-1/NEW-2 paths untested).

#### Language-Specific Unit Test Policy (Section 4)
- PASS Bash/bats conventions.

---

### Metrics Summary

- PASS 85/85 bats tests green in CI at head code content (run 29970805348); genuine fail-before run captured (29970355445)
- PASS 90.4% bash line coverage repo-wide (baseline 89.0%, +1.4); all four production files at or above 85%; no regression
- PASS shfmt/shellcheck clean (executor evidence + reviewer-local corroboration)
- PASS Evidence-location validator exit 0; all files within size caps
- FAIL Generalized hard-failure invariant (two reproduced residual fail-open paths)

---

### Recommendation

**Blocked.** CR-1 itself is resolved and verified, but merge is blocked by NEW-1 (hard diff-tree failure resolves to a delete-eligible verdict — reproduced). Remediation cycle 3 must apply the cycle-2 guarded-capture pattern to the two diff-tree call sites (and preferably the `compute_protected` rev-parse reads), add hard-failure fixtures/tests for those paths, and re-run the bash toolchain via CI dispatch. Inputs: `remediation-inputs.2026-07-22T21-16.md`.

---

## Appendix A: Test Inventory

Bash suite: 85 tests total — the 80 tests inventoried in `policy-audit.2026-07-22T09-23.md` Appendix A plus the five cycle-2 hard-failure tests listed in section 5 above (4 in `test_cleanup_worktrees_classification.bats`, 1 in `test_cleanup_worktrees_enumeration.bats`).

---

## Appendix B: Toolchain Commands Reference

**Cycle-2 verification commands used in this re-audit:**
```bash
# CI run identity and conclusion
gh run view 29970805348 --json headSha,conclusion,headBranch   # success at 8ba4fb79
git diff --name-only 8ba4fb79..HEAD                            # docs-only delta to head

# Coverage re-parse (downloaded Cobertura artifact)
grep -oE '<coverage[^>]*line-rate="[0-9.]+"' artifacts/pester/kcov-ci/cov.xml
grep -oE 'filename="[^"]*cleanup[^"]*"[^>]*line-rate="[0-9.]+"' artifacts/pester/kcov-ci/cov.xml

# Local format/lint corroboration (CI versions canonical per .claude/rules/shell.md)
shfmt -d scripts/bash/cleanup-worktrees.sh scripts/bash/cleanup_worktrees_lib.sh \
  scripts/bash/cleanup_worktrees_enumerate_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh
shellcheck scripts/bash/cleanup-worktrees.sh scripts/bash/cleanup_worktrees_lib.sh \
  scripts/bash/cleanup_worktrees_enumerate_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh

# File-size caps
wc -l scripts/bash/cleanup*.sh tests/shell/*.bats tests/fixtures/cleanup_worktrees/stub-bin/git

# Fail-open reproductions (scratchpad-only stub scenarios; no repo mutation)
# NEW-1: cherry emits '+ <sha>'; diff-tree.<sha>.rc = 128 -> classify_branch prints MERGED_EQUIVALENT, status 0
# NEW-2: rev-parse.abbrev-ref-HEAD.rc = 128, rev-parse.show-toplevel.rc = 128 -> current branch prints MERGED_CLEAN

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
3. CI verification relies on the green run 29970805348 at `8ba4fb79`; the branch head `921b5c40` differs only by six `docs/features/**` files (verified with `git diff --name-only 8ba4fb79..HEAD`).
4. The Go/No-Go standard applied to NEW-1 is the orchestrator's own cycle-2 escalation rationale (fail-open classification paths in a destructive tool are Blocking for this feature), recorded in `remediation-inputs.2026-07-23T00-30.md`.
