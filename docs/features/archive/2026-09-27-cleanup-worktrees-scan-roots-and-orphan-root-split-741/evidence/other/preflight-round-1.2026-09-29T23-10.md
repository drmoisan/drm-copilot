# Preflight Round 1 — Issue #741

Timestamp: 2026-09-29T23-10
Plan: docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/plan.2026-09-29T22-26.md
Directive: DIRECTIVE: PREFLIGHT VALIDATION ONLY
Reviewer: atomic-executor
Worktree HEAD at review: 74e946aa14ff8046eeddb26c78ec3d577a2f74a6 (branch bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741; remote branch at the same SHA)

PREFLIGHT: REVISIONS REQUIRED
CONVERGENCE: NO FURTHER ROUNDS EXPECTED

The whole plan was reviewed in one pass. Two defects were found. Both are local text changes to D6, P1-T3, and P1-T9, and neither changes task order, task count, the write list, or any expected count.

## Defects

### Defect 1 — D6 permits a `run_helper_sourced` form that aborts under kcov (CI only)

- Location: D6; P1-T9.
- Finding: D6 requires only that the child shell "sources `"${HELPER}"`, clears nounset with the literal `set +u`, and then runs the caller's body". It does not require the `source` and the `set +u` to run inside a shell function. The helper enables `set -euo pipefail` at its top level (`.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh` line 42). Suppose the child shell runs `source "$1"; set +u` at the top level of the child shell. Under kcov, the PS4 trace of that top-level `set +u` then expands `${BASH_SOURCE}` while nounset is on, and `${BASH_SOURCE}` is unset at that level, so the test aborts. The current `load_helper` wrapper exists to avoid this (`tests/shell/test_cleanup_worktrees_scan_helper.bats` lines 42-44). The research records the same trap (research section 6.3, line 250). However, the research's suggested shape at line 214 (`bash -c 'source "$1"; set +u; shift; <body>'`) is the top-level form that triggers it, and D6 inherits that ambiguity. The failure appears only in the P2-T12 CI run, not in any local gate (P1-T9, P1-T18, P2-T3), so the plan cannot detect it before commit.
- Impact: a conforming implementation can pass every local gate and then fail AC-11 in CI. That forces a Phase 2 remediation loop and a second CI run.
- Plan delta (replace the first two sentences of D6 with):

  > D6 — `load_helper` removal (AC-8). `tests/shell/test_cleanup_worktrees_scan_helper.bats` gains one file-local function `run_helper_sourced`, placed after `setup()`. It runs `run env CLEANUP_WT_SCAN_GITFILE_NAME=dotgit` over a child shell whose script first defines a function named `source_helper` whose body sources its first argument and then runs the literal `set +u`, then calls `source_helper` with `"${HELPER}"`, and then runs the caller's body with the caller's arguments. The `source` and the `set +u` run only inside `source_helper`, never at the top level of the child shell: the helper enables nounset at its top level, and under kcov the PS4 trace of the next top-level command expands `${BASH_SOURCE}`, which is unset at the top level of the child shell. The function is not named `load_helper`.

  The remaining D6 sentences (comment contains PS4 exactly once and no literal `set +u`; the drive-letter test calls it and no longer restates the rationale) are unchanged.

- Plan delta (P1-T9): append the command `grep -c -F "source_helper() {" tests/shell/test_cleanup_worktrees_scan_helper.bats` after the `run_helper_sourced` grep, and append "the `source_helper() {` count is 1" to the Acceptance line after the `run_helper_sourced` clause. This keeps the `set +u` count at 1 and the PS4 count at 1, so those two assertions are unchanged. The added grep is not the last command, so the artifact's top-level `EXIT_CODE:` is still the bats run's exit code.

### Defect 2 — P1-T3 T13/T14 "retargeted" bodies can carry `load_helper`, which P1-T9 and P2-T7 then reject in a file those tasks do not own

- Location: P1-T3 (T13, T14); P1-T9 command `grep -rn load_helper tests`; P2-T7 third and sixth greps.
- Finding: T13 and T14 are specified as "the body of `tests/shell/test_cleanup_worktrees_scan_helper.bats` lines 69-83 [85-101] retargeted to source only `${ELIB}`". Those source lines contain `load_helper() { source "$1"; set +u; }`, a `load_helper "$1"` call, and a comment naming `load_helper` and PS4 (lines 72-75, 88-91). A literal retargeting keeps the `load_helper` tokens, and the tests' current names contain `scan_helper_is_absolute_path`. NEW-SUITE is created in P1-T3. P1-T9's `grep -rn load_helper tests` and P2-T7's `grep -rn load_helper tests` and `grep -rl scan_helper_is_absolute_path ... tests/shell` then fail on NEW-SUITE. Repairing them would write `tests/shell/test_cleanup_worktrees_scan_roots.bats` from P1-T9 or P2-T7, whose titles do not name that file (blast-radius rule). D4 states that these tests need no `set +u`, but P1-T3 does not carry the constraint or check it.
- Impact: whether P1-T9 passes depends on how the executor reads "retargeted". The repair path would write a file outside the task that names it.
- Plan delta (P1-T3, replace the T13 and T14 bullets' "retargeted" wording with):

  > (T13) ...: a child shell sources `${ELIB}` at its top level (the enumeration library never enables nounset), shifts, and runs the candidate loop of `tests/shell/test_cleanup_worktrees_scan_helper.bats` lines 77-79 calling `cleanup_wt_is_absolute_path` over `/abs`, `C:/x`, `c:/x`, `C:\x`; status 0 and empty output.
  > (T14) ...: the same child-shell form running the loop of lines 93-97 over `../rel`, `rel`, `C:rel`, and the empty string; status 0 and empty output.
  > No line of NEW-SUITE contains the tokens `load_helper`, `set +u`, or `scan_helper_is_absolute_path`.

- Plan delta (P1-T3 Commands and Acceptance): insert `grep -c -F "load_helper" tests/shell/test_cleanup_worktrees_scan_roots.bats`, `grep -c -F "set +u" tests/shell/test_cleanup_worktrees_scan_roots.bats`, and `grep -c -F "scan_helper_is_absolute_path" tests/shell/test_cleanup_worktrees_scan_roots.bats` before the `git status` command. Append to Acceptance: "each of the three new greps prints 0 (exit 1 is the pass condition here)". `git status` remains the last command, so the artifact's top-level `EXIT_CODE:` is unchanged.

Delta self-check: both deltas use single-line, placeholder-free tokens (`source_helper() {`, `load_helper`, `set +u`, `scan_helper_is_absolute_path`). Each added grep can fail, and each is satisfiable on a correct run at the point in task order where it runs. Neither delta adds a file or a task, and the delta prose uses neutral wording.

## Verified without defect (evidence)

- Citations re-derived against the tree: report library `cleanup_wt_scan_roots` lines 114-150 and override early return at 129-137; `parse_worktree_list` line 85 and `normalize_wt_path` line 150 of the enumeration library; wrapper source order (lines 16-18, 23) and usage entry lines 142-143; scan helper `set -euo pipefail` line 42, predicate lines 73-85, caller line 116; preserve library line 161 and HT1 regex line 471; `tests/shell/test_cleanup_worktrees_report_records.bats` lines 10-23, 30, 33-42, 130; scan-helper suite lines 36-55 and 69-101 and the nine `load_helper` lines (42, 48, 49, 72, 74, 75, 88, 90, 91); `set +u` count 3 and PS4 count 3; SKILL.md bullet lines 129-133; stub scan lines 29 and 38-46; `worktree_list_error/worktree-list.rc` = 128; preserve suite loop at line 176; `.gitattributes` line 1.
- Line counts (`wc -l`): 252, 476, 492, 182, 234, 496, 495, 101, 132, matching P0-T5.
- A2 logic, run inline against HEAD: `run_report_scans` 39 lines and `classify_all_branches` 131 lines; line 476 is `}`.
- Targeted-set `@test` count: 10+5+2+15+26+11+6+11 = 86. Local run `npx --yes bats --formatter tap <TARGETED-SET>`: exit 0, `1..86`, no `not ok`. P1-T18 M = 86 − 2 + 16 = 100.
- `shfmt -d` over CHANGED-SH: exit 0, no output. `shellcheck` over CHANGED-SH: exit 0, no output. This matches the success-case observations stated in P0-T7, P0-T8, P2-T1, and P2-T2.
- Mirror parity: all six canonical/mirror pairs have identical SHA-256; the plain `git diff --no-index --exit-code` on SKILL.md exits 0 with no output. (The guard refuses `cd ... && git ...` chains; the plan's commands are plain and run from the worktree root.)
- Bundle-parity pytest: `14 passed`; `git status --porcelain` stays clean afterward (the lcov addopts writes no tracked file).
- P0-T3 preconditions hold: the three-dot diff against the merge base lists only the three feature-folder documents, and status is clean.
- Existing report-records tests under the new design: `orphan_dir_present` and `report_single_scan` list only `/repo/main`, so no derived root is added. The override test, the two-root derivation test, and the one-scan test keep their exact line counts. The hard-fail test keeps empty output. AC-3 and AC-5 "passes unchanged" are satisfiable.
- Other suites: across all scenario fixtures, the only non-main worktrees are `/repo-wt/*`, so the only new derived root is `/repo-wt`, which does not exist on any host. No suite outside report-records asserts the scan argv (`stub-scan` appears nowhere else).
- Fixture derivation traced by hand against D2: kept `/repo/main-wt` (duplicate of a default root), `/repo/main-wt/a-wt`, and `/scratch/planhome` (`/Scratch/PlanHome` deduplicated); excluded `/repo` (ancestor of main), `/repo/main` (equal), `/repo/main/.claude` (inside main), `/scratch/planhome/ph1/inner` (inside a registered worktree), and `/scratch/planhome/ph1` (equal to one). T1, T3, and T12 expected lines are consistent.
- P1-T4 pass/fail split traced against current code: T5–T11 fail through `IFS=:` splitting (T10 through pathname expansion of `/*`); T13 and T14 fail with command-not-found output; T15 fails because the inline predicate ignores the override; T4 and T16 pass. 14 `not ok` lines and 2 `ok` lines.
- Filter arithmetic: P1-T5 `cleanup_wt_is_absolute_path` selects T13 and T14 (2). P1-T6 `cleanup_wt_scan_roots|CLEANUP_WT_ORPHAN_ROOTS|run_report` selects T1–T12 (12). P1-T7 `preserve_relative_path_reason` selects T15 and T16 (2). P1-T8 `scan-dirs` selects 3 of the 5 scan-helper tests. No gate runs a deliberately failing test before its fix.
- Windows roots: `normalize_wt_path` maps `C:\x` to `c:/x`. A derived parent `C:` (from `C:/wt`) normalizes to `c:`, and the main path `c:/...` begins with `c:/`, so it is excluded as an ancestor. The main worktree's parent is excluded by the "M begins with N/" rule.
- D7: "semicolon", "default pair", and "always added" each occur 0 times in both files today. After the edit, counts are ≥1, and "semicolon" occurs exactly 1 time in the wrapper. The SKILL.md numstat of 11 added and 3 deleted follows from 5 old lines, 13 new lines, and a 2-line common prefix with no common suffix.
- CI: `.github/workflows/_shell-coverage.yml` declares `workflow_dispatch` (line 5). Artifact `shell-coverage` uploads `artifacts/pester/kcov/**`, so `cov.xml` sits at the download root. `shell_qc_lib.sh` lines 290-291 print `Bash coverage (lines): NN.N%` on success. A recorded run (`docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/evidence/qa-gates/shell-coverage-files.2026-09-28T22-35.md`) shows repo-relative `.claude/skills/cleanup-merged-worktrees/scripts/...` filenames with per-file line rates of 0.875–0.976 for the five CHANGED-SH files. A1's `filename="<path>"` match therefore returns numeric rates.
- Blast radius: every repository file written is the first backticked path in its own create or update task title (P1-T2, P1-T3, P1-T5–P1-T17, P2-T14). All evidence paths resolve under FEATURE/evidence/{baseline,regression-testing,qa-gates,other}/. Scratch scripts and CI downloads go to SCRATCH. The AC-12 boundary files are not written by any task.
- Command text: no planned command contains the words bash, pwsh, or wsl, and none uses a heredoc. jq is used only through `gh --jq`.
- Evidence accounting: each multi-command task's top-level `EXIT_CODE:` source is its last non-grep command. Tasks whose expected exit is non-zero (P1-T4, P2-T14, P0-T10/P2-T6 case b) carry `ExpectedExitCode: 1`. No task has a SKIPPED path. Coverage values are numeric in P0-T12, P2-T12, and P2-T13.

## Non-blocking note

- D9 limits AC-11's `shfmt -d`/`shellcheck` clause to CHANGED-SH. Evidence observed during this review supports that reading: `shfmt -d` on the existing `tests/shell/test_cleanup_worktrees_scan_helper.bats` exits 1 (the repository's bats files use 4-space indentation, not shfmt default tabs), and `shellcheck` reports SC2016 on it. The planner may add this observation to D9 so the audit has it on record. No change is required for execution.
