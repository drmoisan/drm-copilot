# Baseline actionlint on ci.yml (Issue #1074)

Timestamp: 2026-11-04T15-29
Task: [P0-T6]
Command: pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/ci.yml (from the worktree root through SCRATCH/issue-1074-actionlint.sh)
EXIT_CODE: 0
Output Summary:
- actionlint 1.7.12 (on PATH).
- Output: only the wrapper line `Running actionlint...`; no finding lines.
- Findings: 0.
