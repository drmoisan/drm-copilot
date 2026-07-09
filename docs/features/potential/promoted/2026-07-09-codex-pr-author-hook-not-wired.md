# codex-pr-author-hook-not-wired (Issue #335)

- Date captured: 2026-07-09
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/codex-pr-author-hook-not-wired/ (Issue #335)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #335
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/335
- Last Updated: 2026-07-09
## Summary

The bundled Codex mirror of the `enforce-pr-author-skill.ps1` hook exists but is not wired into any `[[hooks.PreToolUse]]` entry in either the bundled `codex-and-agents-customizations/.codex/config.toml` or the root `.codex/config.toml`, so Codex-ecosystem agents calling `gh pr create` / `gh pr edit` are not protected by the sentinel check that the Claude-ecosystem hook enforces.

## Environment

- OS/version: N/A (configuration/wiring gap, not environment-specific)
- Python version: N/A
- Command/flags used: `gh pr create` / `gh pr edit --body*` issued by a Codex-ecosystem agent
- Data source or fixture: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`, `.codex/config.toml`

## Steps to Reproduce

1. Inspect `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` and confirm `enforce-pr-author-skill.ps1` exists as a hook file under the sibling `hooks/` path but has no matching `[[hooks.PreToolUse]]` entry.
2. Inspect the root `.codex/config.toml` and confirm neither the hook file nor any wiring for it is present.
3. In a Codex-ecosystem session (or a consumer repo that received this push-down bundle), invoke `gh pr create` / `gh pr edit --body*` and observe that no PreToolUse hook intercepts the call.

## Expected Behavior

A Codex-ecosystem agent calling `gh pr create` or `gh pr edit --body*` should be intercepted by the same PR-authorship sentinel enforcement that the Claude-ecosystem `enforce-pr-author-skill.ps1` PreToolUse hook provides, so bypassing the `pr-author` handoff is blocked consistently across both ecosystems.

## Actual Behavior

The Codex mirror hook file is present and current but has no runtime effect because no `[[hooks.PreToolUse]]` entry in `config.toml` references it, in either the bundled template or the root repository's own `.codex/` configuration.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: N/A — confirmed by direct file inspection, not a runtime log.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

Identified as a known follow-up gap during feature #272 (`local-preflight-orchestrator-state-gate`): see `docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/evidence/other/follow-up-codex-wiring-gap.md` ("the Codex hook body receives the contract-parity edit in this feature's scope, but it has no runtime effect in the Codex ecosystem as currently configured, because nothing invokes it") and `docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/spec.md:54,229` ("The Codex mirror hook is currently an orphaned artifact... Codex mirror re-wiring gap remains unresolved."). The gap was explicitly deferred at that time and never separately tracked. Confirmed still present via `docs/research/2026-07-09-remaining-technical-debt-audit.md`.

## Proposed Fix / Validation Ideas

- [ ] Add a `[[hooks.PreToolUse]]` entry in `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` referencing `enforce-pr-author-skill.ps1`, matching the matcher/pattern used by the Claude-ecosystem hook wiring.
- [ ] Decide whether the root repository's own `.codex/config.toml` should also carry the hook and wiring (the root repo currently has neither), and add it if so.
- [ ] Integration scenario to retest: a Codex-ecosystem `gh pr create` call without a valid `pr-author` receipt should be blocked with the same `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`-style message as the Claude-ecosystem hook.
- [ ] Manual verification notes: confirm the push-down bundling step that copies `codex-and-agents-customizations/.codex/` into consumer repos carries the corrected wiring.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
