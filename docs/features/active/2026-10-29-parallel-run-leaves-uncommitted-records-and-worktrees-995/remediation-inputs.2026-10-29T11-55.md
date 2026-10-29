# Remediation Inputs: Parallel run leaves uncommitted records and worktrees (#995)

Review-Verdict: PASS

- Review timestamp: 2026-10-29T11-55
- Base: `main` (merge base `972e4083c59fefd1d40984929503c9956eed7137`)
- Head: `bed21939d7da24cce0c2100ef619fe3aaa23f19d`

## Review Artifacts

- Policy audit: `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995/policy-audit.2026-10-29T11-55.md`
- Code review: `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995/code-review.2026-10-29T11-55.md`
- Feature audit: `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995/feature-audit.2026-10-29T11-55.md`

## Remediation-Required Findings

None. The review recorded zero merge-preventing findings: every policy section is PASS, PowerShell and Python coverage are PASS, the toolchain is clean, and AC-1 to AC-19 are PASS. AC-20 is a CI-dependent criterion owned by the item's own orchestrator run at S9 and is not a review finding.

## Non-Blocking Observations (optional, orchestrator discretion)

These are Minor code-review items. They do not change the verdict. They are listed so the orchestrator can fold them into a remediation cycle if it chooses.

1. `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`: align the case rule of `Find-CleanupWorktreeManifestRemovalRecord` with `Test-WorktreeRunPathEqual`, so the manifest lookup and the checkpoint-coverage exclusion compare paths the same way.
2. `.claude/skills/parallel-orchestrate/SKILL.md` and `.claude/agents/parallel-orchestrator.md` (and bundle copies): in Run Closing substep 3, drop or qualify the `artifacts/orchestration/` pathspec prefix, which git ignores and the docs-only precondition rejects.
3. `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1`: add RE2 deny rows for the epic `features[]` branch.
4. `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` and `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`: consolidate the identical base-root helpers into one exported helper in `WorktreeRunRecordPath.psm1`.

Remediation-Mode: proportionate
