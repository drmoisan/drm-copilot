# Feature Audit: ci-green-gate-all-checks-and-codex-parity (Issue #899, also #891)

- Timestamp: 2026-10-12T16-45
- Reviewer: feature-review agent (reduced minor-audit review)
- Companion artifacts: `policy-audit.2026-10-12T16-45.md`, `code-review.2026-10-12T16-45.md`, `remediation-inputs.2026-10-12T16-45.md`

## Scope and Baseline

- Branch: `bug/ci-green-gate-all-checks-and-codex-parity-899`, HEAD `a14899f7b059f0059866c0a67216475ceecf0a94`.
- Base: `origin/main` @ `9338ed463c63a039cadbe4f0548af7151f43f687` (merge-base). Diff: `git diff origin/main...HEAD`, 64 files (+2177/-84): 13 source surfaces (including the parser), 13 bundle mirrors, 1 Pester test file, 1 new Python test module, and 36 feature-folder files (issue, plan, research, and 33 evidence files).
- Work mode: `minor-audit`. AC source: `issue.md` `## Acceptance Criteria` (AC-1 to AC-11). `spec.md` and `user-story.md` are absent.
- Plan: `plan.2026-10-11T09-44.md`, 65 of 65 tasks checked (reviewer count).
- Baseline behavior on `origin/main`: S9 queried `gh pr checks --required` for non-epic PRs; Merge-on-Green re-read checks only "when the check conclusion must be re-read"; the Codex `## CI Green Gate` had no parser invocation or epic-child guard; parser lines 104 and 338 were not executed by any test.

## Acceptance Criteria Inventory

| ID | Criterion (short form) | State before review |
|---|---|---|
| AC-1 | S9 (source and mirror) queries every check, no `--required` | checked |
| AC-2 | S9 epic-child guard and pinned wording preserved | checked |
| AC-3 | S9 states `no checks reported` is never green for any PR | checked |
| AC-4 | Merge-on-Green always re-reads every check through the parser; superseded phrase removed | checked |
| AC-5 | Codex gate (source and mirror) invokes parser, `-RequireWorkflow CI` for epic base, every check, fail-closed when parser absent | checked |
| AC-6 | No in-scope surface restates a required-only population | checked |
| AC-7 | `generate_codex_agent_variants --check` exits 0 | checked |
| AC-8 | Both default clock delegates execute under two new passing Pester tests | checked |
| AC-9 | CI `poshqc-test-results` reports zero missed lines for the parser | unchecked (CI-dependent) |
| AC-10 | Every edited surface byte-identical to its mirror; push-down and mirror parity tests pass | checked |
| AC-11 | Hash-pinned epic surfaces unchanged; surface contract test passes | checked |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence |
|---|---|---|
| AC-1 | PASS | Reviewer run of `test_ci_gate_all_checks_contracts.py` passed (`test_s9_queries_every_check_without_required_flag` over source and mirror). Reviewer `grep -n -- '--required'` over S9 source, Codex gate source, parallel-orchestrate, and parser returned no match. |
| AC-2 | PASS | Reviewer run of `test_ci_gate_epic_child_contracts.py` passed. The epic-child paragraph in S9 retains its wording; only the clause about `--required` returning an empty set changed. |
| AC-3 | PASS | `test_s9_states_no_checks_error_is_never_green` passed over source and mirror; S9 No-checks rule text in the diff. |
| AC-4 | PASS | `test_merge_on_green_always_rereads_every_check` passed over source and mirror; it asserts the parser command, the `success`-only `ci_green` condition, and absence of "when the check conclusion must be re-read". |
| AC-5 | PASS | `test_codex_ci_green_gate_invokes_parser_with_epic_child_guard` and `test_codex_ci_green_gate_fails_closed_without_parser` passed over source and mirror; reviewer run of `test_completion_gate_documentation_contracts.py` passed. |
| AC-6 | PASS | `test_surface_restates_no_required_only_population` passed over 22 surfaces (11 sources and 11 mirrors). |
| AC-7 | PASS | `evidence/qa-gates/final-codex-variants-check.2026-10-11T09-44.md` records exit 0 with empty stderr. Reviewer confirmed the 12 TOML files carry 0 CR bytes and each source/mirror pair is byte-identical; the executor's CR normalization is recorded in `evidence/other/codex-variants-regenerate.2026-10-11T09-44.md`. |
| AC-8 | PASS | Local `artifacts/pester/pester-junit.xml` (written by the P2-T6 `run_poshqc_test` run): 37 tests, 0 failures, 0 errors; both `default NowProvider delegates` cases Passed. Local coverage records lines 104 and 338 with `ci="2"`. |
| AC-9 | PENDING-CI | CI-dependent; checked by the orchestrator against the PR `CI` run artifact `poshqc-test-results`. Supplementary local value: `Invoke-CiGateParser.ps1` LINE missed 0, covered 46. Not a blocking finding per caller direction. |
| AC-10 | PASS | Reviewer `cmp -s` reported SAME for all 13 source/mirror pairs. Reviewer run of `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and `test_completion_gate_documentation_contracts.py` passed. |
| AC-11 | PASS | `git diff --name-only origin/main...HEAD` returns zero paths for `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md`; reviewer run of `test_parallel_orchestrator_surface_contracts.py` passed. |

Reviewer pytest total for the six modules named above: 152 passed, 0 failed.

## Summary

- AC verdicts: 10 PASS (AC-1 to AC-8, AC-10, AC-11), 1 PENDING-CI (AC-9), 0 FAIL.
- Relative to the `origin/main` baseline, the branch delivers the #899 behavior (every check counts at S9 and at the parallel merge) and the #891 behavior (Codex gate parity and execution of both default clock delegates).
- Executor deviations assessed as non-blocking: CRLF normalization of generator output (result verified), estimated-then-corrected evidence timestamps (chronology only), and `git grep -c` substitution for single-match checks (equivalent assertion).
- Concurrent item #890: the parallel-orchestrate diff is limited to Merge-on-Green steps 1-2 (hunks at lines 376 and 378-384).
- Overall review verdict: **FAIL**, driven solely by policy-audit finding PA-1 (Python coverage artifact absent; evidence-only, Remediability `autonomous`). Code review: 0 Blocking, 2 Minor, 2 Info.

## Acceptance Criteria Check-off

- AC-1 to AC-8, AC-10, and AC-11 were already checked in `issue.md` by the executor; each is evaluated PASS above, so no change to `issue.md` was required.
- AC-9 remains unchecked (PENDING-CI).
- No AC text was modified and no criterion was added.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/issue.md`
- Total AC items: 11
- Checked off (delivered): 10
- Remaining (unchecked): 1
- Items remaining: AC-9 (CI-dependent): The PR `CI` run artifact `poshqc-test-results` reports zero missed lines for `Invoke-CiGateParser.ps1` in `artifacts/pester/powershell-coverage.xml`.
