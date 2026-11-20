# Contract Tests (Phase 8 gate)

Timestamp: 2026-10-31T15-55
Command: poetry run pytest <the fifteen contract modules below> -q -p no:cacheprovider --no-cov -rf; poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check; sh SCRATCH/issue-1013-pester-run.sh p8t3 (branch-current Pester over claude-architecture-doc, hook-dependency-guard-completeness, BlastRadius.Manifest, and ClaudeLibModuleConvention; counts from the JUnit file)
EXIT_CODE: 0
Output Summary: zero failures. pytest 280 passed; generator check exit 0 (no drift); Pester JUnit tests=688 failures=0 errors=0 skipped=0, of which BlastRadius.Manifest.Tests.ps1 tests=4 failures=0.

## pytest modules (all passed)

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`
- `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`
- `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py`
- `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py`
- `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`
- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` (consumes `PINNED_FROZEN_SURFACE_HASHES`; `test_frozen_epic_surface_matches_pinned_baseline_digest` passes, no pinned file edited)
- `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`
- `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`
- `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py`
- `tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py` (#1002; `test_bundled_copies_are_byte_identical_to_canonical[skill]` and `[agent]` pass after P8-T1)
- `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` (`test_orchestration_skills_carry_the_linkage_and_current_mirrors` rows and `test_execution_environment_fact_is_unchanged_across_copies` pass)
- `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` (added to this run: its `test_edited_surface_matches_bundled_mirror[claude-parallel-orchestrate]` row is a bundle byte-identity row that failed between P7-T4 and P8-T1; it passes now)

## Generator

- `scripts/dev_tools/generate_codex_agent_variants.py --check`: exit 0, no drift.

## Pester (branch-current)

- `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1`: tests=4, failures=0 (`lists every discovered library module in core.json paths`, `ships a bundled counterpart for every library module`, and `lists the facade module exactly once` pass).
- `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`, `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`: zero failures.
