# Phase 0 — Policy Instruction Read Evidence

Timestamp: 2026-08-07T14-17

Task: [P0-T1]
Feature: 2026-08-07-parallel-blast-radius-447 (issue #447)
Branch: feature/parallel-blast-radius-447

Policy Order: the `policy-compliance-order` sequence as enumerated by [P0-T1] — standing instructions first (`CLAUDE.md`), then the cross-language code-change policy, then the cross-language unit-test policy, then the language-specific rules for the languages in scope (Python, then PowerShell), then the Python commenting/docstring policy. Precedence follows this order when policies conflict.

## Files Read (7)

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`
6. `.claude/rules/powershell.md`
7. `.claude/rules/self-explanatory-code-commenting.md`

## Constraints Carried Forward

- Toolchain order per language: Python `black` -> `ruff` -> `pyright` -> `pytest`; PowerShell `run_poshqc_format` -> `run_poshqc_analyze` -> `run_poshqc_test` (no type-check stage). Restart from step 1 if any stage fails or changes files.
- Coverage thresholds are uniform across T1-T4: line >= 85%, branch >= 75%. No coverage regression on changed lines.
- No production, test, or reusable script file may exceed 500 lines.
- Tests must not use temporary files, network, external processes, sleeps, or wall-clock reads.
- Test files must live under `tests/` mirroring the production tree; colocation is prohibited.
- Suppressions (`# noqa`, `# type: ignore`) require a pre-authorized pattern or explicit approval.
- Python requires full type annotations, mandatory class/function docstrings, intent comments on loops and branching.
- PowerShell targets 7+, advanced functions with `CmdletBinding()`, approved verbs, `throw`/`Write-Error` for failures.
- Policy files under `.claude/rules/` and `.github/instructions/` must not be modified.

Output Summary: All seven policy files in the required order were read prior to any Phase 0 command execution. No policy file was modified.
