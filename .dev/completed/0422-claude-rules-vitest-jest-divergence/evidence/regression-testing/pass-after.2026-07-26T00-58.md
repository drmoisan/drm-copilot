# Pass-After Evidence — TypeScript Toolchain Instruction Contracts (Issue #422)

Timestamp: 2026-07-26T00-58

Command:
```
poetry run pytest tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py
```

EXIT_CODE: 0

Tree state at capture: post-fix. All six paired mirror corrections (`[P2-T1]` .. `[P2-T6]`, twelve files) had been applied.

Output Summary:

- Collected: 15 items
- **Passed: 15**
- Failed: 0
- Duration: 0.05s
- Verbatim result line: `15 passed in 0.05s`

Delta against the fail-before run recorded at `docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/regression-testing/fail-before.2026-07-26T00-58.md`:

| Metric | Fail-before (pre-fix) | Pass-after (post-fix) |
|---|---|---|
| Exit code | 1 | 0 |
| Passed | 3 | 15 |
| Failed | 12 | 0 |

All twelve previously failing cases now pass:

- 6 x `test_mirror_does_not_name_the_vitest_framework` (one per repo-root mirror) — no `vitest` token remains in any of the six mirrors.
- 3 x `test_mirror_does_not_reference_the_vitest_api` — no `vi.*` API token remains; the three that already passed pre-fix still pass.
- `test_typescript_rule_npm_commands_resolve_to_root_package_scripts` — every backtick-wrapped `npm run <script>` token in `.claude/rules/typescript.md` now resolves to a key in the root `package.json` `scripts` block.
- `test_typescript_rule_testing_line_names_the_unit_test_command` — the Testing toolchain line now names `` `npm run test:unit` `` and no longer names `` `npm run test` ``.
- `test_typescript_rule_coverage_line_names_the_coverage_command` — the coverage line now names `` `npm run test:unit:coverage` ``.
