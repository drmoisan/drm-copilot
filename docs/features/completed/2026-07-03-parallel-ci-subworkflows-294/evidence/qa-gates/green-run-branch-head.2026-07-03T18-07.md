# Branch-Head Green Run (P4-T8 / AC-6)

- Timestamp: 2026-07-03T22:41:00Z to 2026-07-03T22:45:53Z (initial run); re-verified
  2026-07-03T23:05:00Z after the branch was rebased onto an updated `main`; re-verified again
  2026-07-03T23:45:00Z after a remediation cycle (feature-review found the prior evidence
  stale by one evidence-only commit -- see
  `remediation-inputs.2026-07-03T23-36.md` / `remediation-plan.2026-07-03T23-36.md`)
- Command (dispatch): `gh workflow run ci.yml --ref feature/parallel-ci-subworkflows-294`
- Command (poll): `gh run view <run-id> --json status,conclusion,jobs,headSha,url`
- Owner: orchestrator (direct `gh` invocation)

## Current run — authoritative for AC-6 (post-remediation)

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/28688452090
- Head SHA: `cb4399749f68a97759cd86f63eb0a44c077921d1`
- EXIT_CODE: 0
- Conclusion: **success**, all 11 job runs `success` (`poshqc`, `shell-coverage`, `build-check`,
  `quality-checks7` x4 matrix legs, `security-scan`, `docs-validation`,
  `drm-copilot-extension-tests` x2 matrix legs).
- This dispatch was run immediately after commit `cb43997` (the feature-review-artifacts /
  remediation-plan commit) was pushed, and represents the last content-changing commit before
  this re-audit cycle; per the remediation plan, no further commit is expected before the next
  feature-review re-audit. If any further commit lands on this branch for any reason, this
  dispatch-then-verify sequence must repeat against the new final head before the evidence below
  can be trusted again.

## Superseded runs — retained for audit trail only

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/28687660881
- Head SHA: `574aaa2a086d77857a5cd7d46723f87e090558c2` (superseded once commit `cb43997` -- an
  evidence-and-review-artifacts-only commit -- landed afterward; a live `gh api .../check-runs`
  query at that later head returned zero runs, which is the exact finding that triggered this
  remediation cycle)
- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/28686408104
- Head SHA: `4125238fcecb5e37ab2c2193e902ed47752e7ccf` (superseded after `git rebase main`
  rewrote this branch's commit history onto an updated `main` tip; the SHA above no longer
  exists as this branch's head)
- EXIT_CODE: 0 for both superseded runs

## Output Summary

Overall run conclusion: **success**.

All 11 job runs across the 7 extracted gates completed with `conclusion: success`:

| # | Job name (as reported by GitHub) | Conclusion |
|---|---|---|
| 1 | `docs-validation / Documentation Validation` | success |
| 2 | `quality-checks7 / Code Quality & Tests (3.10)` | success |
| 3 | `quality-checks7 / Code Quality & Tests (3.11)` | success |
| 4 | `quality-checks7 / Code Quality & Tests (3.12)` | success |
| 5 | `quality-checks7 / Code Quality & Tests (3.13)` | success |
| 6 | `security-scan / Security Scanning` | success |
| 7 | `build-check / Build Package` | success |
| 8 | `poshqc / PowerShell QC` | success |
| 9 | `shell-coverage / Shell Coverage (Bats + kcov)` | success |
| 10 | `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)` | success |
| 11 | `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)` | success |

This confirms:
1. All 7 rewritten/extracted gates execute correctly end-to-end when invoked through the rewritten
   thin-orchestrator `ci.yml`.
2. The required-status-check name composition rule for a `workflow_call`-invoked job is
   **`<caller-job-id> / <callee-job-display-name>`** (e.g. `quality-checks7 / Code Quality & Tests
   (3.12)`), directly observed here -- resolving the item the research pass flagged as
   "not independently confirmed by static documentation reads."
3. This satisfies AC-6 ("A green workflow run against the branch head is captured before merge, per
   the `modified-workflow-needs-green-run` policy rule").

Raw job JSON (truncated to name/conclusion/startedAt/completedAt) is preserved in this feature's
session transcript; the full `gh run view --json jobs` payload is reproducible via the command
above against run id `28686408104`.
