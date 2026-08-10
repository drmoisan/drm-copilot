# Phase 3 Shell Gate — Issue #462

Timestamp: 2026-08-10T16-22

Task: [P3-T17]
Command:
```
git push origin HEAD
gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-08-10T09-25
gh run view 31407914330 --json status,conclusion,url,headSha
gh run view 31407914330 --log | grep "Bash coverage (lines)"
```
EXIT_CODE: 0

Bash verification is CI-only on this win32 host (binding constraint 1). No local
bats, shfmt, shellcheck, or kcov run was attempted or recorded.

## Output Summary

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/31407914330
- Run ID: 31407914330
- headSha at dispatch: `c8f906cbc1cbc7069e1cad989898ac988e04e2b5`
- Conclusion: **success**
- `Run shell-qc check (shfmt diff + shellcheck)` — **success** (the [P1-T6] step;
  this is its first green run, confirming the step is correctly placed and is a
  genuine pass/fail gate)
- `Run shell-qc test with coverage` — **success**
- bats: `1..229`, **229 ok, 0 not ok**
- Printed coverage line: `Bash coverage (lines): 92.4%`
- Threshold check: 92.4% >= 85% (`.claude/rules/quality-tiers.md`). The workflow has
  no coverage-threshold gate, so this value is read from the printed line, not
  inferred from the run conclusion.
- Baseline was 91.5% ([P0-T5]); the new library and its suites raised line coverage
  by 0.9 points.

## Iteration History (four dispatches to green)

| Run | headSha | Conclusion | Failing stage and cause |
| --- | --- | --- | --- |
| [31405454023](https://github.com/drmoisan/drm-copilot/actions/runs/31405454023) | `ca4c2815` | failure | `check` step — shellcheck findings: SC2178/SC2128 name conflation and SC1087 in `parallel-cohorts.sh`, SC2015 in `compute-concurrency-batches.sh`, SC1003 in the YAML scanner, SC2034 across the multi-file library, plus eight pre-existing SC2015 infos in `scripts/bash/shell_qc_lib.sh` and `scripts/bash/cleanup_worktrees_lib.sh` |
| [31406380675](https://github.com/drmoisan/drm-copilot/actions/runs/31406380675) | `91c9cc43` | failure | `check` step — one residual SC1003: `local backslash='\'` |
| [31406575717](https://github.com/drmoisan/drm-copilot/actions/runs/31406575717) | `c1b535af` | failure | `check` green; coverage step — bats sources libraries from `setup()`, so `declare -A` created function-local arrays and the node table failed with an arithmetic-subscript error |
| [31407315530](https://github.com/drmoisan/drm-copilot/actions/runs/31407315530) | (prior head) | failure | coverage step — the discovery fixture was silently gitignored by the generic Python `lib/` rule, and `parallel_yaml_subset.bats` called `pc_enforce_c_locale` without sourcing `parallel-common.sh` |
| [31407914330](https://github.com/drmoisan/drm-copilot/actions/runs/31407914330) | `c8f906cb` | **success** | — |

Every file changed during iteration was re-mirrored into
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/` before the
next dispatch, per [P3-T16].

## Discharge Status

This dispatch verifies that the [P1-T6] `check` step runs and passes. It does **not**
discharge the `modified-workflow-needs-green-run` policy rule
(`.claude/skills/feature-review-workflow/SKILL.md:73`), because later phases add
commits and that rule requires a run whose head SHA matches the terminal branch head.
[P7-T15] supplies the head-SHA-matched discharge.

## Findings Worth Recording

1. **Pre-existing shellcheck findings.** No workflow ran `shell-qc.sh check` before
   [P1-T6] added the step, so eight SC2015 (info) findings in
   `scripts/bash/shell_qc_lib.sh` and `scripts/bash/cleanup_worktrees_lib.sh` had never
   been surfaced. They flag the `<test> && <assign> || true` capture idiom that
   `.claude/rules/shell.md` itself mandates. They were resolved with justified
   file-wide suppressions rather than by restructuring pre-existing production shell.
2. **`.gitignore` blind spot.** The generic Python `lib/` rule excludes any directory
   named `lib` at any depth. The repository already carries three negations for the
   real `.claude/lib` trees; a fourth was required for the Shell-QC discovery fixture.
   Any future fixture or source tree containing a `lib/` directory needs the same
   treatment, and the failure mode is silent: the file simply never reaches CI.
