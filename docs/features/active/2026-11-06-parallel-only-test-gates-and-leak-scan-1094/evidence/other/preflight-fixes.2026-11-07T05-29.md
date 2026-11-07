# Preflight Fixes (Remediation Cycle 3)

Timestamp: 2026-11-07T05-29
Plan: docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/remediation-plan.2026-11-07T05-01.md

Each fix edits task text only. No task was added, removed, or reordered, and no asserted value changed.

## Fixes

1. [P1-T1], citation correction. The existing-test list named `E4-CORPUS-1` to `E4-CORPUS-3`. `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` also holds `E4-CORPUS-4`, whose inputs do not hold the removed text. The list now reads `E4-CORPUS-1` to `E4-CORPUS-4`, with the same unchanged disposition.
2. [P1-T1], literal clarification. The task now states that `-Lines` accepts empty strings. Audit text holds blank lines, and a mandatory string array rejects an empty element unless it is declared to allow one.
3. [P1-T3], literal clarification. The Python row case holds a non-ASCII check mark. The task now states that the suite builds it with `[char]0x2705`, so the test file stays ASCII and the P2-T1 analyzer gate is not affected by the file encoding. The asserted row text is unchanged.
4. Open Questions / Notes, stale fact. The Jest note stated that `coverage/lcov.info` is absent. The file is present in the worktree from the cycle 2 Jest gate. The note now states that, and that P2-T3 reads the file for the TypeScript row.
