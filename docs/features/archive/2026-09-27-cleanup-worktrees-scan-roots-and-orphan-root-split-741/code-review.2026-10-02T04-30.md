# Code Review: cleanup-merged-worktrees scan roots and orphan-root split (#741)

**Review Date:** 2026-10-02
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741`
**Feature Folder Selection Rule:** the only active feature folder whose suffix matches the issue number in the branch name (`-741`).
**Base Branch:** `origin/main` (merge base `71f8dcb49d8ce5d1402ff441855a64be15b37f29`; `origin/main` was merged into the branch as `df5eb303`)
**Head Branch:** `bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741` at `5c783c066abb505ade1b1e7902a679c74bced84b`
**Review Type:** Initial review (review pass 1)

---

## Executive Summary

The branch changes five bash scripts and `SKILL.md` in the `cleanup-merged-worktrees` skill (plus six byte-identical bundle mirrors), adds one bats suite with 16 tests and one fixture, and refactors one existing bats file. Production delta: +174/-6 lines in the enumeration library, -37 net in the report-records library, one-line changes in the preserve library and scan helper, and usage/documentation text. Evidence reviewed: the full `origin/main...HEAD` diff, the regenerated PR context, the feature-folder evidence index, four cited CI runs (conclusions and head SHAs verified with `gh run view`), the final CI log (`1..521`, zero `not ok`), and the baseline and final kcov `cov.xml` artifacts, which this review downloaded and compared.

The implementation is small, documented, and consistent with the binding Scope Decisions in `issue.md`. The override splitter walks characters without word splitting, so no pathname expansion occurs. The derivation excludes the main worktree, its ancestors, and paths equal to or inside a registered worktree, with prefix checks anchored on `/`. The hard-failure contract of the old function (no bare relative root) is preserved and extended to the override case. One shared absolute-path predicate replaces two duplicates.

**What changed:**
- `cleanup_worktrees_enumerate_lib.sh`: new `cleanup_wt_is_absolute_path` (257-271), `cleanup_wt_split_roots` (273-317), `cleanup_wt_derive_scan_roots` (319-372), and `cleanup_wt_scan_roots` (374-416), the latter moved from the report-records library and extended with derived roots.
- `cleanup_worktrees_report_records_lib.sh`: old `cleanup_wt_scan_roots` removed; comments point to the new location. `classify_all_branches` and `run_report_scans` are unchanged.
- `cleanup_worktrees_preserve_lib.sh:161` and `cleanup_worktrees_scan_helper.sh:105` call the shared predicate; the scan helper sources the enumeration library (line 45).
- Wrapper usage text and `SKILL.md` describe the separator contract, the override rule, and derived-root exclusions.
- Tests: `test_cleanup_worktrees_scan_roots.bats` (new); `test_cleanup_worktrees_scan_helper.bats` uses one `run_helper_sourced` helper.

**Top 3 risks:**
1. Derived candidates are not checked with `cleanup_wt_is_absolute_path`; a worktree directly under a second drive's root would yield a drive-relative root such as `D:` (Minor, advisory-only output).
2. The scan helper now depends on the enumeration library being co-located; the pack manifest (`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`) ships both, so this holds for the bundled layout.
3. A stale cross-file line reference in `cleanup_worktrees_detached_lib.sh:46` may mislead a future reader (Minor, documentation only).

**PR readiness recommendation:** **Go** — no Blocker or Major finding; every gate is verified by local re-runs or by CI artifacts this review inspected directly.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh` (and mirror) | line 46 | The comment cites `cleanup_worktrees_enumerate_lib.sh:115-116` for the `DETACHED` branch-field write; the enumeration header grew by three lines, so the cited lines are now 118-119. Non-blocking. | Update the reference to `:118-119`, or replace the line number with the function name (`emit_record` in `parse_worktree_list`) so it does not drift. | Line-number references silently go stale on unrelated edits. | Diff hunk `@@ -4,16 +4,19 @@` in enumerate_lib; current lines 118-119 read `local branch_field="DETACHED"` / `[[ -n $branch ]] && branch_field=$branch`. |
| Minor | `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh` (and mirror) | lines 43-45 | `# shellcheck disable=SC1091` has no inline reason; `.claude/rules/shell.md` permits suppressions only with the reason stated. Non-blocking: the paired `# shellcheck source=` names the target and the bare form has more than ten existing precedents. | Add one comment line, for example `# The library path is resolved at runtime from BASH_SOURCE, so SC1091 is the expected result.` | Keeps the suppression self-justifying, as `cleanup-worktrees.sh:11-12` does. | `shellcheck` exit 0; Grep of `shellcheck disable=SC1091` across `scripts/bash`, `.claude/skills`, `.claude/lib/bash`. |
| Minor | `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh` | lines 348-353 | Derived candidates are not validated with `cleanup_wt_is_absolute_path`. For a registration such as `D:/wt` on a drive other than the main worktree's, `parent` becomes `D:`, which is drive-relative, and it passes the exclusion checks. Override entries receive this validation; derived ones do not. Non-blocking. | Add `cleanup_wt_is_absolute_path "$parent" \|\| continue` before normalization, and a fixture entry for a drive-root registration. | Keeps the "no relative root" invariant uniform across both root sources. The output is advisory and read-only, so the current impact is an extra scan of the drive's current directory. | Code inspection of `cleanup_wt_derive_scan_roots`; `[[ -z $parent \|\| $parent == "$p" ]]` only skips empty and slash-less paths. |
| Nit | `tests/shell/test_cleanup_worktrees_scan_roots.bats` | n/a | No test supplies a backslash-form registration path (`C:\x\y`) to the derivation, so the `${paths[i]//\\//}` conversion on enumerate_lib line 348 is exercised only with forward-slash input. Non-blocking. | Add one `worktree-list.out` scenario with a backslash path and assert the emitted parent. | The Windows path form is the motivating case for this issue. | Fixture `scan_roots_derived/worktree-list.out` uses only `/`-separated paths. |
| Info | `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh` | line 370 | kcov reports `hits=0` for the `done < <(printf ... \| LC_ALL=C sort ...)` terminator while the loop body (line 369) is hit. Changed-line coverage is 79/80. | None required. | Most likely a kcov attribution effect on process-substitution lines. | Baseline/final `cov.xml` comparison (runs 36978610292, 36982722154). |
| Info | `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh`, `cleanup_worktrees_scan_helper.sh` | file level | Per-file line rates fell (0.890 -> 0.879; 0.875 -> 0.873). This review confirmed that the set of uncovered source lines is identical in baseline and final for both files (20 and 7 lines); the drop comes only from removing covered lines. Both remain above 85%. | None required. | Confirms no coverage regression on changed lines. | Scratchpad comparison of the two downloaded `cov.xml` artifacts. |

No Blocker or Major findings.

---

## Implementation Audit

### Bash implementation audit

#### What changed well

- `cleanup_wt_split_roots` walks the value one character at a time and never word-splits, so `*` is kept literally and `IFS` is not modified. The drive-letter rule (`${#entry} -eq 1 && $entry == [A-Za-z] && $next == [/\\]`) matches the Scope Decision exactly and keeps existing `:`-separated lists working.
- `cleanup_wt_derive_scan_roots` compares normalized paths with `/`-anchored prefix checks (`$n == "$w"/*`, `$main_norm == "$n"/*`), so `/repo/main-wt/a-wt` is not treated as inside `/repo/main-wt/a`; the fixture asserts this.
- `cleanup_wt_scan_roots` reads the listing once (`out=$(parse_worktree_list) || rc=$?`), keeps the earlier "no bare relative root" guarantee on hard failure, and emits exactly the override roots in that case, as AC-4 requires.
- Deduplication handles the `/` root, which normalizes to an empty string, by mapping it to `/` before using it as an associative-array key.
- The predicate consolidation leaves one definition (`enumerate_lib:257`) and two call sites; the old helper name has no remaining reference in the canonical tree, the mirror, or `tests/shell`.

#### API and safety notes

- All new functions return 0 and write only to stdout/stderr; they perform no filesystem access. The single filesystem scan stays behind `CLEANUP_WT_SCAN_BIN`.
- Associative arrays (`local -A`) follow existing usage in the same libraries, so no new bash-version requirement is introduced.
- The sourcing-order contract in the enumeration header now documents that the scan helper sources it directly.

#### Error handling and logging

- A relative override entry is dropped with a single stderr line naming the entry, rather than being resolved against the current directory.
- A `parse_worktree_list` failure still degrades to silence for the advisory records, matching `check_main_freshness`'s never-blocking contract.

---

## Test Quality Audit

The new suite covers each AC behavior with a dedicated test and uses the existing git and scan stubs. Fail-before evidence exists: CI run 36979697644 on `48c6023d` (tests and fixture only) failed with 14 of 16 new tests `not ok`, the two passing tests being the predicate tests that hold for the old inline form. Pass-after evidence: runs 36981519472 and 36982722154, both `1..521` with zero `not ok`.

### Reviewed test and QA artifacts

- `tests/shell/test_cleanup_worktrees_scan_roots.bats` — 16 tests across root composition, separator contract, single-scan reporting, and the shared predicate; assertions check exact ordered lines.
- `tests/shell/test_cleanup_worktrees_scan_helper.bats` — one `run_helper_sourced` loader with the kcov rationale stated once; `load_helper` count is 0.
- `tests/fixtures/cleanup_worktrees/scenarios/scan_roots_derived/worktree-list.out` — ten registrations covering every exclusion class, a case-variant duplicate, a default-root duplicate, and a prefix-boundary case.
- `evidence/regression-testing/expect-fail-scan-roots.2026-10-02T03-47.md`, `evidence/regression-testing/pass-after-scan-roots.2026-10-02T04-06.md` — fail-before and pass-after.
- `evidence/qa-gates/coverage-delta.2026-10-02T04-22.md` — changed-line coverage derivation; its inferred baseline counts (162/182, 49/56) were confirmed exactly by this review.

### Quality assessment prompts

- **Determinism:** fixed fixtures and stubs; derived roots sorted with `LC_ALL=C`.
- **Isolation:** each test runs in its own child shell with explicit environment.
- **Speed:** stub-backed; no real git or filesystem traversal outside checked-in fixtures.
- **Diagnostics:** misclassified candidates and excluded roots are printed on failure.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | Roots are passed as quoted array elements (`"${roots[@]}"`) to the scan binary; no `eval`; no unquoted expansion of the override value. |
| Input validation at boundaries | ✅ PASS | Override entries validated as absolute; derived candidates are not (Minor finding above). |
| Error handling remains explicit | ✅ PASS | Hard-failure paths preserved and tested. |
| Configuration / path handling is safe | ✅ PASS | No pathname expansion of the override; read-only scan; no host-absolute paths written into artifacts. |

---

## Research Log

No external research was required. Behavior was verified against the repository's rules, the in-repo research document `research/research.2026-09-29T22-35.md`, and the CI artifacts.

---

## Verdict

The change is ready for normal PR flow. It delivers the scoped behavior with focused tests, keeps every changed file under 500 lines, maintains byte-identical mirrors, and leaves the #756 boundary intact. All gates are green on the final production head, and the current head differs from it only in feature-folder documents.

The three Minor findings and the Nit are non-blocking and can be handled in a follow-up: a stale line reference, a suppression without a stated reason, absolute-path validation of derived candidates, and a backslash-path fixture.
