# Phase 0 — Policy Read Evidence

Timestamp: 2026-04-25T14:37:00Z
Policy Order:
1. `.github/copilot-instructions.md` — tone policy (professional, factual, neutral)
2. `.github/instructions/general-code-change.instructions.md` — baseline code change rules
3. `.github/instructions/general-unit-test.instructions.md` — baseline unit test policy
4. `.github/instructions/python-code-change.instructions.md` — Python coding standards (Black, Ruff, Pyright, pytest)
5. `.github/instructions/python-unit-test.instructions.md` — Python test framework (Pytest)
6. `.github/instructions/python-suppressions.instructions.md` — pre-authorized `# noqa` and `# type: ignore` patterns
7. `.github/instructions/powershell-code-change.instructions.md` — PowerShell coding standards (MCP PoshQC)
8. `.github/instructions/powershell-unit-test.instructions.md` — PowerShell test framework (Pester v5, MCP)

## Files Read

All 8 policy files confirmed read from context (loaded via instructions attachments):
- `.github/copilot-instructions.md` ✓
- `.github/instructions/general-code-change.instructions.md` ✓
- `.github/instructions/general-unit-test.instructions.md` ✓
- `.github/instructions/python-code-change.instructions.md` ✓
- `.github/instructions/python-unit-test.instructions.md` ✓
- `.github/instructions/python-suppressions.instructions.md` ✓
- `.github/instructions/powershell-code-change.instructions.md` ✓
- `.github/instructions/powershell-unit-test.instructions.md` ✓

## Key Policy Constraints Noted

- Python toolchain: Black → Ruff → Pyright → pytest; loop restarts on failure.
- PowerShell toolchain: `mcp__drmCopilotExtension__run_poshqc_format` → `mcp__drmCopilotExtension__run_poshqc_analyze` → `mcp_drmcopilotext_run_poshqc_test`.
- No temporary files in tests; tests must be deterministic and isolated.
- Suppressions require pre-authorization or explicit user approval.
- Coverage: new modules must achieve ≥90%; repo-wide ≥80%.
- Files must not exceed 500 lines.
