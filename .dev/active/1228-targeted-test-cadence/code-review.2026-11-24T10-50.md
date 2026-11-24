# Code Review: targeted-test-cadence (#1228), re-audit after remediation cycle 1

---

**Review Date:** 2026-11-24
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1228-targeted-test-cadence`
**Feature Folder Selection Rule:** the only active folder in the branch diff; its prefix matches issue 1228 in the branch name.
**Base Branch:** `main` (resolved `origin/main` at merge base `a4ebf96688106d9bcd0baf51d237a6b77c055560`)
**Head Branch:** `feature/targeted-test-cadence-1228` at `4ac1f0be8688ddbd9c18a4de072d3f0095dc9cfd`
**Review Type:** Re-audit (remediation cycle 1, inputs `remediation-inputs.2026-11-24T07-15.md`)

---

## Executive Summary

The branch changes the orchestration test cadence on every harness surface so that the full test suite runs only at the `Phase 0 baseline` and in the final QA loop, and every other run uses a test selection. The previous review found two blocking contradictions between the new cadence and dependent contracts. Remediation commit `4ac1f0be8` (45 files) addresses both:

- F1: the QA-gate skills (Python, PowerShell, C#; Claude, Codex, and csharp-legacy variants; bundles) scope `Overall coverage delta` to the final QA loop, add a `Remediation gate coverage` bullet, and state that the remediation gate's selection run is its gate run while any other partial run stays debugging only.
- F2: the feature-review agent source (both halves) and its generated outputs, step 5 of `feature-review-workflow`, and policy-audit template 4A.1 read repo-wide totals from the final-QC artifact and `## CI Cross-check`, treat a selection-run coverage file as per-file evidence only, and replace "does NOT rerun coverage generation" with the D3 selection re-run.

The new contract rows are specific and discriminate: run against the pre-remediation tree, all 24 file-reading rows over the remediated files fail and report each of the five removed sentences, and the other 169 rows pass. Generators, bundle parity, the ledger chain, and the push-down contracts are clean.

One new blocking finding (F3) surfaced while completing this review: the unchanged feature-review coverage Stop hook grades the local coverage report as the repo-wide figure. After the reviewer's selection re-run, which the remediated step 5 prescribes, the hook refused completion at 2.05%. The reviewer then had to run the full Pester suite at head to complete, the run that the branch's D3 text forbids.

**What changed in this cycle:**
QA-gate `## Delta Requirements` and `## Prohibited Shortcuts` (eight copies plus six bundles); feature-review agent `## Coverage Verification` (source, two generated targets, two bundles); `feature-review-workflow` step 5 Python bullet (two copies, two bundles); policy-audit template 4A.1 (template and bundle); `test-cadence-wording.Tests.ps1` (+59 lines: two QA-gate checks, the review check, two new row groups, one discrimination row); ledger `0014` and its stored patch; cycle evidence and the previous review artifacts.

**Top risks:**
1. F3: every review that follows a remediation gate or a D3 re-run is blocked by the coverage Stop hook unless it records a false repo-wide FAIL or runs the full suite.
2. Cross-module regressions surface only at the final QA loop or CI; accepted by design (spec Risks).
3. A remediation gate's per-file coverage relies on the selection reaching every test that exercises a changed production file; the selection rule (mirrored tests plus tests that import, dot-source, or name a changed module) is unchanged and is the documented mitigation, with CI as the backstop.
4. The Copilot standalone typed-engineer agents keep "overall coverage delta if applicable"; they are out of scope under D10 and bracket their own full runs, so no orchestration contradiction arises.

**PR readiness recommendation:** **Needs Revision** — F1 and F2 are resolved; F3 (coverage Stop hook versus the selection cadence) must be resolved before merge.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/validate-feature-review-coverage-metrics.ps1` (with `validate-feature-review-coverage.ps1`, `validate-feature-review-coverage-freshness.ps1`, and bundles) | `Get-LanguageRepoCoverage` / `Get-JacocoRepoCoverage`; the `Test-LanguageCoverageRow` call at line 229 of `validate-feature-review-coverage.ps1` | F3. The unchanged coverage Stop hook reads the root LINE counter of the local coverage report as the repo-wide figure and refuses completion unless the policy audit records a FAIL when it is below the floor; the freshness hook requires the report to postdate the newest commit. Under the branch's cadence the report after a remediation gate or a D3 re-run is selection-only, so a review that follows the remediated text can complete only with a false repo-wide FAIL or a full-suite run that the branch forbids. Spec D3 assumed no hook change was needed. | Make the hook grade only a full-suite report as repo-wide (for example a run-scope marker from the launcher, or the final-QC evidence named in the audit), keep per-file and freshness checks for selection reports, amend D3 with a recorded decision, extend ledger `0014`, and add hook Pester rows. | The review enforcement contradicts the review procedure this branch defines; every review after a remediation cycle would hit it. | This review: after the 721-test selection re-run (2.05%), the Stop hook refused completion ("PowerShell repo-wide coverage is 2.05% ... no FAIL verdict"); true repo-wide is 96.85% (final QA) and 96.85% (reviewer full run at head: 29355 tests, 0 failed, 47435 covered and 1541 missed lines). |
| Info | `.claude/skills/python-qa-gate/SKILL.md` (and the other QA-gate copies) | `## Delta Requirements`, closing sentence | "rerun the full toolchain" after a failed delta check is unchanged. In context it means every toolchain step of the gate in use (the remediation gate's run form is defined two sections earlier), not the full suite. | No action. | The term "full toolchain" names the stage set throughout the repository; the test step's scope is defined by `## Toolchain Execution Sequence` of the same skill. | `grep -n "full toolchain"` on the skill; `## Toolchain Execution Sequence` remediation-gate sentence. |
| Info | `.agents/skills/{python,powershell,csharp}-qa-gate/references/standard.md` | OB-2, OB-3 | The Codex gold standards (unchanged) describe one parallel `pytest -n auto` run with coverage and comparison against the `Phase 0 baseline`. A remediation-gate selection is still one parallel run of the same command with selected files appended, so the skill does not contradict OB-2 (AC-6 of the standard). | No action. | Checked because the cycle changed the skills these standards describe. | File inspection; `git log` shows no change on the branch. |
| Info | `.github/agents/python-typed-engineer.agent.md`, `powershell-typed-engineer.agent.md`, `csharp-typed-engineer.agent.md`, `pytest-unit-test-coding.agent.md`, `python-execution-only-typed.agent.md`, `Powershell DI Unit Test Engineer.agent.md` | QA reporting bullets | These standalone Copilot agents keep "overall coverage delta if applicable". | No action; out of scope under spec D10. | They bracket their own standalone runs and are not orchestrator steps. | Sibling-sentence grep across `.github/agents`. |
| Info | `artifacts/pester/powershell-coverage.xml` | n/a | The remediation gate's selection report (written 10:10Z) predated the remediation commit (10:26Z). The reviewer re-ran the cycle's 14-file selection (per D3), which the metrics hook then graded as repo-wide (F3); the reviewer finally ran the full Pester suite at head, whose report is left in place. | No action beyond F3. | Disclosure of reviewer side effects. | Policy audit section 1.2.1. |

No Warning rows: both changed covered files are below 700 logical lines (688 and 350).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The QA-gate checks pair required tokens for the new clauses with a forbidden token that matches only the old unscoped bullet (`Overall coverage delta** (when the repo enforces it)`), so a partial edit or a revert fails.
- `$script:ReviewAgentCheck` forbids both old sentences of the agent ("does NOT rerun coverage generation" and "rather than rerunning coverage generation") and requires "never runs the full suite", which pins the D3 rule on both halves and their bundles.
- `TCW-COVERAGE-SOURCE-DISCRIMINATES` derives its expected token set from the checks themselves and asserts the distinct count (5), so a forbidden token dropped from a check fails the row.
- The `REVIEW-TEMPLATE` rows list the template and its bundle explicitly with `Bundle = $false`, because the template bundle lives under `resources/templates/`, not under a customization root.

#### API and safety notes

- No function was added; the new code is discovery data and one `It` block using existing helpers (`Get-TcwCheck`, `Get-TcwRow`, `Get-TcwCheckProblem`).
- Formatter and analyzer report 0 findings in the remediation gate.

#### Test quality notes

- The discrimination probe (scratch clone at `731163ca9` with the head test file) failed exactly the 24 file-reading rows over remediated files: 14 `TCW-QAGATE-*`, 4 `TCW-REVIEW-*`, 4 `TCW-REVIEW-AGENT-*`, 2 `TCW-REVIEW-TEMPLATE-*`. The other 169 rows passed.

### Markdown and TOML policy surfaces

- The QA-gate wording keeps every token pinned by `parallel-gate-wording.Tests.ps1` (`single gate run`, `debugging only`, `Phase 0 baseline`, launcher text) and the D13 tokens; `PGW-QA-*` rows pass.
- The agent source keeps `governing repo-wide threshold` in the Claude half, pinned by `test_push_down_tier_rule_adoption_gate.py`, which passed.
- The template sentence keeps `Enforce Python coverage thresholds` and `## CI Cross-check`, pinned by `less-evidence-contract.Tests.ps1`, which passed.
- Generated `.claude/agents/feature-review.md` and `.codex/agents/feature-review.toml` match the generator (`-Check` exit 0).

### Ledger

- `## Files Changed` lists every branch path outside the ledger folder, the feature folder, and the promotion record (reviewer check: 0 absent); the template is recorded under its earlier `docs/features/templates/` key, consistent with entries `0001`, `0006`, and `0009`.
- The commit subject carries `reduction: 0014`; the five ledger suites passed.

---

## Test Coverage Review

- No production file changed in any coverage language; the PowerShell repo-wide figure is 96.85% lines from the final QA full run against a 96.84% `Phase 0 baseline`.
- The remediation gate ran its union selection in coverage mode; it recorded the selection-only root figure as per-file evidence and did not grade it as repo-wide, which is the behavior the remediated contracts now require.

---

## Compliance Summary

| Area | Status | Notes |
|---|---|---|
| General code change policy | PARTIAL | F3: the review enforcement hook was not aligned with the cadence |
| General unit test policy | PASS | Rows discriminate; AAA comments present |
| PowerShell policy | PASS | Formatter and analyzer clean; launcher only |
| Harness generation | PASS | No drift in both modes; Codex variants clean |
| Bundle parity | PASS | Byte-identical copies; `AGENTS.md` identical |
| Process-reduction ledger | PASS | Entry extended; chain tests pass |
| CI | Pending | No PR yet; S9 gate |

---

## Recommendation

**Needs revision.** F1 and F2 are resolved and pinned by discriminating contract rows. Resolve F3 in one full remediation cycle (hook change, spec D3 amendment, ledger extension, hook tests), then re-review.
