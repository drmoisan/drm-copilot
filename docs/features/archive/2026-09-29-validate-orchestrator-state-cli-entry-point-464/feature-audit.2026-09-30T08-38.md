# Feature Audit: Issue #464 (validate-orchestrator-state CLI entry point)

- Timestamp: 2026-09-30T08-38
- Branch: `bug/validate-orchestrator-state-cli-entry-point-exec-464`
- HEAD: `7cf9f1f5`

## Scope and Baseline

- Baseline: merge-base `5b09b53899ac9dad870f855cbcc359098266e213`; pre-execution HEAD `bd8de655d04a41039f50816b92cf524a2c23ab00`
- Work mode: `full-bug`; AC source: `spec.md` `## Acceptance Criteria` (13 items), cross-checked against `issue.md` `## Acceptance Criteria` (8 items)
- Scope: full branch diff against the merge-base.

### Scope Observations

- Out-of-scope items from the spec remained untouched: dispatcher, hooks, `.claude/lib`, `.agents`, `strict_route_membership` flag, adjacent stale SKILL.md text (lines near 191 and 221), `epic-status.md` (optional, not edited).
- PR diff will carry six release-bump paths unless the integration branch is synced with `main` (see policy audit PA-1).
- Possible follow-ups recorded in the spec (dispatcher traceback on missing path; stale SKILL.md statements) are not filed by this change.

## Acceptance Criteria Inventory

- Spec (`spec.md`, `## Acceptance Criteria`): 13 items, evaluated individually below.
- Issue (`issue.md`, `## Acceptance Criteria`): 8 items, evaluated individually below.

## Acceptance Criteria Evaluation

### Spec Acceptance Criteria

| # | Criterion (abridged) | Verdict | Evidence |
|---|---|---|---|
| 1 | `python -m ...validate_orchestrator_state <path>` runs argparse `main()` through `__main__` guard; guard test passes | PASS | Guard at end of `validate_orchestrator_state.py`; `test_validator_module_main_guard_reaches_cli_main` passed in reviewer run (31 passed). |
| 2 | Five flags accepted and forwarded; tests prove True present, False absent | PASS | `build_parser()` declares five `store_true` flags; parametrized `test_main_forwards_flag_true_when_present` plus `test_main_forwards_all_flags_false_when_absent`. |
| 3 | Errors to stderr one per line in order; exit 1 | PASS | `test_main_returns_one_and_writes_each_error_in_order`; reviewer ran invalid checkpoint: exit 1 with error lines on stderr. |
| 4 | Missing, unreadable, or non-UTF-8 path: exit 2, single stderr diagnostic, no traceback; only `OSError` and `UnicodeDecodeError` handled | PASS | Tests for `FileNotFoundError`, `PermissionError`, `IsADirectoryError`, `UnicodeDecodeError`, and `RuntimeError` propagation; code catches the two types only. |
| 5 | Valid checkpoint: exit 0, success line on stdout, empty stderr | PASS | `test_main_returns_zero_and_writes_success_line_for_valid_checkpoint`; reviewer ran `valid-checkpoint.json`: exit 0. |
| 6 | Executed reproduction evidence, before exit 0 and after non-zero with diagnostic | PASS | `evidence/baseline/repro-before-fix.md` (exit 0) and `evidence/other/repro-after-missing-path.md` (exit 2); reviewer re-ran the command and observed exit 2. |
| 7 | Validator at most 500 lines; no new file over 500; count recorded with headroom | PASS | Reviewer `wc -l`: 434, 173, 101, 371. Recorded in `evidence/other/line-counts-final.md`. Headroom 66. |
| 8 | Remediation block moved verbatim; existing tests pass unchanged | PASS | Diff shows identical text in removed and added blocks; `test_validate_orchestrator_state_remediation_loop.py` not in diff and passing. |
| 9 | Validator behavior unchanged; no hook, PowerShell, TypeScript, dispatcher, or #523 change | PASS | Forbidden-surface diff empty (reviewer re-ran); validator diff limited to removal, one import, guard; no `blocked_reason` change. |
| 10 | Coverage line >= 85%, branch >= 75% for the two new modules, dotted names | PASS | CLI: 97.0% line, 100% branch. Remediation loop: 97.2% line, 87.5% branch. Reviewer parsed `artifacts/python/lcov.info`; matches `coverage-new-modules.md`. |
| 11 | Documentation names both CLIs; byte-identical mirrors; no `python -m` or `scripts/...` in any SKILL.md; `.agents` edited only if same text | PASS | Rules: two plan-specified hunks. SKILL.md: two citation replacements. `cmp` reports both pairs identical. No `.agents` change. |
| 12 | Skill-bundle and mirror-parity tests pass after doc edits | PASS (with note) | `skill-bundle-contract-test.md` 1 passed; bundle tests 19 passed isolated. The mirror-parity test passes only when the gitignored #510 state file is moved aside; independent `cmp` and `git hash-object` confirm parity. CI expected to pass. |
| 13 | Full toolchain pass (format, lint, type-check, test) in a single pass | PASS | `qa-loop-summary.md` records one clean pass; reviewer re-ran Ruff and Black check-only (clean) and targeted pytest (31 passed). |

### Issue Acceptance Criteria

| # | Criterion (abridged) | Verdict |
|---|---|---|
| 1 | argparse `main()` via `__main__` guard | PASS |
| 2 | Three named flags passed unchanged | PASS |
| 3 | Errors printed, non-zero exit on non-empty list | PASS |
| 4 | Non-zero exit and diagnostic for missing path | PASS |
| 5 | Exit 0 and empty stderr for valid checkpoint | PASS |
| 6 | Validator under 500 lines; no new file over 500 | PASS |
| 7 | Documentation and mirrors consistent with behavior | PASS |
| 8 | Existing validator behavior and checkpoints unchanged | PASS |

### Deviations Reviewed (classification)

| Deviation | Classification | Basis |
|---|---|---|
| D2: P8-T10 change set lists 11 paths against merge-base (release merge PR #785) | Non-blocking | Against pre-execution HEAD `bd8de655` the diff is exactly the eight expected paths; the extra paths are a release bump (`ac1166db`) that predates execution. Disclosed in plan Implementation Notes item 3. |
| D1: local #510 workaround for the bundle-parity test | Non-blocking | State file moved aside and restored, hash unchanged; CI has no such file; independent byte-identity checks performed. Disclosed in Implementation Notes item 5. |
| Other plan deviations (stale `python -m` premise; `build_complete_small_state` needs `pr_gate`/`ci_gate`; tool equivalents) | Non-blocking | Disclosed in Implementation Notes items 1, 4, 7; none affects an acceptance criterion. |

## Summary

Overall verdict: PASS. All 13 spec criteria and all 8 issue criteria are satisfied. Blocking findings: 0. Deviations D1 and D2 and the other plan deviations are classified non-blocking.

## Acceptance Criteria Check-off

### Acceptance Criteria Status

- Source: `docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464/spec.md` and `issue.md`
- Total AC items: 13 (spec), 8 (issue)
- Checked off (delivered): 13 of 13 (spec), 8 of 8 (issue); all already `[x]` from the executor, each confirmed PASS by this review. No items newly checked by the reviewer.
- Remaining (unchecked): 0
- Items remaining: none. The unchecked Test Strategy items (integration scenario, manual verification notes) are not acceptance criteria; their evidence exists (see policy audit PA-3).
