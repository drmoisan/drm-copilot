# Preflight Fixes (confirming preflight of the per-field and boundary test cases)

Timestamp: 2026-11-08T18-35
Plan: docs/features/active/2026-11-08-owner-directive-relay-1139/plan.2026-11-08T12-32.md
Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-11-08-owner-directive-relay-1139/plan.2026-11-08T12-32.md
EXIT_CODE: 0
Output Summary: The branch-current Python CLI and the installed MCP validator both passed the plan before the fix below; the Python CLI was re-run after it. One trivial fix was made in task text. The four additions to [P1-T2] and [P1-T3] match the spec `## API / Validator Surface` table: the B2 field list (seven fields) and R2 field list (six fields) and their message templates are the spec's; the B8 cases are violations of the B8 condition and, with every other field valid, trip no other rule; the R1 empty-list case is consistent with the R1 condition, which does not require a non-empty list. Substantive defects found by the design check are reported in the preflight return and are not fixed here.

## Fix 1

- Task: [P1-T2]
- Defect class: explanatory prose that omits a rule (the asserted value is unchanged; the B2 field-set assertion is membership)
- Before: "(B3, B5, B6, B7, and R3 for the fixture record citing `OD-1`)"
- After: "(B3, B5, B6, B7, and R3 or R4 for the fixture record citing `OD-1`)"
- Basis: removing or blanking the `class` of entry #1 leaves the fixture's record #1, which carries `class` `extra_planner_revision`, without a matching directive class, which is the R4 condition. The case asserts membership of the B2 string, so the outcome is unchanged.
