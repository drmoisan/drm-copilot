# Phase 2 — PR-Author Published-Head Check Tests

Timestamp: 2026-11-03T20-18
Command: sh SCRATCH/issue-1026-suites.sh p2t5 issue-1026-p2t5.txt (one fresh PowerShell 7 process: Invoke-Pester with JUnit output over the 25 suites below)
EXIT_CODE: 0

Suites: tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1; every tests/scripts/claude-hooks/enforce-pr-author-skill*.Tests.ps1 suite (BodyNumber, Cleanup, CurrentBranch, DocsOnly.Decision, DocsOnly.Exemption, DocsOnly, EpicScope, Issue824, ItemArtifactRoot, OrchestratorStatePreflight, Payload, TargetResolution, the base suite, TriggerScoping, WorktreeResolution, epic-base-branch.EpicModeStrict, epic-base-branch, epic-base-branch.TriggerScoping); tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1; tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1, enforce-gate-suites.EpicStateIsolation.Tests.ps1, enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1, enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1; tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1.

JUnit `testsuites`: tests=814, failures=0, errors=0. Pester result: 814 passed, 0 failed, 0 failed containers.

New test names in the JUnit `testcase` names:

| Test | Status |
|---|---|
| denies a consolidation create when origin/documentationandmemories is missing with CLEANUP_EXEMPTION_REMOTE_HEAD_MISMATCH | Passed |
| denies a consolidation create when origin/documentationandmemories differs from HEAD with CLEANUP_EXEMPTION_REMOTE_HEAD_MISMATCH | Passed |
| resolves the published consolidation branch and HEAD through the bounded docs-only git seam | Passed |

Note: the JUnit file of this targeted run was written under SCRATCH rather than `artifacts/pester/pester-junit.xml`, so the full-scan file is not overwritten.

Output Summary: 814 passed, 0 failed; all three P2-T3 test names pass.
