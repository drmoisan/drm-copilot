# Potential-Entry Disposition (P6-T29)

Timestamp: 2026-10-02T08-45
Command: git/static-equivalent deviation DEV-P6-T29 (replaces `Select-String -SimpleMatch`). `git grep -c -F -e 'Superseded by #527' -- docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md` and `git grep -c -F -e '## Disposition' -- docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md`, run from `<ROOT>`.
EXIT_CODE: 0
Output Summary: `Superseded by #527` count 1; `## Disposition` count 1.
- Acceptance: both counts at least 1. Met.
