# Phase 0 — Policy Instructions Read (Issue #412)

Timestamp: 2026-07-25T17-17

Task: [P0-T1]

Policy Order: The reading order defined by `.claude/skills/policy-compliance-order/SKILL.md`, as enumerated in plan task [P0-T1]:
1. `CLAUDE.md` (standing instructions)
2. `.claude/rules/general-code-change.md` (cross-language code change policy)
3. `.claude/rules/general-unit-test.md` (cross-language unit test policy)
4. Language- and domain-specific rules for the files in scope (Python, PowerShell, TypeScript), plus the two domain rules named by the plan task.

## Files Read (explicit list, in order)

All paths are relative to the workspace root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585`.

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`
6. `.claude/rules/powershell.md`
7. `.claude/rules/typescript.md`
8. `.claude/rules/typescript-suppressions.md`
9. `.claude/rules/orchestrator-state.md`
10. `.claude/rules/quality-tiers.md`

Every file listed in plan task [P0-T1] was read in full from the workspace root above using the Read tool. No policy file was modified.

## Constraints Carried Forward Into Execution

- 500-line hard limit on any production, test, or reusable script file (`general-code-change.md`). Relevant to [P1-T5] (`validate_orchestrator_state.py` currently at the limit) and [P3-T3] (`OrchestratorState.psm1` at 485 lines).
- Coverage thresholds are uniform across T1–T4: line >= 85%, branch >= 75% (`quality-tiers.md`, `general-unit-test.md`).
- Toolchain order: format -> lint -> type-check (Python/TypeScript only; not applicable to PowerShell) -> test. Restart from the format step if any stage fails or changes files (`python.md`, `powershell.md`, `typescript.md`).
- No temporary files in tests; in-memory fixtures only (`general-unit-test.md`).
- Test files live under `tests/` mirroring the production tree; colocation prohibited (`general-unit-test.md`).
- PowerShell per-batch cap: at most 3 production and 3 test files; direct-mode overall scope at most 2 production files (`powershell.md`). Plan Hard Constraint 10 tightens this to the config value of 2 production files per batch.
- Suppressions require a pre-authorized pattern or explicit user approval (`python-suppressions.md`, `typescript-suppressions.md`).
- `.claude/rules/orchestrator-state.md` is the authoritative documentation side for both divergences under repair and MUST NOT be modified (plan Hard Constraint 2).
- Divergence 2 reference points recorded from `orchestrator-state.md`: each `complexity_assessments[]` entry's `floor` must equal `compute_complexity_floor(signals_present)`; C4 is never floor-forced and the floor never exceeds `C3`.

## Note on Rule File Path Resolution

The auto-loaded standing-instruction context in this session referenced rule files under
`C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T09-52/`. To avoid relying on a path
that may not resolve to this worktree, every file above was read explicitly from the
workspace root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585`.
The `CLAUDE.md` contents matched between the two sources.
