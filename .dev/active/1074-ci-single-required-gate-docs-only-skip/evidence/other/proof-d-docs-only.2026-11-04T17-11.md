# Proof D: Docs-Only Head, Gate Green (Issue #1074)

Timestamp: 2026-11-04T17-11
Task: [P7-T6]
Command: bounded poll of gh run view 41874737526 --json jobs (60 s interval); gh run view 41874737526 --log --job 126731576072; gh run view 41874737526 --log --job 126730954874; gh api "repos/drmoisan/drm-copilot/commits/914ffb0c28d3f7d3e3bda9fddb0b9aff068656df/check-runs?check_name=CI%20Required%20Gate"; gh pr view 1077 --json mergeStateStatus,headRefOid; gh pr checks 1077 --json name,bucket,workflow
EXIT_CODE: 0
Output Summary:
- Proof D head: 914ffb0c28d3f7d3e3bda9fddb0b9aff068656df (Markdown under the feature folder only: runbook fill and proof A to C evidence).
- Run: https://github.com/drmoisan/drm-copilot/actions/runs/41874737526 (event `pull_request`), run conclusion `success`.
- `Change scope`: `code=false reason=DOCS_ONLY_SINCE_23dd72202a594c0e829072b7c6aee72b47be8140` (the proof C head, as expected).
- `CI Required Gate`: `success` (job 126731576072); check-runs API `total_count` 1, `app.id` 15368, conclusion `success`.
- Gate log header `CI Required Gate: scope=docs-only code=false`; verdict line `Verdict: PASS`.
- `full-run-marker`, `root-typescript-tests`, and `npm-audit-gate` rows: `skipped` (accepted `success, skipped`, verdict `ok`).
- `needs.poshqc.result` (`poshqc` row): `success`.
- Pull request #1077 `mergeStateStatus`: `BLOCKED` (expected: the legacy per-job contexts are still required by ruleset 15241672).

## Gate Summary (from the gate job log)

| Job | Result | Accepted | Verdict |
|---|---|---|---|
| build-check | success | success | ok |
| changes | success | success | ok |
| docs-validation | success | success | ok |
| drm-copilot-extension-tests | success | success | ok |
| full-run-marker | skipped | success, skipped | ok |
| npm-audit-gate | skipped | success, skipped | ok |
| poshqc | success | success | ok |
| quality-checks7 | success | success | ok |
| root-typescript-tests | skipped | success, skipped | ok |
| security-scan | success | success | ok |
| shell-coverage | success | success | ok |

Verdict: PASS

## Legacy Contexts on the Docs-Only Head

`gh pr checks 1077` lists the job-level skips under unexpanded or caller-only names (`poshqc / PowerShell QC shard ${{ matrix.shard }}`, `NPM Audit Gate`, `root-typescript-tests`), so the required contexts `poshqc / PowerShell QC shard 1` to `3`, `root-typescript-tests / Root TypeScript Tests (ubuntu-latest)` and `(windows-latest)`, and the three `NPM Audit Gate / npm audit (...)` contexts do not report. This is the defect the single required gate addresses once the runbook is applied after merge.

This file was committed by the orchestrator in the commit that followed proof D.
