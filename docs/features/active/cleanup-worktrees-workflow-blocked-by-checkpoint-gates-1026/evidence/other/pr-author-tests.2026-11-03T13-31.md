# PR-Author Gate Suites (Issue #1026, P4-T5)

Timestamp: 2026-11-03T13-31
Command: sh SCRATCH/issue-1026-ps.sh SCRATCH/issue-1026-pester.txt @SCRATCH/issue-1026-list-p4.txt (Invoke-Pester over the 19 suites below in one process, JUnit to artifacts/pester/pester-junit.xml, coverage disabled)
EXIT_CODE: 0
Output Summary: JUnit testcases 298, passed 298, failed 0, skipped 0. The new suite tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1 contributes 14 testcases. The AC7 and AC8 names (11 names, below) all appear in the JUnit testcase names (missing 0). Discovery-guard compliance of the new suite: 0 findings.

Suites run: `tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1` (new); every existing `tests/scripts/claude-hooks/enforce-pr-author-skill*.Tests.ps1` suite (17 files: `.BodyNumber`, `.CurrentBranch`, `.DocsOnly.Decision`, `.DocsOnly.Exemption`, `.DocsOnly`, `.EpicScope`, `.Issue824`, `.ItemArtifactRoot`, `.OrchestratorStatePreflight`, `.Payload`, `.TargetResolution`, the base `.Tests.ps1`, `.TriggerScoping`, `.WorktreeResolution`, `.epic-base-branch.EpicModeStrict`, `.epic-base-branch`, `.epic-base-branch.TriggerScoping`); and `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1`.

AC7 and AC8 names confirmed:

- `allows gh pr create --head documentationandmemories --base main with no checkpoint, a fresh valid manifest, and an allowlisted diff`
- K1: `denies gh pr edit of the consolidation branch with CLEANUP_EXEMPTION_NOT_CREATE`
- K2: `denies a consolidation create when a checkpoint is present with CLEANUP_EXEMPTION_CHECKPOINT_PRESENT`
- K3: `denies an absent, different, short-form, owner-qualified, or repeated --head with CLEANUP_EXEMPTION_HEAD_UNRESOLVED` (cases include `-H documentationandmemories`, `--head drmoisan:documentationandmemories`, and a repeated `--head`)
- K4: `denies a repeated or non-main --base with CLEANUP_EXEMPTION_BASE_UNRESOLVED`
- K5: `denies a missing, stale, future, or invalid manifest or an empty run_id with CLEANUP_EXEMPTION_MANIFEST_INVALID`
- K6: `denies an empty or non-allowlisted diff with CLEANUP_EXEMPTION_EMPTY_DIFF or CLEANUP_EXEMPTION_NON_ALLOWLISTED_PATH` and `denies a failed, unterminated, or throwing git read with CLEANUP_EXEMPTION_DIFF_FAILED`
- `still requires the orchestrator preflight for a non-consolidation PR with no checkpoint`
- `evaluates the docs-only exemption before the cleanup exemption with unchanged results`
- `runs the receipt checks unchanged after the cleanup exemption`

Each K row asserts the `ORCHESTRATOR_STATE_PREFLIGHT_FAILED:` prefix and the `; cleanup exemption not applied: <sub-code>` suffix. The AC13 pairs (`denies the consolidation create against a non-consolidation worktree`, `denies the consolidation create against the session root`) assert the exact docs-only denial text the gate returns today.

Line counts: `enforce-pr-author-skill.cleanup.ps1` 198; `enforce-pr-author-skill.docs-only.ps1` 225; `enforce-pr-author-skill-helpers.ps1` 499 (P0-T2 value, line-neutral edit); new suite 271.
