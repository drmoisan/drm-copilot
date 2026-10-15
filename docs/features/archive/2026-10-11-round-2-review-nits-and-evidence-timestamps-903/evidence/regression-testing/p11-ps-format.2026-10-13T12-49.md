# P11-T14 PowerShell format with porcelain observation

Timestamp: 2026-10-13T12-49
Command: git status --porcelain; mcp__drm-copilot__run_poshqc_format workspace_root=<worktree> scan_folders=["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-lib", "tests/scripts/claude-runtime", "tests/scripts/workflows"]; git status --porcelain
EXIT_CODE: 0
Output Summary:
- MCP call disposition: `{"ok":true,"tool":"run_poshqc_format","workspace_root":"<worktree>","summary":"Ran bundled PoshQC format against '<worktree>' with 5 selected scan folder(s)."}`.
- The pre-format and post-format porcelain outputs are identical. The six Phase 11 files keep their pre-format line counts (267, 81, 179, 268, 150, 270), and `git diff --stat HEAD -- tests` shows 6 files, 72 insertions, 14 deletions after the run.
- Outside `<FEATURE>`, only the six Phase 11 files appear in the post-format porcelain. No file outside this phase was rewritten, so no restore and no third porcelain run were needed.

## Post-format porcelain (identical to pre-format)

```text
 M docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/plan.2026-10-11T10-39.md
 M tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1
 M tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1
 M tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1
 M tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1
 M tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
 M tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
?? docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/evidence/qa-gates/i3-files-unchanged.2026-10-13T12-48.md
?? docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/evidence/qa-gates/publish-workflow-drift.2026-10-13T12-48.md
?? docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/evidence/regression-testing/fail-before-exception.p8-737-846-ps.2026-10-13T12-49.md
?? docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/evidence/regression-testing/p11-line-counts.2026-10-13T12-49.md
```
