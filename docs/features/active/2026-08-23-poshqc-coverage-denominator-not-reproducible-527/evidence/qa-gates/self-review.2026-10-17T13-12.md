# Self-Review, Round 2 Evidence-Only Closure of #527 (P6-T1)

Timestamp: 2026-10-17T13-12
Command: walk of the three templates `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, and `feature-audit.yyyy-MM-ddTHH-mm.md` against the branch diff, using git diff --name-status origin/main...HEAD, git status --porcelain --untracked-files=all, git diff HEAD --stat, and text searches over this run's evidence files (absolute-path tokens, hyperbole words, secret patterns, required command-step fields)
EXIT_CODE: 0
Output Summary: every checklist item of the three templates was walked and given one PASS, FAIL, or N/A row. The summary line at the end of this file carries the FAIL row count. No row is FAIL, so no artifact was rewritten.

Branch diff under review (merge base of origin/main and HEAD, plus the worktree state):

- Committed on the branch: `plan.2026-10-17T08-20.md` (A), `research/research.2026-10-17T12-35.md` (A), `evidence/other/preflight-fixes.2026-10-17T12-43.md` (A), `spec.md` (M, the round 2 revision section and acceptance criteria).
- Worktree changes from this execution: `plan.2026-10-17T08-20.md` (task checkboxes only), `spec.md` (four acceptance-criterion checkboxes: AC-11, AC-12, AC-13, AC-19), and 22 new evidence files under `evidence/baseline/`, `evidence/qa-gates/`, and `evidence/regression-testing/`, including this file; the final scope check (P6-T2) adds `evidence/qa-gates/scope-check.<timestamp>.md` after this review.
- Every path is Markdown inside the feature folder. No Python, TypeScript, C#, PowerShell, Bash, JSON, workflow, test, configuration, or mirror file changed. The scratch helpers (`.ps1` and `.sh`) live in SCRATCH outside the repository and are not part of the diff.
- Verification runs wrote ignored output only (`artifacts/pester/` and `tests/fixtures/poshqc-consumer/artifacts/`, both gitignored).

## A. Policy Audit Template

Reason for N/A rows: this round changes no code, test, or configuration file, so code-language, coverage, and toolchain items do not apply. The plan states this under `## Final QA Applicability`.

### A.0 Header and coverage rules

| Item | Result | Basis |
| --- | --- | --- |
| Code Under Test listing | PASS | No code under test; the changed files are the Markdown files listed above. |
| Coverage Metrics table, Python row | N/A | No Python file changed. |
| Coverage Metrics table, PowerShell row | N/A | No PowerShell file changed. The evidence runs measured the existing denominator (215 files, root LINE total 19095) and recorded it without a threshold change. |
| Coverage Metrics table, Bash row | N/A | No Bash file changed. |
| Coverage Metrics table, JSON row | N/A | No JSON file changed. |
| Coverage Evidence Checklist (TypeScript and PowerShell baseline and post-change artifacts, per-language comparison) | N/A | No language is in scope for coverage; there is no change to compare. |
| Non-negotiable verdict rule (numeric coverage for every language in scope) | N/A | The set of languages in scope is empty. |
| Fail-closed rule (missing baseline, QA, or comparison artifact) | PASS | Every artifact the plan names exists; the one pending leg (AC-01 CI comparison) is recorded as PENDING-CI, not as a pass. |
| Evidence rule (no backfilled evidence) | PASS | Round 1 evidence is cited by file name and marked as round 1; round 2 results come from runs made in this execution. |

### A.1 Executive summary items

| Item | Result | Basis |
| --- | --- | --- |
| Policy documents evaluated: general-code-change | PASS | Read in P0-T1 (`phase0-instructions-read.2026-10-17T12-56.md`). |
| Policy documents evaluated: general-unit-test | PASS | Read in P0-T1. |
| Language policy: Python | N/A | No Python in scope. |
| Language policy: PowerShell | N/A | No PowerShell file changed; PowerShell was run as a verification tool only. |
| Language policy: Bash | N/A | No Bash file changed in the repository. |
| Language policy: JSON | N/A | No JSON file changed. |
| Temporary artifacts: scripts created during development deleted or kept with tests | PASS | Four helpers plus utilities were created in SCRATCH outside the repository; none is committed. The repository file-size exception for throwaway session scripts applies. |
| Temporary artifacts: ongoing tooling scripts tested and compliant | N/A | No ongoing tooling script was added to the repository. |

### A.2 Section 1, General Unit Test Policy

| Item | Result | Basis |
| --- | --- | --- |
| 1.1 Independence | PASS | Three seeded shuffled file-order runs report zero failures in each (`order-independence-summary.2026-10-17T13-09.md`). |
| 1.1 Isolation | N/A | No test added or changed. |
| 1.1 Fast execution | N/A | No test added or changed. |
| 1.1 Determinism | PASS | Runs A, B, and C and three shuffled runs give identical key sets and root LINE totals. |
| 1.1 Readability and maintainability | N/A | No test added or changed. |
| 1.2 Baseline coverage documented | N/A | No code change; no coverage gate applies. |
| 1.2 No coverage regression | N/A | No code change. |
| 1.2 New code coverage at least 90 percent | N/A | No new code. |
| 1.2 Comprehensive coverage | N/A | No new code. |
| 1.2 Positive flows | N/A | No test added. |
| 1.2 Negative flows | N/A | No test added. |
| 1.2 Edge cases | N/A | No test added. |
| 1.2 Error handling | N/A | No test added. |
| 1.2 Concurrency | N/A | Not applicable to this change. |
| 1.2 State transitions | N/A | Not applicable to this change. |
| 1.2.1 Per-language coverage comparison | N/A | No language in scope. |
| 1.3 Clear failure messages | N/A | No test added. |
| 1.3 Arrange-Act-Assert | N/A | No test added. |
| 1.3 Document intent | N/A | No test added. |
| 1.4 Avoid external dependencies | PASS | The verification runs used the local filesystem and the installed Pester; no network or external service. |
| 1.4 Use mocks and stubs | N/A | No test added. |
| 1.4 Environment stability | PASS | No temporary file is created by any test; run output went to gitignored `artifacts/` paths, and `git status --porcelain` for the fixture stayed empty. |
| 1.5 Pre-submission review | PASS | This document is the pre-submission review. |

### A.3 Section 2, General Code Change Policy

| Item | Result | Basis |
| --- | --- | --- |
| 2.1 Clarify the objective | PASS | Issue #527, round 2 revision section of `spec.md`. |
| 2.1 Read existing change plans | PASS | Round 1 plan, remediation plan, and the round 2 plan were read. |
| 2.1 Document the plan | PASS | `plan.2026-10-17T08-20.md`. |
| 2.2 Simplicity first | PASS | Evidence-only closure; no production change. |
| 2.2 Reusability | PASS | Existing `Invoke-PoshQCTest` and existing fixture reused unchanged. |
| 2.2 Extensibility | N/A | No design change. |
| 2.2 Separation of concerns | N/A | No design change. |
| 2.3 Cohesive modules | N/A | No module added. |
| 2.3 Under 500 lines | PASS | Markdown is exempt from the limit; the largest new file is this self-review at 216 lines. The scratch helpers, outside the repository, are each under 120 lines (the longest, `issue-527-compare.ps1`, has 88). |
| 2.3 Public versus internal | N/A | No API change. |
| 2.3 No circular dependencies | N/A | No code change. |
| 2.4 Descriptive names | PASS | Evidence files follow `<name>.<timestamp>.md`; labels `run-a`, `run-b`, `run-c`, `shuffle-<seed>`, `fixture`. |
| 2.4 Docs and docstrings | N/A | No code added. |
| 2.4 Comment why, not what | N/A | No code added. |
| 2.5 Formatting | N/A | No formattable source file changed. |
| 2.5 Linting | N/A | No source file changed. |
| 2.5 Type checking | N/A | Not applicable for PowerShell or Markdown. |
| 2.5 Testing | PASS | The existing PoshQC Pester suite ran six times in this execution (runs A, B, C and three shuffled runs): 195 test cases per run, 0 failures. |
| 2.5 Full toolchain loop | N/A | No code or configuration file changed; see the plan section `Final QA Applicability`. |
| 2.5 Explicit reporting | PASS | Each command step has `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. |
| 2.6 Summarize changes | PASS | Section above and `ac-verification.2026-10-17T13-11.md`. |
| 2.6 Design choices explained | PASS | The plan records the evidence-only decision and the shuffle-by-container method. |
| 2.6 Update supporting documents | PASS | `spec.md` acceptance criteria checkboxes updated for AC-11, AC-12, AC-13, AC-19; no README change is needed. |
| 2.6 Provide next steps | PASS | AC-01 CI leg is assigned to the orchestrator at S9 in `ci-leg-pending.2026-10-17T13-03.md`. |

### A.4 Sections 3 and 4, language-specific policies

| Item | Result | Basis |
| --- | --- | --- |
| 3A Python tooling (Black, Ruff, Pyright, Pytest) | N/A | No Python file changed. |
| 3A Python design and typing (4 items) | N/A | No Python file changed. |
| 3A Python error handling (3 items) | N/A | No Python file changed. |
| 3B PowerShell tooling (formatter, analyzer, findings, 5.1 and 7.6 compatibility) | N/A | No PowerShell file changed in the repository. |
| 3B PowerShell design and safety (4 items) | N/A | No PowerShell file changed in the repository. |
| 3B PowerShell structure, naming, comments (3 items) | N/A | No PowerShell file changed in the repository. |
| 3B Running the toolchain (format, analyze, test, rerun) | N/A | No PowerShell file changed in the repository. |
| 3C Bash tooling and design (6 items) | N/A | No Bash file changed in the repository. |
| 3D JSON tooling and structure (5 items) | N/A | No JSON file changed. |
| 4A Python unit test policy (9 items) | N/A | No Python test changed. |
| 4B PowerShell unit test policy: framework and scope (3 items) | N/A | No PowerShell test added or changed; the existing suite ran through `Invoke-PoshQCTest`-based flows only. |
| 4B PowerShell unit test policy: style, naming, toolchain (10 items) | N/A | No PowerShell test added or changed. |

### A.5 Sections 5 to 10

| Item | Result | Basis |
| --- | --- | --- |
| 5 Test coverage detail | N/A | No function, class, or module added. |
| 6 Test execution metrics | PASS | 195 test cases per run, 0 failures in six runs; 18 test files; population 215 files; root LINE total 19095. Per-test timing is not recorded because no timing gate applies. |
| 7 Code quality checks (Python and PowerShell tables) | N/A | No source file changed. |
| 8 Identified gaps | PASS | One gap recorded: the AC-01 CI comparison is pending until S9 (CI-dependent criterion). |
| 8 Approved exceptions | PASS | None. |
| 8 Removed or skipped tests | PASS | None. |
| 9 Commits in this branch | PASS | Round 2 documentation commits only; this execution does not commit. |
| 9 Files modified | PASS | Listed under `Branch diff under review`. |
| 10 Compliance verdict | PASS | Compliant within the round 2 scope; the CI-dependent AC-01 leg is outstanding. |
| 10 Policy-by-policy summary | PASS | Code, language, and test sections are N/A for the reason above; the general sections are PASS. |
| 10 Metrics summary | PASS | See section 6 row. |
| 10 Recommendation | PASS | Ready for the orchestrator to commit and open the pull request; AC-01 is checked after the CI full run at S9. |
| 10 Fail-closed reminder | PASS | AC-01 is not reported as met. |
| Appendix A test inventory | N/A | No test added. |
| Appendix B toolchain commands | N/A | No toolchain command applies to Markdown-only changes. |

## B. Code Review Template

| Item | Result | Basis |
| --- | --- | --- |
| Header: review date, feature folder, base branch `main`, head branch `bug/poshqc-coverage-denominator-527-r2`, review type | PASS | Base `main`; head is the round 2 branch; type is initial review of the evidence-only closure. |
| Executive summary: what changed | PASS | Markdown evidence plus four checkbox changes in `spec.md`. |
| Executive summary: top risks | PASS | (1) AC-01 CI leg unmatched at S9; (2) the CI base run may be docs-only and skipped, so the newest full CI run must be used; (3) round 1 criteria were not re-verified in round 2. |
| PR readiness recommendation | PASS | Conditional Go: ready to commit; AC-01 pending CI. |
| Findings table: Blocker | PASS | None found. |
| Findings table: Major | PASS | None found. |
| Findings table: Minor | PASS | Info only: the first shuffle launch of seed 527 exited 1 because of a scratch helper defect; the helper was corrected and the seed re-run (recorded in the seed 527 artifact). |
| Python implementation audit | N/A | No Python in the diff. |
| TypeScript implementation audit | N/A | No TypeScript in the diff. |
| PowerShell implementation audit | N/A | No PowerShell in the diff. |
| C# implementation audit | N/A | No C# in the diff. |
| Test quality: reviewed artifacts listed | PASS | Run, comparison, fixture, hygiene, and order-independence artifacts reviewed. |
| Test quality: determinism | PASS | Identical results across three directories and three shuffle seeds. |
| Test quality: isolation | PASS | Each run used its own labeled SCRATCH directory; the launcher removes prior coverage and JUnit outputs before each run. |
| Test quality: speed | PASS | Each suite run completed within one tool call. |
| Test quality: diagnostics | PASS | Each artifact records counts, the key-set hash, and per-file differences. |
| Security: no secrets in code | PASS | Search for secret patterns over this run's evidence files returned no match. |
| Security: no unsafe subprocess or command construction | PASS | Scratch launchers pass quoted literal arguments; no repository file runs a subprocess. |
| Security: input validation at boundaries | N/A | No boundary code changed. |
| Security: error handling explicit | PASS | A failing exit is recorded (the first seed 527 launch) rather than hidden. |
| Security: configuration and path handling safe | PASS | Search for absolute-path, host, and scratchpad tokens over this run's evidence files returned no match; paths are recorded as `<ROOT>` and SCRATCH. |
| Research log | PASS | No external research; local runs only. |
| Verdict consistent with findings table | PASS | No Blocker or Major finding; conditional on the AC-01 CI leg. |

## C. Feature Audit Template

| Item | Result | Basis |
| --- | --- | --- |
| Header: work mode `full-bug`, audit type | PASS | Work mode full-bug; type is initial acceptance review of the round 2 closure. |
| Scope: base and head branches, merge base | PASS | Merge base recorded in `base-ref.2026-10-17T12-56.md`. |
| Scope: evidence sources | PASS | The feature folder `evidence/` tree. |
| Scope: requirements source | PASS | `spec.md` section `## Acceptance Criteria` only. |
| Scope: work mode resolution note | PASS | Work mode is full-bug per the plan header; the AC source is `spec.md`. |
| AC inventory: 19 criteria transcribed | PASS | The inventory is the 19 checkbox items of `spec.md`, enumerated in `ac-verification.2026-10-17T13-11.md`. |

Acceptance criteria evaluation. Result column is the row check of this self-review; Status is the feature-audit status of the criterion.

| AC | Status | Result | Evidence inspected |
| --- | --- | --- | --- |
| AC-01 Deterministic derivation | PARTIAL | PASS | Local legs met (`determinism-comparison.2026-10-17T13-03.md`); CI leg pending (`ci-leg-pending.2026-10-17T13-03.md`); checkbox left unchecked as required. |
| AC-02 Route independence | PASS | PASS | Round 1 evidence present with the recorded exit codes (fail-first exit 1 expected 1; pass-after exit 0); not re-run in round 2. |
| AC-03 Derived population contents | PASS | PASS | Round 1 `pass-after-new-tests` exit 0; not re-run in round 2. |
| AC-04 Precedence order | PASS | PASS | Round 1 `pass-after-new-tests` exit 0; not re-run in round 2. |
| AC-05 Observability | PASS | PASS | Round 1 `pass-after-invokesummary` exit 0; not re-run in round 2. |
| AC-06 Config validation | PASS | PASS | Round 1 `fail-first-coverageconfig-tests` and `pass-after-named-tests`; not re-run in round 2. |
| AC-07 Absolute root | PASS | PASS | Round 1 `pass-after-named-tests` exit 0; not re-run in round 2. |
| AC-08 Allow-list removed | PASS | PASS | Round 1 `runsettings-shape` exit 0; not re-run in round 2. |
| AC-09 Parity preserved | PASS | PASS | Round 1 `parity-after-mirror` and `final-python-pytest-parity` exit 0; not re-run in round 2. |
| AC-10 Config file and source `config` | PASS | PASS | Round 1 `coverage-config` exit 0; round 2 runs log `source=config`. |
| AC-11 Consumer fixture coverage | PASS | PASS | `post-fix-fixture-run.2026-10-17T13-04.md` (1 file, 0 failures), `post-fix-fixture-check.2026-10-17T13-04.md` (covered LINE count 2), `fail-first-reference.2026-10-17T13-04.md`. |
| AC-12 Consumer isolation | PASS | PASS | `post-fix-fixture-check.2026-10-17T13-04.md` (package `scripts`, stand-in absent, 0 outside). |
| AC-13 Fixture output hygiene | PASS | PASS | `fixture-output-hygiene.2026-10-17T13-04.md` (porcelain empty before and after). |
| AC-14 New code coverage | PASS | PASS | Round 1 `coverage-new-code` and `coverage-aggregate` exit 0; not re-run in round 2. |
| AC-15 Existing suite | PASS | PASS | Round 1 final format, analyze, and test artifacts exit 0; round 2 runs add six more suite runs with 0 failures. |
| AC-16 Documentation | PASS | PASS | Round 1 `readme-documentation` exit 0; not re-run in round 2. |
| AC-17 No temporary files in tests | PASS | PASS | Round 1 `test-purity` records the banned-token count 0 with expected exit 1 (no match); the hook was verified by non-denial, as that artifact states; not re-run in round 2. |
| AC-18 File size limits | PASS | PASS | Round 1 `line-limits` exit 0; not re-run in round 2. |
| AC-19 Order independence | PASS | PASS | `order-independence-summary.2026-10-17T13-09.md` and the three seed artifacts. |

| Item | Result | Basis |
| --- | --- | --- |
| Summary: overall readiness | PASS | Criteria summary: 18 PASS, 1 PARTIAL (AC-01, CI-dependent), 0 UNVERIFIED, 0 FAIL. Overall readiness is pending the AC-01 CI leg only. |
| Summary: top gaps | PASS | AC-01 CI comparison at S9. |
| Summary: follow-up verification steps | PASS | Compare file count, root LINE total, and key hash with the newest full CI run of the PR head. |
| Check-off: PASS criteria checked, others unchecked | PASS | `spec.md` shows 18 checked and AC-01 unchecked; the four round 2 changes are exactly AC-11, AC-12, AC-13, AC-19 (`git diff HEAD` over `spec.md` shows four changed lines). |
| AC status summary table | PASS | Source `spec.md`; total 19; checked 18; unchecked 1 (Deterministic derivation). |

## Summary

Rows walked: policy-audit template (sections A.0 to A.5), code-review template (section B), feature-audit template (section C).
PASS and N/A rows only; the N/A rows carry the no-code-change reason.

FAIL_ROWS: 0
