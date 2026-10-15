# P10-T5 PowerShell format with porcelain observation

Timestamp: 2026-10-13T12-40
Command: git status --porcelain; mcp__drm-copilot__run_poshqc_format workspace_root=<worktree> scan_folders=["tests/scripts/claude-hooks"]; git status --porcelain
EXIT_CODE: 0
Output Summary:
- MCP call disposition: `{"ok":true,"tool":"run_poshqc_format","workspace_root":"<worktree>","summary":"Ran bundled PoshQC format against '<worktree>' with 1 selected scan folder(s)."}`.
- The pre-format and post-format porcelain outputs are identical, and `git diff --stat HEAD -- tests` is unchanged (4 files, 51 insertions, 3 deletions); the helpers file remains 496 lines. The formatter rewrote no file.
- Outside `<FEATURE>`, only the four Phase 10 files appear in the post-format porcelain. No restore was needed, so no third porcelain run applies.

## Post-format porcelain (identical to pre-format)

```text
 M docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/plan.2026-10-11T10-39.md
 M tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1
 M tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1
 M tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1
 M tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1
?? docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/evidence/regression-testing/p10-line-counts.2026-10-13T12-40.md
```
