# Bundle Contract Tests — Fail-Before Baseline

Timestamp: 2026-07-22T13-42

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py

EXIT_CODE: 1

Output Summary:
- 1 failed, 8 passed in 0.22s (9 collected).
- Failing test: test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
- Assertion: `Repo file missing from bundle: .claude\skills\cleanup-merged-worktrees\SKILL.md`
- Cause: the repo runtime skill `.claude/skills/cleanup-merged-worktrees/SKILL.md`
  has no byte-identical mirror under the bundled payload
  `extensions/drm-copilot/resources/claude-customizations/.claude/`.
- All tests in test_push_down_claude_pack_manifest_completeness.py passed at
  baseline; the manifest-completeness failure is expected only after the file
  copy lands without a manifest entry, which this remediation avoids by
  registering the entry in the same cycle (Phase 1 T2).
