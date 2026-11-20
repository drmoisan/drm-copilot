# Phase 4 fail-before — ModelRouting floor-signal filtering ([P4-T3], [expect-fail])

Timestamp: 2026-07-25T18-22

Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-lib/model-routing -Output Detailed"` (run from the repository root)

EXIT_CODE: 0

Note on the exit code: `Invoke-Pester` invoked without `-CI` does not propagate a failing
exit status to the host process, so the pass/fail signal for this task is the Pester result
summary reproduced below, not the process exit code.

Output Summary:

- Tests Passed: 46, Failed: 7, Skipped: 0, Inconclusive: 0, NotRun: 0.
- The seven failures are exactly seven of the new [P4-T1]/[P4-T2] cases; every pre-existing
  case in `Get-ComplexityFloor.Tests.ps1`, `ModelRouting.Parity.Tests.ps1`,
  `ModelRouting.Manifest.Tests.ps1`, and `Resolve-DelegationModel.Tests.ps1` passes.

Failing new tests:

From `Get-ComplexityFloor.Tests.ps1`, `Context 'Non-floor and unknown signals'`:

1. `returns C1 for the single non-floor signal single_file_localized_edit`
2. `returns C1 for the single non-floor signal mechanical_rename_or_move`
3. `returns C1 for the single non-floor signal docs_or_comment_only`
4. `returns C1 for a single unknown signal name`
5. `returns C1 for a list containing only non-floor and unknown signals`

   All five fail because the pre-fix `Get-ComplexityFloor` returns `C3` for any non-empty
   signal list regardless of the signal's `floor` flag.

From `ModelRouting.Parity.Tests.ps1`, `Context 'Floor-signal name set'`:

6. `pins FLOOR_SIGNAL_NAMES to the model_policy.complexity signals flagged floor true`
   — `RuntimeException: The variable '$script:FLOOR_SIGNAL_NAMES' cannot be retrieved because it has not been set.`
7. `excludes every model_policy.complexity signal flagged floor false`
   — same `RuntimeException`; the constant does not exist in the pre-fix module.

Passing new tests (behavior already correct pre-fix and required to stay correct):

- All four `Mixed floor and non-floor signals > returns C3 for a mixed list whose only floor
  signal is <name>` cases pass.
- `never returns C4 across the full truth table` passes: the pre-fix implementation clamps to
  C3, and the post-fix implementation must preserve that ceiling.

This is the expected `[expect-fail]` outcome: only the new cases that depend on floor-signal
filtering and on the new `$script:FLOOR_SIGNAL_NAMES` constant fail.
