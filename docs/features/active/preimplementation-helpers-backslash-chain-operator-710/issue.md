# Bug: preimplementation-helpers-backslash-chain-operator

- Issue: #710
- Labels: bug
- Work Mode: full-bug
- Severity: Low
- Source: GitHub issue #710 body (lifecycle record not available on this branch)

## Summary
The command-chain scanner in `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (and its three byte-identical copies) treats an unquoted `\;`, `\&` or `\|` as a chain operator. A POSIX shell treats each as a literal character.

## Environment
- OS/version: any
- Python version: n/a (PowerShell hook)
- Command/flags used: a Bash command containing an unquoted backslash-escaped `;`, `&` or `|`, for example `find . -exec cmd {} \;`
- Data source or fixture: n/a

## Steps to Reproduce
1. Issue a Bash command containing `\;` outside quotes.
2. Observe the gate split the line into more segments than the shell does.

## Expected Behavior
An escaped chain character is a literal, as in POSIX shell, and does not split the command.

## Actual Behavior
The scan splits on it. The mismatch fails toward deny: the gate sees extra segments, so the risk is spurious denials, not a bypass.

## Logs / Screenshots
- Snippet: #663 `evidence/other/follow-ups.md`, item 8.

## Impact / Severity
- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Acceptance Criteria
- [ ] An unquoted backslash-escaped `;`, `&` or `|` (`\;`, `\&`, `\|`) is treated as a literal character by the command-chain scanner and does not split the command into additional segments.
- [ ] Unescaped chain operators (`;`, `&&`, `||`, `|`, `&`) continue to split the command exactly as before, and an escaped backslash followed by an operator (`\\;`) still splits, so the fix introduces no bypass.
- [ ] The fix is applied identically to all four byte-identical copies of `enforce-orchestration-preimplementation-gate-helpers.ps1` (`.claude/hooks`, `.codex/hooks`, and the two extension resource mirrors), and the existing parity test continues to pass.
- [ ] Regression tests covering the escaped and unescaped cases are added and pass under Pester on both Windows and Linux CI.

## Source
From: docs/features/potential/2026-09-26-preimplementation-helpers-backslash-chain-operator.md (GitHub issue #710)
