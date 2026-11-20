# Mapping Copilot Orchestration to Claude Code

## Concept Mapping

| Copilot Concept | Claude Code Equivalent | Notes |
|---|---|---|
| `.github/copilot-instructions.md` | `CLAUDE.md` (repo root) | Auto-loaded every session |
| `.github/instructions/general-code-change.instructions.md` | `CLAUDE.md` (repo root) | Auto-loaded every session |
| `.github/instructions/general-unit-test.instructions.md` | `CLAUDE.md` (repo root) | Auto-loaded every session |
| `.github/instructions/self-explanatory-code-commenting.instructions.md` | `CLAUDE.md` (repo root) | Auto-loaded every session |
| `.github/instructions/self-explanatory-code-commenting.instructions.md` | `CLAUDE.md` (repo root) | Auto-loaded every session |
| `.github/instructions/*.instructions.md` | `CLAUDE.md` files in subdirectories by language type | Auto-loaded when working in that directory |
| `.github/agents/*.agent.md` (orchestrators) | `.claude/commands/*.md` (custom slash commands) | User-invocable entry points via `/command-name` |
| `.github/agents/*.agent.md` (specialists) | Agent definition files read at delegation time | Orchestrator reads the file and passes contents as sub-agent prompt via `Agent` tool |
| `.github/prompts/*.prompt.md` | `.claude/commands/*.md` or agent definition files | Commands if user-invoked; definition files if delegated to |
| `.github/skills/*/SKILL.md` | Inline in `CLAUDE.md` or referenced from commands | No direct skill primitive; embed or reference |
| `handoffs:` (agent frontmatter) | Delegation protocol in orchestrator command | Orchestrator reads agent file + enriches with task context + spawns via `Agent` tool |
| `${variable}` substitution | `$ARGUMENTS` in commands | One argument string, not named params |
| Bypass Approvals | Permission allowlist in `settings.json` | Granular per-tool pattern |
| State machine / checkpoint JSON | File-based checkpoint (same pattern — you write it yourself) | Works identically |
| Long-running 4-hour sessions | `/loop` + context compression | Context auto-compresses; no hard time limit |

## What You Need to Set Up

### Layer 1: Base Instructions (`CLAUDE.md`)

This replaces `copilot-instructions.md` + `*.instructions.md` files. Create a `CLAUDE.md` at the repo root that establishes:

- Tone policy (existing)
- Policy compliance order (existing skill)
- Hard constraints
- Language-specific policies (reference the instruction files or inline them)
- The orchestration state machine protocol
- The handoff contract rules

You can also place `CLAUDE.md` files in subdirectories. For example, `scripts/powershell/CLAUDE.md` for PowerShell-specific instructions, `extensions/drm-copilot/CLAUDE.md` for TypeScript instructions. These are automatically included when Claude works in those directories.

### Layer 2: Commands vs Agent Definitions

Claude Code agents and prompts split into two categories based on how they are invoked.

#### Commands (`.claude/commands/`) — User-Invocable Entry Points

Each `.md` file in `.claude/commands/` becomes a `/command-name` in chat. These are the orchestrators and user-facing prompts — things you kick off directly.

```
.claude/commands/
├── orchestrate.md              # Main orchestrator (replaces orchestrator.agent.md)
├── orchestrate-powershell.md   # PowerShell-specific orchestrator
├── commit-message.md           # commit_steward (user-invoked)
├── pr-author.md                # pr-author (user-invoked)
└── research-issue.md           # task researcher (user-invoked)
```

#### Agent Definitions — Delegation Targets

Specialist agents that the orchestrator delegates to are NOT commands. They are definition files that the orchestrator reads at delegation time and passes as the sub-agent prompt via the `Agent` tool. These can remain in their current location (`.github/agents/`) or be placed under `.claude/agents/` — the location does not matter since they are read by path, not registered with the runtime.

```
.github/agents/                 # Existing location works fine
├── atomic_planning.agent.md    # Read by orchestrator, passed as sub-agent prompt
├── atomic_executor.agent.md    # Read by orchestrator, passed as sub-agent prompt
├── feature-review.agent.md     # Read by orchestrator, passed as sub-agent prompt
├── python-typed-engineer.agent.md
├── powershell-typed-engineer.agent.md
├── prd-feature.agent.md
└── task-researcher.agent.md
```

The orchestrator's delegation protocol reads the agent file, enriches it with task-specific context (feature-folder, plan-path, constraints), and spawns a sub-agent.

#### Sub-Agent Customization

When the orchestrator spawns a sub-agent via the `Agent` tool, it can customize:

| Parameter | Purpose | Example |
|---|---|---|
| `prompt` | Full persona + task context (from agent definition file + runtime variables) | Contents of `atomic_planning.agent.md` + feature-folder path + spec path |
| `subagent_type` | Built-in type controlling available tools | `general-purpose` (default), `Explore`, `Plan` |
| `model` | Model override per sub-agent | `sonnet` for simpler tasks, `opus` for complex planning |
| `isolation` | Git worktree isolation | `"worktree"` for safe parallel execution |
| `run_in_background` | Blocking vs parallel execution | `true` for independent tasks that can run simultaneously |

What cannot be customized per sub-agent:
- Tool access lists (all sub-agents of a given type share the same tools)
- Named custom agent types (no custom `subagent_type` registry)
- Persistent memory across spawns (each spawn is stateless; use checkpoint files)

### Layer 3: Permission Configuration

Copilot "Bypass Approvals" maps to the `permissions.allow` array in `~/.claude/settings.json`. To get near-autonomous execution, expand this significantly.

You can also create a project-level settings file at `.claude/settings.json` in the repo (committed, shared) for repo-specific permissions.

The permission patterns support:

- `Bash(git *)` — allow all git commands
- `Bash(poetry run *)` — allow poetry commands
- `Bash(pwsh *)` — allow PowerShell
- `Edit(docs/**)` — allow edits in docs
- `Edit(scripts/**)` — allow edits in scripts
- `Write(docs/**)` — allow new files in docs
- `mcp__drmcopilotextension__*` — allow all MCP tools from the extension

For truly autonomous operation, `Bash(*)` removes all guardrails. A more measured approach is to allowlist the specific patterns the orchestration needs.

### Layer 4: Orchestration Command with Delegation Protocol

The orchestration logic lives in a single command (`.claude/commands/orchestrate.md`), but specialist agent definitions remain as separate files. The orchestrator reads them at delegation time rather than inlining their content.

`.claude/commands/orchestrate.md` would look structurally like:

```markdown
# Orchestrator

You are an orchestration-only agent. Your job is to receive a user request
and route work to the correct specialist sub-agents until the mission is complete.

## Delegation Protocol

When delegating to a specialist agent:
1. Read the agent definition file from `.github/agents/<agent-name>.agent.md`
2. Read any referenced skill files from `.github/skills/<skill-name>/SKILL.md`
3. Spawn a sub-agent using the Agent tool with:
   - prompt: the agent file contents + task-specific context
     (feature-folder, plan-path, spec-path, constraints, etc.)
   - subagent_type: "general-purpose" (default)
   - model: use default unless the agent file specifies otherwise
4. Wait for the sub-agent result before proceeding
5. Do not proceed past a delegation step until the sub-agent returns
   the required completion signal

## State Machine
[checkpoint protocol — same as powershell-orchestration-state-machine skill]

## Phase 0 — Intake and Budget Estimate
[same logic as orchestrator.agent.md Phase 0]

## Small Path (budget 1-3)
### Step S1 — Scope
[instructions]
### Step S3 — Create Plan
Delegate to `.github/agents/atomic_planning.agent.md`:
- Read the agent file and pass as sub-agent prompt
- Include: feature-folder, plan-path, issue.md path
- Required signal: PREFLIGHT: ALL CLEAR

### Step S5 — Execute
Delegate to `.github/agents/atomic_executor.agent.md`:
- Read the agent file and pass as sub-agent prompt
- Include: approved plan-path, feature-folder, constraints

### Step S8 — Audit
Delegate to `.github/agents/feature-review.agent.md`:
- Read the agent file and pass as sub-agent prompt
- Include: feature-folder, base branch
- If remediation triggered:
  1. Delegate to atomic_planning for remediation plan
  2. Delegate to atomic_executor for remediation execution
  3. Re-delegate to feature-review for re-audit
  4. Loop until clean audit

## Large Path
[same structure with additional delegation steps for research, spec, etc.]
```

### Layer 5: Continuous Execution (`/loop`)

For 4-hour uninterrupted sessions, Claude Code has `/loop`. Invoke:

```
/loop /orchestrate <objective here>
```

This runs the orchestrator command repeatedly, and the state machine checkpoint file ensures it picks up where it left off each iteration. Context compression handles the long conversation automatically.

Alternatively, without `/loop`, a single long session works — Claude Code does not have a hard turn limit, and context compression keeps the window manageable.

## Key Architectural Differences

1. **No native agent persistence between sub-agent spawns.** Each `Agent` tool call starts fresh. The sub-agent does not remember previous invocations. The checkpoint JSON file handles this (same as the current approach).

2. **No typed handoff contracts.** Copilot's `handoffs:` frontmatter gives a declarative delegation protocol with typed labels, agent references, and prompt templates. In Claude Code, the equivalent is encoded as orchestrator instructions — "read `.github/agents/atomic_planning.agent.md`, spawn a sub-agent with its contents, and do not proceed until it returns `PREFLIGHT: ALL CLEAR`." Claude follows these reliably, but it is instruction-driven rather than runtime-enforced metadata.

3. **No auto-attached instructions by file pattern.** Copilot's `.github/instructions/python-code-change.instructions.md` auto-attaches when Python files are in scope. In Claude Code, either put this in the root `CLAUDE.md` (always loaded) or in a subdirectory `CLAUDE.md` (loaded when working in that directory). For dynamic attachment based on file type, include the logic in the orchestrator instructions: "When working on Python files, apply these rules: ..."

4. **Sub-agent tool access is type-based, not per-agent.** Copilot agents declare their `tools:` list individually. Claude Code sub-agents get tools based on their `subagent_type` (e.g., `general-purpose` gets all tools). Scope narrowing is controlled through prompt instructions to the sub-agent, not through tool allowlists.

5. **Variable substitution is prompt-driven.** Copilot uses `${file}`, `${spec}`, etc. as named template parameters. Claude Code commands get `$ARGUMENTS` as a single string. The orchestrator tracks variables internally (in the checkpoint JSON and in-context) and interpolates them into the sub-agent prompt when spawning.

6. **Agent definitions are prompt source material, not runtime declarations.** The `.github/agents/*.agent.md` files are read by the orchestrator and passed as prompt content to the `Agent` tool. They do not register with the Claude Code runtime. This means agent files can live anywhere, use any format, and be composed freely — but there is no runtime validation that the correct agent was delegated to.

## Concrete Next Steps

1. **Create `CLAUDE.md`** at repo root — port tone policy, policy compliance order, hard constraints, and language-specific instructions.

2. **Create `.claude/commands/orchestrate.md`** — adapt `orchestrator.agent.md` with a delegation protocol that reads agent definition files and spawns sub-agents via the `Agent` tool.

3. **Keep existing agent definitions in `.github/agents/`** — these remain as-is. The orchestrator command references them by path when delegating. No need to duplicate or move them.

4. **Create user-invocable commands only for direct-use agents** — `commit-message.md`, `pr-author.md`, and other agents that a user kicks off directly (not via orchestration) become `.claude/commands/` entries.

5. **Expand `settings.json` permissions** — add the tool patterns the orchestration needs to run without interruption.

6. **Test with a small-path run** — invoke `/orchestrate <small scope objective>` and observe where it pauses for approval (then add those patterns to permissions).
