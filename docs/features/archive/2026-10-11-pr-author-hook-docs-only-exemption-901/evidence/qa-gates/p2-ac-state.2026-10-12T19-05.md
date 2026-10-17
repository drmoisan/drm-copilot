# P2-T1 End state of acceptance criteria

Timestamp: 2026-10-12T19-42
Command: grep -c -F -e '- [x] AC-9:' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md
EXIT_CODE: 0
CMD2_EXIT_CODE: 1 (grep -c -F -e '- [ ] AC-' ...; count 0 exits 1)
CMD3_EXIT_CODE: 0 (grep -c -F -e '- [x] AC-' ...)
CMD4_EXIT_CODE: 0 (grep -c -F -e 'AC-9: No edited PowerShell file exceeds 500 lines' ...)
Output Summary:
- Counts printed 1, 0, 10, 1: AC-9 is checked, no open criterion remains, 10 criteria are checked, and the AC-9 text is unchanged.
