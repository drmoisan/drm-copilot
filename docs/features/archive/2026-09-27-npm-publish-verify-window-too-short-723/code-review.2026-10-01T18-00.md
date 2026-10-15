# Code Review (Issue #723)

Scope: `.github/workflows/publish-mcp-npm.yml`, `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`, `docs/engineering/missed-npm-publish.runbook.md`.

## Workflow step

- Schedule arithmetic verified: `$maxAttempts = 14`; the sleep after failed attempt k is `min(10*k, 60)`; the guard `if ($attempt -lt $maxAttempts)` skips the sleep after attempt 14. Waits k=1..13 are 10+20+30+40+50 = 150, then eight waits of 60 = 480, total 630 s (>= 600).
- `$LASTEXITCODE = 0` reset, exact-version operand, `exit 0`/`exit 1`, and ref guard are unchanged (diff touches only the poll parameters, the sleep, and the error message).
- Error message contains `not yet resolvable`, `publish step succeeded`, `Check the registry`, `re-publishing an existing version fails`; the old text `tag push did not publish` is gone. Single `::error::` line.
- Message string uses `$packageOperand` inside a double-quoted string containing single quotes; this is valid PowerShell and actionlint passes.
- The inline comment documents the schedule and references the issue; it is accurate.

## Pester tests

- Four new tests, appropriately scoped: schedule values plus recomputed budget (derived from parsed values, not hard-coded 630), cap plus final-attempt guard with ordering check, message tokens, and retained invariants.
- Good practice: the budget test parses the values from the step and recomputes the sum, so the test stays correct if the schedule is tuned within the >= 600 s bound.
- Regex `\$maxAttempts\s*=\s*14\b` pins the value 14 in addition to the computed budget; this is intentional per AC-1.

## Runbook

- New section is placed after the verifier-state text and states the three required facts in neutral language.

## Findings

### Blocking
None in code.

### Non-blocking
- N1: The runbook sentence "Check the exact version on the registry" does not give the command; the workflow message supplies `npm view <operand> version`. Optional: add the command to the runbook.
- N2: Lint (PSScriptAnalyzer) and per-test pass evidence rely on CI summaries without per-finding or `[+]` detail (accepted limitation under D1-D5).
- N3: The `exit 1` assertion `(?m)^\s*exit 1\s*$` would also match an unrelated `exit 1` elsewhere in the step; low risk because the step has a single failure path.
- N4: The lingering PowerShell coverage-artifact gap is recorded in the policy audit (R1).
