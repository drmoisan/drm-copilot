# HOSTPATH-REGEX Negative Probe (P0-T10, Issue #934)

Timestamp: 2026-10-16T00-14
Command: git -C SCRATCH/issue-934/probe grep --no-index -n -E -e '(^|[^[:alnum:]_])[[:alpha:]](:[^[:alnum:][:space:]]|--)' -- helper-templates.txt
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Empty output (zero matches) over the six-line probe `SCRATCH/issue-934/probe/helper-templates.txt`.
- HOSTPATH-REGEX does not match the `node:path` import, the `UPPER_DRIVE` constant, or the Option A helper templates (`workspacePathOf`, `encodedNameOf`, `WORKSPACE_ROOT`, `EXACT_DIR`).
