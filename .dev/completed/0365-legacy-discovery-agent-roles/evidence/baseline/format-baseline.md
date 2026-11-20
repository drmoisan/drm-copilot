# PowerShell Format Baseline — legacy-discovery-agent-roles (#365)

Timestamp: 2026-07-18T11-15

Command: mcp__drm-copilot__run_poshqc_format (workspace_root = feature worktree root; scan_folders = ["tests/scripts/claude-runtime"])

EXIT_CODE: 0

Output Summary: PoshQC formatter (Invoke-Formatter) ran successfully (`ok: true`) against the
in-scope test directory `tests/scripts/claude-runtime/` before any change. The tool reported a
successful run against 1 selected scan folder with no error. This is the pre-change formatting
baseline; the new test file does not yet exist at this point, so the baseline reflects the four
existing `*.Tests.ps1` files in that directory being format-clean.
