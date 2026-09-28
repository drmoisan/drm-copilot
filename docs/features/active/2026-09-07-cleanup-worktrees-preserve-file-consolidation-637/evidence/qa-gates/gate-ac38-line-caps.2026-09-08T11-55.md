# Gate — AC-38, every changed non-Markdown file is at or below 500 lines

Timestamp: 2026-09-08T11-55
Task: `[P9-T3]`
Command: git diff --name-only epic/cleanup-merged-worktrees-hardening-integration
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: 109 non-Markdown entries measured, 0 over the cap. The two largest are
`scripts/bash/cleanup_worktrees_preserve_lib.sh` at 492 and
`tests/shell/test_cleanup_worktrees_preserve.bats` at 471. Exit codes: `git status --porcelain
--untracked-files=all` 0, `git diff --name-only <ref>` 0.

RouteSubstitution:
- Plan span NOT run: `git add -A`. The delegation governing this execution forbids this executor
  from running `git add`, `git commit`, or `git push`; the orchestrator owns staging.
- Substitute actually run: `git status --porcelain --untracked-files=all`, whose output is merged
  with the anchored `git diff --name-only <ref>` listing and de-duplicated.
- Why the substitute is equivalent for this task's purpose. The plan includes `git add -A` for one
  stated reason: an anchored name-listing diff enumerates tracked changes only and would not
  otherwise see the files this work creates. `git status --porcelain --untracked-files=all` reports
  exactly that missing set, one path per untracked file rather than one path per untracked
  directory, so the merged list covers both tracked modifications and new files without mutating
  the index. The merged list holds 190 entries.
- The `--untracked-files=all` flag is load-bearing. Plain porcelain output collapses a new directory
  to a single `?? <dir>/` line, and a per-file line count cannot be taken from a directory name.

## Method

1. `git status --porcelain --untracked-files=all` from the worktree root, exit 0.
2. `git diff --name-only epic/cleanup-merged-worktrees-hardening-integration`, exit 0.
3. The two listings merged and de-duplicated: 190 entries.
4. `wc -l` run on every entry that exists in the working tree and does not end in `.md`. Markdown
   is exempt from the cap.

Entries present only on the ref would be recorded as `ref-only, not measured`; there are none, so
that row does not appear in the table.

## Per-file line-count table

    .gitattributes                                                                                       2
    scripts/bash/cleanup_worktrees_preserve_eol_lib.sh                                                 212
    scripts/bash/cleanup_worktrees_preserve_lib.sh                                                     492
    scripts/bash/cleanup-worktrees.sh                                                                  163
    tests/fixtures/cleanup_worktrees/preserve/bad-schema/jq.out                                          0
    tests/fixtures/cleanup_worktrees/preserve/bad-schema/jq.rc                                           1
    tests/fixtures/cleanup_worktrees/preserve/bad-schema/manifest.json                                  22
    tests/fixtures/cleanup_worktrees/preserve/bad-tool/jq.out                                            0
    tests/fixtures/cleanup_worktrees/preserve/bad-tool/jq.rc                                             1
    tests/fixtures/cleanup_worktrees/preserve/bad-tool/manifest.json                                    22
    tests/fixtures/cleanup_worktrees/preserve/eol-mixed/check-ignore.agent-memory_atomic-executor_mixed-lesson.md.rc     1
    tests/fixtures/cleanup_worktrees/preserve/eol-mixed/jq.out                                           1
    tests/fixtures/cleanup_worktrees/preserve/eol-mixed/manifest.json                                   22
    tests/fixtures/cleanup_worktrees/preserve/eol-stale/check-ignore.agent-memory_atomic-executor_stale-eol-lesson.md.rc     1
    tests/fixtures/cleanup_worktrees/preserve/eol-stale/jq.out                                           1
    tests/fixtures/cleanup_worktrees/preserve/eol-stale/manifest.json                                   22
    tests/fixtures/cleanup_worktrees/preserve/eol-unterminated/check-ignore.agent-memory_atomic-executor_unterminated-lesson.md.rc     1
    tests/fixtures/cleanup_worktrees/preserve/eol-unterminated/jq.out                                    1
    tests/fixtures/cleanup_worktrees/preserve/eol-unterminated/manifest.json                            22
    tests/fixtures/cleanup_worktrees/preserve/exit-codes/blocked/check-ignore.null.rc                    1
    tests/fixtures/cleanup_worktrees/preserve/exit-codes/blocked/jq.out                                  1
    tests/fixtures/cleanup_worktrees/preserve/exit-codes/blocked/manifest.json                          22
    tests/fixtures/cleanup_worktrees/preserve/exit-codes/clean/check-ignore.null.rc                      1
    tests/fixtures/cleanup_worktrees/preserve/exit-codes/clean/jq.out                                    1
    tests/fixtures/cleanup_worktrees/preserve/exit-codes/clean/manifest.json                            22
    tests/fixtures/cleanup_worktrees/preserve/exit-codes/skipped/check-ignore.null.rc                    1
    tests/fixtures/cleanup_worktrees/preserve/exit-codes/skipped/jq.out                                  2
    tests/fixtures/cleanup_worktrees/preserve/exit-codes/skipped/manifest.json                          37
    tests/fixtures/cleanup_worktrees/preserve/field-matrix/change-class-out-of-vocabulary/jq.out         1
    tests/fixtures/cleanup_worktrees/preserve/field-matrix/change-class-out-of-vocabulary/manifest.json    22
    tests/fixtures/cleanup_worktrees/preserve/field-matrix/disposition-not-preserve/jq.out               1
    tests/fixtures/cleanup_worktrees/preserve/field-matrix/disposition-not-preserve/manifest.json       22
    tests/fixtures/cleanup_worktrees/preserve/field-matrix/evidence-empty/jq.out                         1
    tests/fixtures/cleanup_worktrees/preserve/field-matrix/evidence-empty/manifest.json                 22
    tests/fixtures/cleanup_worktrees/preserve/field-matrix/memory-index-line-key-absent/jq.out           1
    tests/fixtures/cleanup_worktrees/preserve/field-matrix/memory-index-line-key-absent/manifest.json    21
    tests/fixtures/cleanup_worktrees/preserve/field-matrix/source-path-absolute/jq.out                   1
    tests/fixtures/cleanup_worktrees/preserve/field-matrix/source-path-absolute/manifest.json           22
    tests/fixtures/cleanup_worktrees/preserve/field-matrix/target-path-empty/jq.out                      1
    tests/fixtures/cleanup_worktrees/preserve/field-matrix/target-path-empty/manifest.json              22
    tests/fixtures/cleanup_worktrees/preserve/field-matrix/verdict-out-of-vocabulary/jq.out              1
    tests/fixtures/cleanup_worktrees/preserve/field-matrix/verdict-out-of-vocabulary/manifest.json      22
    tests/fixtures/cleanup_worktrees/preserve/field-matrix/worktree-path-empty/jq.out                    1
    tests/fixtures/cleanup_worktrees/preserve/field-matrix/worktree-path-empty/manifest.json            22
    tests/fixtures/cleanup_worktrees/preserve/host-token/check-ignore.null.rc                            1
    tests/fixtures/cleanup_worktrees/preserve/host-token/jq.out                                          1
    tests/fixtures/cleanup_worktrees/preserve/host-token/manifest.json                                  22
    tests/fixtures/cleanup_worktrees/preserve/ht-patterns/check-ignore.null.rc                           1
    tests/fixtures/cleanup_worktrees/preserve/ht-patterns/jq.out                                         6
    tests/fixtures/cleanup_worktrees/preserve/ht-patterns/manifest.json                                 97
    tests/fixtures/cleanup_worktrees/preserve/ht-revision/check-ignore.null.rc                           1
    tests/fixtures/cleanup_worktrees/preserve/ht-revision/jq.out                                         1
    tests/fixtures/cleanup_worktrees/preserve/ht-revision/manifest.json                                 22
    tests/fixtures/cleanup_worktrees/preserve/ignored-target/check-ignore.null.rc                        1
    tests/fixtures/cleanup_worktrees/preserve/ignored-target/jq.out                                      1
    tests/fixtures/cleanup_worktrees/preserve/ignored-target/manifest.json                              22
    tests/fixtures/cleanup_worktrees/preserve/index-absent/.gitkeep                                      4
    tests/fixtures/cleanup_worktrees/preserve/index-absent/check-ignore.null.rc                          1
    tests/fixtures/cleanup_worktrees/preserve/index-absent/jq.out                                        1
    tests/fixtures/cleanup_worktrees/preserve/index-absent/manifest.json                                22
    tests/fixtures/cleanup_worktrees/preserve/index-append/check-ignore.agent-memory_atomic-executor_appended-lesson.md.rc     1
    tests/fixtures/cleanup_worktrees/preserve/index-append/jq.out                                        1
    tests/fixtures/cleanup_worktrees/preserve/index-append/manifest.json                                22
    tests/fixtures/cleanup_worktrees/preserve/index-duplicate/check-ignore.agent-memory_atomic-executor_duplicate-lesson.md.rc     1
    tests/fixtures/cleanup_worktrees/preserve/index-duplicate/jq.out                                     1
    tests/fixtures/cleanup_worktrees/preserve/index-duplicate/manifest.json                             22
    tests/fixtures/cleanup_worktrees/preserve/missing-source/jq.out                                      1
    tests/fixtures/cleanup_worktrees/preserve/missing-source/manifest.json                              22
    tests/fixtures/cleanup_worktrees/preserve/missing-source/wt/agent-memory/atomic-executor/.gitkeep     2
    tests/fixtures/cleanup_worktrees/preserve/modified/check-ignore.null.rc                              1
    tests/fixtures/cleanup_worktrees/preserve/modified/jq.out                                            1
    tests/fixtures/cleanup_worktrees/preserve/modified/manifest.json                                    22
    tests/fixtures/cleanup_worktrees/preserve/no-jq/.gitkeep                                             4
    tests/fixtures/cleanup_worktrees/preserve/no-worktree/check-ignore.null.rc                           1
    tests/fixtures/cleanup_worktrees/preserve/no-worktree/jq.out                                         1
    tests/fixtures/cleanup_worktrees/preserve/no-worktree/manifest.json                                 22
    tests/fixtures/cleanup_worktrees/preserve/order/check-ignore.agent-memory_atomic-executor_aaa-lesson.md.rc     1
    tests/fixtures/cleanup_worktrees/preserve/order/check-ignore.agent-memory_atomic-executor_zzz-lesson.md.rc     1
    tests/fixtures/cleanup_worktrees/preserve/order/jq.out                                               2
    tests/fixtures/cleanup_worktrees/preserve/order/manifest.json                                       37
    tests/fixtures/cleanup_worktrees/preserve/pattern-set-id/advisory-only/check-ignore.null.rc          1
    tests/fixtures/cleanup_worktrees/preserve/pattern-set-id/advisory-only/jq.out                        1
    tests/fixtures/cleanup_worktrees/preserve/pattern-set-id/advisory-only/manifest.json                22
    tests/fixtures/cleanup_worktrees/preserve/pattern-set-id/local-scan-governs/check-ignore.null.rc     1
    tests/fixtures/cleanup_worktrees/preserve/pattern-set-id/local-scan-governs/jq.out                   1
    tests/fixtures/cleanup_worktrees/preserve/pattern-set-id/local-scan-governs/manifest.json           22
    tests/fixtures/cleanup_worktrees/preserve/scan-malformed/absent/jq.out                               1
    tests/fixtures/cleanup_worktrees/preserve/scan-malformed/absent/manifest.json                       18
    tests/fixtures/cleanup_worktrees/preserve/scan-malformed/missing-pattern-set-id/jq.out               1
    tests/fixtures/cleanup_worktrees/preserve/scan-malformed/missing-pattern-set-id/manifest.json       21
    tests/fixtures/cleanup_worktrees/preserve/scan-malformed/missing-result/jq.out                       1
    tests/fixtures/cleanup_worktrees/preserve/scan-malformed/missing-result/manifest.json               21
    tests/fixtures/cleanup_worktrees/preserve/scan-malformed/not-an-object/jq.out                        1
    tests/fixtures/cleanup_worktrees/preserve/scan-malformed/not-an-object/manifest.json                19
    tests/fixtures/cleanup_worktrees/preserve/scan-malformed/result-out-of-vocabulary/jq.out             1
    tests/fixtures/cleanup_worktrees/preserve/scan-malformed/result-out-of-vocabulary/manifest.json     22
    tests/fixtures/cleanup_worktrees/preserve/scan-scope/check-ignore.agent-memory_atomic-executor_scope-lesson.md.rc     1
    tests/fixtures/cleanup_worktrees/preserve/scan-scope/jq.out                                          1
    tests/fixtures/cleanup_worktrees/preserve/scan-scope/manifest.json                                  22
    tests/fixtures/cleanup_worktrees/preserve/stub-bin/jq                                               79
    tests/fixtures/cleanup_worktrees/preserve/stub-keys/add-fails/add.docs_target.md.out                 1
    tests/fixtures/cleanup_worktrees/preserve/stub-keys/add-fails/add.docs_target.md.rc                  1
    tests/fixtures/cleanup_worktrees/preserve/stub-keys/not-ignored/check-ignore.docs_target.md.rc       1
    tests/fixtures/cleanup_worktrees/preserve/untracked/check-ignore.null.rc                             1
    tests/fixtures/cleanup_worktrees/preserve/untracked/jq.out                                           1
    tests/fixtures/cleanup_worktrees/preserve/untracked/manifest.json                                   22
    tests/fixtures/cleanup_worktrees/stub-bin/git                                                      275
    tests/shell/test_cleanup_worktrees_preserve.bats                                                   471
    tests/shell/test_cleanup_worktrees_preserve_eol.bats                                               175

## Result

Every measured entry reports 500 or fewer lines. No split was required at this task: both
pre-authorized splits were already taken at `[P5-T9]`, and
`evidence/other/library-split-decision.2026-09-08T10-30.md` records that decision and its reasoning.
The four files the splits produced or relieved are the four largest in the table.

Verdict: PASS.
