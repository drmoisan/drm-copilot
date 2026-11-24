# Feature Audit: targeted-test-cadence (#1228), re-audit after remediation cycle 2

---

**Audit Date:** 2026-11-24
**Feature Folder:** `.dev/active/1228-targeted-test-cadence`
**Base Branch:** `main`
**Head Branch:** `feature/targeted-test-cadence-1228`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after remediation cycle 2

---

## Scope and Baseline

- **Base branch:** `main`, resolved as `origin/main` (commit `23458fade99f40e81b95ce86ed90805258479782`, fetched at review time)
- **Head branch/commit:** `feature/targeted-test-cadence-1228` (commit `c8a4d99cf3f41b02170caeaf0da398764370c638`, equal to the remote branch head)
- **Merge base:** `23458fade99f40e81b95ce86ed90805258479782`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-24 15:21:52 UTC for head `c8a4d99cf`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff 23458fade c8a4d99cf`
  - Feature evidence: `.dev/active/1228-targeted-test-cadence/evidence/{baseline,remediation-baseline,other,qa-gates}/`
  - Additional evidence: reviewer runs in the item worktree (generator `-Check` modes, Codex `--check`, bundle byte comparison, full launcher Pester run at head with 29658 tests and 0 failures, 17 direct reader probes, a real-file hook probe over the remediation gate's selection report and record)
- **Feature folder used:** `.dev/active/1228-targeted-test-cadence`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`.
- **Scope note:** full branch diff against the merge base (290 paths). The worktree was clean at review start. The previous review (`feature-audit.2026-11-24T10-50.md`) graded 28 of 28 criteria PASS with blocking finding F3 open; remediation cycle 2 added AC-20 and AC-21 to `spec.md`. This audit re-evaluates all 30.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `.dev/active/1228-targeted-test-cadence/spec.md` — primary source (AC-01 to AC-21)
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
20. AC-20: the feature-review coverage hook and its Codex twin grade a report covered by a valid `selection` record as per-file evidence and every other report, including C#, against the repo-wide floors; `RSCOPE-READ-*`, `RSCOPE-HOOK-*`, `RSCOPE-CODEX-*`, `RSCOPE-CONTRACT-LAUNCHER-RECORD` pass.
21. AC-21: the launcher writes the run-scope record after each suite run by the per-runner rules, writes nothing on refusal, timeout, or a thrown suite, reports a write failure without changing the exit code; brief and `test-execution-policy` state the record in all copies; `RSCOPE-LAUNCH-*` and `RSCOPE-DOC-*` pass.

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
| AC-01 | Canonical full-suite and phase-gate statements | PASS | `TCW-CANONICAL-*` rows pass at head | reviewer full launcher `pester` run (29658 tests, 0 failed) | Unchanged in cycle 2 |
| AC-02 | Remediation gate, local gate, kept tokens | PASS | `TCW-CANONICAL-*` and `TCW-CANONICAL-DISCRIMINATES` pass | same | |
| AC-03 | Cadence sweep and helper | PASS | `TCW-CADENCE-SWEEP-SURFACES` and `-HELPER` pass, including the cycle-2 brief and skill edits | same | |
| AC-04 | Repository-wide search evidence | PASS | `evidence/other/cadence-search.2026-11-24T04-48.md`; cycle 2 adds no cadence sentence (sweep rows pass) | file inspection; sweep rows | |
| AC-05 | Remediation handoff plan shape | PASS | `TCW-HANDOFF-*` pass | full run | |
| AC-06 | Regenerate path and `RSC-REGENERATE` same commit | PASS | `RSC-REGENERATE` rows pass; same-commit fact unchanged (`242d160fd`) | full run; `git show --stat 242d160fd` | |
| AC-07 | Typed-engineer D4 sentence | PASS | `TCW-ENGINEER-*` rows pass; generators clean | full run; generator `-Check` | |
| AC-08 | Feature-review step 5 D3 statement | PASS | `TCW-REVIEW-*`, `LEC-*`, `PGW-REVIEW-*` pass; D3 now also states the hook's selection grading (D11) | full run | |
| AC-09 | QA-gate When to Use | PASS | `TCW-QAGATE-*` rows pass | full run | |
| AC-10 | Brief and test-execution-policy selection statements | PASS | `TCW-BRIEF-*`, `TCW-SCOPED-*`, `PGW-SCOPED-*` pass | full run | |
| AC-11 | Harness generation no drift | PASS | Reviewer `-Check` and `-Surface instructions -Check` exit 0; `HarnessGeneration.RepoGate` passes; `evidence/qa-gates/generators.2026-11-24T14-15.md` | `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check` | Regenerated launcher copy included |
| AC-12 | Codex variant generator | PASS | Reviewer `--check` exit 0; recorded in the generators evidence | `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | |
| AC-13 | Bundle parity and `AGENTS.md` identity | PASS | Reviewer `cmp` of every cycle-2 hook and launcher file with its bundle: identical; `cmp AGENTS.md` exit 0; push-down resource suites passed in the remediation gate | `cmp`; remediation-gate pytest (229 passed) | |
| AC-14 | Existing vocabulary sweeps | PASS | `PGW-SWEEP-*` rows pass; token list unchanged | full run | |
| AC-15 | Executor, planner, policy, template rows | PASS | `TCW-EXECUTOR`, `TCW-PLANNER`, `TCW-POLICY`, `TCW-TEMPLATE` rows pass | full run | |
| AC-16 | Ledger entry `0014` | PASS | Entry extended for cycle 2 (Files Changed, stored patch with the two create hunks, revert steps); ledger chain and index suites pass | full run | |
| AC-17 | Phase 0 and final QA remain full runs | PASS | `Final QA loop` bullet kept; baseline and final QA artifacts are full runs with coverage comparison; reviewer full run at head 96.87% against the 96.84% baseline | evidence inspection; full run | |
| AC-18 | CI unchanged | PASS | `git diff --name-only 23458fade c8a4d99cf` lists no `.github/workflows/` path | `git diff --name-only` | |
| AC-19 | Out-of-scope and protected paths untouched | PASS | No path under the protected list, no `config/` path, no added `.py`; the frozen-surface digest test passed in the previous review at `4ac1f0be8`, and neither later commit touches a frozen surface | `git diff --name-only --diff-filter=A` | |
| AC-20 | Hook grades selection reports as per-file | PASS | `RSCOPE-READ-*`, `RSCOPE-HOOK-*`, `RSCOPE-CODEX-*`, and `RSCOPE-CONTRACT-LAUNCHER-RECORD` pass in the reviewer full run (RunScope hook suite 18, Claude freshness 41, Codex freshness 44, Codex coverage 43 tests, 0 failed); 17 reader probes resolve `full` for every malformed or non-covering record and C#; the real-file probe resolves `selection` for the gate's own report and record, where the old grading refuses a PASS row at 14.46% | full run; reader and real-file probes (policy audit section 5) | F3 resolved |
| AC-21 | Launcher writes the run-scope record | PASS | `RSCOPE-LAUNCH-*` (43 tests) and `RSCOPE-DOC-*` pass in the reviewer full run; the reviewer's own launcher run wrote `scope` `full` with a window containing the report write time; the gate's `-TestPath` run wrote `selection` | full run; record inspection | ShouldProcess gap tracked as F4, outside the criterion text |
| US-1 | Canonical section | PASS | As AC-01 and AC-02 | full run | |
| US-2 | No surface requires a full run outside the two points | PASS | Sweep rows pass; the review coverage hook no longer forces a full run after a selection run once merged (D11) | full run; probes | |
| US-3 | Dependent surfaces state the selection runs | PASS | As AC-05 to AC-10 | full run | |
| US-4 | Generated outputs regenerated | PASS | As AC-11 and AC-12 | generator checks | |
| US-5 | Bundle parity | PASS | As AC-13 | `cmp` | |
| US-6 | Pinned tests updated and pass | PASS | As AC-06, AC-14, AC-15 | full run | |
| US-7 | Ledger entry | PASS | As AC-16 | full run | |
| US-8 | Full runs retained | PASS | As AC-17 | evidence; full run | |
| US-9 | CI unchanged, out-of-scope untouched | PASS | As AC-18 and AC-19 | `git diff --name-only` | |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION (every criterion passes as written; blocking policy finding F4 remains)

**Criteria summary:**
- **PASS:** 30 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. F4: `Write-TestSuiteRunScopeRecord` in the launcher (source, generated copy, bundles) is a state-changing function without `SupportsShouldProcess`, contrary to `.claude/rules/powershell.md` `## Coding Standards`. No criterion text names it, so no checkbox is reopened.
2. Non-blocking: `user-story.md` `## Non-Goals` still excludes hook changes, which spec D11 now makes.

**Recommended follow-up verification steps:**

1. After the F4 cycle, confirm the `-WhatIf` row and the regenerated ledger patch, then confirm the CI rows of `## CI Cross-check` at S9. After merge, the first review that follows a selection run confirms D11 under the live hook.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, PASS criteria stay checked.

### AC Status Summary

- Source: `.dev/active/1228-targeted-test-cadence/spec.md`, `.dev/active/1228-targeted-test-cadence/user-story.md`
- Total AC items: 30
- Checked off (delivered): 30
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `.dev/active/1228-targeted-test-cadence/spec.md` | 21 | 21 | 0 | Checkbox-backed; AC-20 and AC-21 were checked by the remediation executor ([P1-T8]) and are confirmed PASS here |
| `.dev/active/1228-targeted-test-cadence/user-story.md` | 9 | 9 | 0 | Checkbox-backed |

The reviewer changed no checkbox in this audit: every PASS item was already checked. The `## Definition of Done` checkboxes in `spec.md` are not acceptance criteria and were left as they are.
