# Preflight Fixes — Advisory-Fix Plan (#1050)

Timestamp: 2026-11-19T12-15
Plan: docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/advisory-fix-plan.2026-11-19T12-07.md
Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>
EXIT_CODE: 0
Output Summary: plan validation passed (branch-current CLI); single-pass review found one trivial defect, fixed in task text; no substantive defect.

## Fixes

1. [P1-T2] | literal-formatting (unsatisfiable-as-worded test double) | The task asked the `Invoke-GhExe` test double to write "one warning record". A `Write-Warning` record goes to the warning stream (3), which `2>&1` does not merge, so `ErrorOutput` would stay empty and the asserted outcome could not occur. The wording now states that the double writes one error-stream record (`Write-Error`) carrying warning text. The asserted outcome (`Output` parses as JSON, `ErrorOutput` holds the warning text) is unchanged.

## Design check

- Item 1 (pagination): P1-T1; failing test `finds a same-name ruleset on the second page and issues no write`.
- Item 2 (stderr separation and messages): P1-T2; failing tests `returns standard output only when the command writes a warning to standard error`, `names the gh call and its error output when listing fails`, `names the gh call when the ruleset list is not JSON`.
- Item 3 (copy-mode tests directory): P1-T3 (guard, contract helper negative case) and P1-T4 (README); failing test `harness workflows are destination-generic`.
- Bundle parity: Jest `CI bundle is complete and copies match`; P2-T4 hash check.
