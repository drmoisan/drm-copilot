# Acceptance-Criteria Reconciliation

Timestamp: 2026-08-20T13-50
Task: [P12-T13]
Issue: #486
Work mode: full-feature, so the acceptance-criteria sources are `spec.md` and `user-story.md`.

Command: `grep -n "^- \[" <spec.md> <user-story.md>` plus per-criterion inspection of the named test bodies and evidence artifacts listed below.

EXIT_CODE: 0

Output Summary: 17 of 18 acceptance criteria re-verified as satisfied and left `[x]`. One criterion, spec `AC7`, was UNCHECKED because the shipped `G5_SEVERITY` value contradicts the criterion as written. Details below.

## Method

This is a reconciliation pass, not a first pass. Every criterion was already `[x]` on arrival. Each was re-verified against the artifact actually on disk — the named test body, or the named evidence file — rather than against the prior check-off. A criterion whose evidence did not support it was unchecked.

## Text-preservation deviation, recorded

`[P12-T13]`'s acceptance clause reads in part "each line names a test node ID or an evidence artifact path under the feature evidence tree". The criterion lines as authored describe their verification in prose ("Verified by two named tests per runtime") without naming node IDs. Appending node IDs to those lines would modify the criterion text, which rule 3 of `.claude/skills/acceptance-criteria-tracking/SKILL.md` prohibits ("change only `- [ ]` to `- [x]`; do not modify the criterion text"), and would also constitute authoring acceptance-criteria content, which rule 5 prohibits. The naming requirement is therefore satisfied by this artifact, which records the verifying node ID or evidence path for every criterion, and the criterion text is left byte-identical. This deviation is recorded rather than resolved silently.

## Spec acceptance criteria

| AC | Verifying node ID or evidence path | Result |
| --- | --- | --- |
| AC1 | Python `tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py::test_g5_reports_literal_absent_from_tree_and_plan` and `::test_g5_exonerates_literal_quoted_in_plan`; TypeScript `plan-gate-discrimination-literals.test.ts` `reports a literal absent from tree and plan` and `exonerates a literal quoted in the plan` | PASS — `[x]` retained |
| AC2 | Python `tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py::test_g1_reports_dotted_remedy_without_context`; TypeScript `plan-gate-discrimination-cov.test.ts` `reports the dotted remedy for a .py cov path without context`. Body re-read: it asserts `"scripts.dev_tools.foo" in finding` and `".py" not in remedy`, where `remedy` is sliced from the `Use --cov=` index, so the negative half of the criterion is genuinely asserted | PASS — `[x]` retained |
| AC3 | Python `tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py::test_structural_errors_match_recorded_baseline_strings`, `::test_clean_plan_returns_empty_without_context`, `::test_clean_plan_returns_empty_with_stub_context`; TypeScript `orchestration-artifacts-plan-gates.test.ts` `returns the seven existing structural error strings unchanged`, `returns an empty error list for a clean plan without context`, `returns an empty error list for a clean plan with a stub context`. Baseline reference: `evidence/baseline/existing-plan-error-strings.2026-08-20T11-40.md`. Re-verified that all seven baseline templates are exercised: the malformed fixture asserts six strings covering templates 1-5 (template 5 fires twice), and the empty fixture asserts templates 6 and 7 | PASS — `[x]` retained |
| AC4 | Python `::test_plan_route_reports_g1_without_new_flag` and `::test_plan_subparser_option_set_is_path_and_workspace_root`; TypeScript `orchestration-artifacts-plan-gates.test.ts` `reports a G1 finding on the existing plan route with no new flag` and `mcp-plan-gate-warning-projection.test.ts` `keeps the validate_orchestration_artifacts input-schema property-key set unchanged` (the latter asserts both duplicate schema modules) | PASS — `[x]` retained |
| AC5 | Python `test_plan_gate_discrimination_cov.py::test_every_finding_begins_with_task_identifier`, `test_plan_gate_commands.py::test_extract_plan_commands_skips_document_preamble`, `::test_extract_plan_commands_skips_phase_preamble`, `::test_extract_plan_commands_skips_span_after_intervening_heading`; TypeScript `every finding begins with the task identifier`, `skips a span in the document preamble`, `skips a span in a phase preamble`, `skips a span after an intervening heading`. Four named tests per runtime, as the criterion requires | PASS — `[x]` retained |
| AC6 | Python `::test_main_emits_warning_prefix_on_stderr_and_exits_zero`; TypeScript `validate-orchestration-service-call-plan-gates.test.ts` `does not throw when the only finding is a warning` and `surfaces the warning on the result warnings field`. Independently corroborated by the `[P12-T12]` run recorded in `evidence/qa-gates/self-gate-run.2026-08-20T13-42.md`, which emitted two warnings, printed the unchanged success line on stdout, and exited 0 | PASS — `[x]` retained |
| AC7 | `evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md`; shipped constants `scripts/dev_tools/plan_gate_discrimination.py:53` and `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts:69` | **FAIL — UNCHECKED.** See below |
| AC8 | Python `::test_g6_cross_line_literal_is_warning_and_not_blocking`; TypeScript `reports a cross-line literal as a warning`. The "and exit 0" half is carried by `::test_main_emits_warning_prefix_on_stderr_and_exits_zero` and by the `[P12-T12]` run | PASS — `[x]` retained |
| AC9 | Python `tests/scripts/dev_tools/test_plan_gate_parity.py::test_parity_findings_match_expected_strings`; TypeScript `plan-gate-parity.test.ts` `produces the same finding strings as the Python runtime`. The fixture set includes `PARITY_G1_APOSTROPHE` and `PARITY_G5_APOSTROPHE`, so the quote-selection class is covered. Evidence: `evidence/qa-gates/parity-fixture-run.2026-08-20T14-32.md`, 8 fixtures compared, 0 mismatches | PASS — `[x]` retained |
| AC10 | Python `::test_context_free_call_skips_context_rules` and `::test_failing_git_adapter_produces_no_findings`; TypeScript `skips context rules with no context` and `produces no finding when the git adapter throws` (plus `skips the tracked-tree cov rules when the adapter throws`) | PASS — `[x]` retained |
| AC11 | Python `tests/scripts/dev_tools/test_plan_gate_commands.py::test_extract_plan_commands_returns_exact_record_fields` and `::test_extract_plan_commands_classifies_kind_grep_pytest_cov_and_other`; TypeScript `returns the exact record field set` and `classifies grep, pytest_cov, and other kinds`. Body re-read: the Python test asserts `sorted(PlanCommand.__dataclass_fields__) == ["argv", "kind", "raw_span", "source_line", "task_id"]`, an exact-set assertion, and the kind test asserts `kinds == ["grep", "pytest_cov", "other"]` | PASS — `[x]` retained |
| AC12 | `evidence/qa-gates/branch-diff-file-list.2026-08-20T14-48.md`. Independently re-verified in this pass: a porcelain status query scoped to `.claude/hooks/validate-planner-output.ps1` produced 0 lines, and a name-only committed-diff query against `main` scoped to the same path produced 0 lines | PASS — `[x]` retained |

## AC7 — unchecked, with reasons

Criterion text, second conjunct: "G5's shipped severity is Blocking if and only if the recorded false-positive count is 0."

Facts on disk:

- `evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md` records `False-positive count: **0**` and `Total G5 finding count: **0**`.
- `scripts/dev_tools/plan_gate_discrimination.py:53` sets `G5_SEVERITY: str = WARNING_CHANNEL`; `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts:69` sets `export const G5_SEVERITY: string = "warning";`.

The recorded false-positive count is 0 and the shipped severity is Warning. The biconditional in AC7 therefore evaluates false, and the same single-conjunct rule appears in the spec body under `### G5 severity is fixed by a pre-declared measurement`: "ships **G5 as Blocking if and only if the measured false-positive count is 0**. Otherwise G5 ships as a Warning." AC7's first conjunct (the artifact exists and records the command, the exit code, the candidate-literal count, and the true-positive and false-positive counts) is fully satisfied; the criterion fails only on the second.

Why the delivered value is nonetheless what the approved plan required, which is a separate question from whether AC7 is met: the approved plan task `[P5-T3]` states a TWO-conjunct rule — `"blocking"` if and only if the total G5 finding count is greater than 0 **and** the false-positive count is 0 — and its acceptance clause states outright that a total finding count of 0 "does not license the Blocking severity", instructs the executor to record `MEASUREMENT INVALID`, set `"warning"`, and re-examine the driver, and adds "The executor should expect this branch to be taken." The executor followed the approved plan exactly. The additional conjunct is defensible on the merits: a false-positive count of 0 measured over 0 findings carries no information, so it cannot discharge a rule that was pre-declared to remove judgement from the decision.

The unresolved defect is a divergence between two documents, not a defect in the code:

- `spec.md` (AC7 and the `### G5 severity` section) states the ONE-conjunct rule.
- `plan.2026-08-17T15-00.md` `[P5-T3]`, `.claude/rules/plan-acceptance-gates.md`, and the measurement artifact state the TWO-conjunct rule.

The one-conjunct rule, applied literally to a vacuous measurement, forces Blocking on no evidence, which is the outcome the spec's own stated motivation ("Shipping G5 as Blocking without that measurement risks creating exactly the false-rejection generator the issue warns against") exists to prevent. The two-conjunct rule is the reading that matches that motivation.

Resolution belongs to the reviewer or the spec author, not to the executor, because both candidate resolutions are outside an executor's authority:

1. Amend `spec.md` AC7 and the `### G5 severity` section to state the two-conjunct rule, then re-check AC7. This is an acceptance-criteria edit, which rule 5 of the acceptance-criteria-tracking skill prohibits the executor from making.
2. Change `G5_SEVERITY` to Blocking in both runtimes to satisfy AC7 as written. This contradicts the approved plan task `[P5-T3]`, changes shipped behavior, and would make G5 Blocking on a measurement the evidence artifact itself labels `MEASUREMENT INVALID`.

AC7 is therefore left `[ ]` and reported as an outstanding acceptance criterion.

## User-story acceptance criteria

Each user-story criterion delegates its verification to a spec criterion. None of the six references AC7, so none is affected by the AC7 finding.

| AC | Delegates to | Verifying node ID | Result |
| --- | --- | --- | --- |
| AC-U1 | spec AC1 | `::test_g5_reports_literal_absent_from_tree_and_plan`, `::test_g5_exonerates_literal_quoted_in_plan` and the two TypeScript counterparts | PASS — `[x]` retained |
| AC-U2 | spec AC2 | `::test_g1_reports_dotted_remedy_without_context` and its TypeScript counterpart | PASS — `[x]` retained |
| AC-U3 | spec AC4 | `::test_plan_route_reports_g1_without_new_flag`, `keeps the validate_orchestration_artifacts input-schema property-key set unchanged` | PASS — `[x]` retained |
| AC-U4 | spec AC5 | the four attribution tests per runtime named in the AC5 row above | PASS — `[x]` retained |
| AC-U5 | spec AC6 | `::test_main_emits_warning_prefix_on_stderr_and_exits_zero`, `does not throw when the only finding is a warning`; corroborated by `evidence/qa-gates/self-gate-run.2026-08-20T13-42.md` | PASS — `[x]` retained |
| AC-U6 | spec AC3 | `::test_structural_errors_match_recorded_baseline_strings` and the two clean-plan tests per runtime | PASS — `[x]` retained |

## Sections deliberately NOT modified

The three checkboxes under `## Seeded Test Conditions (from potential)` in `spec.md` sit outside the `## Acceptance Criteria` section and are assigned by no plan task. They were left `[ ]`. Their exact text and an assessment of each is reported to the reviewer in the executor's completion report; the executor did not check them off, did not add to them, and did not reword them.
