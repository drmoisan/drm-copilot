# Contract and Parity Set — Issue #964

Timestamp: 2026-10-17T00-37
Task: [P5-T4]
Command: sh SCRATCH/issue-964-contracts.sh (poetry run pytest -q over the seventeen suites below, then one fresh Pester 5 process over the three claude-runtime suites)
EXIT_CODE: 0
Output Summary:
- Python: 238 passed, 0 failed (pytest exit 0).
- Pester: Passed=636 Failed=0 Skipped=0 Total=636 (exit 0).
- Preceding steps in this phase: [P5-T1] copy script `COPIED=36 MISMATCH=0`; [P5-T2] both pack-manifest completeness tests 4 passed; [P5-T3] generator write mode then `--check` exit 0, changed set = 20 generated `.codex/agents` variants, 24 bundle `.codex/agents` files and the Codex `core.json`.

## Suites (all zero failures)

Python, under `tests/scripts/dev_tools/`:

- `test_execution_environment_brief_contracts.py`
- `test_plan_gate_document_docs.py`
- `test_plan_gate_scratch_docs.py`
- `test_single_pass_preflight_contracts.py`
- `test_push_down_claude_resource_contracts.py`
- `test_push_down_codex_and_agents_resource_contracts.py`
- `test_push_down_claude_pack_manifest_completeness.py`
- `test_push_down_codex_and_agents_pack_manifest_completeness.py`
- `test_codex_agent_wrapper_contracts.py`
- `test_codex_handoff_contract_parity.py`
- `test_claude_rules_frontmatter.py`
- `test_claude_planning_integrity_contracts.py`
- `test_scratch_location_contracts.py`
- `test_parallel_orchestrator_surface_contracts.py`
- `test_quality_checks_workflow_contracts.py`
- `test_push_down_issue_824_follow_ups.py`
- `test_typescript_toolchain_instruction_contracts.py`

Pester:

- `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`
- `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`

## Generator Newline Note

The first generator write run rewrote six Codex pack manifests with CRLF line endings on Windows (content unchanged). The files were normalized to LF with SCRATCH/issue-964-lf-normalize.py, and the generator's manifest write now uses its newline-preserving helper; a second write run left only the intended `core.json` change.
