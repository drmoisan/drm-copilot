# Task check P1-T1 (remediation cycle 1)

Timestamp: 2026-11-15T18-08
Command: grep -c '^- \[.\] AC-' <FEATURE>/spec.md; grep -c 'AC-16' <FEATURE>/spec.md; git grep -l '<FEATURE>/spec.md' -- tests
EXIT_CODE: 0
Output Summary: changed file: <FEATURE>/spec.md (Markdown). Selection rule (Test Cadence, Markdown path): the contract tests that read that path; `git grep` over `tests/` finds none, so the test selection is empty. AC list holds exactly AC-1..AC-15 (15 checkbox lines, 0 `AC-16` occurrences); AC-2, AC-6, and AC-14 are unchecked. Changed sections: header (Version 0.3, Last Updated), `## Scope & Non-Goals` (classification non-goal narrowed to the two-form supplement with "no command other than these two forms is newly classified"), `## Proposed Fix` (`### Design summary` R1 bullets, new `### Remediation Decision R1 (cycle 1)` with route, rationale, and corrected root cause, `### Boundaries and invariants to preserve`, `#### Files/modules to change`, `#### Rollback/feature-flag considerations`, `#### Backward-compatibility expectations`), the Codex owner-constraint bullet, `## Test Strategy`, and `## Acceptance Criteria` AC-2, AC-6, AC-14.
