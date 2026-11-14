# Feature Audit: Orchestration Test Cadence, Task Check and Phase Gate (Issue #1167)

**Audit Date:** 2026-11-12
**Branch:** `bug/orchestration-test-cadence-targeted-per-task-1167` @ `b9a97e86590e0d2a0a026d29d63b3ef6cba145de` (PR #1168)
**Base:** `main`; merge base `228e6f8c4606e53f36963dc9aa57d71b4882b49e`

## Scope and Baseline

- Scope: the full branch diff `228e6f8c4..b9a97e865`, 168 files, read through `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated 06:12 UTC at this head) and direct `git diff`. Re-review after remediation cycle R1.
- Baseline: the merge base on `main` (equal to `origin/main` at review time), and the Phase 0 artifacts `evidence/baseline/pester.2026-11-12T03-25.md`, `pytest.2026-11-12T03-29.md`, `powershell-static.2026-11-12T03-12.md`, `python-static.2026-11-12T03-14.md`.
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
| AC1 | PASS | Reviewer read the section, including the R1 expect-fail and no-change bullets, in `.claude/skills/atomic-plan-contract/SKILL.md`; base and bundle share blob `f47258725`; `TCW-CANONICAL-*` and `TCW-CANONICAL-DISCRIMINATES` pass in the reviewer run. The F1 design gap is closed. |
| AC2 | PASS | `parallel-gate-wording.Tests.ps1` absent from the diff; its rows pass in the reviewer run; reviewer search of the contract at head for the #1094 tokens and `Targeted runs are allowed` returned no line. |
| AC3 | PASS | `TCW-POLICY`, `REMEDIATION`, `DELEGATION`, `EXECUTOR`, `PLANNER`, `RULE`, `QAGATE`, `PROMPT`, `BRIEF` rows and `TCW-SWEEP-SURFACES` pass; the sweep now includes `CLAUDE.md` and `.github/copilot-instructions.md`. |
| AC4 | PASS | Diffs of the four texts; CR2 wording in the two loop sections; `TCW-POLICY-*` rows pass. |
| AC5 | PASS | R3 and `atomic-executor` delegation bullets in both orchestrate copies carry the reference; `TCW-REMEDIATION-*`, `TCW-DELEGATION-*` pass. |
| AC6 | PASS | Planner diffs carry the D15 sentence; `TCW-PLANNER-*` pass; templates show gates in intermediate phases (bug Phases 2 and 3, feature Phase 1, refactor Phase 2) and `TCW-TEMPLATE-*` pass with layout checks. Reviewer mutants of the bug template were detected. |
| AC7 | PASS | Executor and prompt surfaces unchanged since the prior review, which confirmed them; `TCW-EXECUTOR-*` and `TCW-PROMPT-*` pass. |
| AC8 | PASS | Brief copies unchanged in R1; the prior review confirmed one blob id across the six copies; brief contracts pass in `evidence/qa-gates/pytest.2026-11-12T06-02.md`. |
| AC9 | PASS | Reviewer run of `generate_codex_agent_variants --check`: exit 0 after the R1 planner base edit. |
| AC10 | PASS | Suite present with canonical, reference, sweep plus helper, and byte-identity groups; 136 rows pass in the R1 phase gate, the final gate, and the reviewer run. |
| AC11 | PASS | Final gates 0 failures (`evidence/qa-gates/pester.2026-11-12T05-59.md`, `pytest.2026-11-12T06-02.md`); reviewer run of the PCW and PGW suites passes. |
| AC12 | PASS | Commit `9b99051ae` carries the entry and index row with `reduction: 0011`; five ledger suites pass in the reviewer run; reviewer replay of 74 revert blocks restores 49 of 49 sources to the merge base. |
| AC13 | PASS | Pester 95.80% equal to Phase 0; pytest 97.11% and 94.37% equal to Phase 0 (reviewer parse of the coverage artifacts); `git diff --name-only` of the branch shows no forbidden path and no added `.py` file. |
| AC14 | PENDING-CI | `gh pr checks 1168` at 06:30 UTC on `b9a97e865`: all checks passed except `poshqc / PowerShell QC shard 1` and `shard 2`, still pending. Not a blocking finding; checked off at S9 by the item's orchestrator run. |

## Findings Outside the Criterion Text

- None blocking. Prior finding F1 is resolved. Informational items N1 to N3 are in `code-review.2026-11-12T06-25.md`.

## Summary

13 PASS, 1 pending CI, 0 FAIL. No blocking finding.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-11-11-orchestration-test-cadence-targeted-per-task-1167/spec.md`
- Total AC items: 14
- Checked off (delivered): 13
- Remaining (unchecked): 1
- Items remaining: AC14 (CI-dependent): CI is green on the PR head.

## Acceptance Criteria Check-off

AC1 to AC13 were already checked in `spec.md` by the executor with evidence; this review confirms each as PASS and makes no new check-off. AC14 stays unchecked as pending CI. No item was unchecked.
