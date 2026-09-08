# Baseline — bash line coverage (`shell-qc.sh test --coverage`)

Timestamp: 2026-09-08T09-49
Task: [P0-T5]
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (CI run 34211209394; the workflow's coverage step runs `bash scripts/bash/shell-qc.sh test --coverage`)
EXIT_CODE: 0
ExpectedExitCode: 0

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bash scripts/bash/shell-qc.sh test --coverage'"`
- Substitute actually run: the CI route, dispatched by the orchestrator, run
  `34211209394` at `https://github.com/drmoisan/drm-copilot/actions/runs/34211209394`, ref
  `bug/cleanup-worktrees-preserve-file-consolidation-637-r2`, head SHA
  `0edc15e030d9a79307e1399e9658e95b2cd6066d`, conclusion `success`.
- Reason: `pwsh` is refused unconditionally in this worktree, and neither `bats` nor `kcov` is on
  the Git Bash PATH, so the coverage stage cannot run locally. The plan's
  `## Toolchain invocation shape` paragraph authorizes the CI route for the coverage stage of
  `[P0-T5]` and `[P10-T6]` specifically, and the orchestrator authorized it. CI is canonical when
  local and CI disagree on a coverage value.

Output Summary:

- **Headline recorded: `Bash coverage (lines): 93.5%`.** The numeric value is **93.5**. No branch
  column is printed, which is expected: `kcov` measures line coverage only, and
  `print_coverage_summary` at `scripts/bash/shell_qc_lib.sh` lines 277-291 formats a single
  line-rate value.
- Neither degraded outcome occurred. The headline printed with a non-empty percent value, so
  `extract_cobertura_line_rate` read a `line-rate` attribute successfully and
  `artifacts/pester/kcov/cov.xml` was parseable.
- **This is the authoritative pre-change baseline headline** for the `[P10-T7]` comparison. It was
  captured on the pre-change tree this run. No figure was inherited from sibling children 630, 631,
  632, 545, or 635; each of those changed the test surface since the last recorded baseline, so any
  inherited figure would be stale.
- `artifacts/pester/kcov/cov.xml` was produced by the run: the headline could not have printed
  otherwise, because `extract_cobertura_line_rate` returns 1 and `print_coverage_summary` prints
  nothing at all when that file is missing or carries no `line-rate` attribute. The file is not
  present in this worktree (`artifacts/pester/kcov/` does not exist locally), because the coverage
  stage ran on the CI runner.
- **PENDING-CI ROUND — per-file `cov.xml` entry.** The remaining observation this task requires,
  namely whether the produced `cov.xml` carries a per-file entry whose `filename` names an existing
  `scripts/bash/*.sh` file together with a `line-rate` attribute, with one such entry quoted
  verbatim, is not available to this executor: the artifact resides on the CI run and this executor
  holds no `Bash(gh *)` grant with which to download it. The orchestrator supplies that entry.
  **`[P0-T5]` therefore stays unchecked in the plan until that value is recorded here.** The
  headline value above is complete and is not affected by this gap.

Verdict: PARTIAL. The headline baseline is captured and is authoritative. The per-file `cov.xml`
observation is PENDING-CI ROUND.
