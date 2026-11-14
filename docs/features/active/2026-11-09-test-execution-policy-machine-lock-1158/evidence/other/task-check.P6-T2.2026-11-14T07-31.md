# Task Check: P6-T2

Timestamp: 2026-11-14T07-31
Command: `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -q <selection>`; `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`; Pester `Run.Path` = the two ledger test files, `Run.Exit` = `$true`; sha256sum over the four `Invoke-PesterSuite.ps1` copies
EXIT_CODE: 0
Output Summary: pytest selection 67 passed, 0 failed (resource contracts, both pack-manifest completeness tests, dependency closure, skill-bundle contract, Codex migration inventory, rules frontmatter); generator `--check` exit 0; ledger debugging run 20 passed, 0 failed; the four `Invoke-PesterSuite.ps1` copies share one SHA-256 (prefix 6881717ae013f0a4).

## Changed Files

- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/test-execution-policy/scripts/{Invoke-TestSuite.ps1,Invoke-PesterSuite.ps1,run-test-suite.sh}` (bundle copies, new)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/test-execution-policy/scripts/{Invoke-TestSuite.ps1,Invoke-PesterSuite.ps1,run-test-suite.sh}` (bundle copies, new)
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (the skill and its three scripts, after `.claude/skills/skill-canonical-location-audit/SKILL.md`)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (the `.agents` skill and its three scripts, after `.agents/skills/review-discovery-coverage/SKILL.md`)

Ledger rule: the new manifest lines sit in the skills sections, outside the `0010` stored-patch hunks of both `core.json` files (which are in the hooks sections), so no record changes; the ledger tests pass unchanged. The bundled `.sh` copies are mode 100644, as are the 30 bundled `.sh` files already in `extensions/drm-copilot/resources/`.

## Selection and Rule

Rule: for changed configuration and bundle paths, the contract tests that read them (`## Test Cadence (Mandatory)`), plus the ledger tests for the ledger rule.

- pytest: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_skill_bundle_contract_repo.py`, `test_codex_full_migration_inventory.py`, `test_claude_rules_frontmatter.py`.
- Pester: `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`.

## Commands and Exit Codes

| Step | Command | EXIT_CODE |
|---|---|---|
| JSON validity | parse of both `core.json` files | 0 |
| contract tests | launcher `pytest` suite with the selection | 0 |
| generator | `generate_codex_agent_variants --check` | 0 |
| ledger | Pester, two ledger files | 0 |
| hash parity | sha256sum, four `Invoke-PesterSuite.ps1` copies | 0 (one hash) |
