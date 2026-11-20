# Phase 0 Upstream Check: Child 4 (#1029) and Child 5 (#1030) ([P0-T5])

Timestamp: 2026-11-19T07-51
Plan: plan.2026-10-30T18-39.md
Command: grep for COPILOT_ROOT_FOLDERS in extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts and ROOT_FOLDERS in scripts/dev_tools/agentic_sync.py; ls extensions/drm-copilot/resources/customizations/pack-manifests; grep over the #1029 spec.md and plan.2026-10-30T18-37.md, the #1030 spec.md, and .claude/lib/discovery-validation/DiscoveryStartRecord.psm1
EXIT_CODE: 0
Output Summary: RootConstants present for both constants; CopilotManifests: absent; child 4 (#1029) not merged (coordinator decision under OD-4: record-only); DestinationCleanupOwner: unassigned; R3 open; UA-C5 holds. No `blocked: premise_falsified`.

## Child 4 (#1029) — record only

Coordinator decision under OD-4 (cost-benefit rule): UA-C4a, UA-C4b and UA-C4c are record-only. #1029 runs in parallel and is not merged into `epic/shared-agent-harness-layer-integration`; this run records that state and continues.

| ID | Value |
| --- | --- |
| UA-C4a | RootConstants: `COPILOT_ROOT_FOLDERS` present (holds `.github/skills`); `agentic_sync.ROOT_FOLDERS` present (holds `Path(".github/skills")`). P1-T7 applies. |
| UA-C4b | CopilotManifests: absent (`extensions/drm-copilot/resources/customizations/pack-manifests/` does not exist). Child 4 merge state: not merged; its edits to `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts` and its brief bullet are absent from this branch (merge-order dependency R10: whichever merges second rebases over the other). |
| UA-C4c | DestinationCleanupOwner: unassigned; R3 open. Reference: #1029 `spec.md` Behavior item 11 (`Orphans`) reports manifest entries of a retired file as `orphaned` and deletes nothing (O-7); `plan.2026-10-30T18-37.md` decision D3 restates the report-only rule. Neither assigns deletion of previously pushed `.github/skills` copies in destinations. |

## Child 5 (#1030, merged by PR #1207)

| ID | Result | Observation |
| --- | --- | --- |
| UA-C5 | holds | #1030 `spec.md` records `.github/hooks/*.json` registrations as `hook-registration` entries with `disposition: native` and `owner_child: 6` (acceptance criteria checked off). `Get-DiscoveryAgentProfilePath` in `.claude/lib/discovery-validation/DiscoveryStartRecord.psm1` still maps `github-copilot` to directory `.github/agents` with suffix `.agent.md`, so it resolves `.github/agents/<role>.agent.md`. |

The `.github/prompts`, `.github/hooks` and `COPILOT-AGENT-FILES` inventories with one `git hash-object` value per file are in `github-native-inventory.2026-11-19T07-51.md`.
