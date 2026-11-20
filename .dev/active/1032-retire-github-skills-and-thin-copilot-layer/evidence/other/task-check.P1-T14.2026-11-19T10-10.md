# Task Check P1-T14

Timestamp: 2026-11-19T10-10
Plan: plan.2026-10-30T18-39.md
Changed files: `.agents/README.md` (the historical-source sentence now states that issue #1032 retired the Copilot skill copies, that `.agents/skills` is the shared skill source Copilot reads natively, and that `.github/agents` stays the Copilot-native agent source) and its bundle copy under `codex-and-agents-customizations/` (`cmp` identical); `README.md` `## Policy and skills references` (the skills link names `.agents/skills/README.md`; the tone-and-policy line, a related current-fact correction, names `AGENTS.md` and marks `.github/copilot-instructions.md` as Copilot-only); `docs/engineering/legacy-discovery-and-parity/maintainer-guide.md` (the canonical skill row names `.agents/skills/<name>/SKILL.md` with child 3's generator and substitution lists; the Copilot bundle row lists the four remaining scoped roots); `workflow.md` (`.agents/skills/<name>/SKILL.md` mirrored by child 3's generator); `consumer-onboarding.md` (the retired root dropped from the Copilot push-down list). Child 3 had made none of these edits.
Selection rule: tests that read these documents (found by searching `tests/` for the file names and section text): `test_discovery_documentation_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py` (bundle equality of `.agents/README.md`), `test_push_down_codex_and_agents_customizations.py`, `test_quality_tiers_contract.py`, `test_discovery_publication_contracts.py`, `HarnessInventory.Tests.ps1`, `HarnessGeneration.Tests.ps1`, `policy-toolchain-naming.Tests.ps1`.

| Command | EXIT_CODE | Result |
| --- | --- | --- |
| `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` over the 5 modules | 0 | 127 passed |
| `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath` `HarnessInventory`, `HarnessGeneration`, `policy-toolchain-naming` | 0 | Invoke-PoshQCParallelTest exit code 0 (workers 3, 128.38s) |
| Grep for RETIRED-PATH over the five documents and the bundle copy | 0 | 0 matches |
