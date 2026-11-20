# Preflight Fixes (Issue #1114)

Timestamp: 2026-11-07T18-43
Plan: docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/plan.2026-11-07T13-15.md

Each entry below is a trivial in-place fix to task text. No task was added, removed, or reordered, and no asserted outcome changed.

1. [P2-T1] | validator-blind fixture defect (expect-fail claim) | The recency candidate that each new row returns from the `Get-ChildItem` mock is now stated to lie beneath the session root, never beneath `/synthetic-worktrees/item-a`. The unfixed hook prints `Audit file: <FullName>` in its continuation reason, so a candidate placed under the item root would let the stale-report row assert a reason containing the item root and pass against the unfixed hook, which contradicts the [P2-T2] fail-before claim.
2. [P3-T1] | literal count clarification | "the eight named rows exist" now states the rows it counts: the four rows the task adds and the four [P2-T1] rows. The count of eight is unchanged.
3. [P5-T2] | literal clarification | "the three changed or new test files" now names the three test files that [P1-T1], [P1-T2], and [P3-T1] write. The plan changes four test files, and the fourth (`legacy-codex-hook-contracts.Tests.ps1`, registration only) stays under the clause "no finding absent from the [P0-T3] artifact elsewhere".
4. [P5-T3] | citation consistency | `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` is added to the list of suites recorded as passing, because the [P5-T6] acceptance reads that result from the [P5-T3] artifact.
5. [P5-T6] | literal formatting | The expected output of `git diff --name-only --diff-filter=A` is now written as full repository-relative paths (`.codex/hooks/validate-feature-review-coverage-freshness.ps1`, `.codex/hooks/feature-review-coverage-target.ps1`), which is what the command prints.
