# require-pr-author-agent-for-prs — Spec

- **Issue:** #231
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-24
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature

## 1. Problem Statement and Motivation

PR bodies must be produced by the `pr-author` skill, but the current enforcement does not guarantee this. The hook `enforce-pr-author-skill.ps1` (root `.claude/hooks/` and the bundled mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`) checks only three blocking conditions on `gh pr create` and `gh pr edit`:

- **Case A:** `gh pr create` with inline `--body` (no `--body-file`) — blocked.
- **Case B:** `gh pr create` with no body flag at all — blocked.
- **Case C:** `--body-file` present but `artifacts/pr_context.summary.txt` is absent — blocked.

The allowed path is `gh pr create/edit --body-file <file>` when `artifacts/pr_context.summary.txt` exists.

The hook does not check which actor issued the command. The main thread (orchestrator) can write a PR body file, ensure the context artifact exists, and call `gh pr create --body-file` directly, bypassing the intended `pr-author` skill workflow. Research confirms this is the mechanism used for PR #228.

Two gaps drive this feature:

1. **No `pr-author` agent exists in `.claude/agents/`.** The Claude ecosystem has a `pr-author` skill (`.claude/skills/pr-author/SKILL.md`) but no agent that runs it and opens the PR. The Codex and GitHub Copilot ecosystems each have a `pr-author` agent, but neither opens or updates the PR; they only generate the body text.
2. **The hook cannot attribute a `gh pr create` call to any specific agent.** It validates artifact presence only, not authorship.

The objective is to require all GitHub PR creation and PR body editing to be delegated to a dedicated `pr-author` agent that runs the `pr-author` skill, and to enforce this with hooks across the Claude, Codex, and GitHub Copilot ecosystems and their bundled copies.

## 2. Chosen Enforcement Mechanism

### 2.1 Mechanism: Authorization-Artifact Sentinel with TTL

The `pr-author` agent writes a short-lived authorization sentinel immediately before issuing any `gh pr create` or `gh pr edit --body*` command, and the PreToolUse hook verifies that sentinel before allowing the command.

**Sentinel file:** `artifacts/pr_author_authorization.json`

```json
{
  "issued_by": "pr-author",
  "issued_at": "<ISO-8601 UTC timestamp>",
  "head_sha": "<git rev-parse HEAD output>",
  "ttl_seconds": 120
}
```

The hook verifies that the sentinel is present, that `issued_by` is exactly `"pr-author"`, and that the sentinel has not expired (elapsed time since `issued_at` does not exceed `ttl_seconds`). If any check fails, the command is blocked.

The `head_sha` field is recorded for optional staleness defense; it may be compared against `git rev-parse HEAD` but is not required for the core acceptance path.

### 2.2 Rationale for Sentinel over Native Attribution

Native environment-variable attribution was evaluated and rejected. Research verified that no `CLAUDE_AGENT_NAME` or equivalent environment variable is set by Claude Code in the Bash PreToolUse context. The Bash tool payload (`CLAUDE_TOOL_INPUT`) contains only `{"command": "..."}`. The `subagent_type` field is present only in the Agent-tool PreToolUse payload, not when a subagent issues a Bash command. Therefore the runtime exposes no native signal at PreToolUse time for "which agent issued this Bash command."

The sentinel approach is consistent with the repository's established pattern of on-disk artifact-presence verification (`pr_context.summary.txt`, checkpoint files, plan files, research files). A timestamp compared to a clock seam is deterministic per hook invocation and requires no shared in-memory state. The 120-second TTL is sufficient for a single `gh` CLI invocation and short enough that a stale sentinel from a prior session expires before reuse.

### 2.3 Honest Enforcement Strength (Known Limitation)

This mechanism is a **policy guardrail, not a cryptographic control.** Any actor with Write access to `artifacts/` can forge the sentinel, because all agents share the same filesystem and `Write(/artifacts/**)` is a permitted tool. The mechanism prevents accidental bypass (the documented PR #228 pattern, where the orchestrator wrote the body file and called `gh pr create` directly) and requires a deliberate, documented act to circumvent.

The mechanism cannot be characterized as cryptographically non-bypassable. This is a direct consequence of the runtime constraint that Claude Code exposes no native agent-identity signal at PreToolUse time. All documentation that describes this enforcement MUST characterize it as a policy guardrail and MUST NOT describe it as a security boundary. This limitation is recorded as a known limitation in Section 8 (Risks).

## 3. Scope

### 3.1 In Scope

- **New `pr-author` agent:** `.claude/agents/pr-author.md` and its bundled mirror, defining the tools allowlist, the `pr-author` skill reference, the sentinel write/delete protocol, and SubagentStop validator wiring.
- **New SubagentStop validator hook:** `.claude/hooks/validate-pr-author-output.ps1` and its bundled mirror, verifying that the `pr-author` agent's final output reports a PR URL or PR number.
- **Strengthened PreToolUse hook:** `enforce-pr-author-skill.ps1` (root and bundled mirror) extended with new block Cases D, E, and F for missing, expired, malformed, and wrong-issuer authorization, layered on top of the unchanged Cases A, B, and C.
- **Settings wiring:** `.claude/settings.json` and its bundled mirror updated to allow `Agent(pr-author)` for the orchestrator and to register the `pr-author` SubagentStop matcher and validator hook.
- **Orchestrate skill documentation:** `.claude/skills/orchestrate/SKILL.md` (and bundled mirror if present) extended with a mandatory PR-creation delegation section.
- **Orchestrator agent documentation:** `.claude/agents/orchestrator.md` (and bundled mirror) updated to add `Agent(pr-author)` and to document the delegation requirement.
- **Cross-ecosystem mirrors and translations:** Codex (`.codex/agents/pr-author.toml`, new `.codex/hooks/enforce-pr-author-skill.ps1`, `config.toml` wiring) and GitHub Copilot (`.github/agents/pr-author.agent.md`, documentation-only).
- **Tests:** extension of `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` and a new `tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1`.

### 3.2 Out of Scope

- **A native runtime attribution signal.** Claude Code does not expose an agent-identity environment variable at Bash PreToolUse time. This feature does not introduce or simulate one.
- **Cryptographic non-bypassability of the sentinel.** The sentinel is a guardrail; making it tamper-proof is not in scope.
- **Migrating historical behavior.** Existing PRs and prior orchestration history are not retroactively modified.
- **GitHub Copilot mechanical hook enforcement.** The Copilot ecosystem has no PreToolUse hook surface; its change is documentation-only.

## 4. Functional Requirements

### FR-1: `pr-author` Agent Contract

A new agent `.claude/agents/pr-author.md` is added whose sole responsibility is to run the `pr-author` skill: consume the canonical PR-context bundle, produce the PR body, and open or update the PR.

- **Frontmatter** must include `name: pr-author`, a descriptive `description`, a `model`, a `skills` list containing `pr-author`, `memory: project`, and a SubagentStop hook entry wiring the matcher `"pr-author"` to `validate-pr-author-output.ps1`.
- **Tools allowlist** must include, at minimum: `Read`, `Bash(git log *)`, `Bash(git rev-parse *)`, `Bash(gh pr create *)`, `Bash(gh pr edit *)`, and `Write(/artifacts/**)`. The `Write(/artifacts/**)` entry is required so the agent can emit the sentinel.
- **Sentinel write/delete protocol** (in the agent system prompt): before any `gh pr create` or `gh pr edit --body*` command, the agent (a) runs `git rev-parse HEAD` to obtain `head_sha`, (b) writes `artifacts/pr_author_authorization.json` with `issued_by: "pr-author"`, `issued_at` as a UTC ISO-8601 timestamp, `head_sha`, and `ttl_seconds: 120`; then (c) issues the `gh` command immediately, within TTL; and (d) deletes `artifacts/pr_author_authorization.json` after the `gh` command completes (success or failure). The agent reports the resulting PR URL or PR number in its final output.
- A bundled mirror with identical content is added at `extensions/drm-copilot/resources/claude-customizations/.claude/agents/pr-author.md`.

### FR-2: Strengthened PreToolUse Hook Acceptance/Rejection Logic

`enforce-pr-author-skill.ps1` is extended to verify the authorization sentinel after the existing Case C check passes. The decision order is:

1. Evaluate Cases A and B first (unchanged). If matched, block.
2. If `--body-file` is present and the context artifact `artifacts/pr_context.summary.txt` is absent, block with Case C (unchanged).
3. If `--body-file` is present and the context artifact exists, evaluate the authorization sentinel:
   - **Case D — missing:** sentinel file absent or empty. Block with `PR_AGENT_AUTHORIZATION_MISSING`.
   - **Malformed:** sentinel present but not valid JSON, or missing/unparseable `issued_at`. Block with `PR_AGENT_AUTHORIZATION_MALFORMED`.
   - **Case E — invalid issuer:** sentinel present, valid JSON, but `issued_by != "pr-author"`. Block with `PR_AGENT_AUTHORIZATION_INVALID`.
   - **Case F — expired:** sentinel present, `issued_by == "pr-author"`, but elapsed time since `issued_at` exceeds `ttl_seconds`. Block with `PR_AGENT_AUTHORIZATION_EXPIRED`.
   - **Allow:** all checks pass (sentinel present, valid JSON, `issued_by == "pr-author"`, within TTL).
4. Commands with no body flag (for example `gh pr edit --title`) and read-only commands (`gh pr view`, `gh pr list`, `gh pr merge`, `gh pr checkout`) are unaffected and allowed.

The implementation must add injectable seam functions:

- `Get-PrAuthorAuthorizationContents` — returns the raw text of `artifacts/pr_author_authorization.json` (or null/empty when absent); injectable in tests.
- `Get-CurrentDateTimeUtc` — returns `[DateTime]::UtcNow`; injectable in tests for time-travel scenarios.
- `Test-PrAuthorAuthorization` — implements Cases D/E/F and the malformed cases; returns null (allow) or a block-reason string.

The TTL value (120 seconds) must be a named constant. The hook verifies the sentinel but does not delete it; cleanup is the agent's responsibility, and TTL expiry handles abandoned sentinels.

A bundled mirror receives the identical modification.

### FR-3: SubagentStop Validator Hook

A new SubagentStop hook `validate-pr-author-output.ps1` validates that the `pr-author` agent's final output confirms a PR was created or updated. It reads `CLAUDE_HOOK_INPUT.output` and checks for a PR URL (`github.com/.../pull/<n>`), a `PR #<n>` reference, or an equivalent `gh pr create`/`gh pr edit` confirmation. It exits 0 (allow) when such a signal is present and exits 1 (block) when output is empty, malformed JSON, or contains no PR URL/number. A bundled mirror receives identical content.

### FR-4: Backward Compatibility with Cases A/B/C

Cases A, B, and C remain unchanged and continue to block before the new authorization check is reached. The existing allowed path (`--body-file` + context artifact present) is extended — not replaced — by the new authorization check. Inline `--body` on `gh pr edit` continues to be blocked by Case A before the authorization check is evaluated. All pre-existing tests for Cases A/B/C and the prior allowed path must continue to pass unchanged.

### FR-5: Orchestrate Skill and Orchestrator Mandatory Delegation

The orchestrate skill is extended with a PR-creation delegation section specifying that the orchestrator must not call `gh pr create` directly, must first produce the PR-context artifact (`mcp__drm-copilot__collect_pr_context` or equivalent), and must then delegate PR creation to `Agent(pr-author)`. The orchestrator agent definition adds `Agent(pr-author)` to its tools list and documents the delegation requirement. Settings wiring adds `Agent(pr-author)` to the orchestrator allow list and registers the `pr-author` SubagentStop matcher and validator hook. Bundled mirrors receive matching changes.

## 5. Cross-Ecosystem Consistency Requirement

Enforcement and agent definitions must be consistent across the Claude, Codex, and GitHub Copilot ecosystems and their bundled copies:

- **Claude (root):** `.claude/agents/pr-author.md` (new), `.claude/hooks/enforce-pr-author-skill.ps1` (modified), `.claude/hooks/validate-pr-author-output.ps1` (new), `.claude/settings.json` (modified), `.claude/skills/orchestrate/SKILL.md` (modified), `.claude/agents/orchestrator.md` (modified).
- **Claude (bundled):** every Claude root change mirrored identically under `extensions/drm-copilot/resources/claude-customizations/.claude/`. The bundled orchestrate skill path must be verified during implementation; the root path is confirmed to exist.
- **Codex (bundled):** `.codex/agents/pr-author.toml` updated to include the sentinel-write step in its instructions; a new `.codex/hooks/enforce-pr-author-skill.ps1` added (currently absent), translated to the Codex hook format (`# Converted hook` header, same PowerShell body) and wired in `config.toml`.
- **GitHub Copilot (bundled):** `.github/agents/pr-author.agent.md` updated to document the sentinel protocol and to state that enforcement in the Copilot ecosystem is documentation-only because no PreToolUse hook surface exists.

Root and bundled copies must remain identical for the Claude ecosystem; Codex copies are translations of the equivalent Claude behavior into the Codex format.

## 6. Acceptance Criteria

Mapped to `issue.md`. These mirror the issue's acceptance criteria with the enforcement design resolved.

- [x] AC1: A `pr-author.md` agent exists under `.claude/agents/` and runs the `pr-author` skill, with a bundled Claude mirror and updated Codex (`pr-author.toml`) and GitHub Copilot (`pr-author.agent.md`) equivalents. The agent declares the required tools allowlist (including `Write(/artifacts/**)` and `Bash(gh pr create *)`/`Bash(gh pr edit *)`) and embeds the sentinel write/delete protocol.
- [x] AC2: No PR can be opened via `gh pr create --body-file` unless a valid `artifacts/pr_author_authorization.json` sentinel is present (`issued_by == "pr-author"`, within TTL). Missing, expired, wrong-issuer, or malformed sentinels are blocked by the PreToolUse hook (Cases D/E/F and malformed).
- [x] AC3: PR body edits via `gh pr edit --body-file` are subject to the same Cases D/E/F authorization check; `gh pr edit --body` (inline) remains blocked by Case A.
- [x] AC4: Enforcement and agent definitions are consistent across the Claude, Codex, and GitHub Copilot ecosystems and their bundled copies, with Claude root/bundled copies identical and the Codex hook added and wired.
- [x] AC5: Hook behavior is covered by tests — allowed: valid sentinel from the `pr-author` agent; blocked: missing/expired/wrong-issuer/malformed sentinel, inline body (Case A), no body flag (Case B), and missing context artifact (Case C). All pre-existing test cases continue to pass.
- [x] AC6: The orchestrate skill documents mandatory delegation to the `pr-author` agent for PR creation, and settings wiring permits `Agent(pr-author)` for the orchestrator.
- [x] AC7: The new SubagentStop validator hook (`validate-pr-author-output.ps1`) verifies the `pr-author` agent's output reports a PR URL or PR number, and is covered by tests.
- [x] AC8: All documentation describing the enforcement characterizes it as a policy guardrail, not a cryptographic or security control, and records the forgeability limitation.

## 7. Testing Requirements

Tests must satisfy the repository unit-test policy: deterministic, isolated, independent, no temporary files, and no reliance on real `gh` or wall-clock time. The hook tests must use injectable seams.

### 7.1 Strengthened PreToolUse hook (`enforce-pr-author-skill.Tests.ps1`, extended)

Use `Get-PrAuthorAuthorizationContents` (sentinel-read seam) and `Get-CurrentDateTimeUtc` (clock seam) as the injectable boundaries. No sentinel file is written to disk; the sentinel content is supplied through the read seam, and elapsed time is controlled through the clock seam.

| Context | Scenario | Expected |
|---|---|---|
| Case D — missing | `--body-file` + context present; sentinel read seam returns null/empty | block / `PR_AGENT_AUTHORIZATION_MISSING` |
| Case E — invalid issuer | sentinel `issued_by: "orchestrator"`, within TTL | block / `PR_AGENT_AUTHORIZATION_INVALID` |
| Case F — expired | sentinel `issued_by: "pr-author"`, `issued_at` 300 s before injected clock | block / `PR_AGENT_AUTHORIZATION_EXPIRED` |
| Malformed JSON | sentinel content is not valid JSON | block / `PR_AGENT_AUTHORIZATION_MALFORMED` |
| Malformed — missing `issued_at` | valid JSON, `issued_at` absent/unparseable | block / `PR_AGENT_AUTHORIZATION_MALFORMED` |
| Valid authorization | sentinel `issued_by: "pr-author"`, `issued_at` 5 s before injected clock, within TTL | allow |
| Backward compat — Case A | `gh pr create --body "inline"` | block (unchanged) |
| Backward compat — Case B | `gh pr create` with no body flag | block (unchanged) |
| Backward compat — Case C | `--body-file` + context artifact absent | block (unchanged) |
| Backward compat — `gh pr edit --title` | no body flag, no sentinel required | allow (unchanged) |

Coverage on `enforce-pr-author-skill.ps1` after changes must remain at line >= 85% and branch >= 75%.

### 7.2 SubagentStop validator hook (`validate-pr-author-output.Tests.ps1`, new)

| Scenario | Expected |
|---|---|
| Output contains PR URL (`github.com/.../pull/123`) | allow (exit 0) |
| Output contains a `gh pr create`/`gh pr edit` confirmation with a PR number | allow (exit 0) |
| Output empty | block (exit 1) |
| Output has no PR URL or number | block (exit 1) |
| `CLAUDE_HOOK_INPUT` empty | block (exit 1) |
| `CLAUDE_HOOK_INPUT` malformed JSON | block (exit 1) |

### 7.3 Determinism and No-Temp-File Constraints

- The clock seam (`Get-CurrentDateTimeUtc`) supplies all time used in TTL evaluation; no test reads wall-clock time and no test depends on `Start-Sleep`.
- The sentinel-read seam (`Get-PrAuthorAuthorizationContents`) supplies all sentinel content; no test writes the sentinel file to disk.
- No temporary files are created in any test, per repository unit-test policy.
- No external service or real `gh` invocation is exercised. No new integration tests are required; this feature is repository tooling only.

## 8. Risks and Backward-Compatibility Notes

### 8.1 Risks

- **Sentinel forgeability (known limitation).** Any actor with `Write(/artifacts/**)` access can forge `artifacts/pr_author_authorization.json`. The mechanism is a policy guardrail, not a cryptographic control. It stops the accidental PR #228-style bypass and requires a deliberate, documented act to circumvent. Mitigation: characterize the enforcement honestly in all documentation; restrict `Write(/artifacts/**)` from being broadly granted where avoidable; rely on the SubagentStop validator and orchestrate-skill delegation policy as complementary controls. This limitation follows directly from the absence of a native agent-identity signal at PreToolUse time.
- **Orchestration deadlock.** Because the strengthened hook blocks direct `gh pr create` by the main thread, the orchestrator must be able to delegate to the `pr-author` agent to satisfy the gate. Mitigation: `Agent(pr-author)` must be in the orchestrator allow list and documented as mandatory in the orchestrate skill; failure to wire this would prevent any PR from being created.
- **Stale sentinel reuse.** A sentinel left on disk from a prior session could in principle be reused. Mitigation: the 120-second TTL expires stale sentinels; the agent deletes the sentinel after use; the optional `head_sha` field provides additional staleness defense.
- **Cross-ecosystem drift.** Root and bundled Claude copies, and Codex translations, can fall out of sync. Mitigation: the change inventory enumerates every paired file; root/bundled Claude copies must be identical.
- **Copilot enforcement gap.** The GitHub Copilot ecosystem has no hook surface, so its control is documentation-only. Mitigation: document the sentinel protocol in `pr-author.agent.md` and state the documentation-only nature explicitly.

### 8.2 Backward Compatibility

- Cases A, B, and C are preserved unchanged and continue to block before the new authorization check.
- The prior allowed path (`--body-file` + context artifact present) is extended, not replaced; legitimate PR creation now additionally requires a valid sentinel, which the `pr-author` agent emits automatically.
- Commands with no body flag and read-only `gh pr` subcommands are unaffected.
- All pre-existing tests must continue to pass without modification to their expectations.
