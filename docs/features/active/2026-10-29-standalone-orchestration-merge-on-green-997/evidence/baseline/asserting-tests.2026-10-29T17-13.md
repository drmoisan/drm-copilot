Timestamp: 2026-10-29T17-13
Command: grep -rln -e "--admin" -e "Get-EpicMergeGateGreenCiDecision" -e "GREEN_CI_MATCH_HEAD_MISMATCH" -e "match-head-commit" tests/scripts
EXIT_CODE: 0
Output Summary: 9 matching files; dispositions below.
- tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1 : updated (new --admin rows, valueless --match-head-commit row; existing rows unchanged)
- tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 : unchanged (authorization branch runs after the green-CI branch)
- tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 : unchanged (docs-only branch, unaffected)
- tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 : unchanged (merge-queue check runs before the green-CI branch)
- tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 : unchanged (tests Get-DocsOnlyMergeShapeViolation, not modified)
- tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 : unchanged (Codex hooks, out of scope)
- tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 : unchanged (Codex hooks, out of scope)
- tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 : unchanged (Codex hooks, out of scope)
- tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 : unchanged (Codex hooks, out of scope)
