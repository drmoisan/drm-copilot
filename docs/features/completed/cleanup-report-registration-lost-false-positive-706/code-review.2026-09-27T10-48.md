# Code Review: cleanup-worktrees scan helper drive-letter gitdir classification (#706)

---

**Review Date:** 2026-09-27
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/cleanup-report-registration-lost-false-positive-706`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its suffix matches issue 706 in the branch name.
**Base Branch:** `main` (`origin/main` @ `849aae60`; merge base is the same SHA)
**Head Branch:** `bug/cleanup-report-registration-lost-false-positive-706` @ `81d4e16b`
**Review Type:** Initial review

---

## Executive Summary

The branch corrects the absolute-path test in `scan_helper_gitdir_target_exists` so that a worktree pointer target written by Git for Windows in drive-letter form (`C:/...`) is no longer prefixed with the worktree directory. The production delta is 28 added and 3 removed lines in one bash file; the test delta is four appended bats tests and one checked-in fixture. The consumer library, the wrapper, the report-records tests, the existing fixture tree, and both SKILL.md copies are unchanged (verified by the executor's `git diff --exit-code` scope check and by this review's diff inspection).

Evidence reviewed: the full `origin/main...HEAD` diff, `artifacts/pr_context.summary.txt` and appendix, the spec and research, 51 executor evidence files, CI runs 36324413557 (baseline) and 36326020967 (post-change) as recorded in evidence, a local re-run of shfmt, shellcheck, and three bats suites (17/17 ok), and a read-only real-host comparison of pre-fix and post-fix logic over the two derived scan roots. On the reporting host, the pre-fix logic reported all 33 pointer-bearing worktrees as missing their target; the fixed helper reports 1, whose target directory is absent (a genuine loss). Implementation quality is good: the change is minimal, the pure predicate is separated from the I/O seam, and the fail-before and negative-control evidence shows the tests can detect the defect.

**What changed:**
- `scripts/bash/cleanup_worktrees_scan_helper.sh`: new `scan_helper_is_absolute_path` (lines 73-85, glob `/*` or `[A-Za-z]:[/\\]*`), new `scan_helper_target_present` (lines 87-95, `[[ -e ${1:-} ]]`), and lines 116 and 119 now call them. Header comment lines 23-24 define "absolute".
- `tests/shell/test_cleanup_worktrees_scan_helper.bats`: tests at lines 36-101.
- `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit`: `gitdir: C:/fixture-repo/.git/worktrees/wt_drive`.

**Top 3 risks:**
1. Test 1 depends on redefining a sourced function (`scan_helper_target_present`). If a later refactor inlines the existence check, test 1 fails rather than passing silently, so the risk is a test break, not a missed defect (spec Risks).
2. Three tests depend on a `load_helper` shim that clears `nounset` after sourcing, because the helper enables `set -euo pipefail` at top level and kcov's PS4 trace expands `${BASH_SOURCE}`. This coupling to kcov tracing behavior caused CI pass 1 to fail (run 36325350057) and could recur for any future test that sources the helper without the shim.
3. Test 2 assumes `C:/fixture-repo/.git/worktrees/wt_drive` does not exist on the test host. That holds on the CI runner and on the reporting host; a host with that exact path would fail the test.

**PR readiness recommendation:** **Go** — no Blocker or Major findings; toolchain, tests, and coverage pass in CI at code identical to the head, and the fix is confirmed on real host data.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `docs/features/active/cleanup-report-registration-lost-false-positive-706/evidence/**` | Files committed in be344727 through 81d4e16b | Evidence filename timestamps and `Timestamp:` values are 4 to 18 minutes later than the commits that contain them. Example: `other/commit-final.2026-09-27T10-55.md` is in commit 81d4e16b dated 10:40:13 -0400; `qa-gates/ci-shell-coverage.2026-09-27T10-48.md` records a dispatch at 14:28:06Z (10:28 local). | Derive evidence timestamps from the host clock at write time (`date +%Y-%m-%dT%H-%M`) rather than from a planned or incremented value. Optionally rename the affected files in a follow-up; not required for merge. | Evidence timestamps are used to order and audit execution; values later than the containing commit cannot be creation times. Substantive results remain verifiable through run IDs and file hashes, which this review confirmed. | `git log --format='%h %ci' --name-only origin/main..HEAD -- <feature>/evidence`; `evidence/qa-gates/reviewer-verification.2026-09-27T10-48.md` section 1 |
| Nit | `tests/shell/test_cleanup_worktrees_scan_helper.bats` | Lines 48-49, 74-75, 90-91 | The `load_helper() { source "$1"; set +u; }` shim and its explanatory comment are repeated in three tests. | Consider defining the shim text once (for example a file-level variable holding the prelude, or a sourced test helper under `tests/shell/`) so a future test that sources the helper cannot omit it. | Reduces the chance of repeating the CI pass-1 failure mode when more sourcing tests are added. | Diff inspection; `evidence/qa-gates/ci-shell-coverage.2026-09-27T10-38.md` (pass-1 failure) |
| Nit | `scripts/bash/cleanup_worktrees_scan_helper.sh` | Line 84 | The drive-letter absolute-path glob duplicates `scripts/bash/cleanup_worktrees_preserve_lib.sh:161` (`[[ $val == /* \|\| $val == [A-Za-z]:[\\/]* ]]`). | No change required now. If a third copy appears, move the predicate into a small sourceable library; the scan helper is a standalone seam binary that currently sources nothing, so sharing today would add a dependency. | Keeps absolute-path rules consistent across the cleanup-worktrees scripts. | `grep -rn '== /\*' scripts/bash/` |
| Info | `scripts/bash/cleanup_worktrees_scan_helper.sh` | Line 42 | The helper runs `set -euo pipefail` at top level, so sourcing it changes the caller's shell options. This pre-existing behavior is why the new tests need the `set +u` shim. | No action in this change. A future refactor could apply strict mode only inside the executable guard at lines 178-182. | Records the root cause of the test shim for future maintainers. | File inspection; test comments at lines 42-44 |
| Info | `scripts/bash/cleanup_worktrees_scan_helper.sh` | Line 84 | Forms classified relative by design: bare `C:` and `C:rel` (drive-relative) and backslash UNC `\\server\share`. Git for Windows does not write these in worktree pointers. The `C:` case is a documented divergence from `Test-WorktreeResolutionAbsolutePath`. | None. | Behavior matches spec D1 and the classification table. | `spec.md` D1; test 4 |
| Info | `scripts/bash/cleanup_worktrees_scan_helper.sh` | Line 84 | `[A-Za-z]` in a bash glob is locale-sensitive only when `globasciiranges` is off; it is on by default in bash 5.0 and later, which both CI and Git Bash use. | None. | Confirms the character range is ASCII on supported shells. | bash documentation (`shopt globasciiranges`) |
| Info | `docs/features/active/cleanup-report-registration-lost-false-positive-706/issue.md` | `## Acceptance Criteria` | `issue.md` AC checkboxes remain unchecked while `spec.md` AC are checked. Under `Work Mode: full-bug`, `spec.md` is the sole AC source, so this is consistent with policy. The GitHub issue body carries `minor-audit`, as noted in `issue.md`. | None required. The PR author may state in the PR body that `spec.md` is authoritative. | Avoids confusion for readers who open `issue.md` first. | `issue.md` lines 11-13, 57-62 |
| Info | `artifacts/pr_context.summary.txt` | `Close candidates` | The PR-context generator lists `#AC-1` through `#AC-4` as author-asserted autoclose issues; these are AC labels, not issue numbers. | When authoring the PR body, close only `#706`. | Prevents spurious issue references in the PR. | `artifacts/pr_context.summary.txt` |
| Info | `evidence/qa-gates/ci-shell-coverage.2026-09-27T10-48.md` | Run 36326020967 | The post-change CI run was at 3bcaee4d, not the head 81d4e16b. The two later commits touch only feature-folder Markdown. | None; the PR-context CI run after rebase will re-confirm at the final head. | Code measured equals code at head. | `git diff --name-only 3bcaee4d..HEAD` |

No Blocker or Major findings. No finding introduces an enforcement-hook bypass or a workflow security regression (the branch modifies no file under `.claude/hooks/`, `.claude/settings.json`, `.github/workflows/`, or `.github/actions/`).

---

## Implementation Audit

### Bash implementation audit

#### What changed well

- The fix addresses the confirmed root cause at the single classification point; no consumer changes were needed, and the record format and CLI are unchanged.
- Classification is a pure glob predicate with no filesystem access, and the only I/O is isolated in a one-line function, which follows the separation-of-concerns rule and makes a drive-letter target testable on a Linux runner.
- `${1:-}` in both new functions keeps them safe under `set -u`.
- The header comment now defines "absolute", which was the undefined term behind the defect.

#### API and safety notes

- No new configuration or environment variable. The seam is a function override, used only in tests; production behavior of `scan_helper_target_present` is exactly the previous inline `[[ -e $target ]]`.
- The helper remains read-only and filesystem-only; no git process is added.
- shellcheck reports no finding and no suppression was added.

#### Error handling and logging

- Unchanged. A missing, empty, or unreadable pointer still yields `0` rather than a failure; test 2 confirms exit status 0 for a missing drive-letter target.

---

## Test Quality Audit

The four new tests cover both predicate outcomes (including lowercase, backslash, drive-relative, and empty inputs) and both scan outcomes for a drive-letter target. Test 1 is a true regression test: it failed against the unmodified helper with record `|1|0|` (`evidence/regression-testing/fail-before.2026-09-27T10-17.md`) and passes after the fix. Test 3 was shown able to fail by temporarily restoring the pre-fix rule (`predicate-negative-control.2026-09-27T10-29.md`, restoration confirmed in `predicate-restored.2026-09-27T10-29.md`). The existing test and the consumer suites pass unchanged. kcov attributes hits to all six new or modified lines.

### Reviewed test and QA artifacts

- `tests/shell/test_cleanup_worktrees_scan_helper.bats` — five tests; the four new tests are append-only (`67 0` numstat). Re-run locally by this review: all ok.
- `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit` — LF-terminated single-line pointer; no target directory is checked in, by design.
- `evidence/regression-testing/fail-before.2026-09-27T10-17.md`, `pass-after.2026-09-27T10-25.md` — fail-before and pass-after for the regression test.
- `evidence/qa-gates/ci-shell-coverage.2026-09-27T10-48.md`, `kcov-per-file.2026-09-27T10-49.md`, `kcov-new-line-hits.2026-09-27T10-49.md`, `coverage-delta.2026-09-27T10-50.md` — CI success, 93.3% repo-wide, 87.5% per file, 6/6 changed lines hit.
- `evidence/qa-gates/reviewer-verification.2026-09-27T10-48.md` — this review's local toolchain re-run, hash check, and real-host comparison (33 false results reduced to 1 genuine loss).

### Quality assessment prompts

- **Determinism:** checked-in fixture, exact-string seam, no clock, RNG, network, or git process.
- **Isolation:** each test runs the helper in its own child shell; function redefinition does not leak between tests.
- **Speed:** each new test spawns one child shell and scans a one-directory fixture root.
- **Diagnostics:** predicate tests print each misclassified candidate; scan tests print the full record on failure.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; the fixture contains a synthetic path only. |
| No unsafe subprocess or command construction | ✅ PASS | No new process execution; the pointer target is only compared by glob and tested with `-e`. |
| Input validation at boundaries | ✅ PASS | Empty target handled before classification (unchanged lines 112-115); predicate handles empty input. |
| Error handling remains explicit | ✅ PASS | Output semantics unchanged; no error is suppressed that was previously surfaced. |
| Configuration / path handling is safe | ✅ PASS | Read-only existence check; no path is written, created, or deleted. |
| Enforcement hooks and workflows untouched | ✅ PASS | No file under `.claude/hooks/`, `.claude/settings.json`, `.github/workflows/`, or `.github/actions/` in the diff. |

---

## Research Log

No external research was required. The branch's own research file and the in-repo precedent `.claude/lib/worktree-resolution/WorktreeResolution.psm1` were sufficient. The bash `globasciiranges` default was taken from general bash knowledge and is recorded as Info only.

---

## Verdict

The change is ready for normal PR flow. It fixes the confirmed root cause with a minimal, well-separated edit, the regression test demonstrably fails before and passes after, CI toolchain and coverage gates pass at code identical to the head, and a real-host comparison confirms the false positives are removed while a genuine registration loss is still reported. The Minor evidence-timestamp finding and the Nit items are non-blocking and can be addressed in follow-up work.
