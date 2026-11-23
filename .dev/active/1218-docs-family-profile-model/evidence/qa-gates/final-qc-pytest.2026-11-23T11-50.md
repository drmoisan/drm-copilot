# Final-QC pytest Gate (Issue #1218, P4-T2)

Timestamp: 2026-11-23T11-50
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest (one pytest -n auto run through the launcher, worktree form, via SCRATCH/issue-1218-both-gates.sh)
EXIT_CODE: 0
Output Summary:
- First attempt ran (no queue timeout); started 2026-11-23T11-48 UTC.
- Result: 17104 passed, 6 skipped, 0 failed in 73.51s (Phase 0 baseline: 17104 passed, 6 skipped, 0 failed).
- The push-down contract tests test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, and test_push_down_pack_manifest_dependency_closure.py ran in this gate with no failure.
- Python coverage: not in scope (the branch changes no Python file).
- PowerShell per-file line coverage from the same final QA loop's Pester gate (final-qc-pester.2026-11-23T11-50.md): DocsProfileFamilies.psm1 100.00%, DocsProfile.psm1 100.00%, DocsProfileCommands.psm1 97.75%.
