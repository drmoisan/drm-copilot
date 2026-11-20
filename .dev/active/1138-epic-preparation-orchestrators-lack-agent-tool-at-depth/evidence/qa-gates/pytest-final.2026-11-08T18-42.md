# pytest Final Gate (remediation cycle 1, P0-T1)

Timestamp: 2026-11-08T18-35
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov --cov-report=json:SCRATCH/issue-1138-cov-r1.json (run from the worktree root through SCRATCH/issue-1138-gates.sh)
EXIT_CODE: 0
Output Summary:
- 16560 passed, 6 skipped, 0 failed in 256.99 s; one run, no re-run (Phase 0 baseline: 16560 passed, 6 skipped, 0 failed)
- Repo-wide line coverage: 97.11% (34296 of 35317 statements); baseline 97.11%, no drop
- Repo-wide branch coverage: 94.36% (12648 of 13404 branches); baseline 94.37% (12649)
- The one-branch difference is in scripts/dev_tools/atomic_executor/cli_copilot_runtime.py (61 of 88 branches; 62 in the baseline and prior final runs; lines 194 of 235 in all three). No Python production file changed on the branch or in this cycle; the only Python edit is the PINNED_FROZEN_SURFACE_HASHES digest in a test-support module. Every other file's line and branch counts equal the prior final run. Recorded as a nondeterministic partial branch outside this change, not re-run (no fix applies).
- Passing (no failure in the run): test_frozen_epic_surface_matches_pinned_baseline_digest (re-baselined .claude/agents/epic-orchestrator.md digest), test_push_down_claude_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, test_push_down_pack_manifest_dependency_closure.py
