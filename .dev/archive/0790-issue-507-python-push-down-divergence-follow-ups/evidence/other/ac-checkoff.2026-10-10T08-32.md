# Acceptance-Criteria Check-Off (Phase 8, P8-T1 through P8-T27)

Timestamp: 2026-10-10T08-32
Command: Edit tool, one `- [ ] AC-N ` to `- [x] AC-N ` replacement per checked AC in spec.md; then git grep --no-index -c -F -e "- [x] AC-" -- docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md; git grep --no-index -c -F -e "- [ ] AC-" -- docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md
EXIT_CODE: 0
Output Summary:
- P8-T27 verification: `- [x] AC-` count printed `spec.md:24` (EXIT 0); `- [ ] AC-` count printed `spec.md:2` (EXIT 0). The artifact holds 24 CHECKED and 2 UNCHECKED lines. The counts match and sum to 26. Top-level EXIT_CODE is the last grep's exit code (0, because two ACs remain unchecked; the plan's expected 1 applies only when all 26 are checked).
- Unchecked: AC-22 and AC-24, both caused by the push_down_claude_filesystem.py branch-coverage gap.
- Source: spec.md `## Acceptance Criteria` (full-bug mode; sole AC source). Evidence paths below are relative to FEATURE/evidence/.

AC-1: CHECKED regression-testing/pass-after-python.2026-10-10T08-22.md; qa-gates/pytest-targeted-coverage.2026-10-10T08-25.md (test_constants_match_typescript_values passing in both)
AC-2: CHECKED regression-testing/pass-after-python.2026-10-10T08-22.md (test_push_down_claude_gitignore_merge.py 16 of 16 passing)
AC-3: CHECKED other/p1-t1.2026-10-10T08-07.md (CASES 11 KEYS_OK True); regression-testing/pass-after-python.2026-10-10T08-22.md (test_gitignore_merge_fixture_parity passing). Location per PD3: tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py (spec-permitted fallback for the line limit).
AC-4: CHECKED regression-testing/typescript-fixture-parity.2026-10-10T08-16.md (P2-T3, 12 passed); qa-gates/jest-targeted.2026-10-10T08-28.md (parity suite passing within 4 suites, 53 tests)
AC-5: CHECKED AC-3 and AC-4 evidence above; byte-equality fixture tests pass on both sides
AC-6: CHECKED regression-testing/pass-after-python.2026-10-10T08-22.md (D1, D2, D3 passing)
AC-7: CHECKED regression-testing/pass-after-python.2026-10-10T08-22.md (D4 test_second_push_down_performs_no_gitignore_write passing)
AC-8: CHECKED regression-testing/pass-after-python.2026-10-10T08-22.md (D5 through D8 passing)
AC-9: CHECKED regression-testing/pass-after-python.2026-10-10T08-22.md (D9, D10, D11 passing)
AC-10: CHECKED regression-testing/pass-after-python.2026-10-10T08-22.md (D12 test_gitignore_written_through_raw_fs_with_active_manifest passing)
AC-11: CHECKED regression-testing/expect-fail-python.2026-10-10T08-15.md (D1-D9, D11-D14 listed FAILED); regression-testing/pass-after-python.2026-10-10T08-22.md (all passing); qa-gates/jest-targeted.2026-10-10T08-28.md (existing claude-gitignore-merge and claude-gitignore-delivery suites passing)
AC-12: CHECKED regression-testing/pass-after-python.2026-10-10T08-22.md (D13, D14 passing); qa-gates/docstrings.2026-10-10T08-31.md (first command, exact AC-12 form, exit 0)
AC-13: CHECKED regression-testing/pass-after-python.2026-10-10T08-22.md (F1, F2 passing)
AC-14: CHECKED regression-testing/expect-fail-python.2026-10-10T08-15.md (F3 test_push_down_excludes_claude_state_and_worktrees_subtrees FAILED); regression-testing/pass-after-python.2026-10-10T08-22.md (passing)
AC-15: CHECKED regression-testing/pass-after-python.2026-10-10T08-22.md (F4, F5, F6 passing)
AC-16: CHECKED other/p4-t2.2026-10-10T08-19.md (PASS); qa-gates/jest-targeted.2026-10-10T08-28.md (adapter suite 29 tests including T1-T6 passing)
AC-17: CHECKED regression-testing/pass-after-python.2026-10-10T08-22.md (test_local_runtime_directories_match_typescript and test_local_runtime_directories_comparison_detects_divergence passing)
AC-18: CHECKED qa-gates/pytest-targeted-coverage.2026-10-10T08-25.md (pack-selection 19 and pack end-to-end 6 passing); qa-gates/ac18-extraction.2026-10-10T08-31.md (PASS). PD2 narrowing: the directory-wide grep for `def _resolve_published_paths` under scripts/dev_tools still matches scripts/dev_tools/push_down_codex_and_agents_customizations.py, which AC-20 requires unchanged; the removal is asserted against scripts/dev_tools/push_down_claude_customizations.py (no match).
AC-19: CHECKED qa-gates/line-counts.2026-10-10T08-30.md (maximum 489; every count at most 500)
AC-20: CHECKED qa-gates/scope-unchanged-files.2026-10-10T08-30.md (diff against BASE_SHA and porcelain both empty); P9-T3 re-confirms the exact spec form after the commit
AC-21: CHECKED qa-gates/scope-surfaces.2026-10-10T08-31.md (diff and porcelain empty; resource-contract pytest 14 passed)
AC-22: UNCHECKED qa-gates/python-coverage-values.2026-10-10T08-25.md and qa-gates/python-coverage-delta.2026-10-10T08-29.md: scripts/dev_tools/push_down_claude_filesystem.py final BRANCH 64.29 is below the 75 threshold (final LINE 88.5 meets 85; baseline LINE 83.18 / BRANCH 57.69). Changed-line coverage is 100.0 for all three modified modules and the other three modules meet both thresholds. No tests were added in this run per the orchestrator directive; remediation is deferred to an orchestrator remediation cycle.
AC-23: CHECKED other/p4-t4.2026-10-10T08-20.md (threshold entry PASS); qa-gates/jest-coverage.2026-10-10T08-28.md (exit 0, no threshold failure); qa-gates/typescript-coverage-delta.2026-10-10T08-30.md (96.99 line / 89.55 branch)
AC-24: UNCHECKED P8-T24 requires P6-T1 through P6-T6 to pass in the final loop iteration; P6-T5 (qa-gates/python-coverage-values.2026-10-10T08-25.md) did not meet its branch threshold for push_down_claude_filesystem.py. Every command AC-24 itself names exited 0 with no PRE-EXISTING ONLY outcome (qa-gates/black-check.2026-10-10T08-24.md, ruff-check.2026-10-10T08-24.md, pyright.2026-10-10T08-25.md, pytest-targeted-coverage.2026-10-10T08-25.md, pytest-push-down-wide.2026-10-10T08-26.md); the gap is the P6-T5 coverage gate only and closes with the AC-22 remediation.
AC-25: CHECKED qa-gates/prettier.2026-10-10T08-27.md (format script run, 509 lines all unchanged, hashes identical); qa-gates/eslint.2026-10-10T08-27.md; qa-gates/tsc.2026-10-10T08-28.md; qa-gates/jest-targeted.2026-10-10T08-28.md (all loop iteration 1)
AC-26: CHECKED qa-gates/docstrings.2026-10-10T08-31.md (D3_LINE_LIMIT True, ENTRY_DELIVERY True). The feature-review inspection named in AC-26 remains with the orchestrator (PD10).
