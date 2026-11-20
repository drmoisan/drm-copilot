# Baseline — PowerShell Format (PoshQC MCP format)

Timestamp: 2026-10-10T08-10
Task: [P0-T14]
Command: mcp__drm-copilot__run_poshqc_format (workspace_root = agent worktree root; scan_folders omitted, so the configured scan set was used)
EXIT_CODE: 0
CI-DEFERRED: yes

Output Summary:
- MCP result: `{"ok":true,"tool":"run_poshqc_format", ... "summary":"Ran bundled PoshQC format against '<worktree root>'."}`
- Call disposition: ok = true. The MCP result carries no formatter output.
- FORMAT token (`FORMAT_CLEAN` / `FORMAT_DRIFT`): not available from the MCP result; taken from the CI PowerShell job log on the pull request.
- Tree observation (the format tool may write files):
  - `git status --porcelain` BEFORE:
    - ` M docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/plan.2026-10-08T13-56.md`
    - `?? docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/evidence/`
  - `git status --porcelain` AFTER: identical to BEFORE.
  - Result: the format tool modified no tracked file. This is a before-and-after tree observation consistent with no formatting drift in the configured PowerShell scan set.
- Deviation recorded in `evidence/other/execution-deviations.2026-10-10T08-02.md`.
