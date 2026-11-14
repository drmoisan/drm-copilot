# Proof A: Full Run on the Implementation Head (Issue #1074)

Timestamp: 2026-11-04T16-31
Task: [P7-T1]
Command: gh run list --branch bug/ci-single-required-gate --workflow ci.yml (bounded poll, 60 s interval); gh run view 41864628204 --log --job 126704224626; gh run view 41864628204 --log --job 126695561897; gh pr checks 1077 --json name,bucket,workflow; gh api "repos/drmoisan/drm-copilot/commits/e3ef692e5fc34efa24c33f3513c12b32a1776f6e/check-runs?check_name=CI%20Required%20Gate"
EXIT_CODE: 0
Output Summary:
- Run: https://github.com/drmoisan/drm-copilot/actions/runs/41864628204 (workflow `CI`, event `pull_request`, PR #1077).
- Head SHA: e3ef692e5fc34efa24c33f3513c12b32a1776f6e.
- `Change scope`: `code=true reason=NON_ALLOWLISTED_PATH: .agents/skills/execution-environment/SKILL.md` (full run).
- `CI Required Gate` conclusion: `success` (job 126704224626); gate log header `CI Required Gate: scope=full code=true`; verdict line `Verdict: PASS`.
- Every summary row `success` (11 rows; table below).
- Context name: `CI Required Gate` (one entry in `gh pr checks 1077`, workflow `CI`, bucket `pass`).
- Check-runs API: `total_count` 1, `name` `CI Required Gate`, `app.id` 15368 (`app.slug` `github-actions`), conclusion `success`.

## Gate Summary (from the gate job log)

| Job | Result | Accepted | Verdict |
|---|---|---|---|
| build-check | success | success | ok |
| changes | success | success | ok |
| docs-validation | success | success | ok |
| drm-copilot-extension-tests | success | success | ok |
| full-run-marker | success | success | ok |
| npm-audit-gate | success | success | ok |
| poshqc | success | success | ok |
| quality-checks7 | success | success | ok |
| root-typescript-tests | success | success | ok |
| security-scan | success | success | ok |
| shell-coverage | success | success | ok |

Verdict: PASS

## Notes

- GitHub Actions reported `degraded_performance` during this run. The run stayed queued about 15 minutes, and the jobs API returned stale per-job status (four jobs listed `in_progress` after `CI Required Gate`, which needs them, had completed). The terminal condition used was the `CI Required Gate` job status, and the result table above is the runner's `needs` view as written to the gate log.
- JSON responses were parsed with the `gh --jq` filter (the executor has no PowerShell tool route for inline parsing); the values recorded are the parsed fields named by the plan.
