# Phase 0 — Policy Instructions Read

Timestamp: 2026-08-10T14-57

Task: [P0-T1]
Issue: #462
Feature: docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462

Policy Order: The policy files were read in the exact order mandated by the plan's
Required References section and `.claude/skills/policy-compliance-order/SKILL.md`:
standing instructions first, then cross-language code-change policy, then cross-language
unit-test policy, then the language-specific rules for the languages in scope (shell,
TypeScript, Python), then the domain rules that govern the parallel surface and the
quality gates, and finally the tonality policy.

## Files Read (in order)

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/shell.md`
5. `.claude/rules/typescript.md`
6. `.claude/rules/python.md`
7. `.claude/rules/parallel-orchestration.md`
8. `.claude/rules/quality-tiers.md`
9. `.claude/rules/tonality.md`

Count: 9 files.

## Key Constraints Carried Into Execution

- Shell toolchain is native bash (shfmt, shellcheck, bats, kcov); no Python or Poetry
  dependency; on Windows it runs under WSL; CI runs it on `ubuntu-latest`.
- Shell discovery roots are currently `tools/` and `scripts/`; kcov reports line coverage
  only, threshold >= 85%.
- No shell, production, or test file may exceed 500 lines.
- Tests must not create temporary files; checked-in fixtures under `tests/fixtures/` only.
- Python: black, ruff, pyright, pytest with `--cov --cov-branch`; >= 85% line, >= 75% branch.
- TypeScript: prettier, eslint, tsc, jest; >= 85% line, >= 75% branch.
- Parallel-surface schema, its nine enums, and its validator invariants are consumed and
  never extended (`.claude/rules/parallel-orchestration.md`).
- Coverage exclusions may never point at a production path.
- Tone: professional, factual, neutral; no humor, hyperbole, or decorative metaphor.

EXIT_CODE: 0
Output Summary: All nine policy files read in the mandated order. No policy file was
modified. Constraints recorded above govern the remainder of plan execution.
