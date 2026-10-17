# Phase 1 Handoff (Issue #406)

Timestamp: 2026-09-30T10-05

Executor performs Phase 1 directly under the plan's constrained extract-and-move rules.

Files written by P1-T2 through P1-T9 (eight):
1. scripts/dev_tools/potential_to_issue_adapters.py (P1-T2, create)
2. scripts/dev_tools/potential_to_issue.py (P1-T3, edit)
3. tests/scripts/dev_tools/potential_to_issue_test_support.py (P1-T4, create)
4. tests/scripts/dev_tools/test_potential_to_issue.py (P1-T5, edit)
5. tests/scripts/dev_tools/test_potential_to_issue_bug_bodies.py (P1-T6, create)
6. tests/scripts/dev_tools/test_potential_to_issue_work_modes.py (P1-T7, create)
7. tests/scripts/dev_tools/test_potential_to_issue_cli_and_adapters.py (P1-T8, create)
8. tests/scripts/dev_tools/test_potential_to_issue_content.py (P1-T9, edit)

Acceptance criteria:
- AC1: scripts/dev_tools/potential_to_issue.py is decomposed to <= 500 lines per file, preserving public behavior.
- AC2: tests/scripts/dev_tools/test_potential_to_issue.py is decomposed to <= 500 lines per file, preserving test coverage.
- AC3: TS/Python config-parity test continues to pass (no behavioral drift introduced by the split).
- AC4: Full Python toolchain (Black, Ruff, Pyright, Pytest) passes with no coverage regression.

Rule: P1-T2 through P1-T9 are the only source edits permitted.
Deviation D1 applies: the adapters module receives five names; the #623 filesystem module is untouched.
