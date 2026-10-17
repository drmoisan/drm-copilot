# Bundled Payload Parity

Timestamp: 2026-09-30T10-01

Plan task: [P2-T13]

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -rf

EXIT_CODE: 1

ExpectedExitCode: 1

PARITY_RESULT: environmental-only

Output Summary: 1 failed. The only path named in the failure output is a git-ignored `.claude/state/` batch-budget file of this worktree; [P2-T12] passed (identical SKILL.md object IDs), so the pre-declared environmental-only condition holds.

## Summary line (verbatim)

```text
============================== 1 failed in 0.15s ==============================
```

## Failure lines (verbatim)

```text
E           AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.worktree-agent-a86c4509777292c35-1c481456.json
E           assert WindowsPath('.claude/state/python-batch-budget.worktree-agent-a86c4509777292c35-1c481456.json') in [WindowsPath('.claude/agent-memory/epic-orchestrator/feedback_commit_push_memory_before_pr.md'), WindowsPath('.claude/..._unmerged_pr_deps.md'), WindowsPath('.claude/agent-memory/orchestrator/feedback_commit_push_memory_before_pr.md'), ...]
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

## Normalized failure paths (every `\` replaced with `/`)

- `.claude/state/python-batch-budget.worktree-agent-a86c4509777292c35-1c481456.json` (under `.claude/state/`)

The bundle-list entries in the `assert ... in [...]` repr are the comparison set, not failing paths; the test stops at the first missing repo file, which is the path above.

## Pre-declared rule evaluation

| Condition | Observed | Met |
|---|---|---|
| EXIT_CODE 1 | 1 | yes |
| Every normalized failure path lies under `.claude/state/` | 1 of 1 | yes |
| [P2-T12] passed | yes (`skill-doc-and-mirror.md`) | yes |

## Result

PASS (environmental-only): the failure is the known local-only git-ignored state file recorded in research section 6 (variant name for this worktree), not a SKILL.md mirror divergence.
