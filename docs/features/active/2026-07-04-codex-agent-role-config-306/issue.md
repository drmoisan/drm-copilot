# codex-agent-role-config (Issue #306)

- Date captured: 2026-07-04
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/codex-agent-role-config/ (Issue #306)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #306
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/306
- Last Updated: 2026-07-04
- Work Mode: full-bug

## Summary

New worktrees can receive a malformed `.codex/agents/orchestrator.toml` role definition that Codex rejects during startup or `codex doctor --json`. The `drm-copilot: New Codex Worktree Session` command can also fail before worktree setup because the extension cannot resolve the Codex CLI executable.

## Environment

- OS/version: Windows, VS Code Insiders
- Command/flags used: `drm-copilot: New Codex Worktree Session`; `codex doctor --json`
- Data source or fixture: affected worktree `C:\Users\DanMoisan\repos\TaskMaster-wt-2026-07-04-12-57\.codex\agents\orchestrator.toml`

## Steps to Reproduce

1. Run `drm-copilot: New Codex Worktree Session` from VS Code Insiders in a repository that uses the pushed-down Codex customization payload.
2. Inspect the generated `.codex/agents/orchestrator.toml` in the new or affected worktree.
3. Run `codex doctor --json` with the Codex executable from the VS Code extension package.

## Expected Behavior

The worktree session command resolves a usable Codex CLI executable, completes bootstrap, and produces a Codex role file that Codex can deserialize without startup warnings.

## Actual Behavior

The command reports that the Codex CLI is not found. When an affected worktree role file is present, Codex startup or `codex doctor --json` reports malformed role-definition warnings including `invalid transport`, `invalid type: map, expected a sequence`, `invalid type: string "policy-compliance-order", expected struct BundledSkillsConfig`, `invalid type: map, expected a boolean`, and `missing field enabled`.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The generated orchestrator role file includes role-local MCP server configuration that belongs in `.codex/config.toml`, and its skills configuration does not match Codex's structured `[skills] config = [{ name = "...", enabled = true }]` shape. The extension's executable resolver should also locate the Codex binary bundled with the installed ChatGPT/Codex extension when PATH does not contain `codex`.

## Proposed Fix / Validation Ideas

- [x] Update the source or bundled resource that owns `.codex/agents/orchestrator.toml`.
- [x] Add regression coverage for the expected role-file TOML shape.
- [x] Add or update worktree-session executable-resolution coverage for bundled Codex CLI discovery.
- [x] Validate an affected or fresh worktree with `codex doctor --json` and confirm startup warnings are absent.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
