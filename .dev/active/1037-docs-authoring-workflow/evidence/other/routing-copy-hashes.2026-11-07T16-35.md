# Routing Copy Hashes (P5-T4, P5-T5)

Timestamp: 2026-11-07T16-35
Command: sh SCRATCH/issue-1037-routing.sh (`cp config/orchestration-routing.json` to `extensions/drm-copilot/resources/config/orchestration-routing.json` and to `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json`; `git hash-object` and a CR count of each copy; a top-level key comparison of each copy against `git show BASE:config/orchestration-routing.json`, BASE = merge base of `origin/epic/documentation-estate-tooling-integration` and `HEAD`)
EXIT_CODE: 0
Output Summary: Three equal blob hashes; each copy parses as JSON, contains 0 CR bytes, adds only the top-level key `docs_operations`, and shows no difference in any pre-existing top-level key (`version`, `routes`, `model_policy`, `model_budget`, `codex_topology_policy`, `discovery_operations`, `codex_model_policy`).

| File | git blob hash | CR bytes | Changed pre-existing keys | Added keys |
|---|---|---|---|---|
| `config/orchestration-routing.json` | `51762637424f64f6297672da54de965dc44e64fc` | 0 | none | `docs_operations` |
| `extensions/drm-copilot/resources/config/orchestration-routing.json` | `51762637424f64f6297672da54de965dc44e64fc` | 0 | none | `docs_operations` |
| `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` | `51762637424f64f6297672da54de965dc44e64fc` | 0 | none | `docs_operations` |

Equal blob hashes imply equal bytes, so the [P5-T4] SHA-256 equality of the source and the `resources/config/` copy also holds. Both bundle copies were made by a copy step, not a Write or Edit call.
