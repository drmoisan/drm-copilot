# Fail-Before Evidence — R-03 Permission-Seam Contract Tests

Timestamp: 2026-08-08T19-34

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py -v`

Working directory: repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`)

Surface state: the three seam tests are authored in Phase 1 against the UNFIXED delivered surface.
`.claude/skills/parallel-orchestrate/SKILL.md` and `.claude/agents/parallel-orchestrator.md` are
byte-identical to their state at HEAD `41633ad5e867070853e3e4501c3457b6641d1efc`. No Phase 2 or Phase 3
edit has been made.

EXIT_CODE: 1

Output Summary:
- Collected: 3
- Failed: **3**
- Passed: 0
- Skipped: 0
- Wall time: 0.09s

This is the intended fail-before state for the `[expect-fail]` tasks `[P1-T4]`, `[P1-T5]`, and
`[P1-T6]`. Each failure reason is the specific one the plan predicted; no failure occurred for any
other reason, so the parsers are correct and Phase 2 may begin.

## Failure 1 — `test_every_prescribed_parent_write_target_has_a_persona_write_grant`

Uncovered prescription named by the assertion message: **`docs/features/active/`**

Verbatim assertion message:

```
AssertionError: the parallel-orchestrate procedure prescribes a parent write to a target no parallel-orchestrator Write grant covers: ('docs/features/active/',). Declared Write grants are ('docs/features/parallel/**', 'artifacts/orchestration/**'). Every parsed target was ('docs/features/parallel/<slug>/parallel-status.md', 'docs/features/active/', 'artifacts/orchestration/parallel-orchestrator-state.json').
assert not ('docs/features/active/',)
```

Verification against the `[P1-T7]` acceptance conditions:

- Exactly ONE uncovered target is reported: `docs/features/active/`, retained from the current
  `## Per-Item Merge-Conflict Handling` step-1 sentence in which the preceding word `under` places the
  token in write-destination position.
- The other two parsed targets, `docs/features/parallel/<slug>/parallel-status.md` and
  `artifacts/orchestration/parallel-orchestrator-state.json`, are both returned and both covered.
- The message names **none** of `config/orchestration-routing.json`,
  `docs/features/active/<basename>`, or `origin/main`, so the immediately-preceding-word adjacency
  condition of `prescribed_parent_write_targets()` is correctly implemented. No delivered skill text
  was edited to satisfy the parser.
- Three parsed targets satisfies the cardinality floor of two at HEAD, so the floor assertion passed
  and the coverage assertion is the one that failed.

## Failure 2 — `test_every_prescribed_command_invocation_has_a_persona_bash_grant`

Uncovered prescription named by the assertion message:
**`python -m scripts.dev_tools.validate_orchestration_artifacts parallel-orchestrator-state <path>`**

Verbatim assertion message:

```
AssertionError: the parallel-orchestrate procedure prescribes a command invocation no parallel-orchestrator Bash grant covers: ('python -m scripts.dev_tools.validate_orchestration_artifacts parallel-orchestrator-state <path>',). Declared Bash grants are ('git *', 'gh *'). Every parsed invocation was ('git worktree list --porcelain', 'git branch', 'gh pr view --json state,mergedAt,headRefOid', 'git fetch origin main', 'gh pr checks', 'gh pr merge --merge <PR>', 'gh pr merge --merge', 'gh pr update-branch', 'git merge --no-commit origin/main', 'git diff --name-only --diff-filter=U', 'git worktree remove <worktree_path>', 'git worktree remove', 'python -m scripts.dev_tools.validate_orchestration_artifacts parallel-orchestrator-state <path>')
assert not ('python -m scripts.dev_tools.validate_orchestration_artifacts parallel-orchestrator-state <path>',)
```

Verification: exactly one uncovered invocation, whose bare `python` head no grant covers. Thirteen
distinct invocations were parsed, clearing the cardinality floor of eight, so the floor assertion
passed and the coverage assertion is the one that failed.

## Failure 3 — `test_manifest_validation_gate_prescribes_a_granted_command_invocation`

Uncovered prescription: **none — the section prescribes no command invocation at all.**

Verbatim assertion message:

```
AssertionError: the .claude\skills\parallel-orchestrate\SKILL.md section that names validate_parallel_manifest_text prescribes no command invocation covered by a parallel-orchestrator Bash grant, so the manifest gate it makes a precondition of any kickoff has no permitted mechanism. Declared Bash grants are ('git *', 'gh *').
assert ()
```

Verification: the section-location assertion passed (exactly one section of the skill names
`validate_parallel_manifest_text`), and the granted-invocation set for that section is empty, which is
the predicted reason. The gate is therefore documented but has no permitted mechanism at HEAD.

## Verbatim Run Summary

```
collecting ... collected 3 items
tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py::test_every_prescribed_parent_write_target_has_a_persona_write_grant FAILED [ 33%]
tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py::test_every_prescribed_command_invocation_has_a_persona_bash_grant FAILED [ 66%]
tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py::test_manifest_validation_gate_prescribes_a_granted_command_invocation FAILED [100%]
============================== 3 failed in 0.09s ==============================
```

Pass-after evidence over these same three test ids, with no assertion weakened, is recorded by
`[P3-T5]` at `../regression-testing/permission-seam-pass-after.<timestamp>.md`.
