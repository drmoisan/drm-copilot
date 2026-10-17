# Feature Audit: parallel-items-fail-completion-on-promotion-receipts (Issue #849)

- Issue: #849
- Branch: bug/parallel-items-fail-completion-on-promotion-receipts-849
- Head: 5cbc47a0c3e846172300fd301af26db0ddfc94db
- Audit timestamp: 2026-10-10T15-11 (UTC)

## Scope and Baseline

- Base: origin/main @ 0ea7978a79b2ef5b237043923bff299e2b45cddf; merge base 0ea7978a79b2ef5b237043923bff299e2b45cddf.
- Diff anchor: `git diff origin/main...HEAD` (94 files). Merge commits 3412e7f5a and baf63356b bring main-side content and are excluded by the three-dot range.
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, generated 2026-10-10 15:07:28 UTC at head 5cbc47a0c (current).
- Work Mode: `full-bug` (from `issue.md` `- Work Mode: full-bug`). AC source: `spec.md` only. No `user-story.md` applies.
- Plan: `plan.2026-10-09T01-33.md`, 100 checked tasks, 0 unchecked.
- Baseline evidence: `evidence/baseline/` (Phase 0, including PowerShell H0 copies from CI run 38057875117).

## Acceptance Criteria Inventory

- Source: `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md`, section `## Acceptance Criteria`.
- Format: markdown checkboxes, AC-1 through AC-18.
- State on entry to review: 18 of 18 checked (checked by the executor in Phase 9).

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence (reviewer-verified unless noted) |
|---|---|---|
| AC-1 Python resolver accepts absent record for transferred / filed_before_orchestration | PASS | 3 positive tests in `test_orchestrator_state_issue_adoption_waivers.py` (filed_before_orchestration bug, transferred feature, preparation route) assert `errors == ()` and the declared waived set. Reviewer re-run: 156 targeted tests passed. |
| AC-2 TypeScript parity of AC-1 | PASS | `orchestrator-state-issue-adoption-origin.test.ts` positive cases; reviewer re-run: 3 suites, 86 tests passed. |
| AC-3 PowerShell parity of AC-1 | PASS | 3 positive `It` cases in `OrchestratorStateIssueAdoption.Tests.ps1`; sanitized JUnit from CI run 38060952234 shows each `status="Passed"` (reviewer grep). |
| AC-4 epic_decomposition without record still errors, empty waived set | PASS | Per-runtime unit test in all three runtimes; fixture `epic-decomposition-waives-entry-tool-without-record.json` passes in all three parity suites (Python reviewer re-run; TS reviewer re-run; Pester JUnit `Passed`). |
| AC-5 present null / invalid record validated as before | PASS | Null-record and invalid-path tests in all three runtimes; fixture `filed-before-orchestration-invalid-present-record.json` passes in all three parity suites. |
| AC-6 five fixtures exist; parity suites pass on every corpus file | PASS | `git diff --name-status` shows five `A` fixture entries; Python and TypeScript parity re-run by reviewer; Pester parity 37 tests, 0 failures. |
| AC-7 fail-before / pass-after regression evidence | PASS | `evidence/regression-testing/py-parity-expect-fail.2026-10-09T01-33.md` (D1 fails with rule-9 `new_potential_bug_entry` error and both missing-receipt errors); pass-after in `py-parity-pass-after`, `ts-parity-origin-pass-after`, and the Pester JUnit D1 testcase `Passed`. |
| AC-8 existing fixtures byte-unchanged; no error string changes | PASS | Fixture diff contains additions only; reviewer read the full production diff and found no added, removed, or altered error literal; `evidence/other/fixture-immutability.2026-10-09T01-33.md` concurs. |
| AC-9 corpus floors equal re-counted corpus | PASS | Floors set to 34 in Python, TypeScript, Pester; reviewer re-count: 34 files by enumeration, 34 by `"name"` content search; `evidence/other/corpus-recount.2026-10-09T01-33.md` compares member sets. |
| AC-10 parallel-plan intake bullet and fan-out adoption line; kickoff line unchanged | PASS | Skill diff; `test_parallel_issue_adoption_skill_contracts.py` passes (reviewer re-run) and failed before the edit (`py-skill-contracts-expect-fail`, 8 failed). |
| AC-11 parallel-orchestrate element 4 extended; no new element or heading | PASS | Skill diff adds lines inside element 4 only; contract test and `test_parallel_orchestrator_surface_contracts.py` pass (reviewer re-run). |
| AC-12 no hook issue-number shape, no active path, no mode marker | PASS | Contract tests pass; `test_parallel_planner_surface_contracts.py` and `test_parallel_kickoff_template_seam.py` pass (reviewer re-run); `enforce-orchestration-preimplementation-gate.Tests.ps1` 35 tests, 0 failures (CI JUnit). |
| AC-13 rule document states origin-conditional requirement and promoted-path sentence | PASS | Diff of `.claude/rules/orchestrator-state.md` table row, rule 9, and new paragraph; pinned by `test_rule_doc_states_origin_conditional_potential_record`. |
| AC-14 orchestrate and feature-promotion-lifecycle skills state the same requirement | PASS | Skill diffs; pinned by `test_skill_states_origin_conditional_potential_record[orchestrate]` and `[feature-promotion-lifecycle]`. |
| AC-15 byte-identical bundled mirrors; push-down bundle test passes | PASS | Reviewer `cmp` of six files: identical; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passed in the reviewer re-run. |
| AC-16 Python toolchain clean; module coverage >= 85% line / >= 75% branch, no regression | PASS | Reviewer re-run: black, ruff, pyright clean; module 100% line and branch. Executor full suite 6870 passed, 0 failed (`qa-gates/py-full-suite`). Changed-line coverage 3/3 (`qa-gates/py-coverage-delta`). |
| AC-17 TypeScript toolchain clean; module coverage thresholds, no regression | PASS | Reviewer re-run: prettier, eslint, tsc clean; module 100% all measures. Executor `test:coverage` 3981 passed, exit 0 (`qa-gates/ts-coverage`). |
| AC-18 PowerShell format/analyze clean; Pester suites pass; module line >= 85% from XML | PASS | CI run 38060952234: FormatStep and AnalyzeStep success (analyzer throws on any finding); sanitized JUnit 122 suites / 3051 tests / 0 failures across the three scan folders; coverage XML LINE 116/116 = 100.00% (reviewer read the counter directly). |

## Summary

All 18 acceptance criteria are verified as PASS against branch evidence and reviewer re-runs. Blocking findings: 0. Non-blocking findings: 6 (recorded in `policy-audit.2026-10-10T15-11.md` section 8 and `code-review.2026-10-10T15-11.md`):

1. Stale "Source A" cross-reference in `evidence/qa-gates/ps-analyze.2026-10-09T01-33.md`.
2. Phase 9 evidence `Timestamp:` values later than the commit that adds them.
3. `/parallel-add` preparation-child residual (documented out of scope; follow-up not yet filed).
4. Positional boolean `recordPresent` in the TypeScript helper.
5. One over-length line in `.claude/skills/parallel-plan/SKILL.md` (cosmetic).
6. Promotion `Status:` path in `issue.md` and the promoted record omits the dated folder name.

Relative to baseline, the change resolves both root causes in `spec.md`: the parallel planning and execution skills now instruct each child to record `issue_adoption`, and rule 9 is satisfiable without a potential record for `transferred` and `filed_before_orchestration` origins. The integration scenario in `issue.md` (a live parallel item completing with zero missing-receipt errors) is not exercised on this branch; it is covered at the validator level by the preparation-route corpus fixture and is not an acceptance criterion in `spec.md`.

Feature audit verdict: **PASS**. No remediation inputs are required.

## Acceptance Criteria Check-off

All 18 items were already checked in `spec.md` by the executor. The reviewer evaluated each as PASS, so no item was unchecked and no new check-off was required.

### Acceptance Criteria Status
- Source: docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md
- Total AC items: 18
- Checked off (delivered): 18
- Remaining (unchecked): 0
- Items remaining: none
