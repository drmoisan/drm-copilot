# Final Full Regression Gate

Timestamp: `2026-08-11T17:44:24.8837222-04:00`

Plan task: `[P6-T17]`

EXIT_CODE: `0`

Output Summary: The final tree passed the full Python, TypeScript, PowerShell, and Bash regression suites in the required order. Current discovery confirms that existing epic, delivered Claude parallel, and publisher contract owners participated in those runs.

## Ordered full-suite results

| Order | Command | Result | Elapsed |
| ---: | --- | --- | ---: |
| 1 | `poetry run pytest -q` | exit `0`; `3,926` passed, `5` skipped, `0` failed | Pytest `7.19 s`; wall `8.577 s` |
| 2 | `npm --prefix extensions/drm-copilot run test:unit -- --runInBand` | exit `0`; `193/193` suites, `2,665/2,665` tests, `0` snapshots | Jest `6.598 s`; wall `7.309 s` |
| 3 | `mcp__drm-copilot__run_poshqc_test` at the exact workspace root | MCP `ok: true`; JUnit `2,294` total, `2,285` passed, `0` failed, `0` errors, `0` skipped, `9` disabled | JUnit `119.963 s` |
| 4 | supported Git Bash with `SHELL_QC_BATS_BIN=<cached Bats 1.13.0>/bin/bats bash scripts/bash/shell-qc.sh test` | exit `0`; TAP `1..250`; `250` passed, `0` failed, `0` skipped; silent-skip markers `0` | `250.780 s` |

The first Git Bash transport probe resolved neither repository nor Bats paths because of an invalid Windows-to-Git-Bash path conversion. It exited the acceptance wrapper with `1`, emitted `bats not installed; skipping shell tests`, and ran `0` tests. It was not accepted. The corrected `/c/...` invocation above discovered and passed all `250` cases. Its four Bats warnings are the intentional command-not-found negative assertions in `test_shell_qc_commands.bats`.

## Authoritative PowerShell receipt

- Receipt: `artifacts/pester/pester-junit.xml`.
- Timestamp: `2026-08-11T17:36:04.0379299-04:00`.
- SHA-256: `7C16E3CBF547BBFB7B98345B6836DD58D88736C8C095BBF4F62FBAAA3DA62014`.
- Result: `2,294` total, `2,285` passed, `0` failed, `0` errors, `0` skipped, `9` disabled.

## Epic contract discovery

Python discovery collected `163` epic nodes from these `13` owners, all included in the `3,926` passing result except only the five separately documented manifest-accessor skips:

- `test_epic_kickoff_contract.py`
- `test_epic_planner_git_integrity.py`
- `test_epic_planner_launch_evidence.py`
- `test_epic_planner_readiness.py`
- `test_epic_planner_readiness_filesystem.py`
- `test_epic_run_kickoff_discovery_contract.py`
- `test_epic_wave_computation.py`
- `test_validate_epic_orchestrator_state.py`
- `test_validate_epic_orchestrator_state_codex_routing.py`
- `test_validate_epic_orchestrator_state_codex_topology.py`
- `test_validate_epic_orchestrator_state_launch_binding.py`
- `test_validate_epic_planner_state.py`
- `test_validate_epic_planner_state_launch_binding.py`

TypeScript discovery included these `14` epic owners in the green `193/193` suite result: `epic-kickoff-artifact`, `epic-orchestrator-state-codex-model-routing`, `epic-orchestrator-state-codex-topology`, `epic-orchestrator-state-core`, `epic-orchestrator-state-launch-binding`, `epic-planner-git-integrity`, `epic-planner-launch-evidence`, `epic-planner-readiness-integrity`, `epic-planner-state-core`, `epic-planner-state-launch-binding`, `epic-wave-computation`, `mcp-epic-validation-definitions`, `mcp-server-epic-validation`, and `mcp-tool-inputs-epic-validation`.

PowerShell discovery executed `254` cases across these `12` epic owners:

- `enforce-epic-invocation-origin` (`27`), `enforce-epic-merge-gate` (`30`), `enforce-epic-wave-barrier` (`24`), and `enforce-epic-worktree-removal-gate` (`22`).
- `enforce-pr-author-skill.epic-base-branch` (`9`) and `codex-epic-runtime-contracts` (`10`).
- `epic-child-launch-attestation` (`12`), `epic-child-launch-hardening` (`19`), and `epic-child-worktree-launcher` (`22`).
- `epic-execution-gates` (`40`), `epic-provenance` (`29`), and `epic-wave-launch-binding` (`10`).

## Delivered parallel contract discovery

Python discovery collected `1,423` parallel nodes from `48` owners. The owners cover cohort/barrier parity and computation, manifest parity and contracts, mutation admission/recoloring/receipt/runtime properties, semantic drift detection/halt/resolution, kickoff and surface contracts, completion receipts, resume truth, Codex readiness, and public planner/orchestrator validation.

TypeScript discovery included `21` parallel owners: orchestration-artifact dispatch; Codex readiness and filesystem binding; cohort-barrier, mutation, and drift parity; kickoff artifact/tables/template; orchestrator core, structures, completion, completion receipts, mutation receipts, receipt cohort, resume truth, and cohort barrier; planner core; and the MCP definition/server/input owners.

PowerShell discovery executed `242` cases across these `12` parallel owners:

- Admission/runtime owners: `enforce-parallel-abandon-gate` (`22`), `enforce-parallel-cohort-barrier` (`56`), `enforce-parallel-drift-gate-helpers` (`26`), `enforce-parallel-drift-gate` (`42`), and `enforce-parallel-worktree-removal-gate` (`40`).
- Native transport and lifecycle owners: `codex-parallel-registered-transport` (`5`), `parallel-child-post-session` (`7`), `parallel-child-resume-live-truth` (`7`), `parallel-child-worktree-launcher` (`8`), `parallel-completion-compensating-controls` (`8`), `parallel-provenance` (`17`), and `parallel-runtime-lifecycle` (`4`).

Bats discovery executed `147` parallel cases across `9` owners: `parallel_bash_manifest_membership` (`9`), `parallel_cohorts_parity` (`3`), `parallel_cohorts` (`31`), `parallel_common` (`24`), `parallel_items_validate` (`22`), `parallel_manifest_parity` (`3`), `parallel_manifest_validate` (`20`), `parallel_payload_only` (`12`), and `parallel_yaml_subset` (`23`).

## Publisher contract discovery

Python discovery collected `124` publisher nodes from `16` owners:

- Claude: `test_push_down_claude_customizations`, `test_push_down_claude_memory_scope`, `test_push_down_claude_pack_end_to_end`, `test_push_down_claude_pack_manifest_completeness`, `test_push_down_claude_pack_memory_modes`, `test_push_down_claude_pack_selection`, and `test_push_down_claude_resource_contracts`.
- Codex: `test_push_down_codex_and_agents_customizations`, `test_push_down_codex_and_agents_pack_manifest_completeness`, `test_push_down_codex_and_agents_resource_contracts`, `test_push_down_codex_pack_selection`, `test_push_down_codex_portable_assets`, and `test_push_down_codex_routing_merge`.
- Copilot: `test_push_down_copilot_customizations`, `test_push_down_copilot_customizations_helpers`, and `test_push_down_copilot_customizations_rewrites`.

TypeScript discovery included `20` publisher owners: the extension Claude push-down owner; Claude config, customization, filesystem, manifest, name-translation, and selection owners; Codex customization, selection, portable-assets, and routing-merge owners; Copilot engine/customization owners; filesystem, service-call, and reference-rewrite owners; and the MCP handler/tool/service Claude and Codex owners.

PowerShell compatibility discovery included `codex-epic-runtime-contracts` (`10` cases) and `legacy-codex-hook-contracts` (`42` cases), preserving root/bundle and legacy registration contracts used by publisher output.

## Terminal integrity and cleanup

- Current Pytest discovery: `3,931` nodes, exactly matching `3,926` passed plus `5` documented skips.
- `.codex/state`: absent; no ephemeral batch receipt remains.
- Canonical QA directories are limited to the established Bash kcov and TypeScript coverage outputs; no P6-T17 transient directory exists.
- `testResults.xml` SHA-256: `02628E73BB8A090824E5E97ADEB385AF1068AD905E7DA636A40AB64FD5F0E96A`; baseline match `true`; Git status and diff counts `0`.
- `.claude/`: baseline/current `150/150`; mismatches `0`; Git status `0`; Git diff `0`.
- `git diff --check`: exit `0`, output lines `0`.

`P6_T17_STATUS: COMPLETE`
