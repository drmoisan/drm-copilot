# Code Review (Issue #723) - Reaudit after remediation cycle 1

Scope: `.github/workflows/publish-mcp-npm.yml`, `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`, `docs/engineering/missed-npm-publish.runbook.md`. Supersedes `code-review.2026-10-01T18-00.md`.

## Change since prior review

Remediation cycle 1 added documentation and evidence only. The diff against origin/main shows no new modification to the workflow, the Pester test file, or the runbook beyond what the prior review covered. The prior code analysis therefore stands.

## Workflow step

- Schedule: `$maxAttempts = 14`; sleep after failed attempt k is `min(10*k, 60)`; no sleep after attempt 14. Total 150 + 480 = 630 s (>= 600).
- `$LASTEXITCODE = 0` reset, exact-version operand, `exit 0`/`exit 1`, and the ref guard are unchanged.
- Error message contains the required tokens and no longer contains `tag push did not publish`.

## Pester tests

- Four new tests cover the schedule and recomputed budget, the cap and final-attempt guard, message tokens, and retained invariants. The budget test derives the total from parsed values rather than hard-coding 630.

## Runbook

- New section states the three required facts in neutral language.

## Findings

### Blocking
None.

### Non-blocking
- N1: The runbook does not give the `npm view` command; the workflow message does. Optional addition.
- N2: Lint and per-test pass evidence rely on CI summaries without per-finding detail (accepted limitation under D1-D5).
- N3: The `exit 1` assertion `(?m)^\s*exit 1\s*$` would match any standalone `exit 1` in the step; low risk because the step has a single failure path.
- N4 (closed): the PowerShell coverage-artifact gap noted previously is resolved by `evidence/qa-gates/final-powershell-coverage.md` (96.35 percent line coverage).
