# Policy Compliance Audit: detached-worktree classification and consolidation-branch ordering (Issue #630)

**Audit Date:** 2026-09-07
**Review Type:** Re-audit (R4) of remediation cycle 1
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
| A/M | 117 test fixture data files under `tests/fixtures/cleanup_worktrees/` |
| A/M | 65 Markdown documents (`.claude/skills/cleanup-merged-worktrees/SKILL.md`, its push-down mirror, feature-folder docs and evidence) |

Full branch diff: **191 files changed, 6977 insertions(+), 106 deletions(-)**.

**Base branch:** `epic/cleanup-merged-worktrees-hardening-integration`
**Merge base:** `a36b6dca7809e456f00c7d5b01eec5da49f7fca0`
**Head:** `2742c417dcd686e76310d9f15420390d421868db` (branch `bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`)
**Work mode:** `full-bug` (marker at `issue.md:12`); AC source is `spec.md` only.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Bash | 4 production `.sh` (1 new, 3 modified) + 5 `.bats` (1 new, 4 modified) | 321 bats cases | PASS 321 pass, 0 fail | 93.6% lines (kcov) | 94.2% lines (kcov) | 100.0% lines (`cleanup_worktrees_detached_lib.sh`) |
| TypeScript | 0 files | 0 tests | N/A | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |
| Python | 0 files | 0 tests | N/A | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |
| PowerShell | 0 files | 0 tests | N/A | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |
| C# | 0 files | 0 tests | N/A | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |

No Python, TypeScript, PowerShell, or C# source file is in the branch diff. Extension inventory of
the 191 changed paths: 87 `.out`, 65 `.md`, 30 `.rc`, 5 `.bats`, 4 `.sh`. The `.out` and `.rc` files
are checked-in git-stub fixture data, not executable source. Bash is therefore the only language
with changed files, and its coverage verdict is an explicit **PASS**.

### Coverage Evidence Checklist

- Bash baseline coverage artifact: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence/baseline/bash-test-coverage.2026-09-07T14-30.md` (CI run 34113725852 at merge-base sha `a36b6dca`; Cobertura re-read directly by this reviewer)
- Bash post-change coverage artifact: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence/qa-gates/final-bash-test-coverage.2026-09-07T16-30.md` (CI run 34142466852 at sha `12cc5766`; Cobertura re-read directly by this reviewer)
- TypeScript baseline coverage artifact: N/A - out of scope
- TypeScript post-change coverage artifact: N/A - out of scope
- PowerShell baseline coverage artifact: N/A - out of scope
- PowerShell post-change coverage artifact: N/A - out of scope
- Python baseline coverage artifact: N/A - out of scope
- Python post-change coverage artifact: N/A - out of scope
- C# baseline coverage artifact: N/A - out of scope
- C# post-change coverage artifact: N/A - out of scope
- Per-language comparison summary: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence/qa-gates/coverage-delta.2026-09-07T16-30.md` and section 1.2.1 of this audit

`N/A - out of scope` above means zero changed files for that language in the branch diff, which is
the only condition under which a coverage verdict may be non-explicit.

---

## Rejected Scope Narrowing

The caller prompt did not attempt to narrow the audit scope to a plan, task, phase, or file subset,
and did not mark any language's coverage as out of scope. The caller stated the opposite
explicitly: *"This is a full re-audit with NO scope narrowing. Review the complete branch diff
against the merge base, not only the remediation delta. Scope determination is yours."* No
narrowing was detected and none was rejected. The audit was performed against the full branch diff
`a36b6dca..2742c417`.

Three caller-supplied statements were treated as inputs to verify rather than as findings to
accept. All three were independently re-derived by this reviewer.

1. Caller text: *"`sh scripts/bash/shell-qc.sh check`, `sh scripts/bash/shell-qc.sh format`, and
   `npx --yes bats <path>` all run in this worktree. Only `kcov` genuinely requires CI."*
   Confirmed. `sh scripts/bash/shell-qc.sh check` was run at head by this reviewer and exited 0
   with empty stdout and empty stderr. `npx --yes bats` was run against the detached suite and the
   five sibling cleanup suites. `kcov` has no local route, so coverage figures were read from the
   CI Cobertura artifacts, which is the required verification model.
2. Caller text: *"CI run 34142466852 at head `12cc5766`: TAP `1..321`, zero `not ok`, `Bash coverage
   (lines): 94.2%`, and per-file `line-rate="1.000"` for `cleanup_worktrees_detached_lib.sh`."*
   Re-derived from source rather than accepted. `gh run view 34142466852 --json` returns
   `conclusion: success`, `headSha: 12cc5766775c4faf172023132b97a199415e9709`. The run log
   contains `1..321`, 321 lines matching `ok <n> `, zero lines matching `not ok `, and the headline
   `Bash coverage (lines): 94.2%`. The run's `shell-coverage` artifact was downloaded and its
   `kcov-merged/cobertura.xml` parsed directly; see section 1.2.1.
3. Caller text: *"the only production edit is operator text inside the `usage()` heredoc"*.
   Confirmed. `git diff 65a56cb9..HEAD -- scripts/` returns a single hunk of five added lines,
   all inside the quoted `usage()` heredoc body. `git diff --name-only 12cc5766..2742c417` outside
   `docs/` is empty, so the head commit is documentation-only and the CI run at `12cc5766` is valid
   evidence for every code and test path at head.

---

## Evidence Location Compliance

**Status: PASS.**

- Diff scan for non-canonical evidence roots:
  `git diff --name-only a36b6dca..2742c417 | grep -E "^artifacts/(baselines|qa|evidence|coverage)/"`
  returned no matches.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited **0** with
  empty output.
- All 47 evidence artifacts on this branch are written under
  `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence/`
  in the canonical `baseline/`, `remediation-baseline/`, `regression-testing/`, `qa-gates/`, and
  `other/` sub-paths.

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose during this review.

---

## Executive Summary

This is the fourth review pass on issue #630 and the first after remediation cycle 1. The prior
audit (`policy-audit.2026-09-07T12-45.md`) returned Conditional Go with two Major blocking findings
and one FAIL coverage verdict. All three are now closed, verified against re-derived evidence rather
than against the executor's reported figures.

**R1 — the two untested delete-eligible verdicts.** `MERGED_CONTENT_NEUTRAL` and `MERGED_EQUIVALENT`
are now each produced by a report-mode case and each drive an apply-mode case through
`remove_detached_worktree` to `ACTION|worktree-remove|/repo-wt/det|OK` with `--force` and
`worktree prune` asserted absent. `MERGED_EQUIVALENT` is produced twice, once at ladder rung 3
(a bare `- <sha>` cherry line) and once at rung 4 (a `+` residual whose touched path holds the same
blob OID on main). `HAS_UNIQUE_RESIDUALS` is produced and its apply-mode non-eligibility asserted.
All three delete-eligible allowlist entries are now proven end-to-end on the destructive path, not
merely named in a report line. **Closed.**

**R2 — the five unexercised fail-closed guards.** Each of the five now has at least one case:
`compute_protected` hard failure (`detached_protection_error`), `CONTENT_NEUTRAL_ERROR`
(`detached_content_neutral_error`), `CHERRY_ERROR` and `DIFF_TREE_ERROR` (`detached_cherry_error`,
two distinct key sets), `RESIDUAL_ERROR` (`detached_residual_error`), and the `((crc != 0))` half of
`reverify_detached_delete_eligible` (driven through `detached_content_neutral_error`). Four of the
five additionally assert the report-mode `ANCESTRY_ERROR` record and a non-zero apply-mode status
with no `worktree remove` argv. **Closed.**

**Coverage FAIL.** The per-file line rate for `scripts/bash/cleanup_worktrees_detached_lib.sh` moved
from 0.806 to **1.000** and the repo-wide bash aggregate from 0.936 (at the merge base) to **0.942**.
Both figures were re-read by this reviewer from the Cobertura XML inside the CI run artifacts, not
taken from the evidence prose. The three modified production files show no per-file regression
against the merge-base baseline. **Closed.**

The three Minor findings (R3, R4, R5) are also closed: the locked case now asserts `$status -ne 0`,
the CLI help case now asserts the record literal `WORKTREE|<path>|DETACHED|<state>|<flags>`, the
apply-mode exit-code change is documented in both `SKILL.md` and the `usage()` heredoc, and
limitation L5 is recorded in `spec.md`.

The remediation introduced no new problem detectable by this review. No executable statement under
`scripts/` changed; the only production edit is five lines of operator text inside a quoted
heredoc, and that text is accurate against the implementation. The four pre-existing bats suites
gained only a `DLIB` sourcing link and appended cases; every pinned assertion enumerated in AC5,
AC6, and AC17 is textually unmodified and passing. `git merge-tree --write-tree` against the
current remote base head `288ca214` exits 0.

One new Minor finding is recorded, and it is a correction of this reviewer's own prior statement.
The AC9 assertion `[[ "$output" != *"merge-base --is-ancestor det00005"* ]]` is **not falsifiable**:
`classify_ancestry` invokes git as `cleanup_wt_git merge-base --is-ancestor "$tip" main >/dev/null
2>&1`, which discards the stub's argv log line, so no `merge-base` line ever reaches `$output`
regardless of whether the probe ran. This reviewer proved it empirically by running report mode
against `detached_merged`, whose `MERGED_CLEAN` verdict can only be produced by that probe, and
observing zero `merge-base` occurrences in the combined output. The prior audit described this
assertion as "the correct falsifiable form for a short-circuit claim," which was wrong. The
underlying behavior is nonetheless correct by inspection —
`classify_detached_head` returns `PROTECTED_CURRENT` at lines 97-98, before the
`classify_ancestry` call at line 102 — and the case's positive assertion is sound, so AC9 remains
PASS. The finding is a test-strength observation, not a defect, and is non-blocking.

**Verdict: COMPLIANT. No blocking findings. Go for PR.**

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Status | Evidence |
|---|---|---|
| Independence | PASS | Every case is self-contained. `setup()` only resolves paths and chmods the stub. No case writes shared state; scenario selection is per-invocation through `CLEANUP_WT_STUB_SCENARIO`. Suites were run individually and in a five-file batch with identical results. |
| Isolation | PASS | Unit cases invoke a single function by name (`is_detached_candidate`, `classify_detached_head`, `reverify_detached_delete_eligible`, `verify_consolidation_merged`); driver cases invoke `run_report` or `run_apply` and assert one behavior each. |
| Fast execution | PASS | The 26-case detached suite completes in the foreground; the five cleanup suites (57 cases) complete together. No sleep, no wall-clock wait, no network. |
| Determinism | PASS | All git access is replayed from checked-in fixture bytes through the `CLEANUP_WT_GIT_BIN` stub. No clock read, no RNG, no ordering dependency. Local run and CI run agree on the TAP plan `1..321`. |
| Readability | PASS | Every new case carries a comment stating which ladder rung or fail-closed branch it drives and why the assertion form was chosen. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|---|---|---|
| Line coverage >= 85% repo-wide (bash) | PASS | 94.2% from CI run 34142466852; `<coverage line-rate="0.942" lines-covered="1773" lines-valid="1882">` read directly from `kcov-merged/cobertura.xml`. |
| Line coverage >= 85% for the new file | PASS | `line-rate="1.000"` for `scripts/bash/cleanup_worktrees_detached_lib.sh`, read from the same Cobertura document. |
| Line coverage >= 85% for modified files | PASS | `cleanup-worktrees.sh` 1.000; `cleanup_worktrees_actions_lib.sh` 0.945; `cleanup_worktrees_lib.sh` 0.944. |
| No regression on changed lines | PASS | Against the merge-base run 34113725852 at `a36b6dca`: `cleanup-worktrees.sh` 1.000 to 1.000; `cleanup_worktrees_actions_lib.sh` 0.928 to 0.945; `cleanup_worktrees_lib.sh` 0.933 to 0.944. Aggregate 0.936 to 0.942. Every delta is non-negative. |
| Branch coverage | Exempt | kcov does not measure branch coverage for bash. Every Cobertura entry carries the fixed placeholder `branch-rate="1.0"`. Per `.claude/rules/quality-tiers.md` and `.claude/rules/shell.md`, no branch threshold applies to bash. Not recorded as FAIL. |
| No production file excluded from measurement | PASS | The kcov include pattern is `$repo_root/tools,$repo_root/scripts,$repo_root/.claude/lib/bash` and the exclude pattern is `$repo_root/tests` (`scripts/bash/shell_qc_lib.sh:335-336`). The new library resolves under `scripts/` and appears as a measured class in the Cobertura output. No exclusion was added or widened by this branch. |
| Positive, negative, edge, and error scenarios | PASS | Seven report-mode verdicts, three destructive-path removals, three non-eligible terminals, six hard-failure fail-closed paths, a flag matrix with eight rows including the empty string, and two consolidation guard shapes. |

### 1.2.1 Per-Language Coverage Comparison

- Bash: Baseline: 93.6% (CI run 34113725852 at merge-base `a36b6dca`, Cobertura `line-rate="0.936"`). Post-change: 94.2% (CI run 34142466852 at `12cc5766`, Cobertura `line-rate="0.942"`). Change: +0.6 percentage points, non-negative. New/changed-code coverage: 100.0% for the added file `scripts/bash/cleanup_worktrees_detached_lib.sh` (Cobertura `line-rate="1.000"`), and 100.0%, 94.5%, 94.4% for the three modified production files, each at or above its merge-base value. Disposition: PASS. Evidence: both `shell-coverage` artifacts were downloaded with `gh api repos/drmoisan/drm-copilot/actions/artifacts/<id>/zip` and their `kcov-merged/cobertura.xml` parsed directly by this reviewer; the figures were not taken from the executor's evidence prose.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|---|---|---|
| Arrange-Act-Assert | PASS | Each case arranges by naming a scenario directory, acts through the `report` or `runin` helper, and asserts on `$output` and `$status`. |
| Descriptive names | PASS | Names state the input condition and the expected verdict, for example `a residual ls-tree hard failure fails closed as ANCESTRY_ERROR`. |
| Actionable failure output | PASS | bats prints the failing expression and the full `$output`, which includes the stub argv log for the non-suppressed git commands. |
| Assertions are falsifiable | PARTIAL | 30 of the 31 new-or-changed cases assert at least one positive condition that can fail. One pre-existing assertion is not falsifiable; see the Minor finding in section 8. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|---|---|---|
| No external services | PASS | All git access is stubbed. The only network call in the production path is the best-effort `fetch` inside `verify_consolidation_merged`, which is stubbed in tests and now runs after the tip-equality pre-check, so the blocked case makes no network call at all. |
| No temporary files | PASS | `grep -nE "mktemp\|BATS_TMPDIR\|BATS_TEST_TMPDIR\|git init"` over `tests/shell/test_cleanup_worktrees_detached.bats` returns no match. All 16 detached scenario directories and the consolidation scenario are tracked in git (`git ls-files`). |
| No mutable global state | PASS | Scenario state is passed per-invocation by environment variable; no case mutates a fixture. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|---|---|---|
| Policy reading order followed | PASS | `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, and `.claude/rules/shell.md` were the governing documents for this review. |
| No policy document modified | PASS | The branch diff touches no path under `.claude/rules/` or `.github/instructions/`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|---|---|---|
| Requirements source identified | PASS | `spec.md` is the sole AC source under `full-bug`; the marker is at `issue.md:12`. Recorded in `evidence/baseline/requirements-source.2026-09-07T11-00.md` and `evidence/remediation-baseline/requirements-source.2026-09-07T15-00.md`. |
| Baseline captured before change | PASS | Merge-base CI coverage run 34113725852, plus a cycle-entry baseline at `65a56cb9`. |

### 2.2 Design Principles

| Principle | Status | Evidence |
|---|---|---|
| Simplicity first | PASS | Six functions, no indirection beyond the existing `cleanup_wt_git` wrapper. The consolidation fix is a 20-line pre-check, not a rewrite. |
| Reusability | PASS | The four existing ladder rungs are reused unchanged against a bare committish. `remove_worktree_safe` is consumed as an opaque contract and is byte-unmodified. |
| Extensibility | PASS | The detached function group lives in its own file so sibling epic children do not collide on the same file regions, as `issue.md` and `spec.md` D-constraints require. |
| Separation of concerns | PASS | Classification (`classify_detached_head`) is separate from emission (`report_detached_worktrees`), from re-verification (`reverify_detached_delete_eligible`), and from the destructive action (`remove_detached_worktree`). |

### 2.3 Module and File Structure

| Requirement | Status | Evidence |
|---|---|---|
| No file over 500 lines | PASS | Largest under `scripts/bash/` is `cleanup_worktrees_lib.sh` at 483. The new `cleanup_worktrees_detached_lib.sh` is 301. `cleanup-worktrees.sh` is 108 after the usage-text addition. |
| Tests mirror source layout | PASS | `tests/shell/test_cleanup_worktrees_detached.bats` for `scripts/bash/cleanup_worktrees_detached_lib.sh`, matching the existing convention for this tool's suites. |
| No colocation of tests in source tree | PASS | No `.bats` file exists under `scripts/`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Descriptive names | PASS | `is_detached_candidate`, `classify_detached_head`, `report_detached_worktrees`, `reverify_detached_delete_eligible`, `remove_detached_worktree`, `apply_detached_worktrees`. |
| Contracts documented | PASS | Every function carries an argument list, a return-code contract, and a rationale for load-bearing ordering. The file header documents the sourcing contract and the git exit-code capture rule. |
| Operator-facing docs updated | PASS | `SKILL.md` documents the five-field record, the state vocabulary, the `BLOCKED-LOCKED` token, the detached apply-mode behavior, the consolidation tip-equality guard, and the apply-mode exit-code change. The `--help` text carries the same four facts. |

### 2.5 After Making Changes — Toolchain Execution

The bash toolchain is format, lint, test. There is no type-check or architecture-boundary stage for
bash in this repository.

| Stage | Command | Result | Evidence |
|---|---|---|---|
| 1 formatting | `sh scripts/bash/shell-qc.sh format` | Rewrote nothing | Executor evidence records byte-identical `git status --porcelain -- tools scripts .claude/lib/bash` listings before and after. This reviewer's independent `check` run at head is the stronger observation: `shfmt -d` produced no diff. |
| 2 lint | `sh scripts/bash/shell-qc.sh check` | Exit 0, empty stdout, empty stderr | Re-run at head `2742c417` by this reviewer. Byte counts of the captured stdout and stderr files were both 0. |
| 3 unit tests | `npx --yes bats tests/shell/test_cleanup_worktrees_detached.bats` | 26 of 26 pass | Re-run at head by this reviewer. |
| 3 unit tests | `npx --yes bats` over the five sibling cleanup suites | 57 of 57 pass | Re-run at head by this reviewer; covers `cli`, `deletion`, `classification`, `hard_failures`, `enumeration`. |
| 3 unit tests, full suite | `npx --yes bats tests/shell/` | Exit 0, TAP `1..321`, 321 `ok`, 0 `not ok` | Re-run in full at head by this reviewer; the local plan line matches CI exactly. Two `BW01` bats advisories are emitted by the pre-existing `test_shell_qc_commands.bats`, which is not in the branch diff; they are non-fatal warnings about `run` exit-code checking, not failures. |
| 3 unit tests, full suite | CI run 34142466852 | TAP `1..321`, 321 `ok`, 0 `not ok` | Run log read directly with `gh run view --log`. |
| 3 + coverage | kcov via `.github/workflows/_shell-coverage.yml` | 94.2% lines | Cobertura XML from the run artifact, parsed by this reviewer. |
| Single clean pass | — | PASS | No stage failed and no stage rewrote a file, so the loop was not restarted. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|---|---|---|
| Behavior change called out | PASS | The apply-mode exit-code change is recorded in `spec.md`, in `SKILL.md`, in the push-down mirror, and in the `--help` text, and is asserted by two tests (`dirty ... BLOCKED-DIRTY` and `locked ... BLOCKED-LOCKED`, both asserting `$status -ne 0`) plus a CLI case asserting the help text names `BLOCKED-REVERIFY`. |
| Known limitations recorded | PASS | `spec.md` records L1 through L5. L5 was added by this cycle and states the detached `COMMIT|` blind spot, its safe failure direction, and its follow-up status. |
| Commit messages describe scope | PASS | Seven commits, each scoped and prefixed (`test(630)`, `fix(630)`, `docs(630)`). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling and Baseline

| Requirement | Status | Evidence |
|---|---|---|
| shfmt formatting clean | PASS | `shell-qc.sh check` runs `shfmt -d` over the discovery roots and produced no diff at head. |
| shellcheck clean | PASS | Same run; shellcheck emitted no finding. |
| `shellcheck source=` directives present | PASS | `cleanup-worktrees.sh` carries `# shellcheck source=scripts/bash/cleanup_worktrees_detached_lib.sh` and `# shellcheck disable=SC1091` for the new source line, matching the two existing source lines. |
| Coverage via kcov | PASS | Run 34142466852; the new file is inside the include pattern. |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|---|---|---|
| Guarded parent-shell capture of every git read | PASS | Traced through all six new functions. `compute_protected`, `classify_ancestry`, `classify_content_neutral`, `classify_cherry_equivalent`, `classify_residual_commit`, and the two consolidation `rev-parse` reads are each captured with `|| rc=$?` or checked by explicit return-code inspection, and each hard failure maps to `ANCESTRY_ERROR` with a non-zero return. |
| Fail closed on hard failure | PASS | No path maps a non-zero git exit to a `MERGED_*` verdict. Six cases now assert this, one per rung plus the protection-set read. |
| No `eval`, no string-built command lines | PASS | All git access routes through `cleanup_wt_git` with separate argv words. Every variable in argument position is double-quoted. |
| Destructive action never forced | PASS | `--force` does not appear anywhere under `scripts/bash/`. `git worktree prune` appears only inside a comment stating it is never invoked. |
| Functions only at source time | PASS | The new library defines functions and runs no work at source time, as its header contract states. Confirmed by the `sourcing the wrapper does not execute main` CLI case and by sourcing the library directly in 26 bats invocations. |

### Section 3D: JSON Configuration Policy Compliance

No JSON configuration file is in the branch diff. Not applicable.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4C: Bash Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| bats is the framework | PASS | All 321 cases are bats. |
| Tests under `tests/shell/` | PASS | The new suite is `tests/shell/test_cleanup_worktrees_detached.bats`. |
| Fixtures checked in, not generated | PASS | 117 fixture data files under `tests/fixtures/cleanup_worktrees/`, all tracked. |
| Seam-driven, no real repository | PASS | `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_STUB_SCENARIO` are the only seams; the stub reads canned bytes and never touches a repository. |
| Negative argv assertions are meaningful | PARTIAL | The `worktree remove`, `--force`, `worktree prune`, and `branch -D` negatives are meaningful, because those commands are invoked without stderr suppression and their stub argv lines demonstrably reach `$output`. The `merge-base --is-ancestor` negative is not; see section 8. |

---

## 5. Test Coverage Detail

### `scripts/bash/cleanup_worktrees_detached_lib.sh` (301 lines, 100.0% line coverage, 26 dedicated tests)

The prior audit recorded 80.6% with 20 uncovered lines. Every one of them is now covered. The
mapping from the previously uncovered regions to the cases that now reach them:

| Previously uncovered lines | Region | Case that now covers it |
|---|---|---|
| 90, 91 | `compute_protected` hard failure to `ANCESTRY_ERROR`, return 2 | `a protection-set hard failure fails closed as ANCESTRY_ERROR` |
| 116, 117 | `MERGED_CONTENT_NEUTRAL` terminal | `report emits MERGED_CONTENT_NEUTRAL for a content-neutral detached HEAD`, `apply removes a content-neutral detached worktree without force` |
| 120, 121 | `CONTENT_NEUTRAL_ERROR` to `ANCESTRY_ERROR` | `a content-neutral probe hard failure fails closed as ANCESTRY_ERROR` |
| 127, 128 | `CHERRY_ERROR` / `DIFF_TREE_ERROR` to `ANCESTRY_ERROR` | `a cherry hard failure fails closed as ANCESTRY_ERROR`, `a diff-tree hard failure fails closed as ANCESTRY_ERROR` |
| 131, 132 | `MERGED_EQUIVALENT` at rung 3 | `report emits MERGED_EQUIVALENT for a cherry-equivalent detached HEAD`, `apply removes a cherry-equivalent detached worktree without force` |
| 141, 142 | `RESIDUAL_ERROR` to `ANCESTRY_ERROR` | `a residual ls-tree hard failure fails closed as ANCESTRY_ERROR` |
| 146, 147 | `CONTENT_ON_MAIN` residual counting | `classify_detached_head returns MERGED_EQUIVALENT when every residual is content-on-main` |
| 152, 153 | `MERGED_EQUIVALENT` at rung 4 | same case |
| 160 | `HAS_UNIQUE_RESIDUALS` terminal | `report emits HAS_UNIQUE_RESIDUALS for a partially incorporated detached HEAD` |
| 190 | `report_detached_worktrees` rc-folding branch | reached as a side effect of the four hard-failure report-mode assertions |
| 212, 213 | `reverify_detached_delete_eligible` hard-failure branch | `reverify_detached_delete_eligible blocks on a classification hard failure` |

The destructive path is now proven for all three allowlist entries. This reviewer independently
drove `run_apply` against `detached_content_neutral` outside bats and observed, in order, the
five-field record `WORKTREE|/repo-wt/det|DETACHED|MERGED_CONTENT_NEUTRAL|detached`, a second
classification pass (the same-process re-verification), the argv line `worktree remove
/repo-wt/det` with no force flag, and `ACTION|worktree-remove|/repo-wt/det|OK`, exiting 0.

### Fixture realism

Each of the eight new scenario directories was checked against the ladder implementation in
`scripts/bash/cleanup_worktrees_lib.sh:53-240` and against the stub's documented key scheme, to
confirm it models a state a real repository can occupy rather than merely satisfying the stub.

| Scenario | Modeled state | Ladder path exercised |
|---|---|---|
| `detached_content_neutral` | HEAD not an ancestor of main but adding no net content, as after a revert pair | rung 1 `NOT_ANCESTOR`, rung 2 `diff --quiet` rc 0 |
| `detached_equivalent` | HEAD whose single commit was cherry-picked onto main | rung 3, cherry `- <sha>`, empty residual list |
| `detached_equivalent_residual` | HEAD with a residual `+` commit whose one touched path holds an identical blob OID on main | rung 4, `CONTENT_ON_MAIN`, unique count 0 |
| `detached_unique_residuals` | HEAD partially incorporated: one equivalent `-` commit and one `+` commit whose path differs on main | rung 5, `MINUS_PRESENT` plus one `UNIQUE` residual |
| `detached_protection_error` | `git rev-parse --abbrev-ref HEAD` exits 128 during protected-set computation | pre-ladder guard |
| `detached_content_neutral_error` | `git diff --quiet main...<head>` exits 128 | rung 2 hard failure |
| `detached_cherry_error` | `git cherry main <head>` exits 128 (det00014); separately, `git diff-tree` exits 128 while probing a `+` commit (det00015) | rung 3 hard failures, both variants |
| `detached_residual_error` | `git ls-tree main -- <path>` exits 128 while resolving a `D` residual | rung 4 D-rung hard failure |

The blob OIDs (`blobSAME` versus `blobA`/`blobB`) and the cherry marker lines are consistent with
what real git output would carry for each shape. The one deviation from one-directory-one-state
purity is `detached_cherry_error`, which hosts a second key set (`det00015`) whose worktree is
deliberately absent from that scenario's `worktree-list.out`; the test comment documents why (the
stub answers `cherry` from a single key per sha, so one directory cannot make both `cherry` and
`diff-tree` fail for the same sha). This is recorded as an Info-level observation, not a defect.

### `scripts/bash/cleanup_worktrees_actions_lib.sh` — `verify_consolidation_merged` tip-equality pre-check (3 tests)

Unchanged since the prior audit and still correct. The `consolidated_zero_commit` fixture sets
`merge-base.documentationandmemories.rc` to 0, so the pre-existing ancestry check would report
`MERGED_CLEAN`; the tip-equality pre-check wins and reports `NOT_ANCESTOR`. That fixture design is
what makes the guard's precedence falsifiable rather than assumed.

### Modified files — per-file post-change coverage

| File | Merge-base line rate | Post-change line rate | Delta |
|---|---|---|---|
| `scripts/bash/cleanup-worktrees.sh` | 1.000 | 1.000 | 0.000 |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 0.928 | 0.945 | +0.017 |
| `scripts/bash/cleanup_worktrees_lib.sh` | 0.933 | 0.944 | +0.011 |
| `scripts/bash/cleanup_worktrees_detached_lib.sh` | not present | 1.000 | new file |

---

## 6. Test Execution Metrics

| Metric | Value | Source |
|---|---|---|
| Total bats cases at head | 321 | CI run 34142466852 TAP plan `1..321`; local `npx --yes bats tests/shell/` reports the same plan line |
| Cases at merge base | 290 | CI run 34113725852 TAP plan `1..290` |
| Net new cases on the branch | 31 | 26 in the new detached suite, 3 consolidation cases in `deletion.bats`, 2 CLI help cases |
| Cases added by remediation cycle 1 | 13 | 12 appended to `detached.bats`, 1 appended to `cli.bats` |
| Failures | 0 | Zero lines matching `not ok ` in the CI log; zero in every local run |
| Suites re-run locally at head by this reviewer | all of `tests/shell/` | Full run: exit 0, `1..321`, 321 `ok`, 0 `not ok`. Targeted runs first: detached (26), cli (7), deletion (9), classification (8), hard_failures (21), enumeration (12) |
| Repo-wide bash line coverage | 94.2% | Cobertura `line-rate="0.942"`, 1773 of 1882 lines |

---

## 7. Code Quality Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Read the full new library and every diff hunk. No credential, token, key, or environment secret is read, written, or logged. All fixture data is synthetic (`det00001`-`det00016`, `aaaa0000`, `blobA`/`blobB`/`blobSAME`). |
| No unsafe subprocess or command construction | PASS | All git access routes through `cleanup_wt_git` with separate argv words. No `eval`, no unquoted expansion in command position. |
| Destructive action is gated | PASS | Removal requires `is_detached_candidate` true, state on the three-token allowlist, not locked, not prunable, and a fresh same-process re-classification still on the allowlist. Any failure at any gate returns 1 and performs no removal. |
| All three allowlist entries proven on the destructive path | PASS | `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, and `MERGED_EQUIVALENT` each drive an apply-mode case to `ACTION|worktree-remove|...|OK`. This was the prior audit's first Major finding. |
| Fail-closed branches are tested | PASS | All six hard-failure branches (five named in the prior finding, plus the already-covered rung-1 `merge-base` failure) now have at least one asserting case. This was the prior audit's second Major finding. |
| Protection of the caller's own worktree | PASS | Decided by normalized path against `compute_protected`'s protected-path records; `classify_detached_head` returns at lines 97-98 before the rung-1 call at line 102. The `detached_current` case asserts the `PROTECTED_CURRENT` record and that apply mode emits no `ACTION|worktree-remove`. The case's third assertion, on the absence of a `merge-base` argv line, is not falsifiable; see section 8. |
| Main worktree is never a candidate | PASS | `is_detached_candidate` returns non-zero for any flag set containing `main` or `bare`, asserted by three rows of the flag matrix and by the negative assertion in the first report case. |
| Input validation at boundaries | PASS | Empty flag sets, empty records, and empty `rev-parse` results are all handled explicitly. The consolidation pre-check treats an empty tip on either side as a hard failure rather than an equality match, and `verify_consolidation_merged fails closed on an empty rev-parse` asserts it. |
| Error handling remains explicit | PASS | Every git-backed read is parent-shell captured and fails closed. No broad catch-all. No silent degradation. |
| Push-down mirror parity | PASS | `git hash-object` on `.claude/skills/cleanup-merged-worktrees/SKILL.md` and its bundled mirror both return `123aa988ebd7af19108d0022ae533115c5bf7c74`. |
| Modified-workflow-needs-green-run rule | Not triggered | The branch diff contains no path matching `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`. |
| Integration conflict pre-check | PASS | `git merge-tree --write-tree origin/epic/cleanup-merged-worktrees-hardening-integration HEAD` exits 0 against the current remote base head `288ca2148d159bf2f7a1cbfff6bad3ee5c8d791b`. |

---

## 8. Gaps and Exceptions

### Identified Gaps

**G1 (Minor, non-blocking, new; supersedes a prior-audit statement).** The assertion
`[[ "$output" != *"merge-base --is-ancestor det00005"* ]]` in
`tests/shell/test_cleanup_worktrees_detached.bats` (the `the caller's own detached worktree is
PROTECTED_CURRENT` case, named by AC9) cannot fail. `classify_ancestry` invokes git as
`cleanup_wt_git merge-base --is-ancestor "$tip" main >/dev/null 2>&1`
(`scripts/bash/cleanup_worktrees_lib.sh:65`), which routes the stub's `stub-git: ` argv line to
`/dev/null`, so no `merge-base` string can reach `$output` in any scenario. This reviewer proved it
by running report mode against `detached_merged` outside bats: the verdict `MERGED_CLEAN` for
`det00001` can only be produced by that probe, yet the combined stdout and stderr contains zero
occurrences of `merge-base`. The prior audit called this assertion "the correct falsifiable form
for a short-circuit claim," which was incorrect and is corrected here.

Impact: the short-circuit claim in AC9 is verified by code inspection, not by test. The behavior
itself is correct — `classify_detached_head` returns `PROTECTED_CURRENT` at lines 97-98 before the
`classify_ancestry` call at line 102 — and the case's positive assertion on the
`PROTECTED_CURRENT` record is sound and would fail if protection regressed. Remediation is not
required. A falsifiable substitute, if the team wants one later, is to give `detached_current` a
`merge-base.det00005.rc` of `0` and assert that the record is `PROTECTED_CURRENT` rather than
`MERGED_CLEAN`: reaching the ancestry rung would then change the verdict, which is observable.

**G2 (Info).** `detached_cherry_error` hosts two key sets in one directory, and the second
(`det00015`) has no entry in that scenario's `worktree-list.out`. The deviation from
one-directory-one-repository-state is documented in the test comment and is forced by the stub's
one-key-per-sha answering scheme. No action.

**G3 (Info).** `report_detached_worktrees` and `apply_detached_worktrees` share an eight-line
iterate-classify-emit preamble. The duplication is deliberate: apply mode must retain the verdict
it emitted in order to decide removal from that same verdict, and the file header states so. No
action.

**G4 (Info).** `scripts/bash/cleanup_worktrees_lib.sh` stands at 483 of the 500-line cap. This is
pre-existing and was the stated reason the detached function group ships in a new file. Sibling
epic children extending the same library should watch the margin.

### Approved Exceptions

**E1 — kcov branch coverage.** kcov does not measure branch coverage for bash. The
`branch-rate="1.0"` attributes in the Cobertura output are fixed placeholders, not measurements.
`.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md` exempt bash from the
branch threshold on exactly this basis. No branch figure is reported and no branch FAIL is
recorded. The exemption is a threshold exemption only; all four production bash files remain in
the coverage denominator.

**E2 — coverage regenerated in CI rather than locally.** `kcov` has no route on this Windows
worktree. The coverage figures come from `.github/workflows/_shell-coverage.yml` runs whose head
SHAs were verified with `gh run view --json headSha`, and whose Cobertura artifacts were downloaded
and parsed by this reviewer. This is the inspection-of-existing-artifacts model the reviewer
contract requires, not a substitution.

**E3 — no failing-run evidence for this remediation cycle.** R1 and R2 added coverage over behavior
that was already correct, so no deterministically failing run could exist. The executor recorded a
fail-before exception dossier with an absence-of-test proof
(`git grep -nE "MERGED_CONTENT_NEUTRAL|MERGED_EQUIVALENT|HAS_UNIQUE_RESIDUALS" -- tests/shell/test_cleanup_worktrees_detached.bats`
exiting 1 with empty output before the cycle). This reviewer re-ran that grep against commit
`65a56cb9` and confirmed exit 1 with no output. Accepted.

**E4 — one pre-existing local test failure, unrelated.** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
fails locally on an untracked, gitignored `.claude/state/` file (issue #510) and is green in CI.
AC21 was verified by the stronger check instead: `git hash-object` on both SKILL.md paths returns
the identical OID `123aa988ebd7af19108d0022ae533115c5bf7c74`.

### Removed/Skipped Tests

None. No test was removed, renamed, or skipped by this branch. Every pinned assertion enumerated in
AC5, AC6, and AC17 is textually unmodified; the only changes to the four pre-existing suites are an
added `DLIB` path variable, an added `source '${DLIB}'` link in the helper chains, and appended
cases.

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
| `12cc5766` | test(630): cover the untested delete-eligible verdicts and fail-closed guards |
| `2742c417` | docs(630): record Phase 6 remediation evidence and check off tasks |

The last two commits are remediation cycle 1. `12cc5766` carries all fixture, test, documentation,
and usage-text changes; `2742c417` is documentation-only, so the CI coverage run at `12cc5766` is
valid evidence for head.

### Files Modified

| Category | Count | Detail |
|---|---|---|
| Production shell, new | 1 | `scripts/bash/cleanup_worktrees_detached_lib.sh`, 301 lines |
| Production shell, modified | 3 | one `source` line plus 17 lines of usage text in `cleanup-worktrees.sh`; a 20-line tip-equality pre-check plus a skip guard and driver call in `cleanup_worktrees_actions_lib.sh`; a contract comment plus a skip guard and driver call in `cleanup_worktrees_lib.sh` |
| Test suites, new | 1 | `tests/shell/test_cleanup_worktrees_detached.bats`, 319 lines, 26 cases |
| Test suites, modified | 4 | `classification`, `cli`, `deletion`, `hard_failures`; sourcing links plus 5 appended cases |
| Fixture data | 117 | 16 detached scenario directories, 1 consolidation scenario, 4 added `rev-parse` keys on 2 existing consolidation fixtures |
| Documentation | 65 | `SKILL.md` and its push-down mirror, `spec.md`, plan and remediation plan, 47 evidence artifacts, 4 prior review artifacts |

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT

### Policy-by-Policy Summary

| Policy | Verdict | Note |
|---|---|---|
| `.claude/rules/general-code-change.md` | PASS | Design principles, file-size cap, fail-fast error handling, naming, and behavior-change documentation all satisfied. |
| `.claude/rules/general-unit-test.md` | PASS | Five core principles satisfied; coverage above threshold with no regression; no temp files; no excluded production file. One non-falsifiable pre-existing assertion is recorded as G1 and does not affect any verdict. |
| `.claude/rules/quality-tiers.md` | PASS | Line coverage 94.2% against the uniform 85% floor. Branch threshold does not apply to bash. |
| `.claude/rules/shell.md` | PASS | shfmt and shellcheck clean; bats suite green; kcov coverage above floor; toolchain completed in one pass. |
| `.claude/rules/tonality.md` | PASS | All authored documentation is factual and measured. |
| Evidence location conventions | PASS | Validator exit 0; no non-canonical evidence path in the diff. |
| `modified-workflow-needs-green-run` | Not triggered | No workflow, action, or benchmark path in the diff. |

### Metrics Summary

| Metric | Value | Threshold | Verdict |
|---|---|---|---|
| Bash line coverage, repo-wide | 94.2% | >= 85% | PASS |
| Bash line coverage, new file | 100.0% | >= 85% | PASS |
| Bash line coverage, modified files | 100.0% / 94.5% / 94.4% | >= 85% and no regression | PASS |
| Bash branch coverage | not measurable | exempt | Exempt |
| bats failures | 0 of 321 | 0 | PASS |
| shfmt diffs | 0 | 0 | PASS |
| shellcheck findings | 0 | 0 | PASS |
| Largest file under `scripts/bash/` | 483 lines | <= 500 | PASS |
| Blocking code-review findings | 0 | 0 | PASS |
| Acceptance criteria PASS | 24 of 24 | 24 of 24 | PASS |

### Recommendation

**Go.** Remediation cycle 1 closed both Major findings in substance, not by line count, and closed
the coverage FAIL with figures this reviewer re-derived from the CI Cobertura artifacts rather than
from the evidence prose. No blocking finding remains, so no `remediation-inputs` artifact is
produced by this pass. The branch is ready for a PR against
`epic/cleanup-merged-worktrees-hardening-integration`.

---

## Appendix A: Test Inventory

### Cases added by remediation cycle 1 (13)

In `tests/shell/test_cleanup_worktrees_detached.bats`:

1. `report emits MERGED_CONTENT_NEUTRAL for a content-neutral detached HEAD`
2. `apply removes a content-neutral detached worktree without force`
3. `report emits MERGED_EQUIVALENT for a cherry-equivalent detached HEAD`
4. `apply removes a cherry-equivalent detached worktree without force`
5. `report emits HAS_UNIQUE_RESIDUALS for a partially incorporated detached HEAD`
6. `classify_detached_head returns MERGED_EQUIVALENT when every residual is content-on-main`
7. `a protection-set hard failure fails closed as ANCESTRY_ERROR`
8. `a content-neutral probe hard failure fails closed as ANCESTRY_ERROR`
9. `a cherry hard failure fails closed as ANCESTRY_ERROR`
10. `a diff-tree hard failure fails closed as ANCESTRY_ERROR`
11. `a residual ls-tree hard failure fails closed as ANCESTRY_ERROR`
12. `reverify_detached_delete_eligible blocks on a classification hard failure`

In `tests/shell/test_cleanup_worktrees_cli.bats`:

13. `--help documents the apply-mode exit-code change for blocked detached removals`

One existing case, `locked detached worktree yields BLOCKED-LOCKED and invokes no removal`, gained
`[ "$status" -ne 0 ]`; one existing case, `--help documents the detached worktree record`, gained
an assertion on the record literal.

### New fixture inventory (cycle 1)

`tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral/`,
`.../detached_content_neutral_error/`, `.../detached_equivalent/`,
`.../detached_equivalent_residual/`, `.../detached_unique_residuals/`,
`.../detached_cherry_error/`, `.../detached_residual_error/`,
`.../detached_protection_error/`. Eight directories, 63 files, all tracked in git.

---

## Appendix B: Toolchain Commands Reference

### Bash (the in-scope language)

```bash
# Formatting (stage 1)
sh scripts/bash/shell-qc.sh format

# Linting: shfmt -d + shellcheck (stage 2)
sh scripts/bash/shell-qc.sh check

# Unit tests (stage 3)
npx --yes bats tests/shell/

# Unit tests with kcov line coverage (stage 3 + coverage)
bash scripts/bash/shell-qc.sh test --coverage
# Coverage headline literal: `Bash coverage (lines): NN.N%`
# Cobertura report: shell-coverage/kcov-merged/cobertura.xml (CI artifact)
# kcov include pattern: $repo_root/tools,$repo_root/scripts,$repo_root/.claude/lib/bash
# kcov exclude pattern: $repo_root/tests
#   (scripts/bash/shell_qc_lib.sh:335-336)
```

### Commands actually executed by this reviewer

```bash
# Base/diff resolution
git merge-base HEAD origin/epic/cleanup-merged-worktrees-hardening-integration
git diff --name-status a36b6dca7809e456f00c7d5b01eec5da49f7fca0..HEAD
git diff --shortstat a36b6dca7809e456f00c7d5b01eec5da49f7fca0..HEAD
git diff 65a56cb9..HEAD -- scripts/
git diff --name-only 12cc5766..2742c417 -- . ':(exclude)docs/**'

# PR context refresh (artifacts were stale at 65a56cb9; regenerated at head)
poetry run python -m scripts.dev_tools.pr_context.collector \
  --base epic/cleanup-merged-worktrees-hardening-integration --head HEAD --repo-root .

# Lint / format gate, re-run at head
sh scripts/bash/shell-qc.sh check          # exit 0, 0 bytes stdout, 0 bytes stderr

# Tests, re-run locally at head
npx --yes bats tests/shell/                                             # exit 0, 1..321, 321 ok, 0 not ok
npx --yes bats tests/shell/test_cleanup_worktrees_detached.bats          # 26/26
npx --yes bats tests/shell/test_cleanup_worktrees_cli.bats \
              tests/shell/test_cleanup_worktrees_deletion.bats \
              tests/shell/test_cleanup_worktrees_classification.bats \
              tests/shell/test_cleanup_worktrees_hard_failures.bats \
              tests/shell/test_cleanup_worktrees_enumeration.bats       # 57/57

# Independent driver runs outside bats (destructive-path confirmation and
# argv-log observability probe)
#   run_apply against detached_content_neutral   -> OK, no force, exit 0
#   run_report against detached_merged           -> MERGED_CLEAN, 0 merge-base argv lines

# CLI contract
sh scripts/bash/cleanup-worktrees.sh --help     # exit 0; record literal and BLOCKED-REVERIFY present

# File-size cap
wc -l scripts/bash/*.sh                          # max 483

# Rejected guard forms
grep -rn "rev-list --count" scripts/bash/        # no match
grep -rn -- "--force" scripts/bash/              # no match
grep -rn "worktree prune" scripts/bash/          # comment only

# Push-down mirror parity
git hash-object .claude/skills/cleanup-merged-worktrees/SKILL.md \
  extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md

# Evidence locations
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .   # exit 0

# Temp-file prohibition in the new suite
grep -nE "mktemp|BATS_TMPDIR|BATS_TEST_TMPDIR|git init" tests/shell/test_cleanup_worktrees_detached.bats

# Absence-of-test proof for the fail-before exception, re-run at the cycle-entry commit
git grep -nE "MERGED_CONTENT_NEUTRAL|MERGED_EQUIVALENT|HAS_UNIQUE_RESIDUALS" 65a56cb9 \
  -- tests/shell/test_cleanup_worktrees_detached.bats                          # exit 1, no output

# CI coverage run verification and artifact parsing
gh run view 34142466852 --json headSha,conclusion,headBranch
gh run view 34142466852 --log
gh api repos/drmoisan/drm-copilot/actions/artifacts/10026546424/zip   # post-change
gh api repos/drmoisan/drm-copilot/actions/artifacts/10015570663/zip   # merge-base baseline

# Integration-conflict pre-check against the current base head
git fetch origin epic/cleanup-merged-worktrees-hardening-integration
git merge-tree --write-tree origin/epic/cleanup-merged-worktrees-hardening-integration HEAD  # exit 0
```

### Not applicable to this branch (zero changed files)

```bash
# TypeScript
npm run test:unit:coverage
# Python
poetry run pytest --cov
# PowerShell
Invoke-Pester -CodeCoverage
# C#
dotnet test --collect:"XPlat Code Coverage"
```

---

## Template Resolution Note

No MCP tool is exposed to this reviewer session. The identical bundled assets were read directly
from the path that `resolve_policy_audit_template_asset` resolves,
`extensions/drm-copilot/resources/templates/policy_audit/`, and the artifact structure follows the
canonical major headings and the Appendix B command reference. Artifact validation was performed
with `poetry run python scripts/dev_tools/validate_orchestration_artifacts.py`.
