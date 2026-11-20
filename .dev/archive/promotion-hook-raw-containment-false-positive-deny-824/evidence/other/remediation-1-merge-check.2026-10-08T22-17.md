# Remediation 1 Merge Check (post-resolution)

Timestamp: 2026-10-08T22-17
Command: sh <SCRATCHPAD>/s-merge-check.sh
EXIT_CODE: 0
Output Summary: MERGE_CHECK: PASS; CONFLICT_MARKER_COUNT: 0; both manifests parse with duplicates=0; ORDER 51/52 (consecutive); both CODEX_ENTRY lines PRESENT; LEGACY_LINES: 497.

```text
MANIFEST_PARSE extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json OK
MANIFEST extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json paths=208 duplicates=0
ORDER feature-folder-resolution=51 hook-command-heredoc=52
MANIFEST_PARSE extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json OK
MANIFEST extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json paths=122 duplicates=0
CODEX_ENTRY .codex/hooks/feature-folder-resolution.ps1 PRESENT
CODEX_ENTRY .codex/hooks/hook-command-heredoc.ps1 PRESENT
SHARED_MODULE_LINES: 1
SHARED_MODULE_COUNT: 10
SHARED_MODULE_DUPLICATES: 0
LEGACY_LINES: 497
CONFLICT_MARKER_COUNT: 0
MERGE_CHECK: PASS
```

Resolution applied ([P1-T4]): CLAUDE_MANIFEST lines 55-58 now read, consecutively, `.claude/hooks/enforce-promotion-mcp-only.ps1`, `.claude/hooks/feature-folder-resolution.ps1`, `.claude/hooks/hook-command-heredoc.ps1`, `.claude/hooks/hook-command-invocation.ps1`.

Resolution applied ([P1-T5]): LEGACY_TEST conflict region (lines 30-34, covering only the `$script:SharedModuleNames` assignment) replaced by the single ten-name line from plan section 2.

## [P1-T7] Staging and post-resolution state

Timestamp: 2026-10-08T22-19

Command: git add -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
EXIT_CODE: 0
Output Summary: no output.

Command: git ls-files -u
EXIT_CODE: 0
Output Summary: empty (no unmerged entries).

Command: git status --porcelain (classified by `<SCRATCHPAD>/porcelain-summary.sh`, which runs that command and counts its lines by category)
EXIT_CODE: 0
Output Summary: 208 lines; no unmerged code; both conflicted paths now `M ` (staged); the only unstaged or untracked lines are under FEATURE/:

```text
GIT_STATUS_EXIT_CODE: 0
TOTAL_LINES: 208
UNMERGED_COUNT: 0
UNSTAGED:  M docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/remediation-baseline/git-baseline.2026-10-08T21-57.md
UNSTAGED:  M docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/remediation-plan.2026-10-09T01-50.md
UNTRACKED: ?? docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/other/remediation-1-merge-check.2026-10-08T22-17.md
UNTRACKED: ?? docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/other/remediation-1-merge.2026-10-08T22-14.md
UNSTAGED_OR_UNTRACKED_OUTSIDE_FEATURE: 0
```
