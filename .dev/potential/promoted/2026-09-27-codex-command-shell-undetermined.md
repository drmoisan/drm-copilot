# codex-command-shell-undetermined (Issue #735)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/codex-command-shell-undetermined/ (Issue #735)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #735
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/735
- Last Updated: 2026-09-27
## Summary

The Codex-surface gates parse commands as if a POSIX shell runs them, but nobody has established which shell Codex actually uses on Windows. If it is PowerShell, recent parser changes may admit commands that main used to deny.

## Environment

- OS/version: Windows 11 (Codex CLI)
- Python version: n/a
- Command/flags used: Codex-surface hooks under `.codex/hooks/`
- Data source or fixture: #710 (backslash-escape handling), #713 (the `$` allowance inside single quotes, and the CR-1 curly-quote fix)

## Steps to Reproduce

1. #710 now treats `\;`, `\&` and `\|` as literals, as POSIX does. PowerShell does not treat backslash as an escape character.
2. #713 allows `$` inside single quotes. PowerShell does not expand inside single quotes either, but curly quotes (U+2018-U+201E) act as quotes in PowerShell. CR-1 fixed that in-PR by refusing to exempt any command containing a curly quote.
3. Which shell Codex uses on Windows is undocumented, so the safety of item 1 on the Codex surface is unverified.

## Expected Behavior

The gate's parsing semantics match the shell that executes the command, on each surface.

## Actual Behavior

The shell is unknown. #710's report item 3 and #713's CR-1 both raised the question and left it open.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: #710 and #713 final reports.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

The shared helpers are byte-identical across the Claude and Codex surfaces, and they assume bash semantics.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: determine and document the Codex command shell on Windows and Linux (Codex docs, `.codex/config.toml`, or a live probe). If it is PowerShell, add PowerShell-semantics deny cases to the Codex gate suites, or have the Codex hooks fail closed on shell-ambiguous constructs.
- [ ] Integration scenario to retest: the Codex gate deny suites run under the determined shell's semantics.
- [ ] Manual verification notes: record the answer in `.claude/rules/` and in the Codex hook headers.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
