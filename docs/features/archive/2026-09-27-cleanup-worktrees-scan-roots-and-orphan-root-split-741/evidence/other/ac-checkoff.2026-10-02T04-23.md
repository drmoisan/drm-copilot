# P2-T14 Acceptance-criteria check-off in issue.md

Timestamp: 2026-10-02T04-23
Command: `grep -c -F "[x] AC-" docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/issue.md`; `grep -c -F "[ ] AC-" docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/issue.md`
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- First grep: 12 (exit 0). Second grep: 0 (exit 1). All 12 criteria checked; EXIT_CODE is the second grep, whose exit 1 is the pass condition.
- `git diff --stat HEAD -- .../issue.md`: 12 insertions, 12 deletions; only the `- [ ]` -> `- [x]` markers of AC-1..AC-12 under `## Acceptance Criteria` changed. Criterion text unchanged.
- Each criterion was checked individually after confirming its mapped evidence (plan traceability table) exists and records a passing result:
  - AC-1: regression-testing/expect-fail-scan-roots.2026-10-02T03-47.md (T1, T3 fail before), regression-testing/pass-after-scan-roots.2026-10-02T04-06.md (T1 ok 455, T3 ok 457), qa-gates/bats-targeted.2026-10-02T04-07.md, qa-gates/shell-coverage-ci.2026-10-02T04-21.md.
  - AC-2: expect-fail-scan-roots, pass-after-scan-roots (T2 ok 456), qa-gates/bats-targeted.
  - AC-3: other/p1-t6.2026-10-02T03-52.md, qa-gates/bats-targeted (0 `not ok`, report-records suite included), qa-gates/ac12-boundary.2026-10-02T04-07.md (report-records suite unmodified).
  - AC-4: pass-after-scan-roots (T4 ok 458), qa-gates/bats-targeted.
  - AC-5: expect-fail-scan-roots, pass-after-scan-roots (T5-T11 ok 459-465), qa-gates/bats-targeted.
  - AC-6: expect-fail-scan-roots, pass-after-scan-roots (T12 ok 466), qa-gates/bats-targeted.
  - AC-7: qa-gates/structural-checks.2026-10-02T04-07.md (greps 1-5 PASS), pass-after-scan-roots (T13-T16 ok 467-470), qa-gates/bats-targeted.
  - AC-8: other/p1-t9.2026-10-02T03-55.md, qa-gates/structural-checks (scoped `load_helper` count 0; `set +u` 1; PS4 1). The repo-wide grep lists two lines in an out-of-scope fixture (DEV-6, DEV-8); AC-8 names only the scan-helper suite.
  - AC-9: qa-gates/mirror-identity.2026-10-02T04-07.md, qa-gates/bundle-parity-pytest.2026-10-02T04-07.md (KL-510: PASSED).
  - AC-10: qa-gates/doc-contract.2026-10-02T04-07.md.
  - AC-11: qa-gates/shfmt.2026-10-02T04-07.md, qa-gates/shellcheck.2026-10-02T04-07.md, qa-gates/line-counts.2026-10-02T04-07.md, qa-gates/shell-coverage-ci.2026-10-02T04-21.md (CI success on FINAL_SHA, 0 `not ok`), qa-gates/coverage-delta.2026-10-02T04-22.md (every changed production file >= 0.850; lowest 0.873).
  - AC-12: qa-gates/ac12-boundary.2026-10-02T04-07.md, qa-gates/scope.2026-10-02T04-07.md.
- Unchecked criteria: none.
- Commit note: the P2-T14 text says this edit and post-P2-T11 evidence remain uncommitted for the orchestrator to commit with the pull request; the segment-4 orchestrator directive instructs the executor to commit and push them. They are confined to FEATURE and do not change any file the P2-T12 run measured.
