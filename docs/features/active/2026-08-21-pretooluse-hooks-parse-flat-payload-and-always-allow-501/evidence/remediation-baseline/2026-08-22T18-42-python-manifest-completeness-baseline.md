# Baseline — Python manifest-completeness test (expect-fail)

Timestamp: 2026-08-22T18-42
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest -v
EXIT_CODE: 1
Output Summary: 1 failed. AssertionError: Bundled .claude files missing from every manifest: ['.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1', '.claude/hooks/enforce-pr-author-skill-helpers.ps1']. Confirms the CI failure reproduces locally before the fix.
