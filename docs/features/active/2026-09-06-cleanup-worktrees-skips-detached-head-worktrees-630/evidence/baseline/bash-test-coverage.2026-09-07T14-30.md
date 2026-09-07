# Baseline — Bash Test and Coverage State (Issue #630)

Timestamp: 2026-09-07T14-30

Task: [P0-T6]

Command: `gh workflow run .github/workflows/_shell-coverage.yml --ref epic/cleanup-merged-worktrees-hardening-integration`

EXIT_CODE: 0

Run URL: <https://github.com/drmoisan/drm-copilot/actions/runs/34113725852>

Run conclusion: success

Baseline ref: `epic/cleanup-merged-worktrees-hardening-integration` at commit `a36b6dca` (the unmodified baseline tree).

## Command Substitution

The plan's [P0-T6] literal is:

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && bash scripts/bash/shell-qc.sh test --coverage'
```

That literal wrapper was unavailable in this environment and was not run. Two substitutions
were applied and are recorded here.

1. **Worktree path.** The plan names the stale worktree `agent-a06652a3fd875c703`. The real
   worktree for this run is `agent-adf4f49cbc48904be`.
2. **Invocation form.** The `wsl -d Ubuntu -- bash -lc '...'` wrapper is refused by the
   worktree-isolation guard in this environment, as recorded in the [P0-T4] artifact, and
   `kcov` has no local route on this machine. The coverage stage was therefore obtained
   from the CI fallback workflow `.github/workflows/_shell-coverage.yml`, dispatched with
   `gh workflow run` against the baseline ref. The workflow step it executes is
   `bash scripts/bash/shell-qc.sh test --coverage` — the same script and the same
   arguments the plan names, run on a Linux runner where `bats` and `kcov` are installed.
   CI is canonical where a local result and a CI result disagree.

## Toolchain Context

- `bats` is not on the Windows PATH. Where a local bats run was required elsewhere in this
  plan it was invoked as `npx --yes bats <target>`, which reports `Bats 1.13.0` — the same
  version the plan's WSL wrapper would have used.
- `shfmt` v3.12.0 and `shellcheck` 0.11.0 are on the Windows PATH, so
  `scripts/bash/shell-qc.sh check` and `format` run natively.
- `kcov` has no local route. Every TAP-plus-coverage figure in this feature's evidence
  therefore comes from the CI fallback workflow named above.

## Recorded Values

- TAP plan line: `1..290`
- Lines beginning `not ok`: 0
- Coverage headline: `Bash coverage (lines): 93.6%`

Output Summary: The baseline suite reported a TAP plan count of **290** with **no line
beginning `not ok`**, and the run exited 0. The baseline bash line coverage is **93.6**
percent, read from the headline line beginning `Bash coverage (lines):`. This is a measured
numeric value, not a placeholder. It is above the uniform 85 percent line-coverage floor in
`.claude/rules/quality-tiers.md`. No branch-coverage figure is reported, because kcov does
not measure branch coverage for bash and no bash branch-coverage gate applies. These two
numbers — 290 and 93.6 — are the baseline that [P1-T11], [P7-T3], and [P7-T5] are read
against.
