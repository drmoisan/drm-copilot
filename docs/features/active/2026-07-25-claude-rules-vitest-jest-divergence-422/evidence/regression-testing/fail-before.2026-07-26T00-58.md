# Fail-Before Evidence — TypeScript Toolchain Instruction Contracts (Issue #422)

Timestamp: 2026-07-26T00-58

Command:
```
poetry run pytest tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py
```

EXIT_CODE: 1 (non-zero; failure is the expected outcome for `[P1-T3] [expect-fail]`)

Tree state at capture: pre-fix. No Phase 2 mirror edit had been applied. `git status --porcelain` at this point showed only the new test module and the feature-folder evidence directory as additions; none of the twelve mirror files was modified.

Output Summary:

- Collected: 15 items
- **Failed: 12**
- Passed: 3
- Duration: 0.12s
- Verbatim result line: `12 failed, 3 passed in 0.12s`

Failing assertions, grouped by the property they enforce:

1. Framework-token absence — `test_mirror_does_not_name_the_vitest_framework` failed for all six repo-root mirrors, at exactly the lines named in `spec.md`:
   - `.claude/rules/typescript.md` — lines 16, 42, 51, 73
   - `.claude/rules/general-unit-test.md` — lines 40, 105
   - `.claude/rules/general-code-change.md` — line 39
   - `.claude/agents/atomic-executor.md` — lines 18, 79
   - `.agents/skills/general-unit-test/SKILL.md` — lines 45, 110
   - `.agents/skills/general-code-change/SKILL.md` — line 44

2. Vitest `vi.*` API absence — `test_mirror_does_not_reference_the_vitest_api` failed for the three mirrors that carry `vi.*` tokens:
   - `.claude/rules/typescript.md` — line 47 (`vi.spyOn`, `vi.mock`, `vi.resetAllMocks()`), line 73 (`vi.useFakeTimers()`)
   - `.claude/rules/general-unit-test.md` — line 105 (`vi.useFakeTimers()`)
   - `.agents/skills/general-unit-test/SKILL.md` — line 110 (`vi.useFakeTimers()`)
   The remaining three mirrors passed this assertion pre-fix (they name Vitest but use no `vi.*` API token), which accounts for the 3 passing cases.

3. Command resolution — `test_typescript_rule_npm_commands_resolve_to_root_package_scripts` failed:
   `AssertionError: .claude/rules/typescript.md names npm scripts that do not exist in root package.json: ['test:coverage']`

4. Semantic anchors:
   - `test_typescript_rule_testing_line_names_the_unit_test_command` failed: the Testing toolchain line reads ``4. **Testing — Vitest**: All TypeScript unit tests must use Vitest. Command: `npm run test` `` and does not name `` `npm run test:unit` ``.
   - `test_typescript_rule_coverage_line_names_the_coverage_command` failed: the coverage line reads ``- Coverage command: `npm run test:coverage` (the script is wired in Prompt B1 alongside the Vitest dependency).`` and does not name `` `npm run test:unit:coverage` ``.

Toolchain state of the new module at capture time (all clean, per `[P1-T2]`): `poetry run black` exit 0 (1 file left unchanged), `poetry run ruff check` exit 0 (`All checks passed!`), `poetry run pyright` exit 0 (`0 errors, 0 warnings, 0 informations`).
