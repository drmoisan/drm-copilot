# Preflight Round 2 — Issue #741

Timestamp: 2026-09-29T23-32
Plan: docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/plan.2026-09-29T22-26.md
Directive: DIRECTIVE: PREFLIGHT VALIDATION ONLY
Reviewer: atomic-executor
Worktree HEAD at review: f6d04e1ce646bf1ac4cd360478e9c2df22be74d1 (branch bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741; remote branch at the same SHA)
Prior round: FEATURE/evidence/other/preflight-round-1.2026-09-29T23-10.md

PREFLIGHT: ALL CLEAR
CONVERGENCE: NO FURTHER ROUNDS EXPECTED

## Scope of change since round 1

`git log 74e946aa..HEAD` shows two commits, both documentation only (the round-1 report and the plan revision). `git diff --stat 74e946aa HEAD` touches only the round-1 report and the plan. `git diff --name-only origin/main...HEAD` lists only four feature-folder documents. No script, test, or fixture changed, so every tree citation verified in round 1 still describes the current tree. `wc -l` re-run: 252, 476, 492, 182, 234, 496, 495, 101, 132, matching P0-T5 and D8.

The plan diff is confined to: the Last Updated line, D6, D9, P1-T3 (T13, T14, the token rule, Commands, Acceptance), and P1-T9 (Commands, Acceptance). No task was added, removed, or reordered; the write list is unchanged (15 paths).

## Round-1 delta verification

### Defect 1 (D6 and P1-T9) — applied completely

- D6 now requires a child-shell function `source_helper` whose body sources its first argument and then runs `set +u`, and states that the `source` and `set +u` never run at the top level of the child shell, with the kcov PS4/`${BASH_SOURCE}` rationale and the helper's nounset source cited (`cleanup_worktrees_scan_helper.sh` line 42, verified: `set -euo pipefail`). The name `load_helper` is excluded. The remaining D6 sentences (PS4 exactly once in the comment, no literal `set +u` in the comment, drive-letter test lines 36-55 calls it) are unchanged.
- The added citation "as the current drive-letter test passes it at line 52" is correct: `tests/shell/test_cleanup_worktrees_scan_helper.bats` line 52 is `' _ "${HELPER}" "${drive_root}"`.
- P1-T9 Commands now include `grep -c -F "source_helper() {" tests/shell/test_cleanup_worktrees_scan_helper.bats` after the `run_helper_sourced` grep, and Acceptance includes "the `source_helper() {` count is 1 (planning-time value 0)". Observed now: count 0, exit 1, so the planning-time value is correct and the assertion can fail.
- The `set +u` count 1 and PS4 count 1 remain satisfiable together: the only `set +u` is the one in the `source_helper` body, and the only PS4 is in the `run_helper_sourced` comment after lines 42-44, 72, and 88 are removed or rewritten.
- The last command of P1-T9 is still the bats run, so the top-level `EXIT_CODE:` is unchanged (expected 0).

### Defect 2 (P1-T3) — applied completely

- T13 and T14 no longer say "retargeted". Each now specifies a child shell that sources `${ELIB}` at its top level, shifts, and runs the candidate loop of the cited lines calling `cleanup_wt_is_absolute_path`. Citations verified: lines 77-79 are the T13 `for ... || printf` loop and lines 93-97 are the T14 `for ... if ... fi` loop.
- Sourcing `${ELIB}` at the child shell's top level is safe under kcov: no `*_lib.sh` under the scripts directory runs `set -u` (the only `set -euo pipefail` lines are the scan helper line 42 and the wrapper line 7), and the enumeration library's only top-level statement other than function definitions is `CLEANUP_WT_BASE_BRANCH="main"` (line 169).
- The token rule "No line of NEW-SUITE contains the tokens `load_helper`, `set +u`, or `scan_helper_is_absolute_path`" is present. It is satisfiable: none of the libraries that NEW-SUITE sources (ELIB, LIB, DIRTLIB, RLIB, DLIB, PLIB) enables nounset, and the `rr`/`report_raw` forms in `tests/shell/test_cleanup_worktrees_report_records.bats` lines 25-42 contain none of the three tokens.
- The three greps are inserted before `git status`, and Acceptance states each prints 0 with exit 1 as the pass condition. `git status` remains the last command, and the Acceptance line states that its exit code is the artifact's top-level `EXIT_CODE:`.

### D9 note — applied

D9 now records the round-1 observation (shfmt exit 1 from 4-space bats indentation; SC2016 on the same file) as the reason the AC-11 lint gate is limited to CHANGED-SH. This matches the round-1 note.

## grep exit-code consistency check (requested)

Observed on this host: `grep -c -F "load_helper" tests/shell/test_cleanup_worktrees_report_records.bats` printed 0 and exited 1; `grep -c -F "source_helper() {" tests/shell/test_cleanup_worktrees_scan_helper.bats` printed 0 and exited 1; `grep -c -F "set +u"` and `grep -c -F "PS4"` on the same file printed 3 and exited 0.

Every task in which a grep is expected to print 0 or nothing was checked against the Evidence accounting rule (top-level `EXIT_CODE:` is the last non-grep command; a grep-only task records the last grep; Phase 1 greps are recorded as `GREP value=<v> exit=<n>` in `Output Summary:`):

| Task | Zero-result grep(s) | Pass condition stated | Top-level EXIT_CODE source | Expected top-level value |
| --- | --- | --- | --- | --- |
| P0-T12 | `... --log \| grep -c "not ok"` | "grep prints 0 and exits 1, which is the pass condition here" | A1 (`sh SCRATCH/changed-line-coverage.sh`) | 0 |
| P1-T3 | three token greps | "prints 0 (exit 1 is the pass condition for each)" | `git status` | 0 |
| P1-T6 | `grep -c "^cleanup_wt_scan_roots() {"` on RLIB | "(exit 1 is the pass condition here)" | second bats run | 0 |
| P1-T8 | `grep -c "scan_helper_is_absolute_path"` | "(exit 1 is the pass condition here)" | bats | 0 |
| P1-T9 | `grep -rn load_helper tests` | "prints nothing and exits 1" | bats | 0 |
| P1-T10 | `grep -c -F "Colon-separated override"` | "(exit 1 is the pass condition here)" | bats | 0 |
| P2-T7 | third and sixth greps | "prints nothing and exits 1" | last grep (`PS4`, prints 1) | 0 |
| P2-T12 | `... --log \| grep -c "not ok"` | "(exit 1 is the pass condition)" | A1 | 0 |
| P2-T14 | `grep -c -F "[ ] AC-"` (last command) | "prints 0 and exits 1 ... `EXIT_CODE: 1` and `ExpectedExitCode: 1`" | last grep | 1, with `ExpectedExitCode: 1` |

No task has a zero-result grep as its top-level `EXIT_CODE:` source without a matching `ExpectedExitCode:`. P1-T4 (bats exit 1) carries `ExpectedExitCode: 1`. No `tests/shell/*.bats` file contains the literal `not ok` (grep over `tests/shell` returned no match), so the CI log count of 0 is attainable on a passing run.

## Whole-plan re-review (one pass)

- Citations: the tree is unchanged since round 1 for every script, test, and fixture; the round-1 citation list therefore still holds. The citations touched by the revision (scan helper line 42, suite lines 52, 77-79, 93-97) were re-derived above.
- Task ordering: filter arithmetic re-traced. P1-T4 (pre-fix) still yields 14 `not ok` and 2 `ok`: under the new T13/T14 form, `cleanup_wt_is_absolute_path` is undefined, so bats `run` captures the command-not-found stderr and the empty-output assertion fails in both tests; T4 and T16 pass. P1-T5 filter selects T13 and T14 only; P1-T6 selects T1-T12; P1-T7 selects T15 and T16; P1-T8 `scan-dirs` excludes the two tests P1-T9 later deletes. No gate runs a test before the task that makes it pass.
- Expected counts: P1-T18/P2-T3 M = BASELINE_LOCAL_N + 14 (86 + 16 - 2 = 100). P1-T9 line cap 90 from 101 is attainable (33 lines removed, one helper of about 12 lines added).
- Blast radius: each of the 15 write-list paths is the first backticked path of exactly one create or update task title (P1-T2, P1-T3, P1-T5 through P1-T17). The revision did not add a write to any file outside its owning task; the P1-T3 token greps now keep NEW-SUITE repairs inside P1-T3.
- AC-12 (#756 boundary): no task writes `tests/shell/test_cleanup_worktrees_report_records.bats`; P1-T6 edits RLIB lines 7-11, 114-150, and the `cleanup_wt_scan_records` docstring, all outside `run_report_scans` (306-344) and `classify_all_branches` (346-476); P1-T6 and P2-T9 gate this with A2 and an anchored `git diff --exit-code BASE_SHA`.
- 500-line limits: D8 targets and the P2-T4 hard limit are unchanged and consistent with measured sizes.
- Evidence fields and locations: every artifact resolves under FEATURE/evidence/{baseline,regression-testing,qa-gates,other}/; command-step artifacts carry `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; P1-T1 records no `EXIT_CODE:` because it runs no command. No task has a SKIPPED path.
- Command text: no command added in the revision contains the words bash, pwsh, or wsl, or a heredoc.

## Non-blocking note

- In P1-T3 the sentence "No line of NEW-SUITE contains the tokens ..." sits between the T14 and T15 bullets at the indentation of `Commands:`. It reads as a whole-suite constraint and is enforced by the three greps, so execution is unaffected. The planner may move it after the T16 bullet in a later edit; no revision is required.
