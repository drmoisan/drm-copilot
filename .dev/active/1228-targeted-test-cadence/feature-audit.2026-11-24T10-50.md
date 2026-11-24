# Feature Audit: targeted-test-cadence (#1228), re-audit after remediation cycle 1

---

**Audit Date:** 2026-11-24
**Feature Folder:** `.dev/active/1228-targeted-test-cadence`
**Base Branch:** `main`
**Head Branch:** `feature/targeted-test-cadence-1228`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after remediation cycle 1

---

## Scope and Baseline

- **Base branch:** `main`, resolved as `origin/main` (commit `a4ebf96688106d9bcd0baf51d237a6b77c055560`, fetched at review time)
- **Head branch/commit:** `feature/targeted-test-cadence-1228` (commit `4ac1f0be8688ddbd9c18a4de072d3f0095dc9cfd`, equal to the remote branch head)
- **Merge base:** `a4ebf96688106d9bcd0baf51d237a6b77c055560`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-24 10:26:24 UTC for head `4ac1f0be8`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff a4ebf9668 4ac1f0be8`
  - Feature evidence: `.dev/active/1228-targeted-test-cadence/evidence/{baseline,remediation-baseline,other,qa-gates}/`
  - Additional evidence: reviewer runs in the item worktree (generator `-Check` modes, Codex `--check`, bundle byte comparison, launcher Pester selection of 12 suites with 671 tests and 0 failures, launcher pytest selection of 7 files with 251 passed, discrimination probe against the pre-remediation tree)
- **Feature folder used:** `.dev/active/1228-targeted-test-cadence`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` line 10 carries `- Work Mode: full-feature`.
- **Scope note:** full branch diff against the merge base (251 paths). The worktree was clean at review start. The previous review (`feature-audit.2026-11-24T07-15.md`) graded 25 of 28 criteria PASS and 3 PARTIAL; the remediation cycle checked the three PARTIAL items. This audit re-evaluates all 28.

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
| AC-01 | Canonical full-suite and phase-gate statements | PASS | `TCW-CANONICAL-*` rows pass at head | launcher `pester -TestPath` (12 suites, 671 tests, 0 failed) | Unchanged in cycle 1 |
| AC-02 | Remediation gate, local gate, kept tokens | PASS | `TCW-CANONICAL-*` and `TCW-CANONICAL-DISCRIMINATES` pass | same | Unchanged in cycle 1 |
| AC-03 | Cadence sweep and helper | PASS | `TCW-CADENCE-SWEEP-SURFACES` and `-HELPER` pass | same | |
| AC-04 | Repository-wide search evidence | PASS | `evidence/other/cadence-search.2026-11-24T04-48.md`; reviewer sibling-sentence grep finds the five cycle-1 sentences only in the test file | file inspection; worktree grep | |
| AC-05 | Remediation handoff plan shape | PASS | `TCW-HANDOFF-*` pass | pester selection | |
| AC-06 | Regenerate path and `RSC-REGENERATE` same commit | PASS | `RSC-REGENERATE` rows pass; same-commit fact unchanged (`242d160fd`) | pester selection; `git show --stat 242d160fd` | |
| AC-07 | Typed-engineer D4 sentence | PASS | `TCW-ENGINEER-*` rows pass; generators clean | pester selection; generator `-Check` | |
| AC-08 | Feature-review step 5 D3 statement | PASS | Step 5 of both skill copies and bundles states the selection re-run and the final-QC/`## CI Cross-check` source, and the Python bullet now limits the below-threshold FAIL to a full-suite final-QC artifact; the agent source, generated targets, and template agree. `TCW-REVIEW-*`, `TCW-REVIEW-AGENT-*`, `TCW-REVIEW-TEMPLATE-*`, `LEC-*`, and `PGW-REVIEW-*` pass; the same rows fail on the pre-remediation tree | pester selection; discrimination probe in a scratch clone at `731163ca9` | F2 resolved |
| AC-09 | QA-gate When to Use | PASS | `TCW-QAGATE-*` 14 rows pass, now also covering the delta and shortcut clauses | pester selection | F1 resolved |
| AC-10 | Brief and test-execution-policy selection statements | PASS | `TCW-BRIEF-*`, `TCW-SCOPED-*`, `PGW-SCOPED-*` pass | pester selection | |
| AC-11 | Harness generation no drift | PASS | Reviewer `-Check` and `-Surface instructions -Check` exit 0; `HarnessGeneration.RepoGate` passes; `evidence/qa-gates/generators.2026-11-24T08-07.md` | `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check` | |
| AC-12 | Codex variant generator | PASS | Reviewer `--check` exit 0; recorded in the generators evidence | `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | |
| AC-13 | Bundle parity and `AGENTS.md` identity | PASS | Reviewer byte comparison of every changed surface path with its bundle: no difference; `cmp AGENTS.md` exit 0; both push-down resource contract suites passed in the reviewer pytest run | `cmp`; launcher `pytest` (251 passed) | |
| AC-14 | Existing vocabulary sweeps | PASS | `PGW-SWEEP-*` rows pass; token list unchanged | pester selection | |
| AC-15 | Executor, planner, policy, template rows | PASS | `TCW-EXECUTOR`, `TCW-PLANNER`, `TCW-POLICY`, `TCW-TEMPLATE` rows pass | pester selection | |
| AC-16 | Ledger entry `0014` | PASS | Entry sections and labels present and extended for cycle 1; reviewer completeness check finds 0 absent paths; five ledger suites pass | pester selection; reviewer path check | |
| AC-17 | Phase 0 and final QA remain full runs | PASS | `Final QA loop` bullet kept; baseline and final QA artifacts are full runs with coverage comparison (96.84% to 96.85% PowerShell lines) | evidence inspection | |
| AC-18 | CI unchanged | PASS | `git diff --name-only a4ebf9668 4ac1f0be8` lists no `.github/workflows/` path | `git diff --name-only` | |
| AC-19 | Out-of-scope paths untouched | PASS | No path under the protected list, no `.py`; `test_parallel_orchestrator_surface_contracts.py` (frozen digest) passed in the reviewer pytest run | `git diff --name-only`; launcher `pytest` | |
| US-1 | Canonical section | PASS | As AC-01 and AC-02 | pester selection | |
| US-2 | No surface requires a full run outside the two points | PASS | Sweep rows pass; the QA-gate overall delta is scoped to the final QA loop and the remediation gate's selection run is its gate run (F1); the review surfaces no longer grade a selection-only file as repo-wide (F2) | pester selection; discrimination probe; worktree grep | F1 and F2 resolved |
| US-3 | Dependent surfaces state the selection runs | PASS | As AC-05 to AC-10 | pester selection | |
| US-4 | Generated outputs regenerated | PASS | As AC-11 and AC-12 | generator checks | |
| US-5 | Bundle parity | PASS | As AC-13 | `cmp`; pytest | |
| US-6 | Pinned tests updated and pass | PASS | As AC-06, AC-14, AC-15 | pester selection | |
| US-7 | Ledger entry | PASS | As AC-16 | pester selection | |
| US-8 | Full runs retained | PASS | As AC-17 | evidence | |
| US-9 | CI unchanged, out-of-scope untouched | PASS | As AC-18 and AC-19 | `git diff --name-only`; pytest | |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION (every criterion passes as written; blocking finding F3 remains against the owner objective and spec D3)

**Criteria summary:**
- **PASS:** 28 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. F3: the feature-review coverage Stop hook (unchanged by the branch) grades the selection-run coverage report as the repo-wide figure, so a review that follows the branch's D3 rule cannot complete without a false repo-wide FAIL or a full-suite run. Spec D3 states that no hook change is needed; that premise does not hold for `validate-feature-review-coverage-metrics.ps1`. The owner objective ("reflected in every rule that operates otherwise for all orchestrators") covers this enforcement. No criterion text names hooks, so no checkbox is reopened.

**Recommended follow-up verification steps:**

1. After the F3 cycle, run a review whose coverage report comes from a selection run with a below-floor root counter and confirm the Stop hook accepts a PASS audit; then confirm the CI rows of `## CI Cross-check` at S9.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, PASS criteria stay checked.

### AC Status Summary

- Source: `.dev/active/1228-targeted-test-cadence/spec.md`, `.dev/active/1228-targeted-test-cadence/user-story.md`
- Total AC items: 28
- Checked off (delivered): 28
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `.dev/active/1228-targeted-test-cadence/spec.md` | 19 | 19 | 0 | Checkbox-backed; AC-08 was re-checked by the remediation executor ([P1-T7]) and is confirmed PASS here |
| `.dev/active/1228-targeted-test-cadence/user-story.md` | 9 | 9 | 0 | Checkbox-backed; items 2 and 3 were re-checked by the remediation executor and are confirmed PASS here |

The reviewer changed no checkbox in this audit: every PASS item was already checked. The `## Definition of Done` checkboxes in `spec.md` are not acceptance criteria and were left as they are.
