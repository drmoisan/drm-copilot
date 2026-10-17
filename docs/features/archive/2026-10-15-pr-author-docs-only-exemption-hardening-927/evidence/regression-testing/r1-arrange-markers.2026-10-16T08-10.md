# R1 Arrange Marker Parity (Issue #927, CR-9)

Timestamp: 2026-10-16T08-10
Command: grep -c -E "^[[:space:]]+It '" tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1
EXIT_CODE: 0
Output Summary: Every It block in suites A, B, D, E, and F carries an Arrange marker: It/Arrange pairs are 21 21, 13 13, 7 7, 7 7, and 8 8 (CR-5 removed the probe row from E).

PAIR A tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1: 21 21
PAIR B tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1: 13 13
PAIR D tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1: 7 7
PAIR E tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1: 7 7
PAIR F tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1: 8 8

Commands (per suite, all exit 0): grep -c -E "^[[:space:]]+It '" <suite>; grep -c -E '^[[:space:]]+# Arrange' <suite>
