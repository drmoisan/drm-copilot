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
- **Per-file `cov.xml` entry — DEFERRED to `[P10-T6]`, with the reason stated.** This task also
  asks whether the produced `cov.xml` carries a per-file entry whose `filename` names an existing
  `scripts/bash/*.sh` file together with a `line-rate` attribute, quoting one such entry verbatim.
  No run available to this executor emitted that entry in a form this executor can read: the
  `cov.xml` artifact resides on the CI runner, this executor holds no `Bash(gh *)` grant with which
  to download it, and the later run 34213641449 produced no coverage output at all because the
  coverage step aborts when a test fails, which is the expected state of the suite at the Phase 2
  checkpoint. Rather than record an invented per-file figure that no run printed, this sub-item is
  deferred to `[P10-T6]`, which runs the coverage stage against a green suite and reads `cov.xml`
  directly. `[P10-T7]` reads the per-file `line-rate` from that same run and already carries an
  explicit fallback for the case where no per-file entry exists.
- **The headline value is complete and is not affected by that deferral.** `[P10-T7]`'s mandatory
  baseline input is the headline percentage, which is recorded above as **93.5**, captured on the
  pre-change tree. No substitution was made for it.

## Why run 34213641449 supplies no coverage headline, and why that is not a gap

The later CI round on head SHA `005b7b3074db361060e841e3875e2424efa42110` concluded `failure` with
three failing tests: 289, 290, and 291, the three `[expect-fail]` cases `[P2-T2]` authored. The
workflow's coverage step does not run after a failing test step, so that round printed no
`Bash coverage (lines):` headline. That is the expected consequence of the deliberate red state at
the Phase 2 checkpoint, not a degraded coverage outcome, and neither of the two degraded branches
this task defines (an empty percent value, or no headline from a completed coverage step) applies to
it. The authoritative baseline remains run 34211209394 on the pre-change head SHA
`0edc15e030d9a79307e1399e9658e95b2cd6066d`.

Verdict: PASS. The baseline headline is captured, is authoritative, and is 93.5%. The per-file
`cov.xml` observation is recorded as deferred to `[P10-T6]` with the reason stated above.
