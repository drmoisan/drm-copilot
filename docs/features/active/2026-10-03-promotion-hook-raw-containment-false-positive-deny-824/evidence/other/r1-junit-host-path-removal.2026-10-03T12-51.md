# r1 P0-T24 — removal of the two prior-cycle JUnit files that carried absolute host paths

Timestamp: 2026-10-03T12-51
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p0-t24-remove.ps1 -Worktree WORKTREE (second step script: P0-T24 commands (2) to (5) and the closing exit line; run only after SCRATCH/steps/r1-p0-t24.ps1 printed both expected lines)
EXIT_CODE: 0
Output Summary:
- Step script 1 (SCRATCH/steps/r1-p0-t24.ps1, exit 0, TS=2026-10-03T12-51), command (1):
  - `expect-fail-issue824.junit.xml CASES=43 FAILURES=14 | expect-fail-issue824.2026-10-03T09-51.md LISTED=43 FAILED=14`
  - `pass-after-issue824.junit.xml CASES=97 FAILURES=0 | pass-after-issue824.2026-10-03T09-57.md LISTED=97 FAILED=0`
- Step script 2 (this artifact's EXIT_CODE), commands (2) to (5):
  - GIT-RM-EXIT=0
  - PRESENT=False,False
  - HOSTPATH-GREP-EXIT=1 (no file-name line printed; the tokens are assembled at run time and `-l` prints file names only)
  - status: two lines, each starting `D `:
    - `D  docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/regression-testing/expect-fail-issue824.junit.xml`
    - `D  docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/regression-testing/pass-after-issue824.junit.xml`
- The two `.md` companions keep their historical `Command:` lines, which name the removed files' former paths. The deletion is staged; the orchestrator's commit step after Phase 9 commits it.
