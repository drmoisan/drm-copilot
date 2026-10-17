# HOSTPATH-REGEX Positive Control (P0-T11, Issue #934)

Timestamp: 2026-10-16T00-14
Command: git -C SCRATCH/issue-934/probe grep --no-index -n -E -e '(^|[^[:alnum:]_])[[:alpha:]](:[^[:alnum:][:space:]]|--)' -- positive-control.txt
EXIT_CODE: 0
Output Summary:
- Exactly 3 output lines:
  - `positive-control.txt:1:` (forward-slash drive path)
  - `positive-control.txt:2:` (backslash drive path)
  - `positive-control.txt:3:` (encoded name with double hyphen)
- HOSTPATH-REGEX matches all three host-path shapes.
