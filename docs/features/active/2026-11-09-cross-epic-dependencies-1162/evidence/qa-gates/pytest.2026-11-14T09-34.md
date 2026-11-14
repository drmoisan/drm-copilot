# pytest Final Gate — Remediation Cycle 1, P2-T5 (Issue 1162)

Timestamp: 2026-11-14T09-30
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1162-cov-final.json --junitxml=SCRATCH/issue-1162-junit-final.xml -q -p no:cacheprovider (from the item worktree root, through sh SCRATCH/issue-1162-pytest-gate.sh final)
EXIT_CODE: 0
Output Summary:
- Counts: 16822 passed, 0 failed, 6 skipped (202.70 s); the JUnit report shows tests=16828, failures=0, errors=0. Started 2026-11-14T09-30-49Z, ended 2026-11-14T09-34-19Z. Phase 0 baseline: 16815 passed, 0 failed, 6 skipped. The 7 additional tests came in with the #1156 merge.
- `test_frozen_epic_surface_matches_pinned_baseline_digest` passed for both parameters (`.claude/agents/epic-orchestrator.md` with digest 5561f79d…af03 and `.claude/skills/epic-orchestrate/SKILL.md` with digest e334237b…7e80).
- Push-down contract tests passed: test_push_down_claude_resource_contracts (14), test_push_down_codex_and_agents_resource_contracts (9), test_push_down_claude_pack_manifest_completeness (2), test_push_down_codex_and_agents_pack_manifest_completeness (2), and test_push_down_pack_manifest_dependency_closure (18) test cases.
- Repository total (scripts.dev_tools), from the JSON report: line 94.93% (17145/18060), branch 90.48% (5995/6626). Phase 0 baseline: line 94.93%, branch 90.48%. No change.
- `artifacts/python/lcov.info` was written by this run (addopts reporter).
