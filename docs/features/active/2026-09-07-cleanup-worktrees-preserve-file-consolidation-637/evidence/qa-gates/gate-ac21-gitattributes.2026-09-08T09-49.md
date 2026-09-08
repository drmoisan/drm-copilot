# Gate — AC-21, the `.gitattributes` CRLF-fixture exception

Timestamp: 2026-09-08T09-49
Task: [P1-T4]
Command: grep -c -F -- -text <ROOT>/.gitattributes && grep -c -F -- preserve/eol-crlf <ROOT>/.gitattributes && tail -n 1 <ROOT>/.gitattributes
EXIT_CODE: 0
ExpectedExitCode: 0

`<ROOT>` above is `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5`;
each of the three spans was run with that absolute path substituted in full.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'grep -c -F -- -text <WSLROOT>/.gitattributes && grep -c -F -- preserve/eol-crlf <WSLROOT>/.gitattributes && tail -n 1 <WSLROOT>/.gitattributes'"`
- Substitute actually run: the identical three-span chain, in Git Bash, with the Windows-form
  absolute root substituted for `<WSLROOT>` and no `pwsh` or `wsl` leg. No leading `cd` is used,
  because `.claude/hooks/validate-bash.ps1` denies a `grep`/`tail` span chained after a `cd`.
- Reason: `pwsh` is refused unconditionally in this worktree.

Output Summary:

- First count (`grep -c -F -- -text`): **1**
- Second count (`grep -c -F -- preserve/eol-crlf`): **1**
- Final line printed by `tail -n 1`, verbatim:

      tests/fixtures/cleanup_worktrees/preserve/eol-crlf/** -text

  That line equals the line AC-21 names, character for character.
- Exit code of the chain: 0.

The file now holds exactly two lines: the pre-existing `* text=auto eol=lf` first, and the exception
second. Order is load-bearing — later rules override earlier ones — and both counts being 1
establishes that the exception was appended once rather than duplicated.

Satisfies **AC-21**.

Verdict: PASS.
