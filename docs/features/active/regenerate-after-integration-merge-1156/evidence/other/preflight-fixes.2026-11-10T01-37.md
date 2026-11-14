# Preflight Fixes

Timestamp: 2026-11-10T01-37
Plan: docs/features/active/regenerate-after-integration-merge-1156/plan.2026-11-09T16-31.md
Branch: feature/regenerate-after-integration-merge-1156-r6
Issue: #1156

Earlier preflight-fixes files in this folder are unchanged; this record is append-only.

## Fixes

1. [P5-T1] | existing-test disposition omission (disposition unchanged) | Searching `tests/` for `pack-manifests` found eleven readers of the two `core.json` files that the task did not name. Each one checks membership of its own entries, scores additions as append-only, or uses an in-memory manifest fixture, so adding entries does not affect it. The task now names `tests/shell/parallel_bash_manifest_membership.bats`, `EpicProgressReport.SkillContract.Tests.ps1`, `test_push_down_codex_and_agents_customizations.py`, `test_discovery_publication_contracts.py`, `test_blast_radius_config_tolerance_keys.py`, `epic-child-launch-hardening.Tests.ps1`, `docs-authoring-roles.Mirrors.Tests.ps1`, `test_push_down_claude_gitignore_delivery.py`, `test_push_down_claude_exclusion_filter.py`, and `test_push_down_claude_config_carriage.py` as unchanged, each with its reason.
2. [P6-T1] | validator-blind class (PoshQC MCP results carry no output), meaning kept | The acceptance "format reports no changed file" now names how it is observed: the direct formatter-output comparison of [P0-T1], or an unchanged `git status --porcelain` before and after the format step.
3. [P6-T7] | literal scope clarification, meaning kept | The 800-line check now names its file set as the extension allowlist of `Test-FileSizeCoveredPath` in `.claude/lib/file-size-policy/FileSizePolicy.psm1` (py, ps1, psm1, ts, tsx, js, cjs, mjs, cs, sh, bats), which the repository gate enforces. It also states that the `.psd1` data file `RegenerationResultTable.psd1` is outside that set, so its 74 rows cannot make the comparison remediation-required.
