# Corrected #840 Passages (P5-T1, P5-T2, P5-T6)

Timestamp: 2026-10-08T22-36

Each passage now names `OrchestratorStateEpicWaveBarrier.psm1` and the potential-entry file `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md`. Each bundled mirror is byte-identical (P5-T5). The per-literal `git grep -c -F` counts were 1 for each of `OrchestratorStateEpicWaveBarrier.psm1`, `tests/fixtures/epic_wave_barrier/`, and `subagentstop-validators-read-undocumented-envelope` in SKILL and in AGENT. The same search at INTEGRATION_SHA 497cb504 for `OrchestratorStateEpicWaveBarrier.psm1` over SKILL, AGENT, and WAVE printed nothing (absent before the edit). SKILL bullet line widths were measured at most 100 characters.

## SKILL: `.claude/skills/epic-orchestrate/SKILL.md` lines 244-263

```text
- **Layer 2 — retrospective backstop:** the wave-barrier ordering invariant of
  `validate_epic_orchestrator_state_text`, enforced at `epic-orchestrator` `SubagentStop` time by a
  PowerShell port, `Get-OrchestratorStateEpicWaveBarrierError` in
  `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`, which the parameterized
  `validate-orchestrator-output.ps1` hook invokes for `epic-orchestrator-state` after resolving the
  epic checkpoint through `WorktreeRunResolution.psm1`. The hook starts no Python process. Parity
  with `validate_epic_orchestrator_state_text` is pinned by the shared fixtures under
  `tests/fixtures/epic_wave_barrier/`, and the Python validator remains the authority used through
  the `mcp__drm-copilot__validate_orchestration_artifacts` call. It checks only a dependent feature
  that is treated as started: one with a string `worktree_created_at`, or with a `merge_status`
  other than `not_started` (a missing or non-string `merge_status` counts as started). It appends
  exactly one error per violated dependency edge. When the dependency's `merge_status` is not
  `merged` or `worktree_removed`, the error is
  `EPIC_WAVE_BARRIER_VIOLATION: <f> is treated as started while dependency <d> is not merged`.
  Otherwise, when the dependency's `merge_confirmed_at` is later than the dependent's
  `worktree_created_at`, the error is
  `EPIC_WAVE_BARRIER_VIOLATION: <f> worktree_created_at precedes dependency <d> merge_confirmed_at`.
  A violation blocks with an instruction to report it to the operator and halt. The hook's runtime
  effect is likely to depend on the `SubagentStop` transport and exit-code defect recorded in
  `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md`.
```

## AGENT: `.claude/agents/epic-orchestrator.md` lines 123-135 (the sentences begin mid-line 123)

```text
Do not launch wave N+1 until every wave-N
feature's dependency edges are durably confirmed `merged` or `worktree_removed`. This durable
confirmation is enforced both by the `enforce-epic-wave-barrier.ps1` per-call deterrent and by the
retrospective wave-barrier ordering check, which runs at your own `SubagentStop` time as
`Get-OrchestratorStateEpicWaveBarrierError` in
`.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`, a PowerShell port of the
check inside `validate_epic_orchestrator_state_text` invoked by
`.claude/hooks/validate-orchestrator-output.ps1`; parity is pinned by
`tests/fixtures/epic_wave_barrier/`, and the Python validator remains the authority used through
the `mcp__drm-copilot__validate_orchestration_artifacts` call. If the check reports a violation,
report it to the operator and halt. Its runtime effect is likely to depend on the `SubagentStop`
transport and exit-code defect recorded in
`docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md`.
```

## WAVE: `.claude/hooks/enforce-epic-wave-barrier.ps1` lines 29-36 (comment help)

```text
    This is the per-call deterrent (Layer 1) of the two-layer wave-barrier design. The
    retrospective backstop (Layer 2) is the wave-barrier ordering invariant of
    validate_epic_orchestrator_state_text, run at epic-orchestrator SubagentStop time by
    validate-orchestrator-output.ps1 through its PowerShell port
    OrchestratorStateEpicWaveBarrier.psm1, with parity pinned by tests/fixtures/epic_wave_barrier/.
    That hook's runtime effect is likely to depend on the SubagentStop transport defect recorded in
    docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md.
    The two layers share no code.
```

Result: PASS (three quotations; each contains `OrchestratorStateEpicWaveBarrier.psm1` and the potential-entry file name).
