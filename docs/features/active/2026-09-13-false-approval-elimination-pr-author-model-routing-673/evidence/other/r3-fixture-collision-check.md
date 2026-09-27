# Fixture-Name Collision Check (issue #673)

Timestamp: 2026-09-19T17-41

Command: `Get-ChildItem -Path '.claude/hooks','.claude/lib','.claude/rules','scripts/dev_tools','scripts/bash' -Recurse -File | Select-String -SimpleMatch -Pattern 'orchestrator-state.json'`, with each hit rendered as a repository-relative path, line number, and trimmed line. A companion `grep -rn 'tests/fixtures'` over the same five trees established which consumers, if any, enumerate the fixture tree.

EXIT_CODE: 0

## Why this check exists

`[P3-T1]` commits fixture checkpoints at `tests/fixtures/worktree-resolution/<root>/artifacts/orchestration/orchestrator-state.json`. Any consumer that locates a checkpoint by **suffix** rather than by a root-anchored relative path could match a fixture file, and any consumer that **enumerates** the repository for checkpoints could ingest fixture content as live state. This task finds both classes before the fixtures exist.

## Classification key

- **root-anchored** — the path is used relative to a single process directory or a supplied root, so it can only ever name one file per root and cannot match a nested fixture path.
- **suffix-matching** — the path is matched against an arbitrary candidate by suffix or by a regex anchored with an alternation that permits a leading path segment, so a nested fixture path can match.
- **documentation** — the occurrence is inside a comment, a doc-comment block, a Markdown rule file, or a docstring, and carries no matching behaviour.
- **compiled artifact** — a `__pycache__` bytecode file whose classification is that of the source module it was compiled from. These are build outputs, not source, and are listed because the recursive scan reached them.

## Rows (28 matching files)

| File | Matching lines | Classification | Enumerates `tests/fixtures/`? |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-checkpoint-monotonic.ps1` | `:9` (doc comment) | **suffix-matching**, established at `:196`, whose regex is anchored `(^\|/)` and therefore admits a leading path segment. `:196` is not itself a `-SimpleMatch` hit because the literal there escapes the dot. | no |
| `.claude/hooks/enforce-completion-consistency.ps1` | `:10`, `:300` | `:10` documentation; `:300` root-anchored | no |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | `:11`, `:14`, `:17`, `:63`, `:64`, `:65` | `:11`, `:14`, `:17` documentation; `:63`, `:64`, `:65` root-anchored | no |
| `.claude/hooks/enforce-epic-wave-barrier.ps1` | `:15`, `:38` | `:15` documentation; `:38` root-anchored | no |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `:13`, `:16`, `:70`, `:71` | `:13`, `:16` documentation; `:70`, `:71` root-anchored | no |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | `:9`, `:46` | `:9` documentation; `:46` root-anchored (the binding-3 default this plan removes) | no |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `:58`, `:59`, `:60` | root-anchored | no |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `:27`, `:35`, `:37`, `:39`, `:40`, `:41`, `:442` | `:442` documentation (inside a deny reason string); the rest root-anchored | no |
| `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | `:19`, `:52` | `:19` documentation; `:52` root-anchored | no |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | `:71` | root-anchored | no |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | `:9`, `:42`, `:49` | `:9` documentation; `:42`, `:49` root-anchored | no |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | `:23`, `:35` | `:23` documentation; `:35` root-anchored (the binding-2 default this plan removes) | no |
| `.claude/hooks/enforce-pr-author-skill.ps1` | `:49` | root-anchored (the binding-1 assignment this plan replaces) | no |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | `:160`, `:368` | `:160` root-anchored (the DD-6 default this plan makes mandatory); `:368` documentation (inside the `must reference a feature folder` deny reason, which `[P9-T4]` rewords) | no |
| `.claude/hooks/validate-orchestrator-output.ps1` | `:7`, `:32`, `:319` | `:7` documentation; `:32`, `:319` root-anchored | no |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | `:427` | root-anchored (the latent fourth binding the spec requires to stay unreached) | no |
| `.claude/rules/orchestrator-state.md` | `:3`, `:27`, `:127` | documentation | no |
| `.claude/rules/parallel-orchestration.md` | `:24`, `:36` | documentation | no |
| `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` | `:5` | documentation (module docstring) | no |
| `scripts/dev_tools/orchestration_handoff_contract.py` | `:329` | root-anchored | no |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | `:28`, `:132` | `:28` documentation; `:132` root-anchored | no |
| `scripts/dev_tools/validate_epic_orchestrator_state.py` | `:416` | documentation | no |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | `:5` | documentation | no |
| `scripts/dev_tools/__pycache__/_parallel_orchestrator_state_cohort_barrier.cpython-313.pyc` | `:13` | compiled artifact of a documentation occurrence | no |
| `scripts/dev_tools/__pycache__/orchestration_handoff_contract.cpython-313.pyc` | `:70` | compiled artifact of a root-anchored occurrence | no |
| `scripts/dev_tools/__pycache__/parallel_drift_detection_cli.cpython-313.pyc` | `:35`, `:95` | compiled artifact of documentation and root-anchored occurrences | no |
| `scripts/dev_tools/__pycache__/validate_epic_orchestrator_state.cpython-313.pyc` | `:232` | compiled artifact of a documentation occurrence | no |
| `scripts/dev_tools/__pycache__/validate_parallel_orchestrator_state.cpython-313.pyc` | `:12` | compiled artifact of a documentation occurrence | no |
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` | `:93` | root-anchored. The comment at `:85-89` states the matching rule explicitly: matching is EXACT and never by prefix. | no |

## The one suffix-matching consumer, assessed

`.claude/hooks/enforce-checkpoint-monotonic.ps1` is the only consumer in the five scanned trees that matches a checkpoint path by suffix. Its predicate at `:196` is a regex anchored with `(^|/)` and terminated with `$`, so it returns true for a fixture path ending in `artifacts/orchestration/orchestrator-state.json` at any depth, including every fixture root `[P3-T1]` creates.

The collision is real in the matcher and does not block the fixtures, for two independent reasons:

1. **It is a write-time gate on the write's own `file_path`, not a tree enumerator.** `Invoke-CheckpointMonotonicDecision` reads `file_path` and `content` from the PreToolUse envelope. It never walks the repository, so a committed fixture file cannot be ingested by it as live state. The companion `tests/fixtures` search confirms no consumer in any of the five trees enumerates the fixture tree at all: the five hits it returned are a preimplementation-gate comment, a bash library comment, two `.claude/rules/shell.md` policy sentences, a converter README, and a cleanup-scan helper comment — all documentation, and none naming `tests/fixtures/worktree-resolution`.
2. **Its deny paths require genuinely bad content.** After the path predicate passes, the gate allows when `content` is absent, when `content` is not valid JSON, when the payload has no `completed_steps`, and when `rollback_history` is non-empty. It denies only on an out-of-order `completed_steps` pair or a missing prerequisite for an advanced step. The base fixture checkpoint is copied from a checkpoint already observed to pass `Invoke-OrchestratorStatePreflight`, so its `completed_steps` is well-ordered; the zero-byte fixture supplies no `content` and the invalid-JSON fixture fails the parse, so both take allow branches.

The residual consequence is bounded and is handed to `[P3-T1]`: writing a fixture checkpoint is *evaluated* by this gate even though it is expected to allow. `[P3-T1]` records any interception and its resolution in this artifact if one occurs.

## `[P3-T1]` interception record

Appended by `[P3-T1]` on 2026-09-19T18-14. **No PreToolUse interception occurred.** The eighteen fixture files were created by a `pwsh -NoProfile -File` process invoking `[System.IO.File]::WriteAllText`, not through a Write or Edit tool, so the checkpoint-monotonic gate — a PreToolUse hook on those tools — was never consulted. Nothing needed resolving.

The gate's substantive safety was verified independently rather than left to the fact that it was bypassed: `[P3-T2]` ran `Invoke-OrchestratorStatePreflight` against every `pr-author/` checkpoint and confirmed the three that must pass do pass, which requires the `completed_steps` order this section predicted would satisfy the monotonic gate's two deny conditions.

COLLISION_BLOCKS_FIXTURES: NO

Output Summary: 28 files in the five scanned trees mention the checkpoint filename, and every one has a row. Twenty-seven use the name either as documentation or as a root-anchored relative path, neither of which can match a nested fixture path. One, `.claude/hooks/enforce-checkpoint-monotonic.ps1`, is suffix-matching, classified from its regex at `:196`; it is a write-time gate on the write's own `file_path` rather than a tree enumerator, and its deny branches require an out-of-order `completed_steps`, which no planned fixture carries. No consumer in any scanned tree enumerates `tests/fixtures/`. The committed fixtures are therefore safe to create, and execution continues.
