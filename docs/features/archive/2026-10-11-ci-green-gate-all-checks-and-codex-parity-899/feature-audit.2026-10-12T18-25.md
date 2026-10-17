# Feature Audit: ci-green-gate-all-checks-and-codex-parity (Issue #899, also #891)

- Timestamp: 2026-10-12T18-25
- Reviewer: feature-review agent (reduced minor-audit re-audit, remediation cycle 2 exit)
- Companion artifacts: `policy-audit.2026-10-12T18-25.md`, `code-review.2026-10-12T18-25.md`

## Scope and Baseline

- Branch: `bug/ci-green-gate-all-checks-and-codex-parity-899`, HEAD `e32cce737c072bef90a724dd7d97e23dd06b2566`.
- Base: `origin/main` @ `7d9a5c33526d7a98d5577ab4a9ad6f465f3dff3c` (merge-base). Diff: `git diff origin/main...HEAD`, 111 files (+3494/-84): 14 source surfaces (13 from the original change plus `.claude/agents/parallel-orchestrator.md`), 14 bundle mirrors, 1 Pester test file, 1 new Python test module, and the feature folder (issue, plan, research, review and remediation artifacts, evidence).
- Work mode: `minor-audit`. AC source: `issue.md` `## Acceptance Criteria` (AC-1 to AC-11). `spec.md` and `user-story.md` are absent.
- Baseline behavior on `origin/main`: S9 queried `gh pr checks --required` for non-epic PRs; Merge-on-Green re-read checks only "when the check conclusion must be re-read"; the Codex `## CI Green Gate` had no parser invocation or epic-child guard; parser lines 104 and 338 were not executed by any test.
- Remediation history: cycle 1 (R-1, Python coverage evidence) and cycle 2 (R-2, persona Bash grant for the parser invocation; R-1 re-closure). Both are closed per `policy-audit.2026-10-12T18-25.md` section 8.

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
| AC-1 | PASS | Reviewer run at HEAD of `test_ci_gate_all_checks_contracts.py` passed (`test_s9_queries_every_check_without_required_flag`, source and mirror). |
| AC-2 | PASS | Reviewer run at HEAD of `test_ci_gate_epic_child_contracts.py` passed. |
| AC-3 | PASS | `test_s9_states_no_checks_error_is_never_green` passed at HEAD. Cycle 2 did not change S9; the backticked S9 pin is intact. |
| AC-4 | PASS | `test_merge_on_green_always_rereads_every_check` passed at HEAD after the cycle 2 quoting change. The parser invocation in step 2 is now executable by the persona: `test_every_prescribed_command_invocation_has_a_persona_bash_grant` passed at HEAD. |
| AC-5 | PASS | Codex gate tests passed at HEAD; `test_completion_gate_documentation_contracts.py` passed at HEAD. |
| AC-6 | PASS | `test_surface_restates_no_required_only_population` passed at HEAD over 22 surfaces. |
| AC-7 | PASS | Reviewer: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` exit 0 at HEAD; 0 CR bytes in the 6 Codex TOML files. |
| AC-8 | PASS | Local `artifacts/pester/pester-junit.xml`: 37 tests, 0 failures; both `default NowProvider delegates` cases Passed. Parser and Pester files are unchanged since that run (`git diff --stat a14899f7b HEAD` on both paths is empty). |
| AC-9 | PENDING-CI | Owned by the orchestrator after the PR `CI` run (`poshqc-test-results` artifact). Supplementary local value: `Invoke-CiGateParser.ps1` LINE missed 0, covered 46. Left unchecked. |
| AC-10 | PASS | Reviewer `cmp -s`: all 14 source/mirror pairs byte-identical, including the cycle 2 persona and Merge-on-Green edits. Push-down Claude and Codex resource contract tests and the completion-gate documentation test passed at HEAD. |
| AC-11 | PASS | Zero changed paths for `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md`; `test_parallel_orchestrator_surface_contracts.py` passed at HEAD. |

Reviewer pytest total at HEAD for the seven contract modules: 155 passed, 0 failed.

## Summary

- AC verdicts: 10 PASS (AC-1 to AC-8, AC-10, AC-11), 1 PENDING-CI (AC-9), 0 FAIL.
- Relative to the `origin/main` baseline, the branch delivers the #899 behavior (every check counts at S9 and at the parallel merge, and the parallel-orchestrator persona can run the parser that the merge step prescribes) and the #891 behavior (Codex gate parity and execution of both default clock delegates).
- Prior blocking findings: PA-1 closed (repo-wide Python line 93.80%, branch 88.10%, 0 failed nodes); R-2 closed (permission contract node passes at HEAD).
- Non-blocking: PA-N1 (policy audit; `artifacts/python/lcov.info` absent at review time, figures verified from same-run data files); CR-1, CR-2 (Minor) and CR-3, CR-4, CR-5 (Info) in the code review.
- Overall review verdict: **PASS**. Blocking count: 0. Non-blocking count: 6.

## Acceptance Criteria Check-off

- AC-1 to AC-8, AC-10, and AC-11 were already checked in `issue.md`; each is evaluated PASS above, so no change to `issue.md` was required.
- AC-9 remains unchecked (PENDING-CI).
- No AC text was modified and no criterion was added.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/issue.md`
- Total AC items: 11
- Checked off (delivered): 10
- Remaining (unchecked): 1
- Items remaining: AC-9 (CI-dependent): The PR `CI` run artifact `poshqc-test-results` reports zero missed lines for `Invoke-CiGateParser.ps1` in `artifacts/pester/powershell-coverage.xml`.
