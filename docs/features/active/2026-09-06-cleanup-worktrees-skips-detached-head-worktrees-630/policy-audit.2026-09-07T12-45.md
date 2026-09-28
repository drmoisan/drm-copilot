# Policy Compliance Audit: detached-worktree classification and consolidation-branch ordering (Issue #630)

**Audit Date:** 2026-09-07
**Code Under Test:**

| Status | Path |
|---|---|
| A | `scripts/bash/cleanup_worktrees_detached_lib.sh` |
| M | `scripts/bash/cleanup-worktrees.sh` |
| M | `scripts/bash/cleanup_worktrees_actions_lib.sh` |
| M | `scripts/bash/cleanup_worktrees_lib.sh` |
| A | `tests/shell/test_cleanup_worktrees_detached.bats` |
| M | `tests/shell/test_cleanup_worktrees_classification.bats` |
| M | `tests/shell/test_cleanup_worktrees_cli.bats` |
| M | `tests/shell/test_cleanup_worktrees_deletion.bats` |
| M | `tests/shell/test_cleanup_worktrees_hard_failures.bats` |
| A/M | 54 test fixture data files under `tests/fixtures/cleanup_worktrees/` |
| A/M | 31 Markdown documents (`.claude/skills/cleanup-merged-worktrees/SKILL.md`, its push-down mirror, feature-folder docs and evidence) |

Full branch diff: **94 files changed, 2910 insertions(+), 106 deletions(-)**.

**Base branch:** `epic/cleanup-merged-worktrees-hardening-integration`
**Merge base:** `a36b6dca7809e456f00c7d5b01eec5da49f7fca0`
**Head:** `65a56cb94352c2a19c381acf4008837fa84aee69` (branch `bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`)
**Work mode:** `full-bug` (marker at `issue.md:12`); AC source is `spec.md` only.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Bash | 4 production `.sh` (1 new, 3 modified) + 5 `.bats` (1 new, 4 modified) | 308 bats cases | ✅ 308 pass, 0 fail | 93.6% lines (kcov) | 92.9% lines (kcov) | 80.6% lines (`cleanup_worktrees_detached_lib.sh`) |
| TypeScript | 0 files | 0 tests | N/A | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |
| Python | 0 files | 0 tests | N/A | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |
| PowerShell | 0 files | 0 tests | N/A | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |
| C# | 0 files | 0 tests | N/A | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |

No Python, TypeScript, PowerShell, or C# source file is in the branch diff. Extension inventory of
the 94 changed paths: 44 `.out`, 31 `.md`, 10 `.rc`, 5 `.bats`, 4 `.sh`. The `.out`/`.rc` files are
checked-in git-stub fixture data, not executable source.

### Coverage Evidence Checklist

- Bash baseline coverage artifact: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence/baseline/bash-test-coverage.2026-09-07T14-30.md` (CI run 34113725852)
- Bash post-change coverage artifact: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence/qa-gates/final-bash-test-coverage.2026-09-07T14-45.md` (CI run 34118811332)
- TypeScript baseline coverage artifact: N/A - out of scope
- TypeScript post-change coverage artifact: N/A - out of scope
- PowerShell baseline coverage artifact: N/A - out of scope
- PowerShell post-change coverage artifact: N/A - out of scope
- Python baseline coverage artifact: N/A - out of scope
- Python post-change coverage artifact: N/A - out of scope
- C# baseline coverage artifact: N/A - out of scope
- C# post-change coverage artifact: N/A - out of scope
- Per-language comparison summary: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence/qa-gates/coverage-delta.2026-09-07T14-45.md` and section 1.2.1 of this audit

`N/A - out of scope` above means zero changed files for that language in the branch diff, which is
the only condition under which a coverage verdict may be non-explicit. Bash is the sole language with
changed files, and its verdict is an explicit FAIL recorded in section 1.2.1 and section 10.

---

## Rejected Scope Narrowing

The caller prompt did not attempt to narrow the audit scope to a plan, task, phase, or file subset,
and did not mark any language's coverage as out of scope. No narrowing was detected and none was
rejected. The audit was performed against the full branch diff `a36b6dca..65a56cb9`.

Two caller-supplied environmental statements were treated as inputs to verify rather than as
findings to accept, and both were independently re-derived by this reviewer:

1. Caller text: *"the worktree-isolation guard refuses any command whose text contains `wsl`, `pwsh`,
   or `bash`, and neither `bats` nor `kcov` is installed on the Windows PATH."* Partially
   re-derived. `npx --yes bats` runs locally in this worktree and was used by this reviewer to
   re-execute the full `tests/shell/` suite; `kcov` has no local route, so coverage figures were
   read from the CI artifacts rather than regenerated, which is the required verification model.
2. Caller text: *"bash line coverage moved from 93.6% (baseline) to 92.9% (post-change) ... the
   aggregate gate passes ... Judge for yourself whether the new library's coverage is adequate."*
   This framing was not accepted as settling the question. See `## 5. Test Coverage Detail` and
   `## 8. Gaps and Exceptions` for the reviewer's independent verdict, which differs from the
   executor's.

---

## Evidence Location Compliance

**Status: ✅ PASS.**

- Diff scan for non-canonical evidence roots:
  `git diff --name-only a36b6dca..65a56cb9 | grep -E "^artifacts/(baselines|qa|evidence|coverage)/"`
  returned no matches.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited **0** with
  empty output.
- All 28 evidence artifacts on this branch are written under
  `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence/`
  in the canonical `baseline/`, `regression-testing/`, `qa-gates/`, and `other/` sub-paths.

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose during this review.

---

## Executive Summary

The change adds detached-HEAD worktree classification and removal to the `cleanup-merged-worktrees`
tool, and adds a tip-equality pre-check that stops apply mode from deleting a zero-commit
`documentationandmemories` consolidation branch. The detached function group ships in a new
sourceable library, `scripts/bash/cleanup_worktrees_detached_lib.sh` (301 lines), so the 500-line
cap is respected on the existing 483-line classification library. Changes to the three pre-existing
shell files are small and additive: two `is_detached_candidate ... && continue` guards plus two
driver calls, a 20-line pre-check inside `verify_consolidation_merged`, one `source` line, and
usage/header contract text.

All mandatory toolchain stages pass. The bash format and lint gates were re-run locally by this
reviewer at head and produced exit 0 with empty stdout and stderr. The full `tests/shell/` bats
suite was re-executed locally by this reviewer and exited 0; CI recorded `1..308` with zero lines
beginning `not ok`. Line coverage is 92.9%, above the uniform 85% floor.

One policy result is not PASS. The new production file `cleanup_worktrees_detached_lib.sh` is
covered at **80.6% line coverage**, below the new-code threshold this review workflow applies
(>= 85% per the uniform tier rule; >= 90% per the workflow's remediation-trigger clause). The
uncovered region is not incidental: **three of the seven documented detached state tokens are never
produced by any test**, and two of those three — `MERGED_CONTENT_NEUTRAL` and `MERGED_EQUIVALENT` —
are on the delete-eligible allowlist that authorizes a destructive `git worktree remove`. Four
fail-closed `ANCESTRY_ERROR` branches guarding that same destructive path are also unexercised.
This is recorded as a FAIL under `.claude/rules/general-unit-test.md` ("Untested critical behavior
is not acceptable even if the overall percentage looks good") and is the sole remediation trigger.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md`
- ✅ `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- ✅ Bash: `.claude/rules/shell.md` — shfmt + shellcheck + bats + kcov
- N/A `python-code-change` / `python-unit-test` — zero changed Python files
- N/A `powershell-code-change` / `powershell-unit-test` — zero changed PowerShell files
- N/A `typescript-*` — zero changed TypeScript files
- N/A `csharp-*` — zero changed C# files
- N/A JSON — zero changed governed JSON files

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script was created and left on the branch. The diff adds one
  production library, one test suite, and checked-in fixture data.
- ✅ `grep -n "mktemp\|BATS_TMPDIR\|BATS_TEST_TMPDIR\|git init\|/tmp/" tests/shell/test_cleanup_worktrees_detached.bats`
  returned no match, confirming the prohibition on temporary files and scratch repositories in tests.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** — Tests run in any order | ✅ PASS | Every case in `tests/shell/test_cleanup_worktrees_detached.bats` invokes a fresh `env ... bash -c "source ...; <driver>"` subshell with a per-case `CLEANUP_WT_STUB_SCENARIO`. No case writes shared state. Re-executed locally by this reviewer both in isolation (`npx bats tests/shell/test_cleanup_worktrees_detached.bats`, 14/14 ok) and as part of the full directory run (exit 0). |
| **Isolation** — Each test targets a single behavior | ✅ PASS | 14 cases map to distinct behaviors: one per detached state, one per apply-mode outcome, plus three direct unit cases on `is_detached_candidate`, `classify_detached_head`, and `reverify_detached_delete_eligible`. The `is_detached_candidate flag matrix` case is the one deliberate exception; it exercises eight input rows of a pure predicate in a single case, which is acceptable table-style testing. |
| **Fast Execution** | ✅ PASS | `npx --yes bats tests/shell/test_cleanup_worktrees_detached.bats` completed well inside the 300 s allowance in this reviewer's run. The full `tests/shell/` directory run exceeded 600 s on Windows and was completed in the background with exit 0; that runtime is dominated by the pre-existing 290-case corpus and by Git Bash process-spawn cost, not by the 18 new cases. |
| **Determinism** — Consistent results | ✅ PASS | All git access is routed through the checked-in stub via the `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_STUB_SCENARIO` seams. No wall-clock read, no randomness, no network. Fixture data is checked in and version-controlled (`git ls-files tests/fixtures/cleanup_worktrees/scenarios/ &#124; grep detached &#124; wc -l` = 41 tracked files). |
| **Readability & Maintainability** | ✅ PASS | Each case has a descriptive name matching the AC text it verifies, and the file carries a header comment explaining why both helpers retain stderr (so that negative argv assertions against the stub log are meaningful). Test file is 166 lines, well under the cap. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Baseline **93.6% lines** (kcov). Command: `bash scripts/bash/shell-qc.sh test --coverage`, executed by CI workflow `.github/workflows/_shell-coverage.yml`, run 34113725852. Verified independently by this reviewer: `gh run view 34113725852` reports `conclusion: success`, `headBranch: epic/cleanup-merged-worktrees-hardening-integration`, `headSha: a36b6dca7809e456f00c7d5b01eec5da49f7fca0` — exactly the merge base. |
| **No Coverage Regression (aggregate)** | ⚠️ PARTIAL | Post-change **92.9% lines**. Change: **-0.7 points**. The aggregate remains 7.9 points above the uniform 85% floor, so the aggregate gate passes; but the movement is a genuine decrease and is recorded as such rather than as noise. Per-file "no regression on changed lines" for the three modified `.sh` files could not be established: neither the baseline artifact nor CI run 34113725852 records per-file baseline percentages, only the aggregate. Marked PARTIAL for that missing operand, not for a detected regression. |
| **New Code Coverage** | ❌ **FAIL** | `scripts/bash/cleanup_worktrees_detached_lib.sh` is new (301 lines) and measures **80.6% line coverage** in CI run 34118811332 (`shell-coverage/cov.xml`). This is below the >= 85% new-code line threshold in `.claude/rules/quality-tiers.md` as applied by this review workflow, and below the >= 90% new-file trigger in the feature-review coverage procedure. See `## 5. Test Coverage Detail` for the specific unexercised regions. |
| **Comprehensive Coverage** | ❌ **FAIL** | All six functions in the new library are entered by at least one test, but three of the seven documented state tokens (`MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`, `HAS_UNIQUE_RESIDUALS`) are never produced by any fixture, and four fail-closed `ANCESTRY_ERROR` branches are never taken. Enumerated in `## 5`. |
| **Positive Flows** | ⚠️ PARTIAL | Covered: report of a `MERGED_CLEAN` detached record (`report emits one detached record with MERGED_CLEAN`); non-forced removal (`apply removes a merged detached worktree without force`); branch-backed four-field record preserved. Not covered: the other two delete-eligible verdicts that also authorize removal. |
| **Negative Flows** | ✅ PASS | `apply never touches an unmerged detached worktree`; `is_detached_candidate flag matrix` asserts non-zero for `main`, `main,bare`, `main,detached`, `prunable`, and the empty string; `reverify_detached_delete_eligible blocks on a flipped verdict`. |
| **Edge Cases** | ✅ PASS | Caller's own detached worktree (`PROTECTED_CURRENT`, protection by normalized path, short-circuit before any ancestry probe); locked worktree; prunable worktree; main worktree excluded; consolidation branch whose tip equals `main`; empty/unresolvable `rev-parse` on either side of the tip comparison. |
| **Error Handling** | ⚠️ PARTIAL | Covered: `merge-base` hard failure (rc 128) mapping to `ANCESTRY_ERROR` with no removal and non-zero apply status, asserted both through `run_apply` and as a direct unit case on `classify_detached_head`; `verify_consolidation_merged` returning 2 on an empty `rev-parse`. Not covered: the `compute_protected`, `CONTENT_NEUTRAL_ERROR`, `CHERRY_ERROR`/`DIFF_TREE_ERROR`, and `RESIDUAL_ERROR` fail-closed branches inside `classify_detached_head`, and the hard-failure branch of `reverify_detached_delete_eligible`. |
| **Concurrency** | N/A | The tool is a single-process sequential driver; no concurrency surface is introduced. |
| **State Transitions** | ✅ PASS | The classification ladder is a state machine over seven tokens; the four reachable tokens are asserted, and the apply-mode transition table (eligible → remove, locked → `BLOCKED-LOCKED`, prunable → silent, reverify-flip → `BLOCKED-REVERIFY`, error → no action) is asserted row by row. |

### 1.2.1 Per-Language Coverage Comparison

- Bash: Baseline: 93.6% lines -> Post-change: 92.9% lines. Change: -0.7 points (a decrease). New/changed-code coverage: 80.6% for the new file `scripts/bash/cleanup_worktrees_detached_lib.sh`. Disposition: FAIL on the new-code threshold; the aggregate-floor sub-check passes at 92.9% against 85.0%. Evidence: `evidence/baseline/bash-test-coverage.2026-09-07T14-30.md`, `evidence/qa-gates/final-bash-test-coverage.2026-09-07T14-45.md`, `evidence/qa-gates/coverage-delta.2026-09-07T14-45.md`.
- TypeScript: Disposition: N/A - zero changed files on this branch. Evidence: branch diff extension inventory in this audit's header.
- Python: Disposition: N/A - zero changed files on this branch. Evidence: branch diff extension inventory in this audit's header.
- PowerShell: Disposition: N/A - zero changed files on this branch. Evidence: branch diff extension inventory in this audit's header.
- C#: Disposition: N/A - zero changed files on this branch. Evidence: branch diff extension inventory in this audit's header.

No branch-coverage figure is reported or asserted for bash. kcov does not measure branch coverage in
any output format, so no bash branch-coverage gate applies (`.claude/rules/shell.md:68-70`,
`.claude/rules/quality-tiers.md`). This reviewer confirms the executor's determination that the
`branch-rate="1.0"` attributes in the uploaded Cobertura report are kcov placeholders identical for
every entry and are therefore not read as measurements. Recording a branch figure from them would be
fabrication.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ⚠️ PARTIAL | Assertions are bare `[[ "$output" == *"literal"* ]]` and `[ "$status" -eq N ]` tests. On failure bats prints the full `$output`, which for these cases includes the stub's `stub-git:` argv log — genuinely useful diagnostics. However, a failing substring assertion reports only the failed expression, not which literal was expected, so a maintainer must read the source line. This matches the pre-existing convention in the four sibling suites and is not a regression. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | `setup()` resolves library and fixture paths (Arrange); the `report`/`runin` helpers execute one driver or function under one scenario (Act); the `[[ ]]` and `[ ]` tests follow (Assert). |
| **Document Intent** | ✅ PASS | Each case name states the behavior. Non-obvious choices carry inline rationale, notably why substring rather than equality assertions are required (stderr retention merges the stub argv log into `$output`) and why the `--force`/`worktree prune` negative assertions are meaningful only with stderr retained. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No database, network, remote API, or real git repository. Every git call is intercepted by `tests/fixtures/cleanup_worktrees/stub-bin/git` through the `CLEANUP_WT_GIT_BIN` seam. |
| **Use Mocks/Stubs** | ✅ PASS | The checked-in git stub is the sole test double. Eight new fixture scenario directories supply its responses: seven under `tests/fixtures/cleanup_worktrees/scenarios/detached_*` and one under `tests/fixtures/cleanup_worktrees/deletion/consolidated_zero_commit/` (9 tracked files). Two existing consolidation fixtures gained `rev-parse.main.out` / `rev-parse.documentationandmemories.out` keys so the new tip-equality pre-check has defined inputs. |
| **Environment Stability** | ✅ PASS | No temporary file creation. `setup()` performs `chmod +x "${STUB}" 2>/dev/null &#124;&#124; true` on a checked-in file — a pre-existing pattern in all sibling suites, not introduced here. No mutable global state; no reliance on external configuration. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document, together with `code-review.2026-09-07T12-45.md` and `feature-audit.2026-09-07T12-45.md` in the same folder, constitutes the required pre-PR review. One outstanding item is carried into `remediation-inputs.2026-09-07T12-45.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Policy files read in order** | ✅ PASS | `evidence/baseline/phase0-instructions-read.md` records the Phase 0 policy read. |
| **Baseline captured before changes** | ✅ PASS | `evidence/baseline/starting-tree.2026-09-07T11-00.md`, `bash-check.2026-09-07T11-00.md`, `shell-file-line-counts.2026-09-07T11-00.md`, `toolchain-availability.2026-09-07T11-00.md`, `bash-test-coverage.2026-09-07T14-30.md`. The coverage baseline was taken against the exact merge-base SHA `a36b6dca`, independently verified via `gh run view 34113725852`. |
| **Failing-test-first for a bug fix** | ✅ PASS | `evidence/regression-testing/fail-before-detached-and-consolidation.2026-09-07T14-30.md` records the 18 new cases failing before the fix. Commit order on the branch confirms it: `bf0bf088` (fixtures) → `669e5b88` (failing tests) → `853f8930` (fix) → `fdd0fecf` (docs) → `65a56cb9` (evidence). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The detached path is a flat sequence of guarded captures and `case` dispatches. No indirection, no callbacks, no dynamic dispatch. The two integration points in existing files are one-line guards (`is_detached_candidate "$wflags" && continue`) plus one driver call each. |
| **Reusability** | ✅ PASS | The four ladder rungs (`classify_ancestry`, `classify_content_neutral`, `classify_cherry_equivalent`, `classify_residual_commit`) are reused unmodified against a bare SHA rather than reimplemented. `remove_worktree_safe` is consumed as an opaque contract and is byte-unmodified (both diff hunks in `cleanup_worktrees_actions_lib.sh` are at old lines 202-207 and 343-351; `remove_worktree_safe` occupies old 252-279 / new 272-299 and lies between them). |
| **Extensibility** | ✅ PASS | `is_detached_candidate` isolates the detection predicate as a pure, git-free string test that a sibling epic child can call. `remove_detached_worktree` takes `(path, head, flags)` positionally with no hidden global. |
| **Separation of concerns** | ✅ PASS | Pure logic (`is_detached_candidate`) is separated from git-backed reads (`classify_detached_head`), from the re-verification gate (`reverify_detached_delete_eligible`), from the destructive action (`remove_detached_worktree`), and from the drivers (`report_detached_worktrees`, `apply_detached_worktrees`). |
| **Deliberate non-reuse justified** | ✅ PASS | The file header states in full why `classify_branch` is not reused: its worktree lookup matches on branch name and a detached record's branch field is the literal `DETACHED`, so the caller's own detached worktree would escape `PROTECTED_CURRENT`; and it emits into the `BRANCH&#124;` namespace and can fabricate SHA-keyed `COMMIT&#124;` records that `cherry_pick_candidates` would misread. Verified against `scripts/bash/cleanup_worktrees_lib.sh:346-363`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No file exceeds 500 lines** | ✅ PASS | `wc -l scripts/bash/*.sh` re-run by this reviewer at head: `cleanup_worktrees_lib.sh` 483, `cleanup_worktrees_actions_lib.sh` 406, `shell_qc_lib.sh` 379, `cleanup_worktrees_detached_lib.sh` **301**, `cleanup_worktrees_enumerate_lib.sh` 236, `shell-qc.sh` 103, `cleanup-worktrees.sh` 103, `coverage_demo.sh` 8, `coverage_lib.sh` 7. Maximum 483 < 500. `tests/shell/test_cleanup_worktrees_detached.bats` is 166 lines. |
| **New-file decision justified** | ✅ PASS | `cleanup_worktrees_lib.sh` was 479 lines at baseline, leaving 21 lines of headroom against the cap. Putting a 301-line function group there was not possible, so the new file is the correct structural response, not gratuitous fragmentation. |
| **Test file location** | ✅ PASS | `.claude/rules/shell.md:90` — "Tests live in `tests/shell/*.bats` and mirror `scripts/bash/`." The new suite is at `tests/shell/test_cleanup_worktrees_detached.bats`. No test file was placed in the production source tree. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `is_detached_candidate`, `classify_detached_head`, `report_detached_worktrees`, `reverify_detached_delete_eligible`, `remove_detached_worktree`, `apply_detached_worktrees`. Each name states its subject and action, and each parallels its branch-backed counterpart (`reverify_delete_eligible`, `remove_worktree_safe`, `run_report`, `run_apply`). |
| **Snake_case convention** | ✅ PASS | Consistent with the surrounding libraries. |
| **Function documentation** | ✅ PASS | Every one of the six functions carries a header comment stating its contract, arguments, return codes, and — where load-bearing — the ordering invariant. Example: `remove_detached_worktree` documents that the locked and prunable string tests must precede every git invocation so that "no removal was attempted" is observable as an empty argv log rather than inferred from a report line. |
| **Contract comments updated** | ✅ PASS | `cleanup_worktrees_lib.sh:44` adds the five-field record to the report-line contract block; `cleanup-worktrees.sh` usage text adds both record shapes and the full state vocabulary. |

### 2.5 After Making Changes — Toolchain Execution

The mandatory loop for bash is the three-stage `shell-qc.sh` sequence (`.claude/rules/shell.md:28-29`).
Type checking, architecture-boundary tests, and contract/schema checks have no bash instrument in this
repository and are not applicable.

| Stage | Command | Result | Status |
|---|---|---|---|
| 1. Formatting | `bash scripts/bash/shell-qc.sh format` | Exited 0, printed nothing. `git status --porcelain -- tools scripts .claude/lib/bash` captured immediately before and immediately after is **byte-identical**, proving shfmt rewrote nothing. | ✅ PASS |
| 2. Linting | `bash scripts/bash/shell-qc.sh check` | Exited 0 with empty stdout and empty stderr. **Independently re-run at head by this reviewer** as `sh scripts/bash/shell-qc.sh check` → exit 0, no output. `shfmt -d` prints a unified diff for any unformatted discovered file, so empty output is the falsifiable positive observation. | ✅ PASS |
| 3. Type checking | n/a | No bash type checker exists; explicitly out of scope per `.claude/rules/shell.md`. | N/A |
| 4. Architecture-boundary tests | n/a | No bash architecture instrument in this repository. | N/A |
| 5. Unit tests | `bash scripts/bash/shell-qc.sh test --coverage` | CI run 34118811332: TAP plan `1..308`, zero lines beginning `not ok`, exit 0. **Independently re-run locally by this reviewer**: `npx --yes bats tests/shell/` exited 0; targeted runs gave 14/14, 15/15, and 41/41 ok across the five `cleanup_worktrees` suites (70 cases). | ✅ PASS |
| 6. Contract / schema checks | n/a | No schema surface changed. | N/A |
| 7. Integration tests | n/a | No bash integration tier in this repository. | N/A |
| **Single clean pass** | — | `evidence/qa-gates/toolchain-single-pass.2026-09-07T14-45.md` records iteration 1 with no restart condition met at any stage. | ✅ PASS |

**Toolchain substitution (recorded, not concealed).** The plan's literal invocation form
`wsl -d Ubuntu -- bash -lc 'cd <path> && bash scripts/bash/shell-qc.sh ...'` is refused by the
worktree-isolation guard in this environment, and `kcov` has no local route. `shfmt` v3.12.0 and
`shellcheck` 0.11.0 are on the Windows PATH and ran natively; `bats` ran as `npx --yes bats`
(Bats 1.13.0, the same version the WSL wrapper would have used); the coverage stage was dispatched
to CI workflow `.github/workflows/_shell-coverage.yml`, whose step executes the identical
`bash scripts/bash/shell-qc.sh test --coverage` on `ubuntu-latest`. Every evidence artifact states
this substitution explicitly. This reviewer verified both CI runs directly with `gh run view` and
confirms branch, head SHA, and `conclusion: success` for each. The plan's recorded worktree path
`agent-a06652a3fd875c703` is stale; the live worktree is `agent-adf4f49cbc48904be`. That discrepancy
is documented in the evidence and does not affect any result.

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Behavior change called out** | ⚠️ PARTIAL | The apply-mode exit code becomes non-zero on a checkout containing a dirty or locked detached worktree where it previously exited 0. `spec.md` records this explicitly under `### ACTION lines: apply-mode results` ("Apply-mode exit code ... This is a visible change ... recorded here so it is not later mistaken for a regression"). `.claude/skills/cleanup-merged-worktrees/SKILL.md` and the `--help` text do **not** mention it. No in-repo automated consumer inspects that exit code (`.github/workflows/_build-check.yml` runs `--help` only), so operator impact is limited to a human reading the skill. Recorded as a Minor code-review finding. |
| **New result token documented** | ✅ PASS | `BLOCKED-LOCKED` is documented in `SKILL.md` apply-mode workflow step 5 and in the state list. |
| **Error handling explicit, fail-closed** | ✅ PASS | Every git-backed read in the new file is captured in the parent shell with `&#124;&#124; rc=$?` and fails closed to `ANCESTRY_ERROR` with a non-zero return. There is no path from a hard git failure to a `MERGED_*` verdict or to a removal. Verified by reading all six functions. |
| **No breaking public API** | ✅ PASS | The four-field branch-backed `WORKTREE&#124;` record is byte-unchanged; the detached record's first four fields are exactly the shape `issue.md` names, so any prefix or substring assertion written against `WORKTREE&#124;<path>&#124;DETACHED&#124;<state>` still matches. All in-repo callers were updated (five `.bats` helper source-chains). |
| **Dependencies** | ✅ PASS | No new dependency. The change uses only bash builtins and `git` through the existing `cleanup_wt_git` wrapper. |
| **I/O boundaries** | ✅ PASS | All git I/O funnels through `cleanup_wt_git`. `is_detached_candidate` is pure and testable with no git access at all, and is tested that way. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | ✅ PASS | `bash scripts/bash/shell-qc.sh format` exited 0 and rewrote nothing (before/after porcelain listings byte-identical). shfmt v3.12.0. |
| **Linting with shellcheck** | ✅ PASS | `bash scripts/bash/shell-qc.sh check` exited 0 with empty stdout and stderr. Re-run at head by this reviewer with the same result. shellcheck 0.11.0. Two `# shellcheck source=` / `# shellcheck disable=SC1091` directives were added for the new `source` line, matching the three pre-existing directives in the same file — the correct, narrowly-scoped suppression for a runtime-resolved source path. |
| **Testing with bats** | ✅ PASS | 308 cases, 0 failures (CI run 34118811332). Locally re-verified: full `tests/shell/` run exit 0. |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | ✅ PASS | `scripts/bash/cleanup_worktrees_detached_lib.sh:1` is `#!/usr/bin/env bash`, matching the sibling libraries. |
| **Error handling** | ✅ PASS | `set -euo pipefail` is set once in the entry wrapper `cleanup-worktrees.sh:7`; the libraries define functions only and set no options, which is the established pattern. The `is_detached_candidate "$wflags" && continue` guards are safe under `set -e` because a command preceding the final `&&` in an AND-list is exempt from the errexit rule. Confirmed empirically: the wrapper runs to completion and `--help` exits 0. |
| **No work at source time** | ✅ PASS | The new file defines six functions and executes nothing at source time, as its header states. Verified by reading the file top to bottom. |
| **Guarded-read discipline** | ✅ PASS | `cpout=$(compute_protected) &#124;&#124; cprc=$?`, `state=$(classify_detached_head ...) &#124;&#124; crc=$?` in three places. Every capture is in the parent shell, never inside a pipeline whose exit code would be discarded. The `MINUS_PRESENT` partial-merge signal is read from the already-captured cherry verdict rather than from a second `git cherry` invocation, precisely to avoid a discarded pipeline exit code. |
| **Under 500 lines** | ✅ PASS | 301 lines. Maximum across `scripts/bash/` is 483. |
| **Sourcing order** | ✅ PASS | `cleanup-worktrees.sh:25-27` sources the new library last, after enumerate → classification → actions. Bash resolves function names at call time, so `run_report` and `run_apply` — defined in earlier-sourced files — legitimately call into it. The header documents this contract. |

### Section 3D: JSON Configuration Policy Compliance

N/A — no governed JSON file is in the branch diff.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4C: Bash Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Tests in `tests/shell/*.bats` mirroring `scripts/bash/`** | ✅ PASS | `tests/shell/test_cleanup_worktrees_detached.bats` for `scripts/bash/cleanup_worktrees_detached_lib.sh`. |
| **No temporary files, no scratch repositories** | ✅ PASS | Zero-match search for `mktemp`, `$BATS_TMPDIR`, `$BATS_TEST_TMPDIR`, `git init`, `/tmp/` in the new suite. |
| **Stub seam used for all git access** | ✅ PASS | `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_STUB_SCENARIO` on every `run env` invocation. |
| **Fixtures checked in** | ✅ PASS | 41 tracked files under `tests/fixtures/cleanup_worktrees/scenarios/detached_*`; 9 under `deletion/consolidated_zero_commit/`. |
| **No test file exceeds 500 lines** | ✅ PASS | 166 lines. |
| **New library fully exercised** | ❌ **FAIL** | `spec.md` D3 states the requirement directly: the new library is in the kcov denominator and "every function in it must be exercised." Every function is entered, but three of seven state tokens and four fail-closed error branches are not. See `## 5`. |

---

## 5. Test Coverage Detail

### `scripts/bash/cleanup_worktrees_detached_lib.sh` (301 lines, 80.6% line coverage, 14 dedicated tests)

| Test Name | Scenario Type | Behavior Covered | Status |
|-----------|--------------|------------------|--------|
| `report emits one detached record with MERGED_CLEAN` | Positive | `report_detached_worktrees` emission; exactly-one-record replacement semantics; main worktree excluded | ✅ |
| `report emits NOT_MERGED for an unmerged detached HEAD` | Positive | Full ladder to the `NOT_MERGED` terminal | ✅ |
| `is_detached_candidate flag matrix` | Positive + Negative | 8-row predicate table, no git access | ✅ |
| `branch-backed worktree records keep the four-field shape` | Regression guard | Four-field record unchanged | ✅ |
| `apply removes a merged detached worktree without force` | Positive | `apply_detached_worktrees` → `remove_detached_worktree` → `remove_worktree_safe`; no `--force`; no `worktree prune` | ✅ |
| `apply never touches an unmerged detached worktree` | Negative | Allowlist gate | ✅ |
| `dirty detached worktree blocks with DIRTY lines` | Error handling | `BLOCKED-DIRTY` inherited from `remove_worktree_safe`; non-zero status | ✅ |
| `locked detached worktree yields BLOCKED-LOCKED and invokes no removal` | Edge case | Locked short-circuit precedes every git call | ✅ |
| `prunable detached worktree is report-only` | Edge case | Prunable short-circuit; no removal, no prune | ✅ |
| `the caller's own detached worktree is PROTECTED_CURRENT` | Edge case | Path-based protection; short-circuit before the ancestry probe | ✅ |
| `a hard git failure maps to ANCESTRY_ERROR with no removal` | Error handling | `merge-base` rc 128 → `ANCESTRY_ERROR`, non-zero apply status | ✅ |
| `classify_detached_head returns MERGED_CLEAN for an ancestor HEAD` | Positive unit | Direct unit assertion on rung 1 | ✅ |
| `classify_detached_head returns 2 on a hard failure` | Error handling unit | Return code 2 contract | ✅ |
| `reverify_detached_delete_eligible blocks on a flipped verdict` | Error handling unit | `BLOCKED-REVERIFY`, status 1, no removal argv | ✅ |

**Not covered — enumerated.** The seven new detached fixtures were read directly by this reviewer and
produce exactly four of the seven documented state tokens:

| Fixture | Decisive key | Resulting state |
|---|---|---|
| `detached_merged` | `merge-base.det00001.rc` = 0 | `MERGED_CLEAN` |
| `detached_merged_dirty` | `merge-base.det00003.rc` = 0 | `MERGED_CLEAN` |
| `detached_locked` | `merge-base.det00004.rc` = 0 | `MERGED_CLEAN` |
| `detached_prunable` | `merge-base.det00007.rc` = 0 | `MERGED_CLEAN` |
| `detached_unmerged` | `merge-base` rc 1, `diff-quiet` rc 1, cherry `+ det00002`, blobA≠blobB | `NOT_MERGED` |
| `detached_current` | `rev-parse.abbrev-ref-HEAD` = `HEAD`, toplevel = `/repo-wt/current` | `PROTECTED_CURRENT` |
| `detached_ancestry_error` | `merge-base.det00006.rc` = 128 | `ANCESTRY_ERROR` |

Never produced by any test, and therefore never covered:

1. **`MERGED_CONTENT_NEUTRAL`** — the `classify_content_neutral` rung returning delete-eligible.
   **On the delete-eligible allowlist.** No fixture supplies a `diff-quiet.<sha>.rc` of 0 for a
   non-ancestor detached HEAD.
2. **`MERGED_EQUIVALENT` via the cherry rung** — `classify_cherry_equivalent` returning the single
   `MERGED_EQUIVALENT` line. **On the delete-eligible allowlist.**
3. **`MERGED_EQUIVALENT` via the rename-aware blob fallback** — the `((unique_count == 0))` terminal
   after every residual resolves `CONTENT_ON_MAIN`. **On the delete-eligible allowlist**, and reached
   through the most complex rung in the ladder.
4. **`HAS_UNIQUE_RESIDUALS`** — the `minus_present == 1 || content_count > 0` terminal.
5. **`compute_protected` hard failure → `ANCESTRY_ERROR`, return 2** — the fail-closed branch that
   prevents a weakened (empty) protected set from letting the caller's own worktree reach a
   delete-eligible verdict. The branch-backed counterpart *is* tested
   (`rev_parse_error_protection: classify_branch reports ANCESTRY_ERROR for the current branch, never MERGED_CLEAN`);
   the detached counterpart is not.
6. **`CONTENT_NEUTRAL_ERROR` → `ANCESTRY_ERROR`, return 2** — fail-closed branch.
7. **`CHERRY_ERROR` / `DIFF_TREE_ERROR` → `ANCESTRY_ERROR`, return 2** — fail-closed branch.
8. **`RESIDUAL_ERROR` → `ANCESTRY_ERROR`, return 2** — fail-closed branch.
9. **`reverify_detached_delete_eligible` hard-failure branch** (`((crc != 0))` → `BLOCKED-REVERIFY`) —
   only the allowlist-miss branch is tested.
10. **`report_detached_worktrees` return-code folding** (`((crc > rc))` → `rc=$crc`) — report mode is
    never run against `detached_ancestry_error`; only apply mode is.

Items 1-3 are the material ones: **two of the three verdicts that authorize `git worktree remove` on
a detached worktree are never produced in any test**, so the removal path is proven for exactly one
of three entry conditions. Items 5-8 are fail-closed guards on that same destructive path.

Mitigating facts, weighed and recorded: the ladder rungs themselves are shared, already-covered
functions tested through `classify_branch`; the uncovered code in this file is the thin dispatch and
`printf` around them; and every uncovered error branch fails in the safe direction (no removal). This
is why the finding is graded **Major** rather than **Blocker** in the accompanying code review.

### `scripts/bash/cleanup_worktrees_actions_lib.sh` — `verify_consolidation_merged` tip-equality pre-check (3 tests)

| Test Name | Scenario Type | Behavior Covered | Status |
|-----------|--------------|------------------|--------|
| `a zero-commit consolidation branch is never deleted` | Positive (guard fires) | `BLOCKED-CONSOLIDATION-UNMERGED`; no `branch -D`; no `worktree remove /repo-wt/dm` | ✅ |
| `verify_consolidation_merged returns NOT_ANCESTOR on tip equality` | Unit | status 1, `NOT_ANCESTOR`, not `MERGED_CLEAN` | ✅ |
| `verify_consolidation_merged fails closed on an empty rev-parse` | Error handling | status 2, `ANCESTRY_ERROR`, no `branch -D` | ✅ |
| `consolidated-content branch deletion is gated on the merge check` (pre-existing) | Regression guard | Genuinely merged branch still deletable after the pre-check | ✅ |

Fixture inputs verified directly by this reviewer: `consolidated_zero_commit` has both
`rev-parse.main.out` and `rev-parse.documentationandmemories.out` equal to `aaaa0000`;
`consolidated_merged` and `consolidated_unmerged` gained distinct values (`aaaa0000` vs `dm000001`)
so the guard does not fire falsely on them. This closes the exact trap the spec's Research
Correction 2 identified.

**Coverage of this function group: complete.** The pre-check has three outcomes and all three are
asserted. Reported per-file coverage of `cleanup_worktrees_actions_lib.sh` is 93.3%.

### Modified files — per-file post-change coverage

| File | Post-change line coverage |
|---|---|
| `scripts/bash/cleanup_worktrees_lib.sh` | 93.3% |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 93.3% |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 92.1% |
| `scripts/bash/cleanup-worktrees.sh` | 100.0% |

All four are above the 85% line floor. Per-file *baseline* figures were not captured, so the
"no regression on changed lines" clause is **UNVERIFIED** for these four files, with the concrete
reason that CI run 34113725852 recorded only the aggregate headline and this reviewer cannot
regenerate a baseline per-file report without `kcov`, which has no local route in this worktree.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (full bash suite, CI) | 308 | ✅ |
| Tests Passed | 308 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| New tests added by this branch | 18 (14 detached suite + 3 deletion + 1 CLI) | ✅ |
| Baseline test count | 290 | ✅ |
| Local re-verification by reviewer | `npx --yes bats tests/shell/` exit 0; targeted runs 14/14 + 15/15 + 41/41 ok | ✅ |
| Test File Size (new suite) | 166 lines | ✅ Maintainable |
| Functions in new library / covered by >= 1 test | 6 / 6 | ✅ |
| Code Coverage (bash aggregate) | 92.9% lines; branch coverage not measurable by kcov | ✅ vs 85% floor |
| Code Coverage (new file) | 80.6% lines | ❌ vs 85% new-code threshold |

---

## 7. Code Quality Checks

**For Bash:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| shfmt formatting | `bash scripts/bash/shell-qc.sh format` | Exit 0, no output; before/after porcelain listings byte-identical | ✅ |
| shfmt diff + shellcheck | `bash scripts/bash/shell-qc.sh check` | Exit 0, empty stdout and stderr. **Reviewer re-run at head:** `sh scripts/bash/shell-qc.sh check` → exit 0, no output | ✅ |
| bats + kcov | `bash scripts/bash/shell-qc.sh test --coverage` | `1..308`, 0 `not ok`, `Bash coverage (lines): 92.9%` (CI 34118811332) | ✅ |
| File-size cap | `wc -l scripts/bash/*.sh` | Max 483; new file 301 | ✅ |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | Exit 0, no output | ✅ |
| Push-down mirror parity | `diff .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` | Identical | ✅ |
| CLI smoke | `sh scripts/bash/cleanup-worktrees.sh --help` | Exit 0; stdout contains the literal `WORKTREE&#124;<path>&#124;DETACHED&#124;<state>&#124;<flags>` | ✅ |
| Rejected guard forms absent | `grep -rn "rev-list --count&#124;--force&#124;worktree prune" scripts/bash/` | Only one hit: a comment at `cleanup_worktrees_detached_lib.sh:39` stating that `git worktree prune` is never invoked. No invocation of any of the three forms. | ✅ |
| Clean merge onto current base head | `git merge-tree --write-tree 288ca214 65a56cb9` | Exit 0 — no conflict | ✅ |

**Notes on pre-existing conditions unrelated to this change:**

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  fails locally on an untracked, gitignored `.claude/state/` file. That is previously filed issue
  #510, is unrelated to this change set, and is green in CI. The executor's recorded pass was
  obtained after moving that one untracked file aside; no tracked file was altered. This reviewer
  verified the substantive requirement of that test directly and independently with a byte-level
  `diff` of the two SKILL.md files, which reported them identical. The AC does not depend on the
  failing harness.
- `tests/shell/test_shell_qc_commands.bats` emits a bats `BW01` advisory (a `run` invocation whose
  command exits 127 by design). It is a warning, not a failure; the suite exits 0. Pre-existing.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **New-file coverage below threshold (FAIL, remediation-triggering).**
   `scripts/bash/cleanup_worktrees_detached_lib.sh` measures 80.6% line coverage against a >= 85%
   new-code threshold (uniform tier rule, `.claude/rules/quality-tiers.md`) and a >= 90% new-file
   remediation trigger in the feature-review coverage procedure. The substantive content of the gap
   is that `MERGED_CONTENT_NEUTRAL` and `MERGED_EQUIVALENT` — two of the three verdicts that
   authorize a destructive `git worktree remove` on a detached worktree — are never produced by any
   test, `HAS_UNIQUE_RESIDUALS` is never produced, and four fail-closed `ANCESTRY_ERROR` branches on
   the destructive path are unexercised. `.claude/rules/general-unit-test.md` states that "Untested
   critical behavior is not acceptable even if the overall percentage looks good," which is the
   operative rule here, independent of any percentage.

   **Explicit disagreement with the executor's framing.** `evidence/qa-gates/coverage-delta.2026-09-07T14-45.md`
   states that "no per-file gate exists in this repository against which to pass or fail it." That is
   accurate as a reading of `quality-tiers.md`, which states repo-wide and changed-line thresholds.
   It is not the whole rule set that governs this review: the feature-review workflow contract
   applies an explicit per-new-file coverage threshold, and `general-unit-test.md` applies a
   qualitative untested-critical-behavior rule that no percentage can satisfy. Both are cited above.
   The aggregate AC24 gate is separately and correctly PASS at 92.9%.

2. **Aggregate coverage regressed by 0.7 points (PARTIAL).** 93.6% → 92.9%. The post-change value
   clears the 85% floor with 7.9 points of margin, so the aggregate gate passes; the regression is
   recorded as a genuine decrease attributable to gap 1 and is expected to reverse when gap 1 is
   remediated.

3. **Per-file baseline coverage not captured (UNVERIFIED).** The "no regression on changed lines"
   clause cannot be evaluated for the three modified `.sh` files. Concrete reason: CI run
   34113725852 recorded only the aggregate headline, and `kcov` has no local route in this worktree,
   so a baseline per-file report cannot be regenerated by this reviewer. Post-change per-file values
   for all four touched production files are 92.1%-100%, so a regression below the floor is not
   plausible, but the comparison itself is unverified.

4. **Apply-mode exit-code change not documented in the operator-facing skill (Minor).** See
   `## 2.6`. `spec.md` records it; `SKILL.md` and `--help` do not.

5. **A detached worktree with unique residuals emits no `COMMIT|` records (Minor).**
   `classify_detached_head` deliberately does not emit into the `COMMIT|` namespace (spec Research
   Correction 4: `classify_branch` "can fabricate SHA-keyed `COMMIT\|` records that
   `cherry_pick_candidates` would misread"). The consequence is that unique work held in a detached
   worktree is correctly retained but never surfaced to the consolidation/cherry-pick triage flow
   that reads `COMMIT|...|UNIQUE` records. This limitation is not listed under `spec.md`
   `## Known Limitations` (L1-L4) and is not documented in `SKILL.md`. It fails in the safe
   direction and is a follow-up candidate, not a defect in this change.

### Approved Exceptions

- **No bash branch-coverage gate.** kcov does not measure branch coverage for bash in any output
  format. `.claude/rules/shell.md:68-70` and `.claude/rules/quality-tiers.md` name bash (and
  PowerShell) as exempt from the >= 75% branch threshold. The absence of a branch figure is
  correctly **not** recorded as a FAIL. The exemption does not permit excluding any file from line
  measurement, and none was excluded: the new library appears as its own entry in the Cobertura
  report, confirming it is inside the kcov include pattern
  (`scripts/bash/shell_qc_lib.sh:335-336`).
- **CI-dispatched coverage instead of a local run.** `kcov` has no local route in this worktree and
  the WSL wrapper form is refused by the worktree-isolation guard. The CI fallback workflow executes
  the identical command on `ubuntu-latest`. Both runs were verified by this reviewer with
  `gh run view` for branch, head SHA, and conclusion.
- **MCP template resolution unavailable.** The workflow requires resolving review templates through
  `mcp__drm-copilot__resolve_policy_audit_template_asset`. No MCP tool is exposed to this reviewer
  session. The identical bundled assets were read directly from the path that tool resolves,
  `extensions/drm-copilot/resources/templates/policy_audit/` (verified against
  `extensions/drm-copilot/src/policy-audit-template-assets.ts:19-58`), so the template source is the
  same bundled asset the MCP tool would have returned. Recorded as a substitution, not a silent skip.
- **Coverage-artifact paths.** The feature-review coverage table names TypeScript, Python,
  PowerShell, and C# artifact paths. Bash is not in that table; its canonical artifact is the
  Cobertura `cov.xml` produced by `_shell-coverage.yml` and summarized in the feature-folder
  evidence, per `.claude/rules/shell.md:44`. Absence of `coverage/lcov.info`,
  `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`, and
  `artifacts/csharp/coverage.xml` is correct, because those four languages have zero changed files
  on this branch.

### Removed/Skipped Tests

**None.** No test was removed, skipped, or weakened. All 290 pre-existing bash cases pass unchanged.
Verified by `git diff` on the four modified `.bats` files: the only changes are `DLIB` variable
definitions and added `source '${DLIB}'` links in helper chains, plus one appended CLI case. No
pinned assertion line was altered.

---

## 9. Summary of Changes

### Commits in This PR/Branch

| SHA | Subject |
|---|---|
| `bf0bf088` | test(630): add detached-worktree and consolidation fixture scenarios |
| `669e5b88` | test(630): add failing detached-worktree and consolidation regression cases |
| `853f8930` | fix(630): classify and remove detached-HEAD worktrees, guard zero-commit consolidation |
| `fdd0fecf` | docs(630): document detached worktree records and the consolidation guard |
| `65a56cb9` | docs(630): record Phase 7 QC evidence and check off acceptance criteria |

Commit ordering follows the required failing-test-first sequence for a bug fix.

**Coverage-run staleness check.** CI run 34118811332 was dispatched at `fdd0fecf`, one commit behind
head `65a56cb9`. `git diff --stat fdd0fecf 65a56cb9` shows 23 files changed, **all** of them Markdown
under `docs/features/active/.../` — no `.sh`, `.bats`, or fixture file. The coverage and test figures
therefore remain valid for the head tree. The format and lint gates were additionally re-run at head
by this reviewer with exit 0.

### Files Modified

**Production source (4):**
- `scripts/bash/cleanup_worktrees_detached_lib.sh` — **new**, 301 lines, 6 functions.
- `scripts/bash/cleanup-worktrees.sh` — +13/-2: one `source` line with its two shellcheck directives; usage text for both record shapes and the state vocabulary.
- `scripts/bash/cleanup_worktrees_actions_lib.sh` — +24: 20-line tip-equality pre-check in `verify_consolidation_merged`; `is_detached_candidate` skip guard and `apply_detached_worktrees` call in `run_apply`.
- `scripts/bash/cleanup_worktrees_lib.sh` — +4: report-line contract comment; `is_detached_candidate` skip guard and `report_detached_worktrees` call in `run_report`.

**Tests (5):**
- `tests/shell/test_cleanup_worktrees_detached.bats` — **new**, 166 lines, 14 cases.
- `tests/shell/test_cleanup_worktrees_deletion.bats` — +38/-1: `DLIB` sourcing; 3 new consolidation cases.
- `tests/shell/test_cleanup_worktrees_cli.bats` — +9: 1 new `--help` case.
- `tests/shell/test_cleanup_worktrees_classification.bats` — +4/-2: `DLIB` sourcing only.
- `tests/shell/test_cleanup_worktrees_hard_failures.bats` — +2/-1: `DLIB` sourcing only.

**Fixtures (54 files):** 7 new `scenarios/detached_*` directories, 1 new
`deletion/consolidated_zero_commit/` directory, and 4 added `rev-parse` keys in 2 existing
consolidation fixtures.

**Documentation (31 files):** `.claude/skills/cleanup-merged-worktrees/SKILL.md` (+29) and its
push-down mirror (+29, content-identical), `spec.md`, `plan.2026-09-06T17-12.md`, and 28 evidence
artifacts.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

### Policy-by-Policy Summary

| Policy | Status | Notes |
|---|---|---|
| `.claude/rules/general-code-change.md` | ✅ PASS | Design principles, file-size cap, naming, error handling, dependency policy, and I/O boundaries all satisfied. Toolchain loop completed in one clean pass. |
| `.claude/rules/general-unit-test.md` | ❌ **FAIL** | Core principles, test location, external-dependency, and no-temp-file rules all pass. Fails on scenario completeness and the untested-critical-behavior rule: two of three delete-eligible verdicts and four fail-closed error branches on the destructive path are unexercised. |
| `.claude/rules/quality-tiers.md` | ⚠️ PARTIAL | Uniform 85% line floor met at 92.9% aggregate. New-code line coverage of 80.6% is below the same uniform 85% floor applied to the new file. Branch threshold correctly not applied to bash. |
| `.claude/rules/shell.md` | ✅ PASS | shfmt, shellcheck, bats, kcov denominator inclusion, 500-line cap, `tests/shell/` location, and stub-seam discipline all satisfied. |
| `.claude/rules/tonality.md` | ✅ PASS | Code comments, skill documentation, and evidence artifacts are factual and measured. No hyperbole, humor, or decorative metaphor observed. |
| Evidence-location invariant | ✅ PASS | Validator exit 0; zero non-canonical paths in the diff. |
| `modified-workflow-needs-green-run` | N/A (rule did not fire) | No path in the branch diff matches `.github/workflows/**`, `.github/actions/**`, or `scripts/benchmarks/**`. |

### Metrics Summary

| Metric | Value | Threshold | Verdict |
|---|---|---|---|
| Bash aggregate line coverage | 92.9% | >= 85% | ✅ PASS |
| Bash aggregate coverage delta | -0.7 pts | no regression preferred; floor is binding | ⚠️ PARTIAL |
| New-file line coverage (`cleanup_worktrees_detached_lib.sh`) | 80.6% | >= 85% (uniform) / >= 90% (new-file trigger) | ❌ **FAIL** |
| Modified-file line coverage (4 files) | 92.1%-100% | >= 85% | ✅ PASS |
| Modified-file changed-line regression | not measurable | no regression | ⚠️ UNVERIFIED (per-file baseline not captured; `kcov` has no local route) |
| Bash branch coverage | not measurable by kcov | no gate applies | N/A (correctly exempt) |
| Bash tests passing | 308 / 308 | 100% | ✅ PASS |
| Max shell file length | 483 lines | <= 500 | ✅ PASS |
| Format gate | exit 0, nothing rewritten | clean | ✅ PASS |
| Lint gate | exit 0, empty output | clean | ✅ PASS |
| Toolchain iterations | 1 | single clean pass | ✅ PASS |
| Acceptance criteria PASS | 24 / 24 | all | ✅ PASS |

**Coverage verdict for every language with changed files on this branch:**

- **Bash: ❌ FAIL** — driven solely by the new-file threshold. Aggregate, modified-file, and
  test-outcome sub-gates all pass.
- TypeScript / Python / PowerShell / C#: N/A — zero changed files on this branch.

### Recommendation

**Conditional Go.** The functional change is correct, well-structured, fully documented, and passes
every toolchain gate. Acceptance criteria are 24/24 PASS. The single non-PASS result is new-file test
coverage, and its substance — that `MERGED_CONTENT_NEUTRAL` and `MERGED_EQUIVALENT` are never
produced by any test even though both authorize a destructive `git worktree remove` — is a concrete,
cheaply closable gap: it requires two additional stub fixture directories and roughly four bats
cases, with no production-code change.

Route through `remediation-inputs.2026-09-07T12-45.md`. This finding does not warrant reverting or
restructuring any part of the implementation.

---

## Appendix A: Test Inventory

### Complete Test List — new and modified cases (18)

**`tests/shell/test_cleanup_worktrees_detached.bats` (14, all new):**

1. `report emits one detached record with MERGED_CLEAN`
2. `report emits NOT_MERGED for an unmerged detached HEAD`
3. `is_detached_candidate flag matrix`
4. `branch-backed worktree records keep the four-field shape`
5. `apply removes a merged detached worktree without force`
6. `apply never touches an unmerged detached worktree`
7. `dirty detached worktree blocks with DIRTY lines`
8. `locked detached worktree yields BLOCKED-LOCKED and invokes no removal`
9. `prunable detached worktree is report-only`
10. `the caller's own detached worktree is PROTECTED_CURRENT`
11. `a hard git failure maps to ANCESTRY_ERROR with no removal`
12. `classify_detached_head returns MERGED_CLEAN for an ancestor HEAD`
13. `classify_detached_head returns 2 on a hard failure`
14. `reverify_detached_delete_eligible blocks on a flipped verdict`

**`tests/shell/test_cleanup_worktrees_deletion.bats` (3 new):**

15. `a zero-commit consolidation branch is never deleted`
16. `verify_consolidation_merged returns NOT_ANCESTOR on tip equality`
17. `verify_consolidation_merged fails closed on an empty rev-parse`

**`tests/shell/test_cleanup_worktrees_cli.bats` (1 new):**

18. `--help documents the detached worktree record`

**Pre-existing bash suite:** 290 cases, all passing unchanged. Total 308.

### New fixture inventory

`tests/fixtures/cleanup_worktrees/scenarios/`: `detached_merged`, `detached_unmerged`,
`detached_merged_dirty`, `detached_locked`, `detached_current`, `detached_prunable`,
`detached_ancestry_error` (41 tracked files).

`tests/fixtures/cleanup_worktrees/deletion/`: `consolidated_zero_commit` (9 tracked files); plus
`rev-parse.main.out` and `rev-parse.documentationandmemories.out` added to `consolidated_merged` and
`consolidated_unmerged`.

---

## Appendix B: Toolchain Commands Reference

### Bash (the in-scope language)

```bash
# Formatting (stage 1)
bash scripts/bash/shell-qc.sh format

# Linting: shfmt -d + shellcheck (stage 2)
bash scripts/bash/shell-qc.sh check

# Unit tests (stage 5)
bash scripts/bash/shell-qc.sh test

# Unit tests with kcov line coverage (stage 5 + coverage)
bash scripts/bash/shell-qc.sh test --coverage
# Coverage headline literal: `Bash coverage (lines): NN.N%`
# Cobertura report: shell-coverage/cov.xml (CI artifact)
# kcov include pattern: $repo_root/tools,$repo_root/scripts,$repo_root/.claude/lib/bash
# kcov exclude pattern: $repo_root/tests
#   (scripts/bash/shell_qc_lib.sh:335-336)
```

### Commands actually executed by this reviewer

```bash
# Base/diff resolution
git diff --stat a36b6dca7809e456f00c7d5b01eec5da49f7fca0 65a56cb94352c2a19c381acf4008837fa84aee69
git diff --name-status a36b6dca7809e456f00c7d5b01eec5da49f7fca0 65a56cb94352c2a19c381acf4008837fa84aee69 -- '*.sh' '*.bats'
git log --oneline a36b6dca7809e456f00c7d5b01eec5da49f7fca0..65a56cb94352c2a19c381acf4008837fa84aee69
git diff --stat fdd0fecf 65a56cb94352c2a19c381acf4008837fa84aee69

# PR context refresh (artifacts were absent; regenerated against the supplied base)
poetry run python -m scripts.dev_tools.pr_context.collector \
  --base epic/cleanup-merged-worktrees-hardening-integration --head HEAD --repo-root .

# Lint / format gate, re-run at head
sh scripts/bash/shell-qc.sh check          # exit 0, empty stdout and stderr

# Tests, re-run locally
npx --yes bats tests/shell/                                          # exit 0
npx --yes bats tests/shell/test_cleanup_worktrees_detached.bats      # 14/14 ok
npx --yes bats tests/shell/test_cleanup_worktrees_deletion.bats \
             tests/shell/test_cleanup_worktrees_cli.bats             # 15/15 ok
npx --yes bats tests/shell/test_cleanup_worktrees_classification.bats \
             tests/shell/test_cleanup_worktrees_enumeration.bats \
             tests/shell/test_cleanup_worktrees_hard_failures.bats   # 41/41 ok

# CLI contract
sh scripts/bash/cleanup-worktrees.sh --help   # exit 0; contains WORKTREE|<path>|DETACHED|<state>|<flags>

# File-size cap
wc -l scripts/bash/*.sh | sort -rn            # max 483; new file 301

# Rejected guard forms
grep -rn "rev-list --count\|--force\|worktree prune" scripts/bash/

# Push-down mirror parity
diff .claude/skills/cleanup-merged-worktrees/SKILL.md \
     extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md

# Evidence locations
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .   # exit 0
git diff --name-only a36b6dca 65a56cb9 | grep -E "^artifacts/(baselines|qa|evidence|coverage)/"

# Temp-file prohibition in the new suite
grep -n "mktemp\|BATS_TMPDIR\|BATS_TEST_TMPDIR\|git init\|/tmp/" tests/shell/test_cleanup_worktrees_detached.bats

# CI coverage run verification
gh run view 34113725852 --json headSha,conclusion,headBranch,workflowName   # baseline @ a36b6dca
gh run view 34118811332 --json headSha,conclusion,headBranch,workflowName   # post-change @ fdd0fecf

# Integration-conflict pre-check against the current base head
git merge-tree --write-tree 288ca2148d159bf2f7a1cbfff6bad3ee5c8d791b 65a56cb94352c2a19c381acf4008837fa84aee69
```

### Not applicable to this branch (zero changed files)

```bash
# TypeScript
npm run test:unit:coverage        # artifact: coverage/lcov.info
# Python
poetry run pytest --cov           # artifact: artifacts/python/lcov.info
# PowerShell
Invoke-PoshQCTest -Root .         # artifact: artifacts/pester/powershell-coverage.xml
# C#
dotnet test --collect:"XPlat Code Coverage"   # artifact: artifacts/csharp/coverage.xml
```
