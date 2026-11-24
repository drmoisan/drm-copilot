# Code Review: targeted-test-cadence (#1228)

---

**Review Date:** 2026-11-24
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1228-targeted-test-cadence`
**Feature Folder Selection Rule:** the only active folder in the branch diff; its suffix matches issue 1228 in the branch name.
**Base Branch:** `main` (resolved `origin/main` at merge base `a4ebf96688106d9bcd0baf51d237a6b77c055560`)
**Head Branch:** `feature/targeted-test-cadence-1228` at `731163ca96861582594fb861f370e5153cd76369`
**Review Type:** Initial review

---

## Executive Summary

The branch changes the orchestration test cadence on every harness surface: the full test suite runs only at the `Phase 0 baseline` and in the final QA loop, a `[phase-gate]` unit stage runs the union of the phase's task test selections with no coverage, a remediation cycle ends with one remediation gate in coverage mode over the cycle's selection, sync checks run the selection of the paths a merge changed, and the review coverage re-run uses the branch's selection. The change touches 227 paths: Markdown and TOML policy surfaces (sources, generated outputs, Codex variants, bundles), two Pester contract test files, ledger entry `0014` with a 3225-line stored patch, and the feature records. No production code in any coverage language changed.

The canonical `## Test Cadence (Mandatory)` rewrite is precise and keeps every pinned token; the R1 reference sentence is applied consistently; generators and bundle parity are clean; the contract tests are well structured and passed in a reviewer launcher run (430 of 430). The review found two contracts that the new cadence depends on but that were left unchanged, and both contradict the new rules in a way that an agent following the text literally will hit on the first remediation cycle or review.

**What changed:**
Canonical section in both `atomic-plan-contract` copies; R1 sentence across rules, agents, skills, Copilot agents, prompts, plan templates, and `AGENTS.md`; QA-gate skills now apply to "the final QA loop or a remediation gate"; remediation handoff `## Plan Shape`; orchestrate regenerate path; feature-review step 5; typed-engineer D4 sentence; execution-environment and test-execution-policy selection statements; new `TCW-*` rows and cadence sweep; `RSC-REGENERATE` literals; ledger `0014`.

**Top 3 risks:**
1. A remediation gate cannot pass the QA-gate skills as written (F1), so executors either fail the gate or run the full suite, which defeats the objective.
2. A review that follows the new D3 re-run, or that reads the coverage report after a remediation gate, produces a selection-only coverage report, and the unchanged agent procedure and Python sentence grade it as a repo-wide FAIL (F2); this can open spurious remediation cycles.
3. Cross-module regressions now surface only at the final QA loop or CI; accepted by design (spec Risks).

**PR readiness recommendation:** **Needs Revision** — two blocking contract contradictions introduced by the new cadence must be resolved before merge.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/skills/python-qa-gate/SKILL.md` (also `powershell-qa-gate`, `csharp-qa-gate`, their `.agents` copies, bundles, and csharp-legacy variants) | `## Delta Requirements` (`Overall coverage delta`); `## Prohibited Shortcuts` ("Do not report success based on partial or targeted runs", "the final gate is the single gate run"; "Do not ... narrow any step") | F1. The branch makes these skills apply to a remediation gate and adds that its test step runs the cycle's test selection in coverage mode, but the unchanged overall-coverage delta compares a selection run with the full-run baseline, and the unchanged prohibition forbids reporting success from a targeted run. The remediation gate is unsatisfiable as written. | Scope the overall-coverage delta and the partial-run prohibition to the final QA loop; state that in a remediation gate the selection run is the gate run, the per-file delta applies to the changed files, and the repository-wide figure comes from the orchestration's final-QC artifact and CI. Add `TCW-QAGATE` required and forbidden tokens for the reworded clauses and extend ledger `0014`. | A gate whose own skill forbids its prescribed run form leads executors to fail the cycle or to restore a full run, which the owner objective removes. | `grep -n` of the three skills at head: lines 28 (selection in remediation gate), 44/45/60 (`Overall coverage delta`), 76/77/92 (`partial or targeted runs`). |
| Blocker | `scripts/harness-generation/sources/agents/feature-review.md` (both halves; generated `.claude/agents/feature-review.md`, `.codex/agents/feature-review.toml`, bundles); `.claude/skills/feature-review-workflow/SKILL.md` and `.agents` copy and bundles; `.dev/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` and bundle | agent `### Verification Procedure` step 3 bullets 1, 2, 3 and the closing "does NOT rerun coverage generation"; skill step 5 Python bullet; template 4A.1 | F2. The new D3 text re-runs coverage over a selection and says repo-wide totals come from the final-QC artifact and `## CI Cross-check`, but the unchanged agent procedure parses the repo-wide figure from the local artifact and grades it FAIL below 85%, forbids a re-run, and the skill, agent, and template keep "a local artifact that shows the Python total below a threshold is still FAIL". Every pytest run writes `artifacts/python/lcov.info` (pyproject `addopts`), and a `-TestPath` Pester run rewrites `powershell-coverage.xml`, so after a remediation gate or a D3 re-run the local artifact is selection-only. | Reword the agent procedure, the skill Python bullet, and the template 4A.1 sentence so the repo-wide figure is read from the final-QC artifact and `## CI Cross-check`, a selection-only local artifact is evidence for per-file figures only, and the D3 selection re-run replaces "does NOT rerun coverage generation"; regenerate, re-copy bundles, add `TCW-REVIEW` rows for the agent surfaces and template, add the old sentences to a forbidden list, and extend ledger `0014`. | The contradiction makes reviews raise false repo-wide FAIL findings and re-open remediation, or forces a full run that the new cadence removes; the freshness hook already forces a re-run at most reviews. | Reviewer selection run (`run-test-suite.sh pester -TestPath`, 7 suites, 430 tests) produced a merged report with root LINE 917 covered, 48059 missed (1.87%). `grep` for "is still FAIL" and "does NOT rerun coverage" lists the six files named. `pyproject.toml` line 130 `addopts` writes `--cov-report=lcov:artifacts/python/lcov.info`. |
| Info | `.dev/engineering/process-reductions/0014-targeted-test-cadence.md` | branch log | Commit `242d160fd` (wip pause, 141 files) carries part of the reduction without the `reduction: 0014` token; the token and entry land in `731163ca9`. | No action; matches the owner-requested pause-checkpoint practice; the stored patch is derived from the merge base and covers both commits. | Recorded for the ledger-commit rule of `feature-review-workflow`. | `git log --oneline a4ebf9668..HEAD`; entry `## Stored Patch` paragraph. |
| Info | `.dev/engineering/process-reductions/patches/0014-targeted-test-cadence.patch` | template hunks | The three plan-template hunks use the earlier key `docs/features/templates/`, so a live-tree `git apply -R --check` rejects those paths; the chain maps them to `.dev/templates/` and the entry documents the manual mapping. | No action. | Consistent with entries `0005`, `0009`, `0011`. | `git apply -R --check` output; `ProcessReductionChain.Ledger.Tests.ps1` passed. |
| Info | `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/pester-junit.xml` | n/a | The reviewer selection run overwrote both reports; they were snapshotted first and restored byte-identically (gitignored, not in the diff). | No action. | Disclosure of reviewer side effects. | SHA-256 prefix `2adad1d3e05f83de` before and after. |

No Warning rows: both changed covered files are below 700 logical lines (629 and 350).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- `$script:CadenceSweepToken` and `$script:CanonicalSelectionToken` are discovery data passed into rows through `-ForEach`, matching the existing `PerTaskSweepToken` pattern.
- The sweep excludes the D5 and D10 files by ordinal path suffix, so their bundle copies are excluded without listing each, and the exclusion count is asserted (11).
- The QA-gate row both requires the new phrase and forbids the old one, which discriminates a partial edit.
- `RSC-REGENERATE` literals were updated in commit `242d160fd`, the same commit as the orchestrate item-5 text and its bundle.

#### API and safety notes

- No function was added; analyzer and formatter report 0 findings for both files.

#### Error handling and logging

- File reads in the sweep fail the row on error; no silent catch.

---

## Test Quality Audit

The contract tests are read-only checks of committed Markdown and TOML. The reviewer re-ran the pinned suites through the launcher; the executor's final QA Pester, pytest, and Jest runs were full runs with coverage compared with the `Phase 0 baseline`.

### Reviewed test and QA artifacts

- `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` — new selection, handoff, engineer, review, scoped, and sweep rows; all pass. It does not pin the QA-gate delta and prohibition clauses or the feature-review agent surfaces (F1, F2).
- `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1` — two updated literals; pass.
- `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/pester.2026-11-24T06-30.md` — full run, 0 failures, 96.85% lines versus 96.84% baseline.
- `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/pytest.2026-11-24T06-43.md` — full run, 17104 passed, coverage unchanged.
- `.dev/active/1228-targeted-test-cadence/evidence/other/cadence-search.2026-11-24T04-48.md` — AC-04 search with scope, patterns, and classified hits.
- `.dev/active/1228-targeted-test-cadence/evidence/other/scope-diff.2026-11-24T06-59.md` — AC-18 and AC-19 diff evidence.

### Quality assessment prompts

- **Determinism:** inputs are committed files and literals.
- **Isolation:** one heading or one sweep per row.
- **Speed:** 430 tests in 16.46 s of test time.
- **Diagnostics:** failures list file and token pairs.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; Markdown, TOML, and test literals only. |
| No unsafe subprocess or command construction | N/A | No executable code added. |
| Input validation at boundaries | N/A | No boundary code. |
| Error handling remains explicit | ✅ PASS | Test reads fail loudly. |
| Configuration / path handling is safe | ✅ PASS | No configuration file changed; no absolute host path in committed artifacts. |
| Policy consistency across dependent contracts | ❌ FAIL | F1 and F2. |

---

## Research Log

No external research was required. All evidence comes from the repository, the item evidence, and reviewer runs in the item worktree.

---

## Verdict

The cadence rewrite is accurate at its canonical location and is propagated consistently with clean generator, parity, and contract-test results. The change is not ready to merge: the QA-gate skills and the feature-review coverage contract still require full-suite figures from runs that the new cadence makes selection-only (F1, F2). One full remediation cycle that rewords those clauses on every copy, pins them with contract rows, and extends ledger entry `0014` should close both findings.
