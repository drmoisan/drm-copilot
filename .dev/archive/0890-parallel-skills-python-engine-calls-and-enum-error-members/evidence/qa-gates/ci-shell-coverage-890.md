# CI Shell Coverage Evidence (Issue 890)

Timestamp: 2026-10-12T21-10

Command:
- `gh run list --workflow ci.yml --branch bug/parallel-skills-python-engine-calls-and-enum-error-members-890 --status completed --limit 1 --json databaseId,headSha,conclusion`
- `gh run view 38306234921 --json jobs` (job `shell-coverage / Shell Coverage (Bats + kcov)`)
- `gh run view 38306234921 --log` (line containing `Bash coverage (lines):`)
- `gh run download 38306234921 -n shell-coverage -D <session scratchpad>/issue-890-shell-coverage`

EXIT_CODE: 0

Provenance: the gh commands were run by the orchestrator under operator constraint (the executor has no `gh` access). The values below were transcribed from the orchestrator's observations at 2026-10-12T21:10Z, not observed directly by the executor.

Deviation: the artifact download directory was the session scratchpad with the `issue-890-` prefix (`issue-890-shell-coverage`) instead of the plan path `artifacts/scratch/890/shell-coverage-890`, as required by the operator. Per-file rates were read from the merged `cov.xml` at the artifact root.

Output Summary:
- PR: #921 (https://github.com/drmoisan/drm-copilot/pull/921)
- ci.yml run ID: 38306234921 (https://github.com/drmoisan/drm-copilot/actions/runs/38306234921)
- Run head SHA: b0f38423d5bc9b9f35cb0fc4c522420fccb93939, equal to `git rev-parse origin/bug/parallel-skills-python-engine-calls-and-enum-error-members-890` at read time (and to local HEAD at the time of this record).
- Job `shell-coverage / Shell Coverage (Bats + kcov)` (job 115000848516): conclusion success.
- Log line: `Bash coverage (lines): 95.2%`
- Bats: zero `not ok` lines in the job log. Passing cases observed include `ok 283 the bash lane reproduces every run corpus fixture` (parallel_mutation_run_parity.bats), `ok 230` through `ok 235` admit cases (parallel_mutation_run.bats), `ok 224 pm_decide_removal lists the dispositions for an out-of-enum disposition` (parallel_mutation_remove.bats), `ok 28 the seven CLI entry points are present in both trees` (parallel_bash_manifest_membership.bats).
- Per-file line-rate (merged cov.xml):
  - .claude/lib/bash/mutate-parallel-run.sh: 1.000 (100.0%) [new]
  - .claude/lib/bash/parallel-mutation-ops.sh: 1.000 (100.0%) [new]
  - .claude/lib/bash/parallel-mutation-cli.sh: 1.000 (100.0%) [new]
  - .claude/lib/bash/parallel-mutation.sh: 0.971 (97.1%)
  - .claude/lib/bash/remove-parallel-item.sh: 1.000 (100.0%)
- All 20 PR checks on that head concluded SUCCESS.

Acceptance evaluation:
- Job conclusion success: PASS.
- Overall `Bash coverage (lines):` value recorded (95.2%) and five per-file rates recorded: PASS.
- Each new file at or above 85% (100.0%, 100.0%, 100.0%): PASS.
- No bats, kcov, or shell wrapper run locally: PASS.
