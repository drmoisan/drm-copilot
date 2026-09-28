# Reviewer Verification (feature review, issue #706)

Timestamp: 2026-09-27T10-48
Branch: bug/cleanup-report-registration-lost-false-positive-706
HEAD: 81d4e16b109525a2f965b7353cd2f9492f6225ef
Merge base (origin/main): 849aae609787172240c1ae7c33d10d6dd337d497
Producer: feature-review agent (check-only commands; no source file was modified)

## 1. Code identity between the CI coverage run and the branch head

Command: git diff --name-only 3bcaee4d..HEAD
EXIT_CODE: 0
Output Summary: 15 paths, all under `docs/features/active/cleanup-report-registration-lost-false-positive-706/` (evidence files, `plan.2026-09-26T22-56.md`, `spec.md`). No path under `scripts/` or `tests/`. The code measured by CI run 36326020967 (head 3bcaee4d) is identical to the code at 81d4e16b.

Command: sha256sum scripts/bash/cleanup_worktrees_scan_helper.sh tests/shell/test_cleanup_worktrees_scan_helper.bats tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit
EXIT_CODE: 0
Output Summary: fee0479e...070274f, 4c338dec...daed7490, bd5d1f63...ea882398. All three equal the hashes recorded in `qa-gates/qc-loop-pass.2026-09-27T10-46.md`.

Command: git ls-files --eol <the three files above>
EXIT_CODE: 0
Output Summary: `i/lf w/lf` for all three; the fixture pointer is LF-terminated.

## 2. Local toolchain re-run (check-only)

Command: sh scripts/bash/shell-qc.sh check
EXIT_CODE: 0
Output Summary: No output (no shfmt diff, no shellcheck finding, repo-wide).

Command: shellcheck -f gcc scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: No findings.

Command: shfmt -d scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: No diff. Local shfmt is v3.12.0; CI pins 3.8.0 and the CI check step also passed (run 36326020967).

Command: npx --yes bats tests/shell/test_cleanup_worktrees_scan_helper.bats tests/shell/test_cleanup_worktrees_report_records.bats tests/shell/test_cleanup_worktrees_scan_seam.bats
EXIT_CODE: 0
Output Summary: 1..17, 17 ok, 0 not ok. Includes all four new tests and the unchanged existing scan-dirs test.

## 3. Real-host comparison, pre-fix vs post-fix helper (read-only)

Method: the pre-fix classification and existence lines were reconstructed in a session-scratchpad copy of the helper (`if [[ $target != /* ]]; then` and `if [[ -e $target ]]; then`, the two lines the fix replaced). Both the reconstructed copy and the branch helper were run with `scan-dirs` over the two derived roots on the reporting host (`<main>/.claude/worktrees` and `<main>-wt`). The helper is read-only; no file was written outside the scratchpad.

Command: bash <scratchpad>/scan_helper_base.sh scan-dirs <main>/.claude/worktrees <main>-wt
EXIT_CODE: 0
Output Summary: 41 records; target_exists 1: 0; target_exists 0: 33; no pointer (NA): 8.

Command: bash scripts/bash/cleanup_worktrees_scan_helper.sh scan-dirs <main>/.claude/worktrees <main>-wt
EXIT_CODE: 0
Output Summary: 41 records; target_exists 1: 32; target_exists 0: 1; no pointer (NA): 8.

Pointer form: every sampled pointer uses `gitdir: C:/Users/<user>/repos/drm-copilot/.git/worktrees/<name>` (drive-letter form).

Remaining target_exists 0 record: `<main>-wt/2026-08-25T14-46`. Its pointer names `C:/.../drm-copilot/.git/worktrees/2026-08-25T14-46` (LF-terminated, verified with `od -c`), and `ls -d` on that target reports `No such file or directory`. This is a genuine registration loss, which the fixed helper still reports (AC-2 behavior on real data).

Result: on the reporting host, 32 of 33 false `target_exists 0` records are corrected and the one genuine loss is preserved.
