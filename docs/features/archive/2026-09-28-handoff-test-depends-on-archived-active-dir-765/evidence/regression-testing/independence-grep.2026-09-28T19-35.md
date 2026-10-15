Timestamp: 2026-09-28T19-48
Command: git grep -nF 'resolve_pinned_plan_path(ROOT, "docs/features/active")' -- tests/scripts/dev_tools/test_orchestration_handoff_paths.py ; git grep -cF 'resolve_pinned_plan_path(ROOT, FIXTURES.relative_to(ROOT).as_posix())' -- tests/scripts/dev_tools/test_orchestration_handoff_paths.py
EXIT_CODE: 1 (removed literal, zero matches, expected) ; 0 (replacement literal, count 1)
Output Summary: Removed literal: exit 1, zero matches. Replacement literal: exit 0, count 1 (test_orchestration_handoff_paths.py:1).
The local docs/features/active/ directory exists for issue #765, so a local test pass cannot show independence from it; this grep result, not the test pass, is the independence evidence.
