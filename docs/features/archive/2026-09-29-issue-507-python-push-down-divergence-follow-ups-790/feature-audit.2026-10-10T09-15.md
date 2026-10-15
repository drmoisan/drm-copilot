# Feature Audit: Issue #790 Python Push-Down Divergence Follow-Ups (Remediation Cycle 1 Re-Audit)

- Review timestamp: 2026-10-10T09-15
- Work mode: `full-bug` (marker `- Work Mode: full-bug` in `issue.md`)
- AC source: `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`, `## Acceptance Criteria` (AC-1 through AC-26). No `user-story.md` applies in `full-bug` mode.
- Prior review: `feature-audit.2026-10-10T08-46.md` (25 PASS, AC-22 FAIL as written, blocking finding FA-B1)

## Scope and Baseline

- Branch: `bug/issue-507-python-push-down-divergence-follow-ups-790` at `ef71184a525f40e28cba2642efc2cfa6f262ae86`.
- Base: `origin/main` at `7bbd0b9b990737642b4eeded01a27b7c5c8348b3`.
- Diff: `git diff 7bbd0b9b990737642b4eeded01a27b7c5c8348b3...HEAD`. Delta since the prior review (`0f28f1398..HEAD`): 48 files; the only non-documentation change is `tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py` (+57 lines).
- PR context artifacts were stale and were regenerated for this head.
- CI: not run (no PR exists). No AC in `spec.md` depends on CI; this is not a finding.

## Closure of Prior Blocking Finding FA-B1

Status: **CLOSED**.

| Check | Result |
|---|---|
| Required change: tests only, in a file the Test Strategy command already runs | Met. Four parametrized cases in `test_push_down_claude_pack_end_to_end.py` (a file named in the command); no production file changed (`remediation-scope.2026-10-10T09-10.md`; reviewer diff stat). |
| Cases required: `skip`; `merge` with destination present and absent; `merge` with `destination_root=None` | Met. Case ids: `skip-drops-general-memory`, `merge-drops-memory-present-at-destination`, `merge-keeps-memory-absent-at-destination`, `merge-without-destination-root-keeps-memory`. Reviewer read the production branches (`push_down_claude_filesystem.py:406-414`) and each case reaches a distinct return path. |
| Target: at least 21 of 28 branches under the Test Strategy command | Met. 22 of 28 (78.57%). Reviewer independently re-ran the literal spec command (without the executor's extra parity file) with `COVERAGE_FILE` in the scratchpad: 100 passed; filesystem module 113 statements, 8 missed (122, 128, 135, 145, 148, 182-183, 326), 28 branches, 6 partial = 92.92% line, 78.57% branch. Lines 407 and 409-414 are no longer missing. |
| Other three modules unchanged and above thresholds | Met. gitignore_merge 100.0/100.0; customizations 93.67/87.5; pack_selection 93.98/83.33 (reviewer run and `remediation-python-coverage-values.2026-10-10T09-07.md`). |
| No regression on changed lines | Met. 100% changed-line coverage in the three modified modules (`remediation-python-coverage-delta.2026-10-10T09-07.md`). |
| Toolchain loop in order, single pass | Met. Black 585 unchanged, Ruff clean, Pyright 0 errors, targeted pytest 101 passed, wide pytest 585 passed (baseline 581 + 4), all iteration 1. Reviewer re-ran Black, Ruff, and Pyright on the edited file: clean. |
| AC-19 re-confirmed for the edited test file | Met. 447 lines (reviewer `wc -l`); maximum across tracked files 489. |
| AC-24 re-confirmed on the post-remediation tree | Met. The final loop was run after the last code commit (`2d060aaf6`, 09:06:17); later commits are documentation only. |

## Acceptance Criteria Inventory

| AC | Summary | State at review start | State after review |
|---|---|---|---|
| AC-1 | New merge module with four constants and two functions | checked | checked |
| AC-2 | Merge semantics, each scenario a named test | checked | checked |
| AC-3 | Shared fixture; Python byte-equality parity test | checked | checked |
| AC-4 | TypeScript parity test over the same fixture | checked | checked |
| AC-5 | Managed block lists exactly two entries | checked | checked |
| AC-6 | Python delivery, unscoped and pack-scoped | checked | checked |
| AC-7 | Second run performs no `.gitignore` write | checked | checked |
| AC-8 | Manifest skip behavior | checked | checked |
| AC-9 | Delivery ordering and summary exclusion | checked | checked |
| AC-10 | Write through raw `fs` | checked | checked |
| AC-11 | Removing the merge on either side fails a test | checked | checked |
| AC-12 | CRLF limitation D2 | checked | checked |
| AC-13 | Python runtime-directory constant and predicate | checked | checked |
| AC-14 | Runtime-directory files neither written nor listed | checked | checked |
| AC-15 | Lookalikes, general memory, outside-root retained | checked | checked |
| AC-16 | TypeScript constant and predicate | checked | checked |
| AC-17 | Static parity test plus negative self-test | checked | checked |
| AC-18 | `resolve_published_paths` extraction | checked | checked |
| AC-19 | Every written file <= 500 lines | checked | checked |
| AC-20 | Seven named files unchanged | checked | checked |
| AC-21 | No bundled mirror or customization surface changed | checked | checked |
| AC-22 | Python coverage >= 85/75 for four modules under the Test Strategy command | checked (remediation) | checked (confirmed) |
| AC-23 | Jest per-file threshold; `test:coverage` passes | checked | checked |
| AC-24 | Python toolchain single pass | checked | checked |
| AC-25 | TypeScript toolchain single pass | checked | checked |
| AC-26 | Docstrings state D3 placement and post-copy delivery | checked | checked |

## Acceptance Criteria Evaluation

AC-1 through AC-21, AC-23, AC-25, and AC-26 keep their PASS verdicts from `feature-audit.2026-10-10T08-46.md`. This cycle changed no production, TypeScript, config, or fixture file, so the prior evidence for those criteria still describes the code at HEAD. Specific re-checks made in this cycle:

| AC | Verdict | Evidence and notes |
|---|---|---|
| AC-19 | PASS | Maximum per-file count is 489 (`push_down_claude_filesystem.py`); the edited test file is 447 (`evidence/qa-gates/remediation-line-counts.2026-10-10T09-10.md`, reviewer `wc -l`). |
| AC-20 | PASS | No path among the seven protected files appears in the diff since the prior review (`evidence/qa-gates/remediation-scope.2026-10-10T09-10.md`). |
| AC-21 | PASS | No mirror or customization surface changed this cycle (same artifact). |
| AC-22 | PASS | Filesystem 92.92% line / 78.57% branch, gitignore_merge 100.0/100.0, customizations 93.67/87.5, pack_selection 93.98/83.33, all at or above 85/75 under the Test Strategy command (executor evidence and reviewer re-run). Changed-line coverage 100% against the baseline (`remediation-python-coverage-delta.2026-10-10T09-07.md`); filesystem baseline 88.5/64.29 improved by +4.42/+14.28. |
| AC-24 | PASS | Every named command exited 0 in one iteration after the last code change (`evidence/qa-gates/remediation-ac24-reconfirm.2026-10-10T09-10.md`, which cites the five recorded outputs). The reconfirm record is derived from recorded artifacts, not a fresh run; this is acceptable because no code changed after the loop. |

## AC Check-off State Verification

- `spec.md`: 26 lines match `^- [x] AC-`; 0 lines match `- [ ]` (reviewer grep).
- `git diff 0f28f1398..HEAD -U0 -- spec.md`: exactly one line changed, AC-22 from `- [ ]` to `- [x]`, with identical criterion text on both sides (`evidence/qa-gates/remediation-spec-diff.2026-10-10T09-10.md`; the reviewer's diff stat shows `spec.md | 2 +-`).
- The AC-22 check-off is evidence-backed: it follows the 09:07 coverage values, the delta record, and the P4-T1 record, and the reviewer reproduced the numbers.
- AC-24 was checked at the prior review; the post-remediation reconfirmation holds. No criterion was checked without evidence and none was left unchecked despite evidence.
- `plan.2026-10-08T13-56.md` changed on three task lines (P6-T5, P7-T1, P8-T22); task text preserved with remediation pointers appended.

## Findings

### Blocking

None. Blocking findings: 0.

### Non-blocking

- **FA-N1 to FA-N4:** carried over unchanged from `feature-audit.2026-10-10T08-46.md` (AC-18 wording, non-canonical spec evidence paths, AC-26 check-off timing, Test Strategy command scope). None gates merge. FA-N4 is now resolved in practice: the remediation tests make the literal Test Strategy command reach the thresholds.
- **FA-N5 (timestamp deviation, classification requested).** Some remediation artifact filenames carry composed, not clock-read, timestamps. Evidence: `remediation-line-counts.2026-10-10T09-10.md` has mtime 09:08:29 and its content was committed in `35b9de2d8` at 09:08:01 to 09:09:13; `rem-p3-t4.2026-10-10T09-11.md` has mtime 09:09:10; `rem-p4-t1.2026-10-10T09-09.md` and `rem-p2-t8.2026-10-10T09-09.md` are within a minute of their mtimes; other `rem-*` and `remediation-*` files carry names one to three minutes ahead of the write time. All names are inside the 09:02 to 09:11 run window and monotonic with the plan order. Classification: **Non-blocking process deviation** from the evidence-and-timestamp conventions (timestamps must be read from the clock). Impact: none on any AC verdict; no artifact asserts an event order that the real timestamps contradict. Not remediated, because renaming would break the cross-references recorded in `rem-ac-checkoff.2026-10-10T09-10.md` and the plan pointers. Recommendation: future executors read the clock for each artifact name.
- **FA-N6 (pre-existing uncovered branches).** Six filesystem branches remain uncovered (lines 122, 128, 135, 145, 148, 182-183, 326); all are pre-existing and above threshold. Optional follow-up.

## Summary

- 26 acceptance criteria evaluated: 26 PASS (AC-18 with the documented narrowing carried over from the prior review).
- FA-B1 is closed from evidence and from an independent re-measurement of the Test Strategy command.
- No new defect was introduced by the remediation: the only code change is one test, which passes Black, Ruff, and Pyright and exercises real production branches.
- Policy verdict: PASS (see `policy-audit.2026-10-10T09-15.md`). Code review: APPROVE (see `code-review.2026-10-10T09-15.md`).
- Overall feature verdict: **PASS**. Blocking findings: 0. Remediation inputs are not required.

## Acceptance Criteria Check-off

- Newly checked off by this review: none.
- Confirmed and retained: AC-1 through AC-26.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`
- Total AC items: 26
- Checked off (delivered): 26
- Remaining (unchecked): 0
- Items remaining: none
