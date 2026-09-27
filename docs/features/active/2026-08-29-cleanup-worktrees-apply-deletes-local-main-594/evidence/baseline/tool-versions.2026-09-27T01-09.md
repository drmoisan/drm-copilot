# P0-T4 — Tool Availability (issue #594)

Timestamp: 2026-09-27T01-09
Task: [P0-T4]
Working directory: repository worktree root

## shfmt

Command: `shfmt --version`
EXIT_CODE: 0
Output: `v3.12.0`

## shellcheck

Command: `shellcheck --version`
EXIT_CODE: 0
Output: `version: 0.11.0`

## bats (via npx)

Command: `npx --yes bats --version`
EXIT_CODE: 0
Output: `Bats 1.13.0`

## gh

Command: `gh version`
EXIT_CODE: 0
Output: `gh version 2.87.3 (2026-02-23)`

Output Summary:
- shfmt v3.12.0 (CI pins 3.8.0; local drift is expected and CI is canonical).
- shellcheck 0.11.0.
- bats resolves through npx: `Bats 1.13.0` (line begins `Bats `); the P1-T20 CI fallback is not required.
- gh 2.87.3.
- All four commands exit 0.
