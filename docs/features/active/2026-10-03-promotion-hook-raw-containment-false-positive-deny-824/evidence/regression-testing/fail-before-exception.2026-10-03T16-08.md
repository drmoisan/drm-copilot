# Fail-before exception dossier (remediation cycle 2, issue #824)

Timestamp: 2026-10-03T16-08
Command: pwsh -NoProfile -File "SCRATCH/steps/r2-p1-t11.ps1" -Worktree "WORKTREE" (git show bda1982bcb9048a22efe9ba124a2b53516e9e3c1:.codex/codex-web-setup.sh; BASE-DEFINITIONS; BASE-LAST-IS-GUARD; VERDICT), then pwsh -NoProfile -File "SCRATCH/steps/r2-p1-t11-check.ps1" -Worktree "WORKTREE" (WHY-COUNT; VERDICT)
EXIT_CODE: 0
Output Summary: first script SHOW-EXIT=0, BASE-DEFINITIONS=0,0,0, BASE-LAST-IS-GUARD=False (exit 0); second script WHY-COUNT=1 (exit 0). EXIT_CODE is the larger of the two process exit codes.
WhyFailingRunImpossible: (a) R824-N11, R824-N12, A824-WT10, and A824-WT11-2 pin behaviour that already holds at BASE_SHA (D9), so they cannot fail on the unfixed tree. (b) BATS cannot run on this host: bats and kcov run only in the CI job shell-coverage / Shell Coverage (Bats + kcov) (the existing Run shell-qc test with coverage step and the D13 Measure step), which runs on the PR head after the fix, and the executor has no permitted local route (D8).

## Alternative proof

For (a): the P1-T10 artifact FEATURE/evidence/regression-testing/r2-expect-fail-pester.2026-10-03T16-07.md lists R824-N11 and R824-N12 (U1 and U2) and A824-WT10 and A824-WT11-2 (S6, S7, and S8) on PASSED lines, while the 45 FIX-SET rows fail in the same run against the unfixed tree (passed=198 failed=45, exit 45).

For (b): the first step script printed:

```text
SHOW-EXIT=0
BASE-DEFINITIONS=0,0,0
BASE-LAST-IS-GUARD=False
```

BASE-DEFINITIONS=0,0,0 shows that resolve_repo_root, select_solution_file, and list_root_solution_files do not exist at BASE_SHA, so cases C824-2 to C824-7 would fail there with a command-not-found status. BASE-LAST-IS-GUARD=False shows that at BASE_SHA the last line is not the BASH_SOURCE guard, so sourcing the file runs main: C824-1 fails, and the setup of every case would run the full bootstrap.

## Negative-evidence search

SearchScope: FEATURE/evidence/regression-testing/
SearchPatterns: r2-expect-fail-*.md, fail-before-exception.*.md
SearchResult: FEATURE/evidence/regression-testing/r2-expect-fail-pester.2026-10-03T16-07.md and this dossier.
