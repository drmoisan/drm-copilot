# Feature Audit: Orchestration Test Cadence, Task Check and Phase Gate (Issue #1167)

**Audit Date:** 2026-11-12
**Branch:** `bug/orchestration-test-cadence-targeted-per-task-1167` @ `d789aa821f900b36dfc884952ffc45126e15a042` (PR #1168)
**Base:** `main`; merge base `228e6f8c4606e53f36963dc9aa57d71b4882b49e`

## Scope and Baseline

- Scope: the full branch diff `228e6f8c4..d789aa821`, 149 files, read through `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated at this head) and direct `git diff`.
- Baseline: the merge base on `main`, and the Phase 0 artifacts `evidence/baseline/pester.2026-11-12T03-25.md`, `pytest.2026-11-12T03-29.md`, `powershell-static.2026-11-12T03-12.md`, `python-static.2026-11-12T03-14.md`.
- Requirements source and work mode: `issue.md` marker `Work Mode: full-bug`, so the AC source is `spec.md` `## Acceptance Criteria` only.
- Review mode: concurrent; CI on PR #1168 runs alongside this review.

## Acceptance Criteria Inventory

| ID | Criterion (abbreviated) | Source |
|---|---|---|
| AC1 | Six contract copies carry `## Test Cadence (Mandatory)` before `## Final QA Loop`, stating D3 to D6; bases equal bundles | `spec.md` |
| AC2 | No #1094 sweep token or `Targeted runs are allowed` in new text; `parallel-gate-wording.Tests.ps1` unchanged and passing | `spec.md` |
| AC3 | Every referring surface of D7 to D9 names the section; no surface prescribes a per-task full run | `spec.md` |
| AC4 | Four general code-change texts and bundles state phase-gate and final-QA requirement, contract reference, CI integration, restart from step 1 | `spec.md` |
| AC5 | Orchestrate R3 sentence replaced; delegation guidance references the cadence | `spec.md` |
| AC6 | Planner surfaces require `[phase-gate]`; three templates show one in an intermediate phase | `spec.md` |
| AC7 | Executor surfaces and hard-lock prompts reference the cadence; Copilot language executors relabel their toolchain | `spec.md` |
| AC8 | Brief copies byte-identical with the four required brief edits and the pinned sentence retained | `spec.md` |
| AC9 | Generator `--check` exits 0 | `spec.md` |
| AC10 | New suite exists with the four row groups and passes in the gates | `spec.md` |
| AC11 | Existing contract and parity tests pass | `spec.md` |
| AC12 | Ledger entry `0011` and README row in the same commit; chain tests pass | `spec.md` |
| AC13 | No coverage regression; forbidden paths untouched; no new Python file | `spec.md` |
| AC14 | CI green on the PR head (CI-dependent) | `spec.md` |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| AC1 | PASS | Reviewer read the section in `.claude/skills/atomic-plan-contract/SKILL.md`; `TCW-CANONICAL-*` rows (next-heading check) pass in the reviewer run; base and bundle share blob `254bc870e`. The design gap in F1 lies in what D4 omits, not in a missing AC1 element. |
| AC2 | PASS | `parallel-gate-wording.Tests.ps1` absent from the diff; its 56 rows pass in the reviewer run; `TCW-*` forbidden lists pass. |
| AC3 | PASS | `TCW-POLICY`, `REMEDIATION`, `DELEGATION`, `EXECUTOR`, `PLANNER`, `RULE`, `QAGATE`, `PROMPT`, `BRIEF` rows and `TCW-SWEEP-SURFACES` pass; the sweep tokens occur in 30 or more surface files at the merge base and in none at head. |
| AC4 | PASS | Diffs of the four texts; `TCW-POLICY-*` rows pass. |
| AC5 | PASS | R3 and `atomic-executor` delegation bullets in both orchestrate copies carry the reference; `TCW-REMEDIATION-*`, `TCW-DELEGATION-*` pass. |
| AC6 | PASS | Planner diffs; `TCW-PLANNER-*` and `TCW-TEMPLATE-*` pass. See F1: the templates satisfy AC6 as written but conflict with the canonical rule in the `[expect-fail]` phase. |
| AC7 | PASS | Executor and prompt diffs; `TCW-EXECUTOR-*` and `TCW-PROMPT-*` pass; `Phase-gate and final-QA toolchain for Python` label read in the diff. |
| AC8 | PASS | Six brief copies share blob `0804a2afa`; brief diff shows the four edits; pinned sentence retained (pytest brief contracts pass in the final gate). |
| AC9 | PASS | Reviewer run of `generate_codex_agent_variants --check`: exit 0. |
| AC10 | PASS | Suite present with canonical, reference, sweep plus helper, and byte-identity groups; 135 rows pass in the phase gate, final gate, and reviewer run. |
| AC11 | PASS | Final gates 0 failures (`evidence/qa-gates/pester.2026-11-12T04-19.md`, `pytest.2026-11-12T04-23.md`); reviewer run of the PCW and PGW suites passes. |
| AC12 | PASS | Commit `9b99051ae` carries both files and `reduction: 0011`; five ledger suites pass in the reviewer run (149 tests). |
| AC13 | PASS | Pester 95.80% equal to Phase 0; pytest 97.11% and 94.37% equal to Phase 0 (reviewer parse of the coverage artifacts); `git diff --name-only` shows no forbidden path and no `.py` file. |
| AC14 | PENDING-CI | `gh pr checks 1168` at review time: all checks passed except two PowerShell QC shards, still pending. Not a blocking finding; checked off at S9 by the item's orchestrator run. |

## Findings Outside the Criterion Text

- F1 (blocking, design): the phase-gate rule gives no provision for a phase that ends with an `[expect-fail]` test failing, and the bug template omits the gate in Phases 1 and 2. Detail in `code-review.2026-11-12T04-53.md` and `remediation-inputs.2026-11-12T04-53.md`.

## Summary

13 PASS, 1 pending CI, 0 FAIL. One blocking design finding outside the criterion text.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-11-11-orchestration-test-cadence-targeted-per-task-1167/spec.md`
- Total AC items: 14
- Checked off (delivered): 13
- Remaining (unchecked): 1
- Items remaining: AC14 (CI-dependent): CI is green on the PR head.

## Acceptance Criteria Check-off

AC1 to AC13 were already checked in `spec.md` by the executor with evidence; this review confirms each as PASS and makes no new check-off. AC14 stays unchecked as pending CI. No item was unchecked.
