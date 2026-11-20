# preimplementation-gate-resolves-sibling-worktree-bash-to-session-root (Issue #1188)

- Date captured: 2026-11-14
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/preimplementation-gate-resolves-sibling-worktree-bash-to-session-root/ (Issue #1188)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1188
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1188
- Last Updated: 2026-11-14
- Work Mode: full-bug

## Summary

In the sibling-worktree topology (a non-isolated agent working in an item worktree under `.claude/worktrees/`), the preimplementation gate (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`) resolves some Bash commands to the session root instead of the item worktree. The session root has no orchestrator checkpoint, so the gate denies with `PREIMPLEMENTATION_GATE_BLOCKED`. The #1158 executor could run its pytest gate only through scratch `sh` scripts. The same gate also resolves commands that carry the worktree path only in a shell variable (`git -C $W ...`) to the session root.

## Environment

- OS/version: Windows 11, Claude Code runtime, PowerShell 7
- Python version: not applicable
- Command/flags used: a direct test-runner command from a sibling item worktree, for example `env -u VIRTUAL_ENV poetry -C <abs worktree> run pytest <abs test path>`
- Data source or fixture: reported by the #1158 run (PR #1184 body, ORCH-D8)

## Steps to Reproduce

1. In a session whose root has no orchestrator checkpoint, work in a sibling item worktree that has a ready checkpoint.
2. Run the item's test gate with a direct command that names the worktree through `poetry -C <abs>` (or `git -C <abs>`) and absolute test paths.
3. Observe `PREIMPLEMENTATION_GATE_BLOCKED` naming the missing checkpoint, although the named worktree's checkpoint is ready.

## Expected Behavior

The gate resolves the target worktree from the command operands it already supports (`git -C`, `poetry -C`/`--directory`, `npm --prefix`, absolute paths) for every command family it gates, and allows the command when that worktree's checkpoint is ready. Unresolvable commands keep failing closed.

## Actual Behavior

Direct commands are denied, and agents fall back to scratch `sh` scripts, which hide the command from every text-based hook. That weakens enforcement rather than strengthening it.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: see PR #1184, `## Decisions` (ORCH-D8) and `## Follow-ups`.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The resolver (`Resolve-HookTargetWorktree` / the CommandOperand source) likely recognises the worktree operand only for some command shapes, so other shapes fall back to the payload cwd, which is the session root. Shell-variable operands cannot be resolved from text and are expected to fail closed; the brief already tells agents to write paths literally.

## Proposed Fix / Validation Ideas

- [ ] Extend operand resolution to every command family the gate gates (poetry -C/--directory, npm --prefix, absolute script and test paths) with byte-identical behaviour in the Codex mirror
- [ ] Pester rows: each operand form resolving to a ready sibling worktree is allowed; the same form naming a not-ready worktree is denied; a shell-variable operand still denies
- [ ] Re-check the execution-environment brief text on sibling-worktree command shapes

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
