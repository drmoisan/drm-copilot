# Feature Audit: plan-validator-accepts-bare-scratch-paths (Issue #932) — Re-audit after Remediation Cycle 2

- Review timestamp: 2026-10-16T05-25 (UTC)
- Companion artifacts: `policy-audit.2026-10-16T05-25.md`, `code-review.2026-10-16T05-25.md`
- Prior audit: `feature-audit.2026-10-16T03-15.md` (31 PASS, AC-23 pending CI; verdict PASS).

## Scope and Baseline

- Branch / head: `bug/plan-validator-accepts-bare-scratch-paths-932` @ `95d61f2a5fcdef6cbb25e8152dac60cb4ca3daf9`.
- Base: `origin/main`, merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99` (unchanged since Phase 0; no rebase).
- Work mode: `full-bug` (`issue.md:12`). AC source: `spec.md` only (`## Acceptance Criteria`; 32 checkbox items).
- Plans: `plan.2026-10-15T15-45.md`, `remediation-plan.2026-10-16T01-52.md`, and `remediation-plan.2026-10-16T03-19.md`; all three pass `validate_orchestration_artifacts.py plan` (reviewer run) and have no unchecked task. The cycle-2 plan has 59 task lines (`[P0-T*]` to `[P5-T*]`), all checked; the caller's figure of 61 tasks was not reproduced, and the only unchecked box in the file is inside a code example (`:602`).
- Baseline behaviour: at the merge base, a plan defining `SCRATCH` as the bare session scratchpad passes the Python CLI and the MCP port. At the cycle-2 start (`64fb37f2b`), the two G10 runtimes classified NEL, the information separators, and the byte-order mark differently for continuation and normalization, the `splitPlanLines` comment named `str.splitlines()`, and the Python G6 cross-line check split tracked text with `splitlines()`.
- Evidence sources: executor evidence under `evidence/` (including `remediation-baseline/*-rc2*`, `regression-testing/*-rc2*`, `qa-gates/*-rc2*`); reviewer reruns listed in the policy audit Section 6; PR context regenerated for head `95d61f2a5`.

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
| AC-01 | PASS | `test_g10_severity_is_blocking` passed (reviewer run at head `95d61f2a5`, 196-test batch). |
| AC-02 | PASS | `test_bare_scratch_definitions_accepts_namespaced_forms` passed. |
| AC-03 | PASS | `test_bare_scratch_definitions_flags_unnamespaced_forms` passed. |
| AC-04 | PASS | `test_bare_scratch_definitions_ignores_non_definitions` passed. |
| AC-05 | PASS | `test_wrapped_definition_reports_first_line` and `test_logical_line_stops_at_heading_fence_and_task_line` passed. Cycle 2 changes only which characters count as leading whitespace; column-0 headings, fences, and task lines still end the logical line. |
| AC-06 | PASS | `test_g10_message_matches_frozen_string[apostrophe,tab]` passed; tab is a member of `PLAN_WHITESPACE_CLASS`, so the frozen string is unchanged. |
| AC-07 | PASS | `test_evaluate_plan_gates_reports_g10_with_and_without_context` passed. |
| AC-08 | PASS | `test_cli_rejects_bare_scratch_definition`, `test_cli_accepts_namespaced_scratch_definition` passed. |
| AC-09 | PASS | Exports and re-export unchanged except the added `PLAN_WHITESPACE_CLASS` export; `plan-gate-scratch.test.ts` passed in the full jest run. |
| AC-10 | PASS | `plan-gate-scratch.test.ts` mirrors the Python fixtures, now including the whitespace-class continuation and normalization fixtures (`:271-315`); suite passed. |
| AC-11 | PASS | Dispatcher, `validateArtifactWithWarnings`, and throw-path cases passed in the full jest run (271 suites, 4023 tests). |
| AC-12 | PASS | `test_g10_severity_constant_matches_typescript` passed. |
| AC-13 | PASS | `test_no_repr_formatting_in_gate_messages` passed. |
| AC-14 | PASS | `plan-gate-parity.test.ts` passed. |
| AC-15 | PASS | `jest.config.cjs` per-file entry for `./src/lib/validate/plan-gate-scratch.ts` (`lines: 85`, `branches: 75`); file unchanged by cycle 2; `npm run test:coverage` exit 0 with no threshold message. |
| AC-16 | PASS | `test_scratch_location_contracts.py` passed (included in the 196-test reviewer run). |
| AC-17 | PASS | `test_scratch_pattern_check_self_test` passed. |
| AC-18 | PASS | Codex `RULE_SOURCES` / `EXECUTOR_SOURCES` cases passed. |
| AC-19 | PASS | Codex TOMLs unchanged since the prior review; contract suites passed. |
| AC-20 | PASS | `test_generate_codex_agent_variants.py` passed (reviewer 634-test batch). |
| AC-21 | PASS | The four named Codex suites passed in the reviewer's 634-test batch. |
| AC-22 | PASS | All listed elements remain present; `test_rule_file_documents_g10` passed. Cycle 2 replaced the parity-residual sentence with the shared-class statement and the fence-pattern residual (`.claude/rules/plan-acceptance-gates.md:153`), asserted by `test_rule_file_states_g10_whitespace_alignment`. |
| AC-23 | UNVERIFIED | Pending CI by the criterion's own text (remediability: awaiting_ci). Local evidence: `cmp` identical for the rule file and the `atomic-plan-contract` skill copies; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passed locally (reviewer run). Left unchecked for the S9 check-off by the item's orchestrator run. |
| AC-24 | PASS | `test_discrimination_docstrings_name_g10` and the TS JSDoc case passed. |
| AC-25 | PASS | `test_claude_rules_frontmatter.py` passed. |
| AC-26 | PASS | Unchanged: decision rule `3135d7ee2` precedes the measurement; result in `evidence/qa-gates/g10-corpus-measurement.2026-10-16T01-21.md`. |
| AC-27 | PASS | Reviewer: `validate_orchestration_artifacts.py plan` exit 0 for `plan.2026-10-15T15-45.md` (and for both remediation plans). |
| AC-28 | PASS | The branch diff lists three plan files, all inside this feature folder: `plan.2026-10-15T15-45.md`, `remediation-plan.2026-10-16T01-52.md`, `remediation-plan.2026-10-16T03-19.md`. |
| AC-29 | PASS | Reviewer: `black --check` (11 unchanged), `ruff check` (clean), `pyright` (0 errors), and the named pytest suites (196 + 634 passed). |
| AC-30 | PASS | Reviewer: `prettier --check` and `eslint` clean on all 11 changed TypeScript/config files; `npm run typecheck` exit 0; `npm run test:coverage` (working directory `extensions/drm-copilot/`) 271 suites / 4023 tests passed, exit 0. |
| AC-31 | PASS | `plan_gate_scratch.py` 100% (55/55) / 100% (16/16); `plan-gate-scratch.ts` 100% (226/226) / 100% (31/31); `plan_gate_discrimination.py` 98.50% / 96.15% with changed lines 34 and 279 executed; `plan-gate-commands.ts` cycle-2 change comment-only. |
| AC-32 | PASS | Largest changed file 494 lines; no temporary-file API in any changed test (reviewer grep, exit 1). |

## Remediation Cycle 2 Verification

| Item | Verdict | Evidence |
| --- | --- | --- |
| N-1 (one whitespace class, both runtimes) | PASS | Identical `PLAN_WHITESPACE_CLASS` string in both modules, pinned by `test_whitespace_class_matches_typescript`; reviewer probe shows the class is the exact intersection of Python `isspace()` and JavaScript `\s` (24 code points). Frozen fixtures cover NEL (U+0085), U+001F, and the byte-order mark (characters on which the native classes disagree) plus U+00A0, in both suites. Rule file, bundle copy (`cmp` identical), and `spec.md` NFR-2 state the alignment. |
| N-2 (splitter comment) | PASS | `plan-gate-commands.ts:268` names `split_plan_lines`. |
| U-1 (G6 splitter) | PASS | `plan_gate_discrimination.py:279` uses `split_plan_lines`; form-feed and U+2028 parity fixtures in both suites, recorded red before the fix; corpus A/B 508 plans, 0 differing, 1175 findings before and after. |

## Regression Check

- No previously passing test fails: the full jest suite, the Python plan-gate suites, and the contract and Codex suites pass at head `95d61f2a5`; the executor's full dev-tools run reports 7080 passed (`evidence/qa-gates/python-devtools-final-rc2.2026-10-16T05-18.md`).
- The G10 output changes only for plans containing NEL, an information separator, or the byte-order mark at the start of a continuation line or inside a logical line; the cycle-1 corpus scan found no plan containing those characters.

## Findings

- Blocking: none.
- Related Non-blocking: N-3 (code review): G6 whitespace normalization in `_has_cross_line_presence` / `_window_join` and their TypeScript twins still uses the native whitespace classes. Severity: Non-blocking. Remediability: autonomous. It does not affect any acceptance criterion in `spec.md`.
- Unrelated: U-2 (jest threshold-key messages when invoked from the repository root; invocation-dependent and pre-existing) and U-3 (promotion path in `issue.md:5`), both previously declined.

## Summary

Thirty-one of thirty-two criteria are PASS; AC-23 is UNVERIFIED only because its verifier is the CI run on the PR head, and local evidence supports it. All three cycle-2 items (N-1, N-2, U-1) are resolved and introduced no regression. The review verdict is PASS with zero Blocking findings. One related Non-blocking finding (N-3) is available for in-item correction at the orchestrator's discretion.

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
