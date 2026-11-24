# Final QC - Push-Down Contract Suites (remediation cycle 1)

Plan: remediation-plan.2026-11-24T08-32.md
Task: [P1-T8]
Timestamp: 2026-11-24T10-36
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -v (launcher pytest suite, `pytest -n auto`; run through a retry wrapper under the worktree's ignored artifacts/ directory); sha256sum of both edited files and their bundle copies
EXIT_CODE: 0
Output Summary:
- 43 passed in 4.37s, 0 failed; xdist created 24 workers (parallel).
- Per file: test_push_down_claude_resource_contracts.py 14 passed; test_push_down_codex_and_agents_resource_contracts.py 9 passed; test_push_down_claude_pack_manifest_completeness.py 2 passed; test_push_down_pack_manifest_dependency_closure.py 18 passed.
- Hash equality with the bundle copies under extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/:
  - DocsFamilyCheck.psm1: 423649e55e70b8bdf6c0e95c496d60f6cabcd42dee2e7a0b2f72e80282b4d26c in both copies.
  - Invoke-DocsCommand.ps1: f32cd54964fa3c3ca63fcd3dd8e505ad898c306bb11fbddc17a714b1ef7923e1 in both copies.
- Queue timeouts (exit 75, lock busy; re-run after the holder finished): 2026-11-24T10-22 (holder pid 14592), 2026-11-24T10-31 (holder pid 26636), 2026-11-24T10-34 (holder pid 48732).

Owner waiver: targeted contract files only, under the owner instruction dated 2026-11-23: "The full test suite for any destination repo should only be run at the beginning of the orchestration and in the qc run. everything else should be targeted tests."
