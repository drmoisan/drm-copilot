# Feature Audit: plan-validator-accepts-bare-scratch-paths (Issue #932) — Re-audit after Remediation Cycle 3 (exit gate)

- Review timestamp: 2026-10-16T07-38 (UTC)
- Companion artifacts: `policy-audit.2026-10-16T07-38.md`, `code-review.2026-10-16T07-38.md`
- Prior audit: `feature-audit.2026-10-16T05-25.md` (31 PASS, AC-23 pending CI; verdict PASS).

## Scope and Baseline

- Branch / head: `bug/plan-validator-accepts-bare-scratch-paths-932` @ `990db511f1bd9d3f96d0470b8464257f01aeff4e`.
- Base: `origin/main` @ `b6be46b5e`, merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99` (unchanged since Phase 0; no rebase). `git merge-tree` against `origin/main` reports no conflicted path.
- Work mode: `full-bug` (`issue.md:12`). AC source: `spec.md` only (`## Acceptance Criteria`; 32 checkbox items).
- Plans: `plan.2026-10-15T15-45.md`, `remediation-plan.2026-10-16T01-52.md`, `remediation-plan.2026-10-16T03-19.md`, and `remediation-plan.2026-10-16T05-36.md`; all four pass `validate_orchestration_artifacts.py plan` (reviewer run). The cycle-3 plan has 62 task lines, all checked, matching the caller's figure.
- Baseline behaviour: at the merge base, a plan defining `SCRATCH` as the bare session scratchpad passes the Python CLI and the MCP port. At the cycle-3 start (`95d61f2a5`), G6 normalized tracked text with each runtime's native whitespace class, so a tracked file containing NEL or the byte-order mark could produce different G5/G6 results in Python and TypeScript, and `PLAN_WHITESPACE_CLASS` was declared in the two G10 modules.
- Evidence sources: executor evidence under `evidence/` (including `remediation-baseline/*-rc3*`, `regression-testing/*-rc3*`, `qa-gates/*-rc3*`); reviewer reruns listed in the policy audit Section 6; PR context regenerated for head `990db511f`.

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
| AC-01 | PASS | `test_g10_severity_is_blocking` passed (reviewer run at head `990db511f`, 203-test batch). |
| AC-02 | PASS | `test_bare_scratch_definitions_accepts_namespaced_forms` passed. |
| AC-03 | PASS | `test_bare_scratch_definitions_flags_unnamespaced_forms` passed. |
| AC-04 | PASS | `test_bare_scratch_definitions_ignores_non_definitions` passed. |
| AC-05 | PASS | `test_wrapped_definition_reports_first_line` and `test_logical_line_stops_at_heading_fence_and_task_line` passed. Cycle 3 moved the normalizer without changing its behaviour; the G10 whitespace fixtures in `test_plan_gate_scratch_whitespace.py` still pass. |
| AC-06 | PASS | `test_g10_message_matches_frozen_string[apostrophe,tab]` passed. |
| AC-07 | PASS | `test_evaluate_plan_gates_reports_g10_with_and_without_context` passed. |
| AC-08 | PASS | `test_cli_rejects_bare_scratch_definition`, `test_cli_accepts_namespaced_scratch_definition` passed. |
| AC-09 | PASS | `G10_SEVERITY`, `bareScratchDefinitions`, `evaluateScratchGate`, `scratchFindingMessage` exported and re-exported from `plan-gate-discrimination.ts:71-76`; `PLAN_WHITESPACE_CLASS` is now exported from `plan-gate-commands.ts` instead (a cycle-2 addition, not part of the criterion); `npm run typecheck` exit 0 and `plan-gate-scratch.test.ts` passed. |
| AC-10 | PASS | `plan-gate-scratch.test.ts` mirrors the Python fixtures; passed in the full jest run. |
| AC-11 | PASS | Dispatcher, `validateArtifactWithWarnings`, and throw-path cases passed in the full jest run (271 suites, 4025 tests). |
| AC-12 | PASS | `test_g10_severity_constant_matches_typescript` passed. |
| AC-13 | PASS | `test_no_repr_formatting_in_gate_messages` passed. |
| AC-14 | PASS | `plan-gate-parity.test.ts` passed. |
| AC-15 | PASS | `jest.config.cjs` per-file entry for `./src/lib/validate/plan-gate-scratch.ts` (`lines: 85`, `branches: 75`); file unchanged by cycle 3; `npm run test:coverage` exit 0. |
| AC-16 | PASS | `test_scratch_location_contracts.py` passed (included in the 203-test reviewer run). |
| AC-17 | PASS | `test_scratch_pattern_check_self_test` passed. |
| AC-18 | PASS | Codex `RULE_SOURCES` / `EXECUTOR_SOURCES` cases passed. |
| AC-19 | PASS | Codex TOMLs unchanged since the prior review; contract suites passed. |
| AC-20 | PASS | `test_generate_codex_agent_variants.py` passed (reviewer 634-test batch). |
| AC-21 | PASS | The four named Codex suites passed in the reviewer's 634-test batch. |
| AC-22 | PASS | All listed elements remain present; `test_rule_file_documents_g10`, `test_rule_file_states_g10_whitespace_alignment`, and `test_rule_file_states_g6_whitespace_alignment` passed. Cycle 3 extended the parity paragraph (`.claude/rules/plan-acceptance-gates.md:153`) with the single declaration site, G6 alignment, and the plan-quotation residual, and kept the fence-pattern residual sentence. |
| AC-23 | UNVERIFIED | Pending CI by the criterion's own text (remediability: awaiting_ci). Local evidence: `cmp` exit 0 for the rule file and the `atomic-plan-contract` skill copies; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passed locally (reviewer run). Left unchecked for the S9 check-off by the item's orchestrator run. |
| AC-24 | PASS | `test_discrimination_docstrings_name_g10` and the TS JSDoc case passed. |
| AC-25 | PASS | `test_claude_rules_frontmatter.py` passed. |
| AC-26 | PASS | Unchanged: decision rule `3135d7ee2` precedes the measurement; result in `evidence/qa-gates/g10-corpus-measurement.2026-10-16T01-21.md`. |
| AC-27 | PASS | Reviewer: `validate_orchestration_artifacts.py plan` exit 0 for `plan.2026-10-15T15-45.md` (and for all three remediation plans). |
| AC-28 | PASS | The branch diff lists four plan files, all inside this feature folder: `plan.2026-10-15T15-45.md` and `remediation-plan.2026-10-16T{01-52,03-19,05-36}.md`. |
| AC-29 | PASS | Reviewer: `black --check` (11 unchanged), `ruff check` (clean), `pyright` (0 errors), and the named pytest suites (203 + 634 passed). |
| AC-30 | PASS | Reviewer: `prettier --check` and `eslint` clean on all 12 changed TypeScript/config files; `npm run typecheck` and `npm run lint` exit 0; `npm run test:coverage` 271 suites / 4025 tests passed, exit 0. |
| AC-31 | PASS | `plan_gate_scratch.py` 100% (52/52) / 100% (16/16); `plan-gate-scratch.ts` 100% (208/208) / 100% (29/29); every changed line in `plan_gate_commands.py`, `plan_gate_discrimination.py`, `plan-gate-commands.ts`, and `plan-gate-rules.ts` executed; every changed module is above 85% line and 75% branch. |
| AC-32 | PASS | Largest changed file 494 lines; no temporary-file API in any changed test (reviewer grep, exit 1). |

## Remediation Cycle 3 Verification

| Item | Verdict | Evidence |
| --- | --- | --- |
| N-3: G6 single-line test and window join use the G10 class in both runtimes | PASS | `plan_gate_discrimination.py:262-263,278-279,287` and `plan-gate-rules.ts:395-397,421-422,431` call `normalize_plan_whitespace` / `normalizePlanWhitespace`, which use `PLAN_WHITESPACE_CLASS`. |
| N-3: class declared once per runtime; string parity pinned | PASS | Declared at `plan_gate_commands.py:336` and `plan-gate-commands.ts:288` only; `test_whitespace_class_declared_once_per_runtime` asserts the counts; `test_whitespace_class_matches_typescript` compares the TypeScript string (now read from `plan-gate-commands.ts`) to the Python string. |
| N-3: NEL and byte-order-mark fixtures, both directions | PASS | Four frozen cases in each literal suite. Red evidence shows the NEL cases failing in Python only and the byte-order-mark cases failing in TypeScript only before the fix (`python-red-rc3.2026-10-16T06-25.md`, `ts-red-rc3.2026-10-16T06-25.md`). |
| N-3: corpus A/B with a discriminating probe, no G1-G9 change | PASS | `g6-whitespace-corpus-ab-rc3.2026-10-16T07-16.md`: both probes differ, 509 plans, 0 differing per runtime, 1175 findings before and after. |
| N-3: rule file, bundle copy, NFR-2 note | PASS | Rule file line 153 and the bundle copy (`cmp` identical) state the shared class for G6 and keep the fence-pattern residual; `spec.md` NFR-2 note updated (cycle 1 to 3 note). |
| Empty-needle branch tests (`a1576c292`) | PASS | Python and TypeScript cases expect the G5 absent finding for literal `' '`; the reviewer's in-memory mutation probe shows the Python test fails when the guard is removed; the Python guard at `plan_gate_discrimination.py:251-252` was unexecuted at the cycle-3 baseline and is executed now. |
| Coverage and file size | PASS | Both G10 modules at 100% line and 100% branch; no changed line uncovered; largest changed file 494 lines. |

## Regression Check

- No previously passing test fails: the full jest suite, the Python plan-gate suites, and the contract and Codex suites pass at head `990db511f`; the executor's full dev-tools run reports 7087 passed, 6 skipped, with no newly failing node (`evidence/qa-gates/python-devtools-final-rc3.2026-10-16T07-34.md`).
- The G6 output changes only for tracked files whose candidate lines contain NEL, an information separator, or the byte-order mark; the corpus A/B shows no change on the 509-plan corpus.

## Findings

- Blocking: none.
- Related Non-blocking: N-4 (Info, code review): the G5 plan-quotation exoneration keeps each runtime's native whitespace class. The code is unchanged since the merge base, outside the N-3 scope, and the residual is stated accurately in the rule file and NFR-2 note. Severity: Non-blocking. Remediability: autonomous. It does not affect any acceptance criterion in `spec.md`.
- Unrelated: U-2 (jest threshold-key messages when invoked from the repository root; invocation-dependent and pre-existing) and U-3 (promotion path in `issue.md:5`; promotion-tooling output), both previously declined.

## Summary

Thirty-one of thirty-two criteria are PASS; AC-23 is UNVERIFIED only because its verifier is the CI run on the PR head, and local evidence supports it. N-3 is resolved in both runtimes with discriminating fixtures, a declaration-count guard, and corpus evidence of no G1-G9 change. The review verdict is PASS with zero Blocking findings.

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
