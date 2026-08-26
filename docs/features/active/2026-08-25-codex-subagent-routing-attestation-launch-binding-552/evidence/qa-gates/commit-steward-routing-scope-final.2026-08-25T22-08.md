Timestamp: 2026-08-25T22-08
Command: Get-FileHash/Get-Item for revision paths and staged PoshQC mirror; git status --short; git diff --name-only; git diff --cached --name-only -- docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/evidence
EXIT_CODE: 0
Output Summary: The staged PoshQC mirror retains P3-T2 SHA-256 7A43CE095D86E1944CDE00435F1957A211B9667C1728B00AC2A0D4B8B4EE10FD and length 15349. Existing staged evidence remains staged and unchanged; all newly created evidence is below this feature's canonical evidence hierarchy. No command outcome in this revision is SKIPPED.

Allowed non-evidence revision paths verified:
- config/orchestration-routing.json
- extensions/drm-copilot/resources/config/orchestration-routing.json
- scripts/dev_tools/resolve_codex_deployment.py
- scripts/dev_tools/generate_codex_agent_variants.py
- tests/scripts/dev_tools/test_resolve_codex_deployment.py
- tests/scripts/dev_tools/test_generate_codex_agent_variants.py
- tests/scripts/dev_tools/test_codex_model_policy_config_parity.py
- .codex/agents/commit-steward.toml and its bundled alias
- root and bundled .codex/agents/commit-steward-{c1,c2,c3,c3-elevated,c4}.toml
- extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json

Final exact C3 profile SHA-256: 53EF0B396A7DFA96F631A096FB308F47712148C0BCF32CF6FAD1F84E5DF8FB22 (1010 bytes) in both root and bundle.
