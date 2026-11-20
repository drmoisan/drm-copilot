# Preflight Fixes - Issue 1034 Remediation Design Cycle 2

Timestamp: 2026-11-07T03-02
Plan: docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/remediation-plan.2026-11-07T02-24.md

## Fixes

- P1-T3 | validator-blind defect, correction keeps the assertion | The driver dot-sourced the `HOOK` of the worktree, whose root has no `docs/documentation-estate/docs-profile.json`, so with only `Invoke-DocsOnlyGhExe` replaced every command would allow with no lookup. The driver now dot-sources the `HOOK` of a consumer copy under `SCRATCH/bash-exact/consumer/` with an enabled profile and no receipt. What the task asserts is unchanged.
- P2-T5 | validator-blind defect, correction keeps the assertion | Added that the P1-T3 consumer copy is refreshed so it holds the corrected `HOOK` and `HELPER`. What the task asserts is unchanged.
