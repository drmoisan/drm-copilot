# Preflight Fixes (Revision 2026-11-07 amendment)

Timestamp: 2026-11-07T17-18
Plan: docs/features/active/2026-10-30-docs-authoring-workflow-1037/plan.2026-10-30T18-59.md
Scope: the amendment commit "docs(features): amend issue 1037 plan classification after P7-T7 halt" against its parent.

Verified against HEAD:
- `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` exists, carries the `$script:ExemptHook` row `enforce-docs-role-write-scope.ps1`, and contains the test `lists every hook registered for the Bash, Write|Edit, and Agent matchers as composed or exempted`.
- The merged JUnit of the [P7-T3] parallel gate lists that file with 12 tests, 0 failures.
- `evidence/qa-gates/powershell-analyze.2026-11-07T16-52.md` records the file among 15 analyzed files with 0 findings.
- Plan validator (MCP, artifact_type plan): ok, no warnings, after the fix below.

## Fixes

1. N13 | factual correction in a note, no assertion change | N13 described [P7-T3] as "the fresh single-process run" and said "the seeded shuffle runs of [P7-T4] did not include it". The recorded evidence shows [P7-T3] ran as one `Invoke-PoshQCParallelTest` run under the owner directive of 2026-11-07 (`pester-coverage.<timestamp>.md`) and that [P7-T4] made no shuffle run (waived, `pester-shuffle.<timestamp>.md`). The sentence now states both facts. No task text, acceptance condition, or checkbox changed.
