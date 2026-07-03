# Codex Native Ecosystem Research

**Timestamp:** 2026-06-16T13-32  
**Purpose:** Map Claude Code customization primitives onto Codex-native equivalents with equivalent enforceability for skill authors.

---

## Sources

All findings are grounded in the following verified authoritative sources retrieved during this session:

- `https://developers.openai.com/codex/guides/agents-md` — AGENTS.md discovery and merging
- `https://developers.openai.com/codex/config-reference` — config.toml full schema
- `https://developers.openai.com/codex/hooks` — hooks documentation
- `https://developers.openai.com/codex/concepts/sandboxing` — sandbox modes and OS mechanisms
- `https://developers.openai.com/codex/concepts/sandboxing/auto-review` — auto-review mechanism
- `https://developers.openai.com/codex/agent-approvals-security` — approval policies
- `https://developers.openai.com/codex/skills` — skills documentation
- `https://developers.openai.com/codex/subagents` and `https://developers.openai.com/codex/concepts/subagents` — subagents
- `https://developers.openai.com/codex/mcp` — MCP server configuration
- `https://developers.openai.com/codex/noninteractive` — codex exec / non-interactive mode
- `https://developers.openai.com/codex/github-action` — GitHub Action integration
- `https://developers.openai.com/codex/cli/reference` — CLI flags reference
- `https://developers.openai.com/codex/environment-variables` — environment variables
- `https://developers.openai.com/codex/concepts/customization` — customization surfaces
- `https://developers.openai.com/codex/glossary` — authoritative terminology

---

## A. AGENTS.md — Hierarchical Instruction Discovery

### Discovery Order

Codex builds an instruction chain from three scopes, concatenated from root down (files closer to `$CWD` appear later and therefore override earlier content):

1. **Global scope** — `~/.codex/AGENTS.override.md` (highest priority if present), otherwise `~/.codex/AGENTS.md`.
2. **Project scope** — Directory walk from Git root toward `$CWD`. At each directory, Codex loads `AGENTS.override.md` if present; otherwise `AGENTS.md`. At most one file per directory is included.
3. **Fallback filenames** — Additional filenames treated as instruction files, configured via `project_doc_fallback_filenames` in `config.toml` (e.g., `TEAM_GUIDE.md`).

### Merging Semantics

Files are concatenated with blank-line separators. Precedence is positional: later content (closer to `$CWD`) overrides earlier content by appearing after it in the combined prompt. This is a prompt-concatenation strategy, not a structured merge.

### Size Limit

`project_doc_max_bytes` (default: 32 KiB) stops adding files once the combined size reaches the threshold.

### Path-Scoped Instructions (Analogue to Claude `paths:` YAML frontmatter)

There is no frontmatter `paths:` glob mechanism. Nested `AGENTS.md` files in subdirectories achieve directory-scoped instructions: a file at `payments/AGENTS.md` applies only when `$CWD` is within `payments/`. An `AGENTS.override.md` at that subdirectory replaces (not appends) the parent directory's file for that level.

**Capability gap vs. Claude:** Claude `paths:` rules apply file-extension-level glob scoping (e.g., `**/*.py`) regardless of `$CWD`. Codex path scoping is directory-presence-based. There is no glob-pattern file-extension scoping equivalent.

### Precedence Summary

```
~/.codex/AGENTS.override.md  >  ~/.codex/AGENTS.md
  > <git-root>/AGENTS.override.md  >  <git-root>/AGENTS.md
    > <subdir>/AGENTS.override.md  >  <subdir>/AGENTS.md
      > (closest-to-$CWD wins by appearing last)
```

### Claude Primitive Mapping

| Claude primitive | Codex equivalent | Enforceability |
|---|---|---|
| `CLAUDE.md` standing instructions | `~/.codex/AGENTS.md` + `.codex/AGENTS.md` (repo root) | Prompt-level (model reads, not OS-enforced) |
| `.claude/rules/*.md` with `paths:` glob | Nested per-directory `AGENTS.md` files | Prompt-level; directory-scoped only, no file-extension glob |

**Flag:** Claude `paths:` file-extension glob scoping has NO mechanically-enforceable Codex equivalent. Must be re-grounded in separate per-directory AGENTS.md files or moved to sandbox configuration.

---

## B. Configuration — `config.toml` Schema

### Location

- **User-level:** `~/.codex/config.toml` (or `$CODEX_HOME/config.toml`)
- **Project-level:** `<repo>/.codex/config.toml` — loaded only if the project `trust_level` is `"trusted"` (default for local repos)
- **Profiles:** `$CODEX_HOME/<profile-name>.config.toml`, selected via `--profile <name>` CLI flag

### Core Model Keys

| Key | Type | Notes |
|---|---|---|
| `model` | string | Model identifier, e.g., `gpt-5.5` |
| `model_provider` | string | Provider ID; defaults to `openai` |
| `model_context_window` | number | Available context tokens |
| `model_auto_compact_token_limit` | number | Token threshold triggering history compaction |

### Approval and Sandbox Policy

| Key | Type | Values / Notes |
|---|---|---|
| `approval_policy` | string or table | `untrusted \| on-request \| never \| { granular = { sandbox_approval, rules, mcp_elicitations, request_permissions, skill_approval } }` |
| `sandbox_mode` | string | `read-only \| workspace-write \| danger-full-access` |
| `sandbox_workspace_write.writable_roots` | array\<string\> | Additional writable paths in workspace-write mode |
| `sandbox_workspace_write.network_access` | boolean | Allow outbound network during sandbox execution |
| `default_permissions` | string | Named permission profile; built-ins: `:read-only`, `:workspace`, `:danger-full-access` |

### Permissions Profiles

```toml
[permissions.<name>]
extends = "<parent-profile>"  # inheritance chain

[permissions.<name>.filesystem]
# path-based read/write/deny rules; supports globs and `:workspace_roots` token

[permissions.<name>.network]
enabled = true  # boolean
# domain allow/blocklist with wildcard support:
#   *.example.com  — subdomains only
#   **.example.com — apex + subdomains
#   *              — allow all

[permissions.<name>.network.unix_sockets]
# unix socket allowlist overrides
```

### MCP Server Configuration

```toml
[mcp_servers.<id>]
command = "..."               # launcher command for stdio server
url = "..."                   # endpoint for HTTP streamable servers
enabled = true                # boolean
enabled_tools = ["tool1"]     # tool allowlist by name
disabled_tools = ["tool2"]    # tool blocklist (applied after allowlist)
default_tools_approval_mode = "auto"  # auto | prompt | approve
```

### Shell Environment

```toml
[shell_environment_policy]
inherit = "all"               # all | core | none
include_only = ["VAR1"]       # whitelist patterns for env vars
exclude = ["SECRET_*"]        # glob patterns removing variables
set = { KEY = "value" }       # explicit environment overrides for subprocesses
```

### Hooks (Inline)

```toml
[hooks]
PreToolUse = [
  { hooks = [ { command = "path/to/script", timeout = 600 } ] }
]
PostToolUse = [...]
SessionStart = [...]
# full event list: SessionStart, SubagentStart, PreToolUse, PermissionRequest,
#                  PostToolUse, PreCompact, PostCompact, UserPromptSubmit,
#                  SubagentStop, Stop
```

Alternatively defined in `~/.codex/hooks.json` or `<repo>/.codex/hooks.json`.

### Notify

```toml
notify = ["path/to/notify-script"]  # array<string>
```

The `notify` program receives a JSON payload from Codex on `stdin`. Exact payload schema is documented as including at minimum `session_id`, `cwd`, `hook_event_name`, and event-specific fields. This is fire-and-forget (see Section C for critical detail).

### Projects Trust

```toml
[projects."<absolute-path>"]
trust_level = "trusted"   # or "untrusted"
```

`untrusted` projects skip all project-scoped `.codex/` config layers, including project-local config, hooks, and rules. This means an untrusted project's `.codex/config.toml`, `.codex/hooks.json`, and `.codex/agents/` are all ignored.

### Agents Global Config

```toml
[agents]
max_threads = 6                 # concurrent open agent thread cap
max_depth = 1                   # spawned agent nesting depth
job_max_runtime_seconds = 3600  # per-worker timeout
```

### Features Toggle

```toml
[features]
hooks = false   # disable hooks entirely
goals = true    # enable goal mode
```

### Enterprise Managed Hooks (`requirements.toml`)

```toml
managed_dir = "/etc/codex/hooks"             # macOS/Linux managed hooks directory
windows_managed_dir = "C:\\codex\\hooks"     # Windows path
allow_managed_hooks_only = true              # ignore user/project hooks
```

When `allow_managed_hooks_only = true`, only hooks in `managed_dir` execute. This is the enterprise enforcement mechanism for hooks.

---

## C. Enforcement — Mechanical Blocking Mechanisms

This section answers the most critical question: which Codex mechanisms are OS/runtime-enforced rather than prompt-based.

### C.1 Sandbox Modes

Three modes; the distinction matters for enforceability:

| Mode | Filesystem | Network | Commands | OS mechanism |
|---|---|---|---|---|
| `read-only` | Read-only; no file writes; no command execution without approval | Off | Requires approval for all writes/exec | macOS: Seatbelt; Linux/WSL2: bubblewrap; Windows: Native Windows Sandbox |
| `workspace-write` (default) | Read/write within project directory and `writable_roots` | Off by default (`network_access = false`) | Routine local commands auto-approved | Same OS mechanisms |
| `danger-full-access` (`--dangerously-bypass-approvals-and-sandbox` / `--yolo`) | Unrestricted | Unrestricted | No approvals, no sandbox | No OS sandbox applied |

**OS mechanism detail:**
- **macOS:** Seatbelt (`sandbox-exec`) — kernel-enforced, per-process policy applied to spawned commands. Subprocess inheritance is confirmed: "the sandbox applies to spawned commands, not just to Codex's built-in file operations. If Codex runs tools like `git`, package managers, or test runners, those commands inherit the same sandbox boundaries."
- **Linux / WSL2:** `bubblewrap` (user-space namespace sandbox). Codex bundles a helper if system `bubblewrap` is unavailable.
- **Windows:** Native Windows Sandbox in PowerShell; Linux `bubblewrap` implementation when running in WSL2.
- **Network access with `network_access = false`:** The documentation confirms this triggers approval prompts when network access is attempted but does not explicitly confirm whether the OS sandbox blocks the kernel-level syscall. The behavior documented is that crossing this boundary surfaces an approval request; whether an unapproved attempt is OS-blocked or simply denied by the approval gate is not stated with certainty.

### C.2 `approval_policy` Values

| Value | Behavior |
|---|---|
| `untrusted` | Pauses before any command that can mutate state or trigger external execution. Read operations auto-approved. |
| `on-request` (default) | Works autonomously within sandbox; prompts only when crossing sandbox boundaries (file writes outside workspace, network access). |
| `never` | Removes all approval prompts. Use with `workspace-write` or `danger-full-access` for fully unattended runs. |
| `{ granular = {...} }` | Selective: `sandbox_approval`, `rules`, `mcp_elicitations`, `request_permissions`, `skill_approval` each independently toggled. |

Approval policy is enforced by the Codex runtime agent, not by the OS sandbox. It is a second layer on top of the sandbox.

### C.3 PreToolUse Hook — Direct Equivalent of Claude PreToolUse

**Yes.** Codex has a programmable PreToolUse hook that can intercept and mechanically block a tool call based on custom logic.

**Exact blocking mechanism:**

A hook script that exits with code `2` causes Codex to deny the tool call. Alternatively, the hook script can output a JSON object on stdout containing `"permissionDecision": "deny"` to block, or `"permissionDecision": "allow"` with an optional `"updatedInput"` field to rewrite the command before execution.

```json
{
  "permissionDecision": "deny",
  "stopReason": "Custom reason surfaced to user"
}
```

**Payload received on stdin (common fields for all hooks):**
- `session_id`
- `transcript_path`
- `cwd`
- `hook_event_name` (value: `"PreToolUse"`)
- `model`
- `turn_id`
- `permission_mode`
- `tool_name` (e.g., `"Bash"`, `"apply_patch"`, or MCP tool name)
- `tool_use_id`
- `tool_input` (full input to the tool, e.g., the shell command string for Bash)

**Matcher (filter by tool name):**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/validator-script",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

`matcher` is a regex applied to `tool_name`. Omit or use `"*"` to match all tools.

**Other blocking-capable events:**
- `PermissionRequest`: Multiple hooks; any `deny` wins. Suitable for policy-gate logic on escalation requests.
- `UserPromptSubmit`: Can block prompts with `"decision": "block"`.
- `Stop` / `SubagentStop`: Return `"decision": "block"` to force continuation rather than stop (not a block per se, but a gate on completion).

**PostToolUse:** Cannot undo a completed action; cannot block. It can replace the tool result in the conversation but the side effect has already occurred.

**Trust requirement:** Non-managed hooks require explicit trust review via the `/hooks` CLI command before they execute. Trust is recorded against the hook's content hash. Any modification triggers re-review. This means a hook author cannot silently change hook behavior without re-trust.

**Bypass:** `--dangerously-bypass-hook-trust` flag runs hooks without persisted trust (for automation use cases).

**Enterprise lock-down:** `allow_managed_hooks_only = true` in `requirements.toml` ignores all user/project hooks and enforces only managed (system-admin-controlled) hooks.

### C.4 `notify` Program — Fire-and-Forget

The `notify` program configured in `config.toml` receives a JSON payload on `stdin` when Codex events fire. Based on the documentation, `notify` is **fire-and-forget (post-event notification only)**. It is explicitly documented as "Commands invoked for notifications" — not as a decision-making gate. There is no documented mechanism by which a `notify` process can block or veto an action. The `notify` key is distinct from `hooks`; only hooks have the `permissionDecision: deny` blocking semantics.

**What events fire `notify`:** The documentation does not enumerate a specific event list for `notify` separately from hooks. It appears to be a simpler notification channel rather than the full lifecycle-hook framework.

**Payload:** The documentation states it "receives a JSON payload from Codex" but does not publish a complete field schema distinct from the hooks payload.

**Conclusion for mapping:** Do not use `notify` as an enforcement gate. Use `PreToolUse` / `PermissionRequest` hooks for blocking.

### C.5 Command Allow/Deny List (Rules)

The glossary defines **Rules** as "Policies that allow, prompt for, or deny command prefixes or permission exceptions." The approval configuration includes a `rules` granular toggle (`approval_policy.granular.rules`). The `--ignore-rules` flag on `codex exec` skips loading execpolicy rule files.

Rules appear to be a prefix/pattern-based allow-prompt-deny mechanism on commands, distinct from (but complementary to) hooks. Full schema for rule files was not returned by the documentation fetcher, but rule files are read from the `.codex/` config layer and are bypassed when the project is untrusted or when `--ignore-rules` is passed.

### C.6 MCP Servers as a Gating Mechanism

MCP servers can serve as an enforcement channel under specific conditions:

- Configure `default_tools_approval_mode = "approve"` on an MCP server to require human approval for every call.
- Use `enabled_tools` / `disabled_tools` to allowlist or blocklist specific MCP tool names at the config level.
- A project-enforced MCP server that wraps all file I/O or all network calls can force every operation of that class through a single chokepoint — the MCP server process — where custom logic can validate, log, or reject.

**Limitation:** This only gates calls that go through that specific MCP server. It does not prevent the model from using the built-in `Bash` tool or `apply_patch` file-write tool directly. Combining MCP gating with `enabled_tools`/`disabled_tools` restrictions on built-in tools would be required to make MCP the sole path for a class of operations — but disabling built-in tools entirely is not documented as possible via config alone; this would require a `PreToolUse` hook blocking the built-in tool.

**Conclusion:** MCP can enforce a chokepoint for external service calls; it cannot replace sandbox + hook enforcement for filesystem operations.

---

## D. Subagents / Multi-Agent

### Native Subagent Mechanism

Codex has a native subagent system. Subagents are defined as TOML files:

- **User-level:** `~/.codex/agents/<name>.toml`
- **Project-level:** `.codex/agents/<name>.toml` (trusted projects only)

Required fields: `name`, `description`, `developer_instructions`.

Optional fields that override the parent session: `model`, `model_reasoning_effort`, `sandbox_mode`, `mcp_servers`, `skills.config`, `nickname_candidates`. Any `config.toml` key is valid in an agent file.

**Three built-in agents ship with Codex:**
- `default` — general-purpose fallback
- `worker` — execution-focused for implementation and fixes
- `explorer` — read-heavy codebase exploration

### Delegation

The parent orchestrator spawns subagents explicitly (user instruction or orchestrator logic required; Codex does not auto-spawn). The orchestrator waits for all results before consolidating.

`max_threads` (default 6) caps concurrent threads. `max_depth` (default 1) limits nesting depth (one level of spawned subagents by default).

### Sandbox and Hooks Inheritance

Subagents inherit the parent session's sandbox policy. Individual agents can override `sandbox_mode` in their TOML file. Approval requests from subagent threads surface with thread labels in interactive mode; in non-interactive mode, unapproved actions fail and return errors to the parent.

### Tool Surface Restriction

There is no documented explicit tool allowlist at the agent TOML level (unlike Claude subagent `tools:` frontmatter). Tool restriction per-agent is achieved indirectly via:
- `skills.config` toggles to enable/disable skill availability.
- Per-agent `mcp_servers` to limit which MCP tools are accessible.
- Agent-level `sandbox_mode` to narrow filesystem/network access.
- `PreToolUse` hooks with matchers that check `session_id` or other context (not documented as per-agent, but feasible).

**Capability gap vs. Claude:** Claude subagents have an explicit `tools:` allowlist in frontmatter. Codex has no equivalent direct tool allowlist at the agent definition level. Sandbox mode + skills config is the closest approximation.

### Claude Primitive Mapping

| Claude primitive | Codex equivalent | Enforceability |
|---|---|---|
| `.claude/agents/*.md` (persona, tools allowlist, model, hooks) | `.codex/agents/<name>.toml` (persona, model, sandbox_mode, mcp_servers) | Partially: model + sandbox OS-enforced; tool surface only indirectly restricted |
| Subagent `tools:` allowlist | No direct equivalent — approximate via sandbox_mode + skills.config | NOT mechanically enforceable via allowlist; sandbox only |
| Subagent `hooks:` | Hooks are session-level, not agent-definition-level (not confirmed as per-agent) | N/A |

---

## E. Skills / Reusable Prompts

### Native Skills Mechanism

Skills are directory packages discovered from these locations in priority order:

1. `$CWD/.agents/skills` — working-directory-specific
2. `$CWD/../.agents/skills` — parent folder (nested repos)
3. `$REPO_ROOT/.agents/skills` — repository-wide
4. `$HOME/.agents/skills` — user personal
5. `/etc/codex/skills` — system admin skills
6. Bundled with Codex — OpenAI system skills

Each skill is a directory containing:
- `SKILL.md` (required): YAML frontmatter with `name` and `description`; markdown body with instructions
- `scripts/` (optional): executable code
- `references/` (optional): documentation
- `assets/` (optional): templates
- `agents/openai.yaml` (optional): UI metadata and tool dependencies

### Invocation

- **Explicit:** `/skills` command or `$` mention in CLI/IDE
- **Implicit:** Codex auto-selects matching skills based on task description (based on name/description loaded at ~2% of context window)

### Path of SKILL.md

```yaml
---
name: skill-name
description: When skill triggers and its boundaries
---

Instructions for Codex follow here.
```

The `SKILL.md` format is structurally similar to Claude's `.claude/skills/<name>/SKILL.md` with `name` and `description` fields. Claude additionally uses `allowed-tools`, `context`, and `agent` frontmatter fields; these have no documented Codex equivalent.

### No Slash Command / `~/.codex/prompts/` Directory

No `~/.codex/prompts/*.md` directory or slash command system was found in the documentation. Skills are the reusable-prompt mechanism. There are no standalone prompt templates separate from skills.

### Claude Primitive Mapping

| Claude primitive | Codex equivalent | Enforceability |
|---|---|---|
| `.claude/skills/<name>/SKILL.md` (name, description, allowed-tools, context, agent) | `.agents/skills/<name>/SKILL.md` (name, description only) | Prompt-level for instructions; allowed-tools has NO equivalent |
| `allowed-tools` in skill frontmatter | No direct equivalent | NOT mechanically enforceable |
| `context: fork` with `agent:` routing | Skill can include `agents/openai.yaml` for UI metadata; no `context: fork` semantics | NOT equivalent |

---

## F. CI / Out-of-Band Enforcement

### For Claude SubagentStop Hook Equivalents

Claude SubagentStop hooks run custom scripts on subagent completion to validate outputs before the result is used. In Codex, the `SubagentStop` hook event exists and can use `"decision": "block"` to force continuation. However, for completion-gate validation that must be externally enforced (not dependent on model behavior), the following patterns are idiomatic in Codex:

#### 1. `codex exec` Exit Code in CI

`codex exec` streams progress to stderr and the final agent message to stdout. Exit code 0 = success, non-zero = failure. A wrapper script can:

```bash
codex exec --sandbox workspace-write "run the test suite and fix failures" \
  && ./scripts/validate-output.sh \
  || exit 1
```

The validation script runs after `codex exec` completes and can reject the output before the CI job succeeds.

#### 2. `openai/codex-action` GitHub Action with Required Status Checks

```yaml
- uses: openai/codex-action@v1
  with:
    openai-api-key: ${{ secrets.OPENAI_API_KEY }}
    prompt-file: .github/codex/prompts/task.md
    output-file: codex-output.md
    sandbox: workspace-write

- name: Validate completion gate
  run: ./scripts/validate-completion-gate.sh codex-output.md
```

Making this job a **required GitHub Actions status check** on the branch provides mechanical enforcement: the branch cannot merge unless the completion gate passes. This is the closest equivalent to a blocking SubagentStop hook in a CI context.

#### 3. `SubagentStop` Hook (In-Process)

For in-process enforcement during a `codex exec` run, the `SubagentStop` hook event can run a script. If the script returns `"decision": "block"`, Codex creates a continuation prompt for the agent rather than completing the turn. This does not "reject" the output but forces the agent to continue working.

#### 4. Git Pre-Commit Hooks

For rules that must apply to every commit regardless of tool used, git pre-commit hooks (via `pre-commit` framework or direct `.git/hooks/pre-commit`) provide enforcement independent of Codex.

#### 5. `PostToolUse` Hook for Audit/Logging

`PostToolUse` runs after every tool call and can capture audit trails. It cannot block the completed action but can log, alert, or write evidence artifacts.

### Claude Primitive Mapping

| Claude primitive | Codex equivalent | Enforceability |
|---|---|---|
| `SubagentStop` blocking hook (validates completion, blocks bad output) | `SubagentStop` hook with `decision: block` (forces continuation, not rejection) + required GitHub Actions status check | Partial: in-process hook forces re-try; CI status check enforces merge gate |
| `PreToolUse` blocking hook | `PreToolUse` hook with exit code 2 or `permissionDecision: deny` | Direct equivalent — mechanically enforced |

---

## Primitive-to-Primitive Mapping Summary

| Claude primitive | Codex-native equivalent | Mechanical enforceability | Gap / action required |
|---|---|---|---|
| `CLAUDE.md` standing instructions | `~/.codex/AGENTS.md` + `<repo>/.codex/AGENTS.md` / `AGENTS.md` at repo root | Prompt-level only | No OS enforcement; same level as Claude |
| `.claude/rules/*.md` with `paths:` file-extension glob | Nested per-directory `AGENTS.md` files | Prompt-level; directory-scoped | **No file-extension glob equivalent.** Must use per-directory AGENTS.md or move to sandbox restrictions. |
| `.claude/skills/<name>/SKILL.md` | `.agents/skills/<name>/SKILL.md` | Prompt-level | `allowed-tools` / `context` / `agent` fields have no Codex equivalent. |
| Skill `allowed-tools` frontmatter | No direct equivalent | **NOT mechanically enforceable** | Re-ground in sandbox mode + `disabled_tools` on MCP servers |
| `.claude/agents/*.md` (persona, model, tools, hooks) | `.codex/agents/<name>.toml` (persona, model, sandbox_mode, mcp_servers) | Model + sandbox OS-enforced; tools only indirectly restricted | No per-agent tool allowlist; use sandbox_mode + skills.config |
| `.claude/settings.json` `permissions` allow/deny globs | `permissions.<name>` profiles in `config.toml` with filesystem and network rules | OS-enforced via sandbox | Directly equivalent; Codex permissions profiles are more expressive |
| `PreToolUse` hook (blocks by non-zero exit / block decision) | `PreToolUse` hook (exit code 2 or `permissionDecision: deny`) | OS-process-enforced — direct equivalent | No gap; exact functional equivalent |
| `SubagentStop` hook (completion gate, block decision) | `SubagentStop` hook (`decision: block` forces continuation) + required CI status check | Partial: in-process re-try gate; external merge gate via required GH Actions check | SubagentStop forces re-try rather than hard rejection; use CI gate for hard rejection |
| Claude `hooks` blocking (non-zero exit = block) | Codex hooks exit code 2 = deny/block | Process-exit-enforced | Same semantics; document the `2` vs non-zero distinction |

---

## Automation Feasibility

This section assesses whether configuring all documented Codex primitives can be performed unattended via file edits and CLI commands, with no third-party UI clicks required.

| Configuration surface | File editable? | CLI configurable? | UI required? | Assessment |
|---|---|---|---|---|
| `~/.codex/config.toml` (all keys) | Yes — plain TOML, write programmatically | Partially via `--config key=value` at runtime | No | **Fully automatable** |
| `<repo>/.codex/config.toml` | Yes — checked into repository | N/A (file-based) | No | **Fully automatable** |
| `~/.codex/AGENTS.md`, `AGENTS.md` | Yes — plain Markdown | N/A (file-based) | No | **Fully automatable** |
| `.agents/skills/<name>/SKILL.md` | Yes — plain Markdown/YAML | N/A (file-based) | No | **Fully automatable** |
| `.codex/agents/<name>.toml` | Yes — plain TOML | N/A (file-based) | No | **Fully automatable** |
| `hooks.json` or `[hooks]` in config.toml | Yes — plain JSON/TOML | N/A (file-based) | No | **Automatable; hook trust requires `/hooks` CLI command or `--dangerously-bypass-hook-trust` flag for first run** |
| `requirements.toml` (enterprise managed hooks) | Yes — plain TOML | N/A (file-based) | No (requires admin file placement) | **Automatable for enterprise deployment via MDM/config management** |
| `mcp_servers` config | Yes — in `config.toml` | Partially via `--config` | No | **Fully automatable** |
| GitHub Action (`openai/codex-action`) | Yes — workflow YAML | N/A (file-based) | No | **Fully automatable via YAML** |
| `projects.<path>.trust_level` | Yes — in user-level `config.toml` | No CLI flag for this | No | **Automatable; must be set in user config, not project config** |
| Hook trust (first-time review) | No — requires interactive `/hooks` CLI command | `--dangerously-bypass-hook-trust` bypasses for CI | UI-based first run | **Partial: `--dangerously-bypass-hook-trust` enables unattended CI; interactive sessions require one-time trust review** |
| Codex App UI settings (App-specific) | Unknown (App-specific, likely UI-only) | Unknown | Likely yes | **Out of scope for CLI-based automation** |

**Overall verdict:** All enforcement-critical surfaces (sandbox mode, permissions profiles, hooks, AGENTS.md, skills, agents, MCP) are file-based and fully automatable via file writes and CLI flags. The only friction point is first-time hook trust for interactive sessions, which is bypassed by `--dangerously-bypass-hook-trust` in CI contexts.

---

## Key Findings Summary

1. **PreToolUse hooks are a direct mechanical equivalent** of Claude PreToolUse hooks. Exit code 2 or `permissionDecision: deny` blocks the tool call at the process level.

2. **Sandbox modes are OS-enforced** (macOS Seatbelt, Linux bubblewrap, Windows Sandbox) and apply to all spawned subprocesses. `workspace-write` with `network_access = false` is the recommended baseline.

3. **The `notify` program is fire-and-forget.** It cannot veto actions. Use hooks, not notify, for enforcement gates.

4. **AGENTS.md has no file-extension glob scoping.** Claude's `paths:` frontmatter glob has no Codex equivalent. Directory-presence nesting is the only path-scope mechanism.

5. **Subagents have no explicit tool allowlist.** Claude subagent `tools:` frontmatter has no Codex equivalent. Approximate via `sandbox_mode` + `skills.config` + `disabled_tools` on MCP servers.

6. **Skill `allowed-tools` and `context: fork` have no Codex equivalents.** These must be re-grounded in sandbox config or MCP gating.

7. **SubagentStop as a hard rejection gate requires a CI layer.** The Codex `SubagentStop` hook with `decision: block` forces the agent to continue rather than rejecting the output externally. Use a required GitHub Actions status check for hard merge-gate enforcement.

8. **Permissions profiles in `config.toml` are more expressive than Claude `settings.json` permissions.** They support filesystem glob rules, network domain allowlists, profile inheritance, and per-agent overrides.

9. **Enterprise lock-down via `allow_managed_hooks_only = true`** is the Codex equivalent of Claude's project-level hook enforcement — it prevents user/project hook overrides.

10. **All configuration surfaces are file-based and fully automatable** except first-time interactive hook trust, which is bypassed in CI via `--dangerously-bypass-hook-trust`.
