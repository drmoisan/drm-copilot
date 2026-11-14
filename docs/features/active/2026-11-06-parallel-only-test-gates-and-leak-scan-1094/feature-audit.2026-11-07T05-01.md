# Feature Audit: parallel-only-test-gates-and-leak-scan (#1094)

---

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094`
**Base Branch:** `origin/main`
**Head Branch:** `feature/parallel-only-test-gates-and-leak-scan-1094`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after the remediation of RF-5

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `9a19be8e72ea479212e2e43c3ad766afb270fae6`)
- **Head branch/commit:** `feature/parallel-only-test-gates-and-leak-scan-1094` (commit `6b8c3640a48e0ea7f1c2c80e8bb89201d8a87164`)
- **Merge base:** `9a19be8e72ea479212e2e43c3ad766afb270fae6`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated at head `6b8c3640a`, current)
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
| 1 | No text requires a removed or comparison run | PASS | RF-5 is closed. An independent phrasing search over the skill, agent, prompt, template, and Codex roots found no passage that requires a removed run or names a serial command as a gate. `## Test Isolation Checks` carries the governing sentence for policy files. | `git grep` at head for run, subset, batch, focused, comparison, delta, and baseline phrasing, with each remaining hit read | Policy-file residuals and deferred tools are excluded per Decision 1. Remaining `baseline` hits are static baselines, evidence folder names, or other senses that the spec keeps. |
| 2 | No policy file changes | PASS | Path-limited diff is empty, including the bundle copies. | `git diff --name-only` from the merge base over the policy paths | |
| 3 | No CI, PoshQC, tasks, tool, or validator change | PASS | Path-limited diff is empty. | `git diff --name-only` from the merge base over `.github/workflows`, `scripts/powershell/PoshQC`, `.vscode/tasks.json`, `scripts/dev_tools`, and `extensions/drm-copilot/src` | |
| 4 | Test Isolation Checks and mirror match | PASS | Section read at head; the six copies share one blob; a search of the skill roots finds no leak scan name. | `git ls-files -s` on the six `execution-environment/SKILL.md` copies | |
| 5 | Brief passages in every copy | PASS | Passages read at head; one blob across six copies; `## CI-Only Failure Classes` names no scan. | Section reads at head | |
| 6 | Pre-Mortem bullet in every copy | PASS | Bullet read; `test_contract_premortem_test_isolation_states_parallel_gates` covers six copies. Each bundle copy shares the blob of its source. | `git ls-files -s` on the `atomic-plan-contract` copies | |
| 7 | No plan-contract or review comparison; focused run is debugging only | PASS | Plan-contract and review text carries no comparison run; the brief states the rule. | `git grep` for comparison wording at head | |
| 8 | Static baselines stay; coverage from the single gate run | PASS | The plan contract requires static baselines in Phase 0. Comparison searches return no requirement at head. All 66 changed sources with a same-path bundle copy equal that copy. | `git grep` for coverage comparison phrasing; pair hash comparison | |
| 9 | Template and validators accept the record | PASS | The template records `N/A - no pre-change run`. Two Python tests and two Jest cases pin the record against the two validators the spec names, and all passed in the gates. The validators are unchanged. `policy-audit.2026-11-07T05-01.md` carries the record and passed the policy-audit validator. | Diff read; `evidence/qa-gates/jest-coverage.2026-11-07T04-03.md`; validator run on the policy audit | Graded on the criterion text, which names the policy-audit validators. The separate stop hook rejects the record; that defect is RF-6 and is carried as a review finding, not under this criterion. |
| 10 | A3 surfaces; permissions unchanged | PASS | No listed surface names a serial command as a gate. A search of the agent diff returns 0 changed tool-entry lines. | `git grep` over the A3 surfaces; `git diff` from the merge base over the agent roots | |
| 11 | Contract tests pass and discriminate | PASS | Gates green. Each of the 5 cycle 2 tokens hits 2 files at `2c5c12a08` and 0 at head, and the sweep reads every mirror root. | `git grep` of the tokens at both commits | Discrimination was judged by this replay and by reading the rows, not by a separate test run. |
| 12 | Worktree filter fixed | PASS | The test uses `path.relative_to(REPO_ROOT).parts`, and the pytest gate ran in the item worktree with 0 failures. | Test body read at head | |
| 13 | Parallel gates zero failures | PASS | Pester: ExitCode 0, JUnit 14518 tests, 0 failures. Pytest: 16103 passed, 0 failures. Both ran after the last change outside the feature folder. | JUnit read of `artifacts/pester/pester-junit.xml`; `evidence/qa-gates/pytest-parallel.2026-11-07T04-50.md` | |
| 14 | Evidence from the parallel gates | PASS | A search of `evidence/baseline`, `evidence/remediation-baseline`, `evidence/qa-gates`, and `evidence/other` for the removed-run words returns no file. | `grep` over `evidence/` | |
| 15 | CI Required Gate on final PR head | UNVERIFIED | Pending CI. No PR exists yet, so CI has not run on this head. | `gh pr list --head feature/parallel-only-test-gates-and-leak-scan-1094 --state all` returned no PR | Owned by the item's orchestrator at S9. This is a pending-CI criterion, not a finding. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 14 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. RF-6: every locally verifiable criterion passes, but the coverage stop hooks reject the `N/A - no pre-change run` record that the branch prescribes. The `user-story.md` scenario `Planning an item with no test-suite baseline` ends with the audit being accepted; the hook does not accept it.

**Recommended follow-up verification steps:**

1. Apply the hook change in both hooks and their bundle copies, and add a test that runs the rule on the lines the template prescribes.
2. Run the real hook from the item worktree on an audit filled from the template, and confirm exit 0.
3. Re-run the Pester gate once, and any other gate the edit affects.

---

## Acceptance Criteria Check-off

Criterion 1 evaluates as PASS and was checked off in `spec.md` and `user-story.md`, changing only the checkbox. Criteria 2 to 14 were already checked, and this audit confirms them as PASS. Criterion 15 is pending CI and stays unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/spec.md`, `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/user-story.md`
- Total AC items: 15 per file
- Checked off (delivered): 14 per file
- Remaining (unchecked): 1 per file
- Items remaining: criterion 15 (`CI Required Gate` on the final PR head)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 15 | 14 | 1 | Checkbox-backed |
| `user-story.md` | 15 | 14 | 1 | Checkbox-backed |
