# PR-Author Agent Enforcement Research

- **Feature:** require-pr-author-agent-for-prs (Issue #231)
- **Research Date:** 2026-06-24
- **Research Path:** docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/research/2026-06-24T15-45-pr-author-agent-enforcement-research.md

---

## 1. Current State Analysis

### 1.1 Existing Hook: `enforce-pr-author-skill.ps1`

Source: `.claude/hooks/enforce-pr-author-skill.ps1` (root) and mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`.

Current enforcement checks three blocking conditions on `gh pr create` and `gh pr edit` commands:

- **Case A:** `gh pr create` with inline `--body` (no `--body-file`) — blocked.
- **Case B:** `gh pr create` with no body flag at all — blocked.
- **Case C:** `--body-file` present but `artifacts/pr_context.summary.txt` is absent — blocked.

Allowed: `gh pr create/edit --body-file <file>` when `artifacts/pr_context.summary.txt` exists.

**Critical gap:** The hook does not check WHO is invoking the command. The main thread (orchestrator) can write a PR body file, ensure the context artifact exists, and call `gh pr create --body-file` successfully — bypassing the intended pr-author skill workflow. This is confirmed as the mechanism for PR #228's bypass.

### 1.2 Environment Variables Available at PreToolUse Time

Verified from reading all hooks under `.claude/hooks/`:

| Variable | Source | Contents |
|---|---|---|
| `CLAUDE_TOOL_INPUT` | Set by Claude Code | JSON payload for the tool being intercepted. For Bash: `{"command": "..."}`. For Agent tool: `{"subagent_type": "...", "prompt": "..."}`. |
| `CLAUDE_HOOK_INPUT` | Set by Claude Code | JSON payload for SubagentStop hooks: `{"output": "..."}` containing the agent's final text output. |
| `CLAUDE_SESSION_ID` | Set by Claude Code | Opaque session identifier used for per-session state files (verified in `enforce-powershell-batch-budget.ps1` lines 218-220). |

**No `CLAUDE_AGENT_NAME` or equivalent env var is set by Claude Code in the Bash PreToolUse context.** Verified by grepping all hooks for `CLAUDE_AGENT`, `agent_name`, `invoking_agent`, `parent_agent` — zero matches except for `subagent_type` in the Agent tool payload.

**`subagent_type` field:** The `enforce-prd-feature-before-planner.ps1` hook reads `$toolInput.subagent_type` from `CLAUDE_TOOL_INPUT`, but this field is present only in the **Agent tool** (PreToolUse for the `Agent(...)` matcher), not in the **Bash tool** payload. When a subagent issues a Bash command, the hook receives `{"command": "..."}` only — with no indication of which agent issued it. This is the root architectural constraint.

### 1.3 Existing `subagent_type` Pattern (Agent Tool PreToolUse Only)

The `enforce-prd-feature-before-planner.ps1` hook intercepts the orchestrator's `Agent(atomic-planner)` tool call. In that context `CLAUDE_TOOL_INPUT` contains `{"subagent_type": "atomic-planner", "prompt": "..."}`. This is NOT available when a subagent runs a Bash command.

### 1.4 SubagentStop Hook Identity Signal

SubagentStop hooks are scoped by a `matcher` field that names the agent (e.g., `"task-researcher"`, `"feature-review"`). The `CLAUDE_HOOK_INPUT` at SubagentStop time contains `{"output": "..."}`. The agent identity is encoded in the hook registration, not the payload. This cannot be leveraged for PreToolUse decisions.

### 1.5 Existing `pr-author` Representations

- **Claude skill:** `.claude/skills/pr-author/SKILL.md` — defines PR body authoring workflow, `allowed-tools: [Read, "Bash(git log *)"]`. The skill does NOT include `Bash(gh pr create *)`.
- **Claude agent:** Absent from `.claude/agents/`. No `pr-author.md` exists.
- **Codex agent:** `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/pr-author.toml` — exists, instructs the agent to generate the PR body in a fenced markdown block only; does NOT open the PR itself.
- **GitHub Copilot agent:** `extensions/drm-copilot/resources/customizations/.github/agents/pr-author.agent.md` — exists, full PR body generation instructions; does NOT issue `gh pr create`.

The Codex and Copilot ecosystem already have a `pr-author` agent, but neither opens the PR. The Claude ecosystem has no agent at all.

### 1.6 Test Coverage

Test file: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`

Tests cover: Cases A, B, C (blocked); allowed `--body-file` with context present; helper function behavior; script entrypoint end-to-end. Tests do NOT cover agent attribution — no test for "allowed when pr-author agent" vs "blocked when main thread."

---

## 2. Attribution Mechanism: Candidate Approaches

### 2.1 Native Environment Variable Attribution (Rejected)

**Description:** Rely on a Claude Code–provided env var (e.g., `CLAUDE_AGENT_NAME`) to identify the active agent in the Bash PreToolUse hook.

**Finding:** No such env var exists in the Claude Code runtime as observed in this codebase. `CLAUDE_SESSION_ID` is the only agent-neutral session identifier available. The Bash tool payload contains only `{"command": "..."}`. There is no native attribution signal for "which agent issued this Bash command."

**Verdict:** Not available in the current runtime. Cannot be used.

### 2.2 Authorization-Artifact Mechanism (Recommended)

**Description:** The `pr-author` agent writes a short-lived authorization sentinel file (`artifacts/pr_author_authorization.json`) before issuing any `gh pr create` or `gh pr edit --body*` command. The PreToolUse hook reads this file and allows the command only if the file is present and valid. After the command, the agent removes the file (or the hook invalidates it).

**Recommended design:**

**Sentinel file:** `artifacts/pr_author_authorization.json`

```json
{
  "issued_by": "pr-author",
  "issued_at": "<ISO-8601 timestamp>",
  "head_sha": "<git rev-parse HEAD output>",
  "ttl_seconds": 120
}
```

**Hook logic additions to `Get-PrAuthorBypassReason`:**

1. When `gh pr create` or `gh pr edit --body*` is intercepted AND `--body-file` is present AND the context artifact exists (passing existing Case C check), additionally:
2. Read `artifacts/pr_author_authorization.json`. If absent: block with `PR_AGENT_AUTHORIZATION_MISSING`.
3. Parse the JSON. If `issued_by` is not `"pr-author"`: block.
4. Compare `issued_at` against current time. If elapsed seconds exceed `ttl_seconds` (120): block with `PR_AGENT_AUTHORIZATION_EXPIRED`.
5. Compare `head_sha` against `git rev-parse HEAD`. If mismatch: block with `PR_AGENT_AUTHORIZATION_STALE` (optional extra defense; may be omitted for simplicity).
6. If all checks pass: allow.

**`pr-author` agent write protocol:**

Before issuing `gh pr create` or `gh pr edit --body-file`:

1. Write `artifacts/pr_author_authorization.json` with current timestamp and current HEAD SHA.
2. Issue the `gh` command immediately (within TTL).
3. After the `gh` command completes, delete `artifacts/pr_author_authorization.json`.

**Why timestamp + TTL instead of a nonce:** The hook runs as a process and has no in-memory state. A timestamp compared to `Get-Date` is deterministic per invocation without requiring a shared secret store. A 120-second TTL is sufficient for a single `gh` CLI call and short enough that a stale sentinel from a previous session is expired before it could be reused.

**Enforcement strength:** This is a guardrail, not a cryptographic control. The main thread or another agent can write the sentinel file because all agents share the same filesystem and `Write(/artifacts/**)` is permitted. The mechanism stops accidental bypass (the documented PR #228 scenario) and requires a deliberate and documented act of circumvention to bypass. The enforcement statement in all documentation must clearly characterize this as a policy guardrail, not a security boundary.

**Advantages:**
- No dependency on a missing runtime feature.
- Consistent with the repo's existing artifact-on-disk verification pattern (every hook validates artifact presence on disk: `pr_context.summary.txt`, checkpoint files, plan files, research files).
- Testable without real `gh` calls: the hook function `Get-PrContextArtifactExistence` pattern can be replicated as `Get-PrAuthorAuthorizationContents` (injectable in tests).
- Small, minimal extension of the current hook structure.

**Limitations:**
- Not cryptographically non-bypassable: any agent with Write access to `artifacts/` can create the sentinel. This must be documented.
- Requires the `pr-author` agent definition to include `Write(/artifacts/**)` in its tools list.
- The hook needs a clock seam (wrapper for `Get-Date`) to remain deterministic in tests.

### Rejected Alternative Summary

Native env-var attribution was rejected because `CLAUDE_AGENT_NAME` or equivalent does not exist in the Claude Code runtime. The `CLAUDE_TOOL_INPUT.subagent_type` field is only present for the `Agent` tool type, not for `Bash` commands issued by a subagent.

---

## 3. Behavior Semantics

### 3.1 Allowed Flows

- `pr-author` agent writes `artifacts/pr_author_authorization.json` (issued_by: pr-author, within TTL), then issues `gh pr create --body-file <file>` with `artifacts/pr_context.summary.txt` present. Hook: allow.
- `pr-author` agent issues `gh pr edit --body-file <file>` under same conditions. Hook: allow.
- Any agent or main thread issues `gh pr edit --title foo` (no body flag). Hook: allow (unchanged from current behavior).
- Any agent or main thread issues `gh pr view`, `gh pr list`, `gh pr merge`, `gh pr checkout`. Hook: allow.

### 3.2 Blocked Flows (New Cases in Addition to Existing A/B/C)

- **Case D:** `gh pr create/edit --body-file` command issued but `artifacts/pr_author_authorization.json` is absent. Block: `PR_AGENT_AUTHORIZATION_MISSING`.
- **Case E:** Authorization file present but `issued_by != "pr-author"`. Block: `PR_AGENT_AUTHORIZATION_INVALID`.
- **Case F:** Authorization file present but `issued_at` is more than `ttl_seconds` ago. Block: `PR_AGENT_AUTHORIZATION_EXPIRED`.

Cases A, B, C from the current hook remain unchanged and continue to block before the new Cases D/E/F are evaluated. The existing `--body-file + context present` path is extended by the new authorization check.

### 3.3 Edge Cases

- Authorization file is malformed JSON: block with `PR_AGENT_AUTHORIZATION_MALFORMED`.
- Authorization file is present but `issued_at` field is missing or unparseable: block with `PR_AGENT_AUTHORIZATION_MALFORMED`.
- `gh pr edit` with `--body` (inline): still blocked by Case A before reaching authorization check.
- `gh pr create` with no body flags: still blocked by Case B.
- Context artifact absent: still blocked by Case C.
- `pr-author` agent writes sentinel and then `gh` command is delayed past TTL: hook blocks with `PR_AGENT_AUTHORIZATION_EXPIRED`; agent must re-write sentinel and retry.

---

## 4. Requirements Mapping (Acceptance Criteria → Concrete Design)

### AC1: `pr-author.md` agent under `.claude/agents/`

**New file:** `.claude/agents/pr-author.md`

Required frontmatter fields (matching the repo agent contract from `task-researcher.md`, `feature-review.md`, `atomic-executor.md`):

```yaml
---
name: pr-author
description: PR authoring specialist that runs the pr-author skill to produce a GitHub PR body from the canonical PR-context bundle, then opens or updates the PR using gh pr create / gh pr edit.
model: sonnet
tools:
  - Read
  - "Bash(git log *)"
  - "Bash(git rev-parse *)"
  - "Bash(gh pr create *)"
  - "Bash(gh pr edit *)"
  - "Write(/artifacts/**)"
skills:
  - pr-author
memory: project
hooks:
  SubagentStop:
    - matcher: "pr-author"
      hooks:
        - type: command
          command: pwsh -NoProfile -File .claude/hooks/validate-pr-author-output.ps1
---
```

Body: Agent system prompt instructing it to run the `pr-author` skill, write the sentinel before the `gh` command, delete the sentinel after, and report the PR URL in the final output.

**Mirror:** `extensions/drm-copilot/resources/claude-customizations/.claude/agents/pr-author.md` — identical content.

### AC2: No `gh pr create` except by `pr-author` agent

Modify `.claude/hooks/enforce-pr-author-skill.ps1` to add authorization-artifact check as Cases D/E/F described in Section 3.2.

Add injectable wrapper functions:
- `Get-PrAuthorAuthorizationContents` — reads `artifacts/pr_author_authorization.json` raw text, injectable for tests.
- `Get-CurrentDateTimeUtc` — returns `[DateTime]::UtcNow`, injectable for tests.
- `Test-PrAuthorAuthorization` — implements Cases D/E/F, returns null (allow) or a block reason string.

**Mirror:** Same modification to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`.

### AC3: PR body edits restricted to `pr-author` agent

Covered by Cases D/E/F applied to `gh pr edit --body-file` commands (identical code path in `Get-PrAuthorBypassReason`). The existing `gh pr edit` with `--body` (inline) continues to be blocked by Case A.

### AC4: Consistent enforcement across ecosystems

**Codex ecosystem:** `.codex/hooks/` does not currently contain an `enforce-pr-author-skill.ps1` hook. The Codex `config.toml` does not reference it. However, Codex has a `pr-author.toml` agent. A Codex hook must be added if Codex agents can issue `gh pr create` commands. The Codex agent definition in `.codex/agents/pr-author.toml` should be updated to include the sentinel-write step, and a hook should be added at `.codex/hooks/enforce-pr-author-skill.ps1` wired via `config.toml`.

**GitHub Copilot ecosystem:** The `.github/agents/pr-author.agent.md` file exists but does not include `gh pr create` in its instructions. No Copilot hook mechanism is available for `gh` command interception. The Copilot agent file should be updated to document the sentinel protocol and restrict PR creation to the agent's workflow. Hook enforcement is not applicable in the Copilot ecosystem (no PreToolUse hook surface).

**Root vs bundled sync:** Root `.claude/` and `extensions/drm-copilot/resources/claude-customizations/.claude/` must be kept identical. Both must receive every change.

### AC5: Hook behavior covered by tests

Modify `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` to add:
- Context "pr-author authorization — Case D (missing authorization file)": block.
- Context "pr-author authorization — Case E (invalid issued_by)": block.
- Context "pr-author authorization — Case F (expired TTL)": block.
- Context "pr-author authorization — Case D malformed JSON": block.
- Context "pr-author authorization — valid sentinel from pr-author agent": allow.
- Existing allowed/blocked test cases must continue to pass unchanged.

### AC6: Orchestrate skill documents mandatory delegation to `pr-author` agent

Modify `.claude/skills/orchestrate/SKILL.md` (and its mirror) to add a `## PR Creation Delegation` section specifying:
- The orchestrator must not call `gh pr create` directly.
- The orchestrator must delegate to the `pr-author` agent for PR creation.
- The orchestrator must call `mcp__drm-copilot__collect_pr_context` first to produce the context artifact.
- Then delegate `Agent(pr-author)`.

Also update:
- `.claude/settings.json`: add `Agent(pr-author)` to the orchestrator's allow list.
- `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`: same.

### New SubagentStop hook for `pr-author`

**New file:** `.claude/hooks/validate-pr-author-output.ps1`

Validates that the `pr-author` agent's final output contains a PR URL or PR number, confirming the PR was actually created or updated. Reads `CLAUDE_HOOK_INPUT.output` and checks for a pattern like `github.com/.*/pull/\d+` or `PR #\d+` or a `gh pr create` confirmation message.

**Mirror:** `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1`.

The `SubagentStop` matcher `"pr-author"` must also be added to `.claude/settings.json`'s `SubagentStop` hooks section and its mirror.

---

## 5. Per-File Change Inventory

### New Files

| File | Change |
|---|---|
| `.claude/agents/pr-author.md` | New: pr-author agent definition with tools allowlist, pr-author skill, SubagentStop hook wiring. |
| `.claude/hooks/validate-pr-author-output.ps1` | New: SubagentStop hook verifying pr-author output contains PR URL/number. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/pr-author.md` | New: mirror of root agent file. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1` | New: mirror of root hook file. |

### Modified Files

| File | Change |
|---|---|
| `.claude/hooks/enforce-pr-author-skill.ps1` | Add `Get-PrAuthorAuthorizationContents`, `Get-CurrentDateTimeUtc`, `Test-PrAuthorAuthorization` functions; extend `Get-PrAuthorBypassReason` to call `Test-PrAuthorAuthorization` for Cases D/E/F; update `.SYNOPSIS` and `.DESCRIPTION`. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` | Mirror of root hook change. |
| `.claude/settings.json` | Add `Agent(pr-author)` to orchestrator allow list; add `pr-author` to SubagentStop matcher pattern; add SubagentStop hook entry for `validate-pr-author-output.ps1`. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` | Mirror of root settings change. |
| `.claude/skills/orchestrate/SKILL.md` | Add `## PR Creation Delegation` section documenting mandatory agent delegation. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` | Mirror of skill change (if it exists — verify path). |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/pr-author.toml` | Update to include sentinel-write step in the developer_instructions. |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` | New (currently absent): add Codex hook wired in `config.toml`. |
| `extensions/drm-copilot/resources/customizations/.github/agents/pr-author.agent.md` | Update: add authorization sentinel protocol to instructions; note that enforcement is documentation-only in Copilot (no hook surface). |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | Add new test contexts for Cases D/E/F and valid authorization. |
| `.claude/agents/orchestrator.md` | Add `Agent(pr-author)` to tools list; document delegation requirement. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md` | Mirror. |

### Verify Path for Bundled Orchestrate Skill

The path `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` should be verified during implementation. The bundled skills list shows `pr-author/SKILL.md` exists there but `orchestrate` was not confirmed in the truncated directory listing. The root `.claude/skills/orchestrate/SKILL.md` is confirmed to exist.

---

## 6. Recommended Attribution Mechanism

**Recommendation: Authorization-Artifact (sentinel file) with TTL.**

### Hook Logic Sketch (non-code description)

```
Get-PrAuthorBypassReason (extended):
  existing Cases A, B checked first (unchanged)
  if --body-file present:
    if context artifact absent: return Case C block (unchanged)
    call Test-PrAuthorAuthorization
    if Test-PrAuthorAuthorization returns non-null: return that block reason
  return null (allow)

Test-PrAuthorAuthorization:
  read artifacts/pr_author_authorization.json via injectable Get-PrAuthorAuthorizationContents
  if file absent or empty: return "PR_AGENT_AUTHORIZATION_MISSING: ..."
  parse JSON; if fails: return "PR_AGENT_AUTHORIZATION_MALFORMED: ..."
  if issued_by != "pr-author": return "PR_AGENT_AUTHORIZATION_INVALID: ..."
  parse issued_at; if fails: return "PR_AGENT_AUTHORIZATION_MALFORMED: ..."
  compute elapsed = Get-CurrentDateTimeUtc - issued_at
  if elapsed.TotalSeconds > ttl_seconds: return "PR_AGENT_AUTHORIZATION_EXPIRED: ..."
  return null (allow)
```

### `pr-author` Agent Protocol (embedded in agent system prompt)

1. Before any `gh pr create` or `gh pr edit --body*` command:
   a. Run `git rev-parse HEAD` to get `head_sha`.
   b. Write `artifacts/pr_author_authorization.json` with `issued_by: "pr-author"`, `issued_at: <UTC ISO-8601>`, `head_sha: <sha>`, `ttl_seconds: 120`.
2. Immediately issue the `gh` command.
3. After the `gh` command completes (success or failure), delete `artifacts/pr_author_authorization.json`.

### Enforcement Strength Statement

This mechanism is a policy guardrail. It prevents accidental bypass (the documented PR #228 pattern where the orchestrator wrote the body file and called `gh pr create` directly). It does not prevent a deliberate actor — a main-thread prompt or another agent — from writing the sentinel file, because all agents share the same filesystem and `Write(/artifacts/**)` is a permitted tool. The mechanism provides meaningful attribution enforcement in the intended scenario (AI agent orchestration where agents follow their system prompts) and is consistent with the repo's existing artifact-presence enforcement pattern. It cannot be characterized as cryptographically non-bypassable.

---

## 7. Testing Strategy

### 7.1 Tests for `enforce-pr-author-skill.ps1` (extend existing `enforce-pr-author-skill.Tests.ps1`)

Tests must use injectable seams matching the PowerShell DI rules. Specifically:

- `Get-PrAuthorAuthorizationContents` is a wrapper function that reads the sentinel file text (injectable via `Mock`).
- `Get-CurrentDateTimeUtc` is a wrapper that returns `[DateTime]::UtcNow` (injectable for time-travel tests).

**New test contexts to add:**

| Context | Scenario | Expected |
|---|---|---|
| Authorization missing (Case D) | `--body-file` + context present, sentinel file absent (`Get-PrAuthorAuthorizationContents` returns `$null`/empty) | block / `PR_AGENT_AUTHORIZATION_MISSING` |
| Authorization invalid issuer (Case E) | Sentinel present with `issued_by: "orchestrator"`, within TTL | block / `PR_AGENT_AUTHORIZATION_INVALID` |
| Authorization expired (Case F) | Sentinel present with `issued_by: "pr-author"`, `issued_at` 300 seconds ago | block / `PR_AGENT_AUTHORIZATION_EXPIRED` |
| Authorization malformed JSON | Sentinel file contains `{not-json` | block / `PR_AGENT_AUTHORIZATION_MALFORMED` |
| Authorization malformed (missing issued_at) | Sentinel present, `issued_at` field absent | block / `PR_AGENT_AUTHORIZATION_MALFORMED` |
| Valid authorization — pr-author agent | Sentinel present, `issued_by: "pr-author"`, `issued_at` 5 seconds ago, within TTL | allow |
| Backward compat: `gh pr edit --title` | No body flag, no sentinel needed | allow (unchanged) |
| Backward compat: Case A inline body | `--body "inline"` | block / `PR_AUTHOR_SKILL_BLOCKED` (unchanged) |
| Backward compat: Case B no body flag | `gh pr create` (no body) | block / `PR_AUTHOR_SKILL_BLOCKED` (unchanged) |
| Backward compat: Case C context absent | `--body-file` + no context artifact | block / `PR_CONTEXT_MISSING` (unchanged) |

**Coverage requirement:** Line coverage >= 85%, branch coverage >= 75% on `enforce-pr-author-skill.ps1` after changes. The existing test suite currently covers the original logic; the new authorization logic must reach the same thresholds.

### 7.2 Tests for `validate-pr-author-output.ps1` (new file)

Test location: `tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1`

| Scenario | Expected |
|---|---|
| Output contains PR URL (`github.com/.../pull/123`) | allow (exit 0) |
| Output contains `gh pr create` confirmation line with PR number | allow |
| Output is empty | block (exit 1) |
| Output has no PR URL or number | block (exit 1) |
| `CLAUDE_HOOK_INPUT` is empty | block (exit 1) |
| `CLAUDE_HOOK_INPUT` is malformed JSON | exit 1 |

### 7.3 No New Integration Tests Required

This feature is purely repository tooling (hooks, agents, skills). No external service integration is touched. No integration test beyond the hook unit tests is required.

---

## 8. Cross-Ecosystem File Inventory Summary

| Ecosystem | Files Requiring Changes |
|---|---|
| Claude (root) | `.claude/agents/pr-author.md` (new), `.claude/hooks/enforce-pr-author-skill.ps1` (modify), `.claude/hooks/validate-pr-author-output.ps1` (new), `.claude/settings.json` (modify), `.claude/skills/orchestrate/SKILL.md` (modify), `.claude/agents/orchestrator.md` (modify) |
| Claude (bundled) | All above mirrored under `extensions/drm-copilot/resources/claude-customizations/.claude/` |
| Codex (bundled) | `.codex/agents/pr-author.toml` (modify), `.codex/hooks/enforce-pr-author-skill.ps1` (new), `config.toml` (modify to wire hook) |
| GitHub Copilot (bundled) | `.github/agents/pr-author.agent.md` (modify — documentation only, no hook surface) |
| Tests | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (modify), `tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1` (new) |

---

## 9. Decisions and Rationale

**Decision: Authorization artifact over env-var attribution.**
Native env-var attribution does not exist in the Claude Code runtime. The authorization-artifact approach is the only viable mechanism. It matches the repo's established pattern of on-disk artifact verification.

**Decision: 120-second TTL.**
Sufficient for a single `gh` CLI invocation (typically completes in 2-10 seconds). Short enough to expire stale sentinels from prior sessions without requiring explicit cleanup on cold-start. The value should be a named constant in the hook script.

**Decision: Sentinel deletion is agent-protocol, not hook-enforced.**
The hook verifies the sentinel exists and is fresh before allowing the command; it does not consume or delete it. The agent is responsible for cleanup. If the agent crashes mid-operation, the sentinel expires by TTL in the next hook call.

**Decision: Codex hook is a new addition (not previously present).**
The Codex hooks directory does not contain `enforce-pr-author-skill.ps1`. This must be created as part of this feature. Wiring in `config.toml` requires a hook invocation mechanism consistent with Codex's hook surface. The Codex hook format uses a `# Converted hook` header and the same PowerShell body (as seen in the existing Codex hooks).

**Decision: GitHub Copilot enforcement is documentation-only.**
The GitHub Copilot ecosystem has no PreToolUse hook surface equivalent to Claude Code's hook system. The `pr-author.agent.md` file is updated to document the sentinel protocol, but enforcement cannot be mechanically applied there.
