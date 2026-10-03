# r2 Phase 9 acceptance-criteria check-off (remediation cycle 2, issue #824)

Timestamp: 2026-10-03T16-41
AC source: docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md v0.3 (Work Mode full-bug), sections Acceptance Criteria and Scope Extension.
Command: pwsh -NoProfile -File "SCRATCH/steps/r2-p9-t1.ps1" -Worktree "WORKTREE" (case-sensitive, line-anchored counts of the re-verified and regressed lines in this artifact and of checked AC lines in spec.md; VERDICT)
EXIT_CODE: 0
Output Summary: P9-T1 REVERIFIED=39 REGRESSED-COUNT=0 CHECKED=39 (AC-1 to AC-13, AC-15 to AC-26, and AC-28 to AC-41). Later Phase 9 tasks append their records below.
Evidence locations: FEATURE/evidence/regression-testing/, FEATURE/evidence/qa-gates/, FEATURE/evidence/other/ (artifact names below omit the TS suffix where unique within this cycle).

## P9-T1 re-verification of previously checked criteria

RE-VERIFIED AC-1: r2-ac1-ac2.2026-10-03T16-23 (A3 RAWINVOCATION=1 RAWCONTAINMENT=0 and A5 WORDPRESENT=1 SEQUENCEMATCH=0 on both surfaces); r2-pass-after-pester.2026-10-03T16-20 R824-P26 to R824-P30 passed on both surfaces, which carry the words in an order the earlier grammar rejected.
RE-VERIFIED AC-2: r2-ac1-ac2.2026-10-03T16-23 (CONTAINMENT-HITS=4 DEFINITIONS=2 MENTION-CALLERS=2; containment is used only by Test-CommandLineMention).
RE-VERIFIED AC-3: r2-pass-after-pester.2026-10-03T16-20 P824-D11 (unbalanced segment denied) on both runtimes; r2-p2-t4.2026-10-03T16-10.
RE-VERIFIED AC-4: r2-p2-t2.2026-10-03T16-09 (U1 58 passed) and r2-p2-t3.2026-10-03T16-10 (U2 58 passed, EQUAL=True).
RE-VERIFIED AC-5: r2-pass-after-pester.2026-10-03T16-20 P824-A1 on both runtimes; r2-p2-t4.2026-10-03T16-10.
RE-VERIFIED AC-6: r2-pass-after-pester.2026-10-03T16-20 P824-A2 on both runtimes; r2-p2-t4.2026-10-03T16-10.
RE-VERIFIED AC-7: r2-pass-after-pester.2026-10-03T16-20 P824-D1; r2-p2-t4.2026-10-03T16-10.
RE-VERIFIED AC-8: r2-pass-after-pester.2026-10-03T16-20 P824-D2; r2-p2-t4.2026-10-03T16-10.
RE-VERIFIED AC-9: r2-pass-after-pester.2026-10-03T16-20 P824-D3; r2-p2-t4.2026-10-03T16-10.
RE-VERIFIED AC-10: r2-pass-after-pester.2026-10-03T16-20 P824-D4; r2-p2-t4.2026-10-03T16-10.
RE-VERIFIED AC-11: r2-pass-after-pester.2026-10-03T16-20 P824-D5; r2-p2-t4.2026-10-03T16-10.
RE-VERIFIED AC-12: r2-pass-after-pester.2026-10-03T16-20 P824-D6; r2-p2-t4.2026-10-03T16-10.
RE-VERIFIED AC-13: r2-pass-after-pester.2026-10-03T16-20 P824-D7; r2-p2-t4.2026-10-03T16-10.
RE-VERIFIED AC-15: r2-p4-t7.2026-10-03T16-14 (N824-1 passed in S3 and S3X; 201 passed, 0 failed).
RE-VERIFIED AC-16: r2-p4-t3.2026-10-03T16-13 and r2-p4-t4.2026-10-03T16-13 (title renamed, numstat 2 2); r2-p4-t7.2026-10-03T16-14 RENAMED-PASSED=2; r2-test-integrity.2026-10-03T16-23 (NAMED=13 BAD-DELETES=0); r2-hook-suites-full.2026-10-03T16-20 (3688 passed, 0 failed).
RE-VERIFIED AC-17: r2-call-site-derivation.2026-10-03T16-23 (CALL-SITES=37 FILES=13) and the Remediation cycle 2 addendum in FEATURE/evidence/other/containment-path-hook-audit.md.
RE-VERIFIED AC-18: r2-hook-suites-full.2026-10-03T16-20 (pr-author trigger-scoping Issue824 rows pass; 0 failed).
RE-VERIFIED AC-19: r2-hook-suites-full.2026-10-03T16-20 (worktree-removal A824-WT1 and A824-WT2 rows pass on all three gate suites); r2-p3-t4.2026-10-03T16-11.
RE-VERIFIED AC-20: r2-hook-suites-full.2026-10-03T16-20 (validate-bash trigger-scoping Issue824 rows pass on both runtimes).
RE-VERIFIED AC-21: r2-hook-suites-full.2026-10-03T16-20 (preimplementation-gate and epic-merge-gate Issue824 rows pass on both runtimes).
RE-VERIFIED AC-22: r2-ac22.2026-10-03T16-23 (HITS=0; WHOLE-ORDERED-CALLERS=3/0/2 on all four copies).
RE-VERIFIED AC-23: r2-ac23-ac29.2026-10-03T16-24 (AC23-EQUAL=True,True); r2-identity.2026-10-03T16-40 (PAIRS=10 UNEQUAL=0); r2-p6-t2.2026-10-03T16-19 (parity 45 passed).
RE-VERIFIED AC-24: r2-identity.2026-10-03T16-40 (bundle copies byte-identical); r2-p6-t2.2026-10-03T16-19 (ISSUE-510-BRANCH=True, parity exit 0); r2-ac23-ac29.2026-10-03T16-24.
RE-VERIFIED AC-25: r2-ac25.2026-10-03T16-24 (LEGACY 43 passed, LINES=497, NUMSTAT-LINES=0).
RE-VERIFIED AC-26: r2-poshqc-format.2026-10-03T16-25 (FORMATTED=0), r2-poshqc-analyze.2026-10-03T16-26 (zero findings), r2-poshqc-test.2026-10-03T16-29 (6826 tests, 0 failures), r2-coverage-delta.2026-10-03T16-38 (every changed or new file at least 85%, no uncovered changed line).
RE-VERIFIED AC-28: r2-line-counts.2026-10-03T16-40 (every SCOPE-PATHS file at most 500 lines; HOOKS-OVER-500=0).
RE-VERIFIED AC-29: r2-ac23-ac29.2026-10-03T16-24 (PINS=5, S3 45 passed).
RE-VERIFIED AC-30: r2-pass-after-pester.2026-10-03T16-20 A824-WT3 passed on S6, S7, and S8.
RE-VERIFIED AC-31: r2-pass-after-pester.2026-10-03T16-20 A824-WT4-1 to -5 and A824-WT5-1 to -5 passed on S6, S7, and S8.
RE-VERIFIED AC-32: r2-pass-after-pester.2026-10-03T16-20 A824-WT3 (negative control) and A824-WT4 and A824-WT5 rows passed on S6, S7, and S8.
RE-VERIFIED AC-33: r2-poshqc-format.2026-10-03T16-25, r2-poshqc-analyze.2026-10-03T16-26, r2-poshqc-test.2026-10-03T16-29, r2-coverage-delta.2026-10-03T16-38.
RE-VERIFIED AC-34: r2-hook-suites-full.2026-10-03T16-20 (F824-1, F824-2, F824-3 on PASSED lines).
RE-VERIFIED AC-35: r2-p6-t2.2026-10-03T16-19 (PYG 40 passed).
RE-VERIFIED AC-36: r2-p6-t2.2026-10-03T16-19 (PYG 40 passed, including test_surface_does_not_hard_code_solution_file for SETUP and its bundle copy; parity 45 passed).
RE-VERIFIED AC-37: r2-p6-t2.2026-10-03T16-19 (PYG 40 passed).
RE-VERIFIED AC-38: r2-p6-t2.2026-10-03T16-19 (PYG 40 passed).
RE-VERIFIED AC-39: r2-pytest.2026-10-03T16-38 (6595 passed, 0 failed, TOTAL 94%).
RE-VERIFIED AC-40: the cycle-1 check-off evidence named in FEATURE/evidence/other/r1-ac-checkoff.2026-10-03T13-43.md, and r2-scope.2026-10-03T16-40, which shows docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md unchanged in this cycle.
RE-VERIFIED AC-41: every P8 artifact (r2-poshqc-format, r2-poshqc-analyze, r2-poshqc-test, r2-coverage-delta, r2-black, r2-ruff, r2-pyright, r2-pytest, r2-prettier, r2-eslint, r2-tsc, r2-jest, r2-shell-qc, r2-identity, r2-line-counts, r2-scope, r2-host-path-scan) and r2-qc-loop-complete.2026-10-03T16-40.

## P9-T2 check-off of AC-14

AC-14 changed from unchecked to checked in spec.md (checkbox only; criterion text unchanged). Evidence: r2-expect-fail-pester.2026-10-03T16-07 (P824-D16 to P824-D19 failed in S1 and S2; A824-X1, X2, X3, X4, X7, X8, X10 failed in S6, S7, and S8 on the unfixed tree) and r2-pass-after-pester.2026-10-03T16-20 (the same rows passed after the fix; P824-D16 to P824-D19 assert Get-PromotionMcpOnlyGhIssueBlockedReason); the unchanged prior rows P824-D8, P824-D9, P824-D10, and P824-A3 passed in both runs; r2-p2-t4.2026-10-03T16-10; r2-p3-t4.2026-10-03T16-11.
P9-T2 step script SCRATCH/steps/r2-p9-t2.ps1 (16-42): CHECKED=1, exit 0.

## P9-T3 check-off of AC-43

AC-43 changed from unchecked to checked in spec.md (checkbox only; criterion text unchanged). Evidence: r2-expect-fail-pester.2026-10-03T16-07 (A824-WT6 and A824-WT11-1 failed on S6, S7, and S8 on the unfixed tree; A824-WT10 and A824-WT11-2 passed) and r2-pass-after-pester.2026-10-03T16-20 (A824-WT6, A824-WT10, A824-WT11-1, A824-WT11-2 passed on S6, S7, and S8; A824-WT3 still allowed, which preserves AC-30; A824-WT4-1 to -5 and A824-WT5-1 to -5 unchanged, which preserves AC-31); r2-p3-t1.2026-10-03T16-11, r2-p3-t2.2026-10-03T16-11, r2-p3-t3.2026-10-03T16-11, r2-p3-t4.2026-10-03T16-11.
P9-T3 step script SCRATCH/steps/r2-p9-t3.ps1 (16-42): CHECKED=1, exit 0.

## P9-T4 AC-42 not checked off by this plan

PENDING AC-42: local criteria verified in r2-ac42-local.2026-10-03T16-24, r2-p5-t1.2026-10-03T16-15, r2-p5-t2.2026-10-03T16-15, r2-p5-t5.2026-10-03T16-17, r2-p5-t6.2026-10-03T16-18, r2-p5-t8.2026-10-03T16-18, r2-shell-qc.2026-10-03T16-39, and fail-before-exception.2026-10-03T16-08. S9 check-off condition: on the PR head's pull_request run of shell-coverage / Shell Coverage (Bats + kcov), whose headSha equals the branch head, the steps Run shell-qc test with coverage, Measure .codex/codex-web-setup.sh coverage with kcov (issue 824), and Gate .codex/codex-web-setup.sh changed-function coverage (issue 824) succeed, and the Gate step log shows six FUNCTION <name> ... PASS lines (one per D7 function: resolve_repo_root, select_solution_file, list_root_solution_files, restore_packages_if_needed, verify_windows_visual_studio_task_capability, write_repo_notes; each pct= at least 85), a CHANGED-LINES=<n> INSTRUMENTED=<m> UNCOVERED-CHANGED=NONE line with n greater than 0, and GATE-FAILED=False. The orchestrator transcribes those lines with the run URL and headSha into FEATURE/evidence/qa-gates/r2-ac42-ci-kcov.<TS>.md (spec AC-42 requires the record under evidence/qa-gates/) and then checks AC-42 off. A run that prints CHANGED-LINES=NOT-CHECKED (a push or workflow_dispatch run) does not satisfy AC-42. If the Gate step fails, the S9 response is the D13 known-risk rule: stop and report the FUNCTION and CHANGED-LINES lines; the threshold, the function list, and the include pattern are not changed.
P9-T4 step script SCRATCH/steps/r2-p9-t4.ps1 (16-42): PENDING-LINES=1 AC42-UNCHECKED=1, exit 0.

## P9-T6 AC-27 pending CI and final checkbox state

AC-27 is not checked off by this plan. It depends on the poshqc / PowerShell QC job (windows-latest, every suite with coverage) and the poshqc / PowerShell hook suites (Linux) job (ubuntu-latest, tests/scripts/claude-hooks and tests/scripts/codex-hooks, coverage disabled) of .github/workflows/_poshqc.yml, and on the rest of the repository CI, on the PR head. AC-27 is checked off at orchestration step S9.
P9-T6 step script SCRATCH/steps/r2-p9-t6.ps1 (16-43, run after every Phase 9 artifact and the spec.md checkbox edits were written): CHECKED=41 OPEN=AC-27,AC-42; host-path re-scan printed no file-name line, HOSTPATH-GREP-EXIT=1, JUNIT-COUNT=0; exit 0.
