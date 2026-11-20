# Preflight Fixes - Issue #1173 (confirming preflight)

Timestamp: 2026-11-14T06-41
Plan: docs/features/active/2026-11-14-documentation-workflow-tooling-defects-part-b-1173/plan.2026-11-14T00-13.md
Command: env -u VIRTUAL_ENV poetry -C <worktree> run python scripts/dev_tools/validate_orchestration_artifacts.py plan <plan>
EXIT_CODE: 0
Output Summary: Branch-current Python CLI plan validation passed before and after the fixes (exit 0). The plan keeps 167 physical lines and its task set; four task lines changed. The earlier record `preflight-fixes.2026-11-14T06-10.md` is not edited.

## Round-1 defects confirmed resolved

- `[P3-T2]` / `[P3-T3]` extension-import raw digest: D-4 and `[P3-T3]` add `raw_sha256`, compare it in `Test-DocsExtensionCapturedDigest`, and build the test manifest from it.
- `[P5-T2]` command-level split test: `DocsReferenceWriter.Split.Tests.ps1` drives `Invoke-DocsGenerateReferenceCommand -Write` on an in-memory context.
- `[P4-T5]` single load and compare: `[P4-T3]` counting stubs and `[P4-T5]` counting `ReadBytes` and `WriteText` wrappers.
- `[P1-T2]` stale hook help: the `.DESCRIPTION` of `Invoke-DocsRoleOutputValidation` and the TargetWorktree suite synopsis are corrected in the task.

## Fixes

1. `[P1-T1]` | literal-formatting defect (vacuous search literal) | The acceptance asserted that the text `else .` no longer appears, but spec.md and user-story.md write the fallback as a code span holding a single dot, so that text never matched and the condition could not fail. Restated as: no B6 rule, test bullet or criterion in either file still ends the detection order with a single-dot code span, naming the four places that hold it today. The asserted outcome (the fallback is no longer `.`) is unchanged.
2. `[P1-T7]` | task-ordering satisfiability (validator-blind) | `[P1-T3]` to `[P1-T6]` edit skill and agent text before this suite exists, so the B12 rows (the only B12 tests) had no fail-before record, which the Execution Rules regression-first bullet and the spec criterion on fail-before regression tests require. Added a fail-before step that runs the new file against a `SCRATCH` copy of the merge base and records the failing B1 and B12 rows. No task was moved and the passing assertion is unchanged.
3. `[P4-T1]` | citation correction and changed existing behavior without a named asserting test | The task stated that the `update-ledger` option list "still has no `Claim`"; the committed row already carries `Claim` (for `pin`). Corrected to name where B3 rule 4 is asserted (`set-dimension` entry of `$script:Permitted` in `DocsLedgerCommands.Properties.Tests.ps1`). The cited `Invoke-DocsCommand.Tests.ps1` help-text assertions that list `update-ledger` options do not exist (the `-Help` case matches only the usage prefix); recorded as unchanged. Named `exposes TestAncestor and ListChangedPath after ReadRevisionText with their leading parameters` in `Invoke-DocsCommand.RevisionContext.Tests.ps1`, which pins the last three members of `New-DocsCommandContext`, as unchanged by placing `ReadStdin` before `ResolveRevision`; named the twelve-member assertion of `New-DocsLedgerTestContext` in `DocsLedger.TestSupport.Tests.ps1` as unchanged.
4. `[P4-T5]` | citation correction | No test asserts the text `The -Operation option is required.`, and `DocsLedgerCommands.UpdateLedger.Tests.ps1` holds no such case. Named the one related assertion, the `-Operation` fragment in `returns one DOCS_CLI_ARGUMENTS finding for an option outside the operation set` in `DocsLedgerCommands.Tests.ps1`, as unchanged.

No task was added, removed or reordered.
