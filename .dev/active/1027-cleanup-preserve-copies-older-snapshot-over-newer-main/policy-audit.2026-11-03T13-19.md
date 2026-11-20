# Policy Compliance Audit: cleanup-merged-worktrees preserve staging decision (Issue #1027)

**Audit Date:** 2026-11-03
**Branch:** `bug/cleanup-preserve-older-snapshot-1027-r2` at `ca69ec5c5b030e76494ccdcbeaffa2f3cd74175e`
**Base:** `main` (resolved `origin/main` at `715241396b557ce198e44f5c4b606fbcd9082c3c`); merge base `715241396b557ce198e44f5c4b606fbcd9082c3c`
**Scope:** full branch diff against the merge base (215 paths), per `artifacts/pr_context.summary.txt` generated 2026-11-03 13:16:19 UTC for head `ca69ec5c5`.

**Code Under Test:**

- Production (bash): `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_merge_lib.sh` (new), `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh` (modified), `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh` (modified)
- Documentation: `.claude/skills/cleanup-merged-worktrees/SKILL.md` (modified)
- Bundle mirrors: the four files above under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/`, plus `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (one entry added)
- Tests (bats): `tests/shell/test_cleanup_worktrees_preserve_merge.bats` (new), `tests/shell/test_cleanup_worktrees_preserve_merge_fallback.bats` (new), `tests/shell/test_cleanup_worktrees_preserve.bats`, `tests/shell/test_cleanup_worktrees_preserve_eol.bats`, `tests/shell/test_cleanup_worktrees_preserve_failures.bats` (modified)
- Test infrastructure: `tests/fixtures/cleanup_worktrees/stub-bin/git` (modified), 16 new fixture scenario directories under `tests/fixtures/cleanup_worktrees/preserve/`, and `tests/fixtures/cleanup_worktrees/preserve/modified/{jq.out,manifest.json}` (evidence-text change)
- Feature documentation and evidence under `docs/features/active/2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main-1027/`, and the promoted lifecycle record `docs/features/potential/promoted/2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main.md`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Bash | 3 production scripts (+3 mirrors), 5 bats suites, 1 stub | 761 bats tests (CI full suite) | PASS: 761 pass, 0 fail | 95.2% lines (3272/3437) | 95.3% lines (3377/3543) | 99.0% lines (`cleanup_worktrees_preserve_merge_lib.sh`) |
| JSON | 1 pack manifest, 16 fixture manifests | N/A | PASS: parse and contract tests | N/A (config files) | N/A (config files) | N/A |
| Python | 0 files | 66 contract tests run unchanged | PASS: 66 pass, 0 fail | N/A - no changed Python files | N/A - no changed Python files | N/A |
| TypeScript | 0 files | N/A | N/A | N/A - no changed files | N/A - no changed files | N/A |
| PowerShell | 0 files | N/A | N/A | N/A - no changed files | N/A - no changed files | N/A |
| C# | 0 files | N/A | N/A | N/A - no changed files | N/A - no changed files | N/A |

### Coverage Evidence Checklist

- Bash baseline coverage artifact: `evidence/baseline/shell-coverage.2026-11-03T12-30.md` (CI run 41634792230, head `0fa5e2f89`, before any production change)
- Bash post-change coverage artifact: `evidence/qa-gates/shell-coverage.2026-11-03T13-12.md` (CI run 41640864723, head `456b9da17`)
- Bash comparison: `evidence/qa-gates/coverage-delta.2026-11-03T13-12.md`
- TypeScript baseline coverage artifact: N/A - out of scope (no changed TypeScript files)
- TypeScript post-change coverage artifact: N/A - out of scope (no changed TypeScript files)
- PowerShell baseline coverage artifact: N/A - out of scope (no changed PowerShell files)
- PowerShell post-change coverage artifact: N/A - out of scope (no changed PowerShell files)
- Python coverage artifacts: N/A - out of scope (no changed Python files)
- Per-language comparison summary: Section 1.2.1

Reviewer verification of the post-change figures: the reviewer downloaded the `shell-coverage` artifact of CI run 41640864723 (`gh run download 41640864723 -n shell-coverage`) into the session scratchpad and read `cov.xml` directly. The aggregate `line-rate="0.953" lines-covered="3377" lines-valid="3543"` and the per-file rates `cleanup_worktrees_preserve_merge_lib.sh` 0.990, `cleanup_worktrees_preserve_lib.sh` 0.908, and `cleanup-worktrees.sh` 0.977 match the executor's evidence. `git diff --name-only 456b9da17 HEAD` lists only feature-folder documentation and evidence, so the code measured by run 41640864723 is identical to the code at the review head.

Changed-line coverage: the reviewer intersected the zero-hit lines in `cov.xml` with the new-side hunk ranges of `git diff -U0` for each modified script. `cleanup_worktrees_preserve_lib.sh` zero-hit lines (112-124, 453, 479-485) fall outside every changed hunk (15, 178, 239-402). `cleanup-worktrees.sh` zero-hit line 205 falls outside the changed hunks (33-90). The only zero-hit line of the new library is line 38, the `done < <(printf ...)` terminator of the line-split loop, which kcov does not attribute as executed. No changed executable line is unexecuted.

Branch coverage: kcov does not measure branch coverage for bash, so no branch threshold applies (`.claude/rules/general-unit-test.md`, Coverage Requirements). The `branch-rate="1.0"` value in `cov.xml` is a kcov placeholder and is not used as evidence.

Threshold source: the root `CLAUDE.md` states no coverage threshold, so the defaults govern: line coverage of at least 85% for new files, modified files, and repo-wide per language.

---

## Rejected Scope Narrowing

None detected. The caller prompt named the base branch, merge base, head, feature folder, PR-context artifacts, and AC source, and did not narrow the audit to a plan, task, phase, or file subset, or exempt any language from coverage. The audit covers the full branch diff.

## Evidence Location Compliance

- `git diff --name-only 715241396...HEAD` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <item worktree>` exited 0 with no reported path.
- All executor evidence lives under `docs/features/active/2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main-1027/evidence/{baseline,qa-gates,regression-testing,other}/`.
- Result: PASS. No evidence-location override was required in this review.

---

## Executive Summary

The branch fixes issue #1027: `cleanup-worktrees.sh --preserve` copied an older worktree snapshot whole over a newer target on the consolidation branch, which silently dropped lines `main` had added. The fix adds a staging decision library (`cleanup_worktrees_preserve_merge_lib.sh`) that, for a target that already exists as a regular file, applies a line-subsequence guard (guard (b)) or a bounded three-way `git merge-file --union --object-id` merge (guards G1, G2, G3), and refuses the record with `ACTION|preserve-stage|<tgt>|REFUSED-WOULD-REGRESS` when no lossless outcome exists. The plan stream gains columns 9 and 10, and the writing phase stages a merged blob through `cat-file blob` when column 9 is `merge`.

**Policy documents evaluated:**

- PASS `CLAUDE.md` (tone, policy order, architecture)
- PASS `.claude/rules/general-code-change.md` (design, file size, error handling, I/O boundaries)
- PASS `.claude/rules/general-unit-test.md` (core principles, coverage, no temporary files, test location)
- PASS `.claude/rules/quality-tiers.md` (uniform coverage thresholds; tier classification not applicable, see below)
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**

- PASS Bash: shfmt, shellcheck, bats with kcov (`.claude/rules/shell.md` as listed in the executor's phase-0 read; `scripts/bash/shell-qc.sh`)
- PASS JSON: strict JSON in `core.json` and the fixture manifests
- N/A Python, PowerShell, TypeScript, C#: no changed files in these languages

Tier classification: PASS. `quality-tiers.yml` exists at the repository root on the base branch (`git cat-file -e 715241396:quality-tiers.yml` succeeds) and `.github/workflows/_quality-checks.yml` runs a `tier-classification` step, so the repository has adopted tiers. The branch does not modify `quality-tiers.yml` and adds no path that the discovery rules R1-R5 in `scripts/dev_tools/quality_tiers_contract.py` treat as a new project (no `package.json`, `pyproject.toml`, `*.csproj`, `*.psd1`/`*.psm1` pair, `scripts/<name>` code folder, `.claude/lib/<name>` folder, or hooks folder). The changed skill scripts fall under the root `.` entry (T4), and the bundle mirrors fall under `extensions/drm-copilot` (T3). The tier-dependent gates for T3 and T4 (no property-test density, mutation, or golden-test obligation; escape-hatch limits do not apply to bash) impose no additional requirement on this change. The checker itself could not be run locally because the item worktree's Poetry environment lacks the `yaml` module; the conclusion rests on the discovery rules and the unchanged manifest.

Toolchain results: `scripts/bash/shell-qc.sh format` rewrote no file; `scripts/bash/shell-qc.sh check` (shfmt diff and shellcheck) produced no output locally and in CI; the CI coverage job ran 761 bats tests with 0 failures and reported `Bash coverage (lines): 95.3%`; the Python contract tests reported 66 passed, 0 failed.

**Temporary artifacts cleanup:**

- PASS Launcher scripts (`issue-1027-shell-qc.sh`, `issue-1027-bats.sh`, `issue-1027-contracts.sh`) lived under the executor's session scratch directory outside the repository; none appears in the branch diff.
- PASS No new ongoing tooling script was added outside the tested skill scripts.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | `evidence/regression-testing/bats-order-isolation.2026-11-03T13-03.md`: the five preserve suites pass forward and reversed (71 of 71 each). The two read-failure tests redefine `cleanup_wt_git` inside their own bats test process, which bats isolates per test. |
| **Isolation** - Each test targets single behavior | PASS | Pure-helper tests (`is_subsequence`, `extra_within`) are separate from scenario tests; each scenario test drives one verdict-table row or one base-unavailable cause. |
| **Fast Execution** - Tests complete quickly | PASS | Stubbed git and jq; no repository or network access. The CI full shell suite duration is reported as unchanged from baseline in the self-review. |
| **Determinism** - Consistent results | PASS | Every git call goes through the recording stub `tests/fixtures/cleanup_worktrees/stub-bin/git` with canned per-key answers; no clock, randomness, or real git history. |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive `@test` names; shared assertion helpers `merge_assert_refused`, `merge_assert_merge_entry`, `fallback_assert_ok_and_bad`; file headers state scope and fixture rationale. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline:** 95.2% lines (3272/3437). **Command:** `gh workflow run _shell-coverage.yml --ref bug/cleanup-preserve-older-snapshot-1027-r2` (job runs `bash scripts/bash/shell-qc.sh test --coverage`). **Timestamp:** 2026-11-03 12:30 UTC, head `0fa5e2f89`, before the first production commit `83bcb28a1`. |
| **No Coverage Regression** | PASS | Aggregate 95.2% to 95.3% (+0.1 points). `cleanup_worktrees_preserve_lib.sh` 90.6% to 90.8%; `cleanup-worktrees.sh` 97.6% to 97.7%. No changed executable line is unexecuted (see the changed-line check above). |
| **New Code Coverage** | PASS | `cleanup_worktrees_preserve_merge_lib.sh` 0.990 line rate from `cov.xml` (threshold 85%). The single zero-hit line is the loop terminator at line 38. |
| **Comprehensive Coverage** | PASS | Every function in the new library is driven: `preserve_merge_split_lines` and `preserve_merge_is_subsequence` (5 helper tests plus every scenario), `preserve_merge_extra_within` (2 helper tests plus G3 scenario), `preserve_merge_refuse` (all refusals), `preserve_merge_check_duplicate` (duplicate scenario), `preserve_merge_resolve_base` (four fallback causes and all base-available scenarios), `preserve_merge_guard_b` (five fallback tests), `preserve_merge_decide` (all scenarios). |
| **Positive Flows** - Valid inputs | PASS | `a clean merge plans the merged blob in merge mode`; `both sides appending at end of file is merged with OK`; `an addition already on main merges to main content`; `an absent target is copied with no decision git call`; the `notes/ok.md` copy in each fallback test; `a merge-mode plan entry writes the merged blob through cat-file`. |
| **Negative Flows** - Invalid inputs | PASS | G1 (`merge-g1`), merge-file error rc 129 (`merge-error`), G2 (`merge-g2`), G3 (`merge-g3`), guard (b) refusals (`notes/bad.md` in five scenarios), duplicate target (`merge-duplicate`). |
| **Edge Cases** - Boundary conditions | PASS | Empty needle and empty haystack; reordered lines; repeated needle lines; CRLF with one carriage return stripped and a doubled carriage return kept; unterminated final line; blank lines in multiset counts; duplicate-count limits in G3. |
| **Error Handling** - Error paths | PASS | `an unreadable base blob is refused by G1`; `an unreadable merged blob is refused by G2`; `a merge-file error is refused and names the git exit code`; `a failed merged blob read is reported as FAILED` (writing phase). |
| **Concurrency** - If applicable | N/A | Single-process CLI pass; no shared state across processes. |
| **State Transitions** - If applicable | PASS | `PRESERVE_SEEN_TARGETS` is reset per pass in `preserve_plan` and accumulates across records; `a duplicate target_path in one pass is refused after the first` drives the transition. |

### 1.2.1 Per-Language Coverage Comparison

- Bash: Baseline: 95.2% lines -> Post-change: 95.3% lines. Change: +0.1% lines. New/changed-code coverage: 99.0%. Disposition: PASS. Evidence: `evidence/baseline/shell-coverage.2026-11-03T12-30.md`, `evidence/qa-gates/shell-coverage.2026-11-03T13-12.md`, `evidence/qa-gates/coverage-delta.2026-11-03T13-12.md`, reviewer read of `cov.xml` from CI run 41640864723.
- Python: Baseline: N/A - out of scope. Post-change: N/A - out of scope. New/changed-code coverage: N/A - out of scope. Disposition: N/A (zero changed Python files). Evidence: `git diff --name-status 715241396...HEAD`.
- TypeScript: N/A - out of scope (zero changed files). New/changed-code coverage: N/A - out of scope. Disposition: N/A.
- PowerShell: N/A - out of scope (zero changed files). New/changed-code coverage: N/A - out of scope. Disposition: N/A.
- C#: N/A - out of scope (zero changed files). New/changed-code coverage: N/A - out of scope. Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `merge_assert_merge_entry` echoes `plan entry columns: N, mode: '...'`, which the fail-before run printed as `plan entry columns: 8, mode: ''` (`evidence/regression-testing/fail-before-repro.2026-11-03T12-35.md`). |
| **Arrange-Act-Assert Pattern** | PASS | Seams are exported (arrange), `run merge_drive_plan` or `run preserve_commit_merge_one` acts, assertions follow. |
| **Document Intent** | PASS | Section comments in each suite; each `@test` name states the scenario and the expected outcome. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No real git, jq, network, or repository; `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_JQ_BIN` point at stubs. |
| **Use Mocks/Stubs** | PASS | Recording git stub with four new key forms (`merge-base-of`, `cat-file`, `merge-file`, `hash-object-w`); jq stub; in-process `cleanup_wt_git` redefinition for two read-failure tests. |
| **Environment Stability** | PASS | No temporary files; writing-phase tests write to `/dev/null`; merge scenarios drive only the read-only planning phase, so no checked-in fixture is written. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit, the companion code review, and the feature audit with the same timestamp. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` (#1027) and `spec.md` `## Root Cause Analysis`. |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.2026-11-03T12-09.md`; research document under `research/`. |
| **Document the plan** | PASS | `plan.2026-10-30T20-58.md`; one conventional commit per phase. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | One decision function with three pure guard helpers; no new CLI flag or stdout record type. |
| **Reusability** | PASS | `preserve_merge_is_subsequence` serves G1, G2, and guard (b); `preserve_merge_refuse` centralizes the refusal contract. |
| **Extensibility** | PASS | Plan entry columns 9 and 10 are appended; an empty column 9 means `copy`, so eight-column entries still work (driven by `preserve_commit_one` in the failures suite). |
| **Separation of concerns** | PASS | Policy lives in the merge library; `preserve_commit_plan` executes the recorded mode and takes no staging decision. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | The new library holds only the staging decision. |
| **At or below the 800-line hard limit** | PASS | Logical line counts at head (`awk 'END{print NR}'`, equivalent to `@(Get-Content).Count` for LF files): merge lib 234, preserve lib 500, wrapper 256 (mirrors identical), `test_cleanup_worktrees_preserve.bats` 478, `_eol.bats` 177, `_failures.bats` 311, `_merge.bats` 291, `_merge_fallback.bats` 137, stub `git` 451. No covered file is at or above 700 lines; `config/file-size-baseline.json` is unchanged. |
| **Public vs internal** | PASS | CLI flags unchanged; new functions are internal to the skill's sourced libraries. |
| **No circular dependencies** | PASS | The merge library depends only on `cleanup_wt_git`; the preserve library calls the merge library, not the reverse. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `preserve_merge_*` prefix; reason tokens `G1`, `G2`, `G3`, `guard-b`, `merge-file rc=`, `duplicate-target`. |
| **Docs/docstrings** | PASS | Every new function has a header comment stating arguments and return values. |
| **Comment why, not what** | PASS | Comments explain the carriage-return variable, the associative-array key prefix, and each scoped SC2034 suppression. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `scripts/bash/shell-qc.sh format`. **Result:** no file rewritten (`evidence/qa-gates/shell-format.2026-11-03T13-02.md`). |
| **2. Linting** | PASS | **Command:** `scripts/bash/shell-qc.sh check`. **Result:** no output, exit 0 locally (`evidence/qa-gates/shell-qc-check.2026-11-03T13-02.md`) and in CI run 41640864723. |
| **3. Type checking** | N/A | Bash has no type-check stage. |
| **4. Testing** | PASS | **Command:** `bash scripts/bash/shell-qc.sh test --coverage` in CI. **Result:** `1..761`, 0 `not ok`. |
| **Full toolchain loop** | PASS | Two loop passes; pass 2 ran clean in a single pass after the self-review added two read-failure tests (commit `456b9da17`). |
| **Explicit reporting** | PASS | One evidence artifact per QC step under `evidence/qa-gates/` and `evidence/regression-testing/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Conventional commit messages per phase (Section 9). |
| **Design choices explained** | PASS | `spec.md` verdict table and guard definitions; merge library header. |
| **Update supporting documents** | PASS | `SKILL.md` `### Preserve staging outcomes`; wrapper `usage`; `preserve_plan`, `preserve_plan_one`, `preserve_validate_record`, and `preserve_commit_plan` comments. |
| **Provide next steps** | PASS | PR creation and the PR-head `ci.yml` gate remain for the orchestrator (S9). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | PASS | **Command:** `bash scripts/bash/shell-qc.sh format`. **Result:** no change. |
| **Linting with shellcheck** | PASS | **Command:** `bash scripts/bash/shell-qc.sh check`. **Result:** clean; three SC2034 suppressions, each line- or function-scoped with a stated cross-file reason. |
| **Testing with bats** | PASS | **Command:** `bash scripts/bash/shell-qc.sh test --coverage`. **Result:** 761 pass, 0 fail (CI run 41640864723). |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | PASS | `#!/usr/bin/env bash` in the new library. |
| **Error handling** | PASS | Wrapper keeps `set -euo pipefail`; each guard failure refuses fail-closed with a reason-tagged stderr line. One non-blocking edge case (an unreadable target read yields empty content) is recorded in the code review as a Minor finding. |
| **At or below the 800-line hard limit** | PASS | See Section 2.3. |

### Section 3D: JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | PASS | `core.json` diff adds one quoted string entry in sorted position; fixture manifests parse through the jq stub's recorded projections and the contract tests. |
| **Deterministic key order** | PASS | `core.json` entry placed immediately after `cleanup_worktrees_preserve_lib.sh`, preserving the sorted list. |
| **Schema validation** | N/A | No governed JSON with a `$schema` property changed. |

---

## 4. Language-Specific Unit Test Policy Compliance

Bash unit tests are covered in Sections 1 and 3C. No Python, PowerShell, TypeScript, or C# test file changed. Test files live under `tests/shell/`, following the repository's existing bats layout; no test file is colocated with production source.

---

## 5. Test Coverage Detail

### `cleanup_worktrees_preserve_merge_lib.sh` (26 new tests across two suites, plus 2 writing-phase tests)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| merge library defines functions only and runs no work at source time | Positive (contract) | PASS |
| is_subsequence accepts an ordered subset and rejects a missing or reordered line | Positive / Negative | PASS |
| is_subsequence handles empty inputs | Edge Case | PASS |
| is_subsequence strips one trailing carriage return per line | Edge Case | PASS |
| is_subsequence counts an unterminated final line | Edge Case | PASS |
| extra_within accepts worktree additions and an empty difference | Positive | PASS |
| extra_within rejects a resurrected base line and counts duplicates | Negative | PASS |
| an older modified snapshot never overwrites newer main lines | Positive (issue repro) | PASS |
| a clean merge plans the merged blob in merge mode | Positive | PASS |
| both sides appending at end of file is merged with OK | Positive / Edge Case | PASS |
| an addition already on main merges to main content | Edge Case | PASS |
| a worktree that deleted a base line is refused by G1 | Negative | PASS |
| a merge-file error is refused and names the git exit code | Error Handling | PASS |
| a merged result missing a main line is refused by G2 | Negative | PASS |
| a resurrected base line is refused by G3 | Negative | PASS |
| an absent target is copied with no decision git call | Positive (unchanged path) | PASS |
| --help documents REFUSED-WOULD-REGRESS | Positive (docs) | PASS |
| an unreadable base blob is refused by G1 | Error Handling | PASS |
| an unreadable merged blob is refused by G2 | Error Handling | PASS |
| the git stub replays the merge key forms | Test infrastructure | PASS |
| no worktree HEAD falls back to guard-b | Negative / Fallback | PASS |
| no merge base falls back to guard-b | Negative / Fallback | PASS |
| a file absent at the merge base falls back to guard-b | Negative / Fallback | PASS |
| a renamed target falls back to guard-b without resolving a base | Negative / Fallback | PASS |
| an untracked record with an existing target is guarded by guard-b | Positive / Negative | PASS |
| a duplicate target_path in one pass is refused after the first | Negative / State | PASS |
| a merge-mode plan entry writes the merged blob through cat-file | Positive (phase 2) | PASS |
| a failed merged blob read is reported as FAILED | Error Handling (phase 2) | PASS |

**Coverage:** 99.0% of the new library (one zero-hit line: line 38, the loop terminator).

**Not covered:** line 38 only, which kcov does not attribute; the loop body on line 37 is executed.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 761 (CI shell suite; baseline 733) | PASS |
| Tests Passed | 761 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Preserve-area subset | 116 of 116 (`evidence/regression-testing/pass-after-repro.2026-11-03T12-41.md`) | PASS |
| Functions Tested | 8 of 8 new functions | PASS |
| Largest Test File Size | 478 logical lines | PASS |
| Code Coverage | 95.3% lines aggregate; branch not measured for bash | PASS |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| shfmt | `scripts/bash/shell-qc.sh format` | No file rewritten | PASS |
| shfmt diff + shellcheck | `scripts/bash/shell-qc.sh check` | No output, exit 0 (local and CI) | PASS |
| bats + kcov | `scripts/bash/shell-qc.sh test --coverage` | 761 pass, 95.3% lines | PASS |
| Python contract tests | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` | 66 passed, 0 failed | PASS |
| Bundle mirror parity | `cmp` of the four source/mirror pairs (reviewer re-run) | All four identical | PASS |

**Notes:** the local WSL coverage route could not write `cov.xml` under the `/mnt/c` mount at baseline, so the executor used the CI dispatch route for both coverage measurements, as the plan authorizes. The PR-head `ci.yml` run has not occurred because no PR exists yet; that run is the orchestrator's S9 gate.

---

## 8. Gaps and Exceptions

### Identified Gaps

**None.** All policy requirements are met. Non-blocking observations are recorded in `code-review.2026-11-03T13-19.md`.

### Approved Exceptions

- Coverage route: coverage was measured by CI dispatch (`_shell-coverage.yml`) rather than locally, because the local kcov route produced no `cov.xml` under the WSL `/mnt/c` mount. The CI run measured code identical to the review head.

### Removed/Skipped Tests

**None.** All planned tests implemented.

---

## 9. Summary of Changes

### Commits in This Branch

1. `1ff1cd647` docs(features): open active feature folder for issue 1027
2. `932268e66` docs(features): add issue 1027 research and bug spec
3. `23dc78c58` docs(features): add issue 1027 atomic plan
4. `bf0023d1b` docs(features): record issue 1027 preflight fixes
5. `9038165f4` Merge origin/main before orchestration
6. `c5bc076b3` docs(features): record the promoted entry and feature folder for issue 1027
7. `2f50b3d37` docs(features): record the single-pass preflight for issue 1027
8. `0fa5e2f89` docs(features): record the phase 0 baseline for issue 1027
9. `915243340` docs(features): record the baseline shell coverage for issue 1027
10. `efe3be650` test(cleanup-worktrees): add merge stub keys and preserve merge fixtures
11. `83bcb28a1` feat(cleanup-worktrees): add the preserve merge decision library
12. `990f5bf8e` test(cleanup-worktrees): add the issue 1027 repro and fail-before evidence
13. `fd3276f7a` fix(cleanup-worktrees): stop preserve from overwriting newer main lines
14. `dc1e9dc97` docs(cleanup-merged-worktrees): document preserve staging outcomes
15. `ba5ae650d` chore(extension): mirror the preserve merge fix into the bundle
16. `16a1a6e77` docs(features): record the shell format and lint gates for issue 1027
17. `456b9da17` test(cleanup-worktrees): drive the merge decision's blob read failures
18. `ca69ec5c5` docs(features): record the final QA loop and self-review for issue 1027

### Files Modified

1. `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_merge_lib.sh` (NEW): staging decision, guards, base resolver, refusal helper.
2. `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh` (MODIFIED): calls the duplicate check and decision; ten-column plan entry; merge-mode write in phase 2; header comments state the phase-1 blob-write exception.
3. `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh` (MODIFIED): sources the merge library; `usage` text describes per-class staging and `REFUSED-WOULD-REGRESS`.
4. `.claude/skills/cleanup-merged-worktrees/SKILL.md` (MODIFIED): `### Preserve staging outcomes` subsection.
5. Bundle mirrors and `pack-manifests/core.json` (MODIFIED/NEW): byte-identical copies; one manifest entry.
6. Tests, stub, and fixtures (NEW/MODIFIED): as listed under Code Under Test.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All evaluated policies pass on inspected evidence. Bash, the only coverage language with changed files, has numeric baseline (95.2%) and post-change (95.3%) coverage, new-code coverage of 99.0%, and no unexecuted changed line. No file-size, evidence-location, or coverage-exclusion violation exists.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: plan, research, and phase-0 read recorded.
- PASS Design Principles: decision isolated; phase 2 policy-free.
- PASS Module & File Structure: largest file 500 lines; no file at or above 700.
- PASS Naming, Docs, Comments: function headers and rationale comments present.
- PASS Toolchain Execution: format, lint, and tests clean in a single pass.
- PASS Summarize & Document: SKILL.md, usage, and header comments updated.

#### Language-Specific Code Change Policy (Section 3)
- PASS Bash: shfmt, shellcheck, bats clean.
- PASS JSON: strict JSON, sorted manifest entry.

#### General Unit Test Policy (Section 1)
- PASS Core Principles: order isolation verified in both directions.
- PASS Coverage & Scenarios: every verdict-table row and base-unavailable cause driven.
- PASS Test Structure: Arrange-Act-Assert with diagnostic output.
- PASS External Dependencies: stubs only, no temporary files.
- PASS Policy Audit: this document.

### Metrics Summary

- PASS 761 of 761 bats tests passing (100%).
- PASS 8 of 8 new functions driven by tests.
- PASS 95.3% aggregate bash line coverage; 99.0% on the new library.
- PASS Test files under `tests/shell/`, fixtures under `tests/fixtures/cleanup_worktrees/`.
- PASS All code quality checks passing.

### Recommendation

**Ready for merge** after the normal PR flow, subject to the PR-head `ci.yml` run (orchestrator S9 gate).

---

## Appendix A: Test Inventory

### Complete Test List (new and changed tests on this branch)

- `tests/shell/test_cleanup_worktrees_preserve_merge.bats` (19 tests): the 19 tests listed in Section 5 from "merge library defines functions only and runs no work at source time" through "an unreadable merged blob is refused by G2".
- `tests/shell/test_cleanup_worktrees_preserve_merge_fallback.bats` (7 tests): "the git stub replays the merge key forms", "no worktree HEAD falls back to guard-b", "no merge base falls back to guard-b", "a file absent at the merge base falls back to guard-b", "a renamed target falls back to guard-b without resolving a base", "an untracked record with an existing target is guarded by guard-b", "a duplicate target_path in one pass is refused after the first".
- `tests/shell/test_cleanup_worktrees_preserve_failures.bats` (2 added tests): "a merge-mode plan entry writes the merged blob through cat-file", "a failed merged blob read is reported as FAILED".
- `tests/shell/test_cleanup_worktrees_preserve.bats` (modified): source-guard test gains case three for the wrapper's six-library chain; setup and inline chains source the merge library; the `modified` test comment describes the absent-target copy.
- `tests/shell/test_cleanup_worktrees_preserve_eol.bats` (modified): setup and inline chain source the merge library.

---

## Appendix B: Toolchain Commands Reference

```bash
# Formatting and lint (shfmt diff + shellcheck)
bash scripts/bash/shell-qc.sh format
bash scripts/bash/shell-qc.sh check

# Tests with coverage (bats + kcov), run in CI by dispatch
gh workflow run _shell-coverage.yml --ref bug/cleanup-preserve-older-snapshot-1027-r2
gh run download 41640864723 -n shell-coverage

# Local preserve-area bats run
npx --yes bats tests/shell/test_cleanup_worktrees_preserve_merge.bats tests/shell/test_cleanup_worktrees_preserve_merge_fallback.bats

# Python contract tests for bundle parity and the pack manifest
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py

# Evidence-location scan (reviewer)
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-03
**Policy Version:** Current (as of audit date)
