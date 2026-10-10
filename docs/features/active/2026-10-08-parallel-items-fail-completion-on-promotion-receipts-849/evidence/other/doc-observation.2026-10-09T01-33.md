# Post-Edit Document Observation (P5-T6, Issue #849)

Timestamp: 2026-10-10T14-32
Command: Read tool over .claude/rules/orchestrator-state.md (lines 277, 289, 293), .claude/skills/orchestrate/SKILL.md (line 445), and .claude/skills/feature-promotion-lifecycle/SKILL.md (line 48)
EXIT_CODE: 0
Output Summary: all five quoted passages match their plan text blocks (R1, R2, R3, O1, L1) verbatim; P5-T3 recorded `test_rule_doc_states_origin_conditional_potential_record` and both `test_skill_states_origin_conditional_potential_record` cases as PASSED (AC-13, AC-14).

## R1 - `.claude/rules/orchestrator-state.md`, line 277 (`potential_record` table row)

```text
| `potential_record` | When waiving a promotion-entry tool: required when `origin` is `epic_decomposition`, optional when `origin` is `transferred` or `filed_before_orchestration`, and validated whenever it is present (a path under `docs/features/potential/` ending in `.md`). |
```

Matches text block R1: yes.

## R2 - `.claude/rules/orchestrator-state.md`, line 289 (rule 9)

```text
9. Only when the rule-8 shape check passed: each distinct waived promotion-entry tool (`new_potential_entry` or `new_potential_bug_entry`) requires a valid `potential_record`, except that rule 9 reports nothing when `origin` is `transferred` or `filed_before_orchestration` and the `potential_record` key is absent. A present `potential_record`, including `null`, is always validated.
```

Matches text block R2: yes.

## R3 - `.claude/rules/orchestrator-state.md`, line 293 (paragraph after "The closed waivable set is" at line 291)

```text
A lifecycle record moved to `docs/features/potential/promoted/` satisfies the `potential_record` path rule, because the rule checks only the `docs/features/potential/` prefix and the `.md` suffix and does not check that the file exists.
```

Matches text block R3: yes.

## O1 - `.claude/skills/orchestrate/SKILL.md`, line 445 (replaced sentence pair within the paragraph)

```text
It may waive only `potential_to_issue` and the checkpoint's promotion-entry tool (`new_potential_entry`, or `new_potential_bug_entry` for a bug-type checkpoint); `potential_to_issue` must always be listed. For a promotion-entry waiver, `potential_record` (a markdown path under `docs/features/potential/`) is required when `origin` is `epic_decomposition`, optional when `origin` is `transferred` or `filed_before_orchestration`, and validated whenever it is present.
```

Matches text block O1: yes. The surrounding sentences of the line-445 paragraph ("When the GitHub issue already exists before orchestration starts ..." through "... under `## Invariants (issue_adoption object)`.") are unchanged.

## L1 - `.claude/skills/feature-promotion-lifecycle/SKILL.md`, line 48 (step 2 of the adopted-issue list)

```text
2. Record a top-level `issue_adoption` object in the orchestrator checkpoint (`issue_num`, `issue_url`, `origin`, `verified_via`, `verified_at`, `evidence`, `waived_tools`, and, when a promotion-entry tool is waived, `potential_record`). For that waiver `potential_record` is required when `origin` is `epic_decomposition`, optional when `origin` is `transferred` or `filed_before_orchestration`, and validated whenever it is present. A valid record waives the `potential_to_issue` receipt requirement at completion.
```

Matches text block L1: yes.

## Named-test citation

From `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-skill-contracts-pass-after.2026-10-09T01-33.md` (P5-T3, EXIT_CODE 0, 11 passed):

```text
tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py::test_rule_doc_states_origin_conditional_potential_record PASSED [ 81%]
tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py::test_skill_states_origin_conditional_potential_record[feature-promotion-lifecycle] PASSED [ 90%]
tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py::test_skill_states_origin_conditional_potential_record[orchestrate] PASSED [100%]
```
