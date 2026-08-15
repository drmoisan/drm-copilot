# Phase 0 — Policy Instructions Read (issue #472)

Timestamp: 2026-08-15T10-40

Policy Order: The repository policy-compliance reading order defined in `CLAUDE.md` and the `policy-compliance-order` skill: standing instructions first, then cross-language code-change policy, then cross-language unit-test policy, then the language-specific rules for every language in scope (Python, TypeScript, PowerShell).

## Files Read (in order)

1. `CLAUDE.md` — standing repository instructions (tone policy, policy compliance reading order, architecture).
2. `.claude/rules/general-code-change.md` — cross-language code change policy (design principles, mandatory toolchain loop, 500-line file limit, error handling, I/O boundaries).
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy (five core properties, coverage requirements >= 85% line / >= 75% branch, coverage exclusion policy, test file location, determinism infrastructure, prohibition on temporary files in tests).
4. `.claude/rules/python.md` — Python toolchain (`poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`) and coding standards.
5. `.claude/rules/python-suppressions.md` — pre-authorized `# noqa` / `# type: ignore` patterns and the escalation path.
6. `.claude/rules/typescript.md` — TypeScript toolchain (`npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:unit`) and coding standards.
7. `.claude/rules/typescript-suppressions.md` — pre-authorized ESLint / TypeScript suppression patterns and prohibited file-level suppressions.
8. `.claude/rules/powershell.md` — PowerShell toolchain (PoshQC MCP format / analyze / test) and coding standards.

## Notes

- `CLAUDE.md`, `.claude/rules/general-code-change.md`, and `.claude/rules/general-unit-test.md` are auto-loaded as standing instructions in this runtime and were present in context at task start; their content was confirmed present and applied.
- Items 4 through 8 were read explicitly with the Read tool during [P0-T1].
- Binding constraint 2 of the plan of record is acknowledged: `.github/instructions/**` and `.claude/rules/**` are canonical policy and are not modified by this item.
