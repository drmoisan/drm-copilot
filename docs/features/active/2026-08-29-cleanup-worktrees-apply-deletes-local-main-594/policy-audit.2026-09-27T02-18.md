# Policy Compliance Audit: cleanup-worktrees base-branch protection (#594)

**Audit Date:** 2026-09-27 (UTC)
**Branch:** `bug/cleanup-worktrees-apply-deletes-local-main-594`, HEAD `c00d9587a5568caacfe17e56198e60eeae09f540`
**Base:** `origin/main`, merge base `b67453837646fd2dd4f5ac692f76e6f7703fe798`
**Code Under Test:**
- Bash production: `scripts/bash/cleanup_worktrees_enumerate_lib.sh`, `scripts/bash/cleanup_worktrees_actions_lib.sh`, `scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup_worktrees_report_records_lib.sh`, `scripts/bash/cleanup-worktrees.sh`
- Bash tests (bats): `tests/shell/test_cleanup_worktrees_enumeration.bats`, `tests/shell/test_cleanup_worktrees_classification.bats`, `tests/shell/test_cleanup_worktrees_deletion.bats`
- Test fixtures (plain text, 8 files): `tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out/*`, `tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree/*`
- Markdown: `.claude/skills/cleanup-merged-worktrees/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`, and feature-folder documents and evidence

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Bash | 8 files (5 production, 3 bats) | 473 tests (CI full suite; 10 new) | PASS 473 pass, 0 fail | 93.3% lines (repo-wide bash, CI run 36285238036) | 93.3% lines (repo-wide bash, CI run 36287146354) | 100% (6 of 6 instrumented added lines) |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Python | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| PowerShell | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files in the branch diff)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files in the branch diff)
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files in the branch diff)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files in the branch diff)
- Bash baseline coverage artifact: `evidence/baseline/ci-shell-coverage.2026-09-27T01-27.md` and `evidence/baseline/kcov-per-file.2026-09-27T01-28.md` (CI run 36285238036)
- Bash post-change coverage artifact: `evidence/qa-gates/kcov/coverage-summary.2026-09-27T02-12.md` and `evidence/qa-gates/kcov/added-line-hits.2026-09-27T02-14.md` (CI run 36287146354 `shell-coverage` artifact, `cov.xml`)
- Per-language comparison summary: section 1.2.1 of this document and `evidence/qa-gates/coverage-delta.2026-09-27T02-15.md`

---

## Executive Summary

The branch fixes issue #594: `cleanup-worktrees.sh --apply` deleted local `main` when the primary worktree had a different branch checked out. The fix adds a non-overridable constant `CLEANUP_WT_BASE_BRANCH="main"`, emits `protected-branch|main` from `compute_protected` in every checkout topology (after the two `rev-parse` fail-closed guards, and without duplication when the current branch is `main`), and adds a defense-in-depth refusal at the top of `delete_candidate` that emits `ACTION|delete|main|BLOCKED-PROTECTED-BASE` before any git call. Comments, help text, and both SKILL.md copies were corrected. Ten bats tests and two scenario fixture directories were added.

**Policy documents evaluated:**
- PASS `.claude/rules/general-code-change.md` (mirror of `general-code-change.instructions.md`)
- PASS `.claude/rules/general-unit-test.md` (mirror of `general-unit-test.instructions.md`)
- PASS `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- N/A Python, TypeScript, PowerShell, C# (zero changed files for each)
- PASS Bash: `.claude/rules/shell.md` (shfmt + shellcheck + bats + kcov)
- N/A JSON (no JSON files changed)

The reviewer independently verified: the full branch file list against merge base `b6745383`; the production and test diff; `gh run view 36287146354` (conclusion `success`, all steps including "Run shell-qc check (shfmt diff + shellcheck)" and "Run shell-qc test with coverage" `success`, headSha `e29ad95d`); the downloaded `cov.xml` from that run (overall line-rate 0.933; per-file rates and added-line hits match the executor's evidence); that no code, test, or skill path changed between `e29ad95d` and HEAD; `wc -l` for all changed shell files; SKILL.md byte parity; golden and out-of-scope file immutability; and `validate_evidence_locations.py --root .` (exit 0).

Blocking findings: 0. Non-blocking findings: 2. Informational findings: 7 (see section 8).

**Temporary artifacts cleanup:**
- PASS No temporary or one-time scripts were added to the repository by this branch. The executor states the CI log and kcov download were held in its session scratchpad outside the repository; the branch diff contains no such files.
- PASS No new tooling scripts were added.

---

## Rejected Scope Narrowing

- Caller text: "Diff base: use 92d78897371cc5c4f301c8cc2238adeb3fff2fea (`git diff 92d78897 HEAD`)."
- Justification: `92d78897` is the branch's third commit, so a diff from it omits the branch's own `issue.md` creation, research document, and spec creation commits; the audit scope is the full branch diff against the resolved base, so this audit used merge base `b67453837646fd2dd4f5ac692f76e6f7703fe798` (`git diff b6745383 HEAD`, equivalent to `git diff origin/main...HEAD`). The two scopes differ only by three feature-folder Markdown files (`issue.md`, `research/research.2026-09-25T22-10.md`, and the initial `spec.md` body); no code, test, or fixture finding depends on the difference.

---

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — exit 0, no violations reported.
- Branch diff scan: no file in `git diff --name-only b6745383 HEAD` is under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All 55 evidence files are under `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/evidence/{baseline,regression-testing,qa-gates,other}/`.
- Verdict: PASS. No FAIL-level evidence-location findings.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | Each new `@test` runs in its own `run env ... bash -c` subshell and sources the libraries afresh; no shared mutable state. `setup()` only computes paths. |
| **Isolation** | PASS | T1-T3 target `compute_protected`; T4-T5 target `classify_branch`; T6 `run_report`; T7-T8 `run_apply`; T9-T10 `delete_candidate`. One behavior per test. |
| **Fast Execution** | PASS | The 52-test subset completed in about two minutes locally under `npx bats` on Windows (`evidence/regression-testing/pass-after.2026-09-27T01-40.md`); the stub-driven tests invoke no real git. |
| **Determinism** | PASS | git is replaced by the checked-in stub `tests/fixtures/cleanup_worktrees/stub-bin/git` through `CLEANUP_WT_GIT_BIN`; the scan through `CLEANUP_WT_SCAN_BIN`. No clock, randomness, network, or remote refs. |
| **Readability & Maintainability** | PASS | Descriptive `@test` names match the spec's T1-T10 names exactly; each non-obvious test carries a one-line topology comment. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Baseline repo-wide bash 93.3% lines, CI run 36285238036 at `b5f98be2` (`evidence/baseline/ci-shell-coverage.2026-09-27T01-27.md`); per-file baseline in `evidence/baseline/kcov-per-file.2026-09-27T01-28.md`. |
| **No Coverage Regression** | PASS | Repo-wide 93.3% -> 93.3%. enumerate_lib 92.1% -> 92.4%; actions_lib 95.3% -> 95.3%; lib 95.4% -> 95.4%; report_records_lib 89.0% -> 89.0%; cleanup-worktrees.sh 97.6% -> 97.6%. Reviewer re-read the post-change values from the downloaded `cov.xml`. |
| **New/changed code coverage** | PASS | All 6 instrumented added lines (enumerate_lib:169, 212, 213; actions_lib:346, 347, 348) have `hits="1"` in `cov.xml` (reviewer-verified). The two added `fi` lines are not instrumented by kcov. No new production files. |
| **Uniform thresholds (line >= 85%)** | PASS | Every modified production file is >= 85% and repo-wide bash is 93.3%. Branch threshold does not apply (kcov measures line coverage only; `.claude/rules/shell.md`). |
| **Positive Flows** | PASS | T1, T2 (base record emitted alongside prior records), T4-T6 (PROTECTED_CURRENT), T7 positive controls (`feature-merged`, `zeta-merged` still deleted). |
| **Negative Flows** | PASS | T7, T8 assert absence of `branch -D main`, `ACTION|branch-delete|main|`, and `worktree remove /repo-wt/base`; T9, T10 assert refusal with status 1. |
| **Edge Cases** | PASS | T3 pins the no-duplicate case (current branch is `main`); T5/T8/T10 cover the linked-worktree topology; `zeta-merged` sorts after `main` to show the loop continues past the base. |
| **Error Handling** | PASS | Existing `test_cleanup_worktrees_hard_failures.bats` (rev-parse fail-closed) passes unchanged in CI; the new record is emitted only after both guards. |
| **Concurrency** | N/A | Single-process CLI; no concurrency in the changed code. |
| **State Transitions** | N/A | No stateful component changed. |

### 1.2.1 Per-Language Coverage Comparison

- Bash: Baseline: 93.3% lines (repo-wide) -> Post-change: 93.3% lines (repo-wide). Change: +0.0% repo-wide; per-file enumerate_lib +0.3% (92.1% to 92.4%), other four files +0.0%. New/changed-code coverage: 100% (6 of 6 instrumented added lines executed). Disposition: PASS. Evidence: `evidence/qa-gates/coverage-delta.2026-09-27T02-15.md`, `evidence/qa-gates/kcov/coverage-summary.2026-09-27T02-12.md`, `evidence/qa-gates/kcov/added-line-hits.2026-09-27T02-14.md`, CI run 36287146354.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | bats prints the failing assertion line; the fail-before run shows each first failure is a `main` assertion (`evidence/regression-testing/fail-before.2026-09-27T01-33.md`). |
| **Arrange-Act-Assert Pattern** | PASS | Arrange via scenario env vars, act via `run`, assert via `[ ]`/`[[ ]]`. |
| **Document Intent** | PASS | Names state scenario and expected outcome; topology comments in T1, T4, T5, T3. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, no real git repository, no `origin/*` refs. Reviewer grep of the new scenario directories for `origin/`, `/mnt/`, drive roots, `mktemp`, `artifacts/` returned no match. |
| **Use Mocks/Stubs** | PASS | Checked-in git and scan stubs via `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_SCAN_BIN`. |
| **Environment Stability** | PASS | No temporary files, no `BATS_TMPDIR`/`BATS_TEST_TMPDIR`, no `git init`. The only redirection is `2>/dev/null` (T1-T3, T6), which creates no file. Fixtures are LF-only (reviewer grep for CR returned 0). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document, with `code-review.2026-09-27T02-18.md` and `feature-audit.2026-09-27T02-18.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` (#594), `spec.md` root-cause trace and D1-D7. |
| **Read existing change plans** | PASS | `research/research.2026-09-25T22-10.md`; `evidence/baseline/phase0-instructions-read.md`. |
| **Document the plan** | PASS | `plan.2026-09-25T22-07.md`; 103 tasks, all checked (reviewer count: 0 unchecked). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Four executable lines in `compute_protected`, four in `delete_candidate`, one constant. No new state name, no new git call. |
| **Reusability** | PASS | Reuses the existing `protected-branch|` record and rung 1 of `classify_branch`. |
| **Extensibility** | PASS | Single named constant; configurability deferred (D6) with rationale. |
| **Separation of concerns** | PASS | Policy lives in the protection-set producer; enumeration plumbing unchanged (D2). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Changes stay in their owning libraries. |
| **Under 500 lines** | PASS | `wc -l`: enumerate_lib 252, actions_lib 451, lib 496, report_records_lib 476, cleanup-worktrees.sh 234, enumeration.bats 142, classification.bats 273, deletion.bats 199. |
| **Public vs internal** | PASS | No function signature changed. |
| **No circular dependencies** | PASS | actions_lib reads a constant from enumerate_lib, which is sourced first by every caller (documented sourcing contract). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `CLEANUP_WT_BASE_BRANCH` follows the `CLEANUP_WT_CONSOLIDATION_BRANCH` convention. |
| **Docs/docstrings** | PASS | `compute_protected`, `delete_candidate`, `run_apply`, `classify_branch`, `classify_all_branches` comments updated; see non-blocking NB-2 and informational I-3. |
| **Comment why, not what** | PASS | Comments state why the record follows the guards and why the constant is not read from the environment. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | Local shfmt v3.12.0 `-d` no diff (`evidence/qa-gates/qc-step1-shfmt.2026-09-27T01-47.md`); CI shfmt 3.8.0 check step `success` (run 36287146354, reviewer-verified). |
| **2. Linting** | PASS | shellcheck 0.11.0 clean on production and bats files (`qc-step2a`, `qc-step2b`, `qc-step2c`); CI check step `success`. |
| **3. Type checking** | N/A | Bash has no type-check stage; `bash -n` syntax check passed (`qc-step3-syntax`). |
| **4. Architecture-boundary tests** | N/A | No architecture-boundary tooling exists for bash in this repository. |
| **5. Unit tests** | PASS | Local cleanup suites 241/241 (`qc-step4`); CI full shell suite 473/473. |
| **6. Contract / schema checks** | N/A | No contract or schema surface changed; state vocabulary unchanged. |
| **7. Integration tests** | N/A | No integration suite for this script; the CI run is the authoritative execution. |
| **Full toolchain loop** | PASS | Single clean pass, pre/post hash listings identical (`evidence/qa-gates/qc-loop-pass.2026-09-27T01-57.md`). |
| **Explicit reporting** | PASS | Every command and exit code is recorded in the evidence folder. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit subjects `8ad50ace`, `769afaa1`, `763b3865`, `fd4d2656` describe each step. |
| **Design choices explained** | PASS | spec D1-D7; operator approval of D1-D7 supplied 2026-09-26 via the orchestrator prompt. |
| **Update supporting documents** | PASS | Help text and both SKILL.md copies updated and in byte parity. |
| **Provide next steps** | PASS | AC-23 deferred to the PR CI gate; follow-ups listed in section 8. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3C: Bash Script Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **shfmt default formatting (tabs)** | PASS | Production edits use tab indentation; CI shfmt 3.8.0 diff clean. The bats files keep their existing 4-space style, which the CI check accepts. |
| **shellcheck clean, no new suppressions** | PASS | No `# shellcheck disable` added in the diff; `evidence/other/actions-lib-sc2154-check.2026-09-27T01-36.md` records that the cross-file constant reference raises no SC2154. |
| **Quote all expansions** | PASS | `"$CLEANUP_WT_BASE_BRANCH"` and `"$name"` quoted in comparisons and `printf`; the unquoted left side of `[[ ... == ]]` is safe in bash. |
| **Fail-closed contract preserved** | PASS | The base record is emitted after both `rev-parse` guards (`cleanup_worktrees_enumerate_lib.sh:196-214`); `hard_failures.bats` passes unchanged. |
| **Non-overridable constant** | PASS | Plain assignment at `cleanup_worktrees_enumerate_lib.sh:169`; sourcing overwrites any environment value; no `${CLEANUP_WT_BASE_BRANCH:-` form anywhere in `scripts/bash/` (reviewer grep). |
| **500-line limit** | PASS | See 2.3. |

### Sections 3A, 3B, 3D and other languages

N/A. Zero Python, PowerShell, TypeScript, C#, or JSON files are in the branch diff.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4C: Bash (bats) Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Tests in `tests/shell/*.bats`, mirroring `scripts/bash/`** | PASS | Added to the existing enumeration, classification, and deletion suites. |
| **No temporary files** | PASS | No `mktemp`, `BATS_*TMPDIR`, or file redirection in added lines; fixtures are checked in. |
| **Stubs through override seams** | PASS | `CLEANUP_WT_GIT_BIN`, `CLEANUP_WT_SCAN_BIN`, `CLEANUP_WT_STUB_SCENARIO`. |
| **Pre-existing test bodies unmodified** | PASS | `git diff b6745383 HEAD -- tests/shell` contains 0 removed lines (reviewer-verified). |
| **Fail-before / pass-after** | PASS | 9 `not ok` before the fix (T3 passes by design), 52/52 after (`evidence/regression-testing/`). |
| **Assertion strength** | PASS (with note) | T9's negative `merge-base` assertion cannot observe the ladder's `merge-base --is-ancestor` call; see NB-1. The test still discriminates the guard order through its status and token assertions. |

### Sections 4A, 4B and other languages

N/A. No tests in other languages were added or changed.

---

## 5. Test Coverage Detail

### `compute_protected` (3 new tests: T1, T2, T3)

- T1 `base_not_checked_out`: emits `protected-branch|chore-cleanup` and `protected-branch|main`.
- T2 `current_exclusion`: prior records plus `protected-branch|main`.
- T3 `merged_no_worktree` (current branch `main`): exactly one `protected-branch|main`.

### `classify_branch` (2 new tests: T4, T5)

- T4 `base_not_checked_out` and T5 `base_in_linked_worktree`: output equals `BRANCH|main|PROTECTED_CURRENT`.

### `run_report` / `run_apply` (3 new tests: T6, T7, T8)

- T6 report mode, T7 apply mode (with positive controls), T8 linked-worktree apply mode.

### `delete_candidate` (2 new tests: T9, T10)

- T9 empty worktree path and T10 linked worktree path: status 1, `ACTION|delete|main|BLOCKED-PROTECTED-BASE`, no destructive argv.

---

## 6. Test Execution Metrics

| Metric | Value | Source |
|---|---|---|
| Fail-before (3 suites) | 43 ok, 9 not ok (exit 1, expected) | `evidence/regression-testing/fail-before.2026-09-27T01-33.md` |
| Pass-after (3 suites) | 52 ok, 0 not ok | `evidence/regression-testing/pass-after.2026-09-27T01-40.md` |
| Local cleanup suites | 241 ok, 0 not ok | `evidence/qa-gates/qc-step4-bats-cleanup-suites.2026-09-27T01-57.md` |
| CI full shell suite | 473 ok, 0 not ok | CI run 36287146354 (reviewer-verified conclusion `success`) |
| Repo-wide bash line coverage | 93.3% | `cov.xml` line-rate 0.933 (reviewer-verified) |

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|---|---|---|
| shfmt (CI 3.8.0) | PASS | CI step "Run shell-qc check (shfmt diff + shellcheck)" `success` |
| shellcheck | PASS | Same CI step; local `qc-step2a`/`qc-step2b` |
| bash -n | PASS | `qc-step3-syntax.2026-09-27T01-47.md` |
| Golden files unchanged | PASS | `git diff --exit-code b6745383 HEAD -- tests/fixtures/cleanup_worktrees/expected/` exit 0 (reviewer) |
| Out-of-scope files unchanged | PASS | stub-bin, detached_lib, dirt_lib, `.github/` unchanged (reviewer, exit 0) |
| SKILL.md parity | PASS | `git diff --no-index --exit-code` between the two copies exit 0 (reviewer) |
| Coverage exclusion policy | PASS | No coverage configuration changed |

---

## 8. Gaps and Exceptions

### Identified Gaps

Blocking: 0.

Non-blocking:
- NB-1: `tests/shell/test_cleanup_worktrees_deletion.bats` T9 asserts `[[ "$output" != *"merge-base"* ]]`, but `classify_ancestry` runs `merge-base --is-ancestor` with `>/dev/null 2>&1` (`scripts/bash/cleanup_worktrees_lib.sh:71`), so the stub's stderr argv line for that call never reaches `$output`. That single assertion cannot fail through the re-verification ladder. The test still pins the ordering (a guard moved after `reverify_delete_eligible` would emit `BLOCKED-REVERIFY` instead of `BLOCKED-PROTECTED-BASE`). Recommended follow-up: assert that `$output` contains no `stub-git:` line at all, since the guard issues no git call.
- NB-2: `tests/shell/test_cleanup_worktrees_dirt_clear.bats:14` cites `scripts/bash/cleanup-worktrees.sh:145`; the `CLEANUP_WT_CLEAR_DISPOSABLE=1` line is at `:197` on HEAD and was at `:192` at the merge base, so the citation was stale before this branch and the 5-line help insertion moves it further. Modifying that file is excluded by AC-12. Recommended follow-up issue.

### Approved Exceptions

- DEV-1 base remap: the plan literal base `0658f694` was replaced by its rebased counterpart `92d78897`; equivalence commands are recorded in `evidence/baseline/base-sha.2026-09-27T01-08.md`. Informational (I-1).
- AC-23 deferred to the PR CI gate because no pull request exists; the same workflow succeeded on dispatch run 36287146354. Informational (I-2).

### Informational

- I-1: DEV-1 base remap as above; no code-path impact.
- I-2: AC-23 deferred, not a defect.
- I-3: `scripts/bash/cleanup_worktrees_lib.sh:7` file header still summarizes `compute_protected` as "the current-worktree/branch protection set" without the base branch; the functional docstring at `:319-320` was updated as the spec required.
- I-4: The `cleanup_worktrees_actions_lib.sh` file header names the "base-branch refusal" but not the `BLOCKED-PROTECTED-BASE` token; the `delete_candidate` docstring, help text, and SKILL.md do name it.
- I-5: The working tree holds two uncommitted plan check marks and the untracked `evidence/other/commit-final.2026-09-27T02-23.md`; these must be committed by the orchestrator before the PR.
- I-6: Several executor evidence timestamps are approximate (for example, `ci-shell-coverage.2026-09-27T02-00.md` describes a run that completed at 02:08:06Z, and `commit-final` is stamped 02-23, later than this review). Evidence content was re-verified independently where it bears on a verdict.
- I-7: `spec.md` still reads "Status: Draft" and "operator review not obtained" for D1-D7; operator approval of D1-D7 was supplied on 2026-09-26 through the orchestrator prompt. The reviewer does not edit spec text beyond AC checkboxes.

### Removed/Skipped Tests

None.

---

## 9. Summary of Changes

### Commits in This PR/Branch

`b3ee52a0`, `99e7c92b`, `92d78897`, `5a5c6fbc`, `d3738706`, `b5f98be2`, `3e12620b` (docs/plan/baseline); `8ad50ace` (tests, fail-before); `769afaa1` (compute_protected); `763b3865` (delete_candidate); `fd4d2656` (comments, help, skill); `7e54e0e1`, `f52742ce`, `e29ad95d`, `c00d9587` (evidence).

### Files Modified

- 5 bash production files, 3 bats suites, 8 new fixture files, 2 SKILL.md copies, feature-folder documents and evidence (77 paths total in `git diff --name-only b6745383 HEAD`).

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

### Policy-by-Policy Summary

| Policy | Verdict |
|---|---|
| General code change | PASS |
| General unit test | PASS |
| Shell rules | PASS |
| Quality tiers (uniform coverage) | PASS |
| Evidence location | PASS |
| Tonality | PASS |

### Metrics Summary

- Bash coverage: PASS (93.3% repo-wide; every modified file >= 85%; no regression; 100% of instrumented added lines).
- Other languages: N/A (zero changed files).
- Total blocking findings: 0.

### Recommendation

Proceed to PR authoring. Confirm AC-23 at the PR CI gate and file follow-ups for NB-1 and NB-2.

---

## Appendix A: Test Inventory

### Complete Test List (new tests)

| ID | File | Test name |
|---|---|---|
| T1 | `tests/shell/test_cleanup_worktrees_enumeration.bats` | compute_protected emits protected-branch main when the primary worktree is on another branch |
| T2 | `tests/shell/test_cleanup_worktrees_enumeration.bats` | compute_protected emits protected-branch main under current_exclusion |
| T3 | `tests/shell/test_cleanup_worktrees_enumeration.bats` | compute_protected emits exactly one protected-branch main when the current branch is main |
| T4 | `tests/shell/test_cleanup_worktrees_classification.bats` | classify_branch main is PROTECTED_CURRENT when the primary worktree is on another branch |
| T5 | `tests/shell/test_cleanup_worktrees_classification.bats` | classify_branch main is PROTECTED_CURRENT when main is checked out in a linked worktree |
| T6 | `tests/shell/test_cleanup_worktrees_deletion.bats` | run_report classifies main PROTECTED_CURRENT when the primary worktree is on another branch |
| T7 | `tests/shell/test_cleanup_worktrees_deletion.bats` | run_apply does not delete main when the primary worktree is on another branch |
| T8 | `tests/shell/test_cleanup_worktrees_deletion.bats` | run_apply neither removes nor deletes main checked out in a linked worktree |
| T9 | `tests/shell/test_cleanup_worktrees_deletion.bats` | delete_candidate refuses the base branch before re-verification |
| T10 | `tests/shell/test_cleanup_worktrees_deletion.bats` | delete_candidate refuses the base branch before removing its linked worktree |

---

## Appendix B: Toolchain Commands Reference

- Format and lint: `bash scripts/bash/shell-qc.sh check`
- Tests: `bash scripts/bash/shell-qc.sh test`; subset: `npx --yes bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats`
- Coverage (CI authoritative): `.github/workflows/_shell-coverage.yml`; `gh run view 36287146354`; `gh run download 36287146354 --name shell-coverage`
- Reviewer checks: `git diff --name-only b6745383 HEAD`; `git diff --exit-code b6745383 HEAD -- tests/fixtures/cleanup_worktrees/expected/ tests/fixtures/cleanup_worktrees/stub-bin/ scripts/bash/cleanup_worktrees_detached_lib.sh scripts/bash/cleanup_worktrees_dirt_lib.sh .github/`; `git diff --name-only e29ad95d HEAD`; `git diff --no-index --exit-code <SKILL.md copies>`; `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
