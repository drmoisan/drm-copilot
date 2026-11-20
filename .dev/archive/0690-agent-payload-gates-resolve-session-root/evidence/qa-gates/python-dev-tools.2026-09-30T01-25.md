# Python Regression tests/scripts/dev_tools (P13-T2) - NOT PASSED

Timestamp: 2026-09-30T01-25
Command: poetry run pytest tests/scripts/dev_tools -q -rf
EXIT_CODE: 1
Output Summary:
- 2 failed, 5250 passed, 6 skipped (collected total 5258, equal to the P0-T38 total of 1 + 5251 + 6).
- FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts (KL-510, case b, STATE-ONLY; member of the P0-T38 baseline failure set).
- FAILED tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/skills/epic-orchestrate/SKILL.md-620183f57a337dedf6158d61264b2257d012762454a9af0b3b6f059ff79ab00b] - NOT a member of the baseline failure set.
- Cause: the Phase 2 edit of .claude/skills/epic-orchestrate/SKILL.md (Appendix D2, commit 0dcb1cf5) changed a file whose SHA-256 is pinned in tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py (PINNED_FROZEN_SURFACE_HASHES). Issues #663 and #762 re-baselined that pin by editing the Python file.
- Acceptance not met. The fix requires either a Python edit to the pin (conflicts with P13-T3, "No Python file changed") or reverting the planned D2 skill edit. This is a plan-scope decision; execution halted here for a plan revision.
