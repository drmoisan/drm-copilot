# Evidence Location Validation

Timestamp: 2026-09-07T16-30
Task: [P6-T13]

Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
EXIT_CODE: 0

Output: none.

## Branch taken

The **primary** branch applies. `poetry` resolved in this environment and the validator ran to
completion, exiting 0 with no output. The substitution branch described in the [P6-T13] task text —
recording the refusal text verbatim and running the three substitute observations
(`git status --porcelain --untracked-files=all -- artifacts`,
`git ls-files <feature>/evidence`, and
`git status --porcelain --untracked-files=all -- <feature>/evidence`) — was **not needed** and was
therefore not exercised. This is recorded explicitly rather than being left unstated.

## What the exit code means

`scripts/dev_tools/validate_evidence_locations.py` scans the repository for evidence artifacts
written outside the canonical `<FEATURE>/evidence/<kind>/` scheme and reports any that fall under a
forbidden `artifacts/` sub-path. An exit code of 0 with no output means the validator found no
violation.

## Canonical location statement

All evidence produced by this remediation cycle resolves under

`docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence/<kind>/`

with `<kind>` in `remediation-baseline`, `regression-testing`, `qa-gates`, and `other`, as the plan's
non-overridable evidence-location clause requires. No artifact was written to
`artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`,
`artifacts/coverage/`, `artifacts/evidence/`, `artifacts/regression-testing/`, or
`artifacts/post-change/`. The calling directive supplied only the canonical location, so there was
no non-canonical path to reject and no `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record is required.

Output Summary: the validator exited 0 with no output, so no evidence artifact in this repository
sits outside the canonical `<FEATURE>/evidence/<kind>/` scheme. The primary branch of the [P6-T13]
acceptance applies; the substitution branch and its three substitute observations were not needed
and were not run.
