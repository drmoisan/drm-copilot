# Baseline — push-down claude-resource contract test (expected non-zero exit)

Timestamp: 2026-09-09T00-00

Task: [P0-T10] `[expect-fail]`

Command: `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
EXIT_CODE: 1
ExpectedExitCode: 1

Run from the worktree root
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`, with stdout
and stderr captured together.

## Output Summary

Summary line, verbatim:

```
1 failed, 10 passed in 0.15s
```

Progress line and failing node, verbatim:

```
.F.........                                                              [100%]
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

Assertion message, verbatim:

```
AssertionError: Repo file missing from bundle: .claude\state\current-session-id
```

## Why this is recorded as an expected non-zero exit rather than left unchecked

The single failing assertion concerns `.claude/state/current-session-id`, a gitignored local
session-state file written by the Claude runtime in this checkout. It is not tracked content
and it is not attributable to this branch: the same test is green in CI, where no such file
exists. The defect is filed as issue **#510** and is recorded in
`evidence/other/phase0-blocked-gates.2026-09-08T22-00.md` as one of the two adjudicated
blocked gates for this feature. The caller's adjudication forbids planning work to close it,
and the plan explicitly does not attempt to make this leg pass. Deleting the gitignored state
file is not a durable fix and is not attempted; the file is left in place.

`ExpectedExitCode: 1` is declared so the gate's known outcome is auditable rather than left as
an unchecked box. The ten passing tests in the same file are the legs that do exercise this
branch's content.

## The half of this contract that this feature owns

The portion of the push-down claude-resource contract this feature is responsible for is the
**`SKILL.md` mirror parity**: every `.claude/**` edit this cycle makes must be mirrored
byte-identically into `extensions/drm-copilot/resources/claude-customizations/.claude/**`.
That property is checked separately by **P4-T7**, which compares the two copies directly
rather than relying on this pytest module. This cycle's failing leg above says nothing about
mirror parity; it reports only that an untracked, gitignored runtime file present in this
checkout is absent from the bundle.
