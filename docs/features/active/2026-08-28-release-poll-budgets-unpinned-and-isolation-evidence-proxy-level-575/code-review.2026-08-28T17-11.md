Timestamp: 2026-08-28T17-11

# Code Review — issue #575 (release-poll-budgets-unpinned-and-isolation-evidence-proxy-level)

Branch: `bug/release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575-r2`
Diff scope: `git diff origin/main` (merge-base `e546e814`; see policy-audit for base-resolution rationale).

## Files Reviewed

1. `tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1` (new, 79 lines)
2. `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md` (append-only, +25 lines)
3. Feature-folder documentation and evidence artifacts under `docs/features/active/2026-08-28-release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575/`

No production `.ps1` file is part of this diff.

## Primary Focus: Mocking Strategy Genuineness (Gap 1)

This was the highest-risk item in the review, since a test that mocks the function under test can
pass while asserting nothing real. Verified directly against the production source, not just the
plan's narrative claim:

- `tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1` contains no
  `Mock -CommandName Invoke-TagPublishVerification` line anywhere (confirmed by reading the full
  79-line file).
- `Invoke-ReleaseTagPush.ps1:244-250` calls `Invoke-TagPublishVerification` with **no explicit
  budget arguments**, so the call site relies entirely on that function's own defaults.
  `Invoke-ReleaseVerification.ps1:353-358` defines those defaults as
  `RunIntervalSeconds=10, RunMaxAttempts=18, StepIntervalSeconds=20, StepMaxAttempts=60,
  NpmIntervalSeconds=15, NpmMaxAttempts=40` — exactly the (10,18)/(20,60)/(15,40) triples the three
  new `It` blocks assert.
- `Invoke-TagPublishVerification` itself calls `Wait-ForWorkflowRun -IntervalSeconds
  $RunIntervalSeconds -MaxAttempts $RunMaxAttempts` (`:362-366`) and
  `Test-PublishStepConclusion -IntervalSeconds $StepIntervalSeconds -MaxAttempts $StepMaxAttempts`
  (`:372-377`), and runs its own `for` loop for check (c) bounded by `$NpmMaxAttempts` with a sleep
  of `$NpmIntervalSeconds` on all but the last iteration (`:387-392`). Because none of these are
  mocked, the real forwarding chain — call site → `Invoke-TagPublishVerification` defaults →
  `Wait-ForWorkflowRun`/`Test-PublishStepConclusion`/the raw loop — genuinely executes.
- Test (c)'s asserted counts (41 `Invoke-NpmExe` calls, 39 `Invoke-Sleep` calls at 15s) are
  arithmetically consistent with the real loop: 40 attempts inside
  `Invoke-TagPublishVerification`'s check (c), plus exactly one additional `Invoke-NpmExe` call from
  the pre-push guard (`Invoke-ReleaseTagPushGuarded:198`, via the real, unmocked
  `Test-NpmVersionResolved`), for 41 total; 39 sleeps because the loop's sleep condition is
  `attempt -lt MaxAttempts` (39 true, 1 false at the final attempt).
- Because `Wait-ForWorkflowRun` and `Test-PublishStepConclusion` are mocked with a `-ParameterFilter`
  restricted to the exact expected values (tests a/b) or unconditionally (test c, to reach check c),
  a call site that forwarded a wrong value (e.g., the plan's illustrative "3-minute pair where 20
  minutes is required") would fail to match the filter and the test would fail — this is a
  genuinely falsifiable assertion, not a tautology.

**Conclusion: the mocking strategy genuinely exercises the real composition/forwarding logic.** The
plan's explicit constraint (no line mocks `Invoke-TagPublishVerification`) is satisfied, and the
constraint's stated purpose — that a regression in the call site's forwarded arguments would be
caught — is substantively true, not merely textually true.

## Style and Convention Consistency

- The mock signatures (`Test-Path -MockWith { param($LiteralPath) ... }`,
  `Get-NpmVersion -MockWith { param([string]$ManifestPath) ... }`, `Invoke-GitExe -MockWith {
  param([string[]]$GitArgs) ... }`) are byte-identical in shape to the pattern used 10+ times in the
  sibling file `Invoke-ReleaseTagPush.Tests.ps1`, satisfying the "mock signature parity" rule in
  `.claude/rules/powershell.md`.
- `Set-StrictMode -Version Latest` at the top matches repository convention for Pester files.
- The `Describe`/`Context`/`It` nesting and one-behavior-per-`It` structure follow
  `.claude/rules/powershell.md`'s testing standards.
- Comments are used purposefully to explain non-obvious counts (the 41-vs-40 discrepancy versus the
  directly-invoked scenario in `Invoke-ReleaseVerification.Tests.ps1`) rather than restating code.

## Minor Observations (non-blocking)

- The three `It` blocks each independently invoke `Invoke-ReleaseTagPushGuarded -ConfirmToken 'yes'
  -RepoRoot '/repo'` with a fresh `BeforeEach` mock set, so there is some duplication of the
  invocation line across the three tests. This mirrors the sibling file's own style (which also
  repeats setup per `It`) and keeps each test independently readable without a shared helper; not a
  finding, just noted for consistency awareness.
- The `Context`-level comment (lines 38-41) that explains the never-mock-`Invoke-TagPublishVerification`
  constraint is placed above the `It` blocks rather than as a docstring/comment on the `Describe`
  block itself. This is a stylistic choice and does not affect Pester's test discovery or reporting.

## Gap 2 (documentation correction) Review

- The correction is structurally sound: new `##`-level heading, dated, cross-referenced to issue
  #575, and placed strictly after the file's prior final line (pure addition in the diff, no
  deletions).
- The corrected claim is precise and narrower than the original, and explicitly separates AC21's two
  clauses (isolation depth vs. test purity), correcting only the first while reaffirming the second
  with fresh, independently-run evidence (a `git grep` across all four release-verification test
  files for direct `npm`/`gh`/`git` invocation, zero matches).
- No code-quality concerns apply to a documentation-only change of this kind; the writing is
  concise, factual, and avoids overstating the correction's scope (it does not claim the original
  AC21 checkbox should be unchecked).

## Findings Summary

No Blocking findings. No Major findings. Two Minor/informational style observations recorded above,
neither of which requires remediation.

**Overall code-review verdict: PASS.**
