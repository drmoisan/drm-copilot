# Scope Confirmation — [P0-T2]

Timestamp: 2026-08-24T22-20

Issue: #524
Work Mode: full-bug
Task: [P0-T2]

## Sources Read

1. `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/spec.md` — requirements source, section `## Acceptance Criteria` (16 criteria).
2. `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/research/2026-08-23T23-45-epic-launch-binding-gate-research.md` — research artifact.
3. `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/issue.md` — defect report.

`user-story.md` is intentionally absent for this bug and must not be created. Confirmed absent by directory listing of the feature folder.

## Confirmed Defect and Correction

`scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` admits the generic `require_complete` flag into an otherwise Codex-specific activation set, which made Codex-only launch evidence a universal completion requirement. The evidence has exactly one production writer, `.codex/scripts/launch-epic-child-wave.ps1`, on the Codex runtime; the Claude runtime never writes it, so the gate cannot pass there.

The decided correction:

1. Under `require_complete` alone, validate a feature's launch binding only when that feature carries `launch_receipt_path` or `launch_status_path`. Presence is key membership, so a key present with an empty or null value still arms the gate.
2. Under `require_codex_model_routing` or `require_codex_topology`, the gate stays unconditional and byte-identical to today, including the existing `skip_not_started` filter.
3. A partial binding — one launch path key present, the other missing — must still fail under `require_complete` alone. Implemented deliberately as "either key", never "both keys", and tested in both runtimes.
4. No error string is added, removed, or reworded. Python and TypeScript error strings stay byte-identical to each other.

## The Six Enumerated Production and Test File Paths

Production (4):

1. `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`
2. `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts`
3. `.claude/rules/orchestrator-state.md`
4. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`

Tests (2):

5. `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py`
6. `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-launch-binding.test.ts`

Production files 3 and 4 are one logical change recorded twice under the byte-identical mirror relation enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. Both receive the identical edit in the same task ([P3-T5]).

## Authorization For The `.claude/rules/` Edit

The amendment of `.claude/rules/orchestrator-state.md` is a deliberate, authorized exception to the baseline constraint in `.claude/skills/policy-compliance-order/SKILL.md` against modifying policy documents under `.claude/rules/`. The authorization rests on three facts:

- That file is the repository's declared enforcement specification for the very validator being corrected.
- Issue #524 names it explicitly among the files that must change (`issue.md`, section `## Suspected Cause / Notes`: "the epic-orchestrator agent, the orchestrator-state validators under `.claude/lib/orchestrator-state/`, `.claude/hooks/validate-orchestrator-output.ps1`, and `.claude/rules/orchestrator-state.md` are all push-down destinations"), and `spec.md` lists it under Scope, in scope.
- Leaving it unamended would make its prose false about the gate's activation scope.

No other file under `.claude/rules/` may be modified by this diff.

## Excluded Paths (Out Of Scope)

- **The epic planner surface.** `scripts/dev_tools/validate_epic_planner_state.py` calls `validate_epic_planner_child_launch_bindings` unconditionally inside its `require_ready_for_execution` block and carries a structurally identical defect. It is latent: no Claude skill or agent passes `require_ready_for_execution`, so no symptom reproduces. It must NOT be fixed in this diff. A separate GitHub issue is filed for it in [P5-T4] and its number recorded in [P5-T5].
- `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` — unmodified for the same reason.
- `.claude/lib/orchestrator-state/` — implements no part of this gate (verified zero matches for the launch-binding identifiers across the whole `.claude/` tree).
- `.claude/hooks/validate-orchestrator-output.ps1` — performs a structural check only for the epic artifact type and never passes `require_complete`.
- `.codex/**` and `.agents/**` — the Codex runtime keeps the gate unchanged because it passes both Codex flags.
- `extensions/drm-copilot/jest.config.cjs` — no per-file coverage-threshold entry is added; post-change TypeScript coverage for the changed module is read from the `text` coverage reporter instead.
- MCP tool definitions and `scripts/dev_tools/validate_orchestration_artifacts.py` — the epic subparser already carries and dispatches all three flags.
- **PowerShell / Pester.** There is no Pester coverage of this gate, so the PowerShell toolchain is not part of this plan's QA loop. Languages in scope are Python and TypeScript only.

## Delegation Scope For This Execution Pass

This delegation executes plan tasks [P0-T1] through [P2-T4] only. Phase 3 is not begun. No production source file is modified in this pass: Phase 0 is read and baseline only, Phase 1 writes JSON fixtures under this feature folder's evidence tree only, and Phase 2 adds two new tests to two existing test files.

## Evidence Location

All evidence resolves under
`docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/<kind>/`.
No `artifacts/`-rooted evidence path was supplied or used.
