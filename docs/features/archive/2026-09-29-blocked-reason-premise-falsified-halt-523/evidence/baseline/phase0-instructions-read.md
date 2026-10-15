# Phase 0 Policy Reads (P0-T1)

Timestamp: 2026-09-30T14-14
Command: read policy files in the order below (Bash `cat` and the session-loaded standing instructions)
EXIT_CODE: 0
Output Summary: All eleven policy files were read in the order stated by plan task P0-T1.

Policy Order:

1. `CLAUDE.md` (56 lines)
2. `.claude/rules/general-code-change.md` (80 lines)
3. `.claude/rules/general-unit-test.md` (105 lines)
4. `.claude/rules/quality-tiers.md` (51 lines)
5. `.claude/rules/python.md` (100 lines)
6. `.claude/rules/python-suppressions.md` (143 lines)
7. `.claude/rules/powershell.md` (97 lines)
8. `.claude/rules/typescript.md` (74 lines)
9. `.claude/rules/typescript-suppressions.md` (66 lines)
10. `.claude/rules/plan-acceptance-gates.md` (257 lines)
11. `.claude/rules/orchestrator-state.md` (163 lines)

Key constraints noted: 500-line file limit; no temporary files in tests; tests under `tests/` mirroring source; Python toolchain black, ruff, pyright, pytest; TypeScript toolchain prettier, eslint, tsc, jest; PowerShell toolchain PoshQC format, analyze, Pester; no policy-file edits; evidence only under the feature `evidence/<kind>/` folders.
