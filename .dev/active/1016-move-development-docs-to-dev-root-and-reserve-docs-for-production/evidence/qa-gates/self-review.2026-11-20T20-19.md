# Self-Review [P2-T9] — remediation cycle 1

Timestamp: 2026-11-20T20-19
Command: walk of `.dev/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md` and `feature-audit.yyyy-MM-ddTHH-mm.md` against `git -C <worktree> diff -M BASE HEAD` (BASE = merge base of `origin/epic/shared-agent-harness-layer-integration` and HEAD, head 117ab1346) and `git -C <worktree> status --porcelain`, with this cycle's changes read from `git -C <worktree> diff f744ce9e0 HEAD` (the reviewed head), and against findings F1, F2 and F3 of `remediation-inputs.2026-11-20T18-20.md`
EXIT_CODE: 0
Output Summary: no FAIL row. F1, F2 and F3 are PASS. The four pending-CI toolchain criteria are N/A pending CI and stay unchecked. Correction of the previous self-review (self-review.2026-11-20T18-14.md, row 3C): the branch changes three bash files, `.claude/lib/bash/report-lane-assertion.sh`, its bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/report-lane-assertion.sh`, and `tests/shell/report_lane_assertion_dispatch.bats`; the reviewer's run in review-coverage-check.2026-11-20T18-28.md records bats 14 of 14 passed and kcov line rate 89.8% for `report-lane-assertion.sh`. This cycle changes no bash file. One non-blocking deviation is recorded (root-jest-baseline-deviation.2026-11-20T20-14.md).

## Findings of the remediation inputs

| Item | Status | Evidence |
| --- | --- | --- |
| F1: post-move records keep the in-tree rewrite scope; second run empty | PASS | `isMappedTargetPath` in `layout-map.ts`, used in `scanRewrites` of `migration-plan.ts` (commit e49111fac); fail-before `regression-testing/fail-before-f1.2026-11-20T19-17.md` (2 expected failures); pass-after `task-check.P1-T2.2026-11-20T19-22.md` (80 and 233 tests passed); `post-apply-dry-run-check.2026-11-20T19-24.md`: Moves 0, Renames 0, Refusals none, Outside rewrites 0, In-tree links-only candidates 0, four Stay rows excluded; `migration-plan.ts` 589 lines, coverage thresholds unchanged and met |
| F2: A14 supersession of user-story criterion (c) 1 recorded | PASS | `user-story.md` note `Supersession (2026-11-20, A14, OD-1):` and restated criterion (unchecked, for re-audit grading against `folder-rename-decisions.2026-11-20T12-24.json`); `spec.md` A14 bullet sentence; `task-check.P1-T4.2026-11-20T19-26.md` and `task-check.P1-T5.2026-11-20T19-27.md` (checkbox counts equal to HEAD) |
| F3: stage-timing entry test no longer reads the real checkout; class swept | PASS | `Get-StageTimingReport.Tests.ps1` (commit f331c32ca); fail-before `regression-testing/fail-before-f3.2026-11-20T19-29.md` (the CI failure reproduced on the clean layout); pass-after 7 of 7; `moved-root-sweep.2026-11-20T19-34.md` (65 files, 13 hits, all non-reads); `phase-gate.P1.2026-11-20T19-55.md` (`Sweep: none`, absence check before and after) |

## Pending-CI criteria

| Criterion | Status | Evidence |
| --- | --- | --- |
| spec stage A: seven-stage toolchain for the changed TypeScript, no changed production file above 800 lines | N/A | Stages 1 to 6 clean locally (ts-static.2026-11-20T20-08.md, ts-test-coverage.2026-11-20T20-13.md); stage 7 is CI-dependent; unchecked pending CI |
| spec stage B: seven-stage toolchain for TypeScript, Python and PowerShell with the key at `.dev` | N/A | Final loop pass 2 artifacts under `evidence/qa-gates/` 2026-11-20T20-08 to 20-19; stage 7 CI-dependent; unchecked pending CI |
| spec epic: full toolchain passes with `development_docs_root` at `.dev` | N/A | as above; unchecked pending CI |
| user-story (d): full seven-stage toolchain with the key at `.dev` | N/A | as above; unchecked pending CI |

## Policy audit template

| Item | Status | Evidence |
| --- | --- | --- |
| Coverage evidence checklist: TypeScript baseline and post-change | PASS | baseline-citation.2026-11-20T19-13.md; ts-test-coverage.2026-11-20T20-13.md; root-jest-coverage.2026-11-20T20-14.md |
| Coverage evidence checklist: Python baseline and post-change | PASS | baseline-citation.2026-11-20T19-13.md; py-test-coverage.2026-11-20T20-12.md |
| Coverage evidence checklist: PowerShell baseline and post-change | PASS | baseline-citation.2026-11-20T19-13.md; ps-test-coverage.2026-11-20T20-18.md |
| Coverage evidence checklist: per-language comparison | PASS | coverage-delta.2026-11-20T20-19.md (46 files, 0 violations, 0 missing) |
| 1.1 Independence | PASS | The new Jest cases build their own in-memory fixtures; the Pester mock is scoped to one `It`; all suites pass in the parallel full runs. |
| 1.1 Isolation | PASS | Each new case targets one behavior: the predicate, the post-move classification, the second links-only apply, the no-open-choice refusal text, the default-root read. |
| 1.1 Fast execution | PASS | The development-docs-migration selection runs 80 tests in under one second; the edited Pester case runs in 0.11 s. |
| 1.1 Determinism | PASS | No clock, random or file system access in the new cases; the F3 case no longer depends on an untracked directory on disk. |
| 1.1 Readability and maintainability | PASS | Arrange-Act-Assert comments and descriptive case names. |
| 1.2 Baseline coverage documented | PASS | baseline-citation.2026-11-20T19-13.md |
| 1.2 No coverage regression | PASS | coverage-delta.2026-11-20T20-19.md; no per-file or total drop. Root Jest line total compared like-for-like (deviation record). |
| 1.2 Changed files meet thresholds | PASS | `layout-map.ts` 100% lines and branches; `migration-plan.ts` 100% lines, 98.64% branches. |
| 1.2 New code coverage at least 90% | PASS | 28 of 28 added production lines covered, 11 of 11 branches taken. |
| 1.2 Positive, negative, edge and error flows | PASS | Predicate true and false cases, the string-prefix-only edge (`.dev/activex/a.md`), the discovery target argument, the refusal text without open choices. |
| 1.2 Concurrency | N/A | No concurrent behavior changed. |
| 1.2 State transitions | PASS | First apply then second apply on the resulting tree. |
| 1.3 Clear failure messages | PASS | Exact-value `toEqual` and `Should -Invoke -ParameterFilter` assertions. |
| 1.4 Avoid external dependencies | PASS | In-memory file system and git fakes; Pester mock of `Read-StageTimingEvidence`; no file written. |
| 1.4 Environment stability | PASS | The F3 fix removes the dependency on leftover local directories; the clean layout reproduced the CI checkout. |
| 1.5 Policy audit requirement | PASS | This file. |
| 2.1 Clarify the objective and read the plan | PASS | `remediation-plan.2026-11-20T18-37.md` executed task by task after the confirming preflight (preflight-fixes.2026-11-20T19-11.md). |
| 2.2 Simplicity first | PASS | One pure predicate and a one-condition change in `scanRewrites`. |
| 2.2 Reusability and separation of concerns | PASS | The predicate lives beside `mapLegacyPath` in the layout table module; `scanRewrites` stays pure. |
| 2.3 At or below the 800-line hard limit | PASS | Changed code files this cycle: `layout-map.ts` 181, `migration-plan.ts` 589, `layout-map.test.ts` 185, `migration-apply.test.ts` 268, `migration-plan.test.ts` 542, `Get-StageTimingReport.Tests.ps1` 104 lines. |
| 2.3 Files at or above 700 lines | PASS | None among this cycle's changed code files; branch-wide largest changed code file 699 (scope-size-decisions.2026-11-20T18-12.md). |
| 2.4 Names, docs and comments | PASS | Doc comment on `isMappedTargetPath`; intent comment on the `scanRewrites` condition and the F3 mock. |
| 2.5 Formatting | PASS | ts-static, py-static, ps-static 2026-11-20T20-08: 0 changes. |
| 2.5 Linting | PASS | ESLint 0, Ruff 0, PSScriptAnalyzer 0 findings; leak scan 0 failures. |
| 2.5 Type checking | PASS | tsc 0 errors (extension and root); Pyright 0 errors. |
| 2.5 Testing | PASS | Jest extension 6707, root Jest 6724, pytest 17104, Pester 29157 tests; 0 failures. |
| 2.5 Full toolchain loop | PASS | Pass 2 clean; pass 1 was stopped and restarted after the coverage fix (commit 520617870). |
| 2.5 Stage 7 integration | N/A | CI-dependent. |
| 2.6 Summarize, design choices, next steps | PASS | Commit messages per task; deviation record for the root Jest comparison. |
| 3A Python | N/A | No Python file changed in this cycle; Python gates clean. |
| 3B PowerShell tooling, design and safety | PASS | One test file changed; Pester-scoped mock only; ps-static 0 findings. |
| 3C Bash scripts | PASS | Branch changes three bash files (listed above); bats 14 of 14 and kcov 89.8% recorded in review-coverage-check.2026-11-20T18-28.md; no bash file changed in this cycle. |
| 3D JSON | N/A | No JSON file changed in this cycle apart from the generated dry-run report evidence. |
| 4A Python unit tests | N/A | No Python test changed. |
| 4B PowerShell unit tests | PASS | Pester 6 through `Invoke-PoshQCParallelTest`; the edited suite keeps its `*.Tests.ps1` name and location. |
| TypeScript unit tests | PASS | Jest only; tests mirror `src/lib/development-docs-migration/` under `test/lib/development-docs-migration/`. |
| CI cross-check | N/A | CI-dependent: the orchestrator compares CI at the new head (S9). |

## Code review template

| Item | Status | Evidence |
| --- | --- | --- |
| Findings table: blocking findings | PASS | None found in this cycle's diff. |
| Warning: files at or above 700 lines | PASS | None among changed code files. |
| TypeScript implementation: typing and API | PASS | `isMappedTargetPath(path: string, discoveryTarget: string): boolean` is a new exported pure function; no existing signature changed; no `any`, no type assertion. |
| PowerShell implementation | N/A | No production PowerShell file changed in this cycle. |
| Python implementation | N/A | No Python file changed in this cycle. |
| Test quality: determinism, isolation, speed, diagnostics | PASS | See policy rows 1.1 to 1.4. |
| No secrets in code | PASS | None in the diff. |
| No unsafe subprocess or command construction | PASS | No subprocess change. |
| Input validation at boundaries | PASS | Unchanged; the predicate reads only the static table and its arguments. |
| Error handling remains explicit | PASS | No error path changed. |
| Configuration and path handling is safe | PASS | Paths stay repository-relative with forward slashes; the predicate matches whole targets (`.dev/activex/` is not matched). |

## Feature audit template (criteria touched in this cycle)

| Criterion | Status | Evidence |
| --- | --- | --- |
| spec: A second dry run after apply reports an empty plan | PASS (checked) | post-apply-dry-run-check.2026-11-20T19-24.md |
| spec epic: migration command moves, rewrites, and a second run changes nothing | PASS (checked) | `migration-apply.test.ts` second-apply cases; post-apply dry run |
| user-story (d): a post-apply dry run reports an empty plan | PASS (checked) | post-apply-dry-run-check.2026-11-20T19-24.md |
| user-story (c) 1, restated: the orchestrator decision step writes the decision file from A2 to A13 and the stage A dry-run JSON | PASS, left unchecked for the re-audit | `folder-rename-decisions.2026-11-20T12-24.json`; the plan assigns the grading to the re-audit |
| Pending-CI toolchain criteria (four) | N/A | unchecked pending CI |
