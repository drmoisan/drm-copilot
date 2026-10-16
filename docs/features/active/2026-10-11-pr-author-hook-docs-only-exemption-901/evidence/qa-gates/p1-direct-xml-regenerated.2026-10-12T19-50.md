# P1-T6 Direct run regenerated both result files

Timestamp: 2026-10-13T11-17
TIMESTAMP_RECONSTRUCTED: true
TIMESTAMP_ORIGINAL: 2026-10-13T11-32
TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-14 .. 2026-10-13T11-17
TIMESTAMP_DERIVATION: lower: XML_MTIME_AFTER_EPOCH 1791890071 (2026-10-13T11:14:31Z) recorded in this file; upper: committer time of ff1b7cbd4 confirmed in the #927 pa-n3-commit-confirmation evidence
Command: test -f SCRATCHPAD/issue-901-direct-run-start.marker
EXIT_CODE: 0
CMD2_EXIT_CODE: 0 (test -f SCRATCHPAD/issue-901-plan-start.marker)
CMD3_EXIT_CODE: 0 (coverage XML -nt direct-run marker)
CMD4_EXIT_CODE: 0 (pester-junit.xml -nt direct-run marker)
CMD5_EXIT_CODE: 0 (coverage XML -nt plan-start marker)
CMD6_EXIT_CODE: 1 (grep -c MCP-run report name; printed 0)
CMD7_EXIT_CODE: 1 (grep -c P0-T2 report name; printed 0)
CMD8_EXIT_CODE: 0 (grep -c enforce-pr-author-skill.docs-only; printed 2)
CMD9_EXIT_CODE: 0 (grep -c enforce-pr-author-skill.artifact-root; printed 2)
CMD10_EXIT_CODE: 0 (stat -c %Y)
Output Summary: Both result files are newer than both markers. The MCP-run report name count is 0 and the P0-T2 report name count is 0. Class entries exist for docs-only (count 2) and artifact-root (count 2).
XML_MTIME_AFTER_EPOCH: 1791890071
