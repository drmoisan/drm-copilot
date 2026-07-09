# Phase 0 — Instructions Read

Timestamp: 2026-07-07T12-24

Policy Order:
1. CLAUDE.md standing instructions (auto-loaded)
2. .claude/rules/general-code-change.md (cross-language code change policy)
3. .claude/rules/general-unit-test.md (cross-language unit test policy)
4. .claude/rules/powershell.md (PoshQC loop, seams, mocking, change budget)
5. .claude/rules/typescript.md (Prettier/ESLint/tsc/test loop, pure-module rules)
6. .claude/rules/typescript-suppressions.md (suppression authorization)
7. .claude/rules/quality-tiers.md (uniform coverage thresholds)

Files Read (explicit list):
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/powershell.md
- .claude/rules/typescript.md
- .claude/rules/typescript-suppressions.md
- .claude/rules/quality-tiers.md
- .claude/rules/architecture-boundaries.md (in scope for pure-module import contract)

Notes:
- Uniform coverage thresholds: line >= 85%, branch >= 75% across all tiers (T1-T4).
- PowerShell files must stay under 500 lines; use scriptblock/adapter seams for filesystem access; no temp files in tests.
- TypeScript pure command-builder modules must not import vscode, node:fs, node:child_process, or node:path (remove-worktrees.ts).
- Coverage-enabled test commands are mandatory for both languages.
