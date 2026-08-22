# Baseline evidence: the epic merge gate is inert in a live session (#501)

- Captured: 2026-08-21T21:58Z
- Captured by: orchestrator (main session), Claude Code on Windows 11 Pro 10.0.26200
- Branch: `bug/pretooluse-hooks-parse-flat-payload-501`
- Purpose: independent, in-session confirmation of the Blocker claimed by issue #501, taken before
  any fix work was planned.

## Why this probe is decisive

`.claude/settings.json` registers `enforce-epic-merge-gate.ps1` as a `PreToolUse` hook on the
`Bash` matcher. Its contract is that `gh pr merge --merge` is denied with `EPIC_MERGE_GATE_BLOCKED`
unless one of three checkpoint allow-branches is satisfied.

At capture time no allow-branch was satisfiable in this session:

- `artifacts/orchestration/orchestrator-state.json` exists with `epic_mode: false` and
  `step9_status: "pending"`.
- No `artifacts/orchestration/epic-orchestrator-state.json` is present.
- No `artifacts/orchestration/parallel-orchestrator-state.json` is present.

A working gate therefore had to deny the command.

## Command issued

```text
gh pr merge 999999 --merge
```

PR 999999 does not exist in `drmoisan/drm-copilot`; the number was chosen so that a gate failure
would be observable without any possibility of merging a real pull request.

## Observed result

```text
GraphQL: Could not resolve to a PullRequest with the number of 999999. (repository.pullRequest)
```

The command reached the `gh` CLI and failed only because the pull request does not exist. No hook
decision was emitted, no `EPIC_MERGE_GATE_BLOCKED` reason appeared, and the tool call was not
denied.

## Interpretation

The gate did not fire on a command it is specified to deny. This confirms the issue's central
claim from inside a live Claude Code session, independently of the issue author's reported run and
independently of any static trace: the `PreToolUse` enforcement surface is failing open.

The probe establishes only that the gate is inert. It does not by itself distinguish the two causes
the research artifact identifies — the wrong transport (hooks read `CLAUDE_TOOL_INPUT` /
`CLAUDE_HOOK_INPUT`, which the documented hook environment does not include) and the wrong shape
(tool arguments read off the parsed root rather than the nested `tool_input` object). Both must be
corrected; correcting only the shape would leave this probe's result unchanged.

## Expected result after the fix

Re-running the same command against the same checkpoint state must produce a denial whose reason
begins `EPIC_MERGE_GATE_BLOCKED:`. This probe is the acceptance check for the fix's end-to-end
effect and should be repeated as final-QA evidence.

## Cross-references

- Research: `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/research/2026-08-21T17-45-pretooluse-hook-payload-envelope-501-research.md`
- Issue: #501
