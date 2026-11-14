# owner-directive-pass-down-fails-on-non-ascii-text (Issue #1187)

- Date captured: 2026-11-14
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/owner-directive-pass-down-fails-on-non-ascii-text/ (Issue #1187)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1187
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1187
- Last Updated: 2026-11-14
- Work Mode: full-bug

## Summary

On Windows the owner-directive pass-down PreToolUse hook (`.claude/hooks/enforce-owner-directive-pass-down.ps1`, issue #1157) cannot match a recorded directive whose `text` contains a non-ASCII character such as an em dash. It therefore denies every worker or orchestrator delegation for that item with `OWNER_DIRECTIVE_RELAY_REQUIRED`, even when the brief relays the directive verbatim. The #1158 run could proceed only by re-recording the directive with an ASCII hyphen and a recomputed hash, which changes the owner's words.

## Environment

- OS/version: Windows 11, Claude Code runtime, PowerShell 7
- Python version: not applicable
- Command/flags used: `Agent(<worker>)` delegation whose prompt carries a fenced `Owner directives:` block relaying a directive that contains U+2014
- Data source or fixture: reported by the #1158 run (PR #1184 body, ORCH-D5)

## Steps to Reproduce

1. Record an owner directive whose text contains an em dash (U+2014) in an item checkpoint, with `text_sha256` over the UTF-8 bytes.
2. Delegate a worker from that item with the directive relayed verbatim in the `Owner directives:` block.
3. Observe the delegation denied as if the directive were not relayed.

## Expected Behavior

A directive relayed byte-for-byte is recognised whatever characters it contains; the hook compares text and hashes over UTF-8 consistently on every platform.

## Actual Behavior

The delegation is denied on Windows. Recording only ASCII text works around it, but owner directives are recorded verbatim, so the workaround alters the record.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: see PR #1184, `## Decisions` (ORCH-D5) and `## Follow-ups`.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Likely an encoding mismatch on Windows: the hook payload, the checkpoint read, or the hash input is decoded or re-encoded with a non-UTF-8 code page (for example the console default), so the relayed text or its SHA-256 differs from the stored value. Check `[Console]::InputEncoding`, `Get-Content` without `-Encoding utf8`, and any string-to-bytes conversion in the hook and `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1`. The stop-hook coverage check and the ledger validation may share the defect.

## Proposed Fix / Validation Ideas

- [ ] Read stdin and files as UTF-8 explicitly and hash UTF-8 bytes in every owner-directive path
- [ ] Pester rows with em dash, curly quotes and a non-BMP character in directive text (relay accepted; altered text still denied)
- [ ] Verify the stop-hook pass-down check and the ledger validator on the same inputs

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
