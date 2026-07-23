# Policy Compliance Audit: cleanup-merged-worktrees (Issue #396)

---

**Audit Date:** 2026-07-22
**Code Under Test:**
- `scripts/bash/cleanup-worktrees.sh` (NEW, 86 lines)
- `scripts/bash/cleanup_worktrees_lib.sh` (NEW, 499 lines)
- `scripts/bash/cleanup_worktrees_actions_lib.sh` (NEW, 300 lines)
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` (NEW)
- `tests/shell/test_cleanup_worktrees_{enumeration,classification,consolidation,deletion,cli}.bats` (NEW, 5 suites, 36 tests)
- `tests/fixtures/cleanup_worktrees/**` (NEW: git stub + checked-in scenario fixtures)
- `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/**` (NEW scoping docs, plan, research, evidence)

**Review scope:** full branch diff `b2351cbc..69188347` (base `main`, merge base `b2351cbc3fb3916f516d77567a1c9e40457c8981`), 123 files, +2800/-0. Languages with changed files: Bash (shell) and Markdown. Python, TypeScript, PowerShell, and C# have zero changed files on this branch.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Bash | 4 shell files (3 production + 1 test stub) + 5 bats suites | 80 total (36 new) | PASS 80 pass, 0 fail (CI run 29922832766, TAP `1..80`) | 88.2% lines (run 29918840204) | 89.0% lines | `cleanup-worktrees.sh` 100.0%, `cleanup_worktrees_lib.sh` 88.5%, `cleanup_worktrees_actions_lib.sh` 89.8% (all >= 85%) |
| Markdown | ~15 docs/evidence files | N/A | N/A (docs) | N/A | N/A | N/A |

Coverage verdicts (explicit, per language with changed files):
- **Bash: PASS.** Repo-wide 89.0% lines >= 85%; each new production file >= 85% lines; no regression (baseline 88.2% -> 89.0%). Branch coverage is not measurable by kcov for bash; per `.claude/rules/shell.md` there is no bash branch-coverage gate. Independently re-verified by this reviewer by parsing the downloaded CI artifact `artifacts/pester/kcov-ci/cov.xml` (Cobertura `line-rate` attributes: overall 0.890; per-class 1.000 / 0.885 / 0.898).
- Python: N/A (zero changed files). TypeScript: N/A (zero changed files). PowerShell: N/A (zero changed files). C#: N/A (zero changed files).

### Coverage Evidence Checklist

- Bash baseline coverage artifact: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/baseline/shell-coverage-ci.2026-07-22T08-12.md` (run 29918840204, 88.2% lines)
- Bash post-change coverage artifact: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/qa-gates/final-shell-coverage-ci.2026-07-22T09-01.md` (run 29922832766, 89.0% lines) plus downloaded `artifacts/pester/kcov-ci/cov.xml`
- Per-language comparison summary: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/qa-gates/coverage-delta.2026-07-22T09-01.md`
- TypeScript baseline coverage artifact: `N/A - out of scope (zero changed TypeScript files on this branch)`
- TypeScript post-change coverage artifact: `N/A - out of scope (zero changed TypeScript files on this branch)`
- PowerShell baseline coverage artifact: `N/A - out of scope (zero changed PowerShell files on this branch)`
- PowerShell post-change coverage artifact: `N/A - out of scope (zero changed PowerShell files on this branch)`
- Python / C# artifacts: `N/A - zero changed files on this branch`

**Threshold basis (assumption documented):** the uniform tier rule per `.claude/rules/quality-tiers.md` (Authoritative Decision #2) applies: line coverage >= 85% for new files, modified files, and repo-wide, with no regression. The 90% "new code" figure that appears in the legacy policy-audit template text is superseded by the uniform rule; repository precedent applies the 85% gate to new bash files (feature #393 audit passed new files at 88.6% / 87.6%). For completeness: `cleanup_worktrees_lib.sh` (88.5%) and `cleanup_worktrees_actions_lib.sh` (89.8%) are below 90% but above the authoritative 85% gate.

---

## Rejected Scope Narrowing

None detected. The caller instruction explicitly requested the full branch diff versus `main` ("Scope is the full branch diff, not narrowed to any subset of commits"). No narrowing was attempted; the audit scope is the full feature-vs-base diff.

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` -> exit 0 (no violations).
- Branch diff inspection (`git diff --name-status b2351cbc..HEAD`): zero files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All feature evidence lives at the canonical `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/{baseline,qa-gates}/` paths. **PASS.**

---

## Executive Summary

The branch delivers the cleanup-merged-worktrees feature (issue #396): a deterministic bash CLI (`cleanup-worktrees.sh` + two sourceable libraries), a Claude Code skill documenting the detect -> report -> consolidate -> pr-author handoff -> post-merge deletion workflow, 36 new bats tests driven through a checked-in git-binary stub with checked-in fixtures, and complete scoping/evidence documentation. Work mode is `full-feature`.

All policy gates pass. Formatting (shfmt) and linting (shellcheck) were re-verified check-only by this reviewer locally (exit 0 for both over the three production scripts and the test stub) and are confirmed by executor evidence and the green CI run. The bats suite and kcov coverage were verified through the CI dispatch path (run 29922832766, green, on this branch at commit `4851f3c9`; the only delta between that commit and the branch head `69188347` is docs/evidence files under `docs/features/**`, verified with `git diff --name-only 4851f3c9..HEAD`). No `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` paths are modified, so the `modified-workflow-needs-green-run` rule does not fire; a green branch-head-content run exists regardless.

**Policy documents evaluated:**
- PASS `general-code-change` policy (`.claude/rules/general-code-change.md`)
- PASS `general-unit-test` policy (`.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- PASS Bash: `.claude/rules/shell.md` (shfmt + shellcheck + bats + kcov)
- N/A Python, PowerShell, TypeScript, C#: zero changed files
- PASS Tonality (`.claude/rules/tonality.md`): the new SKILL.md and all evidence docs use neutral, factual language.

**Temporary artifacts cleanup:**
- PASS No temporary or throwaway scripts remain in the diff; all added scripts are permanent tooling with tests.
- PASS The checked-in git stub is test infrastructure under `tests/fixtures/`, documented and shellcheck-clean.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Each `@test` builds its own `run env ... bash -c "source ...; <fn>"` invocation with scenario selected via `CLEANUP_WT_STUB_SCENARIO`; no shared mutable state between tests; `setup()` only computes paths and restores the stub's executable bit. |
| **Isolation** - Each test targets single behavior | PASS | Suites are split by concern (enumeration, classification, consolidation, deletion, CLI). Tests exercise one library function or one CLI path each. |
| **Fast Execution** - Tests complete quickly | PASS | Stub-only subprocesses; CI run 29922832766 completed the 80-test TAP suite within the normal `_shell-coverage.yml` run time. |
| **Determinism** - Consistent results | PASS | The git binary itself is stubbed (`CLEANUP_WT_GIT_BIN` seam); canned stdout/exit codes replayed from checked-in fixtures; `LC_ALL=C` ordering asserted; no wall-clock, randomness, or network. Two fallback tests invoke only `git --version` on the real binary. |
| **Readability & Maintainability** - Clear structure | PASS | Header comments state each suite's scope; helper functions (`cb`, `report`, `apply`) name the pattern; assertions use exact-line or substring matches on the documented report contract. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Baseline 88.2% bash lines. Command: `gh workflow run _shell-coverage.yml` (run 29918840204). Evidence: `evidence/baseline/shell-coverage-ci.2026-07-22T08-12.md`. Captured before implementation (P0-T3). |
| **No Coverage Regression** | PASS | Post-change 89.0% lines (+0.8%). Baseline 88.2% -> 89.0%. Reviewer re-parsed `artifacts/pester/kcov-ci/cov.xml`: overall `line-rate="0.890"`. |
| **New Code Coverage** | PASS | New files: `cleanup-worktrees.sh` 100.0%, `cleanup_worktrees_lib.sh` 88.5%, `cleanup_worktrees_actions_lib.sh` 89.8% — all >= the uniform 85% line gate (see threshold-basis note above). Branch coverage not measurable for bash per `.claude/rules/shell.md`. |
| **Comprehensive Coverage** | PASS | All exported functions in both libraries are exercised: enumeration (2 fns), parsing (1), protection (1), freshness (1), ladder rungs (4), candidate selection (1), branch orchestration (1), report driver (1), consolidation (3), merge gate (1), deletion (4), apply driver (1), plus wrapper dispatch/usage/source-guard. |
| **Positive Flows** | PASS | merged_no_worktree, merged_with_worktree, content_neutral, residual_on_main, consolidation ok, consolidated_merged, CLI report/apply happy paths. |
| **Negative Flows** | PASS | unknown CLI argument (exit 2), pre-existing consolidation branch refusal, dirty-worktree block, reverify flip block, consolidation-unmerged gate. |
| **Edge Cases** | PASS | ancestry_error (merge-base exit 128 -> hard failure, never "not merged"), detached/locked/prunable worktree stanzas, empty cherry-pick reclassification, main divergence WARN, seam fallback with empty/nonexistent override. |
| **Error Handling** | PASS | `ANCESTRY_ERROR` propagates a non-zero run_report exit; conflict pick aborts and returns non-zero; CLI usage error exits 2. |
| **Concurrency** | N/A | Single-process CLI tool; no concurrent execution paths. |
| **State Transitions** | PASS | Classification-state ladder transitions covered per rung, including the HAS_UNIQUE_RESIDUALS vs NOT_MERGED split and the CONFLICT/CONTENT_ON_MAIN reclassification. |

### 1.2.1 Per-Language Coverage Comparison

- Bash: Baseline: 88.2% lines -> Post-change: 89.0% lines. Change: +0.8% lines. New/changed-code coverage: 88.5% minimum per new file (the three new files measure 100.0%, 88.5%, and 89.8%). Disposition: PASS. Evidence: `evidence/qa-gates/coverage-delta.2026-07-22T09-01.md`, `artifacts/pester/kcov-ci/cov.xml`, CI run 29922832766.
- TypeScript: `N/A - zero changed files on this branch`.
- Python: `N/A - zero changed files on this branch`.
- PowerShell: `N/A - zero changed files on this branch`.
- C#: `N/A - zero changed files on this branch`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | bats reports the failing assertion line; exact-string assertions (`[ "$output" = ... ]`, `[ "${lines[N]}" = ... ]`) identify the divergent record directly. |
| **Arrange-Act-Assert Pattern** | PASS | Arrange = scenario env + fixture dir; Act = `run env ... bash -c`; Assert = status + output assertions. Consistent across all 36 tests. |
| **Document Intent** | PASS | Every suite has a scope header comment; test names describe scenario and expected outcome (e.g., "a dirty worktree blocks removal, reports DIRTY lines, and never forces"). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, no databases, no scratch git repositories. The stub never touches a real repository and writes nothing to disk. Two seam-fallback tests invoke the real `git --version` only (read-only, no repo access). |
| **Use Mocks/Stubs** | PASS | The git binary itself is stubbed via the `CLEANUP_WT_GIT_BIN` seam, replaying checked-in fixtures — the same convention as the existing `SHELL_QC_<TOOL>_BIN` seam. |
| **Environment Stability** | PASS | **No temporary files created** (policy: strictly prohibited). All fixtures are checked in under `tests/fixtures/cleanup_worktrees/`. `chmod +x` on the checked-in stub is a permission restoration, not file creation. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the required policy review for the feature branch. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #396; `issue.md`, `spec.md`, `user-story.md` present with `- Work Mode: full-feature`. |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.md` records the P0-T1 policy reading order. |
| **Document the plan** | PASS | `plan.2026-07-22T07-46.md` (atomic plan, all tasks checked) and `research/2026-07-22T08-30-cleanup-merged-worktrees-research.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Thin wrapper + two function libraries; each function does one ladder rung or one action; no indirection layers beyond the documented git seam. |
| **Reusability** | PASS | The `CLEANUP_WT_GIT_BIN` seam mirrors the established `SHELL_QC_<TOOL>_BIN` convention; report-line contract shared by report and apply drivers. |
| **Extensibility** | PASS | Classification states and per-commit states are closed enums documented as a contract; new rungs/actions attach as functions. |
| **Separation of concerns** | PASS | Read-only classification (`cleanup_worktrees_lib.sh`) is a separate file from mutating actions (`cleanup_worktrees_actions_lib.sh`); the wrapper only dispatches. One deviation noted: stub-aware stderr re-surfacing inside `cherry_pick_candidates` (see code review finding CR-2). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Enumeration/classification vs consolidation/deletion split matches the 500-line cap plan (Planner Decision 1). |
| **Under 500 lines** | PASS | 86 / 499 / 300 / 193 (stub) / 63-101 (bats). Reviewer note: `cleanup_worktrees_lib.sh` at 499 lines is at the cap boundary; any future addition to that file requires a split. Evidence: `evidence/qa-gates/file-size-caps.2026-07-22T09-01.md`; independently spot-checked. |
| **Public vs internal** | PASS | Internal helper `_blob_equal` uses the underscore prefix; the report-line contract is the public surface. |
| **No circular dependencies** | PASS | `actions_lib` depends on `lib`; the wrapper sources both in order; no reverse dependency. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `classify_ancestry`, `reverify_delete_eligible`, `cleanup_consolidation_on_abort`, etc.; snake_case throughout. |
| **Docs/docstrings** | PASS | Every function has a purpose/args/returns comment block; both library headers document the sourcing contract and report-line contract. |
| **Comment why, not what** | PASS | Comments explain rationale (e.g., why `-D` not `-d`; why the diff --quiet short-circuit runs before `git cherry`; why `-x` on cherry-picks). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `bash scripts/bash/shell-qc.sh format` -> exit 0, no rewrites (executor evidence `final-shell-format.2026-07-22T09-01.md`). Reviewer re-check: `shfmt -d` over the 3 production scripts + stub -> exit 0. |
| **2. Linting** | PASS | **Command:** `bash scripts/bash/shell-qc.sh check` -> exit 0 (7 discovered scripts). Reviewer re-check: `shellcheck` over the 3 production scripts + stub -> exit 0. |
| **3. Type checking** | N/A | Not applicable for bash per `.claude/rules/shell.md` (optional `bash -n` only). |
| **4. Testing** | PASS | **Command:** CI dispatch `gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-07-21T21-57` -> run 29922832766 green, TAP `1..80`, 0 failures. Local bats execution is not possible in this Windows environment; CI dispatch is the sanctioned verification path (spec Constraints; `.claude/rules/shell.md` CI-canonical rule). |
| **Full toolchain loop** | PASS | One remediation cycle occurred (first coverage dispatch 29922246766 red due to test-only stderr-merge assertions); after test-only commit `4851f3c9` the loop was restarted and P7-T1..P7-T4 completed clean in a single pass. Evidence: `final-qa-summary.2026-07-22T09-01.md`. |
| **Explicit reporting** | PASS | All commands, exit codes, and run URLs recorded in `evidence/qa-gates/*.md`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages `28861a8a`, `4851f3c9`, `69188347` describe scope; spec Overview matches delivery. |
| **Design choices explained** | PASS | Research doc + spec carry the design decisions (ancestry primitive, ladder, `-D` refinement, stub-vs-scratch-repo policy resolution). |
| **Update supporting documents** | PASS | New SKILL.md; feature-folder docs complete. |
| **Provide next steps** | PASS | Spec Definition of Done and the pr-author handoff path are documented. |

---

## 3. Language-Specific Code Change Policy Compliance

Sections for Python, PowerShell, TypeScript, C#, and JSON are omitted: zero changed files in those languages on this branch.

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | PASS | **Command:** `bash scripts/bash/shell-qc.sh format` -> exit 0, no rewrites; format idempotency verified by executor (md5 unchanged). Reviewer check-only re-run: `shfmt -d scripts/bash/cleanup-worktrees.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh tests/fixtures/cleanup_worktrees/stub-bin/git` -> exit 0. |
| **Linting with shellcheck** | PASS | **Command:** `bash scripts/bash/shell-qc.sh check` -> exit 0. Reviewer check-only re-run over the same four files -> exit 0. The stub is outside the `tools/`/`scripts/` discovery roots but was verified shellcheck-clean directly. Suppressions: two justified inline `# shellcheck disable=SC1091` in the wrapper (runtime-resolved source paths) with reasons stated — compliant with the suppression policy. |
| **Testing with bats** | PASS | CI run 29922832766: 80/80 pass including the 36 new tests. Coverage: `bash scripts/bash/shell-qc.sh test --coverage` in CI -> `Bash coverage (lines): 89.0%`. |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | PASS | `#!/usr/bin/env bash` in all three production scripts and the stub; `#!/usr/bin/env bats` in test suites. |
| **Error handling** | PASS (with one Major robustness finding) | Wrapper uses `set -euo pipefail` with a source-guard and explicit final `exit "$rc"`. Expected non-zero git exits are captured with the house or-capture idiom (`rc=$?` after the command) so intended failures do not abort the run. Finding CR-1 (code review): the or-capture assignments placed inside process substitutions are dead in the parent shell, leaving a latent fail-open on abnormal `git cherry` / `git worktree list` / `git rev-list` termination. Not a gate failure (spec-enumerated error conditions are handled; the affected path requires an anomalous git failure), but recommended for follow-up hardening. |
| **Under 500 lines** | PASS | 86 / 499 / 300 lines; every bats suite <= 101 lines; stub 193 lines. |

---

## 4. Language-Specific Unit Test Policy Compliance

Python, PowerShell, TypeScript, and C# unit-test sections are omitted: no tests in those languages changed. Bash unit-test compliance is governed by `.claude/rules/shell.md`:

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework: bats under `tests/shell/`** | PASS | Five new `tests/shell/test_cleanup_worktrees_*.bats` suites; no new framework introduced. |
| **Tests mirror `scripts/bash/`** | PASS | Suites map to `cleanup_worktrees_lib.sh` (enumeration, classification), `cleanup_worktrees_actions_lib.sh` (consolidation, deletion), and `cleanup-worktrees.sh` (cli). |
| **No temporary files; checked-in fixtures and stub binaries via the env seam** | PASS | All fixtures under `tests/fixtures/cleanup_worktrees/`; stub wired through `CLEANUP_WT_GIT_BIN` (the tool's analogue of `SHELL_QC_<TOOL>_BIN`); stub writes nothing to disk. |
| **Coverage >= 85% lines on library files; wrapper thin** | PASS | 88.5% / 89.8% on the libraries; wrapper 100.0% and 86 lines. |

---

## 5. Test Coverage Detail

### cleanup_worktrees_lib.sh — enumeration/classification (19 tests: 11 enumeration + 8 classification)

| Test Name | Scenario Type | Target | Status |
|-----------|--------------|--------|--------|
| enumerate_branches emits name/sha pairs in LC_ALL=C order | Positive | `enumerate_branches` | PASS |
| parse_worktree_list parses a branch stanza and marks the first as main | Positive | `parse_worktree_list` | PASS |
| parse_worktree_list parses a detached and locked stanza | Edge Case | `parse_worktree_list` | PASS |
| parse_worktree_list parses a prunable stanza | Edge Case | `parse_worktree_list` | PASS |
| cleanup_wt_git honors an executable CLEANUP_WT_GIT_BIN override | Positive | `cleanup_wt_git` | PASS |
| cleanup_wt_git falls back to PATH git when the override is empty | Negative | `cleanup_wt_git` | PASS |
| cleanup_wt_git falls back to PATH git when the override does not exist | Negative | `cleanup_wt_git` | PASS |
| compute_protected protects the current branch (dual-check: branch match) | Positive | `compute_protected` | PASS |
| compute_protected protects the current worktree path and always the main worktree | Positive | `compute_protected` | PASS |
| check_main_freshness emits WARN on main/origin divergence and returns 0 | Edge Case | `check_main_freshness` | PASS |
| check_main_freshness emits nothing when main matches origin/main | Positive | `check_main_freshness` | PASS |
| merged_no_worktree: MERGED_CLEAN and no worktree record | Positive (AC8-1) | `classify_branch`, `run_report` | PASS |
| merged_with_worktree: MERGED_CLEAN plus its WORKTREE record | Positive (AC8-2) | `run_report` | PASS |
| unmerged: NOT_MERGED (excluded from destructive action) | Negative (AC8-3) | `classify_branch` | PASS |
| ancestry_error: run fails with ANCESTRY_ERROR, not classified as unmerged | Error Handling | `classify_ancestry`, `run_report` | PASS |
| content_neutral: MERGED_CONTENT_NEUTRAL via the diff --quiet short-circuit | Edge Case | `classify_content_neutral` | PASS |
| residual_on_main: MERGED_EQUIVALENT with no cherry-pick candidates | Positive (AC8-4) | `classify_cherry_equivalent`, blob tier | PASS |
| residual_unique_doc: HAS_UNIQUE_RESIDUALS with a UNIQUE COMMIT record | Positive (AC8-5) | `select_cherry_pick_candidates` | PASS |
| current_exclusion: PROTECTED_CURRENT and never delete-eligible | Negative (AC8-6) | `compute_protected`, `classify_branch` | PASS |

### cleanup_worktrees_actions_lib.sh — consolidation/deletion (12 tests: 6 + 6)

| Test Name | Scenario Type | Target | Status |
|-----------|--------------|--------|--------|
| pre-existing documentationandmemories branch stops the run with a report | Negative | `create_consolidation_worktree` | PASS |
| fresh run creates the consolidation worktree off main via worktree add | Positive | `create_consolidation_worktree` | PASS |
| candidates are cherry-picked in fed order with -x on every commit | Positive | `cherry_pick_candidates` | PASS |
| a conflicting pick aborts, records CONFLICT, and skips the rest of its branch | Error Handling | `cherry_pick_candidates` | PASS |
| an empty pick is skipped and the commit is reclassified as content-on-main | Edge Case | `cherry_pick_candidates` | PASS |
| abort cleanup removes the consolidation worktree and branch | Positive | `cleanup_consolidation_on_abort` | PASS |
| a dirty worktree blocks removal, reports DIRTY lines, and never forces | Negative | `run_apply`, `remove_worktree_safe` | PASS |
| a candidate whose re-verification flips is blocked before any branch delete | Negative | `delete_candidate`, `reverify_delete_eligible` | PASS |
| worktree removal is invoked strictly before branch deletion | Positive | `delete_candidate` ordering | PASS |
| a merged branch with no worktree gets only a branch delete | Edge Case | `delete_candidate` | PASS |
| non-eligible states produce no destructive argv | Negative | `run_apply` allowlist gate | PASS |
| consolidated-content branch deletion is gated on the merge check | State Transition | `run_apply`, `verify_consolidation_merged` | PASS |

### cleanup-worktrees.sh — CLI (5 tests)

| Test Name | Scenario Type | Target | Status |
|-----------|--------------|--------|--------|
| --help prints usage and exits 0 | Positive | `usage`, `main` | PASS |
| an unknown argument prints usage to stderr and exits 2 | Negative | `main` | PASS |
| default report mode emits classification lines and performs no mutation | Positive | report default | PASS |
| apply mode emits ACTION lines and destructive argv only for eligible states | Positive | apply dispatch | PASS |
| sourcing the wrapper does not execute main (source-guard) | Edge Case | source-guard | PASS |

**Coverage:** 89.0% overall bash lines; per new file 100.0% / 88.5% / 89.8%.

**Not covered:** the residual uncovered lines in the two libraries (11.5% / 10.2%) are error-branch report lines (e.g., `worktree-add FAILED`, `branch-delete FAILED` paths) per the kcov class data — acceptable at the 85% uniform gate.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (bash suite, CI) | 80 (TAP `1..80`) | PASS |
| Tests Passed | 80 (100%) | PASS |
| Tests Failed | 0 | PASS |
| New tests in this feature | 36 (enumeration 11, classification 8, consolidation 6, deletion 6, CLI 5) | PASS |
| Execution environment | `ubuntu-latest`, CI run 29922832766 (green) | PASS |
| Code Coverage | 89.0% lines (bash; branch coverage not measurable by kcov) | PASS |
| Largest test file | 101 lines (`test_cleanup_worktrees_enumeration.bats`) | PASS Maintainable |

---

## 7. Code Quality Checks

**For Bash:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| shfmt (format diff) | `bash scripts/bash/shell-qc.sh check` (stage 1) / reviewer `shfmt -d <4 files>` | clean, exit 0 | PASS |
| shellcheck | `bash scripts/bash/shell-qc.sh check` (stage 2) / reviewer `shellcheck <4 files>` | 0 findings, exit 0 | PASS |
| bats + kcov | CI dispatch `_shell-coverage.yml` run 29922832766 | 80/80 green, 89.0% lines | PASS |
| File-size caps | `wc -l` (executor evidence, spot-checked) | all <= 500 | PASS |
| Evidence locations | `python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | PASS |

**Notes:**
- Local shfmt/shellcheck are winget installs and may drift from CI's pinned shfmt 3.8.0 / apt shellcheck; CI versions are canonical and the CI run is green, so local agreement is corroborating rather than authoritative.
- The bats/kcov stage cannot run locally in this Windows environment; CI dispatch is the sanctioned verification path per the spec's Constraints section and `.claude/rules/shell.md`.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **CR-1 (Major, non-blocking):** `|| rc=$?` captures inside process substitutions (`cleanup_worktrees_lib.sh` lines 117, 270, 375) execute in a subshell, so the parent function's `rc` is never updated. An abnormal hard failure of `git cherry` (empty output + non-zero exit) after the earlier ladder rungs succeeded would classify a branch `MERGED_EQUIVALENT` (fail-open) instead of failing fast. Mitigations that bound the risk: report mode is the default and mutates nothing; apply-mode deletion re-verifies in-process; git itself refuses to delete a checked-out branch; the failure mode requires git to fail on `cherry` while succeeding on `merge-base`/`diff` in the same process. Recommended follow-up: capture command output via command substitution with explicit exit-code propagation (details in `code-review.2026-07-22T09-23.md`). Not a policy-gate failure; tracked as a code-review Major finding.
- No other gaps. All policy requirements are met.

### Approved Exceptions

- **None required.** The "scratch git repo integration fixture" idea from the issue draft was resolved at spec time as conflicting with the no-temp-files policy; the compliant stub-driven approach was delivered instead (spec "Seeded Test Conditions"). This is a documented scope resolution, not a policy exception.

### Removed/Skipped Tests

- **None.** All planned tests implemented; 0 skips in the TAP output.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **28861a8a** - feat(shell): add cleanup-merged-worktrees tool, tests, fixtures, and skill (#396)
2. **4851f3c9** - test(shell): isolate stub stderr in exact-match bats assertions and harden source-guard (#396)
3. **69188347** - docs(shell): record cleanup-merged-worktrees plan/AC completion and Phase 7 QA evidence (#396)

### Files Modified

1. **scripts/bash/cleanup-worktrees.sh** (NEW) — thin CLI wrapper: dispatch, usage heredoc, source-guard, exit-code discipline.
2. **scripts/bash/cleanup_worktrees_lib.sh** (NEW) — git seam, enumeration, worktree parsing, dual current-exclusion, freshness warning, four-rung classification ladder, report driver.
3. **scripts/bash/cleanup_worktrees_actions_lib.sh** (NEW) — consolidation (dedicated worktree, cherry-pick with conflict/empty handling, abort cleanup), merge gate, deletion mechanics, apply driver.
4. **.claude/skills/cleanup-merged-worktrees/SKILL.md** (NEW) — end-to-end workflow with pr-author delegation and prohibited-shortcuts list; narrow allowed-tools.
5. **tests/shell/test_cleanup_worktrees_*.bats** (NEW, 5 files) — 36 tests.
6. **tests/fixtures/cleanup_worktrees/** (NEW) — recording git stub (193 lines) + scenario/consolidation/deletion fixtures (canned porcelain output and exit codes).
7. **docs/features/active/2026-07-22-cleanup-merged-worktrees-396/** (NEW) — issue/spec/user-story/plan/research + baseline and qa-gates evidence.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All uniform gates pass for the one language with changed code (bash): format clean, lint clean, 80/80 tests green in CI at branch-head content, line coverage 89.0% repo-wide and >= 85% per new file with no regression, all files within the 500-line cap, no temporary files, evidence at canonical locations, and no CI-gate paths modified. One Major (non-blocking) robustness finding is documented in the code review for follow-up hardening.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: issue/spec/plan/research all present.
- PASS Design Principles: clean wrapper/library split, seam reuse.
- PASS Module & File Structure: all files <= 500 lines (one at 499 — boundary note).
- PASS Naming, Docs, Comments: consistent, rationale-focused.
- PASS Toolchain Execution: single clean pass after one documented remediation cycle.
- PASS Summarize & Document: evidence complete.

#### Language-Specific Code Change Policy (Section 3)
- PASS Bash Tooling & Baseline: shfmt/shellcheck/bats/kcov all green.
- PASS Bash Design: shebang, `set -euo pipefail`, source-guard, quoting, seam (CR-1 noted for follow-up).
- PASS Size caps.

#### General Unit Test Policy (Section 1)
- PASS Core Principles.
- PASS Coverage & Scenarios (89.0% / per-file >= 85%).
- PASS Test Structure.
- PASS External Dependencies (no temp files, stubbed git).
- PASS Policy Audit.

#### Language-Specific Unit Test Policy (Section 4)
- PASS Bash: bats under `tests/shell/`, mirrored layout, checked-in fixtures, seam-stubbed binary.

---

### Metrics Summary

- PASS 80/80 tests passing (100%), 36 new
- PASS 89.0% bash line coverage repo-wide (baseline 88.2%, +0.8%)
- PASS New files 100.0% / 88.5% / 89.8% lines (>= 85% uniform gate)
- PASS 0 shfmt / 0 shellcheck findings
- PASS All files <= 500 lines
- PASS Evidence-location validator exit 0

---

### Recommendation

**Ready for merge.** Zero blocking findings. Recommended (non-gating) follow-up: harden the dead `|| rc=$?` captures in process substitutions per code-review finding CR-1.

---

## Appendix A: Test Inventory

- test_cleanup_worktrees_enumeration.bats :: enumerate_branches emits name/sha pairs in LC_ALL=C order
- test_cleanup_worktrees_enumeration.bats :: parse_worktree_list parses a branch stanza and marks the first as main
- test_cleanup_worktrees_enumeration.bats :: parse_worktree_list parses a detached and locked stanza
- test_cleanup_worktrees_enumeration.bats :: parse_worktree_list parses a prunable stanza
- test_cleanup_worktrees_enumeration.bats :: cleanup_wt_git honors an executable CLEANUP_WT_GIT_BIN override
- test_cleanup_worktrees_enumeration.bats :: cleanup_wt_git falls back to PATH git when the override is empty
- test_cleanup_worktrees_enumeration.bats :: cleanup_wt_git falls back to PATH git when the override does not exist
- test_cleanup_worktrees_enumeration.bats :: compute_protected protects the current branch (dual-check: branch match)
- test_cleanup_worktrees_enumeration.bats :: compute_protected protects the current worktree path and always the main worktree
- test_cleanup_worktrees_enumeration.bats :: check_main_freshness emits WARN on main/origin divergence and returns 0
- test_cleanup_worktrees_enumeration.bats :: check_main_freshness emits nothing when main matches origin/main
- test_cleanup_worktrees_classification.bats :: merged_no_worktree: MERGED_CLEAN and no worktree record for the branch
- test_cleanup_worktrees_classification.bats :: merged_with_worktree: MERGED_CLEAN plus its WORKTREE record
- test_cleanup_worktrees_classification.bats :: unmerged: NOT_MERGED (excluded from destructive action)
- test_cleanup_worktrees_classification.bats :: ancestry_error: run fails with ANCESTRY_ERROR, not classified as unmerged
- test_cleanup_worktrees_classification.bats :: content_neutral: MERGED_CONTENT_NEUTRAL via the diff --quiet short-circuit
- test_cleanup_worktrees_classification.bats :: residual_on_main: MERGED_EQUIVALENT with no cherry-pick candidates
- test_cleanup_worktrees_classification.bats :: residual_unique_doc: HAS_UNIQUE_RESIDUALS with a UNIQUE COMMIT record
- test_cleanup_worktrees_classification.bats :: current_exclusion: PROTECTED_CURRENT and never delete-eligible
- test_cleanup_worktrees_consolidation.bats :: pre-existing documentationandmemories branch stops the run with a report
- test_cleanup_worktrees_consolidation.bats :: fresh run creates the consolidation worktree off main via worktree add
- test_cleanup_worktrees_consolidation.bats :: candidates are cherry-picked in fed order with -x on every commit
- test_cleanup_worktrees_consolidation.bats :: a conflicting pick aborts, records CONFLICT, and skips the rest of its branch
- test_cleanup_worktrees_consolidation.bats :: an empty pick is skipped and the commit is reclassified as content-on-main
- test_cleanup_worktrees_consolidation.bats :: abort cleanup removes the consolidation worktree and branch
- test_cleanup_worktrees_deletion.bats :: a dirty worktree blocks removal, reports DIRTY lines, and never forces
- test_cleanup_worktrees_deletion.bats :: a candidate whose re-verification flips is blocked before any branch delete
- test_cleanup_worktrees_deletion.bats :: worktree removal is invoked strictly before branch deletion
- test_cleanup_worktrees_deletion.bats :: a merged branch with no worktree gets only a branch delete
- test_cleanup_worktrees_deletion.bats :: non-eligible states produce no destructive argv
- test_cleanup_worktrees_deletion.bats :: consolidated-content branch deletion is gated on the merge check
- test_cleanup_worktrees_cli.bats :: --help prints usage and exits 0
- test_cleanup_worktrees_cli.bats :: an unknown argument prints usage to stderr and exits 2
- test_cleanup_worktrees_cli.bats :: default report mode emits classification lines and performs no mutation
- test_cleanup_worktrees_cli.bats :: apply mode emits ACTION lines and destructive argv only for eligible states
- test_cleanup_worktrees_cli.bats :: sourcing the wrapper does not execute main (source-guard)

(Plus the 44 pre-existing shell-qc suite tests, all green in the same CI run.)

---

## Appendix B: Toolchain Commands Reference

**For Bash (this feature's only code language):**
```bash
# Formatting (write mode)
bash scripts/bash/shell-qc.sh format

# Format diff + lint (check-only)
bash scripts/bash/shell-qc.sh check

# Tests
bash scripts/bash/shell-qc.sh test

# Tests with kcov line coverage (canonical: CI on ubuntu-latest)
bash scripts/bash/shell-qc.sh test --coverage
gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-07-21T21-57
gh run watch <run-id> --exit-status
gh run download <run-id> --name shell-coverage --dir artifacts/pester/kcov-ci
```

**Reviewer check-only re-verification commands used in this audit:**
```bash
shfmt -d scripts/bash/cleanup-worktrees.sh scripts/bash/cleanup_worktrees_lib.sh \
  scripts/bash/cleanup_worktrees_actions_lib.sh tests/fixtures/cleanup_worktrees/stub-bin/git
shellcheck scripts/bash/cleanup-worktrees.sh scripts/bash/cleanup_worktrees_lib.sh \
  scripts/bash/cleanup_worktrees_actions_lib.sh tests/fixtures/cleanup_worktrees/stub-bin/git
gh run view 29922832766 --json headSha,conclusion,headBranch
git diff --name-only 4851f3c9..HEAD   # docs-only delta after the green CI run
python scripts/dev_tools/validate_evidence_locations.py --root .
grep -rn "gh pr create|gh pr edit" .claude/skills/cleanup-merged-worktrees/ scripts/bash/cleanup*.sh
```

---

**Audit Completed By:** feature-review agent (Claude Code)
**Audit Date:** 2026-07-22
**Policy Version:** Current (as of audit date)

**Reviewer assumptions (documented per policy):**
1. MCP server tools were unavailable in this session; templates were sourced from the bundled asset path `extensions/drm-copilot/resources/templates/policy_audit/` (the same files the MCP server exposes), and artifact validation was run via the CLI `python scripts/dev_tools/validate_orchestration_artifacts.py` instead of the MCP tool.
2. Coverage thresholds applied are the uniform tier rule (85% line / 75% branch) per `.claude/rules/quality-tiers.md`; kcov cannot measure bash branch coverage, and `.claude/rules/shell.md` defines no bash branch gate.
3. bats/kcov verification relied on the green CI dispatch run 29922832766 at commit `4851f3c9`; the branch head `69188347` differs from that commit only by `docs/features/**` files (verified), so the run remains representative of the head's shell code.
