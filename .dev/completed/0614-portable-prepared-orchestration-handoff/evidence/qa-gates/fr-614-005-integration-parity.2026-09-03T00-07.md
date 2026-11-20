# Integration and Parity — P3-T15

Timestamp: 2026-09-06T00-00
Task: [P3-T15]
Working directory: repository root

## Gitignored runtime-state precondition

`.claude/state/` is gitignored at `.gitignore:68` and is not repository
content. The regenerated runtime session file was removed immediately before
the test command. A failure caused by that gitignored runtime state is an
environmental precondition and does not trigger a P3-T1 restart; none occurred
on this run.

Command: `git status --porcelain=v1 --untracked-files=all -- .claude` (before)
EXIT_CODE: 0
```
 M .claude/skills/orchestrate/SKILL.md
```

## Integration and parity suite

Command: `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py tests/scripts/dev_tools/test_orchestration_handoff_adapters.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_validate_epic_planner_state.py`
EXIT_CODE: 0

```
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py .... [ 60%]
..........                                                               [ 66%]
tests\scripts\dev_tools\test_parallel_orchestrator_surface_contracts.py . [ 66%]
...................................                                      [ 87%]
tests\scripts\dev_tools\test_validate_epic_planner_state.py ............ [ 94%]
.........                                                                [100%]

============================= 169 passed in 0.86s =============================
```

Passed: 169
Failed: 0
Skipped: 0

The 167-case baseline recorded in
`evidence/remediation-baseline/integration-parity.2026-09-03T00-07.md` passes
in full, plus the two new consumer-contract cases added by P1-T4
(`test_codex_guidance_requires_independent_expected_context` and
`test_claude_orchestrate_requires_independent_expected_context`).

Command: `git status --porcelain=v1 --untracked-files=all -- .claude` (after)
EXIT_CODE: 0
```
 M .claude/skills/orchestrate/SKILL.md
```

## Boundary observations

The before and after `.claude` porcelain observations are identical to each
other, so the test run changed no tracked path under `.claude`. The only path
either observation lists is `.claude/skills/orchestrate/SKILL.md`, the published
orchestrate skill that P2-T6 is authorized to change.

Source, bundled, core-pack, variant-pack, and installed-consumer parity is
exact: the parity assertions in
`test_push_down_codex_and_agents_customizations.py` and
`test_push_down_claude_resource_contracts.py` compare normalized source and
bundled content for all three published skills and pass. All three consumer
tools fail closed without the independent expected context, asserted by the two
new cases through `assert_independent_context_guidance`. FR-614-001 containment
remains green in `test_orchestration_handoff_taskmaster_469.py` and
`test_orchestration_handoff_adapters.py`. Issue #467 scheduling ownership and
issue #543 epic-ready behavior remain unchanged, asserted by
`test_parallel_orchestrator_surface_contracts.py` and
`test_validate_epic_planner_state.py`.

## Fixture hydration

Command: `git diff --quiet 8defb1df335efc47063a5f5394faa539e9513bfe -- tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md`
EXIT_CODE: 0

Command: `pwsh -NoProfile -Command 'Get-FileHash -Algorithm SHA256 ...'`
EXIT_CODE: 0
```
54C9718097DE0A151947CA2E639856E67FE1B7ABFBF9EDC75ADAC80EA3C9BA2F  plan.2026-08-29T12-22.md
54C9718097DE0A151947CA2E639856E67FE1B7ABFBF9EDC75ADAC80EA3C9BA2F  plan.2026-08-29T12-22.md
```

Both pinned TaskMaster plan fixtures still carry SHA-256
`54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f`, so no
fixture hydration occurred.

Output Summary: Pytest exited 0 with 169 passed and zero failures, covering the
167-case baseline plus the two new consumer-contract cases. Parity is exact,
the `.claude` porcelain observations are identical before and after, the
TaskMaster fixtures are unchanged, and no fixture hydration occurred.
