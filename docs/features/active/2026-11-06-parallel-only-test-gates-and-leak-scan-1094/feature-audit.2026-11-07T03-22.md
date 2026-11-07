# Feature Audit: parallel-only-test-gates-and-leak-scan (#1094)

---

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094`
**Base Branch:** `origin/main`
**Head Branch:** `feature/parallel-only-test-gates-and-leak-scan-1094`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `9a19be8e72ea479212e2e43c3ad766afb270fae6`)
- **Head branch/commit:** `feature/parallel-only-test-gates-and-leak-scan-1094` (commit `f59b9caab5344611ee11008dc2af5bd3fb924fb5`)
- **Merge base:** `9a19be8e72ea479212e2e43c3ad766afb270fae6`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated at head `f59b9caab`, current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/`
  - Additional evidence: `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, and reviewer probes at head
- **Feature folder used:** `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` states `- Work Mode: full-feature`.
- **Scope note:** The gates ran before merge commit `f59b9caab` brought `origin/main` into the branch. The audit scope is the full diff against the merge base. The owner directive applies: no single-process, shuffled, reversed-order, comparison, or pre-change run is required, and the absence of one is not a finding.

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
| 1 | No text requires a removed or comparison run | PARTIAL | The brief, plan contract, QA gates, and review workflow comply, and the brief carries the governing sentence. Four Copilot agents and bundle copies keep a comparison (RF-1). Typed-engineer agents keep required per-batch targeted runs (RF-2). | `grep` over the skill, agent, prompt, and template roots at head | Policy-file residuals and deferred tools are excluded per Decision 1. |
| 2 | No policy file changes | PASS | Path-limited diff is empty. | `git diff --name-only origin/main...HEAD -- .claude/rules .github/instructions .agents/skills/powershell .agents/skills/python` | Bundle copies also unchanged. |
| 3 | No CI, PoshQC, tasks, tool, or validator change | PASS | Path-limited diff is empty. | `git diff --name-only origin/main...HEAD -- .github/workflows scripts/powershell/PoshQC .vscode/tasks.json scripts/dev_tools extensions/drm-copilot/src` | |
| 4 | Test Isolation Checks and mirror match | PASS | Section read at head; six copies share one normalized hash. | Normalized hash of six `execution-environment/SKILL.md` copies | |
| 5 | Brief passages in every copy | PASS | Passages read; `test_brief_passages_state_parallel_gate_facts` covers all copies. | Section reads at head | |
| 6 | Pre-Mortem bullet in every copy | PASS | Bullet read; `test_contract_premortem_test_isolation_states_parallel_gates` covers six copies. | `grep -n 'Test isolation'` on the contract | |
| 7 | No plan-contract or review comparison; focused run is debugging only | PASS | Plan-contract and review text carries no comparison run; the brief states the rule. | `grep` on `atomic-plan-contract` and `feature-review-workflow` | |
| 8 | Static baselines stay; coverage from the single gate run | PARTIAL | Static baselines stay. The three non-regression sentences in RF-1 do not read coverage from the single gate run against the thresholds. Per-batch coverage confirmation in RF-2 conflicts as well. | `grep` for `not regress` at head | |
| 9 | Template and validators accept the record | PARTIAL | Template complies; Python validator pinned by two tests. No test covers the TypeScript twin, which the spec names (RF-3). | `grep -c 'no pre-change' extensions/drm-copilot/test/lib/validate/policy-audit-artifact.test.ts` returned 0 | The MCP validation of this review's policy audit is one execution, not a contract test. |
| 10 | A3 surfaces; permissions unchanged | PASS | No listed surface names a serial command as a gate. No permission line changed in the agent diffs. | Scripted diff scan for permission lines | `poetry run pytest *` and `run_poshqc_test` grants stay as permissions. |
| 11 | Contract tests pass and discriminate | PASS | Gates green. 46 of 46 `PGW-` rows fail against `origin/main` text, by replay. The brief and contract negative tests read every copy. | Scratch replay of rows against base blobs | A wording gap in the sweep is reported under RF-1 and RF-2. |
| 12 | Worktree filter fixed | PASS | The diff uses `path.relative_to(REPO_ROOT).parts`; the evidence records the test as passed in the item worktree. | `git diff origin/main...HEAD -- tests/scripts/dev_tools/test_discovery_documentation_contracts.py` | |
| 13 | Parallel gates zero failures | PASS | Pester: ExitCode 0, JUnit 14452 tests, 0 failures. Pytest: 16103 passed, 0 failures. | JUnit read of `artifacts/pester/pester-junit.xml`; `evidence/qa-gates/pytest-parallel.2026-11-07T03-11.md` | The runs predate the final merge of `origin/main`. |
| 14 | Evidence from the parallel gates | PASS | Evidence cites only the gates and static tools; a scan found the removed-run words only in quoted issue text and in template row names. | `grep` over `evidence/` | Waivers record that no suite baseline ran. |
| 15 | CI Required Gate on final PR head | UNVERIFIED | No PR exists yet; CI has not run on this head. | `gh pr list --head feature/parallel-only-test-gates-and-leak-scan-1094` | Pending CI; owned by the item's orchestrator at S9. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 11 criteria
- **PARTIAL:** 3 criteria
- **UNVERIFIED:** 1 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. RF-1 and RF-2: agent text still carries a coverage comparison and required per-batch focused runs (criteria 1 and 8).
2. RF-3: no contract test covers the TypeScript validator (criterion 9).
3. RF-4: the Python coverage artifact is below the repo-wide thresholds. This is a policy finding and maps to no acceptance criterion.

**Recommended follow-up verification steps:**

1. Re-run the sweep with added tokens, and confirm that RF-1 and RF-2 wording is absent from every mirror.
2. Run one gate per suite after the fixes, with the discovery package resolved inside the worktree, and record Python totals at or above 85% and 75%.

---

## Acceptance Criteria Check-off

Criteria 2 to 7 and 10 to 14 were already checked by the executor, and this audit confirms them as PASS. No new item was checked off.

Criteria 1, 8, and 9 were checked by the executor and evaluate as PARTIAL, so this review reverted them to `- [ ]` in `spec.md` and `user-story.md`, changing only the checkbox. Criterion 15 stays unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/spec.md`, `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/user-story.md`
- Total AC items: 15 per file
- Checked off (delivered): 11 per file
- Remaining (unchecked): 4 per file
- Items remaining: criterion 1 (no text requires a removed or comparison run), criterion 8 (static baselines stay and coverage is read from the single gate run), criterion 9 (template and validators accept the record), criterion 15 (`CI Required Gate` on the final PR head)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 15 | 11 | 4 | Checkbox-backed |
| `user-story.md` | 15 | 11 | 4 | Checkbox-backed |
