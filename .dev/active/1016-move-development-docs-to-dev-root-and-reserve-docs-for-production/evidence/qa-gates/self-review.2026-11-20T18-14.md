# Self-Review ([P5-T7], stage B)

Timestamp: 2026-11-20T18-14
Command: walk of `.dev/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md` and `feature-audit.yyyy-MM-ddTHH-mm.md` against `git diff -M BASE HEAD` plus `git status --porcelain` (BASE = merge base of `origin/epic/shared-agent-harness-layer-integration` and HEAD), and against every stage B criterion of `spec.md` (`### Stage B — move, rename and flip`, `### Epic-level criteria owned by this child`) and of `user-story.md` scenarios (c) and (d)
EXIT_CODE: 0
Output Summary: no FAIL row. N/A rows are either out of scope (no Bash or C# change) or CI-dependent (stage 7 integration tests and the CI cross-check run in CI). Three criteria are PARTIAL and stay unchecked: the strict "no rewrites" wording of the second dry run (spec and user story) and the owner presentation of OQ-1 to OQ-13, which A14 replaced with an orchestrator decision step. Evidence references are the newest artifacts under `evidence/qa-gates/` (`ts-static`, `py-static`, `ps-static`, `ts-test-coverage`, `py-test-coverage`, `ps-test-coverage`, `coverage-delta` 2026-11-20T18-10, `scope-size-decisions.2026-11-20T18-12.md`, `phase-gate.P3.2026-11-20T16-04.md`) and `evidence/other/` (task checks, Phase 4 records, `final-qa-loop.2026-11-20T18-10.md`).

## Policy audit template

| Item | Status | Evidence |
| --- | --- | --- |
| Coverage evidence checklist: TypeScript baseline and post-change | PASS | `evidence/baseline/ts-test-coverage.2026-11-20T10-44.md`; `evidence/qa-gates/ts-test-coverage.2026-11-20T18-10.md` |
| Coverage evidence checklist: Python baseline and post-change | PASS | `evidence/baseline/py-test-coverage.2026-11-20T10-49.md`; `evidence/qa-gates/py-test-coverage.2026-11-20T18-10.md` |
| Coverage evidence checklist: PowerShell baseline and post-change | PASS | `evidence/baseline/ps-test-coverage.2026-11-20T11-03.md`; `evidence/qa-gates/ps-test-coverage.2026-11-20T18-10.md` |
| Coverage evidence checklist: per-language comparison | PASS | `coverage-delta.2026-11-20T18-10.md` (46 files, 0 violations, 0 missing values) |
| 1.1 Independence | PASS | The new tests build their fakes per test (`TestStreamCopilotOutput`, the two unresolved-target suites); all suites pass in the parallel full runs. |
| 1.1 Isolation | PASS | Each edited or added test targets one behavior (literal reads, template keys, unresolved-target denial, the no-timeout polling edge). |
| 1.1 Fast execution | PASS | Pester 711 s for 29157 tests with 8 workers; pytest 139 s; Jest 11 s; the new tests run in well under one second each, apart from one 0.1 s production queue poll. |
| 1.1 Determinism | PASS | The run-to-run variance in the Copilot stream loop and the unreached cleanup-leg line were removed by deterministic tests (`final-qa-loop.2026-11-20T18-10.md`). |
| 1.1 Readability and maintainability | PASS | Arrange-Act-Assert comments and descriptive names in the new Pester suites; docstrings in the new pytest case. |
| 1.2 Baseline coverage documented | PASS | Phase 0 baseline artifacts above. |
| 1.2 No coverage regression | PASS | `coverage-delta.2026-11-20T18-10.md`: no per-file drop; no language total drops. |
| 1.2 Changed files meet thresholds | PASS | The three hand-edited production files are at 100% lines and, for Python, 100% branches. |
| 1.2 New code coverage at least 90% | PASS | New lines in `ProcessReductionChain.psm1` (13) and `build_discovery_runtime.py` (11 statements, 8 branches) are fully covered. |
| 1.2 Positive, negative, edge and error flows | PASS | Template-key mapping for moved and unmoved keys; fallback present and absent paths ([P1-T5]); unresolved-target denial; the polling loop's continue edge. |
| 1.2 Concurrency | N/A | No concurrent production behavior changed; the stream-loop test drives the existing reader thread deterministically. |
| 1.2 State transitions | PASS | Ledger chain reverts newest-first through the regenerated hunks (`PRC-LEDGER-CHAIN-HOLDS`). |
| 1.3 Clear failure messages | PASS | `-Because` reasons and exact-value assertions in the new suites. |
| 1.4 Avoid external dependencies | PASS | New tests create no file and start no process; `mem_fs_path` fakes for the discovery build case. |
| 1.4 Environment stability | PASS | Repository-relative paths through `Join-Path` and `Path` joins; exact-case `.dev` paths for the Linux hook suites. |
| 1.5 Policy audit requirement | PASS | This file. |
| 2.1 Clarify the objective and read the plan | PASS | Plan `plan.2026-10-30T23-35.md` executed task by task from [P3-T3] in run 2. |
| 2.2 Simplicity first | PASS | The moved-template mapping is one key-to-source table in the disk boundary; no new dependency. |
| 2.2 Reusability and separation of concerns | PASS | `source_path_for_resource` and `resource_key_for_source` are pure helpers used by the I/O class. |
| 2.3 At or below the 800-line hard limit | PASS | `scope-size-decisions.2026-11-20T18-12.md`: 0 changed code files above 800; `build_discovery_runtime.py` 520 lines (above the 500 guidance tier, no gate). |
| 2.3 Files at or above 700 lines | PASS | No changed code file at or above 700 lines (largest 699). |
| 2.4 Names, docs and comments | PASS | Docstrings on the new Python helpers and the new test; intent comments on loops and branches. |
| 2.5 Formatting | PASS | Prettier, Black and the PowerShell formatter report 0 changes (`ts-static`, `py-static`, `ps-static`). |
| 2.5 Linting | PASS | ESLint 0, Ruff 0, PSScriptAnalyzer 0 findings. |
| 2.5 Type checking | PASS | `tsc` 0 errors; Pyright 0 errors. |
| 2.5 Testing | PASS | Jest 6685, pytest 17104, Pester 29157 tests; 0 failures. |
| 2.5 Full toolchain loop | PASS | Pass 5 of 5 is clean; the four restarts and their fixes are recorded. |
| 2.5 Stage 7 integration | N/A | CI-dependent; integration and golden lanes run in CI. |
| 2.6 Summarize, design choices, next steps | PASS | Commit messages per task and phase; decisions D-P3T6-1, D-P4T3-1, D-P5-1 in the evidence. |
| 3A Python tooling (Black, Ruff, Pyright, pytest) | PASS | `py-static.2026-11-20T18-10.md`; `py-test-coverage.2026-11-20T18-10.md`. |
| 3A Python design and typing | PASS | Full annotations on the new helpers; the tuple-of-pairs constant is immutable. |
| 3A Python error handling | PASS | No new exception path; `validate_resource_path` still runs on every key before the source mapping. |
| 3B PowerShell tooling and findings | PASS | `ps-static.2026-11-20T18-10.md` (0 findings). |
| 3B PowerShell design and safety | PASS | `Resolve-ProcessReductionLivePath` is read-only; no global state in the new suites (Pester-scoped mocks only). |
| 3B PowerShell compatibility | PASS | PowerShell 7 suites under `#Requires -Version 7.0`, as the sibling suites. |
| 3C Bash scripts | N/A | No `.sh` or `.bats` file changed. |
| 3D JSON | PASS | The three routing copies, `config/blast-radius.json` and the new fixture parse and keep their existing key order; the routing copies are byte-identical. |
| 4A Python unit tests | PASS | pytest only; tests mirror code paths (`tests/scripts/dev_tools/...`). |
| 4B PowerShell unit tests | PASS | Pester 6 through `Invoke-PoshQCParallelTest`; new suites under `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, named `*.Tests.ps1`, with the isolation-guard form. |
| CI cross-check | N/A | CI-dependent: the orchestrator compares CI at the reviewed head. |

## Code review template

| Item | Status | Evidence |
| --- | --- | --- |
| Findings table: blocking findings | PASS | None found in the diff walk. |
| Warning: files at or above 700 lines | PASS | None among changed code files. |
| Python implementation: typing and API | PASS | No new public API beyond the two helpers in `build_discovery_runtime.py`; `RESOURCE_ROOTS` and the manifest unchanged. |
| PowerShell implementation: API and safety | PASS | The ledger fallback changes no `LiveText` key and reads only absent recorded paths. |
| TypeScript implementation | N/A | No TypeScript production file changed in stage B (the stage A files are unchanged since the pre-apply commit). |
| Test quality: determinism, isolation, speed, diagnostics | PASS | See policy rows 1.1 to 1.4. |
| No secrets in code | PASS | No credentials or tokens in the diff. |
| No unsafe subprocess or command construction | PASS | No production subprocess change. |
| Input validation at boundaries | PASS | Resource keys are validated before the key-to-source mapping. |
| Error handling remains explicit | PASS | No swallowed errors added. |
| Configuration and path handling is safe | PASS | `.dev` paths are repository-relative; the cleanup allowlist stays on `docs/` (A27). |

## Feature audit template: stage B criteria (`spec.md`)

| Criterion | Status | Evidence |
| --- | --- | --- |
| Phase 0 stage B gate artifact, fresh `source_digest` equal | PASS | `stage-b-gate.2026-11-20T07-58.md`; `digest-comparison.2026-11-20T12-28.md` |
| After apply, `.dev/` layout, `docs/README.md`, renames shown | PASS | `layout-check.2026-11-20T16-07.md`; `apply-commit.2026-11-20T13-33.md` (R100 35222) |
| Folder renames match the rule or decision; comparison stored | PASS | `layout-check.2026-11-20T16-07.md` (0 mismatches) |
| A second dry run reports an empty plan | PARTIAL | `post-apply-dry-run-check.2026-11-20T16-11.md`: 0 moves, 0 renames, 0 link candidates, but 4572 files with reference text listed (D-P4T3-1); unchecked |
| `development_docs_root` is `.dev` in the three copies | PASS | `task-check.P3-T2.2026-11-20T14-19.md` |
| `config/blast-radius.json` lists `.dev`; bundle copy empty | PASS | `task-check.P3-T3.2026-11-20T15-04.md` |
| Both plan template copies link with the right depth | PASS | `template-link-check.2026-11-20T15-10.md` |
| Epic manifest names child 2's renamed folder | PASS | `epic-manifest-check.2026-11-20T15-11.md` |
| `PINNED_FROZEN_SURFACE_HASHES` and `KICKOFF_IDENTITY_FRAGMENTS` | PASS | frozen surfaces unchanged (`exclusion-integrity`); `manual-literal-edits.2026-11-20T15-19.md` |
| Historical fixtures unchanged and passing | PASS | `exclusion-integrity.2026-11-20T16-09.md`; full gates |
| Write-scope checker, both root forms | PASS | `ts-test-coverage.2026-11-20T18-10.md`; `production-root-search.2026-11-20T16-13.md` |
| Mirrors, manifests, generators, contract tests | PASS | `brief-fact-check.2026-11-20T15-39.md`; `phase-gate.P3.2026-11-20T16-04.md`; final gates |
| Production-root search and link check stored | PASS | `production-root-search.2026-11-20T16-13.md`; `post-apply-dry-run-check.2026-11-20T16-11.md` |
| Checkpoint records the post-move `<FEATURE>` | PASS | `checkpoint-path-verified.2026-11-20T14-11.md` |
| Seven-stage toolchain with the key at `.dev` | N/A | Stages 1 to 6 pass in one local pass; stage 7 is CI-dependent; unchecked pending CI |
| No Python file added | PASS | `scope-size-decisions.2026-11-20T18-12.md` |
| Each `global_decisions` answer implemented or `no change` | PASS | `scope-size-decisions.2026-11-20T18-12.md` |
| Epic: `.dev/` holds all records, `docs/` production only | PASS | `layout-check.2026-11-20T16-07.md` |
| Epic: migration command idempotent (second run changes nothing) | PARTIAL | `migration-apply.test.ts` second-apply case passes; the post-apply dry run lists reference text (D-P4T3-1); unchecked |
| Epic: migration command needs no Python | PASS | stage A `language-scope.2026-11-20T07-49.md`; `scope-size-decisions` |
| Epic: full toolchain passes with the key at `.dev` | N/A | CI-dependent (stage 7); unchecked pending CI |
| Epic: historical fixtures frozen and passing | PASS | `exclusion-integrity`; final gates |
| Epic: mirrored files, manifests, Codex counterparts, contract tests | PASS | final gates; `brief-fact-check` |

## Feature audit template: `user-story.md` scenarios (c) and (d)

| Criterion | Status | Evidence |
| --- | --- | --- |
| (c) OQ-1 to OQ-13 presented to the owner; neither plan decides them | PARTIAL | A14 replaced the owner stop with an orchestrator decision step under OD-1; neither plan decides them (`DECISIONS` is orchestrator-written); unchecked |
| (c) decision file records every held item, digest and global answers | PASS | `folder-rename-decisions.2026-11-20T12-24.json`; [P0-T2] decision-file check |
| (c) apply honors each decision exactly | PASS | `layout-check.2026-11-20T16-07.md` |
| (c) a tree change after approval makes apply refuse on `source_digest` | PASS | `migration-decisions.test.ts` digest-mismatch refusal, passing in `ts-test-coverage.2026-11-20T18-10.md` |
| (d) `.dev/` layout and `docs/README.md` | PASS | `layout-check.2026-11-20T16-07.md` |
| (d) `development_docs_root` is `.dev` in the three copies | PASS | `task-check.P3-T2.2026-11-20T14-19.md` |
| (d) `<NNNN>-<feature>` names except kept folders; other areas keep names | PASS | `layout-check.2026-11-20T16-07.md` |
| (d) plan from the template has working links; both copies same depth | PASS | `template-link-check.2026-11-20T15-10.md` |
| (d) historical fixtures unchanged and passing | PASS | `exclusion-integrity`; final gates |
| (d) write-scope checker, generator checks, contract tests | PASS | `ts-test-coverage`, `brief-fact-check`, final gates |
| (d) full seven-stage toolchain with the key at `.dev` | N/A | CI-dependent (stage 7); unchecked pending CI |
| (d) a post-apply dry run reports an empty plan | PARTIAL | D-P4T3-1; unchecked |
| (d) no new Python file | PASS | `scope-size-decisions.2026-11-20T18-12.md` |
