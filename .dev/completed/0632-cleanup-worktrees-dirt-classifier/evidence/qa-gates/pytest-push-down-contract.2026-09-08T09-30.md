# Push-down claude-resource contract test — cycle 2, Phase 4 (P4-T7)

Timestamp: 2026-09-08T09-30
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ac72d35e7980bc69d`

Command: `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
EXIT_CODE: 1

## Output Summary

`1 failed, 10 passed in 0.25s`.

Passed count: 10. The task's acceptance demands `EXIT_CODE: 0` and `11 passed`, so **the acceptance
is not met and [P4-T7] remains unchecked**.

Failing test:
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`

```
E           AssertionError: Repo file missing from bundle: .claude\state\current-session-id
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:125: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
1 failed, 10 passed in 0.25s
```

## This is the pre-existing failure adjudicated at Phase 0, not a regression

The cause is `.claude/state/current-session-id`, which is gitignored at `.gitignore:67` while the
test's repo-side enumeration walks the filesystem and excludes only `settings.local.json` and
`.claude/agent-memory/**`. This is the recorded bundle-parity defect, open as issue **#510**: it
fails locally and is green in CI, because CI's checkout carries no local session-state file.

The identical failure — same test, same assertion, same `1 failed, 10 passed` — was observed at the
Phase 0 baseline by [P0-T10], before any source change on this branch. That baseline-versus-
post-change comparison is the one that matters, and both ends of it carry the same pre-existing
failure. The adjudication is recorded at
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/other/phase0-blocked-gates.2026-09-08T22-00.md`.

The state file was **not** deleted to force a pass. Deleting it is a local mutation that makes the
gate green without changing anything the gate measures, and it is not durable.

## Relation to this phase's own edit

P4-T5 edited `.claude/skills/cleanup-merged-worktrees/SKILL.md` and P4-T6 mirrored it
byte-identically into
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`,
verified by matching `md5sum` digests in
`evidence/qa-gates/skill-mirror-parity.2026-09-08T09-30.md`. The failing assertion names
`.claude/state/current-session-id` and not the skill file, so this phase's mirror obligation is
discharged and is not implicated in the failure.

ExpectedExitCode: 1
