# Remediation Inputs — Cycle 1 (merge conflict with integration branch)

Timestamp: 2026-10-09T01-50
Source: S9 merge-conflict remediation (synthetic Blocking finding)
PR: #855 (base `epic/enforcement-hook-precision-integration`, head `bug/promotion-hook-raw-containment-false-positive-deny-exec-824` at `0450593a`)
Observed: `gh pr view 855 --json mergeable,mergeStateStatus` returned `"mergeable":"CONFLICTING"`, `"mergeStateStatus":"DIRTY"`; CI reported zero checks because a conflicting PR receives no pull_request run.

## Finding MC-1 (Blocking)

- Remediability: autonomous
- Cause: the integration branch advanced to `e1433ff3` (merge of PR #854, issue #565), which added the shared module `feature-folder-resolution.ps1` to the same two list sites that this branch extended.
- Command: `git merge-tree --write-tree --name-only HEAD origin/epic/enforcement-hook-precision-integration`
- EXIT_CODE: 1
- Conflicting files (2):
  1. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — around line 56: this branch adds `".claude/hooks/hook-command-heredoc.ps1",`; the integration branch adds `".claude/hooks/feature-folder-resolution.ps1",` at the same position.
  2. `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` — the `$script:SharedModuleNames` assignment: this branch's list is `codex-pretooluse-file-mapping.ps1, enforce-orchestration-preimplementation-gate-helpers.ps1, hook-command-scanner.ps1, hook-command-invocation.ps1, enforce-batch-budget-route.ps1, hook-command-heredoc.ps1, hook-command-payload.ps1, hook-command-payload-powershell.ps1, hook-command-invocation-operands.ps1`; the integration branch's list is the first five plus `feature-folder-resolution.ps1`.
- Auto-merged without conflict: `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.

## Required resolution

- Merge `origin/epic/enforcement-hook-precision-integration` into the branch with `git merge` (no rebase, no force-push).
- Resolve both conflicts as a union that keeps every entry from both sides:
  - core.json (Claude): keep both lines, in sorted position: `".claude/hooks/feature-folder-resolution.ps1",` then `".claude/hooks/hook-command-heredoc.ps1",`. The result must be valid JSON with no duplicate entries.
  - `SharedModuleNames`: this branch's nine names plus `feature-folder-resolution.ps1` (ten names, no duplicates).
- Verify: no conflict markers remain; both core.json files parse as JSON; the manifest-completeness and parity tests pass (`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, the Claude/Codex pack-manifest pytest parity tests, and the #824 changed suites); PoshQC format/analyze clean on the changed test file.
- Out of scope: any other change; #824 addendum 2.
