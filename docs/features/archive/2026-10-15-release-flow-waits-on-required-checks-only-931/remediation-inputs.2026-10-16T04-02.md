# Remediation Inputs (Issue #931), coordinator decision D5 (cycle 2)

Review-Verdict: REMEDIATION_REQUIRED

**Entry timestamp:** 2026-10-16T04-02
**Feature folder:** `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931`
**Base branch:** `main`
**Work mode:** `minor-audit`; AC source is `issue.md` `## Acceptance Criteria` only
**Blocking finding count:** 4 (autonomous: 4)
**Source:** coordinator decision D5 (operator policy: related follow-ups are fixed inside the item before merge). The cycle 1 re-audit listed items 1 to 4 as non-blocking or unrelated; all four are in `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, the file this item changes, and are therefore treated as related.
**Prior audit artifacts:** `code-review.2026-10-16T03-14.md`, `feature-audit.2026-10-16T03-14.md`, `policy-audit.2026-10-16T03-14.md` (all in the feature folder).

## Findings

### F1 - OutputType mismatch on Invoke-GitExe and Invoke-GhExe

Severity: Blocking
Remediability: autonomous

Both functions declare `[OutputType([hashtable])]` and document a hashtable in `.OUTPUTS`, but return the `[pscustomobject]` built by `ConvertTo-CommandResult`. Make the declaration and the `.OUTPUTS` text match the actual return type.

### F2 - Phase A treats a gh authentication or network failure as "checks not yet registered"

Severity: Blocking
Remediability: autonomous

In `Wait-ForPullRequestChecks`, Phase A retries on any non-zero `gh pr checks` exit code. An authentication or network failure is therefore retried up to RegistrationMaxAttempts times (24 x 5 s, about two minutes) before the failure is reported. Distinguish a gh failure from an empty or not-yet-registered check list and fail promptly on a gh failure. Add Pester tests for both paths: a gh failure that returns 1 immediately without sleeping, and a not-yet-registered state that still retries. The planner must first observe, against the real gh CLI help or a recorded run, what `gh pr checks --json bucket` returns (exit code and stderr text) when no checks are registered, and derive the distinguishing rule from that observation.

### F3 - Script at 499 of 500 lines

Severity: Blocking
Remediability: autonomous

Extract helpers into a dot-sourced helper file next to the script (at least `ConvertFrom-CheckPollOutput` and `Get-CheckSetVerdict`, the two named in the cycle 1 review) so the script has headroom. Behavior must stay identical. Tests dot-source the script; they must keep working, and the new helper file must be inside Pester coverage measurement and the 500-line limit. Update every mirror or reference that lists the script's files (search `.claude/`, `.github/`, `.vscode/`, packaging manifests, and coverage configuration) so mirrors stay in sync.

### F4 - Unreachable $null element guard in Get-CheckSetVerdict

Severity: Blocking
Remediability: autonomous

The `$null -eq $check` branch (former script line 213) cannot be driven (see `evidence/baseline/cycle1-binder-probe.2026-10-16T02-49.md`). During the extraction either remove the guard, or give `-Checks` `[AllowNull()]` and cover the branch with a test. Prefer removal unless a test can drive it.

## Out of scope (unrelated)

- The missing prd-feature receipt: minor-audit forbids spec.md.

## Constraints

- Pester stays on breakpoint coverage. Use the PoshQC MCP tools (format, analyze, test) scoped with `scan_folders`.
- Per-file line coverage for the changed files must not drop below the Phase 0 baseline (94.26% for `Invoke-FullReleaseFlow.ps1`) and the repository coverage threshold in the root `CLAUDE.md` governs.
- Evidence paths follow `<FEATURE>/evidence/<kind>/` only.
