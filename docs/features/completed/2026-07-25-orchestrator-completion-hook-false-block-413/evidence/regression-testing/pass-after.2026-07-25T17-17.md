# Pass-After Regression Evidence (issue #413)

Timestamp: 2026-07-25T17-17

Pairs with the fail-before artifact
`docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/evidence/regression-testing/fail-before.2026-07-25T17-14.md`.
Same command, same test file, same 27 tests; the only delta between the two runs is the
Phase 3 production fix (`$hasErrors = ($exitCode -ne 0)`) plus the docstring/comment
correction and the bundled resync.

## [P4-T1] Pass-after run

Command: `pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 -Output Detailed"` (run at repo root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a0fcdf306557436df`)

EXIT_CODE: 0

Output Summary:

- Discovery: 27 tests in 1 file.
- Result: **Tests Passed: 27, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0** (1.05s).
- **Zero tests fail.**

### The two issue-413 ALLOW tests now PASS (were failing before the fix)

1. `Context 'routing-contract validation (Gap 1)'` ->
   `allows DONE when the validator exits 0 and prints its success line (issue #413)` —
   **PASSED** (7ms). Was FAILED in the fail-before run (`Expected $true, but got $false`).
2. `Context 'Invoke-RoutingContractValidation'` ->
   `reports no errors when the seam returns exit 0 with the validator success line (issue #413)` —
   **PASSED** (2ms). Was FAILED in the fail-before run (`Expected $false, but got $true`).

### The [P2-T3] exit-2 fail-closed test still PASSES

- `Context 'Invoke-RoutingContractValidation'` ->
  `reports HasErrors when the seam returns exit code 2 (argparse misuse / crash path stays fail-closed)` —
  **PASSED** (2ms), in both the fail-before and pass-after runs. Exit code 2 still blocks under
  the exit-code-only rule; the gate is not weakened for non-1 non-zero exits or crash paths.

Fail-before / pass-after delta: 25 passed / 2 failed -> 27 passed / 0 failed.

## [P4-T2] Fail-closed BLOCK tests: diff-untouched and passing

Command: `git diff -- tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`

EXIT_CODE: 0

The diff contains exactly two hunks:

- `@@ -211,6 +211,26 @@` — a pure addition of the new `It 'allows DONE when the validator exits 0
  and prints its success line (issue #413)'` block inside
  `Context 'routing-contract validation (Gap 1)'`. All surrounding lines are context (unchanged).
- `@@ -263,16 +283,33 @@` — the in-place replacement of the defect-asserting
  `It 'reports HasErrors when the seam returns error text with exit 0'` with the two new
  `It` blocks (the exit-2 fail-closed test and the issue-413 success-line test) inside
  `Context 'Invoke-RoutingContractValidation'`.

Neither hunk modifies the body of either fail-closed BLOCK test, identified by test title:

| Test title | In the diff? | Result in the [P4-T1] run |
|---|---|---|
| `reports HasErrors when the seam returns a non-zero exit code` | No — appears only as unchanged context above the second hunk's change region; its `$stub`, `Act`, and `Should -BeTrue` lines carry no `+`/`-` marker | **PASSED** (3ms) |
| `blocks DONE with ROUTING_CONTRACT_BLOCKED when the validator reports errors` | No — does not appear in any hunk of the diff at all | **PASSED** (11ms) |

Additional blocking assertions confirmed untouched and passing in the same run:

- `blocks a fabricated-route checkpoint (pass-after for the P3-T1 fail-before)` — PASSED (10ms),
  asserts `$result.Message | Should -Match 'ROUTING_CONTRACT_BLOCKED'`.
- All 4 payload-validation block tests, both checkpoint-presence block tests, and all 3
  checkpoint-structure block tests — PASSED.

No blocking assertion was removed or relaxed. The only assertion removed anywhere in the suite
is the defect-asserting `exit 0 plus text must block` pair
(`$result.HasErrors | Should -BeTrue` / `$result.ErrorText | Should -Match 'some error'`),
whose removal is the explicit intent of [P2-T1] and spec AC6.

Confirmation that the exit-0-with-text-blocks assertion no longer exists anywhere in the
suite (spec AC6):

- SearchScope: `tests/` (whole tree)
- SearchPatterns: `ExitCode = 0.*Output\s*=\s*'some error'` and
  `reports HasErrors when the seam returns error text with exit 0`
- SearchResult: `none`
