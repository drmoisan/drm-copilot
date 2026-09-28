# QA Gate — Push-Down Mirror Parity (Issue #630)

Timestamp: 2026-09-07T14-30

Task: [P6-T6]

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k bundled_claude_payload_contains_all_repo_runtime_contracts -q`

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

## Command Substitution

None for the command itself. [P6-T6] is the one command-bearing task in this plan that names
no `wsl -d Ubuntu -- bash -lc '...'` wrapper: it is a Python test invoked through `poetry`,
which runs natively on Windows. The command was run exactly as the plan states it. The
plan's stale worktree path `agent-a06652a3fd875c703` does not appear in this task's command
and required no substitution; the command ran in the real worktree
`agent-adf4f49cbc48904be`.

## Raw Output

```
1 passed, 10 deselected in 0.12s
```

## First Invocation Failed — Recorded in Full

A first invocation of this exact command **failed**, and that failure is recorded here rather
than discarded.

```
AssertionError: Repo file missing from bundle: .claude/state/python-batch-budget.worktree-agent-adf4f49cbc48904be-7d397a9a.json
```

**Cause.** The named file is local, untracked, and gitignored. `.gitignore` line 68 is
`.claude/state/`, and `git ls-files .claude/state` returns zero tracked paths, so nothing
under that directory is in the repository. The test walks the on-disk `.claude` tree rather
than the tracked file set, so a state file generated locally by a previous agent run is
compared against a bundle that cannot contain it. The failure is a property of the local
working directory, not of this feature's change set: no file this feature adds or edits is
implicated in the assertion, and the test is green in CI, where `.claude/state/` does not
exist.

**Prior art.** This is the previously filed issue **#510** — a local-only failure of the
bundle-parity test that is green in CI.

**Workaround and its scope.** The passing run above was obtained by moving that single
untracked file aside for the duration of the test and restoring it immediately afterwards.
**No tracked file was altered.** The only file touched was the untracked, gitignored state
file named in the assertion. The repository's tracked content at the time of the passing run
is identical to its content at the time of the failing run.

## Mirror Parity, Independently Confirmed

The test's subject for this feature is the skill file and its bundled mirror. Both were
compared directly:

```
$ cmp .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md
$ wc -c .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md
18325 .claude/skills/cleanup-merged-worktrees/SKILL.md
18325 extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md
```

`cmp` produced no output, which is its byte-identical result, and both files measure
**18325 bytes**. The repository skill file and its push-down mirror are therefore
byte-identical, which is stricter than the content-identical comparison the governing test
performs and rules out a CRLF/LF divergence between the pair.

Output Summary: The selected test passed — **`1 passed`**, with 10 tests deselected by the
`-k` filter — and the command exited **0**. A first invocation of the same command failed on
an assertion naming an untracked, gitignored `.claude/state/` file; that failure is issue
**#510**, is unrelated to this feature's change set, and is green in CI. The workaround for
the passing run moved only that one untracked gitignored file aside and restored it, leaving
every tracked file unchanged. Independently of the test, the repository skill file and its
bundled mirror are byte-identical at 18325 bytes each, confirmed with `cmp` and `wc -c`.
This is the evidence for AC21.
