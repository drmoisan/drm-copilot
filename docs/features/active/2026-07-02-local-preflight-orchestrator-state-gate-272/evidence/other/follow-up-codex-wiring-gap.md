# Follow-up: Codex `.codex/config.toml` Re-wiring Gap — Issue #272

Timestamp: 2026-07-02T19-45

Per spec.md's Risks & Mitigations ("Codex mirror re-wiring gap remains unresolved"), `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` (now hardened by this feature with the same `Invoke-OrchestratorStatePreflight` check as the root `.claude` hook) is **not wired into any `[[hooks.PreToolUse]]` entry** in `.codex/config.toml`. This is a pre-existing condition (confirmed by research, not introduced by issue #272): the Codex hook body receives the contract-parity edit in this feature's scope, but it has no runtime effect in the Codex ecosystem as currently configured, because nothing invokes it.

Explicitly out of scope for issue #272 (per spec.md's Non-Goals: "Re-wiring `.codex/config.toml`'s `[[hooks.PreToolUse]]` list to reference `enforce-pr-author-skill.ps1`").

**Recommendation:** track re-wiring `.codex/config.toml` to reference `enforce-pr-author-skill.ps1` (matcher equivalent to `Bash`) as a separate follow-up issue, so `gh pr create`/`gh pr edit` calls made from within the Codex ecosystem (if any exist) are actually protected by this same local orchestrator-state preflight enforcement.
