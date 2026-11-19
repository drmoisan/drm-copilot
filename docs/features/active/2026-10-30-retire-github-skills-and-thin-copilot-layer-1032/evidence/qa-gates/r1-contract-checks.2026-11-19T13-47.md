# R1 Contract and Generator Checks ([P1-T3])

Plan: remediation-plan.2026-11-19T12-09.md
Timestamp: 2026-11-19T13-47
Command: sh SCRATCH/issue-1032-r1-manifests.sh; env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check; sh SCRATCH/issue-1032-gencheck.sh skills (runs scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface skills -Check with PowerShell 7); grep -F -c for RETIRED-PATH over every bundle's pack-manifests JSON
EXIT_CODE: 0
Output Summary: the five COPILOT-MANIFESTS parse as valid JSON (and the other 13 manifests); Codex generator check exit 0; harness generation check exit 0 printing `harness-generation: no drift`; zero RETIRED-PATH matches over the 18 manifests of the three bundles.

## JSON Parse of COPILOT-MANIFESTS

| Manifest | Parses | `paths` |
| --- | --- | --- |
| `customizations/pack-manifests/core.json` | valid | 81 |
| `customizations/pack-manifests/csharp.json` | valid | 6 |
| `customizations/pack-manifests/powershell.json` | valid | 6 |
| `customizations/pack-manifests/python.json` | valid | 8 |
| `customizations/pack-manifests/typescript.json` | valid | 4 |

## Generator Checks

| Check | EXIT_CODE | Output |
| --- | --- | --- |
| `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | 0 | no output (no drift) |
| `scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface skills -Check` | 0 | `harness-generation: no drift` |

## Manifest Search

`grep -F -c` for `RETIRED-PATH` over `extensions/drm-copilot/resources/claude-customizations/pack-manifests/*.json`, `codex-and-agents-customizations/pack-manifests/*.json` and `customizations/pack-manifests/*.json`: 0 matches (18 files).
