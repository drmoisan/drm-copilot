# Phase 1 Handoff (Issue #931)

Timestamp: 2026-10-16T01-28

Handoff target: small-path implementation engineer. In this run the executing agent performs the implementation tasks directly under the same plan.

Task range performed by the engineer: P1-T2 to P1-T26.

## Files the engineer may edit (exactly the five `## Writes` repository paths)

1. `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (edit)
2. `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` (edit, in-place string and wording changes only)
3. `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` (edit, one wording change and new tests)
4. `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1` (create)
5. `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` (edit, one release-flow pin)

No other repository path outside the feature folder is edited.

## Helper contracts (plan `## Decisions` item 2)

- `function Get-CheckSetVerdict -Checks <object[]>` (empty collection allowed) returns `[pscustomobject]@{ Verdict; Detail }`. Verdict is one of `pass`, `fail`, `unknown`, `pending`, `empty`. Precedence: an empty set returns `empty`; any `fail` or `cancel` returns `fail`; any bucket outside `pass`, `skipping`, `pending`, `fail`, `cancel`, or an absent, null, or blank bucket returns `unknown`; any `pending` returns `pending`; otherwise `pass`. Detail is the first unrecognized bucket value in array order, or `(missing)`, and an empty string for every other verdict. The comparison is exact and case-sensitive. An all-`skipping` set returns `pass`.
- `function ConvertFrom-CheckPollOutput -Output <object[]>` (empty collection allowed) returns `[pscustomobject]@{ Succeeded; Checks }`. The lines are joined with a newline. Blank text returns `Succeeded = $false`. Parsing uses `ConvertFrom-Json -ErrorAction Stop` inside a `try` whose `catch` names `[System.ArgumentException]`. Malformed text, or a null or scalar element, returns `Succeeded = $false`. An empty array returns `Succeeded = $true` with `Checks = @()`.

## Wait-ForPullRequestChecks behavior (plan `## Decisions` item 3)

The poll is `gh pr checks <PrNumber> --json bucket` with no `--required`. If the first successful poll is unparsable, the function returns 1 with `Could not parse the check results for PR #<n>.`. The Phase B verdict drives the loop: `fail` returns 1 with `A check failed for PR #<n>.`; `unknown` returns 1 with `A check reported an unrecognized bucket for PR #<n>: <value>.`; `pass` returns 0; `pending` and `empty` re-poll within `CompletionMaxAttempts`, then time out with "did not complete within the timeout". A non-zero or unparsable completion re-poll consumes an attempt and is treated as `@()`.
