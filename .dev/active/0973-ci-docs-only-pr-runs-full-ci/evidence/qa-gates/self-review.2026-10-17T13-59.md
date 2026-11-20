# Self-Review: Docs-Only Merge-Base Fallback (Issue #973)

Timestamp: 2026-10-17T13-59
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against git diff MB plus the untracked files of git status --porcelain
EXIT_CODE: 0

- Feature folder: `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973` (`FEATURE`)
- Base: merge base of `origin/main` and `HEAD` (`MB`, recorded in `FEATURE/evidence/baseline/execution-context.2026-10-17T13-04.md`); head: branch `bug/ci-docs-only-pr-runs-full-ci-973` working tree (uncommitted)
- Work mode: `full-bug` (from `FEATURE/issue.md`); AC source: `FEATURE/spec.md` `## Acceptance Criteria` only
- Languages in scope: PowerShell (production and tests), YAML workflow (actionlint), JSON configuration, Markdown documentation. Python, TypeScript, C#, and Bash are out of scope (no file written).

Row counts: 118 rows; PASS 106, N/A 12, FAIL 0.

## A. Policy audit template

### A1. General unit test policy: core principles

| # | Item | Status | Evidence |
|---|---|---|---|
| 1 | Independence | PASS | Three seeded shuffled file-order runs (seeds 973, 9731, 97301) pass 208/208 each; the new suite and `Invoke-CiChangeScope.Tests.ps1` ran in both relative orders (`FEATURE/evidence/regression-testing/isolation-shuffle-seed-*.md`). Each row builds its own scenario object; no shared mutable state between rows. |
| 2 | Isolation | PASS | One `It` per behavior group; M rows drive `Resolve-CiChangeScopeDecision` through one changed scenario element each; U rows call one pure function each. |
| 3 | Fast execution | PASS | Six touched suites: 208 tests in about 2.5 s (`FEATURE/evidence/regression-testing/pass-after.2026-10-17T13-33.md` run log). |
| 4 | Determinism | PASS | No clock, randomness, network, process, or file write in the new rows; git and gh are in-memory fakes. |
| 5 | Readability and maintainability | PASS | Row names state scenario and outcome and end in `(#973)`; helpers documented with one-line comments in `BeforeAll`. |

### A2. Coverage and scenarios

| # | Item | Status | Evidence |
|---|---|---|---|
| 6 | Baseline coverage documented | PASS | `FEATURE/evidence/baseline/ps-tests.2026-10-17T13-08.md`: `CiChangeScope.psm1` 93.08%, `Invoke-CiChangeScope.ps1` 88.64%. |
| 7 | No coverage regression | PASS | `FEATURE/evidence/qa-gates/coverage-delta.2026-10-17T13-39.md`: 93.08% to 93.57%; 88.64% to 91.15%. |
| 8 | New code coverage (template 90%; repository 85%) | PASS | Changed executable lines covered 10/10 and 45/45 (100.00% each), from the coverage XML intersected with `git diff -U0 MB`. |
| 9 | Line coverage >= 85% per changed PowerShell production file | PASS | 93.57% and 91.15% in `FEATURE/evidence/qa-gates/ps-tests.2026-10-17T13-39.md`. |
| 10 | Comprehensive coverage (every new function tested) | PASS | `Test-CiMergeBaseFallbackApplicable` (U1, 10 rows), `ConvertFrom-CiMergeBaseOutput` (U2 3, U3 8), `Find-CiChangeScopeMergeBase` (M5 7 rows plus M1), `Get-CiChangeScopeDiffDecision` (existing `ancestry and diff` rows, M2, M3, M9, M10), `Get-CiChangeScopeContext` new keys (M12). |
| 11 | Positive flows | PASS | M1, M4 (3 prefixes), M6 (2 primary reasons), U2, U4. |
| 12 | Negative flows | PASS | M2, M3, M5, U3, U5, M7 (non-main base refs), M8. |
| 13 | Edge cases | PASS | U1 `Main` and empty base ref; U2 trailing LF and 64-character SHA; U3 two trailing LFs, 39 characters, leading and trailing space. |
| 14 | Error handling | PASS | M5 (cat-file exit 128, merge-base exit 1 and 128), M9 (diff exit 128, empty diff); existing envelope rows unchanged and passing. |
| 15 | Concurrency | N/A | The decision runs once per CI job in one process; no concurrent code path. |
| 16 | State transitions | N/A | Stateless decision function; no stateful component added. |
| 17 | Per-language coverage comparison (PowerShell) | PASS | Baseline 93.08% and 88.64% to post-change 93.57% and 91.15%; changed-code 100%; evidence `coverage-delta.2026-10-17T13-39.md`. Python, TypeScript: N/A, out of scope. |

### A3. Test structure and diagnostics

| # | Item | Status | Evidence |
|---|---|---|---|
| 18 | Clear failure messages | PASS | M1 asserts the log line first, so a failure prints the observed reason (fail-before showed `code=true reason=NO_FULL_GREEN_RUN`); `-Because` text on each row. |
| 19 | Arrange-Act-Assert pattern | PASS | Each row: scenario set-up, one `Invoke-TestScenario` or function call, assertions, separated by blank lines. |
| 20 | Document intent | PASS | File header comment states scope and isolation; row names are self-describing. |

### A4. External dependencies and environment

| # | Item | Status | Evidence |
|---|---|---|---|
| 21 | Avoid external dependencies | PASS | No git, gh, network, or process call in tests; invokers are script-block fakes. |
| 22 | Use mocks/stubs (no blanket mocks) | PASS | Fakes passed through `-GhInvoker`, `-GitInvoker`, `-OutputWriter`, `-ReadVariable`; no `Mock` in the new suite or the new rows. |
| 23 | Environment stability (no temporary files, no environment mutation) | PASS | Search of the new suite and of added test lines finds no `New-Item`, `Set-Content`, `Out-File`, `Start-Process`, environment-variable write, `TestDrive`, or temp path; files are only read (`Test-Path` of the entry script, the committed config). |

### A5. Policy audit requirement

| # | Item | Status | Evidence |
|---|---|---|---|
| 24 | Pre-submission review | PASS | This self-review; the formal feature review follows. |

### A6. General code change policy

| # | Item | Status | Evidence |
|---|---|---|---|
| 25 | Clarify the objective | PASS | Issue #973; `FEATURE/spec.md` D1 to D8. |
| 26 | Read existing change plans | PASS | Plan `FEATURE/plan.2026-10-17T08-16.md` and research read in [P0-T2]. |
| 27 | Document the plan | PASS | Plan file with checkboxes on disk. |
| 28 | Simplicity first | PASS | Two pure helpers and two small orchestration functions; the green-run diff is extracted into one shared helper rather than duplicated. |
| 29 | Reusability | PASS | `Get-CiChangeScopeDiffDecision` serves both paths with a reason-prefix parameter; `New-CiChangeScopeDecision` guard reused. |
| 30 | Extensibility | PASS | Fallback trigger set and base-ref rule live in one pure function (`Test-CiMergeBaseFallbackApplicable`). |
| 31 | Separation of concerns | PASS | Pure logic in `CiChangeScope.psm1` (module-structure row still finds no git, gh, file, or process command); I/O stays in the entry script behind invokers. |
| 32 | Cohesive modules | PASS | New pure functions in the pure module; git-calling functions in the entry script. |
| 33 | Under 500 lines | PASS | Largest changed file 395 lines; all eight files at most 411 (`file-sizes.2026-10-17T13-40.md`). |
| 34 | Public vs internal | PASS | Module exports updated for the two new functions only; entry-script functions are script-local. |
| 35 | No circular dependencies | PASS | Entry script imports the module; the module imports nothing. |
| 36 | Descriptive names | PASS | `Find-CiChangeScopeMergeBase`, `Get-CiChangeScopeDiffDecision`, `Test-CiMergeBaseFallbackApplicable`, `ConvertFrom-CiMergeBaseOutput`. |
| 37 | Docs/docstrings | PASS | Comment-based help on every new function; script `.DESCRIPTION` and `Get-CiChangeScopeContext` help updated. |
| 38 | Comment why, not what | PASS | Comments state why the fallback is limited and why `\z` is used instead of `$`. |
| 39 | Formatting | PASS | `ps-format.2026-10-17T13-37.md`: porcelain unchanged around the MCP formatter; 0 of 7 files differ. |
| 40 | Linting | PASS | `ps-analyze.2026-10-17T13-37.md`: 0 findings. |
| 41 | Type checking | N/A | Not applicable to PowerShell. |
| 42 | Testing | PASS | `ps-tests.2026-10-17T13-39.md` 238/238; full run 11271 passed, 0 failed. |
| 43 | Full toolchain loop in a single pass | PASS | Phase 4 pass 1 completed with no failure and no file changed by a Phase 4 task. One documentation clarity edit to the `### Fail-closed rules` sentence of `.github/workflows/README.md` was made during the pass; no Phase 4 gate reads that file (verified by search of `tests/`), so no gate result depends on it. |
| 44 | Explicit reporting | PASS | One artifact per gate under `FEATURE/evidence/`. |
| 45 | Summarize changes | PASS | Section D below. |
| 46 | Design choices explained | PASS | Spec D1 to D8; script help states fallback limits. |
| 47 | Update supporting documents | PASS | Brief bullet (six copies) and workflows README section updated. |
| 48 | Provide next steps | PASS | AC-24 and AC-25 at S9 ([P5-T4], [P5-T5]); AC-26 post-merge ([P5-T6]). |

### A7. PowerShell code change policy

| # | Item | Status | Evidence |
|---|---|---|---|
| 49 | Formatting with Invoke-Formatter | PASS | See row 39. |
| 50 | Linting with PSScriptAnalyzer | PASS | See row 40. |
| 51 | Fix all findings | PASS | No finding at baseline or after the change. |
| 52 | PowerShell 7+ compatible | PASS | Only core language features and .NET string APIs used; analyzer compatibility rules report no finding. |
| 53 | Advanced functions | PASS | Every new function has `[CmdletBinding()]` and `[OutputType()]`. |
| 54 | Parameter validation | PASS | `Mandatory` and `AllowEmptyString` attributes on all new parameters. |
| 55 | Avoid global state | PASS | No script-scoped mutable state added; data passed explicitly. |
| 56 | Error handling | PASS | Every resolution failure maps to `MERGE_BASE_UNRESOLVED` (`code=true`); the fail-closed envelope is unchanged. |
| 57 | Approved verbs | PASS | Test, ConvertFrom, Find, Get. |
| 58 | Comment why | PASS | See row 38. |
| 59 | Toolchain step 1 format | PASS | See row 39. |
| 60 | Toolchain step 2 analyze | PASS | See row 40. |
| 61 | Toolchain step 3 type check | N/A | Not applicable to PowerShell. |
| 62 | Toolchain step 4 test | PASS | See row 42. |
| 63 | Rerun loop if needed | PASS | One pass; no restart required. |

### A8. JSON configuration

| # | Item | Status | Evidence |
|---|---|---|---|
| 64 | Formatting with format_json | N/A | `config/` is not in `GOVERNED_GLOBS` of `scripts/dev_tools/json_config.py`; the file keeps its #962 layout. |
| 65 | Schema validation | N/A | Same reason; the file is validated by `ConvertFrom-CiDocsOnlyPathConfig` and pinned by `CiDocsOnlyPathsConfig.Tests.ps1` (passing). |
| 66 | Required `$schema` | N/A | Not a governed file. |
| 67 | Strict JSON only | PASS | Parsed by `ConvertFrom-Json` in the config suite and in M4 rows. |
| 68 | Deterministic key order | N/A | Not governed; key order unchanged from the committed file; prefix values are in ordinal order. |

### A9. PowerShell unit test policy

| # | Item | Status | Evidence |
|---|---|---|---|
| 69 | Use Pester v5.x | PASS | `Describe`/`Context`/`It`, `BeforeAll`, `-ForEach` data rows. |
| 70 | Use PoshQC configuration | PASS | Runs through `Invoke-PoshQCTest` with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. |
| 71 | Focused unit tests | PASS | See row 2. |
| 72 | Test behavior over implementation | PASS | Rows assert published Output, Log, and Summary text and recorded invoker calls. |
| 73 | Mocking used sparingly | PASS | No mocks; fakes only. |
| 74 | Organization mirrors code location | PASS | `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1` mirrors `scripts/ci/Invoke-CiChangeScope.ps1`. |
| 75 | File naming `*.Tests.ps1` | PASS | New file follows the convention. |
| 76 | Describe/Context/It structure | PASS | New suite: 1 Describe, 2 Contexts, 12 `It` blocks (28 cases). |
| 77 | Logical grouping | PASS | `merge-base decisions` and `event gates and context`; U rows in a `merge-base fallback helpers` context. |
| 78 | Docstrings/comments | PASS | See row 20. |
| 79 | Use PoshQC test command | PASS | See row 70. |
| 80 | No alternative test runner | PASS | Only Pester is used. The isolation runs call `Invoke-Pester` directly, because `Invoke-PoshQCTest` sorts its scan folders (`Resolve-PoshQCScanFolder` returns them sorted), which would undo the seeded file order; they write the same JUnit path. |

### A10. Test coverage detail, execution metrics, quality checks, gaps

| # | Item | Status | Evidence |
|---|---|---|---|
| 81 | Test coverage detail per function | PASS | Row 10. |
| 82 | Total tests / passed / failed | PASS | Six suites 208/208/0; scan folders 238/238/0; `tests/scripts` 11281 cases, 11271 passed, 0 failed, 10 skipped (skips pre-existing, unchanged from baseline). |
| 83 | Execution time | PASS | About 2.5 s for the six suites; full run about 694 s, comparable to the 745 s baseline. |
| 84 | Code quality checks table | PASS | Format, analyze, and test rows above; actionlint exit 0 and 0 findings (`actionlint.2026-10-17T13-40.md`). |
| 85 | Pre-existing failures documented | PASS | None at baseline (`ps-tests-full.2026-10-17T13-25.md`) or after. |
| 86 | Identified gaps | PASS | None in local scope. AC-24, AC-25 (S9) and AC-26 (post-merge) are verified outside this run by design (spec D8). |
| 87 | Approved exceptions | N/A | No exception taken. |
| 88 | Removed or skipped tests | N/A | None removed or skipped. |
| 89 | Temporary artifacts cleanup | PASS | Helper scripts live only under `SCRATCH`; none added to the repository; no `tools/` directory created. |

## B. Code review template

| # | Item | Status | Evidence |
|---|---|---|---|
| 90 | Findings table: Blocker or Major findings | PASS | None found. |
| 91 | PowerShell: what changed well | PASS | Extraction of `Get-CiChangeScopeDiffDecision` removed duplication; existing green-run rows pass unmodified (`git diff --exit-code MB` on `Invoke-CiChangeScope.Tests.ps1` exits 0). |
| 92 | PowerShell: API and safety notes | PASS | `BaseSha` and `BaseRef` are not added to the required-context throw list (spec supplementary decision); `BaseRef` only compared with `-ceq 'main'`. |
| 93 | PowerShell: error handling and logging | PASS | New outcomes flow through `New-CiChangeScopeDecision`; log and summary carry `base=<merge base>` on merge-base diff outcomes (M1, M9). |
| 94 | Test quality: determinism, isolation, speed, diagnostics | PASS | Rows 1 to 4 and 18. |
| 95 | Security: no secrets in code | PASS | No token or credential added; `GH_TOKEN` handling unchanged. |
| 96 | Security: no unsafe command construction | PASS | Git arguments are passed as array elements through the invoker to `Invoke-CiChangeScopeNative`; no `Invoke-Expression`; the base ref never reaches git. |
| 97 | Security: input validation at boundaries | PASS | Merge-base output accepted only as one 40- or 64-character lower-case hex SHA; a malformed base SHA fails at `git cat-file -e` and yields `MERGE_BASE_UNRESOLVED`. |
| 98 | Security: error handling explicit | PASS | Every failure is `code=true`; `code=false` still requires a `DOCS_ONLY_SINCE_` reason. |
| 99 | Security: configuration and path handling | PASS | The allowlist file stays outside the include prefixes (existing row `Test-CiDocsOnlyPath rejects config/ci-docs-only-paths.json` passes); no new exclude needed (no template under the three new trees). |
| 100 | Workflow change: #962 never-skip semantics for merge_group, push, workflow_dispatch | PASS | M11 and the existing event-gate rows pass; the event gate runs before `BaseSha` or `BaseRef` is read. |
| 101 | Workflow change: CI workflow rule (`pwsh` exit codes) | PASS | Only two env lines added; the `run:` block is unchanged and still ends with `exit 0`. |
| 102 | Research log | N/A | No external research needed beyond the committed research document. |

## C. Executor-specified checks

| # | Item | Status | Evidence |
|---|---|---|---|
| 103 | Tonality of new brief, README, help, and test prose | PASS | Plain, factual wording; search of the added lines for hyperbole and casual terms (for example perfect, robust, seamless, simply, easily, guarantee) returns no match. |
| 104 | Mirror byte identity across six brief copies | PASS | `test_brief_copies_are_byte_identical` passes; `cmp` spot checks report identical bytes; brief-copy script compared all five mirrors. |
| 105 | No artifact records an absolute path, drive letter, host name, or scratchpad path | PASS | Search of `FEATURE/evidence/` for drive-letter paths, the user profile path, and the scratchpad directory returns no match; artifacts use `SCRATCH` and `<worktree>`. |
| 106 | Batch budget | PASS | Two production PowerShell files written with Edit; brief copies written by a script. |
| 107 | Process note: task timing | PASS | [P0-T7] and [P0-T8] ran, and the [P1-T1] to [P1-T3] files were written, while the [P0-T6] full run was in progress; check-offs were made in plan order, and the [P0-T6] discovery count (11223) confirms the run used the unchanged tree. |

## D. Feature audit template (AC source `FEATURE/spec.md`)

| # | AC | Status | Evidence |
|---|---|---|---|
| 108 | AC-1 to AC-4 (merge-base skip, non-allowlisted path, rename into and out of the allowlist on both diffs) | PASS | M1, M2, M3, U5 in `pass-after.2026-10-17T13-33.md`. |
| 109 | AC-5 to AC-7 (archive, parallel, epics prefixes with the committed config) | PASS | M4 rows (committed config), U4, config include-prefix rows. |
| 110 | AC-8 to AC-11 (MERGE_BASE_UNRESOLVED causes and output validation) | PASS | M5 (7 rows), U3 (8 rows). |
| 111 | AC-12 (BASE_NOT_PRESENT and BASE_NOT_ANCESTOR fall back) | PASS | M6. |
| 112 | AC-13 (development and epic/x keep NO_FULL_GREEN_RUN, no bare merge-base call) | PASS | M7. |
| 113 | AC-14 (RUN_LIST_FAILED and JOB_LIST_FAILED terminal, no git call) | PASS | M8. |
| 114 | AC-15 (event and fork gates; existing suite unmodified) | PASS | M11; `git diff --exit-code MB` exit 0. |
| 115 | AC-16 and AC-17 (ci.yml env lines; seven-prefix config) | PASS | Workflow rows and config exact-string row. |
| 116 | AC-18 to AC-20 (brief, push-down contract tests, README) | PASS | `python-contract-tests.2026-10-17T13-57.md`; README token search in [P3-T3]. |
| 117 | AC-21 to AC-23 (coverage, file sizes, isolation and full run) | PASS | `ps-tests.2026-10-17T13-39.md`, `file-sizes.2026-10-17T13-40.md`, isolation artifacts, `ps-tests-full-run.2026-10-17T13-56.md`. |
| 118 | AC-24 to AC-26 (S9 and post-merge CI criteria) | N/A | Not verifiable before the pull request exists; orchestrator-owned [P5-T4] to [P5-T6]; left unchecked. |

Output Summary: 118 rows; PASS 106, N/A 12, FAIL 0. No Blocker or Major finding. AC-1 to AC-23 verified locally; AC-24 and AC-25 pending CI at S9; AC-26 post-merge.
