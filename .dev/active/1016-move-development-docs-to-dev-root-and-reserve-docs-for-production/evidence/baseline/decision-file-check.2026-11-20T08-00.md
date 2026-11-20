# Decision File Check ([P0-T2])

Timestamp: 2026-11-20T08-00
Command: sh SCRATCH/issue-1016-p0t2.sh (pwsh -NoProfile -File SCRATCH/issue-1016-p0t2.ps1: ConvertFrom-Json of the decision file and of its named dry-run report; ordinal comparison of the twelve global_decisions with DECIDED_VALUES; HELD_RULE applied to the report's held_items and compared with decisions)
EXIT_CODE: 0
Output Summary: selected file `folder-rename-decisions.2026-11-20T07-55.json`; every key PASS; 45 held items (33 non-matching, 12 multi-folder-issue), 45 decisions, 0 mismatches, 0 extra decisions. No halt condition (commit_split single, remove_fallback no, extension_command no).

| Key | Expected | Observed | Result |
| --- | --- | --- | --- |
| `version` | 1 | 1 | PASS |
| `dry_run_report` names an existing stage A JSON | `dev-docs-migration-dry-run.2026-11-20T07-40.json` exists | exists | PASS |
| `source_digest` present | present | `2f33c96522d776b174bff9370652a8a676c6d03dedc2758570e7f6e87b936a75` (equals the report's) | PASS |
| `discovery_templates_target` | `.dev/discovery/templates` | same | PASS |
| `in_tree_rewrite_scope` | `links-only` | same | PASS |
| `commit_split` | `single` | same | PASS |
| `absent_key_resolves` | `docs/features` | same | PASS |
| `discovery_runtime_resource_key` | `keep` | same | PASS |
| `rules_mirrors_editable` | `no` | same | PASS |
| `remove_fallback` | `no` | same | PASS |
| `run_source` | `branch-build` | same | PASS |
| `allow_list_tool` | `none` | same | PASS |
| `extension_command` | `no` | same | PASS |
| `file_size_excluded_segment` | `no` | same | PASS |
| `plan_template_link_depth` | `three-level` | same | PASS |
| `decisions` equal HELD_RULE over held items | 33 rename to candidate, 12 keep | 33 rename to candidate, 12 keep | PASS |

- Held-item count: 45. Mismatches: 0.
