# Follow-ups Recorded by Issue #659

Timestamp: 2026-09-30T10-50

Plan task: [P1-T16]

Both entries are out of scope for this minor-audit change (plan section 1, "Out of scope"). Line numbers below were re-read against the working tree after [P1-T8]; the planning-time numbers are given in parentheses where they differ.

## 1. Unhashable `merge_status` raises `TypeError` in the Python validator

Title: Python epic validator crashes on a list- or object-valued `merge_status` in the enum and completion checks

Evidence:
- `scripts/dev_tools/validate_epic_orchestrator_state.py` line 238 (planning time 235), in `_validate_merge_status_enum` (line 218): `if merge_status is not None and merge_status not in VALID_MERGE_STATUS:`. Set membership on a `list` or `dict` value raises `TypeError: unhashable type`.
- `scripts/dev_tools/validate_epic_orchestrator_state.py` line 321 (planning time 385), in `_validate_completion` (line 298): `if feature.get("merge_status") not in MERGED_STATUSES:`. Same failure mode under `require_complete`.
- TypeScript counterpart `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts`, `validateMergeStatusEnum` and `validateCompletion`, check `typeof mergeStatus === "string"` before set membership and report an error instead.
- Research reference: `research/research.2026-09-30T01-25.md` section 1.3 P2.
- This change fixed only the wave-barrier path: `validate_wave_barrier_ordering` in `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py` checks `isinstance(dep_merge_status, str)` first (tested by `test_validate_wave_barrier_ordering_reports_unhashable_dependency_status`). Through the public entry point, `validate_epic_orchestrator_state_text` still raises from `_validate_merge_status_enum` before the barrier check runs.

Impact: A malformed checkpoint with a list or object `merge_status` makes the Python validator raise instead of returning an error list, while the TypeScript (MCP) validator returns an `invalid merge_status` error. The two runtimes diverge on this input.

Disposition: not filed; recorded for a later potential entry

## 2. Layer 2 documentation says the check runs at `SubagentStop`, but the hook performs only a structural check

Title: Epic wave-barrier Layer 2 is documented as enforced at `SubagentStop`, but the `SubagentStop` hook path does not run `validate_epic_orchestrator_state_text`

Evidence:
- `.claude/skills/epic-orchestrate/SKILL.md` line 244 (Layer 2 bullet, unchanged sentence kept by [P1-T13]): "enforced at `epic-orchestrator` `SubagentStop` time via the parameterized `validate-orchestrator-output.ps1` hook". The bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` carries the same sentence.
- `.claude/agents/epic-orchestrator.md` lines 126-127: "retrospective wave-barrier ordering check inside `validate_epic_orchestrator_state_text`, invoked at your own `SubagentStop` time."
- `.claude/hooks/enforce-epic-wave-barrier.ps1` lines 26-29: "the retrospective backstop (Layer 2) is the wave-barrier ordering invariant inside validate_epic_orchestrator_state_text, enforced separately at epic-orchestrator SubagentStop time."
- `.claude/hooks/validate-orchestrator-output.ps1` line 218 (help text listing `epic-orchestrator-state` among the structural-check types) and line 267 (the `switch` branch for `epic-orchestrator-state` / `parallel-orchestrator-state`), which calls `Test-OrchestratorCheckpointStructure` (defined at line 152) at line 270. That function checks existence, JSON parse, and structure only; it does not invoke the Python or TypeScript semantic validator.
- Research reference: `research/research.2026-09-30T01-25.md` section 3.5.

Impact: The Layer 2 wave-barrier invariant, including the start guard added by this change, is enforced only where `validate_epic_orchestrator_state_text` or the MCP `validate_orchestration_artifacts` tool is called explicitly. Three documents state that it is enforced automatically at `SubagentStop`, which is not the case on the current hook path.

Disposition: not filed; recorded for a later potential entry
