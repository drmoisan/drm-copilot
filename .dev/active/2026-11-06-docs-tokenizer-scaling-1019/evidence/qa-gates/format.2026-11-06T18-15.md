# Format Gate - Issue 1019

Timestamp: 2026-11-06T18-15
Command: mcp__drm-copilot__run_poshqc_format with scan folders .claude/lib/docs and tests/scripts/claude-lib/docs, then sh SCRATCH/issue-1019-p2-qc.sh (git status --porcelain, sha256sum, SCRATCH/issue-1019-hunkcheck.ps1, and an Invoke-Formatter comparison that writes no file)
EXIT_CODE: 0
Output Summary: First pass and passing pass. The MCP call returned ok true, which proves invocation only. Direct observation: SHA-256 of MODULE, BUNDLE, and SUITE unchanged before and after, git status --porcelain empty after the run, Invoke-Formatter text equal for MODULE and SUITE. Candidate hunks remain byte-identical (hunk failures 0). No re-copy of BUNDLE was required.

## Hashes

| File | SHA-256 before | SHA-256 after |
| --- | --- | --- |
| `MODULE` | `6010cf357e5816136cf60b8d0e7dcf52f85555c42c7ec37b7e65883493ab9cbf` | `6010cf357e5816136cf60b8d0e7dcf52f85555c42c7ec37b7e65883493ab9cbf` |
| `BUNDLE` | `6010cf357e5816136cf60b8d0e7dcf52f85555c42c7ec37b7e65883493ab9cbf` | `6010cf357e5816136cf60b8d0e7dcf52f85555c42c7ec37b7e65883493ab9cbf` |
| `SUITE` | `3955c528ee69a12143f1f6614069a0b9f4224d4a8a56f0de9706b15cff1faf61` | `3955c528ee69a12143f1f6614069a0b9f4224d4a8a56f0de9706b15cff1faf61` |

## Candidate Hunk Identity

| File | Added lines | Missing | Out of order | Removed lines | Still present |
| --- | --- | --- | --- | --- | --- |
| `MODULE` | 12 | 0 | 0 | 3 | 0 |
| `SUITE` | 41 | 0 | 0 | 0 | 0 |

The folder scan covered both folders because the MCP tool accepts folders rather than files; `git status --porcelain` shows that no other file in them changed.
