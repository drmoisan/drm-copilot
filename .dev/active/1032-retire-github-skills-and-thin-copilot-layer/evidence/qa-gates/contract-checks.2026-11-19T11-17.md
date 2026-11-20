# Contract Checks ([P2-T1])

Timestamp: 2026-11-19T11-17
Plan: plan.2026-10-30T18-39.md
Command: sh SCRATCH/issue-1032-contract.sh (env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check; pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface skills -Check; grep -c -F RETIRED-PATH over every extensions/drm-copilot/resources/*/pack-manifests/*.json)
EXIT_CODE: 0
Output Summary: Codex generator check exit 0; child 3's skill-mirror check exit 0 (`harness-generation: no drift`); 12 pack manifests searched, 0 matches for RETIRED-PATH.

| Check | EXIT_CODE | Result |
| --- | --- | --- |
| Codex generator `--check` | 0 | no drift reported |
| Child 3 generator `-Surface skills -Check` | 0 | harness-generation: no drift |
| RETIRED-PATH search over the 12 `pack-manifests/*.json` files (`claude-customizations` and `codex-and-agents-customizations`; the Copilot bundle has no `pack-manifests` folder) | 0 | 0 matches |
