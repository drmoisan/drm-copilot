# Self-review: epic-child PR merges without CI (#1130) (P5-T4)

Timestamp: 2026-11-08T15-04
Command: git diff <merge-base of origin/main and HEAD> HEAD, walked against docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md
EXIT_CODE: 0
Output Summary:
- Scope: branch bug/epic-child-pr-ci-required against the merge base of origin/main and HEAD (origin/main equals the merge base after the P5-T1 merge, which reported "Already up to date"). 50 files outside the feature folder: 2 new helpers plus 2 bundle copies, 2 gates plus 2 bundle copies, 2 pack manifests, 2 new suites, 12 edited test files and 1 edited Python test-support file, 9 skill and rule sources and their bundle copies, and the 6 execution-environment brief copies.
- Result: no FAIL row. All rows are PASS or N/A.

## Policy audit checklist

| Item | Result | Evidence |
|---|---|---|
| 1.1 Independence | PASS | Every new row mocks its seams per It or in BeforeAll; no shared mutable state; the gate runs 8 parallel shards with 0 failures. |
| 1.1 Isolation | PASS | One stage per row: 15 stage deny rows, 3 allow rows, and direct rows per pure helper and seam in each suite. |
| 1.1 Fast execution | PASS | The focused debug run of the Claude suite finished in seconds; no row waits or reads a clock. |
| 1.1 Determinism | PASS | Fixed object ids and fixed DateTime values; Invoke-DocsOnlyGhExe and the child-CI seams are mocked; no network or process. |
| 1.1 Readability | PASS | Row names CHILD-CI-STAGE<N>-<CASE> and RGC-CHILD-CI-*; Arrange/Act/Assert comments. |
| 1.2 Baseline coverage documented | PASS | pester-baseline.2026-11-08T13-29.md, pester-per-file-coverage.2026-11-08T13-52.md, pytest-baseline.2026-11-08T13-27.md. |
| 1.2 No coverage regression | PASS | PowerShell 95.56% -> 95.58%; Claude gate 98.60% -> 98.63%; Codex gate 99.40% -> 99.43%; scripts 94% -> 94% (pester-final.2026-11-08T15-01.md, pytest-final.2026-11-08T15-03.md). |
| 1.2 Changed files meet thresholds | PASS | Both gates above 85%; both helper copies 100.00% and 97.59%. |
| 1.2 New code coverage >= 90% | PASS | New helper copies 100.00% (83/83) and 97.59% (81/83). |
| 1.2 Comprehensive coverage | PASS | Every helper function has direct or gate-row tests: Test-EpicMergeGateChildCiObjectId, Test-EpicMergeGateChildCiPositiveInteger, Get-EpicMergeGateChildCiProperty, Get-EpicMergeGateChildCiPrNumber, both seams, Select-EpicMergeGateChildCiRun, Get-EpicMergeGateChildCiFailureDetail, Get-EpicMergeGateChildCiDecision. |
| 1.2 Positive flows | PASS | Allow rows: green pull_request run, recorded workflow_dispatch run, bare command with recorded PR, in both suites. |
| 1.2 Negative flows | PASS | Deny rows for every stage in both suites (spec stage list). |
| 1.2 Edge cases | PASS | Uppercase and short head_sha, 41-character id, string and zero pr_number, unreadable createdAt, empty run list, tie on createdAt resolved by databaseId. |
| 1.2 Error handling | PASS | gh non-zero exit, malformed output, non-array document, seam throw (decision returns a deny, never throws). |
| 1.2 Concurrency | N/A | The helper holds no shared state. |
| 1.2 State transitions | N/A | No stateful component. |
| 1.2.1 Per-language comparison | PASS | PowerShell: 95.56% -> 95.58% line, new code 100.00%/97.59%. Python: 94% -> 94%, no production Python change. |
| 1.3 Clear failure messages | PASS | Assertions carry -Because with the observed reason. |
| 1.3 Arrange-Act-Assert | PASS | New rows use the three comment markers. |
| 1.3 Document intent | PASS | Suite .DESCRIPTION blocks state scope; each mock added to an existing suite carries a one-line reason naming issue #1130. |
| 1.4 Avoid external dependencies | PASS | No gh, git, or network; synthetic forward-slash roots. |
| 1.4 Use mocks/stubs | PASS | Invoke-DocsOnlyGhExe, the two child-CI seams, checkpoint read seams, and resolution seams. |
| 1.4 Environment stability | PASS | No temporary files; Invoke-PoshQCLeakScan 0 failures. |
| 1.5 Pre-submission review | PASS | This artifact. |
| 2.1 Clarify objective / read plans / document plan | PASS | spec.md, research record, plan.2026-11-08T08-08.md. |
| 2.2 Simplicity | PASS | One helper with six ordered stages; each gate gains one dot-source line and one call. |
| 2.2 Reusability | PASS | One byte-identical helper shared by both runtimes; reuses Invoke-DocsOnlyGhExe. |
| 2.2 Extensibility | PASS | Stage detail strings and the entry contract (Verified, Reason) are stable; the workflow name is one literal. |
| 2.2 Separation of concerns | PASS | Pure helpers are separate from the two gh seams. |
| 2.3 Cohesive modules | PASS | Helper holds only child-CI verification. |
| 2.3 800-line hard limit | PASS | Claude gate 500 (also within the 500-line cap of session-root-reads-850.Constraints.Tests.ps1), Codex gate 436, helper 315; largest edited test file 475. No file at or above 700. |
| 2.3 Public vs internal | PASS | Entry is Get-EpicMergeGateChildCiDecision; the failure-detail function is internal to it. |
| 2.3 No circular dependencies | PASS | The helper dot-sources nothing. |
| 2.4 Descriptive names | PASS | EpicMergeGateChildCi prefix on every function. |
| 2.4 Docs/docstrings | PASS | Comment-based help on every helper function and a file header listing the six stages. |
| 2.4 Comment why | PASS | Comments explain fail-closed choices (unreadable output, seam throw, unknown createdAt order). |
| 2.5 Formatting | PASS | Invoke-Formatter: 0 of 22 PowerShell files differ; Black: 1 file would be left unchanged (static-final.2026-11-08T14-22.md). |
| 2.5 Linting | PASS | PSScriptAnalyzer 0 findings after the loop fixed 5; Ruff: All checks passed. |
| 2.5 Type checking | PASS | Pyright 0 errors on the edited Python file; N/A for PowerShell. |
| 2.5 Testing | PASS | Invoke-PoshQCParallelTest exit 0 (19680 tests, 0 failures); pytest -n auto 16537 passed, 0 failed. |
| 2.5 Full toolchain loop | PASS | Static loop restarted twice; Pester gate re-run once after the guard-suite fix, with the static loop re-run on the edited files. |
| 2.5 Explicit reporting | PASS | Evidence artifacts under evidence/baseline, regression-testing, and qa-gates. |
| 2.6 Summarize / design / docs / next steps | PASS | Orchestrator-state rule section, ci-workflows rule, skill text, and brief updated; next step is PR and CI. |
| 3A Python (Black, Ruff, Pyright, Pytest) | PASS | Only tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py changed (pin digest and comment). |
| 3A.2 / 3A.3 Python design and error handling | N/A | No production Python change. |
| 3B.1 Formatting / analyzer / fix findings | PASS | See 2.5. |
| 3B.1 PowerShell 5.1 and 7.6+ compatible | N/A | Hooks target PowerShell 7 (repository rule: PowerShell 7+). |
| 3B.2 Advanced functions / parameter validation | PASS | CmdletBinding, OutputType, Mandatory and AllowNull attributes on every helper function. |
| 3B.2 Avoid global state | PASS | Only a script-scoped constant for the reason prefix. |
| 3B.2 Error handling | PASS | Every failure returns Verified false with a stage detail; no silent catch: each catch returns a deny-producing value with a comment. |
| 3B.3 Approved verbs | PASS | Test, Get, Select. |
| 3B.4 Toolchain steps | PASS | Format, analyze, test as recorded. |
| 3C Bash | N/A | No bash file changed. |
| 3D JSON | PASS | Two pack-manifest entries added beside the review-helper entry; files parse; manifest-completeness and closure tests pass. |
| 4A Python unit tests | PASS | Frozen-surface pin test passes with the new digest. |
| 4B.1 Pester v6 / PoshQC configuration | PASS | Pester 6.2.0 through Invoke-PoshQCParallelTest. |
| 4B.2 Focused tests / behavior over implementation / mocking sparingly | PASS | Seams mocked only at the gh boundary; gate rows assert decisions and reasons. |
| 4B.2 Organization | PASS | tests/scripts/claude-hooks and tests/scripts/codex-hooks mirror .claude/hooks and .codex/hooks. |
| 4B.3 File naming / structure / grouping | PASS | *.Tests.ps1; Describe with Contexts per row family. |

## Code review checklist

| Item | Result | Evidence |
|---|---|---|
| Findings: Blocker or Major | PASS | None found. |
| No secrets in code | PASS | No credentials or tokens added. |
| No unsafe subprocess or command construction | PASS | gh runs only through Invoke-DocsOnlyGhExe with an argument array; no string-built command. |
| Input validation at boundaries | PASS | PR number must be a positive JSON integer; head_sha a lowercase 40/64 hex id; run entries are read through a type-checking property reader. |
| Error handling remains explicit | PASS | A failed, timed-out, or unparseable gh result denies; the entry never throws. |
| Configuration / path handling is safe | PASS | No path composition beyond the existing gh working root. |
| Gate not weakened | PASS | Every new path fails closed; branch 1 makes no Get-EpicMergeGateLivePrHeadSha call (zero-call assertions pass); review guard still runs first; generic deny text unchanged. |
| Hooks invoke no Python | PASS | enforcement-hooks-no-python-invocation.Tests.ps1 passed in the P5-T2 gate. |
| Review helper unchanged | PASS | `git diff --quiet <merge base> HEAD` over both enforce-epic-merge-gate-review.ps1 copies, enforce-epic-merge-gate-green-ci.ps1, Invoke-CiGateParser.ps1, both epic-orchestrator agent files, .claude/settings.json, and .codex/config.toml: no change. |
| Mirror parity | PASS | Helper twins and bundle copies hash-equal; skill, rule, and brief bundle copies byte-identical; six brief copies share one SHA-256. |
| Research log | N/A | No external research beyond the committed research record. |

## Feature audit checklist (spec.md Acceptance Criteria)

| # | Criterion (abbreviated) | Result | Evidence |
|---|---|---|---|
| 1 | Regression test allowed before, denied after | PASS | child-ci-fail-before.2026-11-08T13-55.md (EXIT_CODE 1, observed allow); CHILD-CI-NO-CI-GATE passes in P5-T2. |
| 2 | Helper twins exist, byte-identical (tested), dot-source nothing, gh only in the two seams, entry returns Verified and Reason | PASS | Helper twins hash-equal; byte-identity row in the Claude suite; Invoke-DocsOnlyGhExe called only in Get-EpicMergeGateChildCiLiveHeadSha and Get-EpicMergeGateChildCiRunList. |
| 3 | Both gates dot-source with the guarded pattern; deny without fall-through | PASS | Guarded line in both gates; C11 dependency-failure case; Codex deny rows supply an epic checkpoint that would allow, and still deny. |
| 4 | Stages in order with a deny test per stage in both suites | PASS | 15 stage rows in each suite; Claude PR-mismatch row is direct because Test-ChildCheckpointPrGateBinding rejects it first. |
| 5 | Allow pull_request and recorded dispatch; deny unrecorded dispatch, failed or in-progress newest, other SHA, gh failure | PASS | Allow and deny rows in both suites. |
| 6 | Existing suites updated with stated reasons; deny text, guard ordering, zero-call assertion unchanged | PASS | P3-T3 to P3-T5 edits; those suites pass in P5-T2. |
| 7 | Review helper unchanged; stage C and stage J suites pass | PASS | Review helper unchanged in both runtimes; ReviewGuard, ReviewPaths, and the Codex review suite pass. Stage J: no `review/verdict` suite exists after the P5-T1 merge (a search of tests, .claude/hooks, and .codex/hooks for `review/verdict` finds nothing; the merge brought in no change), so this row records that absence. |
| 8 | No added or changed hook invokes Python | PASS | enforcement-hooks-no-python-invocation.Tests.ps1 green. |
| 9 | S9 dispatch rule, epic-orchestrate requirement and fallback, epic-run pointer | PASS | Skill text in the three .claude skills. |
| 10 | .agents mirrors and bundle copies match; epic-orchestrator.md unchanged | PASS | cmp of every bundle copy; no diff on .claude/agents/epic-orchestrator.md. |
| 11 | Frozen pin refreshed with RE-BASELINED comment; test_ci_gate_epic_child_contracts.py unchanged and passing | PASS | pytest 0 failed. |
| 12 | Orchestrator-state section and Enforcement bullet; six brief copies updated and identical | PASS | New section and bullet; brief hash identical across six copies. |
| 13 | ci-workflows rule and skill require epic/** for CI, deny other names, need a push-down refresh | PASS | New section in both sources and bundle copies. |
| 14 | Both core.json list the helper; manifest, closure, parity tests pass | PASS | One entry each; pytest 0 failed. |
| 15 | Helper coverage >= 85%; full toolchain passes with no regression | PASS | 100.00% / 97.59%; static-final, pester-final, and pytest-final artifacts. |

AC Status Summary: source spec.md `## Acceptance Criteria`; 15 items; 15 checked off; 0 remaining.
