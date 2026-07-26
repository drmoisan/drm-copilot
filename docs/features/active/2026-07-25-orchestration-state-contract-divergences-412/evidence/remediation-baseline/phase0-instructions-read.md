# Phase 0 — Policy Instructions Read (Remediation Cycle 1, Issue #412)

Timestamp: 2026-07-25T19-51

Policy Order: `policy-compliance-order` skill sequence — (1) standing instructions, (2) cross-language code change policy, (3) cross-language unit test policy, (4) language-specific rules for the files in scope (PowerShell only for this cycle).

## Files Read (in the stated order)

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`

## Constraints Extracted and Binding on This Cycle

- 500-line hard cap on production/test/reusable script files (`general-code-change.md`, "File Size Limit"). `.claude/lib/orchestrator-state/OrchestratorState.psm1` is at 498 lines; budget is 2 lines.
- PowerShell toolchain order is format -> analyze -> test via the PoshQC MCP functions; type checking is not applicable to PowerShell (`powershell.md`, "Toolchain"). Restart from step 1 if any step fails or changes files.
- Direct-mode change budget: up to 2 production PowerShell files plus corresponding tests (`powershell.md`, "Change Budget"). This cycle touches exactly 2 production files (module + byte mirror) and 1 test file.
- Line coverage >= 85%, branch coverage >= 75%; coverage regression on changed lines is blocking (`powershell.md`, "Testing Standards"; `general-unit-test.md`, "Coverage Requirements").
- Creation and use of temporary files in tests is strictly prohibited (`general-unit-test.md`, "External Dependencies"). All fixtures for this cycle are in-memory.
- Tests mirror source structure under `tests/`; Pester 5.x, `Describe`/`Context`/`It`, one behavior per `It` (`general-unit-test.md`, "Test File Location"; `powershell.md`, "Testing Standards").
- Prohibited: weakening assertions to make tests pass; claiming success without running the required toolchain (`powershell.md`, "Prohibited Behaviors").
- Tone policy: professional, factual, neutral (`CLAUDE.md`, "Tone Policy"). Applies to all artifacts written in this cycle.

EXIT_CODE: 0

Output Summary: All four policy files were read from disk in the `policy-compliance-order` sequence prior to any edit in this remediation cycle. No policy file was modified. The binding constraints for this cycle are the 500-line cap (2-line budget on the target module), the PowerShell format -> analyze -> test toolchain order, the 2-production-file change budget, the coverage floors, and the prohibition on temporary files in tests.
