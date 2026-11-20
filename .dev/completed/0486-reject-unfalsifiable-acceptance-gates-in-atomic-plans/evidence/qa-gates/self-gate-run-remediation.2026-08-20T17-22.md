# Plan-Acceptance Gate Run Against This Remediation Plan ([P4-T11])

Timestamp: 2026-08-20T17-22

Command: `PYTHONPATH=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/remediation-plan.2026-08-20T16-10.md --workspace-root .`

Working directory: worktree root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d`

EXIT_CODE: 0

## Full stderr text

The run emitted no stderr output. Combined stdout and stderr consisted of the single stdout line:

```
plan validation passed: docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/remediation-plan.2026-08-20T16-10.md
```

## Warning disposition

**Zero `PLAN GATE WARNING: ` lines were emitted**, so there is no per-warning disposition to record.
The gate prints every Warning-channel finding to stderr with that exact prefix; stderr was empty.
This is consistent with [P4-T10], whose MCP result carried no `warnings` field.

## Negative control (this gate can fail)

To establish that the exit-0 result above is a real pass and not a gate that cannot fail, the same
CLI was run against a deliberately defective one-task plan held outside the repository (in the
session scratchpad), whose acceptance command carried a coverage value ending in the Python suffix:

Command: `PYTHONPATH=... poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <scratchpad>/negative-control-plan.md --workspace-root .`

EXIT_CODE: 1

Output:

```
[P0-T1] --cov argument `scripts/dev_tools/foo.py` names a filesystem path; coverage.py accepts only directories or importable names. Use --cov=scripts.dev_tools.foo.
```

The gate therefore evaluates the artifact it is pointed at and returns a non-zero exit code with a
G1 Blocking finding when one is present. The control file lives outside the worktree and is not part
of the change set.
