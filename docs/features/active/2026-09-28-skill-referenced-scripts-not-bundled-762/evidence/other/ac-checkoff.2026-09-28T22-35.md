# Acceptance-Criteria Check-Off (P11-T2 through P11-T9)

Timestamp: 2026-09-28T22-35
Command: sed -i "s/^- \[ \] ACn:/- [x] ACn:/" FEATURE/spec.md (n = 1..7; AC8 left unchanged)
EXIT_CODE: 0
Output Summary: AC1 through AC7 were checked off in `FEATURE/spec.md`, changing only `[ ]` to `[x]`. AC8 remains unchecked because the P10-T3 CI run concluded `failure`. The plan outcome for AC8 is remediation-required.

Evidence paths are relative to `FEATURE/evidence/`.

## AC1 — checked (P11-T2)
- `qa-gates/ac1-audit-coverage.2026-09-28T22-17.md`: `AUDIT skills=56 missing=0`.

## AC2 — checked (P11-T3)
- Fail-before: `regression-testing/guard-before-fix.2026-09-28T22-02.md` (P1-T11, the `cleanup-merged-worktrees | scripts/bash/cleanup-worktrees.sh | not-in-bundle` violation).
- `regression-testing/cleanup-bats-after-move.2026-09-28T22-02.md` (P2-T13, KL-SHELL-2 only).
- `regression-testing/ci-gate-manifest-after-fix.2026-09-28T22-13.md` (records P4-T1 ten equal script mirror pairs, P4-T2 SKILL.md pair, P4-T5 manifest count 10).
- Pass-after: `regression-testing/guard-after-fix.2026-09-28T22-17.md` (P6-T1, 5 passed).

## AC3 — checked (P11-T4)
- Fail-before: `regression-testing/guard-before-fix.2026-09-28T22-02.md` (P1-T11, `test_ci_gate_parser_skills_invoke_bundled_parser` FAILED) and `regression-testing/ci-gate-manifest-before-fix.2026-09-28T22-02.md` (P1-T19, 0/2 passed).
- `regression-testing/ci-gate-parser-after-move.2026-09-28T22-13.md` (P3-T10, 15/15).
- `regression-testing/ci-gate-manifest-after-fix.2026-09-28T22-13.md` (P4-T4 parser mirror equal; P4-T7 2/2).
- Pass-after: `regression-testing/guard-after-fix.2026-09-28T22-17.md` (P6-T1).

## AC4 — checked (P11-T5)
- `qa-gates/old-path-sweep.2026-09-28T22-17.md` (P6-T3, `SWEEP-EXIT=1`, historical records excluded per OQ2).
- `qa-gates/old-dirs-empty.2026-09-28T22-17.md` (P6-T4, no output).

## AC5 — checked (P11-T6)
- Fail-before: `regression-testing/shell-qc-discovery-before-fix.2026-09-28T22-02.md` (P1-T16, four `not ok`).
- `regression-testing/shell-qc-discovery-after-fix.2026-09-28T22-13.md` (P5-T3, no `not ok`).
- `regression-testing/discovery-skill-scripts.2026-09-28T22-13.md` (P5-T4, ten skill scripts discovered).
- `qa-gates/shell-lint.2026-09-28T22-17.md` (P7-T2, exit 0, no diagnostics).
- `qa-gates/shell-coverage-files.2026-09-28T22-35.md` (P10-T6, all ten measured at the new path, no MISSING).

## AC6 — checked (P11-T7)
- `regression-testing/guard-units-initial.2026-09-28T22-02.md` (P1-T5, 33 passed).
- Fail-before: `regression-testing/guard-before-fix.2026-09-28T22-02.md` (P1-T11).
- Pass-after: `regression-testing/guard-after-fix.2026-09-28T22-17.md` (P6-T1).
- `qa-gates/ci-jobs.2026-09-28T22-35.md` (P10-T4, the guard ran in the CI Python stage: `test_skill_bundle_contract_repo.py .....`, 5340 passed on 3.12; all four quality-checks jobs success).

## AC7 — checked (P11-T8)
- `regression-testing/guard-units-initial.2026-09-28T22-02.md`: `test_find_stale_exceptions_reports_unmatched_exception` PASSED and `test_known_unbundled_references_cite_issue_763` PASSED.
- `regression-testing/guard-after-fix.2026-09-28T22-17.md`: `test_known_unbundled_references_are_not_stale` PASSED.

## AC8 — NOT checked (P11-T9)
- Phases 7, 8, and 9 artifacts pass. `qa-gates/coverage-comparison.2026-09-28T22-35.md` records `Disposition: PASS` for all three languages. P10-T1, P10-T2, P10-T4, P10-T5, and P10-T6 pass.
- `qa-gates/ci-dispatch.2026-09-28T22-17.md` (P10-T3) does not pass: run 36513322997 concluded `failure`, because the three `NPM Audit Gate` jobs failed on the newly published `ip-address` advisories GHSA-rpw4-54j3-4h4q and GHSA-2vr4-cq9g-pvrc. These are unrelated to this change, which touches no npm manifest.
- P11-T9 requires every Phase 10 artifact to pass, so AC8 stays unchecked and the plan outcome is remediation-required. Remediation (orchestrator decision): update `ip-address` in the three npm workspaces, or wait for main to take that fix, then re-dispatch CI and re-run P10-T3.
