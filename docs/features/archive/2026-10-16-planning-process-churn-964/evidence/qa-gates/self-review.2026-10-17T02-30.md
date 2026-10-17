# Self-Review: Planning-Process Churn (#964)

Timestamp: 2026-10-17T02-30
Task: [P6-T12] (orchestrator directives D4 and D5)
Command: walk of `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `docs/features/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` and `docs/features/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md` against `git diff origin/main...HEAD` plus the working tree; QA loop re-run recorded in `toolchain-rerun.2026-10-17T02-28.md`
EXIT_CODE: 0
Output Summary:
- One row per template checklist item, each marked PASS or N/A with a reason; no row is FAIL.
- Findings raised during the walk were fixed in this item before the QA loop was re-run from [P6-T1]; they are listed under "Findings fixed during the walk".
- AC-1 to AC-32 evaluated: 32 PASS. AC-33 and AC-34 are orchestrator-owned and not evaluated here.

## Scope and Baseline

- Base: `origin/main` at `b8fcd7790`; the merge base equals the `origin/main` tip (scope check, `toolchain-rerun.2026-10-17T02-28.md`).
- Head: `bug/planning-process-churn-964`, commits `5897346f4` through `376d5f4a5` plus the uncommitted self-review fixes, which are committed after this artifact.
- Diff: 240 tracked files changed against the merge base (7517 insertions, 572 deletions); 258 paths including new evidence files. All 258 are in the plan's Files Written list or the feature evidence folder; 0 of the deliberately not-touched files changed.
- Pre-mortem: `evidence/other/pre-mortem.2026-10-17T02-06.md` (17 items, all PASS).
- Work mode: `full-bug` (from `issue.md`); AC source: `spec.md`.

## Findings Fixed During the Walk

| # | Finding | Fix | Verification |
|---|---|---|---|
| F1 | The language-specific Copilot executors, planners, orchestrators and typed engineers still carried the removed preflight loop mandates | Single-pass wording applied to the 11 agents with bundle copies; the executor variants state that the in-place edit is the only write validation-only mode permits | `test_codex_and_copilot_executors_drop_loop_mandates` and `test_copilot_bundle_copies_match_canonical` pass |
| F2 | The `{csharp,powershell,python}-change-budget-router` skills and the four `orchestrate-*work.prompt.md` prompts still carried loop mandates | Single-pass wording in every surface and bundle copy | Same tests; mirror copy script reports COPIED=60 MISMATCH=0 |
| F3 | The Codex skill index `.agents/skills/README.md` did not list `execution-environment` | Added under Foundation, with its bundle copy | Byte parity checked by the copy script |
| F4 | The brief's CI section predated the `merge_group` trigger merged from `origin/main` | Section refreshed (D3) | `test_execution_environment_brief_contracts.py` passes |

Each fix is recorded in the plan's Files Written executor note and is inside the scope check's allowed list.

## Part 1 — Policy Audit Template

### Coverage metrics by language

| Language | Files changed (code) | Tests | Result | Baseline | Post-change | New code |
|---|---|---|---|---|---|---|
| Python | 4 production, 10 test | 7325 pass, 0 fail | PASS | 94.04% line / 88.65% branch | 94.11% / 88.78% | `plan_gate_document.py` 100% / 100% |
| TypeScript | 3 production + `jest.config.cjs`, 7 test | 4103 pass, 0 fail | PASS | 97.39% lines / 92.63% branches | 97.41% / 92.65% | `plan-gate-document.ts` 100% / 95.08% |
| PowerShell | 4 hooks, 7 test suites | 11046 pass, 0 fail, 10 skipped | PASS | 92.09% line | 92.23% line | `premortem-section.ps1` 100% |
| JSON | 2 pack manifests | pack-manifest completeness tests | PASS | n/a | n/a | n/a |

Coverage evidence: `evidence/baseline/python-tests.2026-10-16T23-25.md`, `evidence/baseline/ts-tests.2026-10-16T23-25.md`, `evidence/baseline/ps-tests.2026-10-16T23-48.md`, `evidence/qa-gates/coverage-delta.2026-10-17T02-04.md`, `evidence/qa-gates/toolchain-rerun.2026-10-17T02-28.md`.

| # | Template item | Status | Reason |
|---|---|---|---|
| P1 | Policy documents evaluated (general code change, general unit test, Python, PowerShell, TypeScript) | PASS | Read in order at [P0-T1], recorded in `evidence/baseline/phase0-instructions-read.2026-10-16T23-19.md` |
| P2 | Temporary artifacts cleanup | PASS | Every helper script lives under SCRATCH outside the repository; no throwaway script is committed; `artifacts/` coverage outputs are gitignored and untracked |
| P3 | 1.1 Independence | PASS | Seeded shuffles pass: Jest seeds 964964, 20261016 and 31337; Pester file-order seeds 964, 20261016 and 31337; reversed Python order (`evidence/regression-testing/isolation-final.2026-10-17T02-04.md`) |
| P4 | 1.1 Isolation | PASS | Each new test targets one gate, helper or hook branch; for example `premortem-section.Tests.ps1` has one `It` per label or acceptance rule |
| P5 | 1.1 Fast execution | PASS | The new Python modules run in under 2 s within the 238-test contract set; full Jest 13.96 s; the new Pester suites use in-memory fixtures |
| P6 | 1.1 Determinism | PASS | No clock, randomness or network in the new tests; transcript content is injected through the `ReadTranscriptHead` seam |
| P7 | 1.1 Readability | PASS | Behavior-named tests with Arrange/Act/Assert comments and docstrings |
| P8 | 1.2 Baseline coverage documented | PASS | [P0-T4], [P0-T6], [P0-T8] artifacts written before any production edit |
| P9 | 1.2 No coverage regression | PASS | Every language total and every changed production file is at or above baseline (`coverage-delta.2026-10-17T02-04.md`) |
| P10 | 1.2 New code coverage of at least 90% | PASS | New modules: 100% / 100% (Python), 100% / 95.08% (TypeScript), 100% (PowerShell helper); changed hooks 98.17% to 100% |
| P11 | 1.2 Comprehensive coverage | PASS | Every new function has direct tests (Part 5 table); none is untested |
| P12 | 1.2 Positive flows | PASS | Valid Pre-Mortem sections, clean plans, ALL CLEAR preflight with fix records, and parity rows are all accepted |
| P13 | 1.2 Negative flows | PASS | Missing heading or label, line locators, SHAs, oversize plans without justification, malformed preflight outputs and missing fix-record paths are all rejected |
| P14 | 1.2 Edge cases | PASS | Thresholds at exactly 40 tasks and 400 lines, empty justification, fenced blocks, UUID segments, SHA-256 digests, case-insensitive labels, empty plan-line arrays |
| P15 | 1.2 Error handling | PASS | Unparseable or absent transcripts fall back to the plan-file signal check; a missing helper file takes the guarded-load branch (tested) |
| P16 | 1.2 Concurrency | N/A | No concurrent code paths; the hooks and validators are single-invocation |
| P17 | 1.2 State transitions | PASS | Preflight-versus-execution classification and the combined-run BLOCKED allowance are tested on both sides of each transition |
| P18 | 1.2.1 Per-language comparison | PASS | Python +0.07 line / +0.13 branch; TypeScript +0.02 / +0.02; PowerShell +0.14 line; all PASS (`coverage-delta.2026-10-17T02-04.md`) |
| P19 | 1.3 Clear failure messages | PASS | Contract tests report the missing tokens per path (`_lacking` returns a path-to-token map) |
| P20 | 1.3 Arrange-Act-Assert | PASS | Marked in every new Python and TypeScript test; the Pester `It` blocks follow the same order |
| P21 | 1.3 Document intent | PASS | Docstrings name the scenario and the expected outcome |
| P22 | 1.4 External dependencies | PASS | None; the contract tests read committed repository files only |
| P23 | 1.4 Mocks and stubs | PASS | The Pester suites mock only the file and transcript read seams (`Get-ResearchFileContent`, `ReadTranscriptHead`); Jest uses the existing harness mocks |
| P24 | 1.4 Environment stability | PASS | No temporary files are created; fixtures are in-memory strings |
| P25 | 1.5 Pre-submission review | PASS | This artifact |
| P26 | 2.1 Clarify the objective | PASS | `issue.md` and `spec.md` (#964) |
| P27 | 2.1 Read existing plans | PASS | `research/research.2026-10-16T22-36.md` and the approved plan |
| P28 | 2.1 Document the plan | PASS | `plan.2026-10-16T18-10.md` |
| P29 | 2.2 Simplicity | PASS | G11 to G13 are line-regex evaluators over normalized text; the Pre-Mortem check is one helper shared by two hooks |
| P30 | 2.2 Reusability | PASS | `plan_gate_document` reuses `FENCE_RE` and the whitespace helpers; `premortem-section.ps1` is dot-sourced by both hooks |
| P31 | 2.2 Extensibility | PASS | New gates are added through `evaluate_document_gates`, called after G10 without changing existing gate signatures |
| P32 | 2.2 Separation of concerns | PASS | Pure evaluators are separate from file I/O; hook I/O goes through injectable seams |
| P33 | 2.3 Cohesive modules | PASS | One module per concern (document gates, Pre-Mortem helper) |
| P34 | 2.3 Under 500 lines | PASS | 0 touched non-Markdown files over 500 lines; the largest is `repo-automation-dispatch.test.ts` at 500 |
| P35 | 2.3 Public versus internal | PASS | Only `evaluate_document_gates`, `evaluateDocumentGates` and the severity constants are exported |
| P36 | 2.3 No circular dependencies | PASS | `plan_gate_document` imports only `plan_gate_commands` (whitespace helpers) and `plan_gate_scratch` (`FENCE_RE`), and only `plan_gate_discrimination` imports it; `plan-gate-document.ts` has the same graph. No dependency-cruiser configuration exists, so no architecture-boundary test applies (`contract-and-integration.2026-10-17T01-12.md`) |
| P37 | 2.4 Descriptive names | PASS | For example `Test-IsPreflightRun`, `Get-PreflightRunBlockDecision`, `evaluate_document_gates` |
| P38 | 2.4 Docs and docstrings | PASS | Module and function docstrings; comment-based help on the four Pre-Mortem helper functions, `Test-IsPreflightRun` and `Get-PreflightRunBlockDecision`; the small seam functions carry a one-line purpose comment, consistent with the existing hook style |
| P39 | 2.4 Comment why | PASS | Comments explain decisions, for example the ASCII escapes in the helper for Windows PowerShell 5.1 source decoding |
| P40 | 2.5 Formatting | PASS | Black, Prettier and PoshQC format are clean (`toolchain-rerun.2026-10-17T02-28.md`) |
| P41 | 2.5 Linting | PASS | Ruff, ESLint and PSScriptAnalyzer report 0 findings |
| P42 | 2.5 Type checking | PASS | Pyright 0 errors; `tsc` for source and test 0 diagnostics; N/A for PowerShell |
| P43 | 2.5 Testing | PASS | Pytest, Jest and Pester all pass |
| P44 | 2.5 Full toolchain loop | PASS | The re-run completed every stage in one pass with no rewrite |
| P45 | 2.5 Explicit reporting | PASS | Commands and results are recorded under `evidence/qa-gates/` |
| P46 | 2.6 Summarize changes | PASS | Conventional commits per concern (Part 1 section 9) |
| P47 | 2.6 Design choices | PASS | The plan's Design Scope and the executor notes record the choices and the related fixes |
| P48 | 2.6 Update supporting docs | PASS | `plan-acceptance-gates.md`, `claude-code-architecture.md` and the plan templates are updated |
| P49 | 2.6 Next steps | PASS | AC-33 (the #962 re-plan) and AC-34 (CI) are orchestrator-owned |
| P50 | 3A.1 Black / Ruff / Pyright / Pytest | PASS | All clean; 7325 passed |
| P51 | 3A.2 Strong typing | PASS | Full annotations; no `Any` in the new modules |
| P52 | 3A.2 Dataclasses | N/A | No new value objects; findings use the existing report type |
| P53 | 3A.2 Protocols and ABCs | N/A | No new interface |
| P54 | 3A.2 Avoid utility classes | PASS | Module-level functions only |
| P55 | 3A.3 Specific exceptions | PASS | No broad catch in the new or changed Python |
| P56 | 3A.3 Logging over print | PASS | No print in production code; the generator's CLI output path is unchanged |
| P57 | 3A.3 Invariants at construction | N/A | No new classes |
| P58 | 3B.1 Invoke-Formatter | PASS | No rewrite |
| P59 | 3B.1 PSScriptAnalyzer | PASS | No findings (direct run) |
| P60 | 3B.1 Fix all findings | PASS | The plural-noun and ShouldProcess findings raised during development were fixed by renaming |
| P61 | 3B.1 PowerShell 5.1 and 7.6+ compatible | PASS | The helper is ASCII-only with `–`/`—` regex escapes; no 7-only syntax in the changed hooks |
| P62 | 3B.2 Advanced functions | PASS | `[CmdletBinding()]`, `[OutputType()]` and typed parameters on the new hook functions |
| P63 | 3B.2 Parameter validation | PASS | Mandatory parameters; `[AllowEmptyCollection()]` where empty plans are valid input |
| P64 | 3B.2 Avoid global state | PASS | Script-scope seams only, reset per test |
| P65 | 3B.2 Error handling | PASS | Guarded helper load; transcript read failures fall back explicitly |
| P66 | 3B.3 Cohesive and under 500 lines | PASS | Executor hook 449 lines, planner 454, researcher 310, helper 149 |
| P67 | 3B.3 Approved verbs | PASS | Get, Test only |
| P68 | 3B.3 Comment why | PASS | Comments explain the guarded-load and transcript-first rationale |
| P69 | 3B.4 Format / Analyze / Test | PASS | All pass |
| P70 | 3B.4 Type check | N/A | Not applicable to PowerShell |
| P71 | 3B.4 Rerun loop | PASS | Loop re-run after the self-review fixes; single clean pass |
| P72 | 3C Bash | N/A | No committed Bash file changed; SCRATCH `sh` launchers are outside the repository |
| P73 | 3D JSON formatting and schema | N/A | The two changed `pack-manifests/core.json` files are outside the governed globs of `format_json` and `validate_json` (0 matches in either tool's default scope); the branch adds three entries in the existing style, and the pack-manifest completeness tests pass. The default-scope runs report pre-existing findings only in untouched files |
| P74 | 4A Pytest framework and coverage | PASS | Pytest only; new code at 100% |
| P75 | 4A Focused tests, sparing mocks, mirrored layout | PASS | Tests under `tests/scripts/dev_tools/` mirror `scripts/dev_tools/`; no mocks in the new Python tests |
| P76 | 4A Naming and docstrings | PASS | Every test has a docstring |
| P77 | 4A No alternative runners | PASS | Pytest only |
| P78 | 4B Pester 5 and PoshQC configuration | PASS | Pester 5.9 through PoshQC; no settings change |
| P79 | 4B Focused tests and behavior over implementation | PASS | Assertions target hook decisions (block, allow, repairable), not internals |
| P80 | 4B Mirrored organization and `*.Tests.ps1` naming | PASS | `tests/scripts/claude-hooks/` mirrors `.claude/hooks/` per the existing convention |
| P81 | 4B Describe/Context/It structure and grouping | PASS | Grouped by function and scenario |
| P82 | 4B No alternative runners | PASS | Pester only |
| P83 | 6 Test execution metrics | PASS | Totals in the coverage table above; no failures |
| P84 | 7 Code quality checks | PASS | All clean |
| P85 | 8 Gaps and exceptions | PASS | None; the one E501 test-name shortening and the `main([])` coverage route are recorded as plan executor notes, not exceptions |
| P86 | 9 Summary of changes | PASS | Commits listed in the final report; files listed in the plan's Files Written section |
| P87 | 10 Compliance verdict | PASS | Fully compliant on the evidence above |

### Part 5 — Test coverage detail

| Unit | Tests | Coverage |
|---|---|---|
| `plan_gate_document.py` (G11, G12, G13) | `test_plan_gate_document.py` 11 test functions; `test_plan_gate_document_parity.py` 4; `test_plan_gate_document_docs.py` 5 | 100% line / 100% branch |
| `plan-gate-document.ts` | `plan-gate-document.test.ts` 11 cases; `plan-gate-document-parity.test.ts` 3 | 100% / 95.08% |
| `premortem-section.ps1` | `premortem-section.Tests.ps1` 11 `It` blocks | 100% |
| `validate-planner-output.ps1` (Pre-Mortem block, `CITATION:` locator) | `validate-planner-output.PreMortem.Tests.ps1` 4, plus the updated planner suites | 99.52% |
| `validate-task-researcher-output.ps1` | `validate-task-researcher-output.PreMortem.Tests.ps1` 8 | 98.17% |
| `validate-executor-output.ps1` (preflight classification and blocks) | `validate-executor-output.Preflight.Tests.ps1` 26 | 100% |
| Contract text (brief, single-pass, remediation mode) | `test_execution_environment_brief_contracts.py` 16; `test_single_pass_preflight_contracts.py` 10 | n/a (text contracts) |

## Part 2 — Code Review Template

| # | Template item | Status | Reason |
|---|---|---|---|
| C1 | Executive summary and top risks recorded | PASS | Risks: (1) CI-only behavior on Linux runners, covered by pre-mortem items for the hook-suite job and PoshQC shards; (2) G11 or G12 false positives on future plans, measured over 615 committed files with the false-positive classes documented; (3) transcript-format drift, mitigated by the fallback to the plan-file signal check |
| C2 | Findings table: no Blocker or Major open | PASS | F1 to F4 are fixed; no open finding remains |
| C3 | Python: what changed well, typing, error handling | PASS | Pure evaluators, full annotations, no broad catches, no `repr(` or `!r` in the new modules (AC-11) |
| C4 | TypeScript: type safety and maintainability | PASS | No `any` and no suppression comments in `plan-gate-document.ts`; message parity with Python is byte-identical |
| C5 | PowerShell: API, safety, analyzer hygiene | PASS | Advanced functions, approved verbs, analyzer clean; BLOCKED detection made case-sensitive so prose mentions do not match |
| C6 | C# implementation audit | N/A | No C# code changed; the C# Copilot agents changed only in prose |
| C7 | Test quality: determinism, isolation, speed, diagnostics | PASS | See P3 to P7 and P19 |
| C8 | No secrets in code | PASS | Diff inspected; no tokens or credentials |
| C9 | No unsafe subprocess or command construction | PASS | No new subprocess calls in production code |
| C10 | Input validation at boundaries | PASS | Hook envelopes are parsed defensively (`Get-JsonPropertyValue`); a missing `agent_transcript_path` is handled |
| C11 | Error handling remains explicit | PASS | Repairable and non-repairable blocks are distinct and tested |
| C12 | Configuration and path handling safe | PASS | The fix-record path must resolve under `docs/features/`; no absolute host path appears in any artifact (evidence check) |
| C13 | Research log | PASS | No external research needed beyond `research/research.2026-10-16T22-36.md` |
| C14 | Tonality of every new contract sentence | PASS | 881 added prose lines in contract, agent, skill, rule and prompt files scanned: 0 hyperbole or promotional terms, 0 emoji; manual reading found plain, imperative, evidence-matched wording |
| C15 | Verdict consistent with findings | PASS | Go for normal PR flow |

## Part 3 — Feature Audit Template (AC status)

| AC | Status | Evidence |
|---|---|---|
| AC-1 | PASS | `test_execution_environment_brief_contracts.py` passes |
| AC-2 | PASS | Same suite |
| AC-3 | PASS | Same suite |
| AC-4 | PASS | Same suite; CI section refreshed for `merge_group` |
| AC-5 | PASS | Copy script COPIED=60 MISMATCH=0; push-down and pack-manifest tests in the contract set pass |
| AC-6 | PASS | Brief suite and generator `--check` exit 0 |
| AC-7 | PASS | `test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file` passes |
| AC-8 | PASS | `test_plan_gate_document.py`, `plan-gate-document.test.ts` |
| AC-9 | PASS | Same suites |
| AC-10 | PASS | Same suites |
| AC-11 | PASS | Parity suites; existing plan-gate tests unchanged and passing |
| AC-12 | PASS | `test_plan_gate_document_docs.py`, `test_plan_gate_scratch_docs.py` |
| AC-13 | PASS | `test_plan_gate_document_docs.py` |
| AC-14 | PASS | `validate-planner-output.PreMortem.Tests.ps1` and the planner suites |
| AC-15 | PASS | `evidence/other/g11-g13-corpus-measurement.2026-10-16T23-46.md` |
| AC-16 | PASS | `coverage-delta.2026-10-17T02-04.md`, `toolchain-rerun.2026-10-17T02-28.md`; `jest.config.cjs` per-file entry |
| AC-17 | PASS | `validate-executor-output.Preflight.Tests.ps1` |
| AC-18 | PASS | Same suite |
| AC-19 | PASS | `test_single_pass_preflight_contracts.py` |
| AC-20 | PASS | Same suite |
| AC-21 | PASS | Same suite, `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py` |
| AC-22 | PASS | `claude-architecture-doc.Tests.ps1`, `test_scratch_location_contracts.py` in the contract set |
| AC-23 | PASS | `premortem-section.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1` |
| AC-24 | PASS | `validate-task-researcher-output.PreMortem.Tests.ps1`, `test_single_pass_preflight_contracts.py` |
| AC-25 | PASS | `test_plan_templates_carry_premortem_skeleton`, `test_contract_requires_final_phase_self_review` |
| AC-26 | PASS | `test_pre_feature_review_commit_starts_with_self_review_check` |
| AC-27 | PASS | `test_remediation_surfaces_define_remediation_mode` |
| AC-28 | PASS | `validate-executor-output.Preflight.Tests.ps1` |
| AC-29 | PASS | `toolchain-rerun.2026-10-17T02-28.md` (all seven stages in one pass, including generator `--check`, `test_push_down_issue_824_follow_ups.py` and `test_typescript_toolchain_instruction_contracts.py` in the full Pytest run) |
| AC-30 | PASS | `evidence/regression-testing/jest-seeded.2026-10-17T01-21.md`, `python-reversed.2026-10-17T01-21.md`, `pester-single-process.2026-10-17T01-39.md`, `isolation-final.2026-10-17T02-04.md` |
| AC-31 | PASS | Scope check: 0 non-Markdown files over 500 lines |
| AC-32 | PASS | This artifact: every row is PASS or N/A with a reason; no FAIL row |
| AC-33 | N/A | Orchestrator-owned (#962 re-plan after [P6-T12]); not evaluated by the executor |
| AC-34 | N/A | Orchestrator-owned at S9 (pending CI); not evaluated by the executor |

### AC Status Summary

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---|---|---|---|
| `spec.md` | 34 | 32 | 2 | AC-33 and AC-34 remain unchecked as orchestrator-owned |
