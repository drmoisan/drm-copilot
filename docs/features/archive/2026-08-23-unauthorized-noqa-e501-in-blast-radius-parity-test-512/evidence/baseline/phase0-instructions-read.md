---
Timestamp: 2026-09-30T11-20
Policy Order: 
  1. CLAUDE.md
  2. .claude/rules/general-code-change.md
  3. .claude/rules/general-unit-test.md
  4. .claude/rules/python.md
  5. .claude/rules/python-suppressions.md
---

# Phase 0 — Instructions Read

All five required policy files were read in order before any implementation work.

## Files Read

1. **CLAUDE.md** — Repository standing instructions, policy compliance order, and four-layer runtime architecture. Noted the mandatory policy reading order and that `.claude/rules/` mirror authoritative `.github/` sources.

2. **.claude/rules/general-code-change.md** — Cross-language code change policy covering simplicity-first design, the 500-line file limit for production and test code, and the mandatory seven-stage toolchain loop (format, lint, type-check, architecture, unit tests, contract, integration).

3. **.claude/rules/general-unit-test.md** — Cross-language unit test policy covering independence, isolation, fast execution, determinism, and readability. Noted the uniform coverage thresholds: >= 85% line coverage and >= 75% branch coverage across all tiers (T1–T4) for languages whose coverage tooling measures branch coverage.

4. **.claude/rules/python.md** — Python-specific toolchain and standards. Noted the tools: Black (formatting), Ruff (linting), Pyright (type checking), and Pytest (testing). Confirmed toolchain loop order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files.

5. **.claude/rules/python-suppressions.md** — Pre-authorized suppression patterns for `# noqa` and `# type: ignore`. Confirmed that E501 (line too long) is NOT listed among pre-authorized patterns. Any E501 suppression requires explicit user approval.

## Key Constraints Noted

- **Separation of concerns:** Isolate I/O from domain logic; core logic testable without network/filesystem.
- **Determinism:** No temporary files in tests; no sleeps; mocks used sparingly.
- **Coverage:** Line coverage >= 85%, branch coverage >= 75%, no regression on changed lines.
- **Naming:** `snake_case` for Python functions, `PascalCase` for classes.
- **Assertions:** Use only for internal sanity checks, not user-facing validation.

## Feature Scope

This plan targets `tests/scripts/dev_tools/test_blast_radius_config_parity.py`:
- Remove the unauthorized `# noqa: E501` suppression from line 358.
- Rename the test function to shorten the line below the 88-character limit (no suppression needed).
- Verify no other changes occur and no other linting issues arise.
- Ensure coverage remains unchanged.
