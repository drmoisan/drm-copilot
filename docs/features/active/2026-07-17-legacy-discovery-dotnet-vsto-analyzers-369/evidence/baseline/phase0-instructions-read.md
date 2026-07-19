# Phase 0 — Policy Instructions Read Evidence

- Timestamp: 2026-07-18T21-15
- Task: [P0-T1]
- Feature: legacy-discovery-dotnet-vsto-analyzers (#369)

## Policy Order

Policy files were read in the following required order:

1. `.github/copilot-instructions.md` — repository tone and communication policy
2. `.github/instructions/general-code-change.instructions.md` — baseline code change rules
3. `.github/instructions/general-unit-test.instructions.md` — baseline unit test rules
4. `.github/instructions/python-code-change.instructions.md` — Python code change rules
5. `.github/instructions/python-unit-test.instructions.md` — Python unit test rules

## Rule Mirrors Read

- `.claude/rules/python.md` — Python toolchain and coding standards
- `.claude/rules/python-suppressions.md` — Python suppression authorization policy
- `.claude/rules/general-code-change.md` — cross-language code change policy mirror
- `.claude/rules/general-unit-test.md` — cross-language unit test policy mirror
- `.claude/rules/quality-tiers.md` — module rigor tiers and gate matrix
- `.claude/rules/self-explanatory-code-commenting.md` — commenting/docstring policy

## Files Read (explicit list)

- `.github/copilot-instructions.md`
- `.github/instructions/general-code-change.instructions.md`
- `.github/instructions/general-unit-test.instructions.md`
- `.github/instructions/python-code-change.instructions.md`
- `.github/instructions/python-unit-test.instructions.md`
- `.claude/rules/python.md`
- `.claude/rules/python-suppressions.md`
- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/quality-tiers.md`
- `.claude/rules/self-explanatory-code-commenting.md`

## Key Compliance Points Recorded

- Toolchain loop order (mandatory, restart on any change/failure): Black format -> Ruff lint -> Pyright type-check -> Pytest with coverage.
- Coverage thresholds (canonical quality-tiers.md): line >= 85%, branch >= 75% uniform across T1-T4. New modules target >= 90% per general-unit-test.
- 500-line limit applies to all production and test files; raw text fixtures exempt.
- No temporary files in tests; use the in-memory `mem_fs_path` fixture.
- No new runtime dependency without explicit approval; stdlib only for this feature.
- Suppressions require pre-authorized pattern or explicit approval.
- Docstrings mandatory for every class and function; intent comments for loops and branches.
