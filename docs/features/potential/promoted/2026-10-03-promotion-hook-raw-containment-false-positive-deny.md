# promotion-hook-raw-containment-false-positive-deny (Issue #824)

- Date captured: 2026-10-03
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/promotion-hook-raw-containment-false-positive-deny/ (Issue #824)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #824
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/824
- Last Updated: 2026-10-03
## Summary

`.claude/hooks/enforce-promotion-mcp-only.ps1` denies read-only wrapped `pwsh` commands whose raw text merely contains the letters "gh", "issue" and "new" anywhere. The raw-containment fallback in `.claude/hooks/hook-command-invocation.ps1` is documented as loose, on the basis that a false positive only forces a checkpoint check. The promotion hook turns that loose match into an unconditional deny with no checkpoint check and no escape path.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (PowerShell hooks)
- Command/flags used: Bash tool command routed through the PreToolUse hook
- Data source or fixture: main at 93725814

## Steps to Reproduce

1. Send this read-only Bash command, which invokes no `gh`, through the PreToolUse hook:
   `pwsh -NoProfile -Command '$parts = New-Object System.Collections.Generic.List[string]; foreach ($t in @("a phrase that runs through the text", "The call is guarded (issue #1)")) { Write-Output $t }'`
2. Observe the hook decision.

## Expected Behavior

Allow. Only an actual `gh issue create|new` invocation, or a genuinely unresolvable segment, is denied.

## Actual Behavior

Deny with PROMOTION_MCP_ONLY_BLOCKED (gh issue creation reason).

The hook calls `Test-CommandLineInvocation -CommandWord 'gh' -SubcommandPath @('issue','create'|'new')`. For any wrapper-led segment (for example `pwsh -NoProfile -Command '...'`) or segment containing a live substitution, `Resolve-CommandLineInvocation` falls back to `Test-CommandLineRawContainment`. That fallback uses ordinal, case-insensitive substring containment of each word anywhere in the raw text and ignores word boundaries, order and adjacency. "gh" matches inside through/high/length, "issue" matches inside a string, and "new" matches `New-Object`, `::new()` or newline.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `PROMOTION_MCP_ONLY_BLOCKED`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

- An atomic plan's read-only phrase-count verification command was blocked twice in one plan. Each time, execution halted and needed a maintainer-approved one-time bypass. Plans may not reword commands to avoid a hook, so no workaround is permitted.
- Other hooks that call `Test-CommandLineInvocation` / `Resolve-CommandLineInvocation` with an unconditional deny on the containment path likely share the defect: the commit/add/remove scanners and the gh pr create scanners.

## Proposed Fix / Validation Ideas

Required change:

1. Do not deny on raw containment alone in the promotion hook. For wrapper-led and substitution segments, require token-aware evidence of an actual invocation in the raw text, including the text inside a `-Command` / `-c` argument. For example: `(?i)(?<![\w-])gh\s+issue\s+(?:create|new)\b`.
2. Keep fail-closed behavior for genuinely unresolvable cases: an Unbalanced segment, or an obfuscated invocation the token-aware pattern cannot rule out. If loose containment must remain as a last resort, route it to the checkpoint check its comment describes, not to an unconditional deny.
3. Audit the other hooks that hard-block on the containment path (commit/add/remove scanners, gh pr create scanners) and apply the same correction wherever a non-structural match produces a hard block.
4. Do not weaken detection of real bypasses.

Acceptance criteria:

- [ ] The reproduction command above is allowed.
- [ ] Still denied: `gh issue create ...`; `gh issue new ...`; `GH  Issue  Create` (case and spacing variants); `pwsh -NoProfile -Command 'gh issue create --title x'`; `pwsh -c "& gh issue new"`; `bash -c "gh issue create"`; a `gh api repos/o/r/issues -X POST` call.
- [ ] A wrapped payload containing "through", "issue" and "New-Object", but no `gh issue create|new` token sequence, is allowed.
- [ ] Pester tests cover every case above, including a negative control that fails if the substring-containment deny path is restored.
- [ ] `Test-CommandLineRawContainment`'s documented contract ("a false positive only forces a checkpoint check") matches what its callers do, or the comment is corrected.
- [ ] The PowerShell toolchain passes: format, analyze, then test with coverage.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
