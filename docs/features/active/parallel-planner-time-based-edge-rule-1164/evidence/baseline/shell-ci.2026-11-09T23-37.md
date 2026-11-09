# Bash Baseline from CI on main (P0-T7)

Timestamp: 2026-11-09T23-37
Command: gh run list --workflow ci.yml --branch main --limit 10; gh run view 42703258177 --json jobs; gh run view --job 129453497304 --log; gh run download 42703258177 -n shell-coverage -D SCRATCH/shell-p0
EXIT_CODE: 0
Output Summary:
- Run: 42703258177 (ci.yml, event push, branch main, head ff9d8afc0a61ac723cd449b0c0658ea42680cd2e, created 2026-11-09T21:31:12Z), the newest main run; its CI full run job (129453496942) concluded success.
- shell-coverage / Shell Coverage (Bats + kcov) (job 129453497304): success.
- Run shell-qc check (shfmt diff + shellcheck) step: success (0 findings; the step fails on any finding).
- Bats: plan 1..799; 799 ok, 0 not ok.
- kcov repo-wide line coverage (cov.xml): 3384 / 3574 = 94.7%.
- kcov line coverage of .claude/lib/bash/parallel-manifest-validate.sh: 117 / 120 = 97.5% (line-rate 0.975).
