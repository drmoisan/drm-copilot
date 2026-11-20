# Feature Audit: cleanup preserve copies an older snapshot over newer main (#1027)

**Audit Date:** 2026-11-03
**Feature Folder:** `docs/features/active/2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main-1027`
**Base Branch:** `main`
**Head Branch:** `bug/cleanup-preserve-older-snapshot-1027-r2`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main`, commit `715241396b557ce198e44f5c4b606fbcd9082c3c`)
- **Head branch/commit:** `bug/cleanup-preserve-older-snapshot-1027-r2` (commit `ca69ec5c5b030e76494ccdcbeaffa2f3cd74175e`)
- **Merge base:** `715241396b557ce198e44f5c4b606fbcd9082c3c`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-03 13:16:19 UTC for head `ca69ec5c5`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main-1027/evidence/**`
  - Additional evidence: reviewer reads of the source diff, the `cov.xml` of CI run 41640864723 (`gh run download 41640864723 -n shell-coverage`), reviewer `cmp` of mirrors, and reviewer `grep` checks on the stub and wrapper
- **Feature folder used:** `docs/features/active/2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main-1027`
- **Requirements source:** `spec.md` (`## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`, so `spec.md` is the sole AC source. The checkboxes in `issue.md` (`## Logs / Screenshots`, `## Impact / Severity`) are issue-template fields, not acceptance criteria.
- **Scope note:** the latest CI coverage run (41640864723) measured head `456b9da17`. `git diff --name-only 456b9da17 HEAD` lists only feature-folder documentation and evidence, so its test and coverage results apply to the review head. No PR exists yet; the PR-head `ci.yml` run is the orchestrator's S9 gate and is not an acceptance criterion here.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main-1027/spec.md` — only source

### Acceptance criteria

1. Issue repro fixed: when a `modified` record's target exists and `main`'s version contains lines absent from the older worktree snapshot, the pass never writes a file that omits any of `main`'s lines. The record either stages merged content containing every `main` line (`OK`) or emits `ACTION|preserve-stage|<tgt>|REFUSED-WOULD-REGRESS`.
2. Clean or union merge: for a `modified` record with an available base where G1, G2, and G3 pass, the plan entry has mode `merge` with the merged blob oid. Phase 2 writes the blob via `cat-file blob <oid>`. The staged content equals `main`'s version plus only the worktree's added lines, including the case where both sides appended at end of file.
3. Addition already on main: a `modified` record whose worktree additions are already present on `main` produces `OK` with merged content equal to `main`'s version.
4. G1 refusal: a `modified` record whose worktree file is not a line-superset (in order) of the base emits `ACTION|preserve-stage|<tgt>|REFUSED-WOULD-REGRESS`.
5. Merge-error refusal: a `merge-file` non-zero exit or usage error (simulating Git older than 2.43) emits `REFUSED-WOULD-REGRESS`, and the stderr diagnostic names the git exit code.
6. G2 and G3 refusals: a merged result missing any `main` line (G2), or containing a line not among the worktree's additions such as a resurrected base line (G3), emits `REFUSED-WOULD-REGRESS`.
7. Base-unavailable fallback: for each cause (no worktree `HEAD`, no merge base, file absent at the base, `source_path` differing from `target_path`), a record is copied verbatim with `OK` when `main` is a line-subsequence of the source, and emits `REFUSED-WOULD-REGRESS` otherwise.
8. Refusal side effects: every `REFUSED-WOULD-REGRESS` case still emits the preceding `PRESERVE|` record, writes a `cleanup-worktrees:` stderr diagnostic naming the failed guard, and sets `PRESERVE_EXIT=1` so the pass exits 1. It appends no plan-stream entry, emits no `ACTION|preserve-index` record, and performs no index append.
9. Absent target unchanged: `untracked` and `modified` records whose target is not a regular file are copied verbatim with `OK`, and the decision issues no git call (asserted on the stub argv log).
10. Untracked with existing target: an `untracked` record whose target is a regular file is copied with `OK` only when `main` is a line-subsequence of the source, and otherwise emits `REFUSED-WOULD-REGRESS`.
11. Duplicate target: a second record in the same pass with a `target_path` already seen emits `REFUSED-WOULD-REGRESS`, and only the first record reaches the plan stream.
12. CRLF and terminator tolerance: line comparisons strip one trailing carriage return per line, and count an unterminated final line, demonstrated by bats tests with CRLF content built inline.
13. Phase-1 write exception documented: the `preserve_plan` header and the library header comments state that planning writes only unreferenced blob objects (`hash-object -w`, `merge-file --object-id`) and touches no index, ref, or working-tree file.
14. Existing preserve bats suites pass unchanged in outcome: `test_cleanup_worktrees_preserve.bats`, `test_cleanup_worktrees_preserve_eol.bats`, `test_cleanup_worktrees_preserve_failures.bats`, and the preserve tests in `test_cleanup_worktrees_scan_roots.bats` and `test_cleanup_worktrees_dirt_clear.bats`. The `modified` test comment is rewritten to describe the absent-target copy.
15. Fail-before evidence recorded: the issue repro test was run against the unchanged library, and its failing result is recorded under `evidence/regression-testing/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
16. Bundle mirrors and manifest updated: the new library and the edited `SKILL.md`, `cleanup-worktrees.sh`, and `cleanup_worktrees_preserve_lib.sh` are byte-identical in the bundle, and `core.json` lists the new library. `test_push_down_claude_resource_contracts.py` and `test_push_down_claude_pack_manifest_completeness.py` pass.
17. Documentation updated: `SKILL.md` contains a subsection that enumerates the full `ACTION|preserve-stage` vocabulary including `REFUSED-WOULD-REGRESS` and describes per-`change_class` staging. The `cleanup-worktrees.sh` `usage` text no longer describes preserve mode as an unconditional verbatim copy. The `preserve_validate_record` comment no longer says `change_class` does not affect staging. `merge_queue_documentation_expectations.py` assertions still pass.
18. Git stub comments corrected: the stub header no longer cites production line numbers or states that no `-w` behavior exists.
19. Shell QC passes: `bash scripts/bash/shell-qc.sh check` (shfmt and shellcheck) and `bash scripts/bash/shell-qc.sh test --coverage` (bats with kcov) pass. The aggregate line coverage stays at or above 85%, and `cleanup_worktrees_preserve_merge_lib.sh` reaches at least 85% line coverage per the recorded `cov.xml`.
20. File-size tiers respected: no changed or new production file exceeds 500 logical lines without a recorded justification, no file reaches 801 lines, and `tests/fixtures/cleanup_worktrees/stub-bin/git` stays below 500 lines.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Issue repro fixed | PASS | Test `an older modified snapshot never overwrites newer main lines` (`merge-repro`) asserts no refusal and a `merge` plan entry with `merged01`; fail-before run printed `plan entry columns: 8, mode: ''`; pass-after 116/116. Every existing-target path either stages a blob that passed G2 (all main lines present) or refuses. | `npx --yes bats --filter 'older modified snapshot' tests/shell/test_cleanup_worktrees_preserve_merge.bats` (executor, before and after) | Code inspection of `preserve_merge_decide` confirms no existing-target path copies without guard (b) or G2. See the code review's Minor finding for the unreadable-target edge case, which lies outside this criterion's scenario. |
| 2 | Clean or union merge | PASS | Tests `a clean merge plans the merged blob in merge mode`, `both sides appending at end of file is merged with OK`, `a merge-mode plan entry writes the merged blob through cat-file`; `preserve_commit_plan` merge branch writes `cat-file blob "$oid"`. | CI run 41640864723 (`bash scripts/bash/shell-qc.sh test --coverage`, 761 ok) | Staged content equality is established by the fixture shapes (`cat-file.merged01.out` equals main plus the worktree lines) together with G2/G3. |
| 3 | Addition already on main | PASS | Test `an addition already on main merges to main content` (`cmp` of merged blob fixture with main's version, then `OK` from the writing phase). | CI run 41640864723 | |
| 4 | G1 refusal | PASS | Test `a worktree that deleted a base line is refused by G1`; asserts no `merge-file` or `hash-object` call. | CI run 41640864723 | |
| 5 | Merge-error refusal | PASS | Test `a merge-file error is refused and names the git exit code` asserts `cleanup-worktrees: refused notes/n.md: merge-file rc=129`. | CI run 41640864723 | rc 129 is Git's usage-error code, simulating Git older than 2.43. |
| 6 | G2 and G3 refusals | PASS | Tests `a merged result missing a main line is refused by G2` and `a resurrected base line is refused by G3`; helper test `extra_within rejects a resurrected base line and counts duplicates`. | CI run 41640864723 | |
| 7 | Base-unavailable fallback | PASS | Tests `no worktree HEAD falls back to guard-b`, `no merge base falls back to guard-b`, `a file absent at the merge base falls back to guard-b`, `a renamed target falls back to guard-b without resolving a base`; each asserts `notes/ok.md` planned as `copy` and `notes/bad.md` refused. | CI run 41640864723 | |
| 8 | Refusal side effects | PASS | `merge_assert_refused` and `fallback_assert_ok_and_bad` assert the `PRESERVE|` record, the stderr reason, `PRESERVE_EXIT` 1, the plan-stream length, and the absence of `ACTION|preserve-index`; refusal scenarios carry a non-null `memory_index_line` so an index decision would be visible. | CI run 41640864723 | Exit 1 follows from the existing `run_preserve` mapping of `PRESERVE_EXIT`. |
| 9 | Absent target unchanged | PASS | Test `an absent target is copied with no decision git call` for `modified` and `untracked` asserts no `merge-file`, `hash-object`, `merge-base`, or `rev-parse` in the stub argv log and column 9 `copy`. | CI run 41640864723 | |
| 10 | Untracked with existing target | PASS | Test `an untracked record with an existing target is guarded by guard-b` (both outcomes, no base resolution). | CI run 41640864723 | |
| 11 | Duplicate target | PASS | Test `a duplicate target_path in one pass is refused after the first` asserts one plan entry (`notes/a.md`) and the `duplicate-target` refusal. | CI run 41640864723 | |
| 12 | CRLF and terminator tolerance | PASS | Tests `is_subsequence strips one trailing carriage return per line` and `is_subsequence counts an unterminated final line` with inline `$'...'` content. | CI run 41640864723 | Exercised at helper level; see the code review Nit. |
| 13 | Phase-1 write exception documented | PASS | `preserve_plan` header, `preserve_plan_one` header, the preserve library file header, and the merge library header each state the unreferenced-blob exception. | `git diff 715241396...HEAD -- .claude/skills/cleanup-merged-worktrees/scripts/` (reviewer) | |
| 14 | Existing preserve suites pass unchanged in outcome | PASS | Pass-after per-file counts: preserve 26, preserve_eol 6, preserve_failures 13 (11 baseline plus 2 added), scan_roots 21, dirt_clear 15; CI 761 ok. `modified` test comment rewritten (diff of `test_cleanup_worktrees_preserve.bats`). | `npx --yes bats <eight suites>` (executor); CI run 41640864723 | |
| 15 | Fail-before evidence recorded | PASS | `evidence/regression-testing/fail-before-repro.2026-11-03T12-35.md` has `Timestamp:`, `Command:`, `EXIT_CODE: 1`, and `Output Summary:`. | Reviewer read of the artifact | |
| 16 | Bundle mirrors and manifest updated | PASS | Reviewer `cmp` of four source/mirror pairs: identical. `core.json` lists the new library after `cleanup_worktrees_preserve_lib.sh`. Contract tests 66 passed. | `cmp <src> <mirror>` (reviewer); `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py ...` (executor) | |
| 17 | Documentation updated | PASS | `SKILL.md` `### Preserve staging outcomes` lists all eight results and per-class staging; `grep -c -F 'Copies each named source file'` on the wrapper prints 0; `preserve_validate_record` comment rewritten; `test_merge_procedure_records_merge_only_after_confirmation[claude-cleanup-merged-worktrees]` passed. | `grep -c -F 'Copies each named source file' .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh` (reviewer) | |
| 18 | Git stub comments corrected | PASS | `grep -c -E '_lib[.]sh:[0-9]'` prints 0; `grep -c -F 'defines no -w'` prints 0. | Both greps on `tests/fixtures/cleanup_worktrees/stub-bin/git` (reviewer) | |
| 19 | Shell QC passes | PASS | `shell-qc.sh check` clean locally and in CI; CI `1..761`, 0 `not ok`; `cov.xml` aggregate 0.953; `cleanup_worktrees_preserve_merge_lib.sh` 0.990. | `gh run download 41640864723 -n shell-coverage` and read of `cov.xml` (reviewer) | |
| 20 | File-size tiers respected | PASS | Logical lines at head: merge lib 234, preserve lib 500, wrapper 256, stub 451, largest bats 478. No production file exceeds 500; none reaches 801. | `awk 'END{print NR}' <file>` per file (reviewer) | `cleanup_worktrees_preserve_lib.sh` sits exactly at 500, which does not exceed the limit. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 20 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Run the PR-head `ci.yml` workflow after the PR is opened (orchestrator S9 gate).
2. Confirm `git --version` on `ubuntu-latest` and other operator hosts is 2.43 or later, as the spec's rollout section lists; an older Git refuses merges rather than losing lines.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 20 criteria in `spec.md` were already checked off by the executor before this review. Each was independently re-evaluated above as PASS, so no checkbox change was made and none was required.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main-1027/spec.md`
- Total AC items: 20
- Checked off (delivered): 20
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main-1027/spec.md` | 20 | 20 | 0 | Checkbox-backed; sole source for `full-bug` |
