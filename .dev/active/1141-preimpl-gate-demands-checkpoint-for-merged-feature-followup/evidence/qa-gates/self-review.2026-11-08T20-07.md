# Self-Review Against the Audit Templates (issue #1141, [P5-T5])

Timestamp: 2026-11-08T20-07
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against `git diff <merge base of origin/main and HEAD> HEAD` (42 files, 2025 insertions, 103 deletions)
EXIT_CODE: 0
Output Summary:
- 0 FAIL rows. Every applicable checklist item is PASS; items for languages or constructs not in the diff are N/A with the reason.
- AC-1 through AC-20 of spec.md map to evidence below; all 20 are checked off.
- Non-regression: no call admitted before the change is now denied (see `## Admission Non-Regression`).

## Changed Surface

- Production PowerShell: `hook-epic-fan-in.ps1` (four byte-identical copies) and `enforce-orchestration-preimplementation-gate-epic-scope.ps1` (Claude and Codex, each with an equal bundle copy).
- Tests: `tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1` (191 lines added, 0 removed), two new gate-level files (`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.MergedFollowUp.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-merged-follow-up.Tests.ps1`), and the `PINNED_FROZEN_SURFACE_HASHES` constant in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.
- Documentation: epic-orchestrate and orchestrate skills (`.claude`, `.agents`, bundles) and the execution-environment brief (six copies).
- Feature folder: plan, spec check-offs, and evidence. The promoted lifecycle record under `docs/features/potential/promoted/` predates this plan.

## Policy Audit Template

| Section | Item | Result | Evidence |
| --- | --- | --- | --- |
| Coverage Evidence Checklist | PowerShell baseline and post-change coverage artifacts | PASS | evidence/baseline/pester-baseline.2026-11-08T19-20.md; evidence/qa-gates/pester-final.2026-11-08T20-03.md |
| Coverage Evidence Checklist | TypeScript artifacts | N/A | No TypeScript in the diff. |
| Coverage Evidence Checklist | Python coverage artifacts | PASS | evidence/baseline/pytest-baseline.2026-11-08T19-24.md; evidence/qa-gates/pytest-final.2026-11-08T20-06.md |
| 1.1 | Independence | PASS | New suites register mocks per Context `BeforeEach`, use no shared mutable state; both parallel gates passed with zero failures. |
| 1.1 | Isolation | PASS | One behavior per `It`; `-ForEach` tables name each case. |
| 1.1 | Fast execution | PASS | Debug runs: 263 unit rows and 466 gate rows each completed in seconds; no sleeps. |
| 1.1 | Determinism | PASS | Synthetic `/synthetic-worktrees/` roots, mocked resolver seams and staged-index reader; hex values built by repetition. |
| 1.1 | Readability | PASS | Descriptive `It` names; Arrange/Act/Assert comments in the gate suites. |
| 1.2 | Baseline coverage documented | PASS | Repo 95.66%; hook-epic-fan-in.ps1 100.00% both copies; epic-scope 97.60% (Claude) and 97.92% (Codex). |
| 1.2 | No coverage regression | PASS | Repo 95.67%; fan-in 100.00%; epic-scope 97.66% and 97.96%. Python 97.11% line / 94.37% branch versus 97.11% / 94.36%. |
| 1.2 | Changed files meet thresholds | PASS | All four measured PowerShell files at or above 97.66% (threshold 85%). |
| 1.2 | New code coverage >= 90% | PASS | 54/54 changed lines in each hook-epic-fan-in.ps1 copy; 3/3 in each epic-scope file (100%). |
| 1.2 | Comprehensive coverage | PASS | Every new or changed function has unit rows (Get-EpicMergedFeatureRoots, Test-EpicMergedFeaturePath, Get-EpicMergedFeatureFollowUpAllowance, generalized shape/index/allowance). |
| 1.2 | Positive flows | PASS | Qualifying prefix forms, JSON-parsed feature, [long] pr_number, path/add/commit/pathless allows on both surfaces. |
| 1.2 | Negative flows | PASS | Each qualification conjunct refused (status, slug, sha case/length/type/absence, pr_number string/0/-1/null/7.5/$true/absence). |
| 1.2 | Edge cases | PASS | Bare root, missing trailing slash, sibling prefix, status doc plus remainder, empty and blank root lists, `--` with no operand, blank staged name. |
| 1.2 | Error handling | PASS | Throwing staged-index reader and unreadable route_id both answer not allowed with `allowance error:` detail. |
| 1.2 | Concurrency | N/A | Pure functions; no concurrent behavior. |
| 1.2 | State transitions | N/A | No stateful component. |
| 1.3 | Clear failure messages | PASS | `-Because` carries the decision reason on allow rows and the case name on deny rows. |
| 1.3 | Arrange-Act-Assert | PASS | Gate suites carry explicit section comments. |
| 1.3 | Document intent | PASS | File-level `.SYNOPSIS`/`.DESCRIPTION` in every new test file. |
| 1.4 | Avoid external dependencies | PASS | No git, gh, network, or process in tests; the AST scan reads the hook file only. |
| 1.4 | Use mocks/stubs | PASS | Resolver seams, `Get-OrchestrationGateStagedIndex`, and injected reader script blocks. |
| 1.4 | Environment stability | PASS | No temp files, no global state; leak scan 0 failures with no allowlist change. |
| 1.5 | Pre-submission review | PASS | This artifact. |
| 2.1 | Clarify objective / read plans / document plan | PASS | spec.md, plan.2026-11-08T13-26.md, per-task commits. |
| 2.2 | Simplicity, reusability, extensibility, separation | PASS | The allowance reuses Get-EpicFanInAllowance through two optional predicates; no command-leg parser duplicated; pure functions, I/O only through the injected reader. |
| 2.3 | Cohesive modules | PASS | Fan-in and follow-up allowances share one pure file. |
| 2.3 | At or below the 800-line hard limit | PASS | hook-epic-fan-in.ps1 488 (cap 500 by its own contract test); epic-scope 402/462; unit tests 473; new tests 296/186. |
| 2.3 | Public vs internal / no circular dependencies | PASS | New functions consumed only by the epic-scope decision and tests; no new dot-source. |
| 2.4 | Descriptive names / docs / comments | PASS | Comment-based help on every new function; one intent comment on the predicate's scope-chain read. |
| 2.5 | Formatting / linting / type check / testing / loop / reporting | PASS | evidence/qa-gates/powershell-static.2026-11-08T19-53.md (0 drift, 0 findings); python-static.2026-11-08T19-53.md (0/0/0); final gates green. One analyzer finding (PSUseSingularNouns on the spec-fixed name Get-EpicMergedFeatureRoots) was resolved during [P2-T2] with a justified SuppressMessageAttribute before the final loop. |
| 2.6 | Summarize / design choices / supporting docs / next steps | PASS | Skills and brief updated; plan Design Summary; next step is PR authoring and CI. |
| 3A | Python tooling | PASS | Black, Ruff, Pyright clean on the one changed Python file. |
| 3A | Python design, typing, error handling | N/A | Only a string constant and a comment changed; no new Python code. |
| 3B.1 | Invoke-Formatter / PSScriptAnalyzer / fix findings | PASS | See 2.5. |
| 3B.1 | PowerShell 5.1 and 7.6+ compatible | N/A | Repository PowerShell policy targets PowerShell 7+; hook files are PowerShell 7 only. |
| 3B.2 | Advanced functions / parameter validation | PASS | `[CmdletBinding()]`, `[OutputType()]`, `AllowNull`/`AllowEmptyString`/`AllowEmptyCollection` attributes. |
| 3B.2 | Avoid global state | PASS | No new script-scope variable in production; tests use none beyond existing `$script:` fixtures. |
| 3B.2 | Error handling | PASS | Allowance wrapped in try/catch that answers not allowed with detail; deny-side text unchanged. |
| 3B.3 | Approved verbs / comments | PASS | Get-, Test- verbs only. |
| 3B.4 | Toolchain steps and rerun loop | PASS | Format, analyze, test; no rerun needed in the final loop. |
| 3C | Bash | N/A | No bash in the diff. |
| 3D | JSON | N/A | No JSON in the diff. |
| 4A | Python unit tests | PASS | pytest -n auto: 16560 passed, 0 failed; no alternative runner. |
| 4B.1 | Pester v6 via PoshQC configuration | PASS | One Invoke-PoshQCParallelTest per gate. |
| 4B.2 | Focused tests, behavior over implementation, sparing mocks | PASS | Gate rows assert decisions and deny text; mocks are limited to resolver and index seams. |
| 4B.2 | Organization (mirror location) | PASS | Hook tests live under tests/scripts/claude-hooks and tests/scripts/codex-hooks, the established locations for these hooks. |
| 4B.3 | File naming, structure, grouping, comments | PASS | `*.Tests.ps1`; Describe/Context/It grouping by function and outcome. |
| 4B.4 | Use PoshQC test command / no alternative runner | PASS | Gate evidence from Invoke-PoshQCParallelTest only; focused runs were debugging only. |
| 6-7 | Execution metrics and code quality checks | PASS | Pester 20452 passed / 0 failed (527.08s); pytest 16560 passed / 0 failed (165.24s). |
| CI Cross-check | Claimed outcomes | PASS | poshqc / PowerShell QC: pass (local final gate); quality-checks7 / Code Quality & Tests (3.13): pass, 97.11% line (local final gate). CI at the PR head is read by the orchestrator. |
| 8 | Gaps / exceptions / removed tests | PASS | No gaps; no test removed or skipped; one justified analyzer suppression. |

## Code Review Template

| Item | Result | Evidence |
| --- | --- | --- |
| Findings table | PASS | No Blocking or Warning finding. Informational: Test-EpicFanInStagedIndex now admits a NUL list with duplicate status-doc names in default mode; git never emits duplicates and this only widens admission. |
| PowerShell implementation: what changed well | PASS | Predicate injection keeps one command-leg parser; disjunct is allow-side only. |
| PowerShell API and safety | PASS | Optional parameters with defaults; existing callers unchanged. The follow-up predicate reads its roots through the caller scope chain, documented inline. |
| PowerShell error handling and logging | PASS | try/catch returns a detail string; no silent swallow of deny paths. |
| Python / TypeScript / C# implementation | N/A | Not in the diff (Python change is a pinned constant). |
| Test quality: determinism, isolation, speed, diagnostics | PASS | See policy section 1. |
| No secrets in code | PASS | None. |
| No unsafe subprocess or command construction | PASS | No process started; tokens come from the existing tokenizer. |
| Input validation at boundaries | PASS | Paths refused on backslash, glob, `.`/`..`, leading `/`; sha and pr_number type-checked. |
| Error handling remains explicit | PASS | Any error answers not allowed. |
| Configuration / path handling is safe | PASS | Trailing-slash roots prevent sibling-prefix matches; case-sensitive ordinal comparison. |

## Feature Audit Template

| AC | Result | Evidence |
| --- | --- | --- |
| AC-1 fail-before | PASS | evidence/regression-testing/fail-before.2026-11-08T19-39.md (EXIT_CODE 1, ExpectedExitCode 1; both named rows deny with 'merge-in-progress'). |
| AC-2 allows on both surfaces | PASS | Claude `fail-before`/`allows` rows (11) and Codex rows (7) pass in pester-final. |
| AC-3 qualification conjuncts | PASS | `Context 'Get-EpicMergedFeatureRoots'` rows, both copies. |
| AC-4 missing merge_commit_sha denied | PASS | child-d rows, both surfaces. |
| AC-5 missing pr_number denied | PASS | child-e rows, both surfaces. |
| AC-6 non-terminal status denied | PASS | child-b rows. |
| AC-7 hand-authored checkpoint ignored | PASS | Claude row with `lifecycle_ready: true`; `It 'reads no per-item checkpoint and touches no file'`. |
| AC-8 deny shapes with unchanged text | PASS | `Context 'denies with unchanged text'` (-BeExactly) and `Context 'denies'`. |
| AC-9 exact failure only | PASS | epic_manifest_path rows, both surfaces. |
| AC-10 admitted calls stay admitted | PASS | `already admitted` rows; #1136 EpicFanIn and #539 CommandExemption suites pass unchanged. |
| AC-11 deny texts byte-unchanged | PASS | -BeExactly rows and outside-epic-scope rows. |
| AC-12 generalization in the same file | PASS | Shape/index/allowance predicates; existing #1136 unit rows unchanged and passing. |
| AC-13 unit rows and coverage | PASS | 100% changed-line coverage; no file drop. |
| AC-14 copies identical | PASS | Four equal fan-in hashes; epic-scope bundles equal; no hook file added. |
| AC-15 epic-orchestrate docs | PASS | [P4-T1] commit; four copies equal. |
| AC-16 orchestrate pointer | PASS | [P4-T2] commit; no `.github` copy created. |
| AC-17 brief six copies | PASS | Six equal hashes containing `(#1141)`. |
| AC-18 pinned digest | PASS | evidence/other/codex-generator-check.2026-11-08T19-52.md. |
| AC-19 contract tests and generator | PASS | pytest-final named tests pass; Pester wording and guard suites pass in pester-final; generator `--check` exit 0. |
| AC-20 parallel-only verification, no new Python | PASS | One run per gate; no added `.py` file. |

## Admission Non-Regression

- The plug-in adds a second `if` that can only return `''` (allow) for a target whose failure is already `merge-in-progress`; it never turns an allow into a deny, and every other failure returns unchanged.
- With no predicate supplied, Get-EpicFanInShapeDetail, Test-EpicFanInCommitShape, Test-EpicFanInStagedIndex, and Get-EpicFanInAllowance accept a superset of the previous #1136 shapes (one or more operands each equal to the status document instead of exactly one), so no previously admitted #1136 call is refused.

### Acceptance Criteria Status
- Source: docs/features/active/2026-11-08-preimpl-gate-demands-checkpoint-for-merged-feature-followup-1141/spec.md
- Total AC items: 20
- Checked off (delivered): 20
- Remaining (unchecked): 0
- Items remaining: none
