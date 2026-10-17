# Feature Audit: plan-validator-accepts-bare-scratch-paths (Issue #932)

- Review timestamp: 2026-10-16T01-52 (UTC)
- Companion artifacts: `policy-audit.2026-10-16T01-52.md`, `code-review.2026-10-16T01-52.md`, `remediation-inputs.2026-10-16T01-52.md`

## Scope and Baseline

- Branch / head: `bug/plan-validator-accepts-bare-scratch-paths-932` @ `eaabea814519c1ada33121870fb8a00cb3433350`.
- Base: `origin/main`, merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99` (equal to the Phase 0 baseline in `evidence/baseline/git-baseline.2026-10-16T00-27.md`; no rebase).
- Work mode: `full-bug` (`issue.md:12`). AC source: `spec.md` only (`## Acceptance Criteria`, lines 151-204).
- Plan: `plan.2026-10-15T15-45.md`; 79 tasks checked, 1 unchecked (`[P3-T6]`, see code-review CR-1).
- Baseline behaviour: at the merge base, a plan defining `SCRATCH` as the bare session scratchpad passes `validate_orchestration_artifacts.py plan` and the MCP port; `test_scratch_location_contracts.py` uses the six-literal `FORBIDDEN_SCRATCH_PATHS` denylist; the Codex atomic-planner/executor TOMLs carry no `## Scratch Location` section.
- Evidence sources: executor evidence under `evidence/`; reviewer reruns listed in the policy audit Section 6; PR context regenerated at 2026-10-16 01:43 UTC.

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
| AC-01 | PASS | `plan_gate_scratch.py:47,53,97,176`; `test_g10_severity_is_blocking` passed (reviewer run). |
| AC-02 | PASS | `test_bare_scratch_definitions_accepts_namespaced_forms` (3 params) passed. |
| AC-03 | PASS | `test_bare_scratch_definitions_flags_unnamespaced_forms` (11 params incl. backticked, bold, `:=`, `=`, `:`, `889/`) passed. |
| AC-04 | PASS | `test_bare_scratch_definitions_ignores_non_definitions` (6 params incl. fenced) passed. |
| AC-05 | PASS | `test_wrapped_definition_reports_first_line` and `test_logical_line_stops_at_heading_fence_and_task_line` passed; behaviour holds for column-0 headings and task lines. Note: the heading and task-line checks themselves are unreachable (code-review CR-2); the observable behaviour required by the criterion is met. |
| AC-06 | PASS | `test_g10_message_matches_frozen_string[apostrophe,tab]` passed. |
| AC-07 | PASS | `test_evaluate_plan_gates_reports_g10_with_and_without_context` passed; wiring at `plan_gate_discrimination.py:394-395`. |
| AC-08 | PASS | `test_cli_rejects_bare_scratch_definition`, `test_cli_accepts_namespaced_scratch_definition` passed. |
| AC-09 | PASS | `plan-gate-scratch.ts:41,162,221`; re-export at `plan-gate-discrimination.ts:71-76`; re-export case passed. |
| AC-10 | PASS | `plan-gate-scratch.test.ts:30-91` mirrors the Python fixtures and frozen strings; suite passed. |
| AC-11 | PASS | Dispatcher and `validateArtifactWithWarnings` cases in `plan-gate-scratch.test.ts:262-300`; throw case `validate-orchestration-service-call-plan-gates.test.ts:128-146`; suites passed. |
| AC-12 | PASS | `test_g10_severity_constant_matches_typescript` passed. |
| AC-13 | PASS | `test_plan_gate_parity.py:49`; `test_no_repr_formatting_in_gate_messages` passed. |
| AC-14 | PASS | `plan-gate-parity.test.ts:319`; suite passed. |
| AC-15 | PASS | `jest.config.cjs:385-390` (`lines: 85`, `branches: 75`). |
| AC-16 | PASS | `FORBIDDEN_SCRATCH_PATHS` absent; `scratch_violations` uses `bare_scratch_definitions` and `SCRATCHPAD_ROOT_RE` (`test_scratch_location_contracts.py:119-138`); scan test passed. |
| AC-17 | PASS | `test_scratch_pattern_check_self_test` (4 params) passed. |
| AC-18 | PASS | `RULE_SOURCES`, `EXECUTOR_SOURCES`, placement params include the Codex TOMLs (`:46-47,52,67-72,87-92`); all parametrized cases passed. |
| AC-19 | PASS | `.codex/agents/atomic-planner.toml:69-77` and `.codex/agents/atomic-executor.toml:96-105` equal the Claude persona text and sit between the FR-6 anchors. |
| AC-20 | PASS | `test_generate_codex_agent_variants.py` passed (reviewer run, includes `--check`); `cmp` identical for all 12 variant/base TOMLs and bundle copies. |
| AC-21 | PASS | The four named suites passed (629 tests in the reviewer run, together with three plan-gate suites). |
| AC-22 | PASS | Rule file contains the G10 row, prefix exception, shipped set G1-G10, severity subsection with measurement and operator-approved scope, Enforcement bullet, and the four false-negative classes; `test_rule_file_documents_g10` passed. Two residual stale sentences are tracked as CR-3 and do not contradict an element the criterion lists. |
| AC-23 | UNVERIFIED | Pending CI by the criterion's own text. Local evidence: `cmp` identical for the rule file and both skill copies; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passed locally (reviewer run). Left unchecked for the S9 check-off. |
| AC-24 | PASS | `plan_gate_discrimination.py:3-17,355-363`; `plan-gate-discrimination.ts:257-266`; `test_discrimination_docstrings_name_g10` and the TS JSDoc case passed. |
| AC-25 | PASS | `test_claude_rules_frontmatter.py` passed; `paths:` globs `scripts/dev_tools/plan_gate_*` and `extensions/drm-copilot/src/lib/validate/plan-gate-*` reach both modules. |
| AC-26 | PASS | Plan `[P5-T1]` (line 251) precedes `[P5-T4]` (line 260); rule committed in `3135d7ee2` before the measurement; result in `evidence/qa-gates/g10-corpus-measurement.2026-10-16T01-21.md` (493 files, 17 findings, 0 false positives). |
| AC-27 | PASS | Reviewer: `validate_orchestration_artifacts.py plan <plan>` exit 0, `plan validation passed`; plan defines `SCRATCH` as `<session scratchpad>/issue-932/` (line 27). |
| AC-28 | PASS | `git diff --name-status adb9aa5f0 HEAD` lists one plan file, inside this feature folder. |
| AC-29 | PASS | Reviewer: `black --check` (7 unchanged), `ruff check` (clean), `pyright` (0 errors), and the named pytest suites passed. |
| AC-30 | PASS | Reviewer: `prettier --check` clean, `eslint` clean on the changed `.ts` files and via the repository `lint` script (executor `[P6-T8]`), both `tsc --noEmit` exit 0; full `jest --coverage` 271 suites / 4016 tests (executor `[P6-T11]`). The separate `[P3-T6]` command that also lints `jest.config.cjs` fails on a pre-existing error (CR-1); the criterion's `npx eslint` step as run by the repository script passes. |
| AC-31 | PASS | `plan_gate_scratch.py` 100%/100%; `plan-gate-scratch.ts` 100%/100%; modified modules show no changed-line regression (policy audit Section 5). |
| AC-32 | PASS | Largest changed file 494 lines; no temporary-file API in new or changed tests (reviewer grep). |

## Summary

Thirty-one of thirty-two criteria are PASS; AC-23 is UNVERIFIED only because its verifier is the CI run on the PR head, and local evidence supports it. The delivered behaviour matches the spec: bare SCRATCH definitions now fail plan preflight in both runtimes, the scratch contract test shares the production detector, and the Codex agent families carry the scratch rule.

The review verdict is REMEDIATION_REQUIRED because of one autonomous Blocking finding outside the AC set: plan task `[P3-T6]` is unchecked due to a pre-existing ESLint `no-undef` error in `jest.config.cjs` (code-review CR-1). Related Non-blocking findings CR-2 to CR-6 are recommended for the same remediation cycle; see `remediation-inputs.2026-10-16T01-52.md`.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/spec.md`
- Total AC items: 32
- Checked off (delivered): 31
- Remaining (unchecked): 1
- Items remaining: AC-23 — "`extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md` is byte-identical to the repository rule file, and `.claude/skills/atomic-plan-contract/SKILL.md` and its bundle copy both state the shipped set as G1 through G10 and are byte-identical to each other. Verified by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passing in CI." (pending CI; owner: the item's orchestrator run at S9)

## Acceptance Criteria Check-off

- Every criterion evaluated PASS (AC-01 to AC-22, AC-24 to AC-32) was already checked in `spec.md` by the executor (`evidence/other/ac-checkoff.2026-10-16T01-36.md`). The reviewer confirmed each and made no checkbox change.
- AC-23 remains unchecked (UNVERIFIED, CI-dependent).
- Newly checked off by this review: none.
