# Feature Audit: CI gate vacuous on empty check list (#841, also closes #795)

---

**Audit Date:** 2026-10-10
**Feature Folder:** `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841`
**Base Branch:** `main`
**Head Branch:** `bug/ci-gate-vacuous-on-empty-check-list-841`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `793731a12e0aafb5f6eb645fffa072d941797de1`)
- **Head branch/commit:** `bug/ci-gate-vacuous-on-empty-check-list-841` (commit `87f57d4f554172020dbf0f50d7e797a32298a647`)
- **Merge base:** `793731a12e0aafb5f6eb645fffa072d941797de1` (equal to `origin/main`; `origin/main` was merged into the branch at `87f57d4f5`). Executor pre-change base: `5431ccdd471c184917493c4211afcd715bb4b95c`.
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-10 13:46 UTC at head `87f57d4f5`; current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/**` (39 files)
  - Additional evidence: reviewer-run `poetry run pytest` (1299 passed, 5 skipped), Black/Ruff/Pyright on the new test file, `cmp` of four mirror pairs, `wc -l`, `git diff --name-only origin/main...HEAD`, CI run 38054308295 logs at the pre-change base.
- **Feature folder used:** `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** explicit marker `- Work Mode: full-bug` in `issue.md` line 12; `full-bug` resolves to `spec.md` as the sole AC source.
- **Scope note:** full branch diff against `main` (61 paths: 10 code/skill paths, the promoted lifecycle record, and 50 feature-folder paths). PowerShell format, analyze, and Pester results come from executor evidence produced through the operator-mandated PoshQC MCP route (`ROUTE_SUBSTITUTION:`); the reviewer bound that evidence to the committed content by matching the recorded `git hash-object` values (`7c81ef17c`, `dd1af2928`) to the blob IDs in the branch diff. CI has not run (no PR yet).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` — only source (`## Acceptance Criteria`, 22 checkbox items)

### Acceptance criteria

1. AC-1: `Invoke-CiGateParser.ps1` exposes an optional `-RequireWorkflow` string parameter (default `''`) at script level, on `Invoke-CiGateParser`, and on `Get-CiGateConclusion`, with `.PARAMETER RequireWorkflow` help text; verified by a Pester test in `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` that asserts the parameter on all three and its default.
2. AC-2: With `-RequireWorkflow 'CI'`, an empty check array (`-ChecksJson '[]'`) and a `$null` set (`Get-CiGateConclusion -Checks $null -RequireWorkflow 'CI'`) each return `pending`; verified by named Pester tests in the `-RequireWorkflow (epic-child guard)` context.
3. AC-3: With `-RequireWorkflow 'CI'`, a set containing only non-`CI` checks, all `pass`, returns `pending`; verified by a named Pester test.
4. AC-4: With `-RequireWorkflow 'CI'`, a set with a `CI` `pass` check (alone, and together with a non-`CI` `pass` check) returns `success`; verified by named Pester tests.
5. AC-5: With `-RequireWorkflow 'CI'`, a `CI` check with bucket `fail` returns `failure` and a `CI` check with bucket `cancel` returns `failure`; verified by named Pester tests.
6. AC-6: With `-RequireWorkflow 'CI'`, a `CI` `pass` check plus a non-`CI` `fail` check returns `failure`; verified by a named Pester test.
7. AC-7: With `-RequireWorkflow 'CI'`, a `CI` `pending` check returns `pending`, a `CI` `pass` check plus a non-`CI` `pending` check returns `pending`, and a `CI` `pending` check plus any `fail` check returns `failure`; verified by named Pester tests.
8. AC-8: With `-RequireWorkflow 'CI'`, a set whose only `CI` checks are `skipping` returns `pending`; a `pass` check with `workflow = 'ci'` does not satisfy `CI` (returns `pending`); an element lacking a `workflow` property is non-matching and does not throw; and a whitespace-only `-RequireWorkflow` value throws an error naming the parameter; verified by named Pester tests.
9. AC-9: Invoking the script file as `& $script:scriptPath -ChecksJson '[]' -HeadSha x -RequireWorkflow CI -NowProvider $fixedClock` returns an object whose `conclusion` is `pending`; verified by a named Pester test (covers `process`-block forwarding).
10. AC-10: Without `-RequireWorkflow`, behavior is unchanged: every pre-existing `It` block in `Invoke-CiGateParser.Tests.ps1` is retained with its original expectation, the empty-array test (renamed to include "without -RequireWorkflow") returns `success`, and the null-set test returns `success`; verified by the Pester run.
11. AC-11: `.claude/skills/orchestrate/SKILL.md` S9 states that step 3 passes `-RequireWorkflow CI` when `epic_mode` is true; that every observed check counts on an epic child (a failing non-`CI` check fails the gate); that at least one passing `CI` check is required; that a `gh pr checks` "no checks reported" error is handed to the parser as `'[]'` and is never treated as green; step 3 describes the conclusion over the queried checks and the `head_sha` bullet reads "the queried checks were observed against"; the phrases "derives `ci_gate.conclusion` as `success` when all required checks pass" and "that the required checks were observed against" are absent; verified by `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` for the source and the Claude bundle mirror.
12. AC-12: The S9 step 3 command remains on one line beginning `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1`, and `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` passes.
13. AC-13: `.claude/skills/epic-orchestrate/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, `.claude/rules/**`, `.github/instructions/**`, and `.github/workflows/**` are unchanged; verified by `git diff --name-only origin/main...HEAD` listing none of those paths and the `tests/scripts/dev_tools/test_parallel_*` surface-pin tests passing.
14. AC-14: `.claude/skills/feature-review-workflow/SKILL.md` and its Claude bundle mirror define the qualifying run with alternative (a) head SHA equals the current branch head, or (b) the three predecessor-head conditions, containing the fragments `git merge-base --is-ancestor`, `":!<feature-folder>"`, `ci_gate.head_sha`, and "cannot name the SHA of the commit that contains it", and no longer contain "a workflow run whose head SHA matches the current branch head and whose conclusion is success" as the definition; verified by `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`.
15. AC-15: `.agents/skills/feature-review-workflow/SKILL.md` and its Codex bundle mirror contain `## Policy Rules` and `### modified-workflow-needs-green-run` between the work-mode contract and `## Ordered Procedure`, carrying the trigger paths, the AC-14 fragments, the `workflow_dispatch` bullet, the `awaiting_ci` bullet, and the phrase "CI Green Gate (S9)"; verified by `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`.
16. AC-16: A citation-resolution test in `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` asserts, for each of the four `.agents`-side citing copies (`.agents/skills/ci-workflows/SKILL.md`, `.agents/skills/benchmark-baselines/SKILL.md`, and their two Codex bundle mirrors), that the cited `.agents/skills/feature-review-workflow/SKILL.md` contains the heading `### modified-workflow-needs-green-run`, and includes a synthetic negative case that fails when the heading is absent; verified by pytest.
17. AC-17: Mirror parity is preserved: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, and `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1` pass.
18. AC-18: Pinned-fragment suites pass unchanged: `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`, `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`, and `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py`.
19. AC-19: PoshQC formatting (`Invoke-Formatter`) produces no changes and PSScriptAnalyzer reports zero findings for `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` and `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`; results recorded under `evidence/qa-gates/`.
20. AC-20: `Invoke-Pester` on `tests/scripts/claude-lib/ci-gate/` passes with zero failures and line coverage on `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` >= 85% and not below the pre-change baseline; baseline under `evidence/baseline/` and post-change result under `evidence/qa-gates/`.
21. AC-21: `black --check`, `ruff check`, `pyright`, and `pytest` pass for `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`; results recorded under `evidence/qa-gates/`.
22. AC-22: No production or test file written by this item exceeds 500 lines (`.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, its bundle mirror, `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`, `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`); verified by a line count recorded under `evidence/qa-gates/`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 parameter on three surfaces + help | PASS | Diff adds `[string]$RequireWorkflow = ''` at script `:106-107`, `Invoke-CiGateParser` `:340-341`, `Get-CiGateConclusion` `:162-163`, and `.PARAMETER RequireWorkflow` in all three help blocks; AST tests "declares -RequireWorkflow ..." and "documents .PARAMETER RequireWorkflow ..." pass | `mcp__drm-copilot__run_poshqc_test` (ci-gate folder), JUnit 35/35 | Failed before the fix (before-fix items 1-2) |
| 2 | AC-2 empty array and `$null` -> pending | PASS | Tests "returns pending for an empty check array with -RequireWorkflow CI", "returns pending for a null check set with -RequireWorkflow CI" | same Pester run | Code `:177-181` |
| 3 | AC-3 only non-CI pass -> pending | PASS | Test "returns pending when only non-CI checks pass" | same Pester run | Presence rule `:236-237` |
| 4 | AC-4 CI pass (alone / with non-CI pass) -> success | PASS | Two named tests pass | same Pester run | |
| 5 | AC-5 CI fail / cancel -> failure | PASS | "returns failure when a CI check failed", "returns failure when a CI check was cancelled" | same Pester run | |
| 6 | AC-6 CI pass + non-CI fail -> failure | PASS | "returns failure when a CI check passes and a non-CI check failed" | same Pester run | |
| 7 | AC-7 pending combinations | PASS | Three named tests (CI pending; CI pass + non-CI pending; CI pending + fail) | same Pester run | Failure outranks pending |
| 8 | AC-8 skipping, lowercase `ci`, no `workflow` property, whitespace-only throws | PASS | Four named tests; throw message matches `*-RequireWorkflow*whitespace-only*` | same Pester run | StrictMode-safe property check `:213-215` |
| 9 | AC-9 script-level forwarding | PASS | "forwards -RequireWorkflow from the script entry point" uses `& $script:scriptPath ... -RequireWorkflow 'CI'` -> `pending` | same Pester run | `process` block `:398` forwards the parameter |
| 10 | AC-10 default behavior unchanged | PASS | Diff of the test file changes only the `:91` test name; no pre-existing `It` removed or re-expected; 15 pre-existing tests pass before and after the fix | `git diff origin/main...HEAD -- tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`; Pester run | Null-set test at `:201` retained |
| 11 | AC-11 S9 epic-child text in both copies | PASS | `test_orchestrate_s9_states_epic_child_guard`, `test_orchestrate_schema_head_sha_names_queried_checks`, `test_orchestrate_drops_required_check_wording` pass for source and Claude mirror | `poetry run pytest -q -p no:cacheprovider tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` (26 passed, reviewer) | Mirror byte-identical (`cmp`) |
| 12 | AC-12 one-line command; bundle contract test | PASS | `test_orchestrate_parser_command_stays_on_one_line` passes; `test_skill_bundle_contract_repo.py` passes | reviewer pytest run (1299 passed) | Step 3 line begins with the required command span |
| 13 | AC-13 excluded paths unchanged | PASS | Reviewer scan of `git diff --name-only origin/main...HEAD` (61 paths) for `.github/`, `.claude/rules`, `.claude/skills/epic-orchestrate`, `.agents/skills/orchestrate`, `.claude/agents/orchestrator`: zero matches; `test_parallel_*.py` pass | `git diff --name-only origin/main...HEAD`; reviewer pytest run | Also `evidence/qa-gates/unchanged-files.2026-10-08T22-17.md` |
| 14 | AC-14 qualifying-run fragments, SHA-exact sentence removed | PASS | `test_review_rule_defines_satisfiable_qualifying_run` and `test_review_rule_drops_sha_exact_definition` pass for `.claude` source and Claude mirror | reviewer pytest run | Diff replaces `:73` only; `:72`, `:74`, `:75` unchanged |
| 15 | AC-15 `.agents` rule section placement and bullets | PASS | `test_agents_review_rule_sits_before_ordered_procedure`, `test_agents_review_rule_carries_codex_bullets`, and both review-rule tests pass for `.agents` source and Codex mirror | reviewer pytest run | Uses "orchestrator CI Green Gate (S9)" |
| 16 | AC-16 citation resolution + synthetic negative | PASS | `test_agents_citing_copy_resolves_rule` (4 citing copies) and `test_rule_resolution_reports_missing_heading` pass | reviewer pytest run | Bundle citations resolved against the bundle root |
| 17 | AC-17 mirror parity suites | PASS | `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py` pass (reviewer); `CiGate.Manifest.Tests.ps1` 2/2 (executor JUnit) | reviewer pytest run; `mcp__drm-copilot__run_poshqc_test` | Reviewer `cmp` confirms four pairs identical |
| 18 | AC-18 pinned-fragment suites | PASS | `test_completion_gate_documentation_contracts.py`, `test_push_down_tier_rule_adoption_gate.py`, `test_orchestrator_state_remediation_docs.py` pass | reviewer pytest run | |
| 19 | AC-19 PoshQC format and PSSA clean | PASS | `evidence/qa-gates/final-powershell-format.2026-10-08T22-17.md` (ChangedCount=0, hashes `7c81ef17c`/`dd1af2928` match the branch blobs), `final-powershell-analyze.2026-10-08T22-17.md` (DiagnosticCount=0) | `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze` | Operator-mandated MCP route; not re-run by reviewer |
| 20 | AC-20 Pester pass, coverage >= 85% and >= baseline | PASS | 35/35; parser 97.83% (45/46) vs baseline 94.12% (32/34); `evidence/baseline/pester-ci-gate-coverage...`, `evidence/qa-gates/final-pester-coverage...` | `mcp__drm-copilot__run_poshqc_test` + JaCoCo XML read | Route substitution for `Invoke-Pester` is operator-mandated; reviewer confirmed the 46-line executable set against the current XML |
| 21 | AC-21 Black, Ruff, Pyright, pytest on new file | PASS | Reviewer: Black unchanged, Ruff clean, Pyright 0 errors, pytest 26 passed; executor evidence `final-python-{black,ruff,pyright,pytest}...` | `poetry run black --check ...`; `poetry run ruff check ...`; `poetry run pyright ...`; `poetry run pytest ...` | |
| 22 | AC-22 files under 500 lines | PASS | `wc -l`: parser 402 (mirror identical), Pester 410, pytest 312; `evidence/qa-gates/line-counts.2026-10-08T22-17.md` | `wc -l <files>` | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 22 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. After the PR is opened, confirm the CI `PowerShell QC` job passes on the PR head and record its repo-wide `Covered` figure (expected >= 87.31%); this is the orchestrator S9 gate's responsibility.
2. Track the spec follow-ups (Codex S9 epic-child parity; optional wording alignment) as separate items.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`
- Total AC items: 22
- Checked off (delivered): 22
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` | 22 | 22 | 0 | Checkbox-backed; all 22 were already checked by the executor and each was independently verified PASS here |

No source-file checkbox change was made by this review: every criterion was already `[x]` and each evaluated as PASS, so no item needed to be checked or unchecked.
