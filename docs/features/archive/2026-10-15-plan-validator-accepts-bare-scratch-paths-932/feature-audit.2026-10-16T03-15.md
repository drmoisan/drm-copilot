# Feature Audit: plan-validator-accepts-bare-scratch-paths (Issue #932) — Re-audit after Remediation Cycle 1

- Review timestamp: 2026-10-16T03-15 (UTC)
- Companion artifacts: `policy-audit.2026-10-16T03-15.md`, `code-review.2026-10-16T03-15.md`
- Prior audit: `feature-audit.2026-10-16T01-52.md` (31 PASS, AC-23 pending CI; verdict REMEDIATION_REQUIRED from plan task `[P3-T6]`).

## Scope and Baseline

- Branch / head: `bug/plan-validator-accepts-bare-scratch-paths-932` @ `b752fc1f7825f858f5311dafce92b99fe935c46d`.
- Base: `origin/main`, merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99` (unchanged since Phase 0; no rebase).
- Work mode: `full-bug` (`issue.md:12`). AC source: `spec.md` only (`## Acceptance Criteria`; checkbox items at lines 156-205).
- Plans: `plan.2026-10-15T15-45.md` (all tasks checked, including `[P3-T6]` at line 203) and `remediation-plan.2026-10-16T01-52.md` (all tasks checked); both pass `validate_orchestration_artifacts.py plan` (reviewer run).
- Baseline behaviour: at the merge base, a plan defining `SCRATCH` as the bare session scratchpad passes the Python CLI and the MCP port; `test_scratch_location_contracts.py` uses the six-literal `FORBIDDEN_SCRATCH_PATHS` denylist; the Codex atomic-planner/executor TOMLs carry no `## Scratch Location` section; `jest.config.cjs` fails a direct ESLint run with `no-undef`.
- Evidence sources: executor evidence under `evidence/` (including the cycle-1 `remediation-baseline/` and `*-rc1` artifacts); reviewer reruns listed in the policy audit Section 6; PR context regenerated for head `b752fc1f7`.

## Acceptance Criteria Inventory

| ID | Group | Criterion (abbreviated) | State in `spec.md` before review |
| --- | --- | --- | --- |
| AC-01 | Python | `plan_gate_scratch.py` exposes `G10_SEVERITY`, `bare_scratch_definitions`, `evaluate_scratch_gate`; severity equals `BLOCKING_CHANNEL` | checked |
| AC-02 | Python | No finding for accepted forms | checked |
| AC-03 | Python | One finding per rejected form | checked |
| AC-04 | Python | No finding for non-definitions or fenced definitions | checked |
| AC-05 | Python | Wrapped definition reported at first line; continuation stops at heading, fence, task line | checked |
| AC-06 | Python | Frozen message with apostrophe and tab | checked |
| AC-07 | Python | `evaluate_plan_gates` reports G10 with and without context | checked |
| AC-08 | Python | CLI exits 1 with `Line N:` message; namespaced plan has no G10 finding | checked |
| AC-09 | TypeScript | Module exports and re-export | checked |
| AC-10 | TypeScript | Same fixtures and frozen strings | checked |
| AC-11 | TypeScript | Dispatcher, `validateArtifactWithWarnings`, MCP throw | checked |
| AC-12 | Parity | Severity constant parity test | checked |
| AC-13 | Parity | `_PYTHON_GATE_MODULES` includes module; no-repr test passes | checked |
| AC-14 | Parity | TS no-`pythonRepr(` list includes module | checked |
| AC-15 | Coverage config | jest per-file threshold 85/75 | checked |
| AC-16 | Contract test | Denylist removed; detector plus root regex scan | checked |
| AC-17 | Contract test | Parametrized self-test | checked |
| AC-18 | Contract test | Codex TOMLs in `RULE_SOURCES` / `EXECUTOR_SOURCES`; tests pass | checked |
| AC-19 | Codex | Scratch Location text at FR-6 anchors | checked |
| AC-20 | Codex | Variants and bundle copies match generator | checked |
| AC-21 | Codex | Codex parity and schema suites pass | checked |
| AC-22 | Docs | Rule file documents G10 completely | checked |
| AC-23 | Docs | Bundle copies byte-identical; verified by CI node | unchecked (CI-dependent) |
| AC-24 | Docs | Docstrings/JSDoc name G10 | checked |
| AC-25 | Docs | Rules frontmatter test passes | checked |
| AC-26 | Governance | Decision rule precedes measurement; result recorded | checked |
| AC-27 | Governance | Plan passes validation with no G10 finding | checked |
| AC-28 | Governance | No plan file outside the feature folder | checked |
| AC-29 | Quality | Python toolchain one pass | checked |
| AC-30 | Quality | TypeScript toolchain one pass | checked |
| AC-31 | Quality | Coverage thresholds and no changed-line regression | checked |
| AC-32 | Quality | File size and no temporary files | checked |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence |
| --- | --- | --- |
| AC-01 | PASS | `test_g10_severity_is_blocking` passed (reviewer run at head `b752fc1f7`). |
| AC-02 | PASS | `test_bare_scratch_definitions_accepts_namespaced_forms` (3 params) passed. |
| AC-03 | PASS | `test_bare_scratch_definitions_flags_unnamespaced_forms` (11 params) passed. |
| AC-04 | PASS | `test_bare_scratch_definitions_ignores_non_definitions` (6 params incl. fenced) passed. |
| AC-05 | PASS | `test_wrapped_definition_reports_first_line` and `test_logical_line_stops_at_heading_fence_and_task_line` (ids `indented-fence`, `column-0-heading`, `column-0-task-line`) passed. Cycle 1 removed the unreachable heading/task-line conditions without changing behaviour, and `spec.md` logical-line rule 2 now states that a column-0 heading or task line ends the logical line while an indented one is absorbed; the absorb fixtures freeze that behaviour. |
| AC-06 | PASS | `test_g10_message_matches_frozen_string[apostrophe,tab]` passed. |
| AC-07 | PASS | `test_evaluate_plan_gates_reports_g10_with_and_without_context` passed. |
| AC-08 | PASS | `test_cli_rejects_bare_scratch_definition`, `test_cli_accepts_namespaced_scratch_definition` passed. |
| AC-09 | PASS | Exports and re-export unchanged by cycle 1; `plan-gate-scratch.test.ts` passed in the full jest run. |
| AC-10 | PASS | `plan-gate-scratch.test.ts` mirrors the Python fixtures, now including the absorb and separator fixtures (`:230-269`); suite passed. |
| AC-11 | PASS | Dispatcher, `validateArtifactWithWarnings`, and throw-path cases passed in the full jest run (271 suites, 4020 tests). |
| AC-12 | PASS | `test_g10_severity_constant_matches_typescript` passed. |
| AC-13 | PASS | `test_no_repr_formatting_in_gate_messages` passed. |
| AC-14 | PASS | `plan-gate-parity.test.ts` passed. |
| AC-15 | PASS | `jest.config.cjs:385-390` (`lines: 85`, `branches: 75`); file unchanged by cycle 1. |
| AC-16 | PASS | `test_scratch_location_contracts.py` passed (included in the 183-test reviewer run). |
| AC-17 | PASS | `test_scratch_pattern_check_self_test` (4 params) passed. |
| AC-18 | PASS | Codex `RULE_SOURCES` / `EXECUTOR_SOURCES` cases passed. |
| AC-19 | PASS | Codex TOMLs unchanged since the prior review, where the text and anchors were verified; contract suites passed. |
| AC-20 | PASS | `test_generate_codex_agent_variants.py` passed (reviewer run, 634-test batch). |
| AC-21 | PASS | The four named Codex suites passed in the reviewer's 634-test batch. |
| AC-22 | PASS | All listed elements remain present; `test_rule_file_documents_g10` passed. Cycle 1 also corrected the scope and Enforcement text (`.claude/rules/plan-acceptance-gates.md:15,17,292`) and added the issue-token false-negative class (`:169`). A precision gap in the new parity-residual sentence is recorded as code-review N-1 (Non-blocking); it does not affect an element this criterion lists. |
| AC-23 | UNVERIFIED | Pending CI by the criterion's own text. Local evidence: `cmp` identical for the rule file and both skill copies; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passed locally (reviewer run). Left unchecked for the S9 check-off by the item's orchestrator run. |
| AC-24 | PASS | `test_discrimination_docstrings_name_g10` and the TS JSDoc case passed. |
| AC-25 | PASS | `test_claude_rules_frontmatter.py` passed. |
| AC-26 | PASS | Unchanged since the prior audit: decision rule `3135d7ee2` precedes the measurement; result in `evidence/qa-gates/g10-corpus-measurement.2026-10-16T01-21.md`. |
| AC-27 | PASS | Reviewer: `validate_orchestration_artifacts.py plan` exit 0 for `plan.2026-10-15T15-45.md` (and for `remediation-plan.2026-10-16T01-52.md`). |
| AC-28 | PASS | `git diff --name-only adb9aa5f0 HEAD` lists `plan.2026-10-15T15-45.md` and `remediation-plan.2026-10-16T01-52.md`, both inside this feature folder. |
| AC-29 | PASS | Reviewer: `black --check` (9 unchanged), `ruff check` (clean), `pyright` (0 errors), and the named pytest suites (183 + 634 passed). |
| AC-30 | PASS | Reviewer: `prettier --check` and `eslint` clean on all changed TypeScript and config files, including `jest.config.cjs` (prior CR-1 resolved); both `tsc --noEmit` exit 0; full `jest --coverage` 271 suites / 4020 tests passed. |
| AC-31 | PASS | `plan_gate_scratch.py` 100%/100%; `plan-gate-scratch.ts` 100%/100%; `plan_gate_discrimination.py` 97.74%/94.23% and `plan-gate-discrimination.ts` 100%/98.27% with no changed-line regression; cycle-1 modified `plan_gate_commands.py` 99.07%/95.00% and `plan-gate-commands.ts` 95.94%/85.39% with all changed lines executed. |
| AC-32 | PASS | Largest changed file 494 lines; no temporary-file API in any changed test (reviewer grep). |

## Cycle-1 Regression Check

- The shared splitter changes the Python command extractor's line splitting. A reviewer scan of `docs/**/*.md` for the affected separators found no plan or remediation-plan containing one, so no existing G1-G9 result changes; both suites now freeze the new behaviour.
- No previously passing test fails; the full jest suite and the Python plan-gate, contract, and Codex suites pass at head `b752fc1f7`.

## Summary

Thirty-one of thirty-two criteria are PASS; AC-23 is UNVERIFIED only because its verifier is the CI run on the PR head, and local evidence supports it. The prior Blocking finding (plan task `[P3-T6]`) is resolved, and cycle 1 introduced no regression. The review verdict is PASS. Two related Non-blocking documentation findings (code-review N-1, N-2) are available for in-item correction at the orchestrator's discretion.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/spec.md`
- Total AC items: 32
- Checked off (delivered): 31
- Remaining (unchecked): 1
- Items remaining: AC-23 — "`extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md` is byte-identical to the repository rule file, and `.claude/skills/atomic-plan-contract/SKILL.md` and its bundle copy both state the shipped set as G1 through G10 and are byte-identical to each other. Verified by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passing in CI." (pending CI; owner: the item's orchestrator run at S9)

## Acceptance Criteria Check-off

- Every criterion evaluated PASS (AC-01 to AC-22, AC-24 to AC-32) was already checked in `spec.md`. The reviewer confirmed each and made no checkbox change.
- AC-23 remains unchecked (UNVERIFIED, CI-dependent).
- Newly checked off by this review: none.
