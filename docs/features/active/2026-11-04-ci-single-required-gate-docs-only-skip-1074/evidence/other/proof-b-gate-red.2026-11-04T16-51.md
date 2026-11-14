# Proof B: Gate Red When One Needed Job Fails (Issue #1074)

Timestamp: 2026-11-04T16-51
Task: [P7-T2], [P7-T3]
Command: git commit (throwaway step appended to .github/workflows/_docs-validation.yml); git push origin bug/ci-single-required-gate; bounded poll of gh run view 41868374284 --json jobs (60 s interval); gh run view 41868374284 --log --job 126719632406; gh run view 41868374284 --log --job 126708427418; gh api "repos/drmoisan/drm-copilot/commits/16be68a1052ea67126062480cd8d51f576b82a68/check-runs?check_name=CI%20Required%20Gate"
EXIT_CODE: 0
Output Summary:
- Proof B commit (throwaway): 16be68a1052ea67126062480cd8d51f576b82a68, pushed without force; it appends the step `Issue 1074 proof B deliberate failure` (`shell: bash`, `run: exit 1`) to the `docs-validation` job.
- Run: https://github.com/drmoisan/drm-copilot/actions/runs/41868374284 (event `pull_request`), run conclusion `failure`.
- `Change scope`: `code=true reason=NON_ALLOWLISTED_PATH: .github/workflows/_docs-validation.yml`.
- `docs-validation / Documentation Validation`: `failure` (job 126708427745).
- `CI Required Gate`: `failure` (job 126719632406); check-runs API `total_count` 1, `app.id` 15368, conclusion `failure`.
- Gate summary row: `| docs-validation | failure | success | fail |`.
- Verdict line: `Verdict: FAIL (result not accepted: docs-validation)`.
- Every other row `success` with verdict `ok`, so exactly one row is red.

## Gate Summary (from the gate job log)

| Job | Result | Accepted | Verdict |
|---|---|---|---|
| build-check | success | success | ok |
| changes | success | success | ok |
| docs-validation | failure | success | fail |
| drm-copilot-extension-tests | success | success | ok |
| full-run-marker | success | success | ok |
| npm-audit-gate | success | success | ok |
| poshqc | success | success | ok |
| quality-checks7 | success | success | ok |
| root-typescript-tests | success | success | ok |
| security-scan | success | success | ok |
| shell-coverage | success | success | ok |

Verdict: FAIL (result not accepted: docs-validation)

## Justification for the Proof B Change

- `docs-validation` runs in every scope on one `ubuntu-latest` runner, so the failure is cheap and deterministic.
- `_docs-validation.yml` is pinned by no suite except the event-field scan of `tests/scripts/workflows/CiWorkflow.Tests.ps1`; the added step reads no event field, so it does not trip that scan.
- Every other job stays green, so exactly one summary row turns red.
- The step is bash with an explicit `exit 1`, so the `pwsh` exit-leak pattern in `.claude/rules/ci-workflows.md` does not arise.
- The commit is reverted in [P7-T4] and does not remain in the final head tree.
