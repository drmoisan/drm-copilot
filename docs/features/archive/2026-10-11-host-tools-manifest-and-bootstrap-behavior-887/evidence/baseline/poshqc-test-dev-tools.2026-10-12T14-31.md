# Baseline PoshQC Test - tests/scripts/dev-tools (Issue 887)

Timestamp: 2026-10-12T14-31
Command: mcp__drm-copilot__run_poshqc_test scan_folders=["tests/scripts/dev-tools"]
EXIT_CODE: 0
Output Summary:
- MCP status: ok=true (passing). Summary: "Ran bundled PoshQC test against '<worktree root>' with 1 selected scan folder(s)."
- Supplementary (read from the gitignored run output artifacts/pester/pester-junit.xml, not from the MCP result): testsuites tests="608" errors="0" failures="0" disabled="2"; 33 testsuite elements.
- Coverage: numeric baseline values recorded in evidence/baseline/ci-coverage-main.<ts>.md (MCP results carry no coverage figure)
