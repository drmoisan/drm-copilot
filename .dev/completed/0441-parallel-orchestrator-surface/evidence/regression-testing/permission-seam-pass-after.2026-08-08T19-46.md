# Pass-After Evidence — R-03 Permission-Seam Contract Tests

Timestamp: 2026-08-08T19-46

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py -v`

Working directory: repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`)

Surface state: Phase 2 (`[P2-T1]`, `[P2-T2]`) and Phase 3 (`[P3-T1]` through `[P3-T4]`) are applied.

EXIT_CODE: 0

Output Summary:
- Collected: 3
- Passed: **3**
- Failed: 0
- Skipped: 0
- Wall time: 0.07s

## Cross-Reference to Fail-Before

Fail-before artifact:
`docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/regression-testing/permission-seam-fail-before.2026-08-08T19-34.md`
(`EXIT_CODE: 1`, 3 failed, 0 passed).

The same three test ids failed there and pass here:

| Test id | Fail-before | Pass-after |
| --- | --- | --- |
| `test_every_prescribed_parent_write_target_has_a_persona_write_grant` | FAILED (`docs/features/active/` uncovered) | PASSED |
| `test_every_prescribed_command_invocation_has_a_persona_bash_grant` | FAILED (`python -m scripts.dev_tools.validate_orchestration_artifacts parallel-orchestrator-state <path>` uncovered) | PASSED |
| `test_manifest_validation_gate_prescribes_a_granted_command_invocation` | FAILED (section prescribed no covered invocation) | PASSED |

No assertion was relaxed, removed, skipped, or `xfail`-marked between the two runs. The three
assertions, their two cardinality floors (>= 2 write targets, >= 8 command invocations), and their
failure messages are byte-identical in both runs; the entire delta is in the delivered persona and
the delivered skill.

## Parsed Write-Target List (post-fix)

Two targets, both covered by a declared `Write(...)` grant:

| Prescribed target | Covering grant |
| --- | --- |
| `docs/features/parallel/<slug>/parallel-status.md` | `Write(docs/features/parallel/**)` |
| `artifacts/orchestration/parallel-orchestrator-state.json` | `Write(artifacts/orchestration/**)` |

Two targets meets the cardinality floor of two exactly, which is why the floor was not raised.
`docs/features/active/` is no longer prescribed as a parent write: the R-01 rewrite assigns that
write to the child's `atomic-executor`, and the sentence naming the destination names the child as the
writer.

## Parsed Invocation Count (post-fix)

**14** distinct prescribed command invocations, all covered:

| Invocation (head) | Covering grant |
| --- | --- |
| `poetry run python -c "import pathlib, sys; ... " docs/features/parallel/<slug>/parallel.md` | `Bash(poetry run python -c *)` |
| `git worktree list --porcelain` | `Bash(git *)` |
| `git branch` | `Bash(git *)` |
| `gh pr view --json state,mergedAt,headRefOid` | `Bash(gh *)` |
| `git fetch origin main` | `Bash(git *)` |
| `gh pr checks` | `Bash(gh *)` |
| `gh pr merge --merge <PR>` | `Bash(gh *)` |
| `gh pr merge --merge` | `Bash(gh *)` |
| `gh pr update-branch` | `Bash(gh *)` |
| `git merge --no-commit origin/main` | `Bash(git *)` |
| `git diff --name-only --diff-filter=U` | `Bash(git *)` |
| `git worktree remove <worktree_path>` | `Bash(git *)` |
| `git worktree remove` | `Bash(git *)` |
| `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts parallel-orchestrator-state <path>` | `Bash(poetry run python -m *)` |

The count moved from 13 to 14: `[P3-T3]` added the manifest-gate `poetry run python -c` invocation,
and `[P3-T4]` normalized the previously uncovered bare `python -m` fallback in place rather than
removing it. Fourteen clears the cardinality floor of eight.

## Verbatim Output Tail

```
tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py::test_every_prescribed_parent_write_target_has_a_persona_write_grant PASSED [ 33%]
tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py::test_every_prescribed_command_invocation_has_a_persona_bash_grant PASSED [ 66%]
tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py::test_manifest_validation_gate_prescribes_a_granted_command_invocation PASSED [100%]

============================== 3 passed in 0.07s ==============================
```
