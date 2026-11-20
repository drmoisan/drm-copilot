# Code Review — Issue #310 (release-flow-wait-for-ci)

- Timestamp: 2026-07-05T02-34
- Files reviewed: `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (modified), `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` (modified), `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` (modified), `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` (new)

## Summary

The change replaces a single `gh pr checks $prNumber --watch` call (which fails immediately during the window before GitHub registers workflow checks on a newly opened PR) with a two-phase bounded poll: `Wait-ForPullRequestChecks` waits for check registration, then waits for registration to leave the pending bucket, before `Invoke-FullReleaseFlowGuarded` proceeds to merge. The design follows the repository's existing wrapper-seam pattern (`Invoke-GhExe`) and adds a new `Invoke-Sleep` wrapper seam so tests can assert on retry/backoff behavior without a real wall-clock wait. Code quality is consistent with the surrounding file.

## Design Principles (`.claude/rules/general-code-change.md`)

- **Simplicity first**: The two-phase loop structure (registration loop, then completion loop) is the simplest correct design for the stated problem; no unnecessary abstraction layers were introduced.
- **Reusability**: `Invoke-Sleep` is a small, generically reusable wrapper seam placed alongside the existing `Invoke-GitExe`/`Invoke-GhExe`/`Invoke-ChildPowerShellScript` seams, following the same pattern rather than inventing a new one.
- **Extensibility**: All four new tunables (`RegistrationMaxAttempts`, `RegistrationIntervalSeconds`, `CompletionMaxAttempts`, `CompletionIntervalSeconds`) are optional keyword parameters with sensible defaults, consistent with the "prefer keyword-style parameters with defaults" guidance.
- **Separation of concerns**: `Wait-ForPullRequestChecks` is a pure orchestration function over the `Invoke-GhExe`/`Invoke-Sleep` seams; it does not itself touch the network, matching the existing I/O-isolation pattern in this file.

## Findings

### 1. (Non-blocking) Comment-based help does not restate numeric defaults or worst-case total wait

`Wait-ForPullRequestChecks`'s `.PARAMETER` blocks (lines 185–194) describe each parameter's role ("Maximum number of registration-phase poll attempts before timing out.") but do not restate the default value or the resulting worst-case wall-clock bound. With the shipped defaults (`RegistrationMaxAttempts=24`, `RegistrationIntervalSeconds=5`, `CompletionMaxAttempts=60`, `CompletionIntervalSeconds=10`), the function can block for up to 2 minutes waiting for check registration and up to an additional 10 minutes waiting for completion, entirely within a single VS Code task invocation. This is discoverable by reading the parameter defaults in the signature, but a maintainer skimming only the comment-based help (e.g., via `Get-Help Wait-ForPullRequestChecks -Full`) will not see the derived total.

Suggestion: add one sentence to `.DESCRIPTION` or a `.NOTES` block stating the default worst-case bounds, e.g., "With default parameters, registration is bounded at ~2 minutes (24 × 5s) and completion at ~10 minutes (60 × 10s)."

### 2. (Non-blocking) Untested edge case: zero required checks

If a PR has no required status checks configured at all, `gh pr checks $prNumber --required --json bucket` would return exit code 0 with an empty JSON array `[]`. Tracing the code: `$buckets` becomes an empty array; in the completion loop, `$buckets -contains 'fail'` is false, `$stillPending` is empty/`$null`, and `if (-not $stillPending) { return 0 }` fires — so the function correctly treats "no required checks" as success (vacuously, every required check — of which there are none — has reported pass or skipping). This is almost certainly the intended and correct behavior, and it is consistent with AC3's phrasing ("runs only after every required check reports bucket pass or skipping").

However, none of the six new tests in `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` exercise this specific input shape (`Output = @('[]')`, `ExitCode = 0` on the first poll). `.claude/rules/general-unit-test.md`'s "Scenario Completeness" section calls for edge-case and boundary-condition coverage per unit of behavior. This is a real, reachable input shape (a repository or PR with no required checks) that is not directly exercised.

Suggestion: add one more `It` case asserting `Wait-ForPullRequestChecks` returns `0` when the poll returns `@('[]')` with `ExitCode = 0` on the first call, to make the vacuous-success behavior an explicit, regression-tested contract rather than an implicit consequence of the `Where-Object`/`-contains` logic.

### 3. (Informational) Stray trailing text in `plan.md`

`docs/features/active/2026-07-04-release-flow-wait-for-ci-310/plan.md` line 160 ends with a bare line `DIRECTIVE: PREFLIGHT VALIDATION ONLY` after the closing `---` separator, with no further content. This does not affect the production code and was not acted upon by this review (see `policy-audit.2026-07-05T02-34.md`, "Rejected Scope Narrowing"). It appears to be leftover/unintended text and should be removed for document hygiene, but it carries no functional or policy consequence.

## Naming

- `Wait-ForPullRequestChecks`, `Invoke-Sleep` follow PascalCase/approved-verb conventions. The one PSScriptAnalyzer naming exception (`PSUseSingularNouns` on `Wait-ForPullRequestChecks`) is addressed in the policy audit and is justified/precedented.
- Parameter names (`PrNumber`, `RegistrationMaxAttempts`, `RegistrationIntervalSeconds`, `CompletionMaxAttempts`, `CompletionIntervalSeconds`, `Seconds`) are descriptive and unambiguous; no abbreviations.

## Error Handling and Logging

- Both timeout paths and the genuine-failure path each call `Write-StderrLine` with a specific, distinct message before returning `1`, consistent with the file's existing "fail fast and explicitly" pattern and with `.claude/rules/general-code-change.md`'s error-handling guidance.
- No broad catch-alls or silently swallowed errors were introduced. `ConvertFrom-Json` is not wrapped in a try/catch, but this mirrors the existing risk profile of the file (no other `gh`/`git` JSON-parsing call site in this script catches parse errors either), so this is not a new pattern or a regression in rigor.

## Testing Standards (`.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`)

- **Independence/Isolation**: Each new `It` block establishes its own mocks in its own scope; no shared mutable state leaks between tests beyond the `BeforeEach`-reset `$script:` counters, which is the same pattern used throughout the existing suite.
- **Determinism**: `Invoke-Sleep` is mocked in every test that exercises `Wait-ForPullRequestChecks` or `Invoke-FullReleaseFlowGuarded`; no test relies on a real `Start-Sleep`. Poll counts are deterministic via `$script:ghCallCount`/`$script:sleepCallCount` closures.
- **Readability**: Test names ("waits through the registration race then merges", "returns failure on registration timeout", etc.) clearly describe scenario and expected outcome; `Context` blocks group registration-phase, completion-phase, and sleep-seam scenarios logically.
- **Mock signature parity**: All new mocks use `param([string[]]$GhArgs)` / `param([int]$Seconds)`, matching the production wrapper signatures exactly.
- **Location**: The new test file `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` mirrors the production path (`scripts/dev-tools/Invoke-FullReleaseFlow.ps1`) under `tests/scripts/dev-tools/`, consistent with the required test-file layout, and follows the existing sibling-file split pattern (`AdditionalFailurePaths`) rather than growing a single file past the line limit.

## Compatibility / Public API

- `Wait-ForPullRequestChecks` is a new function; it does not break any existing public API. `Invoke-FullReleaseFlowGuarded`'s external contract (parameters, return codes 0/1/2) is unchanged.
- Internal call-site change (replacing the `--watch` invocation) is not part of any published/public API; no external callers exist outside this script and its dedicated test suites.

## Dependencies

- No new third-party dependencies introduced; `Invoke-Sleep` wraps the built-in `Start-Sleep` cmdlet.

## Conclusion

No blocking code-quality findings. Two non-blocking suggestions (documentation completeness for default timeouts; one additional edge-case test for the zero-required-checks scenario) and one informational note (stray text in `plan.md`) are recorded for optional follow-up; none block merge.
