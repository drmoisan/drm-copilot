# Feature Audit: parallel-only-test-gates-and-leak-scan (#1094)

---

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094`
**Base Branch:** `origin/main`
**Head Branch:** `feature/parallel-only-test-gates-and-leak-scan-1094`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after the remediation of RF-1 to RF-4

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `9a19be8e72ea479212e2e43c3ad766afb270fae6`)
- **Head branch/commit:** `feature/parallel-only-test-gates-and-leak-scan-1094` (commit `2c5c12a0885f2ff1e45e78a18919e5a179c4584a`)
- **Merge base:** `9a19be8e72ea479212e2e43c3ad766afb270fae6`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated at head `2c5c12a08`, current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/`
  - Additional evidence: `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, `coverage/lcov.info`, and reviewer probes at head
- **Feature folder used:** `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` states `- Work Mode: full-feature`.
- **Scope note:** The audit scope is the full diff against the merge base. The owner directive applies: no single-process, shuffled, reversed-order, comparison, or pre-change run is required, and the absence of one is not a finding.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/spec.md` — primary
- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/user-story.md` — secondary; the same 15 criteria, with section references that name `spec.md`

### Acceptance criteria

1. No skill, agent, or template text in the repository requires a serial, single-process, seeded-shuffle, reversed-order, comparison, or pre-change test-suite baseline run. Measured as stated in Decision 1: no skill, agent, or template text requires such a run or names a serial command as a validation gate, and the brief states that the parallel gates govern where a policy file names a toolchain test command. The residual limit in `## Constraints & Risks` applies: the deferred Python tools and VS Code aggregates still invoke a serial command until #1096.
2. The branch diff changes no file under `.claude/rules/` or `.github/instructions/`, no bundle copy of those files, and neither `.agents/skills/powershell` nor `.agents/skills/python`.
3. The branch diff changes no file under `.github/workflows/` or `scripts/powershell/PoshQC/`, and does not change `.vscode/tasks.json`, the Python tools named in `### 2. Out of scope`, or the policy-audit validators.
4. `## Test Isolation Checks` states the parallel gates, names no leak scan, and all mirrored copies match.
5. The `## Test Runtime`, `## CI-Only Failure Classes`, and `## PowerShell Route and PoshQC MCP Limits` passages of the brief carry the changes listed in `### 1. Parallel-only test gates`, in every mirrored copy, and `## CI-Only Failure Classes` names no scan.
6. The Pre-Mortem `Test isolation` bullet of `atomic-plan-contract` states the parallel gates, names no leak scan, and names no removed run, in every mirrored copy.
7. No plan-contract or review text requires a comparison run, and the brief states that a focused run of one test file is debugging only and is never a gate or evidence.
8. Static tool baselines remain required, and skill, agent, and template text reads coverage from the single gate run against the thresholds, in every mirrored copy.
9. The policy-audit template requires no pre-change run, its retained baseline fields record `N/A - no pre-change run`, and a contract test shows that an audit filled in that way passes the unchanged policy-audit validators.
10. Every editable surface in table A3 of the research, except `scripts/dev_tools/fix_all_branches.py`, no longer names a serial command as a validation gate, and tool-permission entries in those surfaces are unchanged.
11. The contract tests pass against the new wording and fail if the removed requirements are reintroduced, in any mirrored copy.
12. `test_execution_environment_fact_is_unchanged_across_copies` filters on the parts relative to `REPO_ROOT` and passes in a checkout under `.claude/worktrees/`.
13. `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.
14. The validation evidence for this item comes from the parallel gates, and cites no single-process, seeded-shuffle, reversed-order, comparison, or focused run.
15. CI-dependent: `CI Required Gate` reports success on the final PR head.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | No text requires a removed or comparison run | PARTIAL | RF-1 and RF-2 are closed, and the brief carries the governing sentence. `.github/agents/staged-review.agent.md` and its bundle copy still require a subset run as a review step and record its output as evidence (RF-5). | `git grep` over the skill, agent, prompt, template, and bundle roots at head | Criterion 1 does not name a subset run. The grade follows the spec `### 1` rule that a focused run is never a gate or evidence, and the prior grading of RF-2. Policy-file residuals and deferred tools are excluded per Decision 1. |
| 2 | No policy file changes | PASS | Path-limited diff is empty, including the bundle copies. | `git diff --name-only` from the merge base over the policy paths | |
| 3 | No CI, PoshQC, tasks, tool, or validator change | PASS | Path-limited diff is empty. | `git diff --name-only` from the merge base over `.github/workflows`, `scripts/powershell/PoshQC`, `.vscode/tasks.json`, `scripts/dev_tools`, and `extensions/drm-copilot/src` | |
| 4 | Test Isolation Checks and mirror match | PASS | Section read at head; the six copies share one blob. | `git ls-files -s` on the six `execution-environment/SKILL.md` copies | |
| 5 | Brief passages in every copy | PASS | Passages read at head; one blob across six copies; `## CI-Only Failure Classes` names no scan. | Section reads at head | |
| 6 | Pre-Mortem bullet in every copy | PASS | Bullet read; `test_contract_premortem_test_isolation_states_parallel_gates` covers six copies. Each bundle copy shares the blob of its source. | `git ls-files -s` on the `atomic-plan-contract` copies | |
| 7 | No plan-contract or review comparison; focused run is debugging only | PASS | Plan-contract and review text carries no comparison run; the brief states the rule. | `git grep` for comparison wording at head | RF-5 is a subset run, not a comparison run, so it does not reach this criterion. |
| 8 | Static baselines stay; coverage from the single gate run | PASS | The plan contract requires static baselines in Phase 0. Comparison tokens return 0 hits at head over 902 surface files. Per-file coverage wording in skills and agents reads against the thresholds. 107 mirror pairs are equal. | Token replay at head; `git grep` for coverage comparison phrasing | Reverted to unchecked by the prior audit; rechecked here. |
| 9 | Template and validators accept the record | PASS | The template records `N/A - no pre-change run`. Two Python tests and two Jest cases pin the record, and all passed in the gates. The validators are unchanged. The policy audit of this review carries the same record. | Diff read; `evidence/qa-gates/jest-coverage.2026-11-07T04-03.md`; validator runs on `policy-audit.2026-11-07T04-20.md` | Reverted to unchecked by the prior audit; rechecked here. |
| 10 | A3 surfaces; permissions unchanged | PASS | No listed surface names a serial command as a gate. The scope check records 0 changed tool-entry lines over 148 agent files. | `git grep` over the A3 surfaces | `staged-review.agent.md` is outside table A3. |
| 11 | Contract tests pass and discriminate | PASS | Gates green. The 12 added tokens hit 2 to 18 files at the merge base and 0 at head, and the sweep reads every mirror root. | Scratch replay of tokens against merge-base and head blobs | RF-5 wording is not a removed requirement that returned; its token is added under RF-5. |
| 12 | Worktree filter fixed | PASS | The test uses `path.relative_to(REPO_ROOT).parts`, and the pytest gate ran in the item worktree with 0 failures. | `git diff` from the merge base on `test_discovery_documentation_contracts.py` | |
| 13 | Parallel gates zero failures | PASS | Pester: ExitCode 0, JUnit 14510 tests, 0 failures. Pytest: 16103 passed, 0 failures. Both ran after the last change outside the feature folder. | JUnit read of `artifacts/pester/pester-junit.xml`; `evidence/qa-gates/pytest-parallel.2026-11-07T04-07.md` | |
| 14 | Evidence from the parallel gates | PASS | The removed-run words appear only in the quoted issue text under `evidence/issue-updates/`. `evidence/qa-gates/` and `evidence/remediation-baseline/` hold none. | `grep` over `evidence/` | |
| 15 | CI Required Gate on final PR head | UNVERIFIED | Pending CI. No PR exists yet, so CI has not run on this head. | `gh pr list --head feature/parallel-only-test-gates-and-leak-scan-1094` returned no PR | Owned by the item's orchestrator at S9. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 13 criteria
- **PARTIAL:** 1 criteria
- **UNVERIFIED:** 1 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. RF-5: `staged-review.agent.md` and its bundle copy require a subset run as a review step and use its output as evidence (criterion 1).

**Recommended follow-up verification steps:**

1. Replace the step, add the `smallest applicable subset` sweep token, and confirm that the text is absent from both copies.
2. Re-run the affected gates once each, then re-check criterion 1.

---

## Acceptance Criteria Check-off

Criteria 8 and 9 evaluate as PASS and were checked off in `spec.md` and `user-story.md`, changing only the checkbox. Criteria 2 to 7 and 10 to 14 were already checked, and this audit confirms them as PASS. Criterion 1 evaluates as PARTIAL and stays unchecked. Criterion 15 is pending CI and stays unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/spec.md`, `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/user-story.md`
- Total AC items: 15 per file
- Checked off (delivered): 13 per file
- Remaining (unchecked): 2 per file
- Items remaining: criterion 1 (no text requires a removed or comparison run), criterion 15 (`CI Required Gate` on the final PR head)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 15 | 13 | 2 | Checkbox-backed |
| `user-story.md` | 15 | 13 | 2 | Checkbox-backed |
