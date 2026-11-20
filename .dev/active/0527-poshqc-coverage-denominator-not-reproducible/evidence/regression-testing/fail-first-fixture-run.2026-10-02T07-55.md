# Pre-Fix Consumer Fixture Run (P2-T6)

Timestamp: 2026-10-02T07-55
Command: MCP-satisfiable deviation DEV-P2-T6 (replaces FR args 'tests/fixtures/poshqc-consumer', 'fixture-run.log', '', 'scripts,tests/scripts' and JX args 'tests/fixtures/poshqc-consumer'): mcp__drm-copilot__run_poshqc_test with workspace_root = <ROOT>/tests/fixtures/poshqc-consumer and scan_folders ["scripts","tests/scripts"]; JX values read from tests/fixtures/poshqc-consumer/artifacts/pester/pester-junit.xml (`testsuites` attributes) with the Read tool
EXIT_CODE: 0
Output Summary: TESTS=1 FAILURES=0 ERRORS=0 DISABLED=0
- MCP result ok=true (the MCP tool reports no process exit status; EXIT_CODE 0 records ok=true and a JUnit file with zero failures and errors).
- tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml exists (also pester-junit.xml and powershell-coverage.koverage.xml).
- Pre-fix configuration: the MCP tool runs the installed extension's PoshQC copy with its bundled runsettings allow-list, which is the issue #623 item 1 configuration (classification row P2-T6, P2-T7). No run log file is written by the MCP route (FR's `fixture-run.log` has no equivalent).
- Acceptance: EXIT_CODE 0, JX FAILURES=0, coverage XML exists. Met.
- Same run as `evidence/other/fixture-mcp-run.2026-10-02T07-55.md`.
