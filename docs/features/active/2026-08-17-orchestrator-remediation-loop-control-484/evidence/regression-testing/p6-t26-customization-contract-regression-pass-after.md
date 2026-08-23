# P6-T26 customization contract regression pass-after

Timestamp: 2026-08-23T05-56

Output Summary: PASS. The safe eight-file suite collected and passed all 41
nodes, including every one of the 13 named P2-T16 contract nodes. The generic
surface, Codex variant, and customization-bundle owner checks all exited 0.
The explicit Codex root/mirror SHA-256 comparison found all 13 affected pairs
byte-identical. No test assertion or generated output was edited during this
task.

Command: `poetry run pytest -o "addopts=" tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_codex_full_migration_inventory.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_codex_orchestration_contracts.py tests/scripts/dev_tools/test_csharp_orchestration_contracts.py tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py`

EXIT_CODE: 0

Output Summary: 41 passed in 0.29 seconds.

Command: `poetry run python -m scripts.dev_tools.generate_orchestration_customization_surfaces --check`

EXIT_CODE: 0

Output Summary: Verified 20 orchestration customization surfaces.

Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`

EXIT_CODE: 0

Output Summary: No Codex agent alias, routed-variant, or manifest drift.

Command: `poetry run python -m scripts.dev_tools.synchronize_customization_bundles --check`

EXIT_CODE: 0

Output Summary: Verified 48 packaged customization mappings.

## Required named-node results

| Exact node | Result |
|---|---|
| `test_feature_reviewer_wrapper_preserves_codex_remediation_handoff` | PASS |
| `test_orchestrator_wrapper_preserves_codex_mandatory_delegation_contract` | PASS |
| `test_codex_agent_contracts_follow_expected_wrapper_or_native_patterns` | PASS |
| `test_feature_review_remediation_handoff_is_strict_in_skill_and_agent` | PASS |
| `test_codex_orchestrator_agent_requires_mandatory_specialist_handoffs` | PASS |
| `test_orchestrate_csharp_work_prompt_requires_minor_audit_lifecycle` | PASS |
| `test_minor_audit_contract_files_require_explicit_acceptance_section` | PASS |
| `test_codex_orchestrators_enforce_checkpoint_and_lifecycle_guardrails` | PASS |
| `test_claude_orchestrator_documents_promotion_receipt_namespace` | PASS |
| `test_root_orchestrators_use_direct_potential_entry_commands` | PASS |
| `test_root_orchestrators_use_direct_potential_to_issue_commands` | PASS |
| `test_root_orchestrators_use_direct_new_active_feature_folder_commands` | PASS |
| `test_mirrored_orchestrator_agents_match_root_direct_command_contracts` | PASS |

## Root/mirror equality

Each root hash equals the corresponding file below
`extensions/drm-copilot/resources/codex-and-agents-customizations/`.

| Root path | SHA-256 | Equal |
|---|---|---|
| `.codex/agents/feature-review.toml` | `C261975B7C99DF8AE5642998D14D4DE85A5B5639FBE788EBB2CC97D601A0E3E3` | yes |
| `.codex/agents/orchestrator.toml` | `CB51B12A635BAC1C9CA5E7D76215698B4C1B37E7213690089AAED462E1124614` | yes |
| `.codex/agents/orchestrator-c1.toml` | `801BA71F157A72D8B3C940FAED692D1912E69709E8BCA9196F53F826589E3E7B` | yes |
| `.codex/agents/orchestrator-c2.toml` | `29AD5B7E17C8F0D8B6ED636C42EBF92EB94007BCEC9D7D3B9C0028763EB9A958` | yes |
| `.codex/agents/orchestrator-c3.toml` | `98635CC6072ED5517AB8BC1E827E9AE287B21469DF9A5EC2DD3BCFF41153F02B` | yes |
| `.codex/agents/orchestrator-c3-elevated.toml` | `4C156A0962B2296888D767BDD470BAB065BB93A3EED2D2283443413CE950F3C9` | yes |
| `.codex/agents/orchestrator-c4.toml` | `3DF703923A4F01D78E16B5C0C4F8A8DA056108AE09D6DF50845CECFDE4F343EC` | yes |
| `.codex/agents/task-researcher.toml` | `605B0CCF6C7F297B127535463A012BF894A0D491F8FE680FD30A388A63BFC86F` | yes |
| `.codex/agents/task-researcher-c1.toml` | `0231D5C57C1BB9DC717AE1DF2F4A59C4781889EBBA1CF25A2AD0AD67892975E2` | yes |
| `.codex/agents/task-researcher-c2.toml` | `8CA6506E303B99A9359BAFE649FCA5E5B70DEEA8D611079F3DC5F7D651B63873` | yes |
| `.codex/agents/task-researcher-c3.toml` | `8711449CF9936B7D3E89DB1BE2FF05B62D14BD622ECD8574A424AC881E414474` | yes |
| `.codex/agents/task-researcher-c3-elevated.toml` | `05C64703B25AE115095BA062555467AB686674C374816942A0AA780F74024AAD` | yes |
| `.codex/agents/task-researcher-c4.toml` | `55922A26B68175184BD3AF5973FD4407EFBE90DEFB76F4BF2F25EDB53694A9C3` | yes |

The safe suite's direct-command mirror contract passed, and the synchronizer
owner check verified all 48 mapped root/mirror pairs.
