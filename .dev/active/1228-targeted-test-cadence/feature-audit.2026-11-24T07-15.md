# Feature Audit: targeted-test-cadence (#1228)

---

**Audit Date:** 2026-11-24
**Feature Folder:** `.dev/active/1228-targeted-test-cadence`
**Base Branch:** `main`
**Head Branch:** `feature/targeted-test-cadence-1228`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main`, resolved as `origin/main` (commit `a4ebf96688106d9bcd0baf51d237a6b77c055560`, fetched at review time)
- **Head branch/commit:** `feature/targeted-test-cadence-1228` (commit `731163ca96861582594fb861f370e5153cd76369`, equal to the remote branch head)
- **Merge base:** `a4ebf96688106d9bcd0baf51d237a6b77c055560`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-24 07:04:54 UTC for head `731163ca9`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff a4ebf9668 731163ca9`
  - Feature evidence: `.dev/active/1228-targeted-test-cadence/evidence/{baseline,other,qa-gates}/`
  - Additional evidence: reviewer runs in the item worktree (generator `-Check` modes, Codex `--check`, bundle byte comparison, launcher Pester selection of seven contract suites with 430 tests and 0 failures)
- **Feature folder used:** `.dev/active/1228-targeted-test-cadence`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` line 10 carries `- Work Mode: full-feature`.
- **Scope note:** full branch diff against the merge base (227 paths). The worktree was clean at review start. The executor had already checked every criterion; this audit re-evaluates each and unchecks the PARTIAL ones.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `.dev/active/1228-targeted-test-cadence/spec.md` — primary source (AC-01 to AC-19)
- `.dev/active/1228-targeted-test-cadence/user-story.md` — secondary source (US-1 to US-9, numbered here by order)

### From spec.md

1. AC-01: canonical section states the full suite runs only at the `Phase 0 baseline` and final QA loop and defines the phase-gate unit stage as the union of task selections, parallel, no coverage; new required-token rows pass.
2. AC-02: the section defines the remediation gate and the sync-check local gate; existing canonical tokens and `TCW-CANONICAL-DISCRIMINATES` tokens remain.
3. AC-03: second sweep token list with count assertion, swept over all surfaces excluding D5/D10 paths, plus a helper row; passes.
4. AC-04: repository-wide search evidence with `SearchScope`, `SearchPatterns`, `SearchResult`, classifying every hit.
5. AC-05: remediation handoff `## Plan Shape` requires static baselines citing the `Phase 0 baseline` artifact and one remediation gate in coverage mode.
6. AC-06: orchestrate item 5 regenerate path uses the selection of the paths the merge changed; both `RSC-REGENERATE` literals updated in the same commit and pass.
7. AC-07: D4 sentence in the three typed-engineer sources (both halves) and every generated copy.
8. AC-08: feature-review-workflow step 5 states the D3 selection re-run and names the final-QC artifact and `## CI Cross-check` as the source of repository-wide totals.
9. AC-09: QA-gate `## When to Use This Skill` applies the gate to the final QA loop and the remediation gate, not a phase gate.
10. AC-10: execution-environment brief and test-execution-policy name the phase gate, remediation gate, and sync check as selection runs.
11. AC-11: harness generation `-Check` modes report no drift; `HarnessGeneration.RepoGate.Tests.ps1` passes; output recorded.
12. AC-12: Codex variant generator `--check` exits 0; output recorded.
13. AC-13: bundle parity; push-down contract tests and `TCW-BUNDLE-*` pass; `AGENTS.md` byte-identical with digests recorded.
14. AC-14: existing vocabulary sweeps pass with the `PGW-SWEEP-*` list unchanged.
15. AC-15: `EXECUTOR`, `PLANNER`, `POLICY`, `TCW-TEMPLATE-*` rows pass with gate counts unchanged.
16. AC-16: ledger entry `0014` with required sections, stored patch, revert-step labels, README row; chain and index tests pass.
17. AC-17: final QA loop and `Phase 0 baseline` remain full runs with coverage; item's own artifacts show it.
18. AC-18: recorded branch diff lists no `.github/workflows/` path.
19. AC-19: out-of-scope and protected paths unchanged; no new `.py`; frozen digest test passes.

### From user-story.md

1. US-1: canonical section in both copies (spec AC-01, AC-02).
2. US-2: no rule, skill, agent, prompt, instruction, plan template, or bundle copy requires a full-suite run outside the `Phase 0 baseline` and the final QA loop (spec AC-03, AC-04).
3. US-3: remediation plan shape, regenerate path, typed engineers, feature-review coverage step, QA-gate skills, brief, and test-execution-policy state the selection-based runs (spec AC-05 to AC-10).
4. US-4: generated outputs regenerated (spec AC-11, AC-12).
5. US-5: bundle parity and `AGENTS.md` identity (spec AC-13).
6. US-6: pinned tests updated with the wording and pass with the unchanged sweeps (spec AC-06, AC-14, AC-15).
7. US-7: ledger entry `0014` (spec AC-16).
8. US-8: `Phase 0 baseline` and final QA loop remain full runs (spec AC-17).
9. US-9: CI unchanged and out-of-scope paths untouched (spec AC-18, AC-19).

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC-01 | Canonical full-suite and phase-gate statements | PASS | Both `atomic-plan-contract` copies carry the new first bullet and the rewritten phase-gate bullet; `TCW-CANONICAL-*` 9 rows pass | `run-test-suite.sh pester -TestPath` (7 suites) | Reviewer run, 0 failures |
| AC-02 | Remediation gate, local gate, kept tokens | PASS | `Remediation gate` and `Sync check` bullets present; kept tokens unchanged per diff | same | |
| AC-03 | Cadence sweep and helper | PASS | 10-token list, count assertion 10 in the helper row, exclusion count 11; both rows pass | same | |
| AC-04 | Repository-wide search evidence | PASS | `evidence/other/cadence-search.2026-11-24T04-48.md` records scope, patterns, result, classifications | file inspection | The patterns did not cover the clauses of F1 and F2; see US-2 |
| AC-05 | Remediation handoff plan shape | PASS | `## Plan Shape` lines 101 to 102; `TCW-HANDOFF-*` pass | pester selection | |
| AC-06 | Regenerate path and `RSC-REGENERATE` same commit | PASS | `git show --stat 242d160fd` lists orchestrate, its bundle, and the RSC test together; `RSC-REGENERATE` 2 rows pass | `git show --stat 242d160fd` | |
| AC-07 | Typed-engineer D4 sentence | PASS | Source diff in both halves; `TCW-ENGINEER-*` 42 rows pass; generators clean | pester selection; generator `-Check` | |
| AC-08 | Feature-review step 5 D3 statement | PARTIAL | Step 5 states the selection re-run and names the final-QC artifact and `## CI Cross-check`, but the same step keeps "a local artifact that shows the Python total below a threshold is still FAIL", and the `feature-review` agent procedure keeps the local-artifact repo-wide rule and "does NOT rerun coverage generation" | `grep -n "is still FAIL"`; reviewer selection run (root LINE 1.87%) | Finding F2 |
| AC-09 | QA-gate When to Use | PASS | All copies read "the final QA loop or a remediation gate"; `TCW-QAGATE-*` 14 rows pass | pester selection | Other clauses of the same skills are F1 |
| AC-10 | Brief and test-execution-policy selection statements | PASS | Diff of `## Test Isolation Checks` and `### Scoped Pester runs`; `TCW-BRIEF-*`, `TCW-SCOPED-*` pass | pester selection | |
| AC-11 | Harness generation no drift | PASS | Reviewer `-Check` and `-Surface instructions -Check` exit 0; `HarnessGeneration.RepoGate` passes; `evidence/qa-gates/generators.2026-11-24T04-05.md` | `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check` | |
| AC-12 | Codex variant generator | PASS | Reviewer `--check` exit 0; recorded in generators evidence | `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | |
| AC-13 | Bundle parity and `AGENTS.md` identity | PASS | Reviewer byte comparison of every changed surface path with its bundle: no difference; `cmp AGENTS.md` exit 0; `TCW-BUNDLE-*` pass; push-down pytest suites passed in the executor final QA run; SHA-256 digests in `scope-diff.2026-11-24T06-59.md` | `cmp`; pester selection | Reviewer pytest selection hit a queue timeout (exit 75) and did not run |
| AC-14 | Existing vocabulary sweeps | PASS | `PGW-SWEEP-*` 2 rows pass; `PGW-SWEEP-*` token list unchanged in the diff | pester selection | |
| AC-15 | Executor, planner, policy, template rows | PASS | `TCW-EXECUTOR` 24, `TCW-PLANNER` 24, `TCW-POLICY` 8, `TCW-TEMPLATE` 6 rows pass | pester selection | |
| AC-16 | Ledger entry `0014` | PASS | Entry sections and labels present; README row present; `ProcessReductionChain.Ledger` and `ProcessReductionLedger.Index` pass | pester selection | |
| AC-17 | Phase 0 and final QA remain full runs | PASS | `Final QA loop (unchanged)` bullet kept; baseline and final QA Pester, pytest, Jest artifacts are full runs with coverage comparison (96.84% to 96.85% PowerShell lines) | evidence inspection | |
| AC-18 | CI unchanged | PASS | `git diff --name-only a4ebf9668 HEAD` lists no `.github/workflows/` path; recorded in `scope-diff.2026-11-24T06-59.md` | `git diff --name-only` | |
| AC-19 | Out-of-scope paths untouched | PASS | No path under `scripts/dev_tools/atomic_executor/`, no frozen epic file, no D10 file, no docs-estate path, no `.py`; frozen digest test passed in the executor final QA pytest run | `git diff --name-only`; evidence | |
| US-1 | Canonical section | PASS | As AC-01 and AC-02 | pester selection | |
| US-2 | No surface requires a full run outside the two points | PARTIAL | The QA-gate skills forbid reporting success from a targeted run and require an overall coverage delta against the full baseline in a remediation gate (F1); the feature-review agent, skill, and policy-audit template grade a selection-only local artifact as a repo-wide FAIL (F2). Both force a full run to pass. | `grep -n` on the named files | F1, F2 |
| US-3 | Dependent surfaces state the selection runs | PARTIAL | Handoff, regenerate path, engineers, brief, and policy statements pass; the feature-review coverage step (AC-08) and the QA-gate skills' delta and prohibition clauses do not state the selection runs consistently | as AC-08; `grep -n` | F1, F2 |
| US-4 | Generated outputs regenerated | PASS | As AC-11 and AC-12 | generator checks | |
| US-5 | Bundle parity | PASS | As AC-13 | `cmp` | |
| US-6 | Pinned tests updated and pass | PASS | As AC-06, AC-14, AC-15 | pester selection | |
| US-7 | Ledger entry | PASS | As AC-16 | pester selection | |
| US-8 | Full runs retained | PASS | As AC-17 | evidence | |
| US-9 | CI unchanged, out-of-scope untouched | PASS | As AC-18 and AC-19 | `git diff --name-only` | |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 25 criteria
- **PARTIAL:** 3 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. F1: QA-gate skills keep the overall-coverage delta and the prohibition on targeted runs while applying to the selection-based remediation gate.
2. F2: the feature-review agent procedure, the feature-review skill Python bullet, and the policy-audit template grade a selection-only local coverage artifact as a repo-wide FAIL and forbid the D3 re-run.

**Recommended follow-up verification steps:**

1. After remediation, re-run the launcher Pester selection of `test-cadence-wording`, `parallel-gate-wording`, and `less-evidence-contract` and confirm new rows pin the corrected clauses on every copy.
2. Re-run both harness generation `-Check` modes and the Codex `--check`, and confirm the stored patch and `## Files Changed` of ledger entry `0014` cover the new paths (the ledger chain test passes).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, PASS criteria stay checked, and PARTIAL criteria are left unchecked.

### AC Status Summary

- Source: `.dev/active/1228-targeted-test-cadence/spec.md`, `.dev/active/1228-targeted-test-cadence/user-story.md`
- Total AC items: 28
- Checked off (delivered): 25
- Remaining (unchecked): 3
- Items remaining: spec AC-08 (feature-review step 5 D3 statement); user-story "No rule, skill, agent, prompt, instruction, plan template, or bundle copy requires a full-suite run outside the `Phase 0 baseline` and the final QA loop ..."; user-story "The remediation plan shape, the regenerate-path fallback gate, the typed-engineer workflow, the feature-review coverage step, the QA-gate skills, ... state the selection-based runs ...".

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `.dev/active/1228-targeted-test-cadence/spec.md` | 19 | 18 | 1 | Checkbox-backed; the executor had checked AC-08, and this review reverted it to unchecked |
| `.dev/active/1228-targeted-test-cadence/user-story.md` | 9 | 7 | 2 | Checkbox-backed; the executor had checked both, and this review reverted them to unchecked |

The reviewer changed only the three checkbox markers from `- [x]` to `- [ ]`; no criterion text changed. No new item was checked by this review because every PASS item was already checked.
