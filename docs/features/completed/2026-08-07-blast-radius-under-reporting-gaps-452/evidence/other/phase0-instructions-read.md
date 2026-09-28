# Phase 0 — Policy Instructions Read

Timestamp: 2026-08-08T10-42
Task: [P0-T1]
Feature: 2026-08-07-blast-radius-under-reporting-gaps-452
Branch: bug/blast-radius-under-reporting-452

Policy Order: CLAUDE.md Policy Compliance Reading Order, resolved to the `.claude/rules/` runtime
mirror per `policy-compliance-order`, with language-specific rules selected for the Python and
PowerShell files in scope.

## Files read, in the order read

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`
6. `.claude/rules/self-explanatory-code-commenting.md`
7. `.claude/rules/powershell.md`
8. `.claude/rules/quality-tiers.md`

## Constraints extracted and binding on this plan

- Python toolchain order: `poetry run black .` -> `poetry run ruff check .` -> `poetry run pyright`
  -> `poetry run pytest --cov --cov-branch --cov-report=term-missing`. Restart at step 1 on any
  failure or file modification.
- PowerShell toolchain order: `run_poshqc_format` -> `run_poshqc_analyze` -> `run_poshqc_test`.
  Type checking is not applicable. Restart at step 1 on any failure or file modification.
- Coverage floors are uniform across T1-T4: line >= 85%, branch >= 75%, no regression on changed
  lines.
- 500-line limit applies to every production, test, and reusable script file.
- Ruff `F401` suppression is Explicitly Not Authorized; unused imports must be removed, not
  suppressed. No `# noqa` may be added in this change set.
- Docstrings are mandatory for every function including private helpers; loops, comprehensions,
  and non-trivial branching require intent comments.
- PowerShell change budget: at most 3 production files and 3 test files per batch. Phase
  boundaries in the approved plan are the batch boundaries.
- Policy files under `.claude/rules/**` and `.github/instructions/**` must not be modified.

Output Summary: All eight policy files in the required order were read in full before any code or
test change. No policy file was modified. The extracted constraints above govern every subsequent
phase of the approved plan.
