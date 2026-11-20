# Policy Compliance Audit: cleanup-worktrees report-mode visibility gaps (Issue #631)

**Audit Date:** 2026-09-07
**Code Under Test:** Bash only. `scripts/bash/cleanup_worktrees_report_records_lib.sh` (new, 463 lines), `scripts/bash/cleanup_worktrees_scan_helper.sh` (new, 157 lines), `scripts/bash/cleanup_worktrees_lib.sh` (modified, 491 lines), `scripts/bash/cleanup_worktrees_actions_lib.sh` (modified, 417 lines), `scripts/bash/cleanup-worktrees.sh` (modified, 128 lines), `tests/fixtures/cleanup_worktrees/stub-bin/git` (modified), `tests/fixtures/cleanup_worktrees/stub-bin/scan` (new), 8 `tests/shell/*.bats` files, ~60 checked-in fixture files, `.claude/skills/cleanup-merged-worktrees/SKILL.md` + its extension mirror, and feature-folder documentation.

**Base branch:** `origin/epic/cleanup-merged-worktrees-hardening-integration` @ `6dff80ed4596bec088d548b23013e6077e32c484`
**Head:** `local-work-631-r2` (alias of `bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`) @ `02ce5eec8c7a8178e8ad4317b69d1c62afe0f284`
**Merge base:** `6dff80ed4596bec088d548b23013e6077e32c484`
**Diff size:** 85 files changed, 1346 insertions, 83 deletions.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Bash | 7 script/fixture-executable files + 8 bats files | 335 tests | PASS 335 pass, 0 fail | 94.2% lines | 93.4% lines | `cleanup_worktrees_report_records_lib.sh` 89.0% lines; `cleanup_worktrees_scan_helper.sh` 86.8% lines |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed files | N/A - zero changed files | N/A |
| Python | 0 files | N/A | N/A | N/A - zero changed files | N/A - zero changed files | N/A |
| PowerShell | 0 files | N/A | N/A | N/A - zero changed files | N/A - zero changed files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed files | N/A - zero changed files | N/A |

Bash is the only language with changed files in the branch diff. Verified with
`git diff --name-only <base>..HEAD | sed 's/.*\.//' | sort | uniq -c` — the extension
census returns only `.sh`, `.bats`, `.md`, and fixture data extensions (`.out`, `.rc`,
`.gitkeep`) plus the two extensionless stub binaries. No `.ts`, `.tsx`, `.py`, `.ps1`,
`.psm1`, or `.cs` file appears in the diff.

**Bash coverage verdict: PASS.** Repo-wide bash line coverage at the head SHA is 93.4%,
above the uniform 85% floor in `.claude/rules/quality-tiers.md`. Both new files are above
the floor. Bash has no branch-coverage gate (kcov does not measure branch coverage), per
`.claude/rules/shell.md` and `.claude/rules/quality-tiers.md`.

### Coverage Evidence Checklist

- Bash baseline coverage artifact: `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/baseline/baseline-test-coverage.2026-09-06T23-03.md` (94.2% lines, CI run 34148603116, pre-change tree)
- Bash post-change coverage artifact: **not present on disk in the feature folder.** Recovered by the auditor from GitHub Actions run `34151370364` (head SHA `02ce5eec8c7a8178e8ad4317b69d1c62afe0f284`), job "Shell Coverage (Bats + kcov)", step "Run shell-qc test with coverage", which prints the literal line `Bash coverage (lines): 93.4%`, and from the uploaded `shell-coverage` artifact's `cov.xml` for per-file rates. The plan's Phase 11 evidence artifacts (`evidence/qa-gates/final-format|check|test|test-coverage.*.md`) do not exist.
- TypeScript baseline/post-change coverage artifacts: `N/A - zero changed files`
- PowerShell baseline/post-change coverage artifacts: `N/A - zero changed files`
- Python baseline/post-change coverage artifacts: `N/A - zero changed files`
- C# baseline/post-change coverage artifacts: `N/A - zero changed files`
- Per-language comparison summary: section 1.2.1 below.

**Fail-closed application:** the overall verdict below is NOT PASS. The reason is a
behavioral defect proven by direct execution (section 8, Gap G1), not a missing artifact.
The missing post-change coverage artifact is recorded separately as Gap G7.

---

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope to a plan, task, phase, file
subset, or to mark a language's coverage as out of scope. The delegating prompt explicitly
stated: "Scope determination (which files/languages are in scope) is your responsibility
based on the branch diff; do not accept any narrowing."

One caller instruction constrained method rather than scope, and is recorded here for
transparency:

> "Bash-toolchain evidence you should treat as canonical and NOT re-dispatch unless you find
> code changes are needed: GitHub Actions workflow_dispatch run 34151370364 on commit
> 02ce5eec8c7a8178e8ad4317b69d1c62afe0f284 concluded 'success' ..."

This is consistent with the feature-review-workflow instruction to inspect pre-existing
coverage artifacts rather than regenerate them, so it was followed. The auditor additionally
and independently: (a) verified the run's head SHA, conclusion, and per-step conclusions via
`gh run view 34151370364 --json ...`; (b) extracted the coverage percentage and the bats
plan/pass tallies from the run log; (c) downloaded the `shell-coverage` artifact and parsed
per-file line rates from `cov.xml`; and (d) ran `shfmt -d` and `shellcheck -x` locally over
every changed shell file. No narrowing was accepted.

---

## Evidence Location Compliance

**PASS.** No file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or
`artifacts/coverage/` appears in the branch diff (verified with
`git diff --name-only <base>..HEAD | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'`,
no matches). All feature evidence is written under
`docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/`
in the canonical `baseline/`, `qa-gates/`, and `other/` subfolders.

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exits 0 with no
output.

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events occurred: no delegation prompt specified a
non-canonical evidence path.

---

## Executive Summary

The change adds four additive report-mode record types (`ORPHAN_DIR`, `STALE_REF`,
`CHILD_OF`, `WARN|registration-lost`) to the `cleanup-worktrees` bash tool, introduces a new
sibling library and a filesystem-scan override seam, and replaces the independent per-branch
classification loops in `run_report` and `run_apply` with a shared `classify_all_branches`
driver.

Toolchain hygiene is clean: `shfmt -d` and `shellcheck -x` return exit 0 on every changed
shell file, the full bats suite is 335/335 green at the head SHA, and repo-wide bash line
coverage is 93.4%, above the 85% floor. Documentation, the SKILL.md byte-identical mirror,
the 500-line cap, evidence locations, and the no-automatic-deletion constraint are all
satisfied.

The audit does not pass because of one behavioral defect. The `CHILD_OF` short-circuit is
implemented as "X is a git ancestor of Y and Y resolved `NOT_MERGED`, therefore X is
`NOT_MERGED`". That inference is unsound: a branch already merged into `main` is a git
ancestor of `main` and therefore also a git ancestor of every branch that descends from
`main`, including unmerged ones. The auditor constructed such a scenario against the
checked-in git stub and executed both the pre-change and post-change code paths. Pre-change,
the merged branch resolves `MERGED_CLEAN` and apply mode emits
`ACTION|branch-delete|feature-merged|OK`. Post-change, the same branch resolves `NOT_MERGED`
with a `CHILD_OF` line and apply mode emits no deletion action at all. This violates the
outcome-preservation invariant that spec.md declares as hard, in both of its stated
properties, and suppresses the tool's primary function whenever an unmerged descendant
branch exists — which is the normal state of a working repository. Full reproduction is in
section 8, Gap G1, and in `code-review.2026-09-07T14-49.md`.

A second, smaller cluster of findings concerns performance and robustness: the filesystem
scan is executed twice per report, computes `du -sh` for every candidate directory including
live worktrees, and the pairwise ancestry probe is O(n^2) git subprocess spawns — all in a
change whose stated motivation for gap 9c was reducing report-mode runtime, with no runtime
measurement recorded.

**Policy documents evaluated:**
- PASS `CLAUDE.md`
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- N/A `python-code-change` + `python-unit-test` (zero changed Python files)
- N/A `powershell-code-change` + `powershell-unit-test` (zero changed PowerShell files)
- N/A `typescript-code-change` + `typescript-unit-test` (zero changed TypeScript files)
- N/A `csharp-code-change` + `csharp-unit-test` (zero changed C# files)
- PARTIAL Bash: `.claude/rules/shell.md` (shfmt + shellcheck + bats + kcov). Toolchain clean;
  error-path test coverage incomplete (Gap G6).
- N/A JSON: no governed JSON file changed.

**Temporary artifacts cleanup:**
- PASS No throwaway script was added to the repository by this change. The two new
  non-test scripts (`cleanup_worktrees_report_records_lib.sh`,
  `cleanup_worktrees_scan_helper.sh`) are permanent, sourced/invoked production code and both
  carry bats coverage.
- Auditor-created probe scripts used to reproduce Gap G1 were written to the session
  scratchpad only and are not part of the repository or of this branch.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Every bats test is driven through a `setup()`-scoped helper (`rr()`, `cb()`, `classify_all()`, `report()`, `apply()`, `runin()`) that sets `CLEANUP_WT_GIT_BIN`, `CLEANUP_WT_SCAN_BIN`, and `CLEANUP_WT_STUB_SCENARIO` per invocation and runs the code in a fresh `bash -c` subshell. No test writes shared state; the stubs are pure replayers that "never touch a real repository and write nothing to disk" (`tests/fixtures/cleanup_worktrees/stub-bin/git:2-4`, `.../scan:2-4`). |
| **Isolation** - Each test targets single behavior | PASS | The six new tests in `test_cleanup_worktrees_report_records.bats` each drive exactly one scan function under one scenario. `test_cleanup_worktrees_scan_seam.bats` pins the two branches of `cleanup_wt_scan_bin` separately. The `CHILD_OF` tests drive `classify_all_branches` directly (`test_cleanup_worktrees_classification.bats:28-35`) rather than through `run_report`, isolating the short-circuit from report formatting. |
| **Fast Execution** - Tests complete quickly | PASS | CI job "Shell Coverage (Bats + kcov)" step "Run shell-qc test with coverage" ran 335 tests in 4m59s wall clock (18:23:15Z to 18:28:15Z) under kcov instrumentation, which dominates the runtime. |
| **Determinism** - Consistent results | PASS | Every git read routes through the `CLEANUP_WT_GIT_BIN` stub seam and every filesystem read routes through the new `CLEANUP_WT_SCAN_BIN` seam, both replaying checked-in canned data. `test_cleanup_worktrees_scan_helper.bats` drives the real helper against the checked-in fixture tree `tests/fixtures/cleanup_worktrees/scan_roots/basic/` using the `CLEANUP_WT_SCAN_GITFILE_NAME` seam. No clock, RNG, network, or sleep is used. |
| **Readability & Maintainability** - Clear structure | PASS | Every new `@test` carries a comment stating the scenario and the expected outcome, including why the positive `STALE_REF` fixture deliberately names the remote `upstream` rather than `child` (`test_cleanup_worktrees_report_records.bats:31-33`) and why `classify_all()` deliberately omits `2>/dev/null` (`test_cleanup_worktrees_classification.bats:29-33`). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline (pre-development):** 94.2% lines.<br>**Command:** `bash scripts/bash/shell-qc.sh test --coverage` dispatched as CI run 34148603116 on the pre-change tree.<br>**Artifact:** `evidence/baseline/baseline-test-coverage.2026-09-06T23-03.md`. |
| **No Coverage Regression** | PASS | **Post-change coverage:** 93.4% lines (`Bash coverage (lines): 93.4%`, CI run 34151370364 log, head SHA `02ce5ee`).<br>**Change:** -0.8 percentage points repo-wide.<br>**Status:** Above the 85% floor. The decrease is attributable to the 30 uncovered error-handling lines in the two new files (Gap G6), not to a loss of coverage on pre-existing lines: `cleanup_worktrees_lib.sh` is 93.4% and `cleanup_worktrees_actions_lib.sh` 93.9% post-change. No changed-line regression identified. |
| **New Code Coverage** | PASS | **New files:** `scripts/bash/cleanup_worktrees_report_records_lib.sh` 186/209 instrumented lines = 89.0%; `scripts/bash/cleanup_worktrees_scan_helper.sh` 46/53 = 86.8%.<br>**Calculation method:** parsed per-`<class>` `line-rate` and `hits="0"` line elements from `cov.xml` in the `shell-coverage` artifact of CI run 34151370364.<br>Both exceed the uniform 85% floor in `.claude/rules/quality-tiers.md`. Note: this repository's authoritative threshold for new code is 85%, not 90%; `quality-tiers.md` states "Tier-specific lower coverage thresholds are not used" and sets one uniform 85% line floor. Under a 90% new-file reading both files would fall short, so this is recorded explicitly rather than silently. |
| **Comprehensive Coverage** | PARTIAL | Every new function carries at least one direct or driver-level test: `cleanup_wt_scan_bin` (2 tests), `scan_stale_refs` (2), `scan_orphan_dirs` (2), `scan_registration_loss` (2), `classify_all_branches` (4 + 1 apply-mode), `scan_helper_*` (1 combined). **Untested:** `cleanup_wt_scan_roots`'s `CLEANUP_WT_ORPHAN_ROOTS` override branch (lines 124-129) and its `parse_worktree_list`-failure branch (135); `cleanup_wt_protected_branches`'s two hard-failure returns (292, 303); `cleanup_wt_scan_records`'s non-executable `bash "$bin"` fallback (173) and scan-failure return (176-177); the `scan_stale_refs` git-failure returns (81-82, 86-87); the phase-2b classify failure propagation (453); and in the helper, the `du`-failure `unknown` path (54), the production default pointer-file name `.git` (69), the empty-target path (88-89), and the usage/bad-subcommand path (127, 145-146). See Gap G6. |
| **Positive Flows** - Valid inputs | PASS | Positive cases: `scan_stale_refs` emits `STALE_REF|refs/remotes/upstream/feature-old`; `scan_orphan_dirs` emits `ORPHAN_DIR|.claude/worktrees/agent-old|128K`; `scan_registration_loss` emits `WARN|registration-lost|/repo-wt/half-gone`; `classify_all_branches` emits `BRANCH|feature-child|NOT_MERGED` + `CHILD_OF|feature-child|feature-parent`; `cleanup_wt_scan_bin` returns the override. **Total positive tests:** 7. |
| **Negative Flows** - Invalid inputs | PASS | Negative pairs exist for all three scan records (remote exists; directory registered; pointer resolves) and for `CHILD_OF` (ancestor resolves `MERGED_EQUIVALENT`, so no short-circuit and `cherry main feature-child` is observed in the argv log). **Total negative tests:** 4. |
| **Edge Cases** - Boundary conditions | PARTIAL | Covered: the `for-each-ref` pattern-specificity edge (a `refs/remotes/`-scoped read must not replay `refs/heads/` data) is exercised by the `stale_ref_*` fixtures supplying both `for-each-ref.out` and `for-each-ref.refs_remotes_.out`. **Not covered:** the `ORPHAN_DIR|<path>|unknown` unresolvable-size case and the unreadable-`.git`-file case, both named as required edge cases in spec.md's Test Strategy. |
| **Error Handling** - Error paths | PARTIAL | Covered: `child_of_ancestry_probe_error` proves a `merge-base` exit 128 maps to `BRANCH|feature-child|ANCESTRY_ERROR` with a non-zero driver return (`test_cleanup_worktrees_classification.bats:183-190`). **Not covered:** the `scan_stale_refs` `for-each-ref`/`remote` hard-failure returns and the `cleanup_wt_scan_records` scan-failure return, all of which are unhit per `cov.xml`. |
| **Concurrency** - If applicable | N/A | The tool is a single-process, sequential shell driver with no concurrency. |
| **State Transitions** - If applicable | PARTIAL | The classification state machine is the relevant state model. The new driver's two-phase transition is tested for the `NOT_MERGED` inheritance path and the `MERGED_EQUIVALENT` non-inheritance path, but not for the transition that this audit proves is wrong: a `MERGED_CLEAN` branch that is an ancestor of a `NOT_MERGED` branch (Gap G1). |

### 1.2.1 Per-Language Coverage Comparison

- Bash: Baseline: 94.2% lines -> Post-change: 93.4% lines. Change: -0.8 percentage points. New-file coverage: `cleanup_worktrees_report_records_lib.sh` 89.0%, `cleanup_worktrees_scan_helper.sh` 86.8%. Branch coverage: not measurable (kcov limitation; no bash branch gate). Disposition: **PASS**. Evidence: `evidence/baseline/baseline-test-coverage.2026-09-06T23-03.md` (baseline); GitHub Actions run 34151370364 log line `Bash coverage (lines): 93.4%` and its `shell-coverage` artifact `cov.xml` (post-change).
- TypeScript: `N/A - zero changed files`.
- Python: `N/A - zero changed files`.
- PowerShell: `N/A - zero changed files`.
- C#: `N/A - zero changed files`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Assertions use exact-equality on full output where the record set is closed (`[ "$output" = "STALE_REF|refs/remotes/upstream/feature-old" ]`, `test_cleanup_worktrees_report_records.bats:36`) and substring matching only where the driver emits additional unrelated records. Exact-equality is the stronger form and produces a full expected-vs-actual diff on failure. |
| **Arrange-Act-Assert Pattern** | PASS | The `setup()` block resolves paths (Arrange), the per-file helper invokes the function under a named scenario (Act), and the `[ ... ]` / `[[ ... ]]` assertions follow (Assert). Fixture data is the externalized Arrange step. |
| **Document Intent** | PASS | Every new `@test` name states the behavior and the condition, e.g. `"scan_orphan_dirs emits nothing for a registered worktree directory"`, `"child_of_merged_equivalent: no short-circuit when the ancestor is not NOT_MERGED"`. Each carries a comment explaining the fixture's shape. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, database, or remote API. Real `git` is never invoked in tests: every call routes through `CLEANUP_WT_GIT_BIN`. Real filesystem walks are prevented by the new `CLEANUP_WT_SCAN_BIN` seam, which the change correctly wires into all five pre-existing driver call-site files (verified in `evidence/other/scan-seam-call-site-verification.2026-09-06T23-03.md` and re-confirmed by inspection of the diff to `test_cleanup_worktrees_{cli,deletion,detached,hard_failures,classification}.bats`). |
| **Use Mocks/Stubs** | PASS | Two replaying stubs: `tests/fixtures/cleanup_worktrees/stub-bin/git` (extended additively with a pattern-specific `for-each-ref` key, a target-aware `merge-base.<tip>.<up>` key, and a new `remote)` case) and the new `tests/fixtures/cleanup_worktrees/stub-bin/scan`. Both are documented replayers with a stated key-derivation contract. |
| **Environment Stability** | PASS | **No temporary files are created by any new test.** All fixture data is checked in under `tests/fixtures/cleanup_worktrees/scenarios/` and `tests/fixtures/cleanup_worktrees/scan_roots/`. The `scan_roots` fixture names its pointer file `dotgit` and drives the production default through the `CLEANUP_WT_SCAN_GITFILE_NAME` seam, because git refuses to index a path component named `.git` — a documented, policy-compliant alternative to creating one at test time (`test_cleanup_worktrees_scan_helper.bats:9-13`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document plus `code-review.2026-09-07T14-49.md` and `feature-audit.2026-09-07T14-49.md` constitute the required pre-submission review. Outstanding items are enumerated in section 8 and routed through `remediation-inputs.2026-09-07T14-49.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| Policy files read in the mandated order | PASS | `evidence/baseline/phase0-instructions-read.md` records `CLAUDE.md`, `general-code-change.md`, `general-unit-test.md`, `shell.md` read in order at session start. |
| Baseline toolchain state captured before changes | PASS | `evidence/baseline/baseline-format.2026-09-06T23-03.md` (exit 0, no rewrite), `baseline-check.2026-09-06T23-03.md` (exit 0), `baseline-test.2026-09-06T23-03.md` (321 pass, 0 fail), `baseline-test-coverage.2026-09-06T23-03.md` (94.2%). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PARTIAL | The scan records are simple and readable. `classify_all_branches` is not: it is a 147-line function carrying four associative arrays, a nested O(n^2) probe loop, and two ordering phases, and its correctness argument is carried entirely in a 39-line prose comment rather than in an assertable structure. That prose argument is the thing that turned out to be wrong (Gap G1). |
| **Reusability** | PASS | The `CHILD_OF` short-circuit lives in the shared driver called by both `run_report` (`cleanup_worktrees_lib.sh:486`) and `run_apply` (`cleanup_worktrees_actions_lib.sh:389`), exactly as spec.md's Risks & Mitigations required, rather than being duplicated in report's formatting layer. The design intent here is correct even though the inference rule it carries is not. |
| **Extensibility** | PASS | The filesystem-scan seam follows the established `CLEANUP_WT_GIT_BIN` shape (`cleanup_wt_scan_bin`, lines 42-59) and emits a versionable pipe-delimited tuple. New record types can be added without touching the ladder. |
| **Separation of concerns** | PASS | Pure classification (`classify_branch`) is untouched; filesystem I/O is isolated in `cleanup_worktrees_scan_helper.sh` behind a seam; the emission drivers do formatting only. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **500-line cap on every production, test, and reusable script file** | PASS | `wc -l`: `cleanup_worktrees_lib.sh` 491, `cleanup_worktrees_report_records_lib.sh` 463, `cleanup_worktrees_actions_lib.sh` 417, `cleanup_worktrees_scan_helper.sh` 157, `cleanup-worktrees.sh` 128, `cleanup_worktrees_enumerate_lib.sh` 236, `cleanup_worktrees_detached_lib.sh` 301, `stub-bin/git` 246, `stub-bin/scan` 50, largest bats file 328 (`test_cleanup_worktrees_detached.bats`). Every file is at or under 500. `cleanup_worktrees_lib.sh` grew from 479 to 491 (+12), which is within cap but leaves only 9 lines of headroom. |
| New logic placed in a new sibling file rather than growing the capped file | PASS | 463 of the ~620 new production lines are in the new `cleanup_worktrees_report_records_lib.sh`; `cleanup_worktrees_lib.sh` gained only the `run_report` call-site edit and header documentation. |
| Source order correctness | PASS | `cleanup-worktrees.sh:19-24` sources the report-records lib after the enumerate lib and before `cleanup_worktrees_lib.sh`, with an explanatory comment. Verified by the CLI end-to-end tests passing in `test_cleanup_worktrees_cli.bats`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| Descriptive names, no unexplained abbreviations | PASS | `scan_orphan_dirs`, `scan_stale_refs`, `scan_registration_loss`, `classify_all_branches`, `cleanup_wt_scan_bin`, `cleanup_wt_scan_roots`, `cleanup_wt_scan_records`, `cleanup_wt_protected_branches`, `scan_helper_gitdir_target_exists`. Local abbreviations (`rc`, `crc`, `wlout`, `ebout`) match the established convention in the sibling libraries. |
| Function-level documentation | PASS | Every new function carries a docstring comment stating purpose, argument list, return contract, and failure behavior. |
| Documentation accuracy | PARTIAL | Two inaccuracies: (a) `cleanup-worktrees.sh:58` heads all four new records "(report and apply mode)" although the three scan records are emitted only by `run_report`; (b) `cleanup_worktrees_report_records_lib.sh:243-244` states `scan_registration_loss` "consumes the same scan output ... as `scan_orphan_dirs`, so the two records are always derived from one consistent view of the filesystem", but the function calls `cleanup_wt_scan_records` a second time (line 253) and therefore derives a second, independent view. See Gaps G3 and G5. |

### 2.5 After Making Changes - Toolchain Execution

| Stage | Status | Evidence |
|------|--------|----------|
| 1. Formatting (`shfmt`) | PASS | Auditor ran `shfmt -d` over `cleanup_worktrees_report_records_lib.sh`, `cleanup_worktrees_scan_helper.sh`, `cleanup_worktrees_lib.sh`, `cleanup_worktrees_actions_lib.sh`, `cleanup-worktrees.sh`, `stub-bin/scan`, and `stub-bin/git`: no diff, exit 0. CI step "Run shell-qc check (shfmt diff + shellcheck)" also succeeded. |
| 2. Linting (`shellcheck`) | PASS | Auditor ran `shellcheck -x` over the same seven files: no output, exit 0. |
| 3. Type checking | N/A | Not applicable to bash (`.claude/rules/shell.md`). |
| 4. Architecture-boundary tests | N/A | No architecture-boundary tooling exists for the bash surface. The equivalent structural constraint (new logic must not grow the capped library) is verified in section 2.3. |
| 5. Unit tests (`bats`) | PASS | CI run 34151370364, step "Run shell-qc test with coverage": TAP plan `1..335`, 335 `ok` lines, 0 `not ok` lines. Baseline was 321, so 14 tests were added — matching the 14 new `@test` blocks counted in the diff (6 report-records, 1 scan-helper, 2 scan-seam, 4 classification, 1 deletion). |
| 6. Contract / schema checks | PASS | The `.claude/**` push-down contract is the applicable schema check: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` recorded passing in `evidence/qa-gates/skill-md-mirror-contract.2026-09-06T23-03.md`, and the auditor independently confirmed `md5sum` equality of the two SKILL.md copies. |
| 7. Integration tests | PASS | `test_cleanup_worktrees_cli.bats` runs the assembled wrapper end to end in report and apply mode with both seams engaged. |
| Loop completed in a single clean pass | UNVERIFIED | The plan's Phase 11 (P11-T1 through P11-T5) is entirely unexecuted; no `evidence/qa-gates/final-*.md` artifact exists, so no record asserts that all four stages passed in one pass without a restart. Every individual stage is independently verified above; only the single-pass attestation is missing. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| Change described in feature documentation | PASS | `spec.md` sections "Proposed Fix", "Technical specifications", and "Test Strategy" describe the delivered design accurately, including the exact record shapes. |
| Public surface documented | PASS | `.claude/skills/cleanup-merged-worktrees/SKILL.md` Report Line Contract gained one bullet per new record type, cross-referencing (not restating) the Dirty Worktree Triage Procedure step 7 for orphan-directory disposition. |
| No breaking change to existing public output shapes | FAIL | The four new record types are additive and no existing record's shape changed. However, the *value* of an existing record changed for an entire class of branches: a delete-eligible branch that is a git ancestor of a `NOT_MERGED` branch now reports `BRANCH|<name>|NOT_MERGED` instead of `BRANCH|<name>|MERGED_CLEAN`, and apply mode consequently stops emitting its deletion `ACTION`. See Gap G1. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | PASS | **Command:** `shfmt -d <changed shell files>` (local, shfmt on Windows PATH) and CI `bash scripts/bash/shell-qc.sh check`.<br>**Result:** no diff, exit 0 in both. |
| **Linting with shellcheck** | PASS | **Command:** `shellcheck -x <changed shell files>` (local) and CI `shell-qc.sh check`.<br>**Result:** zero diagnostics, exit 0 in both. |
| **Testing with bats** | PASS | **Command:** `bash scripts/bash/shell-qc.sh test --coverage` (CI run 34151370364).<br>**Result:** 335 planned, 335 passed, 0 failed. |
| **Coverage with kcov** | PASS | `Bash coverage (lines): 93.4%` at head SHA, versus the 85% uniform floor. Note for future audits: `shell-qc.sh` prints the percentage but does **not** enforce a threshold (`print_coverage_summary`, `scripts/bash/shell_qc_lib.sh:276-292`, has no comparison), so a green CI run alone does not establish that the floor was met; the number must be read from the log or `cov.xml`, as was done here. |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | PASS | `cleanup_worktrees_report_records_lib.sh:1`, `cleanup_worktrees_scan_helper.sh:1`, and `stub-bin/scan:1` all use `#!/usr/bin/env bash`. |
| **Error handling** | PASS | `cleanup_worktrees_scan_helper.sh:41` sets `set -euo pipefail` and guards the one pipeline that may legitimately fail (`size=$(du -sh ... | cut -f1) || size=""`, line 52). The sourced libraries deliberately omit `set -e`, matching the existing sibling libraries' sourcing contract. Every git and scan read that must not silently degrade is captured in the parent shell with `out=$(...) || rc=$?` and its non-zero exit is surfaced, consistent with the documented capture rule in `cleanup_worktrees_lib.sh:20-38`. |
| **Under 500 lines** | PASS | See section 2.3; largest changed file is `cleanup_worktrees_lib.sh` at 491. |
| **Override seams instead of direct tool invocation** | PASS | `cleanup_wt_scan_bin` (lines 42-59) mirrors `cleanup_wt_git`'s shape: a non-empty, executable `CLEANUP_WT_SCAN_BIN` wins; otherwise the bundled helper alongside the library is used. Both branches are directly tested. |
| **Test file location mirrors source** | PASS | `tests/shell/test_cleanup_worktrees_report_records.bats`, `test_cleanup_worktrees_scan_helper.bats`, `test_cleanup_worktrees_scan_seam.bats` all live under `tests/shell/`, mirroring `scripts/bash/`. No test file was colocated into `scripts/`. |
| **Sourcing contract: no work at source time** | PASS | `cleanup_worktrees_report_records_lib.sh:14-15` declares and honors a definitions-only contract. `cleanup_worktrees_scan_helper.sh:153-157` guards execution behind `[[ ${BASH_SOURCE[0]} == "${0}" ]]`. |
| **Correctness of new logic** | FAIL | `classify_all_branches`'s inheritance rule is unsound; see Gap G1. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4C: Bash Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| bats tests live in `tests/shell/*.bats` | PASS | All three new test files are under `tests/shell/`. |
| No temporary files created in tests | PASS | Verified by inspection of all eight changed bats files: no `mktemp`, no `BATS_TMPDIR` write, no scratch git repository. Fixture data is entirely checked in. |
| Every new library function carries bats coverage | PASS | All nine new functions have at least one test that executes them, directly or through a driver. |
| Stub seams used rather than real tools | PASS | `CLEANUP_WT_GIT_BIN`, `CLEANUP_WT_SCAN_BIN`, and `CLEANUP_WT_SCAN_GITFILE_NAME` are set in every relevant helper. |
| Backward compatibility of the shared stub edit | UNVERIFIED | See Gap G4: no ordered evidence exists for the standalone regression gate the spec and plan require immediately after the `for-each-ref` stub edit. |
| Error-path scenario completeness | PARTIAL | See Gap G6. |

---

## 5. Test Coverage Detail

### `scan_stale_refs` (2 tests) — lines 61-108

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `scan_stale_refs emits STALE_REF for a remote-tracking ref with no configured remote` | Positive | PASS |
| `scan_stale_refs emits nothing when the remote exists` | Negative | PASS |

**Coverage:** the happy path and both filter branches are covered. **Not covered:** the two hard-failure returns at lines 81-82 (`for-each-ref` non-zero) and 86-87 (`git remote` non-zero).

### `scan_orphan_dirs` (2 tests) — lines 185-232

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `scan_orphan_dirs emits ORPHAN_DIR for an unregistered, .git-less directory` | Positive | PASS |
| `scan_orphan_dirs emits nothing for a registered worktree directory` | Negative | PASS |

**Coverage:** both filter gates (`has_gitfile == 0`, not registered) are exercised. **Not covered:** the scan-failure return at line 202 and the `size` empty-to-`unknown` substitution at line 225.

### `scan_registration_loss` (2 tests) — lines 234-273

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `scan_registration_loss emits WARN|registration-lost for a broken gitdir pointer` | Positive | PASS |
| `scan_registration_loss emits nothing when the gitdir pointer resolves` | Negative | PASS |

**Coverage:** both `target_exists` branches. **Not covered:** the scan-failure return at line 255; the `NA` (pointer-less) skip is exercised indirectly through the `orphan_dir_present` fixture only, not asserted in a dedicated test.

### `cleanup_wt_scan_bin` (2 tests) — lines 42-59

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `cleanup_wt_scan_bin honors an executable CLEANUP_WT_SCAN_BIN override` | Positive | PASS |
| `cleanup_wt_scan_bin falls back to the bundled scan helper when unset` | Negative/default | PASS |

**Coverage:** both branches. **Not covered:** the "set but not executable" sub-case of the override guard.

### `classify_all_branches` (5 tests) — lines 317-463

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `child_of_not_merged: CHILD_OF short-circuit skips feature-child's expensive rungs` | Positive + argv-log negative assertions | PASS |
| `child_of_merged_equivalent: no short-circuit when the ancestor is not NOT_MERGED` | Negative | PASS |
| `child_of_ancestry_probe_error: a hard pairwise ancestry failure maps to ANCESTRY_ERROR` | Error handling | PASS |
| `child_of_not_merged: report-mode BRANCH line is unchanged by the short-circuit` | Outcome preservation (a) | PASS mechanically; see note |
| `apply mode allowlist is unaffected by a CHILD_OF short-circuit` (deletion.bats) | Outcome preservation (b) | PASS mechanically; see note |

**Note on the two outcome-preservation tests.** Both pass, and both are too weak to detect
Gap G1. Test (a) does not compare the same branch with and without the short-circuit; it
compares `feature-child` under `child_of_not_merged` against a *different* branch
(`feature-unmerged`) under a *different* fixture (`unmerged`), so it asserts record shape,
not value invariance. Test (b) asserts only that a `NOT_MERGED` branch is not deleted —
`NOT_MERGED` was never delete-eligible, so the assertion holds whether or not the invariant
does. Neither test exercises the case where the short-circuit changes a delete-eligible
verdict into a non-delete-eligible one, which is the case that fails.

**Not covered in this function:** the enumerate-failure return (364), the empty-order return
(373), the protected-name read (429), and the phase-2b classify-failure propagation (453).

### `cleanup_wt_scan_roots` and `cleanup_wt_protected_branches` (0 direct tests)

Both are exercised only transitively through `scan_orphan_dirs` / `classify_all_branches`.
Their override and failure branches (124-129, 135, 292, 303) are unhit.

### `cleanup_worktrees_scan_helper.sh` (1 test) — lines 43-157

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `scan-dirs emits has_gitfile/target_exists/size for each candidate directory` | Positive, three shapes in one assertion set | PASS |

**Coverage:** 86.8%. The three observable directory shapes (`no_git`, `good_wt`, `broken_wt`)
are asserted. **Not covered:** the `du`-failure `unknown` path (54), the production default
pointer-file name (69, never exercised because every test sets the seam), the empty-target
path (88-89), and the usage / unknown-subcommand exit-2 path (127, 145-146).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 335 | PASS |
| Tests Passed | 335 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Tests Added by this change | 14 (321 -> 335) | PASS |
| Execution Time | 299s under kcov instrumentation (CI 18:23:15Z-18:28:15Z) | PASS |
| Average Time per Test | ~0.89s under kcov | PASS |
| Functions/Classes Tested | 9/9 new functions have at least one executing test | PASS |
| Largest changed test file | 328 lines (`test_cleanup_worktrees_detached.bats`) | PASS |
| Code Coverage | 93.4% lines repo-wide; branch coverage not measurable by kcov | PASS |

---

## 7. Code Quality Checks

**For Bash:**

```
shfmt -d scripts/bash/cleanup_worktrees_report_records_lib.sh \
         scripts/bash/cleanup_worktrees_scan_helper.sh \
         scripts/bash/cleanup_worktrees_lib.sh \
         scripts/bash/cleanup_worktrees_actions_lib.sh \
         scripts/bash/cleanup-worktrees.sh \
         tests/fixtures/cleanup_worktrees/stub-bin/scan
# exit 0, no diff

shellcheck -x <same file list>
# exit 0, no diagnostics

(cd tests/fixtures/cleanup_worktrees/stub-bin && shfmt -d ./git)      # exit 0
(cd tests/fixtures/cleanup_worktrees/stub-bin && shellcheck -x ./git) # exit 0
```

**Notes:**
- `shfmt` and `shellcheck` were available on the Windows PATH and were run by the auditor
  directly. `bats` and `kcov` are not available in this environment, so the test and coverage
  stages were verified from the recorded CI run at the head SHA rather than re-executed.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exits 0.

---

## 8. Gaps and Exceptions

### Identified Gaps

**G1 — BLOCKING. The `CHILD_OF` short-circuit changes classification outcome, not only cost.**

`classify_all_branches` infers `BRANCH|X|NOT_MERGED` whenever X is a git ancestor of some Y
that resolved exactly `NOT_MERGED` (`cleanup_worktrees_report_records_lib.sh:434-447`). The
inference is invalid. A branch already merged into `main` is by definition an ancestor of
`main`, and therefore also an ancestor of every branch that descends from `main` — including
unmerged ones. Such a branch is exactly what this tool exists to find and delete.

Reproduced by direct execution against the checked-in git stub with a three-branch scenario
(`main`, `feature-merged` merged into main, `feature-unmerged` descending from main):

```
=== BASELINE: per-branch classify_branch (pre-change driver loop) ===
BRANCH|feature-merged|MERGED_CLEAN
BRANCH|feature-unmerged|NOT_MERGED
BRANCH|main|PROTECTED_CURRENT

=== NEW: classify_all_branches (post-change shared driver) ===
BRANCH|feature-merged|NOT_MERGED
CHILD_OF|feature-merged|feature-unmerged
BRANCH|feature-unmerged|NOT_MERGED
BRANCH|main|PROTECTED_CURRENT
```

Apply mode, same scenario, pre-change versus post-change:

```
=== PRE-CHANGE run_apply ===
WORKTREE|/repo/main|main|main
BRANCH|feature-merged|MERGED_CLEAN
ACTION|branch-delete|feature-merged|OK
BRANCH|feature-unmerged|NOT_MERGED
BRANCH|main|PROTECTED_CURRENT

=== POST-CHANGE run_apply ===
WORKTREE|/repo/main|main|main
BRANCH|feature-merged|NOT_MERGED
CHILD_OF|feature-merged|feature-unmerged
BRANCH|feature-unmerged|NOT_MERGED
BRANCH|main|PROTECTED_CURRENT
```

This violates spec.md's declared hard invariant in both of its stated properties: the
report-mode `BRANCH|` value is not unchanged, and the apply-mode allowlist decision for a
`CHILD_OF`-short-circuited branch *is* changed. It is fail-safe in the narrow sense that
nothing is deleted that should not be, but it suppresses the tool's primary function whenever
an unmerged descendant branch exists, which is the normal state of a working repository.

The existing `main`-protection carve-out (lines 421-429) does not help: it excludes only
branches that `classify_branch` would resolve `PROTECTED_CURRENT`, not merged feature
branches.

Remediation direction (not prescriptive): the sound direction of the inference is the
opposite one — a branch that is a *descendant* of a `NOT_MERGED` branch contains that
branch's unique residual commits and therefore cannot itself be `MERGED_*`. Note two
consequences that remediation planning must weigh: (a) even the inverted rule does not
distinguish `NOT_MERGED` from `HAS_UNIQUE_RESIDUALS` for the descendant, so it can license
"not delete-eligible" but not necessarily the exact token `NOT_MERGED`; and (b) in the
originally reported scenario the epic child branches were merged *into* the integration
branch, i.e. they were ancestors of it, so an inverted rule would not short-circuit them and
the claimed performance benefit for that scenario would largely disappear. A guard that
short-circuits only when X is additionally *not* an ancestor of `main` is an alternative
worth evaluating, but it costs one extra probe per branch and needs its own soundness
argument.

**G2 — Blocking (test/evidence adequacy). The delivered tests and the recorded
outcome-preservation sweep cannot detect G1.**

No fixture scenario under `tests/fixtures/cleanup_worktrees/scenarios/` pairs a delete-eligible
branch with a `NOT_MERGED` branch. Of the ~30 scenarios, 21 have two branches (`main` plus
one feature) and three have three; the three-branch ones are the new `child_of_*` fixtures,
in which the short-circuited branch is genuinely unmerged (`merge-base.feature-child.main.rc`
is `1`). The "NO_DIFF" outcome-preservation sweep recorded in
`evidence/other/scan-seam-call-site-verification.2026-09-06T23-03.md` compares pre- and
post-change output across the pre-existing scenario set, so its coverage is bounded by that
same fixture set and it could not observe the divergence. The sweep's conclusion —
"Report-mode and apply-mode output are byte-identical to the pre-change baseline across every
pre-existing scenario" — is accurate as stated but does not support the broader claim that
"the four new record types and the `CHILD_OF` short-circuit therefore add records without
altering any existing verdict or action."

**G3 — Major. The filesystem scan is executed twice per report, and the code comment claims
otherwise.**

`scan_orphan_dirs` calls `cleanup_wt_scan_records` at line 200 and `scan_registration_loss`
calls it again at line 253. Each call re-resolves the roots (including a `parse_worktree_list`
git read) and re-runs the helper, which walks every candidate directory and computes `du -sh`
for each. The docstring at lines 243-244 asserts the opposite ("the same scan output ... one
consistent view of the filesystem"), so the two record sets can in principle disagree under
concurrent filesystem change — precisely the mid-run-mutation condition gap 9d describes.

**G4 — Major (evidence). No ordered regression-gate evidence for the shared stub edit.**

Plan task P2-T3 is unchecked and its named artifact
`evidence/regression-testing/stub-git-backward-compat.2026-09-06T23-03.md` does not exist.
Both spec.md's Backward-compatibility expectations and its Manual validation steps require a
full existing-suite bats run *immediately after* the `for-each-ref` and `merge-base` stub
edits and *before* any new scenario fixture is authored on top of them. The end-state suite is
green (335/335), and the auditor confirmed the fallback logic is written to preserve the
historical bare keys (`stub-bin/git:120-123` for `for-each-ref`, `:142-146` for `merge-base`),
but the ordered intermediate gate cannot be reconstructed from a single squashed
implementation commit.

**G5 — Major. New report-mode cost is unmeasured and plausibly exceeds the savings.**

Three new costs are introduced by a change whose stated motivation for gap 9c was reducing
report runtime: (a) the pairwise ancestry probe spawns up to n(n-1) `git merge-base` processes
(`classify_all_branches:377-398`) and does not break out of the inner loop after the first
hit, although at most one resolved target is ever used; for the 20+ branch checkout described
in the issue that is 400+ new process spawns; (b) `du -sh` is computed for every immediate
subdirectory of every scan root including live registered worktrees, even though `<size>` is
only ever emitted for `ORPHAN_DIR` records (`cleanup_worktrees_scan_helper.sh:119`), and the
issue itself cites a 6 GB orphan directory; (c) that entire walk runs twice (G3). No runtime
measurement, before or after, is recorded anywhere in the feature folder.

**G6 — Major. Error-handling paths of the new code are untested.**

30 of the 262 instrumented lines across the two new files are unhit at the head SHA, and they
are almost entirely the error, fallback, and override branches — enumerated in section 1.2 and
section 5. Three of the untested cases are named explicitly in spec.md's Test Strategy as
required edge cases: the `ORPHAN_DIR|<path>|unknown` unresolvable-size case, the scan
hard-failure case, and the unreadable-`.git`-file case. `.claude/rules/general-unit-test.md`
Scenario Completeness requires error-handling behavior to be covered. Repo-wide coverage
remains above the floor, so this is a scenario-completeness gap rather than a threshold
breach.

**G7 — Minor (evidence). Post-change coverage and final-QC evidence artifacts are absent.**

Plan Phases 10 and 11 are entirely unexecuted. None of
`evidence/other/file-size-cap-verification.*.md`,
`evidence/other/ac11-generic-detection-confirmation.*.md`,
`evidence/qa-gates/final-format.*.md`, `final-check.*.md`, `final-test.*.md`, or
`final-test-coverage.*.md` exists. The auditor independently established every underlying fact
(file sizes by `wc -l`, generic detection by grep and by reading the detection logic,
format/lint by running the tools, tests and coverage from the CI run and its uploaded
artifact), so no claim in this audit rests on the missing files; the gap is the absence of the
durable record the plan requires.

**G8 — Minor. `.claude/worktrees` scan root is CWD-relative and never matches a registration.**

`cleanup_wt_scan_roots:131` emits the literal relative path `.claude/worktrees`. The tool never
changes directory to the repository root — `cleanup-worktrees.sh:10` resolves only
`SCRIPT_DIR`. Run from any directory other than the repository root, the helper's
`[[ -d $root ]] || continue` silently skips the root and no `ORPHAN_DIR` or
`WARN|registration-lost` record is produced for it. Additionally, `scan_orphan_dirs` compares
the scanned path against porcelain worktree paths after `normalize_wt_path`, which lowercases
and slash-normalizes but does not absolutize (`cleanup_worktrees_enumerate_lib.sh:150-164`), so
a relative scanned path can never match an absolute registered path and the registration gate
is effectively dead for this root.

**G9 — Minor. Documentation and contract inaccuracies.** See section 2.4: the usage text's
"report and apply mode" heading for the three report-only scan records, and the
`scan_registration_loss` "one consistent view" comment.

**G10 — Minor. `run_report`'s early-abort contract is now partially violated.** The three scan
calls at `cleanup_worktrees_lib.sh:475-477` run after output has begun; a hard scan failure
sets `rc` but the report continues, producing exactly the partial report the function's own
comment says never happens. The three consecutive `|| rc=$?` assignments also use
last-failure rather than maximum semantics.

**G11 — Minor. `run_apply`'s hard-failure detection was narrowed.** The check changed from
"`classify_branch` returned non-zero" to "state == `ANCESTRY_ERROR`"
(`cleanup_worktrees_actions_lib.sh:404-409`). `classify_branch` can return 2 after emitting
`HAS_UNIQUE_RESIDUALS` (`cleanup_worktrees_lib.sh:437-443`). No deletion is unlocked, because
`HAS_UNIQUE_RESIDUALS` is not on the allowlist and the driver still propagates a non-zero rc,
but the per-branch `continue` no longer fires for that case. Related: `printf '%s\n' "$cb_out"`
at line 402 emits a blank line into a one-record-per-line contract when a branch is absent from
the driver's output.

**G12 — Minor. Spec-divergent handling of an unreadable pointer file.** spec.md states that a
`WARN|registration-lost` candidate whose `.git` file cannot be read is "skipped silently".
`scan_helper_gitdir_target_exists` returns `0` for a missing, unreadable, or malformed pointer
file (`cleanup_worktrees_scan_helper.sh:82-89`), so such a directory is reported as
registration-lost rather than skipped. The report never fails, so the never-blocking half of
the contract holds; the skip half does not.

### Approved Exceptions

None. No policy exception was requested or granted for this change.

### Removed/Skipped Tests

None. No test was removed, skipped, or marked pending. The eight pre-existing bats files were
edited only to add the `CLEANUP_WT_SCAN_BIN` seam and the `RLIB` source to their existing
helper templates, plus two new `@test` blocks; no assertion was weakened or deleted.

---

## 9. Summary of Changes

### Commits in This Branch

| SHA | Subject |
|-----|---------|
| `02ce5eec8c7a8178e8ad4317b69d1c62afe0f284` | `feat(631): implement report-mode visibility gaps (Phases 1-9)` |

One commit ahead of `origin/epic/cleanup-merged-worktrees-hardening-integration`
(`6dff80ed4596bec088d548b23013e6077e32c484`).

### Files Modified

| Category | Count | Notes |
|---|---|---|
| New bash production files | 2 | `cleanup_worktrees_report_records_lib.sh` (463), `cleanup_worktrees_scan_helper.sh` (157) |
| Modified bash production files | 3 | `cleanup_worktrees_lib.sh`, `cleanup_worktrees_actions_lib.sh`, `cleanup-worktrees.sh` |
| New bats test files | 3 | report-records, scan-helper, scan-seam |
| Modified bats test files | 5 | classification, cli, deletion, detached, hard-failures |
| New/modified stub binaries | 2 | `stub-bin/scan` (new), `stub-bin/git` (additive key edits) |
| New fixture files | ~60 | 9 new scenario directories plus the `scan_roots/basic` tree |
| Documentation | 4 | SKILL.md + byte-identical extension mirror, spec.md, plan.md |
| Evidence artifacts | 7 | under `evidence/baseline/`, `evidence/qa-gates/`, `evidence/other/` |

---

## 10. Compliance Verdict

### Overall Status: NON-COMPLIANT

The change is well-structured, cleanly formatted, thoroughly documented, correctly seamed for
determinism, within the file-size cap, and above the coverage floor. It fails compliance on a
single but decisive point: the `CHILD_OF` short-circuit changes classification outcomes for a
class of branches, contradicting the invariant that spec.md declares as hard and disabling the
tool's primary function in apply mode for merged branches that are ancestors of any unmerged
branch. That defect is proven by direct execution of both the pre-change and post-change code
paths against the repository's own test stub, not inferred.

### Policy-by-Policy Summary

| Policy | Verdict | Basis |
|---|---|---|
| `CLAUDE.md` (tone, policy order) | PASS | Policy order recorded in `evidence/baseline/phase0-instructions-read.md`; all authored prose is factual and measured. |
| `.claude/rules/general-code-change.md` | FAIL | Design principles, file-size cap, naming, and toolchain loop all pass; "avoid breaking existing behavior" fails on Gap G1. |
| `.claude/rules/general-unit-test.md` | PARTIAL | Five core principles, no-temp-file rule, test location, and coverage floor all pass; Scenario Completeness (error paths) and the negative-case adequacy behind Gap G2 do not. |
| `.claude/rules/quality-tiers.md` | PASS | Line coverage 93.4% >= 85% uniform; no branch gate applies to bash. |
| `.claude/rules/shell.md` | PARTIAL | shfmt/shellcheck/bats/kcov all clean; error-path coverage incomplete. |
| Evidence location invariant | PASS | No non-canonical evidence path in the diff; validator exits 0. |
| `modified-workflow-needs-green-run` | N/A (rule does not trigger) | No path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` appears in the branch diff. A green `workflow_dispatch` run against the head SHA (34151370364) exists regardless. |

### Metrics Summary

| Metric | Value |
|---|---|
| Languages with changed files | 1 (bash) |
| Bash line coverage, baseline -> post-change | 94.2% -> 93.4% (floor 85%) |
| New-file line coverage | 89.0% and 86.8% (floor 85%) |
| bats tests, baseline -> post-change | 321 -> 335, 0 failures |
| shfmt / shellcheck diagnostics | 0 / 0 |
| Largest changed file | 491 lines (cap 500) |
| Blocking findings | 2 (G1, G2) |
| Major findings | 4 (G3, G4, G5, G6) |
| Minor findings | 6 (G7-G12) |

### Recommendation

**Needs revision.** Remediate G1 and G2 before PR. The remaining Major findings (G3, G4, G5,
G6) should be addressed in the same remediation cycle because they are all in code or evidence
that G1's fix will touch. Details and remediation inputs are in
`remediation-inputs.2026-09-07T14-49.md`.

---

## Appendix A: Test Inventory

New `@test` blocks added by this change (14 total):

`tests/shell/test_cleanup_worktrees_report_records.bats` (6)
1. `scan_stale_refs emits STALE_REF for a remote-tracking ref with no configured remote`
2. `scan_stale_refs emits nothing when the remote exists`
3. `scan_orphan_dirs emits ORPHAN_DIR for an unregistered, .git-less directory`
4. `scan_orphan_dirs emits nothing for a registered worktree directory`
5. `scan_registration_loss emits WARN|registration-lost for a broken gitdir pointer`
6. `scan_registration_loss emits nothing when the gitdir pointer resolves`

`tests/shell/test_cleanup_worktrees_scan_seam.bats` (2)
7. `cleanup_wt_scan_bin honors an executable CLEANUP_WT_SCAN_BIN override`
8. `cleanup_wt_scan_bin falls back to the bundled scan helper when unset`

`tests/shell/test_cleanup_worktrees_scan_helper.bats` (1)
9. `scan-dirs emits has_gitfile/target_exists/size for each candidate directory`

`tests/shell/test_cleanup_worktrees_classification.bats` (4)
10. `child_of_not_merged: CHILD_OF short-circuit skips feature-child's expensive rungs`
11. `child_of_merged_equivalent: no short-circuit when the ancestor is not NOT_MERGED`
12. `child_of_ancestry_probe_error: a hard pairwise ancestry failure maps to ANCESTRY_ERROR`
13. `child_of_not_merged: report-mode BRANCH line is unchanged by the short-circuit`

`tests/shell/test_cleanup_worktrees_deletion.bats` (1)
14. `apply mode allowlist is unaffected by a CHILD_OF short-circuit`

New scenario fixture directories (9): `orphan_dir_present`, `orphan_dir_absent`,
`stale_ref_present`, `stale_ref_absent`, `registration_lost_present`,
`registration_lost_absent`, `child_of_not_merged`, `child_of_merged_equivalent`,
`child_of_ancestry_probe_error`. Plus the `scan_roots/basic/` tree with `no_git/`,
`good_wt/` + `good_wt_target/`, and `broken_wt/`.

---

## Appendix B: Toolchain Commands Reference

**Commands run by this audit:**

```bash
# Scope determination
git diff --stat origin/epic/cleanup-merged-worktrees-hardening-integration..HEAD
git diff --name-only origin/epic/cleanup-merged-worktrees-hardening-integration..HEAD
git merge-base origin/epic/cleanup-merged-worktrees-hardening-integration HEAD

# PR context refresh (artifacts were absent)
poetry run python -m scripts.dev_tools.pr_context.collector \
  --base origin/epic/cleanup-merged-worktrees-hardening-integration --head HEAD

# Bash format and lint (locally available on the Windows PATH)
shfmt -d <changed shell files>
shellcheck -x <changed shell files>

# Evidence location compliance
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .

# File-size cap
wc -l scripts/bash/cleanup_worktrees*.sh scripts/bash/cleanup-worktrees.sh tests/shell/*.bats

# SKILL.md mirror
diff -q .claude/skills/cleanup-merged-worktrees/SKILL.md \
        extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md
md5sum <both files>

# Recorded CI evidence at the head SHA (not re-dispatched)
gh run view 34151370364 --json databaseId,headSha,conclusion,status,workflowName,jobs
gh run view 34151370364 --log        # -> "1..335", 335 ok, 0 not ok, "Bash coverage (lines): 93.4%"
gh run download 34151370364 -n shell-coverage
# cov.xml per-file line-rate parse for the two new files
```

**Repository toolchain commands for this language (for reference):**

```bash
bash scripts/bash/shell-qc.sh format
bash scripts/bash/shell-qc.sh check
bash scripts/bash/shell-qc.sh test
bash scripts/bash/shell-qc.sh test --coverage
```

`bats` and `kcov` are not installed in this environment, so stages 3 and 4 were verified from
CI run 34151370364 at the head SHA rather than re-executed locally, per the
feature-review-workflow rule to inspect existing coverage artifacts instead of regenerating
them.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-09-07
**Policy Version:** Current as of 2026-09-07
