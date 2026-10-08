# epic-wave-barrier-layer2-not-run-at-subagentstop (Issue #840)

- Date captured: 2026-10-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-wave-barrier-layer2-not-run-at-subagentstop/ (Issue #840)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #840
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/840
- Last Updated: 2026-10-08
## Summary

Three runtime documents state that the epic wave-barrier Layer 2 check (the wave-barrier ordering invariant inside `validate_epic_orchestrator_state_text`) runs automatically at `epic-orchestrator` `SubagentStop` through `.claude/hooks/validate-orchestrator-output.ps1`. That hook performs only a structural check on the epic checkpoint (the file exists, parses as JSON, and has an object root). It does not call the Python or TypeScript semantic validator, so Layer 2 is not enforced at `SubagentStop`. Originating item: #659 (PR #807), follow-up 2.

## Environment

- OS/version: Windows 11 Pro 10.0.26200 (finding is platform-independent)
- Python version: not applicable (PowerShell `SubagentStop` hook); the semantic validator is `scripts/dev_tools/validate_epic_orchestrator_state.py`
- Command/flags used: the `epic-orchestrator` `SubagentStop` hook as registered in `.claude/agents/epic-orchestrator.md:25-29`: `pwsh -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1 -CheckpointPath artifacts/orchestration/epic-orchestrator-state.json -ArtifactType epic-orchestrator-state`
- Data source or fixture: main at fb413fce; `docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/other/follow-ups.md` section 2; `research/research.2026-09-30T01-25.md` section 3.5 in the same folder

## Steps to Reproduce

1. Write an epic checkpoint that is structurally valid JSON with an object root, in which a started dependent feature (for example `merge_status: "worktree_created"`) depends on a feature whose `merge_status` is `pr_open`.
2. Run the hook as registered: `validate-orchestrator-output.ps1 -CheckpointPath <that file> -ArtifactType epic-orchestrator-state`.
3. Run the semantic validator against the same file, for example the MCP `validate_orchestration_artifacts` tool with `epic-orchestrator-state`, and compare the results.

## Expected Behavior

Either the `SubagentStop` hook runs the Layer 2 wave-barrier ordering check, so the checkpoint in step 1 is rejected with `EPIC_WAVE_BARRIER_VIOLATION`, or the three documents state accurately that Layer 2 is enforced only where the semantic validator is called explicitly.

## Actual Behavior

Derived from code reading on main at fb413fce. The steps above were not executed for this entry.

- `.claude/hooks/validate-orchestrator-output.ps1:267-275`: the `switch` branch for `epic-orchestrator-state` and `parallel-orchestrator-state` calls `Test-OrchestratorCheckpointStructure` (defined at line 152) and returns its result. The function's own help text (lines 157-173) says that it checks only existence, JSON parse, and an object root, and that "the Python reference exposes no validation surface for `epic-orchestrator-state` ... under this hook's flag pair".
- The hook file contains no reference to `validate_epic_orchestrator_state` or to `validate_orchestration_artifacts` (`git grep` on main).
- The documents that claim `SubagentStop` enforcement:
  - `.claude/skills/epic-orchestrate/SKILL.md:244-246` (Layer 2 bullet): "enforced at `epic-orchestrator` `SubagentStop` time via the parameterized `validate-orchestrator-output.ps1` hook". The bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md:245` has the same text.
  - `.claude/agents/epic-orchestrator.md:126-127`: "retrospective wave-barrier ordering check inside `validate_epic_orchestrator_state_text`, invoked at your own `SubagentStop` time."
  - `.claude/hooks/enforce-epic-wave-barrier.ps1:26-29`: "the retrospective backstop (Layer 2) ... enforced separately at epic-orchestrator SubagentStop time."

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `validate-orchestrator-output.ps1:270` `$structural = Test-OrchestratorCheckpointStructure -CheckpointPath $Path`. The #659 code review (`code-review.2026-09-30T10-08.md`, Advisory, row 1) recorded this inaccurate enforcement claim and noted that #659 rewrote the Layer 2 bullet without correcting it.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

The Layer 1 per-call deterrent (`enforce-epic-wave-barrier.ps1`) still applies. However, the retrospective backstop that the skill and the agent describe, including the start guard added by #659, runs only when someone calls the semantic validator explicitly. An ordering violation that Layer 1 misses is therefore not caught at orchestrator termination, even though the documents say it is.

## Suspected Cause / Notes

- The hook's `epic-orchestrator-state` branch was defined as a structural check (PD-3) because, at the time, the Python CLI rejected the hook's flag pair. The skill, agent, and Layer 1 hook text were not updated to match.
- Related issues with different root causes: #787 (this hook reads its checkpoint relative to the session root) and #565 (Layer 1 hook resolves a nested artifact as the feature folder). #793 (the Python validator raises `TypeError` on a non-scalar `merge_status`) matters here: if the hook is changed to call the Python validator, a malformed checkpoint would cause a traceback rather than an error list until #793 is fixed.
- The skill digest is pinned in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (`PINNED_FROZEN_SURFACE_HASHES`). Any wording correction to `.claude/skills/epic-orchestrate/SKILL.md` requires a digest re-baseline.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: choose one of two options. (a) Wire the `epic-orchestrator-state` branch of `validate-orchestrator-output.ps1` to the semantic validator, using `validate_orchestration_artifacts.py epic-orchestrator-state` or the bash or TypeScript equivalent, and add Pester cases for a structurally valid checkpoint with a started dependent of an unmerged dependency (deny) and a kickoff checkpoint where all features are `not_started` (allow). (b) Correct the three documents and the bundled mirror so they state where Layer 2 actually runs, re-baseline the skill digest, and add a contract test that fails if the `SubagentStop` claim reappears without a matching hook invocation.
- [ ] Integration scenario to retest: an `epic-orchestrator` termination with the checkpoint from Steps to Reproduce.
- [ ] Manual verification notes: compare the hook verdict with the result of the MCP `validate_orchestration_artifacts` tool for the same checkpoint. Note that the repository's hook policy prefers bash or PowerShell for enforcement hooks rather than a Python leg.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
